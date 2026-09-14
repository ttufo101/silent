part of '../action.dart';

@Riverpod(keepAlive: true)
class CommonAction extends _$CommonAction {
  @override
  void build() {}

  Future<void> toggleRunning() {
    final running = !ref.read(isStartProvider);
    return ref
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
    final onlyStatisticsProxy = ref.read(
      appSettingProvider.select((state) => state.onlyStatisticsProxy),
    );
    try {
      final traffic = await coreController.getTraffic(onlyStatisticsProxy);
      ref.read(trafficsProvider.notifier).addTraffic(traffic);
      ref.read(totalTrafficProvider.notifier).value = await coreController
          .getTotalTraffic(onlyStatisticsProxy);
    } catch (error) {
      commonPrint.log(
        'updateTraffic error: $error',
        logLevel: coreFailureLogLevel(error),
      );
    }
  }
}
