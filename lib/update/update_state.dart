import 'update_info.dart';

enum UpdatePhase {
  idle,
  checking,
  upToDate,
  available,
  downloading,
  verifying,
  readyToInstall,
  launchingInstaller,
  failed,
}

class UpdateState {
  const UpdateState({
    this.phase = UpdatePhase.idle,
    this.info,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.packagePath,
    this.error,
  });

  final UpdatePhase phase;
  final UpdateInfo? info;
  final int downloadedBytes;
  final int totalBytes;
  final String? packagePath;
  final Object? error;

  double get progress => totalBytes <= 0
      ? 0
      : (downloadedBytes / totalBytes).clamp(0, 1).toDouble();
}
