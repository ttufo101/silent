import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/feedback/views/diagnostic_upload_view.dart';
import 'package:fl_clash/feedback/views/feedback_view.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/about.dart';
import 'package:fl_clash/views/access.dart';
import 'package:fl_clash/views/application_setting.dart';
import 'package:fl_clash/views/connection/connections.dart';
import 'package:fl_clash/views/hotkey.dart';
import 'package:fl_clash/views/routing_domain_rules.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' show dirname, join;

import 'developer.dart';

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/settings/$name.svg',
      width: 24,
      height: 24,
    );
  }
}

class ToolsView extends ConsumerStatefulWidget {
  final bool settingsRoot;

  const ToolsView({super.key, this.settingsRoot = false});

  @override
  ConsumerState<ToolsView> createState() => _ToolViewState();
}

class _ToolViewState extends ConsumerState<ToolsView> {
  var _selectedDesktopSection = 0;

  _SettingsSection _getAppearanceList() {
    return _SettingsSection(
      title: context.appLocalizations.appearanceSettings,
      isFirst: true,
      items: const [DarkModeItem(), _LocaleItem()],
    );
  }

  _SettingsSection _getProxyRulesList() {
    return _SettingsSection(
      title: context.appLocalizations.proxyRules,
      items: [
        const _RoutingDomainItem(type: RoutingDomainType.proxy),
        const _RoutingDomainItem(type: RoutingDomainType.direct),
        const _ConnectionsItem(),
        if (system.isWindows) const _LoopbackItem(),
        if (system.isAndroid) const _AccessItem(),
      ],
    );
  }

  _SettingsSection _getSystemList() {
    return _SettingsSection(
      title: context.appLocalizations.systemSettings,
      items: [
        if (system.isDesktop) const _HotkeyItem(),
        if (system.isDesktop) const MinimizeItem(),
        if (system.isDesktop) const AutoLaunchItem(),
        if (system.isDesktop) const SilentLaunchItem(),
        const AutoRunItem(),
        const CloseConnectionsItem(),
        if (system.isAndroid || system.isWindows)
          const AutoCheckUpdateItem(),
      ],
    );
  }

  _SettingsSection _getFeedbackHelpList() {
    return _SettingsSection(
      title: context.appLocalizations.feedbackAndHelp,
      preserveHeaderStyle: true,
      items: const [
        _DiagnosticLogsItem(),
        _FeedbackItem(),
      ],
    );
  }

  _SettingsSection _getAboutList(bool enableDeveloperMode) {
    return _SettingsSection(
      title: context.appLocalizations.about,
      preserveHeaderStyle: true,
      items: [
        const _InfoItem(),
        if (enableDeveloperMode) const _DeveloperItem(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final enableDeveloperMode = ref.watch(
      appSettingProvider.select((state) => state.developerMode),
    );
    final isMobile = ref.watch(isMobileViewProvider);
    final sections = [
      _getAppearanceList(),
      _getProxyRulesList(),
      _getSystemList(),
      _getFeedbackHelpList(),
      _getAboutList(isMobile ? false : enableDeveloperMode),
    ];
    if (isMobile) {
      final list = ListView.separated(
        key: toolsStoreKey,
        itemCount: sections.length,
        itemBuilder: (_, index) => sections[index],
        separatorBuilder: (_, _) => const _SettingsSectionDivider(),
        padding: const EdgeInsets.only(bottom: 20),
      );
      return CommonScaffold(
        title: widget.settingsRoot
            ? context.appLocalizations.settings
            : context.appLocalizations.tools,
        centerTitle: true,
        body: list,
      );
    }
    final selectedIndex = _selectedDesktopSection.clamp(0, sections.length - 1);
    return Scaffold(
      backgroundColor: context.tDesign.pageBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 216,
                    child: Material(
                      color: context.tDesign.container,
                      borderRadius: BorderRadius.circular(9),
                      clipBehavior: Clip.antiAlias,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: sections.length,
                        itemBuilder: (context, index) {
                          return _DesktopSettingsCategory(
                            label: sections[index].title,
                            selected: index == selectedIndex,
                            onTap: () {
                              setState(() => _selectedDesktopSection = index);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ListTileTheme(
                      data: const ListTileThemeData(
                        dense: true,
                        minVerticalPadding: 8,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 160),
                        child: ListView(
                          key: ValueKey(sections[selectedIndex].title),
                          children: [sections[selectedIndex]],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopSettingsCategory extends StatelessWidget {
  const _DesktopSettingsCategory({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: AlignmentDirectional.centerStart,
        color: selected ? context.colorScheme.primaryContainer : null,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            color: selected
                ? context.colorScheme.primary
                : context.colorScheme.onSurface,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
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
    this.preserveHeaderStyle = false,
  });

  final String title;
  final List<Widget> items;
  final bool isFirst;
  final bool preserveHeaderStyle;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width > 600;
    return Column(
      children: [
        if (preserveHeaderStyle)
          ListHeader(
            title: title,
            padding: isFirst
                ? listHeaderPadding.copyWith(top: 8.ap)
                : listHeaderPadding,
          )
        else
          Container(
            alignment: AlignmentDirectional.centerStart,
            padding: EdgeInsets.fromLTRB(16, isFirst ? 12 : 16, 16, 8),
            child: Text(
              title,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        IconTheme(
          data: IconThemeData(color: context.colorScheme.primary, size: 24),
          child: ListTileTheme(
            data: ListTileThemeData(
              iconColor: context.colorScheme.primary,
              minVerticalPadding: desktop ? 8 : 10,
              horizontalTitleGap: 12,
              titleTextStyle: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
              subtitleTextStyle: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            child: Material(
              color: context.tDesign.container,
              borderRadius: desktop ? BorderRadius.circular(9) : null,
              clipBehavior: desktop ? Clip.antiAlias : Clip.none,
              child: Column(
                children: items
                    .separated(
                      Divider(
                        height: 0,
                        indent: 16,
                        color: context.tDesign.componentStroke,
                      ),
                    )
                    .toList(),
              ),
            ),
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
      leading: const _SettingsIcon('translate'),
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
      leading: const _SettingsIcon('access_control'),
      title: Text(context.appLocalizations.accessControl),
      subtitle: Text(context.appLocalizations.accessControlDesc),
      widget: const AccessView(),
    );
  }
}

class _RoutingDomainItem extends StatelessWidget {
  const _RoutingDomainItem({required this.type});

  final RoutingDomainType type;

  @override
  Widget build(BuildContext context) {
    final isProxy = type == RoutingDomainType.proxy;
    return ListItem.open(
      leading: _SettingsIcon(isProxy ? 'proxy_domains' : 'direct_domains'),
      title: Text(
        isProxy
            ? context.appLocalizations.customProxyDomains
            : context.appLocalizations.customDirectDomains,
      ),
      subtitle: Text(
        isProxy
            ? context.appLocalizations.customProxyDomainsDesc
            : context.appLocalizations.customDirectDomainsDesc,
      ),
      widget: RoutingDomainRulesView(type: type),
    );
  }
}

class _ConnectionsItem extends StatelessWidget {
  const _ConnectionsItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const _SettingsIcon('connections'),
      title: Text(context.appLocalizations.connections),
      subtitle: Text(context.appLocalizations.connectionsDesc),
      widget: const ConnectionsView(),
    );
  }
}

class _DiagnosticLogsItem extends StatelessWidget {
  const _DiagnosticLogsItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const _SettingsIcon('diagnostic_logs'),
      title: Text(context.appLocalizations.uploadDiagnosticLogs),
      subtitle: Text(context.appLocalizations.uploadDiagnosticLogsDesc),
      widget: const DiagnosticUploadView(),
      maxWidth: 400,
      forceFull: false,
    );
  }
}

class _FeedbackItem extends StatelessWidget {
  const _FeedbackItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const _SettingsIcon('feedback'),
      title: Text(context.appLocalizations.feedback),
      subtitle: Text(context.appLocalizations.feedbackDesc),
      widget: const FeedbackView(),
      maxWidth: 400,
      forceFull: false,
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const _SettingsIcon('about'),
      title: Text(context.appLocalizations.about),
      subtitle: Text('$appName · v${globalState.packageInfo.version}'),
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
