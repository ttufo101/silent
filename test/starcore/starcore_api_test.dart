import 'package:fl_clash/auth/data/gateway_client.dart';
import 'package:fl_clash/starcore/data/starcore_api.dart';
import 'package:fl_clash/starcore/models/plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('getPlans uses the starcore gateway contract', () async {
    final client = _FakeGatewayClient({
      'plans': [
        {
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
        },
      ],
    });

    final plans = await StarcoreApi(client).getPlans();

    expect(client.module, 'starland.starcore.com');
    expect(client.method, 'GetPlans');
    expect(client.params, isEmpty);
    expect(plans, hasLength(1));
    expect(plans.single.type, PlanType.time);
  });

  test('getPlans rejects an invalid plan list', () async {
    final client = _FakeGatewayClient({'plans': 'invalid'});

    await expectLater(
      StarcoreApi(client).getPlans(),
      throwsA(isA<GatewayException>()),
    );
  });
}

class _FakeGatewayClient extends GatewayClient {
  final Map<String, dynamic> response;
  String? module;
  String? method;
  Map<String, dynamic>? params;

  _FakeGatewayClient(this.response);

  @override
  Future<Map<String, dynamic>> call({
    required String module,
    required String method,
    required Map<String, dynamic> params,
  }) async {
    this.module = module;
    this.method = method;
    this.params = params;
    return response;
  }
}
