part of '../action.dart';

@Riverpod(keepAlive: true)
class CommonAction extends _$CommonAction {
  bool _updatingTraffic = false;

  @override
  void build() {}

  Future<void> toggleRunning() async {
    final running = !ref.read(isStartProvider);
    if (running && ref.read(coreStatusProvider) != CoreStatus.connected) {
      await globalState.ensureCoreReady();
    }
    await ref
        .read(setupActionProvider.notifier)
        .setRunning(running, initialize: running && !ref.read(initProvider));
  }

  void updateSpeedStatistics() {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(showTrayTitle: !state.showTrayTitle));
  }

  void updateMode() {
    ref.read(patchClashConfigProvider.notifier).update((state) {
      final index = Mode.values.indexWhere((item) => item == state.mode);
      if (index == -1) return state;
      final nextIndex = index + 1 > Mode.values.length - 1 ? 0 : index + 1;
      return state.copyWith(mode: Mode.values[nextIndex]);
    });
  }

  Future<void> updateTraffic() async {
    if (_updatingTraffic) return;
    _updatingTraffic = true;
    final onlyStatisticsProxy = ref.read(
      appSettingProvider.select((state) => state.onlyStatisticsProxy),
    );
    final totalTrafficRevision = ref.read(totalTrafficProvider.notifier).revision;
    try {
      final traffic = await coreController.getTraffic(onlyStatisticsProxy);
      final totalTraffic = await coreController.getTotalTraffic(false);
      if (!ref.mounted) return;
      ref.read(trafficsProvider.notifier).addTraffic(traffic);
      ref
          .read(totalTrafficProvider.notifier)
          .addCoreSnapshot(totalTraffic, totalTrafficRevision);
    } catch (error) {
      commonPrint.log(
        'updateTraffic error: $error',
        logLevel: coreFailureLogLevel(error),
      );
    } finally {
      _updatingTraffic = false;
    }
  }
}
