import 'package:fl_clash/auth/providers.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/starcore/subscription_access.dart';
import 'package:fl_clash/views/dashboard/no_subscription_view.dart';
import 'package:fl_clash/views/dashboard/widgets/announcement_bar.dart';
import 'package:fl_clash/views/dashboard/widgets/connected_location_card.dart';
import 'package:fl_clash/views/proxies/home_selector.dart';
import 'package:fl_clash/views/proxies/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView>
    with WidgetsBindingObserver {
  bool? _lastConnected;
  String? _lastExitIdentity;
  bool _reportedResolvedFrame = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        ref.read(isStartProvider) &&
        !ref.read(suspendProvider)) {
      ref.read(networkDetectionProvider.notifier).startCheck();
    }
  }

  Group? _currentGroup(List<Group> groups) {
    final currentGroupName = ref.watch(
      currentProfileProvider.select((state) => state?.currentGroupName),
    );
    return groups.getGroup(currentGroupName ?? '') ??
        (groups.isEmpty ? null : groups.first);
  }

  String _exitIdentity(Group? group) {
    if (group == null) return '';
    final selectedName = ref.watch(selectedProxyNameProvider(group.name)) ?? '';
    if (selectedName.isEmpty) return group.name;
    final realName = ref
        .watch(realSelectedProxyStateProvider(selectedName))
        .proxyName;
    return '$selectedName|$realName';
  }

  void _syncExitCheck({required bool connected, required String exitIdentity}) {
    if (_lastConnected == connected &&
        (!connected || _lastExitIdentity == exitIdentity)) {
      return;
    }
    _lastConnected = connected;
    _lastExitIdentity = exitIdentity;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(networkDetectionProvider.notifier);
      if (connected) {
        notifier.startCheck();
      } else {
        notifier.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionAccess = ref.watch(subscriptionAccessStatusProvider);
    if (subscriptionAccess == SubscriptionAccessStatus.checking) {
      final syncError = ref.watch(serverProfileSyncErrorProvider);
      if (syncError != null) {
        return Scaffold(
          backgroundColor: context.tDesign.pageBackground,
          body: const SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _ProfileSyncFailureCard(),
              ),
            ),
          ),
        );
      }
      return const _DashboardPreparingView();
    }
    if (!_reportedResolvedFrame) {
      _reportedResolvedFrame = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startupTiming.mark('subscription view first frame');
      });
    }
    if (subscriptionAccess == SubscriptionAccessStatus.inactive) {
      return const NoSubscriptionView();
    }
    final groups = ref.watch(currentGroupsStateProvider).value;
    final currentGroup = _currentGroup(groups);
    final connected = ref.watch(isStartProvider) && !ref.watch(suspendProvider);
    final exitIdentity = _exitIdentity(currentGroup);
    final announcement = ref.watch(dashboardAnnouncementProvider);
    final isMobile = ref.watch(isMobileViewProvider);
    final desktopHeroHeight = (MediaQuery.sizeOf(context).height * 0.36).clamp(
      260.0,
      280.0,
    );
    _syncExitCheck(connected: connected, exitIdentity: exitIdentity);

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: isMobile
                ? const EdgeInsets.fromLTRB(16, 24, 16, 24)
                : const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isMobile ? 720 : 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isMobile && announcement != null) ...[
                    DashboardAnnouncementBar(announcement: announcement),
                    const SizedBox(height: 10),
                  ],
                  _FullBleed(
                    height: isMobile ? 232 : desktopHeroHeight,
                    child: _DashboardHero(
                      connected: connected,
                      announcement: isMobile ? announcement : null,
                    ),
                  ),
                  SizedBox(height: isMobile ? 24 : 16),
                  if (isMobile) ...[
                    const _SpeedPanel(),
                    const SizedBox(height: 24),
                    const _ModePanel(),
                    const SizedBox(height: 24),
                    Text(
                      context.appLocalizations.currentNode,
                      style: context.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    _CurrentNodeSection(group: currentGroup),
                    const SizedBox(height: 36),
                  ] else ...[
                    Text(
                      context.appLocalizations.currentNode,
                      style: context.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 6),
                    _CurrentNodeSection(group: currentGroup),
                    const SizedBox(height: 16),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _ModePanel()),
                        SizedBox(width: 16),
                        Expanded(child: _SpeedPanel()),
                      ],
                    ),
                    if (system.isWindows) ...[
                      const SizedBox(height: 16),
                      const _WindowsNetworkControls(),
                    ],
                    const SizedBox(height: 16),
                  ],
                  const _HomeConnectButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardPreparingView extends ConsumerWidget {
  const _DashboardPreparingView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ref.watch(isMobileViewProvider);
    final desktopHeroHeight = (MediaQuery.sizeOf(context).height * 0.36).clamp(
      260.0,
      280.0,
    );
    return Scaffold(
      backgroundColor: context.tDesign.pageBackground,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: isMobile
                ? const EdgeInsets.fromLTRB(16, 24, 16, 24)
                : const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isMobile ? 720 : 1080),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                builder: (context, opacity, child) {
                  return Opacity(opacity: opacity, child: child);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DashboardPlaceholder(
                      height: isMobile ? 232 : desktopHeroHeight,
                    ),
                    SizedBox(height: isMobile ? 24 : 16),
                    if (isMobile) ...[
                      const _DashboardPlaceholder(height: 88),
                      const SizedBox(height: 24),
                      const _DashboardPlaceholder(height: 88),
                      const SizedBox(height: 24),
                      const _DashboardPlaceholder(height: 72),
                      const SizedBox(height: 36),
                    ] else ...[
                      const _DashboardPlaceholder(height: 60),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Expanded(child: _DashboardPlaceholder(height: 82)),
                          SizedBox(width: 16),
                          Expanded(child: _DashboardPlaceholder(height: 82)),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    const _DashboardPlaceholder(height: 56),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardPlaceholder extends StatelessWidget {
  const _DashboardPlaceholder({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.tDesign.container,
        borderRadius: BorderRadius.circular(9),
      ),
    );
  }
}

class _DashboardHero extends ConsumerWidget {
  const _DashboardHero({required this.connected, required this.announcement});

  final bool connected;
  final DashboardAnnouncement? announcement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkState = connected
        ? ref.watch(networkDetectionProvider)
        : const NetworkDetectionState(isLoading: false, ipInfo: null);
    return Stack(
      children: [
        ConnectedLocationMap(
          networkState: networkState,
          showExitInfo: connected,
          onRetry: () =>
              ref.read(networkDetectionProvider.notifier).startCheck(),
        ),
        if (announcement != null)
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: DashboardAnnouncementBar(announcement: announcement!),
          ),
      ],
    );
  }
}

class _FullBleed extends StatelessWidget {
  const _FullBleed({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) {
        final width = MediaQuery.sizeOf(context).width;
        if (width >= 600) return SizedBox(height: height, child: child);
        return SizedBox(
          height: height,
          child: OverflowBox(
            alignment: Alignment.center,
            minWidth: width,
            maxWidth: width,
            child: SizedBox(width: width, height: height, child: child),
          ),
        );
      },
    );
  }
}

class _SpeedPanel extends ConsumerWidget {
  const _SpeedPanel();

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required bool compact,
    required Color color,
    required String label,
    required num value,
  }) {
    return _DashboardSegment(
      compact: compact,
      leading: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.tDesign.secondaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: compact ? 22 : 28, color: color),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium,
          ),
          Text(
            '${value.traffic.show}/s',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ref.watch(isMobileViewProvider);
    final traffic = ref.watch(
      trafficsProvider.select((state) => state.list.safeLast(const Traffic())),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.appLocalizations.networkSpeed,
          style: context.textTheme.bodyLarge,
        ),
        SizedBox(height: isMobile ? 8 : 6),
        Container(
          decoration: BoxDecoration(
            color: context.tDesign.container,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              Expanded(
                child: _item(
                  context,
                  icon: Icons.arrow_upward,
                  compact: !isMobile,
                  color: context.tDesign.warning,
                  label: context.appLocalizations.upload,
                  value: traffic.up,
                ),
              ),
              SizedBox(
                height: isMobile ? 40 : 32,
                child: VerticalDivider(
                  width: 1,
                  color: context.tDesign.componentStroke,
                ),
              ),
              Expanded(
                child: _item(
                  context,
                  icon: Icons.arrow_downward,
                  compact: !isMobile,
                  color: context.tDesign.success,
                  label: context.appLocalizations.download,
                  value: traffic.down,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModePanel extends ConsumerWidget {
  const _ModePanel();

  void _changeMode(WidgetRef ref, Mode mode) {
    ref.read(setupActionProvider.notifier).changeMode(mode);
  }

  Widget _item(
    BuildContext context,
    WidgetRef ref,
    Mode mode, {
    required bool compact,
  }) {
    return InkWell(
      onTap: () => _changeMode(ref, mode),
      child: _DashboardSegment(
        compact: compact,
        leading: Center(
          child: Radio<Mode>(
            value: mode,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        child: Text(
          Intl.message(mode.name),
          style: compact
              ? context.textTheme.bodyMedium
              : context.textTheme.bodyLarge,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ref.watch(isMobileViewProvider);
    final mode = ref.watch(
      patchClashConfigProvider.select((state) => state.mode),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.appLocalizations.outboundMode,
          style: context.textTheme.bodyLarge,
        ),
        SizedBox(height: isMobile ? 8 : 6),
        Material(
          color: context.tDesign.container,
          borderRadius: BorderRadius.circular(9),
          clipBehavior: Clip.antiAlias,
          child: RadioGroup<Mode>(
            groupValue: mode,
            onChanged: (value) {
              if (value != null) _changeMode(ref, value);
            },
            child: Row(
              children: [
                Expanded(
                  child: _item(context, ref, Mode.rule, compact: !isMobile),
                ),
                SizedBox(
                  height: 32,
                  child: VerticalDivider(
                    width: 1,
                    color: context.tDesign.componentStroke,
                  ),
                ),
                Expanded(
                  child: _item(context, ref, Mode.global, compact: !isMobile),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardSegment extends StatelessWidget {
  const _DashboardSegment({
    required this.leading,
    required this.child,
    this.compact = false,
  });

  final Widget leading;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 56 : 64,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox.square(dimension: compact ? 36 : 44, child: leading),
            SizedBox(width: compact ? 8 : 10),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _WindowsNetworkControls extends ConsumerStatefulWidget {
  const _WindowsNetworkControls();

  @override
  ConsumerState<_WindowsNetworkControls> createState() =>
      _WindowsNetworkControlsState();
}

class _WindowsNetworkControlsState
    extends ConsumerState<_WindowsNetworkControls> {
  bool _tunUpdating = false;
  bool _dnsUpdating = false;

  Future<void> _setTunEnabled(bool enabled) async {
    if (_tunUpdating) return;
    setState(() => _tunUpdating = true);
    try {
      final updated = await ref
          .read(setupActionProvider.notifier)
          .setTunEnabled(enabled);
      if (!updated && mounted) {
        context.showNotifier(context.appLocalizations.tunServiceEnableFailed);
      }
    } finally {
      if (mounted) setState(() => _tunUpdating = false);
    }
  }

  Future<void> _setDnsProtectionEnabled(bool enabled) async {
    if (_dnsUpdating) return;
    setState(() => _dnsUpdating = true);
    try {
      final updated = await ref
          .read(setupActionProvider.notifier)
          .setDnsProtectionEnabled(enabled);
      if (!updated && mounted) {
        context.showNotifier(
          context.appLocalizations.dnsProtectionUpdateFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _dnsUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tunEnabled = ref.watch(
      patchClashConfigProvider.select((state) => state.tun.enable),
    );
    final authorizationState = ref.watch(authorizedTunEnableProvider);
    final effectiveTunEnabled =
        tunEnabled && authorizationState == TunAuthorizationState.authorized;
    final dnsProtection = ref.watch(
      networkSettingProvider.select((state) => state.dnsProtection),
    );
    return Column(
      children: [
        _DesktopToggleRow(
          icon: Icons.shield_outlined,
          title: context.appLocalizations.tunServiceMode,
          description: context.appLocalizations.tunServiceModeDesc,
          value: tunEnabled,
          updating: _tunUpdating,
          onChanged: _setTunEnabled,
        ),
        const SizedBox(height: 12),
        Tooltip(
          message: effectiveTunEnabled
              ? context.appLocalizations.dnsProtectionDesc
              : context.appLocalizations.dnsProtectionRequiresTun,
          child: _DesktopToggleRow(
            icon: Icons.health_and_safety_outlined,
            title: context.appLocalizations.dnsProtection,
            description: context.appLocalizations.dnsProtectionDesc,
            value: effectiveTunEnabled && dnsProtection,
            updating: _dnsUpdating,
            onChanged: effectiveTunEnabled ? _setDnsProtectionEnabled : null,
          ),
        ),
      ],
    );
  }
}

class _DesktopToggleRow extends StatelessWidget {
  const _DesktopToggleRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.updating,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final bool updating;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.tDesign.container,
      borderRadius: BorderRadius.circular(9),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: updating || onChanged == null ? null : () => onChanged!(!value),
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: context.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                if (updating)
                  const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Switch(value: value, onChanged: onChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentNodeSection extends ConsumerWidget {
  const _CurrentNodeSection({required this.group});

  final Group? group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncError = ref.watch(serverProfileSyncErrorProvider);
    final hasProfile = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    if (!hasProfile && syncError != null) {
      return const _ProfileSyncFailureCard();
    }
    return _CurrentProxyCard(group: group);
  }
}

class _ProfileSyncFailureCard extends ConsumerStatefulWidget {
  const _ProfileSyncFailureCard();

  @override
  ConsumerState<_ProfileSyncFailureCard> createState() =>
      _ProfileSyncFailureCardState();
}

class _ProfileSyncFailureCardState
    extends ConsumerState<_ProfileSyncFailureCard> {
  bool _retrying = false;

  Future<void> _retry() async {
    if (_retrying) return;
    setState(() => _retrying = true);
    try {
      await ref.read(serverProfileSyncProvider).synchronize();
      ref.read(serverProfileSyncErrorProvider.notifier).set(null);
    } catch (error) {
      ref.read(serverProfileSyncErrorProvider.notifier).set(error.toString());
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ref.watch(isMobileViewProvider);
    return Container(
      height: isMobile ? 88 : 72,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 12),
      decoration: BoxDecoration(
        color: context.tDesign.container,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: context.tDesign.componentBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: context.colorScheme.error),
          SizedBox(width: isMobile ? 16 : 12),
          Expanded(
            child: Text(
              context.appLocalizations.serverProfileLoadFailed,
              style: context.textTheme.titleMedium,
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: _retrying ? null : _retry,
            icon: _retrying
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: Text(context.appLocalizations.retry),
          ),
        ],
      ),
    );
  }
}

class _CurrentProxyCard extends ConsumerWidget {
  const _CurrentProxyCard({required this.group});

  final Group? group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = this.group;
    final isMobile = ref.watch(isMobileViewProvider);
    final selectedProxyName = group == null
        ? ''
        : ref.watch(selectedProxyNameProvider(group.name)) ?? '';
    final hasProxy = group != null && selectedProxyName.isNotEmpty;
    final realProxyName = hasProxy
        ? ref.watch(realSelectedProxyStateProvider(selectedProxyName)).proxyName
        : '';
    final proxyDescription =
        realProxyName.isNotEmpty && realProxyName != selectedProxyName
        ? ProxyDisplayName.parse(realProxyName).name
        : context.appLocalizations.selectProxy;
    final selectedDisplayName = ProxyDisplayName.parse(selectedProxyName);
    final proxiesByName = {
      for (final proxy in group?.all ?? const <Proxy>[]) proxy.name: proxy,
    };
    final selectedProxy = proxiesByName[selectedProxyName];
    final countryCode = selectedProxy == null
        ? ProxyDisplayName.parse(
            realProxyName.isNotEmpty ? realProxyName : selectedProxyName,
          ).countryCode
        : resolveProxyCountryCode(selectedProxy, proxiesByName);
    return Material(
      color: context.tDesign.container,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        side: BorderSide(color: context.tDesign.componentBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: group == null
            ? null
            : () {
                BaseNavigator.push(
                  context,
                  HomeProxySelectorView(groupName: group.name),
                );
              },
        child: SizedBox(
          height: isMobile ? 72 : 60,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 12),
            child: Row(
              children: [
                ProxyFlag(countryCode: countryCode, size: isMobile ? 40 : 32),
                SizedBox(width: isMobile ? 16 : 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EmojiText(
                        hasProxy
                            ? selectedDisplayName.name
                            : context.appLocalizations.proxiesEmpty,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: isMobile
                            ? context.textTheme.titleMedium
                            : context.textTheme.titleSmall,
                      ),
                      Text(
                        proxyDescription,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: isMobile ? 32 : 24,
                  color: context.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeConnectButton extends ConsumerStatefulWidget {
  const _HomeConnectButton();

  @override
  ConsumerState<_HomeConnectButton> createState() => _HomeConnectButtonState();
}

class _HomeConnectButtonState extends ConsumerState<_HomeConnectButton> {
  bool _switching = false;
  bool _disconnecting = false;

  Future<void> _toggle() async {
    if (_switching) return;
    final disconnecting =
        ref.read(isStartProvider) && !ref.read(suspendProvider);
    setState(() {
      _switching = true;
      _disconnecting = disconnecting;
    });
    try {
      await ref.read(commonActionProvider.notifier).toggleRunning();
    } finally {
      if (mounted) {
        setState(() {
          _switching = false;
          _disconnecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ref.watch(isMobileViewProvider);
    final hasProfile = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    final coreStatus = ref.watch(coreStatusProvider);
    final isStart = ref.watch(isStartProvider);
    final suspend = ref.watch(suspendProvider);
    final isConnected = isStart && !suspend;
    final showDisconnectStyle = isConnected || _disconnecting;
    final preparing = coreStatus == CoreStatus.connecting && !_switching;
    final text = preparing
        ? context.appLocalizations.connecting
        : _switching
        ? _disconnecting
              ? context.appLocalizations.disconnecting
              : context.appLocalizations.connecting
        : isConnected
        ? context.appLocalizations.disconnect
        : context.appLocalizations.connectNow;
    return FilledButton(
      onPressed: !hasProfile || _switching || preparing ? null : _toggle,
      style: FilledButton.styleFrom(
        minimumSize: isMobile ? null : const Size.fromHeight(48),
        backgroundColor: showDisconnectStyle ? context.colorScheme.error : null,
        foregroundColor: showDisconnectStyle
            ? context.colorScheme.onError
            : null,
      ),
      child: _switching
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _disconnecting
                        ? context.colorScheme.onError
                        : context.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(text),
              ],
            )
          : Text(text),
    );
  }
}
