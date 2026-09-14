import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'item.dart';

class ConnectionsView extends ConsumerStatefulWidget {
  final Future<List<TrackerInfo>> Function()? connectionsReader;

  const ConnectionsView({super.key, @visibleForTesting this.connectionsReader});

  @override
  ConsumerState<ConnectionsView> createState() => _ConnectionsViewState();
}

class _ConnectionsViewState extends ConsumerState<ConnectionsView>
    with WidgetsBindingObserver, ActivePollingMixin<ConnectionsView> {
  final _connectionsStateNotifier = ValueNotifier<TrackerInfosState>(
    const TrackerInfosState(),
  );
  final ScrollController _scrollController = ScrollController();
  bool _pollingPaused = false;

  @override
  Duration get pollInterval => const Duration(seconds: 1);

  List<Widget> _buildActions() {
    return [
      IconButton(
        tooltip: _pollingPaused
            ? context.appLocalizations.resumeRefresh
            : context.appLocalizations.pauseRefresh,
        onPressed: () {
          setState(() => _pollingPaused = !_pollingPaused);
          if (_pollingPaused) {
            stopPolling();
          } else {
            startPolling();
          }
        },
        icon: Icon(_pollingPaused ? Icons.play_arrow : Icons.pause),
      ),
      IconButton(
        tooltip: context.appLocalizations.closeAllConnections,
        onPressed: () async {
          coreController.closeConnections();
          await _refreshConnections();
        },
        icon: const Icon(Icons.delete_sweep_outlined),
      ),
    ];
  }

  void _onSearch(String value) {
    _connectionsStateNotifier.value = _connectionsStateNotifier.value.copyWith(
      query: value,
    );
  }

  void _onKeywordsUpdate(List<String> keywords) {
    _connectionsStateNotifier.value = _connectionsStateNotifier.value.copyWith(
      keywords: keywords,
    );
  }

  @override
  Future<void> poll(PollGuard isCurrent) async {
    if (_pollingPaused) return;
    final trackerInfos = await _readConnections();
    if (trackerInfos == null || !isCurrent()) {
      return;
    }
    _applyConnections(trackerInfos);
  }

  Future<void> _refreshConnections() async {
    final trackerInfos = await _readConnections();
    if (trackerInfos == null || !mounted) {
      return;
    }
    _applyConnections(trackerInfos);
  }

  Future<List<TrackerInfo>?> _readConnections() async {
    try {
      final connectionsReader = widget.connectionsReader;
      return connectionsReader != null
          ? await connectionsReader()
          : await coreController.getConnections();
    } catch (error) {
      commonPrint.log(
        'updateConnections error: $error',
        logLevel: coreFailureLogLevel(error),
      );
      return null;
    }
  }

  void _applyConnections(List<TrackerInfo> trackerInfos) {
    _connectionsStateNotifier.value = _connectionsStateNotifier.value.copyWith(
      trackerInfos: trackerInfos,
    );
  }

  Future<void> _handleBlockConnection(String id) async {
    await coreController.closeConnection(id);
    await _refreshConnections();
  }

  @override
  void dispose() {
    _connectionsStateNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final body = ValueListenableBuilder<TrackerInfosState>(
      valueListenable: _connectionsStateNotifier,
      builder: (context, state, _) {
        final connections = state.list;
        if (connections.isEmpty) {
          return NullStatus(
            label: appLocalizations.nullTip(appLocalizations.connections),
            illustration: const ConnectionEmptyIllustration(),
          );
        }
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: context.colorScheme.surfaceContainerLow,
              child: Text(
                appLocalizations.displayedConnections(connections.length),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: SuperListView.separated(
                controller: _scrollController,
                itemCount: connections.length,
                separatorBuilder: (_, _) => const Divider(height: 0),
                itemBuilder: (_, index) {
                  final trackerInfo = connections[index];
                  return TrackerInfoItem(
                    key: Key(trackerInfo.id),
                    trackerInfo: trackerInfo,
                    onClickKeyword: (value) {
                      context.commonScaffoldState?.addKeyword(value);
                    },
                    trailing: IconButton(
                      tooltip: appLocalizations.closeConnection,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(minimumSize: Size.zero),
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _handleBlockConnection(trackerInfo.id);
                      },
                    ),
                    detailTitle: appLocalizations.details(
                      appLocalizations.connection,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
    return CommonScaffold(
      title: appLocalizations.connections,
      onKeywordsUpdate: _onKeywordsUpdate,
      searchState: AppBarSearchState(onSearch: _onSearch),
      actions: _buildActions(),
      body: body,
    );
  }
}
