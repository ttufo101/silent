import 'package:fl_clash/starcore/models/plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses snake case plan fields', () {
    final plan = Plan.fromJson({
      'plan_id': 'yearly',
      'name': 'Yearly',
      'plan_type': 'time',
      'duration_days': 365,
      'traffic_bytes': 0,
      'speed_limit_mbps': 50,
      'max_devices': 3,
      'description': '',
      'price_amount': 2000,
      'currency': 'USD',
    });

    expect(plan.id, 'yearly');
    expect(plan.type, PlanType.time);
    expect(plan.durationDays, 365);
    expect(plan.trafficBytes, 0);
    expect(plan.speedLimitMbps, 50);
    expect(plan.maxDevices, 3);
    expect(plan.priceAmount, 2000);
    expect(plan.currency, 'USD');
  });

  test('accepts camel case fields and integer strings', () {
    final plan = Plan.fromJson({
      'planId': 'traffic-1500',
      'name': 'Traffic',
      'planType': 'traffic',
      'durationDays': '0',
      'trafficBytes': '1610612736000',
      'speedLimitMbps': '50',
      'maxDevices': '3',
      'description': '',
      'priceAmount': '2000',
      'currency': 'USD',
    });

    expect(plan.type, PlanType.traffic);
    expect(plan.trafficBytes, 1500 * 1024 * 1024 * 1024);
  });

  test('uses proto3 defaults when zero-valued fields are omitted', () {
    final plan = Plan.fromJson({
      'plan_id': 'free',
      'name': 'Free',
      'plan_type': 'time',
      'currency': 'USD',
    });

    expect(plan.durationDays, 0);
    expect(plan.trafficBytes, 0);
    expect(plan.speedLimitMbps, 0);
    expect(plan.maxDevices, 0);
    expect(plan.description, '');
    expect(plan.priceAmount, 0);
  });

  test('rejects negative numeric fields', () {
    expect(
      () => Plan.fromJson({
        'plan_id': 'invalid',
        'name': 'Invalid',
        'plan_type': 'time',
        'duration_days': -1,
        'traffic_bytes': 0,
        'speed_limit_mbps': 0,
        'max_devices': 1,
        'description': '',
        'price_amount': 0,
        'currency': 'USD',
      }),
      throwsFormatException,
    );
  });
}
