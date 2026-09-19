import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/auth/providers.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/proxies/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _ProxyMaintenanceTask { idle, syncingConfiguration, testingDelay }

class HomeProxySelectorView extends ConsumerStatefulWidget {
  final String groupName;

  const HomeProxySelectorView({super.key, required this.groupName});

  @override
  ConsumerState<HomeProxySelectorView> createState() =>
      _HomeProxySelectorViewState();
}

class _HomeProxySelectorViewState extends ConsumerState<HomeProxySelectorView> {
  _ProxyMaintenanceTask _task = _ProxyMaintenanceTask.idle;
  int _testedCount = 0;
  int _totalCount = 0;
  String? _frozenRecommendedName;

  bool get _isBusy => _task != _ProxyMaintenanceTask.idle;

  Future<void> _refreshConfiguration() async {
    if (_isBusy) return;
    final previousSelectedNode = ref.read(selectedNodeNameProvider);
    setState(() {
      _task = _ProxyMaintenanceTask.syncingConfiguration;
    });
    try {
      final result = await ref.read(serverProfileSyncProvider).synchronize();
      if (!mounted) return;
      if (!result.hasSubscription) {
        context.showNotifier(
          context.appLocalizations.subscriptionUnavailableTitle,
        );
        return;
      }
      if (result.changed) {
        ref.read(delayDataSourceProvider.notifier).value = {};
        _restoreSelectionIfMissing(previousSelectedNode);
        final group = _effectiveGroup();
        context.showNotifier(
          context.appLocalizations.nodeConfigurationUpdated(
            group?.all.length ?? 0,
          ),
        );
      } else {
        context.showNotifier(
          context.appLocalizations.nodeConfigurationUpToDate,
        );
      }
    } catch (error) {
      if (mounted) {
        commonPrint.log(error.toString(), logLevel: LogLevel.warning);
        context.showNotifier(context.appLocalizations.serverProfileSyncFailed);
      }
    } finally {
      if (mounted) {
        setState(() {
          _task = _ProxyMaintenanceTask.idle;
        });
      }
    }
  }

  Group? _effectiveGroup() {
    final groups = ref.read(currentGroupsStateProvider).value;
    return groups.getGroup(widget.groupName) ?? groups.firstOrNull;
  }

  void _restoreSelectionIfMissing(String? previousSelectedNode) {
    if (previousSelectedNode == null || previousSelectedNode.isEmpty) return;
    final selectedNode = ref.read(selectedNodeNameProvider);
    if (selectedNode != null && selectedNode.isNotEmpty) return;
    final group = _effectiveGroup();
    if (group == null) return;
    for (final proxy in group.all) {
      final realProxyName = ref
          .read(realSelectedProxyStateProvider(proxy.name))
          .proxyName;
      if (realProxyName.isEmpty ||
          RuleTarget.baseTargets.contains(realProxyName)) {
        continue;
      }
      changeProxySelection(
        groupName: group.name,
        groupType: group.type,
        proxy: proxy,
      );
      return;
    }
  }

  Future<void> _testAllDelays(Group group) async {
    if (_isBusy || group.all.isEmpty) return;
    final currentDelays = <String, int?>{
      for (final proxy in group.all)
        proxy.name: ref.read(
          delayProvider(proxyName: proxy.name, testUrl: group.testUrl),
        ),
    };
    final recommended = _recommendedProxy(group.all, currentDelays);
    setState(() {
      _task = _ProxyMaintenanceTask.testingDelay;
      _testedCount = 0;
      _totalCount = group.all.length;
      _frozenRecommendedName = recommended?.name;
    });
    try {
      await delayTest(
        group.all,
        testUrl: group.testUrl,
        onProgress: (completed, total) {
          if (!mounted || _task != _ProxyMaintenanceTask.testingDelay) return;
          setState(() {
            _testedCount = completed;
            _totalCount = total;
          });
        },
      );
      if (mounted) {
        context.showNotifier(context.appLocalizations.delayTestCompleted);
      }
    } catch (error) {
      if (mounted) {
        commonPrint.log(error.toString(), logLevel: LogLevel.warning);
        context.showNotifier(context.appLocalizations.delayTestFailed);
      }
    } finally {
      if (mounted) {
        setState(() {
          _task = _ProxyMaintenanceTask.idle;
          _frozenRecommendedName = null;
        });
      }
    }
  }

  Widget _buildConfigurationAction(BuildContext context, bool isMobile) {
    final syncing = _task == _ProxyMaintenanceTask.syncingConfiguration;
    final icon = syncing
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.sync);
    if (isMobile) {
      return IconButton(
        tooltip: context.appLocalizations.refreshNodeConfiguration,
        onPressed: _isBusy ? null : _refreshConfiguration,
        icon: icon,
      );
    }
    return TextButton.icon(
      onPressed: _isBusy ? null : _refreshConfiguration,
      icon: icon,
      label: Text(context.appLocalizations.refreshNodeConfiguration),
    );
  }

  Widget _buildDelayAction(
    BuildContext context,
    bool isMobile,
    Group? group,
  ) {
    final testing = _task == _ProxyMaintenanceTask.testingDelay;
    final icon = testing
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.speed_outlined);
    final enabled = !_isBusy && group != null && group.all.isNotEmpty;
    final progress = testing
        ? context.appLocalizations.delayTestProgress(
            _testedCount,
            _totalCount,
          )
        : context.appLocalizations.delayTest;
    if (isMobile) {
      return IconButton(
        tooltip: progress,
        onPressed: enabled ? () => _testAllDelays(group!) : null,
        icon: icon,
      );
    }
    return TextButton.icon(
      onPressed: enabled ? () => _testAllDelays(group!) : null,
      icon: icon,
      label: Text(progress),
    );
  }

  Proxy? _recommendedProxy(List<Proxy> proxies, Map<String, int?> delays) {
    final available =
        proxies.where((proxy) => (delays[proxy.name] ?? 0) > 0).toList()
          ..sort((a, b) => delays[a.name]!.compareTo(delays[b.name]!));
    return available.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(
      currentGroupsStateProvider.select(
        (state) => state.value.getGroup(widget.groupName),
      ),
    );
    final selectedProxyName = ref.watch(selectedNodeNameProvider);
    final isMobile = ref.watch(isMobileViewProvider);
    final proxies = group?.all ?? const <Proxy>[];
    final delays = <String, int?>{
      for (final proxy in proxies)
        proxy.name: ref.watch(
          delayProvider(proxyName: proxy.name, testUrl: group?.testUrl),
        ),
    };
    final proxiesByName = {for (final proxy in proxies) proxy.name: proxy};
    final recommended = _task == _ProxyMaintenanceTask.testingDelay
        ? proxiesByName[_frozenRecommendedName]
        : _recommendedProxy(proxies, delays);
    return CommonScaffold(
      title: context.appLocalizations.proxies,
      centerTitle: true,
      actions: [
        _buildConfigurationAction(context, isMobile),
        _buildDelayAction(context, isMobile, group),
      ],
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: isMobile
              ? const EdgeInsets.fromLTRB(16, 56, 16, 24)
              : const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? 640 : 920),
            child: group == null || proxies.isEmpty
                ? NullStatus(label: context.appLocalizations.proxyGroupEmpty)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.appLocalizations.recommendedNode,
                        style: context.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      if (recommended != null)
                        _RecommendedProxy(
                          group: group,
                          proxy: recommended,
                          delay: delays[recommended.name],
                          proxiesByName: proxiesByName,
                          isSelected: recommended.name == selectedProxyName,
                          compact: !isMobile,
                          enabled:
                              _task !=
                              _ProxyMaintenanceTask.syncingConfiguration,
                          testing:
                              _task == _ProxyMaintenanceTask.testingDelay,
                        ),
                      SizedBox(height: isMobile ? 40 : 24),
                      Text(
                        context.appLocalizations.allNodes,
                        style: context.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Material(
                        color: context.tDesign.container,
                        child: Column(
                          children:
                              <Widget>[
                                    for (final proxy in proxies)
                                      _ProxyRow(
                                        group: group,
                                        proxy: proxy,
                                        delay: delays[proxy.name],
                                        proxiesByName: proxiesByName,
                                        isSelected:
                                            proxy.name == selectedProxyName,
                                        showSelected:
                                            proxy.name == selectedProxyName &&
                                            recommended?.name != proxy.name,
                                        compact: !isMobile,
                                        enabled:
                                            _task !=
                                            _ProxyMaintenanceTask
                                                .syncingConfiguration,
                                        testing:
                                            _task ==
                                            _ProxyMaintenanceTask.testingDelay,
                                      ),
                                  ]
                                  .separated(
                                    Divider(
                                      indent: 16,
                                      color: context.tDesign.componentStroke,
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                      const SizedBox(height: 132),
                      Text(
                        context.appLocalizations.pingEstimate,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _RecommendedProxy extends StatelessWidget {
  final Group group;
  final Proxy proxy;
  final int? delay;
  final Map<String, Proxy> proxiesByName;
  final bool isSelected;
  final bool compact;
  final bool enabled;
  final bool testing;

  const _RecommendedProxy({
    required this.group,
    required this.proxy,
    required this.delay,
    required this.proxiesByName,
    required this.isSelected,
    required this.compact,
    required this.enabled,
    required this.testing,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = ProxyDisplayName.parse(proxy.name);
    final countryCode = resolveProxyCountryCode(proxy, proxiesByName);
    return Material(
      color: context.tDesign.container,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.tDesign.componentBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled
            ? () {
                if (!isSelected) {
                  changeProxySelection(
                    groupName: group.name,
                    groupType: group.type,
                    proxy: proxy,
                  );
                }
                if (group.type.isComputedSelected ||
                    group.type == GroupType.Selector) {
                  Navigator.of(context).pop();
                }
              }
            : null,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: compact ? 64 : 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                ProxyFlag(
                  countryCode: countryCode,
                  size: compact ? 36 : 40,
                  fallbackIcon: Icons.bolt,
                  emphasized: true,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EmojiText(
                        displayName.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleMedium,
                      ),
                      Text(
                        context.appLocalizations.optimalPerformance,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _DelayStatus(
                  delay: delay,
                  highlighted: true,
                  testing: testing,
                ),
                const SizedBox(width: 8),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProxyRow extends StatelessWidget {
  final Group group;
  final Proxy proxy;
  final int? delay;
  final Map<String, Proxy> proxiesByName;
  final bool isSelected;
  final bool showSelected;
  final bool compact;
  final bool enabled;
  final bool testing;

  const _ProxyRow({
    required this.group,
    required this.proxy,
    required this.delay,
    required this.proxiesByName,
    required this.isSelected,
    required this.showSelected,
    required this.compact,
    required this.enabled,
    required this.testing,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = ProxyDisplayName.parse(proxy.name);
    final countryCode = resolveProxyCountryCode(proxy, proxiesByName);
    return InkWell(
      onTap: enabled
          ? () {
              if (!isSelected) {
                changeProxySelection(
                  groupName: group.name,
                  groupType: group.type,
                  proxy: proxy,
                );
              }
              if (group.type.isComputedSelected ||
                  group.type == GroupType.Selector) {
                Navigator.of(context).pop();
              }
            }
          : null,
      child: SizedBox(
        height: compact ? 48 : 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ProxyFlag(countryCode: countryCode, size: compact ? 28 : 32),
              const SizedBox(width: 16),
              Expanded(
                child: EmojiText(
                  displayName.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyLarge,
                ),
              ),
              _DelayStatus(delay: delay, testing: testing),
              Icon(
                showSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: showSelected
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DelayStatus extends StatelessWidget {
  final int? delay;
  final bool highlighted;
  final bool testing;

  const _DelayStatus({
    required this.delay,
    required this.testing,
    this.highlighted = false,
  });

  Color _color(BuildContext context) {
    final value = delay;
    if (value == null || value == 0) {
      return context.colorScheme.onSurfaceVariant;
    }
    if (value < 0) return context.colorScheme.error;
    if (value < 600) return context.tDesign.success.color;
    return context.tDesign.warning.color;
  }

  @override
  Widget build(BuildContext context) {
    final value = delay;
    if (testing && (value == null || value == 0)) {
      return const SizedBox(
        width: 56,
        child: Center(
          child: SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return SizedBox(
      width: 56,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value == null || value == 0
                ? '--'
                : value < 0
                ? context.appLocalizations.timeout
                : '$value ms',
            maxLines: 1,
            style: context.textTheme.bodySmall?.copyWith(
              color: highlighted && value != null && value > 0
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurfaceVariant,
            ),
          ),
          Icon(Icons.signal_cellular_alt, size: 16, color: _color(context)),
        ],
      ),
    );
  }
}
