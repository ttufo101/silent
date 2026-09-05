import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constant.dart';

class Preferences {
  static const _vpnPermissionRequestedKey = 'vpnPermissionRequested';
  static const _serverProfileOwnerKey = 'serverProfileOwner';
  static const _serverProfileHashKey = 'serverProfileHash';
  static const _serverProfileSyncedAtKey = 'serverProfileSyncedAt';

  static Preferences? _instance;
  Completer<SharedPreferences?> sharedPreferencesCompleter = Completer();

  Future<bool> get isInit async =>
      await sharedPreferencesCompleter.future != null;

  Preferences._internal() {
    SharedPreferences.getInstance()
        .then((value) => sharedPreferencesCompleter.complete(value))
        .onError((_, _) => sharedPreferencesCompleter.complete(null));
  }

  factory Preferences() {
    _instance ??= Preferences._internal();
    return _instance!;
  }

  Future<int> getVersion() async {
    final preferences = await sharedPreferencesCompleter.future;
    return preferences?.getInt('version') ?? 0;
  }

  Future<void> setVersion(int version) async {
    final preferences = await sharedPreferencesCompleter.future;
    await preferences?.setInt('version', version);
  }

  Future<bool> get hasRequestedVpnPermission async {
    final preferences = await sharedPreferencesCompleter.future;
    return preferences?.getBool(_vpnPermissionRequestedKey) ?? false;
  }

  Future<bool> markVpnPermissionRequested() async {
    final preferences = await sharedPreferencesCompleter.future;
    return preferences?.setBool(_vpnPermissionRequestedKey, true) ?? false;
  }

  Future<({String owner, String contentHash, DateTime syncedAt})?>
  getServerProfileMetadata() async {
    final preferences = await sharedPreferencesCompleter.future;
    final owner = preferences?.getString(_serverProfileOwnerKey);
    final contentHash = preferences?.getString(_serverProfileHashKey);
    final syncedAt = preferences?.getInt(_serverProfileSyncedAtKey);
    if (owner == null || contentHash == null || syncedAt == null) return null;
    return (
      owner: owner,
      contentHash: contentHash,
      syncedAt: DateTime.fromMillisecondsSinceEpoch(syncedAt),
    );
  }

  Future<void> saveServerProfileMetadata({
    required String owner,
    required String contentHash,
    required DateTime syncedAt,
  }) async {
    final preferences = await sharedPreferencesCompleter.future;
    await preferences?.setString(_serverProfileOwnerKey, owner);
    await preferences?.setString(_serverProfileHashKey, contentHash);
    await preferences?.setInt(
      _serverProfileSyncedAtKey,
      syncedAt.millisecondsSinceEpoch,
    );
  }

  Future<void> clearServerProfileMetadata() async {
    final preferences = await sharedPreferencesCompleter.future;
    await preferences?.remove(_serverProfileOwnerKey);
    await preferences?.remove(_serverProfileHashKey);
    await preferences?.remove(_serverProfileSyncedAtKey);
  }

  Future<void> saveShareState(SharedState shareState) async {
    final preferences = await sharedPreferencesCompleter.future;
    await preferences?.setString('sharedState', json.encode(shareState));
  }

  Future<Map<String, Object?>?> getConfigMap() async {
    try {
      final preferences = await sharedPreferencesCompleter.future;
      final configString = preferences?.getString(configKey);
      if (configString == null) return null;
      final Map<String, Object?>? configMap = json.decode(configString);
      return configMap;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, Object?>?> getClashConfigMap() async {
    try {
      final preferences = await sharedPreferencesCompleter.future;
      final clashConfigString = preferences?.getString(clashConfigKey);
      if (clashConfigString == null) return null;
      return json.decode(clashConfigString);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearClashConfig() async {
    try {
      final preferences = await sharedPreferencesCompleter.future;
      await preferences?.remove(clashConfigKey);
      return;
    } catch (_) {
      return;
    }
  }

  Future<Config?> getConfig() async {
    final configMap = await getConfigMap();
    if (configMap == null) {
      return null;
    }
    return Config.fromJson(configMap);
  }

  Future<bool> saveConfig(Config config) async {
    final preferences = await sharedPreferencesCompleter.future;
    return preferences?.setString(configKey, json.encode(config)) ?? false;
  }

  Future<void> clearPreferences() async {
    final sharedPreferencesIns = await sharedPreferencesCompleter.future;
    await sharedPreferencesIns?.clear();
  }
}

final preferences = Preferences();
