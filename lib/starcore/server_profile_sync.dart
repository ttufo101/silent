import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:fl_clash/auth/auth_controller.dart';
import 'package:fl_clash/auth/data/gateway_client.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/starcore/data/starcore_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServerProfileSyncResult {
  const ServerProfileSyncResult({required this.changed});

  final bool changed;
}

class ServerProfileSync {
  ServerProfileSync({
    required AuthController authController,
    required StarcoreApi api,
    required Ref ref,
  }) : _authController = authController,
       _api = api,
       _ref = ref;

  static const staleDuration = Duration(minutes: 20);
  final AuthController _authController;
  final StarcoreApi _api;
  final Ref _ref;
  Future<ServerProfileSyncResult>? _activeTask;
  Timer? _networkRecoveryTimer;
  int _generation = 0;
  bool _lastSyncFailed = false;

  Future<bool> prepare() async {
    final session = _authController.session;
    if (session == null) {
      throw const GatewayException('Authentication required');
    }
    final cachedProfile = globalState.didCrashOnPreviousExecution
        ? null
        : await _getValidCachedProfile(session.uid);
    if (cachedProfile != null) {
      _ref.read(currentProfileIdProvider.notifier).value = cachedProfile.id;
      return true;
    }
    return false;
  }

  Future<ServerProfileSyncResult> synchronize({bool apply = true}) {
    final existing = _activeTask;
    if (existing != null) return existing;
    final task = _synchronize(apply: apply);
    _activeTask = task;
    unawaited(
      task.then(
        (_) => _clearActiveTask(task),
        onError: (Object _, StackTrace _) => _clearActiveTask(task),
      ),
    );
    return task;
  }

  void _clearActiveTask(Future<ServerProfileSyncResult> task) {
    if (identical(_activeTask, task)) {
      _activeTask = null;
    }
  }

  Future<void> synchronizeIfStale() async {
    final session = _authController.session;
    if (session == null) return;
    final metadata = await preferences.getServerProfileMetadata();
    final isStale =
        metadata == null ||
        metadata.owner != session.uid ||
        DateTime.now().difference(metadata.syncedAt) >= staleDuration;
    if (!isStale && !_lastSyncFailed) return;
    await synchronize();
  }

  void scheduleNetworkRecovery() {
    _networkRecoveryTimer?.cancel();
    _networkRecoveryTimer = Timer(const Duration(seconds: 3), () {
      unawaited(
        synchronizeIfStale().catchError((Object error, StackTrace stack) {
          commonPrint.log(error.toString(), logLevel: LogLevel.warning);
        }),
      );
    });
  }

  void invalidate() {
    _generation++;
    _networkRecoveryTimer?.cancel();
  }

  void dispose() {
    invalidate();
  }

  Future<ServerProfileSyncResult> _synchronize({required bool apply}) async {
    final session = _authController.session;
    if (session == null) {
      throw const GatewayException('Authentication required');
    }
    final owner = session.uid;
    final generation = _generation;
    try {
      await _authController.ensureValidAccessToken();
      final bytes = await _api.getLinks();
      _ensureCurrent(owner, generation);
      final contentHash = sha256.convert(bytes).toString();
      final cachedProfile = await _getValidCachedProfile(owner);
      if (cachedProfile != null) {
        final metadata = await preferences.getServerProfileMetadata();
        if (metadata?.contentHash == contentHash) {
          await preferences.saveServerProfileMetadata(
            owner: owner,
            contentHash: contentHash,
            syncedAt: DateTime.now(),
          );
          _ref.read(currentProfileIdProvider.notifier).value = cachedProfile.id;
          _lastSyncFailed = false;
          return const ServerProfileSyncResult(changed: false);
        }
      }
      final profiles = _ref.read(profilesProvider);
      final metadata = await preferences.getServerProfileMetadata();
      final sameOwner = metadata?.owner == owner;
      final profile = profiles.isEmpty
          ? Profile.normal(label: 'Starland')
          : profiles.first.copyWith(
              label: 'Starland',
              currentGroupName: sameOwner
                  ? profiles.first.currentGroupName
                  : null,
              selectedMap: sameOwner ? profiles.first.selectedMap : {},
              overwriteType: sameOwner
                  ? profiles.first.overwriteType
                  : OverwriteType.standard,
              scriptId: sameOwner ? profiles.first.scriptId : null,
            );
      final savedProfile = await profile.saveFile(bytes);
      _ensureCurrent(owner, generation);
      await _ref.read(profilesProvider.notifier).replaceAll([savedProfile]);
      for (final obsolete in profiles.where(
        (profile) => profile.id != savedProfile.id,
      )) {
        final file = File(await appPath.getProfilePath(obsolete.id.toString()));
        if (await file.exists()) {
          await file.safeDelete();
        }
      }
      _ref.read(currentProfileIdProvider.notifier).value = savedProfile.id;
      await preferences.saveServerProfileMetadata(
        owner: owner,
        contentHash: contentHash,
        syncedAt: DateTime.now(),
      );
      if (apply && _ref.read(initProvider)) {
        await _ref
            .read(setupActionProvider.notifier)
            .applyProfile(force: true, silence: true);
      }
      _lastSyncFailed = false;
      return const ServerProfileSyncResult(changed: true);
    } catch (_) {
      _lastSyncFailed = true;
      rethrow;
    }
  }

  Future<Profile?> _getValidCachedProfile(String owner) async {
    final metadata = await preferences.getServerProfileMetadata();
    if (metadata == null || metadata.owner != owner) return null;
    final profiles = _ref.read(profilesProvider);
    if (profiles.length != 1) return null;
    final profile = profiles.single;
    final file = File(await appPath.getProfilePath(profile.id.toString()));
    if (!await file.exists()) return null;
    final contentHash = sha256.convert(await file.readAsBytes()).toString();
    return contentHash == metadata.contentHash ? profile : null;
  }

  void _ensureCurrent(String owner, int generation) {
    if (generation != _generation || _authController.session?.uid != owner) {
      throw const GatewayException('Profile synchronization cancelled');
    }
  }
}
