part of '../action.dart';

@Riverpod(keepAlive: true)
class BackupAction extends _$BackupAction {
  @override
  void build() {}

  Future<String> backup() async {
    final scriptFileNames = await database.scriptsDao.fileNames().get();
    final configMap = ref.read(configProvider).toJson();
    configMap['currentProfileId'] = null;
    configMap['version'] = await preferences.getVersion();
    return backupTask(configMap, scriptFileNames);
  }

  Future<void> restore() async {
    final restoreDirPath = await appPath.restoreDirPath;
    final restoreDir = Directory(restoreDirPath);
    final restoreStrategy = ref.read(
      appSettingProvider.select((state) => state.restoreStrategy),
    );
    final isOverride = restoreStrategy == RestoreStrategy.override;
    try {
      final migrationData = await restoreTask();
      if (!await restoreDir.exists()) {
        throw currentAppLocalizations.restoreException;
      }
      final profileRuleIds = migrationData.links
          .where((item) => item.profileId != null)
          .map((item) => item.ruleId)
          .toSet();
      await database.restore(
        const [],
        migrationData.scripts,
        migrationData.rules
            .where((item) => !profileRuleIds.contains(item.id))
            .toList(),
        migrationData.links.where((item) => item.profileId == null).toList(),
        const [],
        isOverride: isOverride,
      );
      final configMap = migrationData.configMap;
      if (configMap == null) return;
      final config = Config.fromJson(configMap);
      final appSettingProps = config.appSettingProps;
      final themeMode = appSettingProps.themeMode == ThemeMode.system
          ? WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                    Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light
          : appSettingProps.themeMode;
      ref.read(davSettingProvider.notifier).update((_) => config.davProps);
      ref.read(patchClashConfigProvider.notifier).value =
          config.patchClashConfig;
      ref.read(appSettingProvider.notifier).value = appSettingProps.copyWith(
        themeMode: themeMode,
      );
      ref.read(windowSettingProvider.notifier).value = config.windowProps;
      ref.read(vpnSettingProvider.notifier).value = config.vpnProps;
      ref.read(overrideDnsProvider.notifier).value = config.overrideDns;
      ref.read(networkSettingProvider.notifier).value = config.networkProps;
      ref.read(hotKeyActionsProvider.notifier).value = config.hotKeyActions;
      return;
    } finally {
      await restoreDir.safeDelete(recursive: true);
    }
  }
}
