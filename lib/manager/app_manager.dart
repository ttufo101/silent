import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/auth/providers.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/manager/window_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/starcore/providers.dart';
import 'package:fl_clash/widgets/animated_visibility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AppStateManager extends ConsumerStatefulWidget {
  final Widget child;

  const AppStateManager({super.key, required this.child});

  @override
  ConsumerState<AppStateManager> createState() => _AppStateManagerState();
}

class _AppStateManagerState extends ConsumerState<AppStateManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(configProvider, (prev, next) {
      if (prev != next) {
        globalState.container
            .read(storeActionProvider.notifier)
            .savePreferencesDebounce();
      }
    });
    ref.listenManual(suspendProvider, (prev, next) {
      final isStart = ref.read(isStartProvider);
      if (prev != next && isStart) {
        debouncer.call(FunctionTag.suspend, () async {
          if (next == true) {
            await coreController.stopListener();
          } else {
            await coreController.startListener();
          }
        });
      }
    });
    if (system.isMacOS) {
      ref.listenManual(autoSetSystemDnsStateProvider, (prev, next) async {
        if (prev == next) {
          return;
        }
        if (next.a == true && next.b == true) {
          macOS?.updateDns(false);
        } else {
          macOS?.updateDns(true);
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    commonPrint.log('$state');
    if (state == AppLifecycleState.resumed) {
      permissions.check();
      render?.resume();
      unawaited(
        ref.read(serverProfileSyncProvider).synchronizeIfStale().catchError((
          Object error,
          StackTrace stack,
        ) {
          commonPrint.log(error.toString(), logLevel: LogLevel.warning);
        }),
      );
    }
  }

  @override
  void didChangePlatformBrightness() {
    globalState.container.read(themeActionProvider.notifier).updateBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerHover: (_) {
        render?.resume();
      },
      child: widget.child,
    );
  }
}

class AppSidebarContainer extends ConsumerWidget {
  final Widget child;

  const AppSidebarContainer({super.key, required this.child});

  void _updateSideBarWidth(WidgetRef ref, double contentWidth) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sideWidthProvider.notifier).value =
          ref.read(viewSizeProvider.select((state) => state.width)) -
          contentWidth;
    });
  }

  void _handleToPage(PageLabel pageLabel) {
    final focusNode = FocusManager.instance.primaryFocus;
    final preserveNavigationFocus =
        focusNode?.context?.findAncestorWidgetOfExactType<NavigationRail>() !=
        null;
    globalState.container
        .read(currentPageLabelProvider.notifier)
        .toPage(pageLabel);
    if (!preserveNavigationFocus || focusNode == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusNode.context != null && focusNode.canRequestFocus) {
        focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationStateProvider);
    final navigationItems = navigationState.navigationItems;
    final isMobileView = navigationState.viewMode == ViewMode.mobile;
    final currentIndex = navigationState.currentIndex;
    return ColoredBox(
      color: context.colorScheme.surfaceContainer,
      child: Row(
        children: [
          AnimatedVisibility.sidebar(
            visible: !isMobileView,
            child: Material(
              color: context.colorScheme.surfaceContainer,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: context.tDesign.componentStroke),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      if (system.isMacOS) const SizedBox(height: 22),
                      const SizedBox(height: 16),
                      const _DesktopAccountSummary(),
                      const SizedBox(height: 20),
                      Expanded(
                        child: NavigationRail(
                          scrollable: true,
                          extended: true,
                          minWidth: 76,
                          minExtendedWidth: 240,
                          groupAlignment: -1,
                          backgroundColor: Colors.transparent,
                          useIndicator: true,
                          indicatorColor: context.colorScheme.primaryContainer,
                          indicatorShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                          selectedLabelTextStyle: context.textTheme.titleSmall
                              ?.copyWith(
                                color: context.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                          unselectedLabelTextStyle: context.textTheme.titleSmall
                              ?.copyWith(color: context.colorScheme.onSurface),
                          destinations: navigationItems
                              .map(
                                (item) => NavigationRailDestination(
                                  icon: item.icon,
                                  label: Text(
                                    Intl.message(item.label.name),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(growable: false),
                          onDestinationSelected: (index) {
                            _handleToPage(navigationItems[index].label);
                          },
                          selectedIndex: currentIndex,
                          labelType: NavigationRailLabelType.none,
                        ),
                      ),
                      Text(
                        appName,
                        style: context.textTheme.labelLarge?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'v${globalState.packageInfo.version}',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: isMobileView
                  ? EdgeInsets.zero
                  : const EdgeInsets.fromLTRB(0, 16, 16, 16),
              child: ClipRRect(
                borderRadius: isMobileView
                    ? BorderRadius.zero
                    : BorderRadius.circular(12),
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    _updateSideBarWidth(ref, constraints.maxWidth);
                    return child;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopAccountSummary extends ConsumerWidget {
  const _DesktopAccountSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).session;
    final info = ref.watch(userInfoProvider(session?.uid ?? '')).asData?.value;
    final email = info?.username.isNotEmpty == true
        ? info!.username
        : session?.email ?? '';
    final planName = info?.currentPlan?.name;
    return SizedBox(
      width: 216,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(alignment: Alignment.centerLeft, child: AppIcon()),
          const SizedBox(height: 14),
          Text(
            email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium,
          ),
          if (planName != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                planName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelLarge?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (info != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: context.tDesign.componentStroke),
              ),
              child: Column(
                children: [
                  _AccountMetric(
                    label: context.appLocalizations.personalRemainingDays,
                    value: context.appLocalizations.shopDayCount(
                      '${info.remainingDays}',
                    ),
                  ),
                  const SizedBox(height: 6),
                  _AccountMetric(
                    label: context.appLocalizations.personalRemainingTraffic,
                    value: info.unlimited
                        ? context.appLocalizations.shopUnlimited
                        : info.remainingTrafficBytes.traffic.show,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AccountMetric extends StatelessWidget {
  const _AccountMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          maxLines: 1,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
