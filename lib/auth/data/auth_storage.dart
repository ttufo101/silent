import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/auth/models/auth_session.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  const AuthStorage();

  static const _sessionKey = 'authSession';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(storageNamespace: 'silent_auth_v1'),
  );
  static const _legacyStorage = FlutterSecureStorage();
  static Future<AuthSession?>? _readTask;

  static void prefetch() {
    _readTask ??= const AuthStorage()._read();
  }

  Future<AuthSession?> read() {
    return _readTask ??= _read();
  }

  Future<AuthSession?> _read() async {
    var value = await _storage.read(key: _sessionKey);
    if (value == null && Platform.isAndroid) {
      value = await _legacyStorage.read(key: _sessionKey);
      if (value != null) {
        await _storage.write(key: _sessionKey, value: value);
        await _legacyStorage.delete(key: _sessionKey);
      }
    }
    if (value == null) return null;
    try {
      return AuthSession.fromStorageJson(
        Map<String, dynamic>.from(jsonDecode(value) as Map),
      );
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> write(AuthSession session) {
    _readTask = Future.value(session);
    return _storage.write(
      key: _sessionKey,
      value: jsonEncode(session.toJson()),
    );
  }

  Future<void> clear() async {
    _readTask = Future.value();
    await _storage.delete(key: _sessionKey);
    if (Platform.isAndroid) {
      await _legacyStorage.delete(key: _sessionKey);
    }
  }
}
