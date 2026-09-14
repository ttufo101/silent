import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fl_clash/auth/providers.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'update_downloader.dart';
import 'update_info.dart';
import 'update_state.dart';

final updateControllerProvider =
    NotifierProvider<UpdateController, UpdateState>(UpdateController.new);

class UpdateController extends Notifier<UpdateState> {
  Future<UpdateInfo?>? _checkTask;
  CancelToken? _downloadCancelToken;

  @override
  UpdateState build() => const UpdateState();

  bool get isSupported => Platform.isAndroid || Platform.isWindows;

  Future<void> restoreRequiredUpdate() async {
    if (!isSupported) return;
    final cached = await preferences.getRequiredUpdate();
    if (cached == null) return;
    try {
      final info = UpdateInfo.fromJson(
        Map<String, dynamic>.from(jsonDecode(cached) as Map),
      );
      if (info.forceUpdate &&
          utils.compareVersions(
                info.latestVersion,
                globalState.packageInfo.version,
              ) >
              0 &&
          _matchesPlatform(info)) {
        state = UpdateState(
          phase: UpdatePhase.available,
          info: info,
          totalBytes: info.packageSizeBytes,
        );
      } else {
        await preferences.clearRequiredUpdate();
      }
    } on Object {
      await preferences.clearRequiredUpdate();
    }
  }

  Future<UpdateInfo?> check() {
    if (!isSupported) return Future.value();
    return _checkTask ??= _runCheck().whenComplete(() => _checkTask = null);
  }

  Future<UpdateInfo?> _runCheck() async {
    final cached = state.info?.forceUpdate == true ? state.info : null;
    state = UpdateState(phase: UpdatePhase.checking, info: cached);
    try {
      final info = await ref
          .read(starcoreApiProvider)
          .checkUpdate(
            platform: Platform.isAndroid ? 'android' : 'windows',
            currentVersion: globalState.packageInfo.version,
          );
      if (info.updateAvailable &&
          utils.compareVersions(
                info.latestVersion,
                globalState.packageInfo.version,
              ) >
              0) {
        if (!_matchesPlatform(info)) {
          throw const FormatException('Unexpected update package type');
        }
        state = UpdateState(
          phase: UpdatePhase.available,
          info: info,
          totalBytes: info.packageSizeBytes,
        );
        if (info.forceUpdate) {
          await preferences.saveRequiredUpdate(jsonEncode(info.toJson()));
        } else {
          await preferences.clearRequiredUpdate();
        }
        return info;
      }
      await preferences.clearRequiredUpdate();
      state = const UpdateState(phase: UpdatePhase.upToDate);
      return null;
    } catch (error) {
      if (cached != null) {
        state = UpdateState(
          phase: UpdatePhase.available,
          info: cached,
          totalBytes: cached.packageSizeBytes,
          error: error,
        );
        return cached;
      }
      state = UpdateState(phase: UpdatePhase.failed, error: error);
      rethrow;
    }
  }

  Future<void> downloadAndInstall() async {
    final info = state.info;
    if (info == null || !info.updateAvailable) return;
    if (state.phase == UpdatePhase.downloading ||
        state.phase == UpdatePhase.verifying ||
        state.phase == UpdatePhase.launchingInstaller) {
      return;
    }
    final existingPath = state.packagePath;
    if (existingPath != null) {
      state = UpdateState(
        phase: UpdatePhase.readyToInstall,
        info: info,
        downloadedBytes: info.packageSizeBytes,
        totalBytes: info.packageSizeBytes,
        packagePath: existingPath,
      );
      await _install(existingPath);
      return;
    }
    final cancelToken = CancelToken();
    _downloadCancelToken = cancelToken;
    state = UpdateState(
      phase: UpdatePhase.downloading,
      info: info,
      totalBytes: info.packageSizeBytes,
    );
    try {
      final packagePath = await UpdateDownloader().download(
        info,
        cancelToken: cancelToken,
        onProgress: (received, total) {
          state = UpdateState(
            phase: UpdatePhase.downloading,
            info: info,
            downloadedBytes: received,
            totalBytes: total,
          );
        },
        onVerifying: () {
          state = UpdateState(
            phase: UpdatePhase.verifying,
            info: info,
            downloadedBytes: info.packageSizeBytes,
            totalBytes: info.packageSizeBytes,
          );
        },
      );
      state = UpdateState(
        phase: UpdatePhase.readyToInstall,
        info: info,
        downloadedBytes: info.packageSizeBytes,
        totalBytes: info.packageSizeBytes,
        packagePath: packagePath,
      );
      await _install(packagePath);
    } catch (error) {
      if (error is DioException && CancelToken.isCancel(error)) {
        state = UpdateState(
          phase: UpdatePhase.available,
          info: info,
          totalBytes: info.packageSizeBytes,
        );
      } else {
        state = UpdateState(
          phase: UpdatePhase.failed,
          info: info,
          totalBytes: info.packageSizeBytes,
          error: error,
        );
      }
    } finally {
      if (identical(_downloadCancelToken, cancelToken)) {
        _downloadCancelToken = null;
      }
    }
  }

  void cancelDownload() {
    _downloadCancelToken?.cancel('Update download cancelled');
  }

  Future<void> _install(String packagePath) async {
    final info = state.info!;
    if (Platform.isAndroid) {
      final result = await app?.installApk(packagePath);
      if (result == ApkInstallResult.permissionRequired) {
        globalState.showNotifier(
          currentAppLocalizations.updateInstallPermissionRequired,
        );
        return;
      }
      if (result != ApkInstallResult.launched) {
        state = UpdateState(
          phase: UpdatePhase.failed,
          info: info,
          totalBytes: info.packageSizeBytes,
          packagePath: packagePath,
          error: const FormatException('Unable to launch package installer'),
        );
        return;
      }
      state = UpdateState(
        phase: UpdatePhase.readyToInstall,
        info: info,
        packagePath: packagePath,
        downloadedBytes: info.packageSizeBytes,
        totalBytes: info.packageSizeBytes,
      );
      globalState.showNotifier(currentAppLocalizations.updateInstallerOpened);
      return;
    }
    final launched =
        windows?.runas(
          packagePath,
          '/SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS',
        ) ??
        false;
    if (!launched) {
      state = UpdateState(
        phase: UpdatePhase.failed,
        info: info,
        totalBytes: info.packageSizeBytes,
        packagePath: packagePath,
        error: const FormatException('Unable to launch update installer'),
      );
      return;
    }
    state = UpdateState(
      phase: UpdatePhase.launchingInstaller,
      info: info,
      packagePath: packagePath,
      totalBytes: info.packageSizeBytes,
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await ref.read(systemActionProvider.notifier).handleExit(true);
  }

  bool _matchesPlatform(UpdateInfo info) {
    return (Platform.isAndroid && info.packageType == UpdatePackageType.apk) ||
        (Platform.isWindows && info.packageType == UpdatePackageType.exe);
  }
}
