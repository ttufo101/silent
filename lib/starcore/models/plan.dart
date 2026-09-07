enum PlanType {
  time,
  traffic,
  unknown;

  factory PlanType.fromValue(String value) {
    return switch (value) {
      'time' => PlanType.time,
      'traffic' => PlanType.traffic,
      _ => PlanType.unknown,
    };
  }
}

class Plan {
  final String id;
  final String name;
  final PlanType type;
  final int durationDays;
  final int trafficBytes;
  final int speedLimitMbps;
  final int maxDevices;
  final String description;
  final int priceAmount;
  final String currency;

  const Plan({
    required this.id,
    required this.name,
    required this.type,
    required this.durationDays,
    required this.trafficBytes,
    required this.speedLimitMbps,
    required this.maxDevices,
    required this.description,
    required this.priceAmount,
    required this.currency,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    final type = _readString(json, 'plan_type', fallbackKey: 'planType');
    return Plan(
      id: _readString(json, 'plan_id', fallbackKey: 'planId'),
      name: _readString(json, 'name'),
      type: PlanType.fromValue(type),
      durationDays: _readInt(
        json,
        'duration_days',
        fallbackKey: 'durationDays',
      ),
      trafficBytes: _readInt(
        json,
        'traffic_bytes',
        fallbackKey: 'trafficBytes',
      ),
      speedLimitMbps: _readInt(
        json,
        'speed_limit_mbps',
        fallbackKey: 'speedLimitMbps',
      ),
      maxDevices: _readInt(json, 'max_devices', fallbackKey: 'maxDevices'),
      description: _readString(json, 'description', defaultValue: ''),
      priceAmount: _readInt(json, 'price_amount', fallbackKey: 'priceAmount'),
      currency: _readString(json, 'currency'),
    );
  }

  static String _readString(
    Map<String, dynamic> json,
    String key, {
    String? fallbackKey,
    String? defaultValue,
  }) {
    final hasValue =
        json.containsKey(key) ||
        (fallbackKey != null && json.containsKey(fallbackKey));
    if (!hasValue && defaultValue != null) return defaultValue;
    final value = json.containsKey(key)
        ? json[key]
        : fallbackKey == null
        ? null
        : json[fallbackKey];
    if (value is String) return value;
    throw FormatException('Invalid $key');
  }

  static int _readInt(
    Map<String, dynamic> json,
    String key, {
    String? fallbackKey,
    int defaultValue = 0,
  }) {
    final hasValue =
        json.containsKey(key) ||
        (fallbackKey != null && json.containsKey(fallbackKey));
    if (!hasValue) return defaultValue;
    final value = json.containsKey(key)
        ? json[key]
        : fallbackKey == null
        ? null
        : json[fallbackKey];
    final parsed = switch (value) {
      final int number => number,
      final num number
          when number.isFinite && number == number.roundToDouble() =>
        number.toInt(),
      final String text => int.tryParse(text),
      _ => null,
    };
    if (parsed == null || parsed < 0) {
      throw FormatException('Invalid $key');
    }
    return parsed;
  }
}
