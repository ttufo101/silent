import 'package:fl_clash/auth/data/auth_api.dart';
import 'package:fl_clash/auth/data/auth_storage.dart';
import 'package:fl_clash/auth/data/gateway_client.dart';
import 'package:fl_clash/auth/models/auth_session.dart';
import 'package:fl_clash/common/startup_timing.dart';
import 'package:flutter/foundation.dart';

enum AuthStatus { initializing, unauthenticated, authenticated }

class AuthController extends ChangeNotifier {
  AuthController({
    GatewayClient? client,
    AuthStorage storage = const AuthStorage(),
  }) : _client = client ?? GatewayClient(),
       _storage = storage {
    api = AuthApi(_client);
  }

  final GatewayClient _client;
  final AuthStorage _storage;
  late final AuthApi api;
  AuthStatus status = AuthStatus.initializing;
  AuthSession? session;
  Future<void>? _refreshTask;
  bool _remember = false;
  int _sessionRevision = 0;

  Future<void> initialize() async {
    final revision = _sessionRevision;
    startupTiming.mark('session restoration started');
    final stored = await _storage.read();
    startupTiming.mark('session storage read completed');
    if (revision != _sessionRevision) return;
    if (stored == null) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    if (!stored.isRefreshValid) {
      await _storage.clear();
      if (revision != _sessionRevision) return;
      startupTiming.mark('expired session storage cleared');
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      var restored = stored;
      if (!stored.isAccessValid) {
        restored = await api.refresh(stored);
        if (revision != _sessionRevision) return;
        await _storage.write(restored);
        if (revision != _sessionRevision) return;
      }
      session = restored;
      _client.accessToken = restored.accessToken;
      _remember = true;
      status = AuthStatus.authenticated;
    } catch (_) {
      await _storage.clear();
      if (revision != _sessionRevision) return;
      session = null;
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
    required bool remember,
  }) async {
    startupTiming.start();
    startupTiming.mark('authentication request started');
    try {
      final result = await api.login(email: email, password: password);
      startupTiming.mark('authentication response received');
      _sessionRevision++;
      await _accept(result, remember: remember);
    } catch (_) {
      startupTiming.finish('authentication request failed');
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    startupTiming.start();
    startupTiming.mark('authentication request started');
    try {
      final result = await api.register(email: email, password: password);
      startupTiming.mark('authentication response received');
      _sessionRevision++;
      await _accept(result, remember: true);
    } catch (_) {
      startupTiming.finish('authentication request failed');
      rethrow;
    }
  }

  Future<void> _accept(AuthSession value, {required bool remember}) async {
    session = value;
    _remember = remember;
    _client.accessToken = value.accessToken;
    startupTiming.mark('session persistence started');
    if (remember) {
      await _storage.write(value);
    } else {
      await _storage.clear();
    }
    startupTiming.mark('session persistence completed');
    status = AuthStatus.authenticated;
    startupTiming.mark('authenticated state ready');
    notifyListeners();
  }

  Future<void> ensureValidAccessToken() async {
    final current = session;
    if (status != AuthStatus.authenticated || current == null) {
      throw const GatewayException('Authentication required');
    }
    if (current.isAccessValid) return;
    final existing = _refreshTask;
    if (existing != null) return existing;
    final task = _refresh(current);
    _refreshTask = task;
    try {
      await task;
    } finally {
      _refreshTask = null;
    }
  }

  Future<void> _refresh(AuthSession current) async {
    if (!current.isRefreshValid) {
      await logout();
      throw const GatewayException('Authentication expired');
    }
    try {
      final result = await api.refresh(current);
      session = result;
      _client.accessToken = result.accessToken;
      if (_remember) {
        await _storage.write(result);
      }
    } catch (_) {
      await logout();
      rethrow;
    }
  }

  Future<void> logout() async {
    _sessionRevision++;
    await _storage.clear();
    _client.accessToken = null;
    session = null;
    _remember = false;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
