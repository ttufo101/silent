import 'dart:convert';

import 'package:fl_clash/auth/models/auth_session.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  const AuthStorage();

  static const _sessionKey = 'authSession';
  static const _storage = FlutterSecureStorage();

  Future<AuthSession?> read() async {
    final value = await _storage.read(key: _sessionKey);
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
    return _storage.write(
      key: _sessionKey,
      value: jsonEncode(session.toJson()),
    );
  }

  Future<void> clear() => _storage.delete(key: _sessionKey);
}
