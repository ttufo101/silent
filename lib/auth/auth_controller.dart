import 'package:fl_clash/auth/data/auth_api.dart';
import 'package:fl_clash/auth/data/auth_storage.dart';
import 'package:fl_clash/auth/data/gateway_client.dart';
import 'package:fl_clash/auth/models/auth_session.dart';
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

  Future<void> initialize() async {
    final stored = await _storage.read();
    if (stored == null || !stored.isRefreshValid) {
      await _storage.clear();
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      session = stored.isAccessValid ? stored : await api.refresh(stored);
      _client.accessToken = session!.accessToken;
      await _storage.write(session!);
      _remember = true;
      status = AuthStatus.authenticated;
    } catch (_) {
      await _storage.clear();
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
    final result = await api.login(email: email, password: password);
    await _accept(result, remember: remember);
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    final result = await api.register(email: email, password: password);
    await _accept(result, remember: true);
  }

  Future<void> _accept(AuthSession value, {required bool remember}) async {
    session = value;
    _remember = remember;
    _client.accessToken = value.accessToken;
    if (remember) {
      await _storage.write(value);
    } else {
      await _storage.clear();
    }
    status = AuthStatus.authenticated;
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
    await _storage.clear();
    _client.accessToken = null;
    session = null;
    _remember = false;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
