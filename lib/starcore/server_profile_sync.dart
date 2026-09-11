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
import 'package:fl_clash/starcore/subscription_access.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServerProfileSyncResult {
  const ServerProfileSyncResult({
    required this.changed,
    required this.hasSubscription,
  });

  final bool changed;
  final bool hasSubscription;
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
    final cachedProfile = await _getValidCachedProfile(session.uid);
    if (cachedProfile != null) {
      _ref.read(currentProfileIdProvider.notifier).value = cachedProfile.id;
      _setAccessStatus(SubscriptionAccessStatus.active);
      return true;
    }
    _setAccessStatus(SubscriptionAccessStatus.checking);
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
    _setAccessStatus(SubscriptionAccessStatus.checking);
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
    var synchronizationCompleted = false;
    try {
      await _authController.ensureValidAccessToken();
      startupTiming.mark('access token ready');
      final links = await _api.getLinks();
      startupTiming.mark('subscription resolved');
      _ensureCurrent(owner, generation);
      if (!links.hasSubscription) {
        _setAccessStatus(SubscriptionAccessStatus.inactive);
        return _removeSubscriptionAccess(owner, generation);
      }
      _setAccessStatus(SubscriptionAccessStatus.active);
      final bytes = links.content!;
      final contentHash = sha256.convert(bytes).toString();
      startupTiming.mark('profile hash ready');
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
          _setAccessStatus(SubscriptionAccessStatus.active);
          return const ServerProfileSyncResult(
            changed: false,
            hasSubscription: true,
          );
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
      startupTiming.mark('profile file saved');
      _ensureCurrent(owner, generation);
      await _ref.read(profilesProvider.notifier).replaceAll([savedProfile]);
      startupTiming.mark('profile database updated');
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
      startupTiming.mark('profile metadata saved');
      _lastSyncFailed = false;
      synchronizationCompleted = true;
      startupTiming.mark('profile persisted');
      if (apply) {
        await applyCurrentProfile();
      }
      return const ServerProfileSyncResult(
        changed: true,
        hasSubscription: true,
      );
    } catch (_) {
      if (!synchronizationCompleted) {
        _lastSyncFailed = true;
      }
      rethrow;
    }
  }

  Future<void> applyCurrentProfile() async {
    if (!_ref.read(initProvider)) return;
    if (_ref.read(coreStatusProvider) == CoreStatus.connected) {
      await _ref
          .read(setupActionProvider.notifier)
          .applyProfile(force: true, silence: true);
      return;
    }
    await globalState.ensureCoreReady();
  }

  Future<ServerProfileSyncResult> _removeSubscriptionAccess(
    String owner,
    int generation,
  ) async {
    if (_ref.read(initProvider) &&
        _ref.read(coreStatusProvider) == CoreStatus.connected) {
      await _ref.read(setupActionProvider.notifier).setRunning(false);
    }
    _ensureCurrent(owner, generation);
    final profiles = _ref.read(profilesProvider);
    await _ref.read(profilesProvider.notifier).replaceAll([]);
    for (final profile in profiles) {
      final file = File(await appPath.getProfilePath(profile.id.toString()));
      if (await file.exists()) {
        await file.safeDelete();
      }
    }
    _ref.read(currentProfileIdProvider.notifier).value = null;
    await preferences.clearServerProfileMetadata();
    _ensureCurrent(owner, generation);
    _lastSyncFailed = false;
    return ServerProfileSyncResult(
      changed: profiles.isNotEmpty,
      hasSubscription: false,
    );
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

  void _setAccessStatus(SubscriptionAccessStatus value) {
    _ref.read(subscriptionAccessStatusProvider.notifier).set(value);
  }
}
