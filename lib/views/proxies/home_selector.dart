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
    final proxies = group?.all ?? const <Proxy>[];
    final delays = <String, int?>{
      for (final proxy in proxies)
        proxy.name: ref.watch(
          delayProvider(proxyName: proxy.name, testUrl: group?.testUrl),
        ),
    };
    final recommended = _recommendedProxy(proxies, delays);
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
          padding: const EdgeInsets.fromLTRB(16, 56, 16, 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
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
                        ),
                      const SizedBox(height: 40),
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
                                        isSelected:
                                            proxy.name == selectedProxyName,
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

  const _RecommendedProxy({
    required this.group,
    required this.proxy,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.tDesign.container,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.tDesign.componentBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          changeProxySelection(
            groupName: group.name,
            groupType: group.type,
            proxy: proxy,
          );
          if (group.type.isComputedSelected ||
              group.type == GroupType.Selector) {
            Navigator.of(context).pop();
          }
        },
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: context.colorScheme.primary,
                  child: const Icon(Icons.bolt, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EmojiText(
                        proxy.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleMedium,
                      ),
                      Text(
                        context.appLocalizations.optimalPerformance,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _DelayStatus(delay: delay, highlighted: true),
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
  final bool isSelected;

  const _ProxyRow({
    required this.group,
    required this.proxy,
    required this.delay,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = _ProxyDisplayName.parse(proxy.name);
    return InkWell(
      onTap: () {
        changeProxySelection(
          groupName: group.name,
          groupType: group.type,
          proxy: proxy,
        );
        if (group.type.isComputedSelected || group.type == GroupType.Selector) {
          Navigator.of(context).pop();
        }
      },
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: context.colorScheme.primaryContainer,
                child: displayName.flag == null
                    ? Icon(
                        Icons.public,
                        size: 18,
                        color: context.colorScheme.primary,
                      )
                    : Text(
                        displayName.flag!,
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
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

class _ProxyDisplayName {
  final String name;
  final String? flag;

  const _ProxyDisplayName({required this.name, this.flag});

  factory _ProxyDisplayName.parse(String value) {
    final runes = value.runes.toList();
    if (runes.length >= 2 &&
        _isRegionalIndicator(runes[0]) &&
        _isRegionalIndicator(runes[1])) {
      return _ProxyDisplayName(
        name: String.fromCharCodes(runes.skip(2)).trimLeft(),
        flag: String.fromCharCodes(runes.take(2)),
      );
    }
    return _ProxyDisplayName(name: value);
  }

  static bool _isRegionalIndicator(int rune) {
    return rune >= 0x1F1E6 && rune <= 0x1F1FF;
  }
}
