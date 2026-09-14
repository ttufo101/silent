import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/proxies/common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('countryCodeFromName', () {
    test('parses flag emoji in node name', () {
      expect(countryCodeFromName('🇯🇵 东京 01'), 'jp');
      expect(countryCodeFromName('🇸🇬 SG-01'), 'sg');
    });

    test('parses Chinese keywords', () {
      expect(countryCodeFromName('香港 02'), 'hk');
      expect(countryCodeFromName('新加坡 01'), 'sg');
      expect(countryCodeFromName('印度尼西亚 节点'), 'id');
      expect(countryCodeFromName('美国 洛杉矶'), 'us');
    });

    test('parses English keywords', () {
      expect(countryCodeFromName('Tokyo Node'), 'jp');
      expect(countryCodeFromName('Singapore 01'), 'sg');
      expect(countryCodeFromName('usa-three'), 'us');
      expect(countryCodeFromName('America 01'), 'us');
    });

    test('parses standalone abbreviation with word boundaries', () {
      expect(countryCodeFromName('US-01'), 'us');
      expect(countryCodeFromName('uk special'), 'gb');
    });

    test('does not match abbreviation inside words', () {
      expect(countryCodeFromName('Rush Hour'), isNull);
      expect(countryCodeFromName('sinpo-one'), isNull);
    });
  });

  group('normalizeCountryCode', () {
    test('accepts two-letter codes', () {
      expect(normalizeCountryCode('US'), 'us');
      expect(normalizeCountryCode(' sg '), 'sg');
    });

    test('accepts full English country names', () {
      expect(normalizeCountryCode('United States'), 'us');
    });

    test('returns null for empty or unknown values', () {
      expect(normalizeCountryCode(null), isNull);
      expect(normalizeCountryCode(''), isNull);
      expect(normalizeCountryCode('sinpo-one'), isNull);
    });
  });

  group('resolveProxyCountryCode', () {
    test('resolves through group chain', () {
      final proxiesByName = {
        'urltest':
            const Proxy(name: 'urltest', type: 'URLTest', now: 'sinpo-one'),
        'sinpo-one': const Proxy(name: 'sinpo-one', type: 'Shadowsocks'),
        'JP: node': const Proxy(name: 'JP: node', type: 'Shadowsocks'),
      };
      expect(
        resolveProxyCountryCode(
          proxiesByName['urltest']!,
          proxiesByName,
        ),
        isNull,
      );
      expect(
        resolveProxyCountryCode(
          proxiesByName['JP: node']!,
          proxiesByName,
        ),
        'jp',
      );
    });

    test('resolves keyword-named real node inside group', () {
      final proxiesByName = {
        'urltest': const Proxy(name: 'urltest', type: 'URLTest', now: '香港 01'),
        '香港 01': const Proxy(name: '香港 01', type: 'Shadowsocks'),
      };
      expect(
        resolveProxyCountryCode(proxiesByName['urltest']!, proxiesByName),
        'hk',
      );
    });
  });
}
