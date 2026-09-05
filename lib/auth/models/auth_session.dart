class AuthSession {
  const AuthSession({
    required this.uid,
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpireAt,
    required this.refreshExpireAt,
    this.email,
  });

  final String uid;
  final String accessToken;
  final String refreshToken;
  final DateTime accessExpireAt;
  final DateTime refreshExpireAt;
  final String? email;

  bool get isAccessValid =>
      accessExpireAt.isAfter(DateTime.now().add(const Duration(seconds: 30)));

  bool get isRefreshValid => refreshExpireAt.isAfter(DateTime.now());

  AuthSession copyWith({
    String? uid,
    String? accessToken,
    String? refreshToken,
    DateTime? accessExpireAt,
    DateTime? refreshExpireAt,
    String? email,
  }) {
    return AuthSession(
      uid: uid ?? this.uid,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      accessExpireAt: accessExpireAt ?? this.accessExpireAt,
      refreshExpireAt: refreshExpireAt ?? this.refreshExpireAt,
      email: email ?? this.email,
    );
  }

  factory AuthSession.fromGatewayJson(Map<String, dynamic> json) {
    return AuthSession(
      uid: _requiredString(json, 'uid'),
      accessToken: _requiredString(json, 'access_token'),
      refreshToken: _requiredString(json, 'refresh_token'),
      accessExpireAt: _dateTimeFromProtocolValue(json['access_expire_at']),
      refreshExpireAt: _dateTimeFromProtocolValue(json['refresh_expire_at']),
      email: json['email'] as String?,
    );
  }

  factory AuthSession.fromStorageJson(Map<String, dynamic> json) {
    return AuthSession(
      uid: json['uid'] as String,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      accessExpireAt: _dateTimeFromProtocolValue(json['access_expire_at']),
      refreshExpireAt: _dateTimeFromProtocolValue(json['refresh_expire_at']),
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'access_expire_at': (accessExpireAt.millisecondsSinceEpoch ~/ 1000)
          .toString(),
      'refresh_expire_at': (refreshExpireAt.millisecondsSinceEpoch ~/ 1000)
          .toString(),
      'email': email,
    };
  }
}

DateTime _dateTimeFromProtocolValue(Object? value) {
  if (value is! String) {
    throw const FormatException('Invalid protocol timestamp');
  }
  final seconds = int.tryParse(value);
  if (seconds == null) {
    throw const FormatException('Invalid protocol timestamp');
  }
  return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw FormatException('Invalid LoginResponse.$key');
  }
  return value;
}
