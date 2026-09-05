import 'package:fl_clash/auth/data/gateway_client.dart';
import 'package:fl_clash/auth/models/auth_session.dart';
import 'package:fl_clash/common/common.dart';

class EmailCodeResult {
  const EmailCodeResult({required this.expireSeconds});

  final int expireSeconds;
}

class AuthApi {
  AuthApi(this._client);

  static const _loginModule = 'starland.login.com';
  static const _verificationModule = 'starland.vfcode.com';
  static const _passwordRecoveryScene = 'pwd_recovery';

  final GatewayClient _client;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final data = await _client.call(
      module: _loginModule,
      method: 'Login',
      params: {'email': email, 'password': password},
    );
    return _sessionFromData(data, email);
  }

  Future<AuthSession> register({
    required String email,
    required String password,
  }) async {
    final data = await _client.call(
      module: _loginModule,
      method: 'Register',
      params: {'email': email, 'password': password, 'code': ''},
    );
    return _sessionFromData(data, email);
  }

  Future<AuthSession> refresh(AuthSession session) async {
    final data = await _client.call(
      module: _loginModule,
      method: 'RefreshToken',
      params: {'refresh_token': session.refreshToken},
    );
    return _sessionFromData(data, session.email);
  }

  Future<EmailCodeResult> sendPasswordRecoveryCode(String email) async {
    final data = await _client.call(
      module: _verificationModule,
      method: 'SendEmailCode',
      params: {'email': email, 'scene': _passwordRecoveryScene},
    );
    if (data['success'] != true || data['expire_seconds'] is! int) {
      throw const GatewayException('Failed to send verification code');
    }
    return EmailCodeResult(expireSeconds: data['expire_seconds'] as int);
  }

  Future<String> getRestToken({
    required String email,
    required String code,
  }) async {
    try {
      final data = await _client.call(
        module: _loginModule,
        method: 'GetRestToken',
        params: {'email': email, 'scene': _passwordRecoveryScene, 'code': code},
      );
      final restToken = data['rest_token'];
      if (restToken is! String || restToken.isEmpty) {
        commonPrint.log(
          'GetRestToken response missing rest_token; fields=${data.keys.join(',')}',
        );
        throw const GatewayException('Invalid verification code');
      }
      return restToken;
    } on GatewayException catch (error) {
      commonPrint.log(
        'GetRestToken failed; gatewayCode=${error.code ?? 'none'}',
      );
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String email,
    required String restToken,
    required String password,
  }) async {
    final data = await _client.call(
      module: _loginModule,
      method: 'ResetPassword',
      params: {
        'email': email,
        'new_password': password,
        'rest_token': restToken,
      },
    );
    if (data['success'] != true) {
      throw const GatewayException('Failed to reset password');
    }
  }

  AuthSession _sessionFromData(Map<String, dynamic> data, String? email) {
    try {
      return AuthSession.fromGatewayJson({...data, 'email': email});
    } on FormatException {
      throw const GatewayException('Invalid login response');
    }
  }
}
