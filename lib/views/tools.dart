import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/about.dart';
import 'package:fl_clash/views/access.dart';
import 'package:fl_clash/views/application_setting.dart';
import 'package:fl_clash/views/config/config.dart';
import 'package:fl_clash/views/hotkey.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' show dirname, join;

import 'config/advanced.dart';
import 'developer.dart';

class ToolsView extends ConsumerStatefulWidget {
  final bool settingsRoot;

  const ToolsView({super.key, this.settingsRoot = false});

  @override
  ConsumerState<ToolsView> createState() => _ToolViewState();
}

class _ToolViewState extends ConsumerState<ToolsView> {
  Widget _buildNavigationMenuItem(NavigationItem navigationItem) {
    return ListItem.open(
      leading: navigationItem.icon,
      title: Text(Intl.message(navigationItem.label.name)),
      subtitle: navigationItem.description != null
          ? Text(Intl.message(navigationItem.description!))
          : null,
      widget: navigationItem.builder(context),
      maxWidth: 400,
      forceFull: false,
    );
  }

  _SettingsSection _getAppearanceList() {
    return _SettingsSection(
      title: context.appLocalizations.appearanceSettings,
      isFirst: true,
      items: const [DarkModeItem()],
    );
  }

  _SettingsSection _getProxyAndNetworkList(
    List<NavigationItem> navigationItems,
  ) {
    return _SettingsSection(
      title: context.appLocalizations.proxyAndNetwork,
      items: [
        const _ConfigItem(),
        const _AdvancedConfigItem(),
        if (system.isAndroid) const _AccessItem(),
        if (system.isWindows) const _LoopbackItem(),
        const CloseConnectionsItem(),
        const UsageItem(),
        ...navigationItems.map(_buildNavigationMenuItem),
      ],
    );
  }

  _SettingsSection _getAdvancedFeaturesList(
    List<NavigationItem> navigationItems,
  ) {
    return _SettingsSection(
      title: context.appLocalizations.advancedFeatures,
      items: navigationItems.map(_buildNavigationMenuItem).toList(),
    );
  }

  _SettingsSection _getSystemList() {
    return _SettingsSection(
      title: context.appLocalizations.system,
      items: [
        const _LocaleItem(),
        if (system.isDesktop) const _HotkeyItem(),
        if (system.isDesktop) const MinimizeItem(),
        if (system.isDesktop) const AutoLaunchItem(),
        if (system.isDesktop) const SilentLaunchItem(),
        const AutoRunItem(),
      ],
    );
  }

  _SettingsSection _getOtherList(bool enableDeveloperMode) {
    return _SettingsSection(
      title: context.appLocalizations.other,
      items: [
        const OpenLogsItem(),
        if (system.isAndroid) const CrashlyticsItem(),
        const AutoCheckUpdateItem(),
        if (enableDeveloperMode) const _DeveloperItem(),
        const _InfoItem(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final enableDeveloperMode = ref.watch(
      appSettingProvider.select((state) => state.developerMode),
    );
    final navigationItems = ref.watch(
      moreToolsSelectorStateProvider.select((state) => state.navigationItems),
    );
    final isMobile = ref.watch(isMobileViewProvider);
    final sections = [
      _getAppearanceList(),
      _getProxyAndNetworkList(isMobile ? navigationItems : const []),
      if (!isMobile && navigationItems.isNotEmpty)
        _getAdvancedFeaturesList(navigationItems),
      _getSystemList(),
      _getOtherList(enableDeveloperMode),
    ];
    final list = ListView.separated(
      key: toolsStoreKey,
      itemCount: sections.length,
      itemBuilder: (_, index) => sections[index],
      separatorBuilder: (_, _) => const _SettingsSectionDivider(),
      padding: isMobile
          ? const EdgeInsets.only(bottom: 20)
          : const EdgeInsets.fromLTRB(32, 16, 32, 40),
    );
    return CommonScaffold(
      title: widget.settingsRoot
          ? context.appLocalizations.settings
          : context.appLocalizations.tools,
      body: isMobile
          ? list
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: list,
              ),
            ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.items,
    this.isFirst = false,
  });

  final String title;
  final List<Widget> items;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width > 600;
    return Column(
      children: [
        ListHeader(
          title: title,
          padding: isFirst
              ? listHeaderPadding.copyWith(top: 8.ap)
              : listHeaderPadding,
        ),
        Material(
          color: context.tDesign.container,
          borderRadius: desktop ? BorderRadius.circular(9) : null,
          clipBehavior: desktop ? Clip.antiAlias : Clip.none,
          child: Column(
            children: items
                .separated(
                  Divider(height: 0, color: context.tDesign.componentStroke),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsSectionDivider extends StatelessWidget {
  const _SettingsSectionDivider();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.tDesign.pageBackground,
      child: const SizedBox(height: 12),
    );
  }
}

class _LocaleItem extends ConsumerWidget {
  const _LocaleItem();

  String _getLocaleString(BuildContext context, Locale? locale) {
    if (locale == null) return context.appLocalizations.defaultText;
    return Intl.message(locale.toString());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(
      appSettingProvider.select((state) => state.locale),
    );
    final subTitle = locale ?? context.appLocalizations.defaultText;
    final currentLocale = utils.getLocaleForString(locale);
    return ListItem<Locale?>.options(
      leading: const Icon(Icons.language_outlined),
      title: Text(context.appLocalizations.language),
      subtitle: Text(Intl.message(subTitle)),
      dialogTitle: context.appLocalizations.language,
      options: [null, ...AppLocalizations.delegate.supportedLocales],
      onChanged: (Locale? locale) {
        ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(locale: locale?.toString()));
      },
      textBuilder: (locale) => _getLocaleString(context, locale),
      value: currentLocale,
    );
  }
}

class _HotkeyItem extends StatelessWidget {
  const _HotkeyItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.keyboard),
      title: Text(context.appLocalizations.hotkeyManagement),
      subtitle: Text(context.appLocalizations.hotkeyManagementDesc),
      widget: const HotKeyView(),
    );
  }
}

class _LoopbackItem extends StatelessWidget {
  const _LoopbackItem();

  @override
  Widget build(BuildContext context) {
    return ListItem(
      leading: const Icon(Icons.lock),
      title: Text(context.appLocalizations.loopback),
      subtitle: Text(context.appLocalizations.loopbackDesc),
      onTap: () {
        windows?.runas(
          '"${join(dirname(Platform.resolvedExecutable), "EnableLoopback.exe")}"',
          '',
        );
      },
    );
  }
}

class _AccessItem extends StatelessWidget {
  const _AccessItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.view_list),
      title: Text(context.appLocalizations.accessControl),
      subtitle: Text(context.appLocalizations.accessControlDesc),
      widget: const AccessView(),
    );
  }
}

class _ConfigItem extends StatelessWidget {
  const _ConfigItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.edit),
      title: Text(context.appLocalizations.basicConfig),
      subtitle: Text(context.appLocalizations.basicConfigDesc),
      widget: const ConfigView(),
    );
  }
}

class _AdvancedConfigItem extends StatelessWidget {
  const _AdvancedConfigItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.build),
      title: Text(context.appLocalizations.advancedConfig),
      subtitle: Text(context.appLocalizations.advancedConfigDesc),
      widget: const AdvancedConfigView(),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.info),
      title: Text(context.appLocalizations.about),
      widget: const AboutView(),
    );
  }
}

class _DeveloperItem extends StatelessWidget {
  const _DeveloperItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.developer_board),
      title: Text(context.appLocalizations.developerMode),
      widget: const DeveloperView(),
    );
  }
}
