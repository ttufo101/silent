import 'package:fl_clash/starcore/models/plan.dart';

class UserSubscription {
  const UserSubscription({
    required this.plan,
    required this.startsAt,
    required this.expiresAt,
    required this.remainingDays,
    required this.trafficTotalBytes,
    required this.trafficUsedBytes,
    required this.remainingTrafficBytes,
  });

  final Plan plan;
  final int startsAt;
  final int expiresAt;
  final int remainingDays;
  final int trafficTotalBytes;
  final int trafficUsedBytes;
  final int remainingTrafficBytes;

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      plan: Plan.fromJson(_readMap(json, 'plan')),
      startsAt: _readInt(json, 'starts_at', fallbackKey: 'startsAt'),
      expiresAt: _readInt(json, 'expires_at', fallbackKey: 'expiresAt'),
      remainingDays: _readInt(
        json,
        'remaining_days',
        fallbackKey: 'remainingDays',
      ),
      trafficTotalBytes: _readInt(
        json,
        'traffic_total_bytes',
        fallbackKey: 'trafficTotalBytes',
      ),
      trafficUsedBytes: _readInt(
        json,
        'traffic_used_bytes',
        fallbackKey: 'trafficUsedBytes',
      ),
      remainingTrafficBytes: _readInt(
        json,
        'remaining_traffic_bytes',
        fallbackKey: 'remainingTrafficBytes',
      ),
    );
  }
}

class UserInfo {
  const UserInfo({
    required this.username,
    required this.remainingDays,
    required this.remainingTrafficBytes,
    required this.linkUrl,
    required this.activeEntitlementType,
    required this.unlimited,
    required this.boundDeviceCount,
    this.currentPlan,
    this.timeSubscription,
    this.trafficSubscription,
  });

  final String username;
  final Plan? currentPlan;
  final int remainingDays;
  final int remainingTrafficBytes;
  final String linkUrl;
  final UserSubscription? timeSubscription;
  final UserSubscription? trafficSubscription;
  final String activeEntitlementType;
  final bool unlimited;
  final int boundDeviceCount;

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      username: _readString(json, 'username'),
      currentPlan: _readOptionalPlan(
        json,
        'current_plan',
        fallbackKey: 'currentPlan',
      ),
      remainingDays: _readInt(
        json,
        'remaining_days',
        fallbackKey: 'remainingDays',
      ),
      remainingTrafficBytes: _readInt(
        json,
        'remaining_traffic_bytes',
        fallbackKey: 'remainingTrafficBytes',
      ),
      linkUrl: _readString(
        json,
        'link_url',
        fallbackKey: 'linkUrl',
        defaultValue: '',
      ),
      timeSubscription: _readOptionalSubscription(
        json,
        'time_subscription',
        fallbackKey: 'timeSubscription',
      ),
      trafficSubscription: _readOptionalSubscription(
        json,
        'traffic_subscription',
        fallbackKey: 'trafficSubscription',
      ),
      activeEntitlementType: _readString(
        json,
        'active_entitlement_type',
        fallbackKey: 'activeEntitlementType',
        defaultValue: '',
      ),
      unlimited: _readBool(json, 'unlimited'),
      boundDeviceCount: _readInt(
        json,
        'bound_device_count',
        fallbackKey: 'boundDeviceCount',
      ),
    );
  }
}

Plan? _readOptionalPlan(
  Map<String, dynamic> json,
  String key, {
  String? fallbackKey,
}) {
  final value = _readValue(json, key, fallbackKey: fallbackKey);
  if (value == null) return null;
  if (value is Map && value.isEmpty) return null;
  if (value is! Map) throw FormatException('Invalid $key');
  return Plan.fromJson(Map<String, dynamic>.from(value));
}

UserSubscription? _readOptionalSubscription(
  Map<String, dynamic> json,
  String key, {
  String? fallbackKey,
}) {
  final value = _readValue(json, key, fallbackKey: fallbackKey);
  if (value == null) return null;
  if (value is Map && value.isEmpty) return null;
  if (value is! Map) throw FormatException('Invalid $key');
  return UserSubscription.fromJson(Map<String, dynamic>.from(value));
}

Map<String, dynamic> _readMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! Map || value.isEmpty) throw FormatException('Invalid $key');
  return Map<String, dynamic>.from(value);
}

String _readString(
  Map<String, dynamic> json,
  String key, {
  String? fallbackKey,
  String? defaultValue,
}) {
  final value = _readValue(json, key, fallbackKey: fallbackKey);
  if (value == null && defaultValue != null) return defaultValue;
  if (value is String) return value;
  throw FormatException('Invalid $key');
}

int _readInt(
  Map<String, dynamic> json,
  String key, {
  String? fallbackKey,
  int defaultValue = 0,
}) {
  final value = _readValue(json, key, fallbackKey: fallbackKey);
  if (value == null) return defaultValue;
  final parsed = switch (value) {
    final int number => number,
    final num number when number.isFinite && number == number.roundToDouble() =>
      number.toInt(),
    final String text => int.tryParse(text),
    _ => null,
  };
  if (parsed == null || parsed < 0) throw FormatException('Invalid $key');
  return parsed;
}

bool _readBool(
  Map<String, dynamic> json,
  String key, {
  String? fallbackKey,
  bool defaultValue = false,
}) {
  final value = _readValue(json, key, fallbackKey: fallbackKey);
  if (value == null) return defaultValue;
  if (value is bool) return value;
  throw FormatException('Invalid $key');
}

Object? _readValue(
  Map<String, dynamic> json,
  String key, {
  String? fallbackKey,
}) {
  if (json.containsKey(key)) return json[key];
  return fallbackKey == null ? null : json[fallbackKey];
}
