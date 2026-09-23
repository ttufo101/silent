import 'package:fl_clash/auth/data/gateway_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GatewayClient.isTrustedUpdateUri', () {
    test('更新服务器 https（自签名证书）应被信任', () {
      final uri = Uri.parse(
        'https://106.52.77.108/api/v1/app-releases/xxx',
      );
      expect(GatewayClient.isTrustedUpdateUri(uri), isTrue);
    });

    test('更新服务器 http:80 应被信任（兼容旧配置）', () {
      final uri = Uri.parse('http://106.52.77.108/api/v1/app-releases/xxx');
      expect(GatewayClient.isTrustedUpdateUri(uri), isTrue);
    });

    test('更新服务器其他 scheme 应被拒绝', () {
      expect(
        GatewayClient.isTrustedUpdateUri(
          Uri.parse('ftp://106.52.77.108/package.apk'),
        ),
        isFalse,
      );
    });

    test('未知主机应被拒绝', () {
      expect(
        GatewayClient.isTrustedUpdateUri(
          Uri.parse('https://evil.example.com/package.apk'),
        ),
        isFalse,
      );
    });
  });
}
