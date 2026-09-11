import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/auth/providers.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/proxies/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeProxySelectorView extends ConsumerStatefulWidget {
  final String groupName;

  const HomeProxySelectorView({super.key, required this.groupName});

  @override
  ConsumerState<HomeProxySelectorView> createState() =>
      _HomeProxySelectorViewState();
}

class _HomeProxySelectorViewState extends ConsumerState<HomeProxySelectorView> {
  bool _isTesting = false;

  Future<void> _refresh(Group group) async {
    if (_isTesting) return;
    setState(() {
      _isTesting = true;
    });
    try {
      await ref.read(serverProfileSyncProvider).synchronize();
      final refreshedGroup = ref
          .read(currentGroupsStateProvider)
          .value
          .getGroup(widget.groupName);
      final effectiveGroup =
          refreshedGroup ??
          ref.read(currentGroupsStateProvider).value.firstOrNull;
      if (effectiveGroup != null) {
        await delayTest(effectiveGroup.all, effectiveGroup.testUrl);
      }
    } catch (error) {
      if (mounted) {
        commonPrint.log(error.toString(), logLevel: LogLevel.warning);
        context.showNotifier(context.appLocalizations.serverProfileSyncFailed);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTesting = false;
        });
      }
    }
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
    final selectedProxyName = ref.watch(
      selectedProxyNameProvider(widget.groupName),
    );
    final isMobile = ref.watch(isMobileViewProvider);
    final proxies = group?.all ?? const <Proxy>[];
    final delays = <String, int?>{
      for (final proxy in proxies)
        proxy.name: ref.watch(
          delayProvider(proxyName: proxy.name, testUrl: group?.testUrl),
        ),
    };
    final recommended = _recommendedProxy(proxies, delays);
    final proxiesByName = {for (final proxy in proxies) proxy.name: proxy};
    return CommonScaffold(
      title: context.appLocalizations.proxies,
      centerTitle: true,
      isLoading: _isTesting,
      actions: [
        IconButton(
          tooltip: context.appLocalizations.refresh,
          onPressed: group == null || _isTesting ? null : () => _refresh(group),
          icon: const Icon(Icons.refresh),
        ),
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

  const _RecommendedProxy({
    required this.group,
    required this.proxy,
    required this.delay,
    required this.proxiesByName,
    required this.isSelected,
    required this.compact,
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
        onTap: () {
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
        },
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
                _DelayStatus(delay: delay, highlighted: true),
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

  const _ProxyRow({
    required this.group,
    required this.proxy,
    required this.delay,
    required this.proxiesByName,
    required this.isSelected,
    required this.showSelected,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = ProxyDisplayName.parse(proxy.name);
    final countryCode = resolveProxyCountryCode(proxy, proxiesByName);
    return InkWell(
      onTap: () {
        if (!isSelected) {
          changeProxySelection(
            groupName: group.name,
            groupType: group.type,
            proxy: proxy,
          );
        }
        if (group.type.isComputedSelected || group.type == GroupType.Selector) {
          Navigator.of(context).pop();
        }
      },
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
              _DelayStatus(delay: delay),
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

  const _DelayStatus({required this.delay, this.highlighted = false});

  Color _color(BuildContext context) {
    final value = delay;
    if (value == null || value == 0) {
      return context.colorScheme.onSurfaceVariant;
    }
    if (value < 0) return context.colorScheme.error;
    if (value < 600) return context.tDesign.success;
    return context.tDesign.warning;
  }

  @override
  Widget build(BuildContext context) {
    final value = delay;
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
