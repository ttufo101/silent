import 'dart:ui';

class CountryMapPosition {
  const CountryMapPosition({
    required this.code,
    required this.nameZh,
    required this.nameEn,
    required this.latitude,
    required this.longitude,
  });

  final String code;
  final String nameZh;
  final String nameEn;
  final double latitude;
  final double longitude;

  String displayName(Locale locale) =>
      locale.languageCode == 'zh' ? nameZh : nameEn;

  static CountryMapPosition fromCode(String? value) {
    final code = value?.trim().toUpperCase() ?? '';
    return _positions[code] ??
        CountryMapPosition(
          code: code.isEmpty ? '--' : code,
          nameZh: code.isEmpty ? '未知位置' : code,
          nameEn: code.isEmpty ? 'Unknown location' : code,
          latitude: 0,
          longitude: 0,
        );
  }
}

const _positions = <String, CountryMapPosition>{
  'AU': CountryMapPosition(
    code: 'AU',
    nameZh: '澳大利亚',
    nameEn: 'Australia',
    latitude: -25.3,
    longitude: 133.8,
  ),
  'BR': CountryMapPosition(
    code: 'BR',
    nameZh: '巴西',
    nameEn: 'Brazil',
    latitude: -14.2,
    longitude: -51.9,
  ),
  'CA': CountryMapPosition(
    code: 'CA',
    nameZh: '加拿大',
    nameEn: 'Canada',
    latitude: 56.1,
    longitude: -106.3,
  ),
  'CH': CountryMapPosition(
    code: 'CH',
    nameZh: '瑞士',
    nameEn: 'Switzerland',
    latitude: 46.8,
    longitude: 8.2,
  ),
  'DE': CountryMapPosition(
    code: 'DE',
    nameZh: '德国',
    nameEn: 'Germany',
    latitude: 51.2,
    longitude: 10.5,
  ),
  'DK': CountryMapPosition(
    code: 'DK',
    nameZh: '丹麦',
    nameEn: 'Denmark',
    latitude: 56.3,
    longitude: 9.5,
  ),
  'ES': CountryMapPosition(
    code: 'ES',
    nameZh: '西班牙',
    nameEn: 'Spain',
    latitude: 40.5,
    longitude: -3.7,
  ),
  'FI': CountryMapPosition(
    code: 'FI',
    nameZh: '芬兰',
    nameEn: 'Finland',
    latitude: 61.9,
    longitude: 25.7,
  ),
  'FR': CountryMapPosition(
    code: 'FR',
    nameZh: '法国',
    nameEn: 'France',
    latitude: 46.2,
    longitude: 2.2,
  ),
  'GB': CountryMapPosition(
    code: 'GB',
    nameZh: '英国',
    nameEn: 'United Kingdom',
    latitude: 55.4,
    longitude: -3.4,
  ),
  'HK': CountryMapPosition(
    code: 'HK',
    nameZh: '中国香港',
    nameEn: 'Hong Kong',
    latitude: 22.3,
    longitude: 114.2,
  ),
  'ID': CountryMapPosition(
    code: 'ID',
    nameZh: '印度尼西亚',
    nameEn: 'Indonesia',
    latitude: -0.8,
    longitude: 113.9,
  ),
  'IE': CountryMapPosition(
    code: 'IE',
    nameZh: '爱尔兰',
    nameEn: 'Ireland',
    latitude: 53.1,
    longitude: -8.2,
  ),
  'IN': CountryMapPosition(
    code: 'IN',
    nameZh: '印度',
    nameEn: 'India',
    latitude: 20.6,
    longitude: 79.0,
  ),
  'IT': CountryMapPosition(
    code: 'IT',
    nameZh: '意大利',
    nameEn: 'Italy',
    latitude: 41.9,
    longitude: 12.6,
  ),
  'JP': CountryMapPosition(
    code: 'JP',
    nameZh: '日本',
    nameEn: 'Japan',
    latitude: 36.2,
    longitude: 138.3,
  ),
  'KR': CountryMapPosition(
    code: 'KR',
    nameZh: '韩国',
    nameEn: 'South Korea',
    latitude: 35.9,
    longitude: 127.8,
  ),
  'MY': CountryMapPosition(
    code: 'MY',
    nameZh: '马来西亚',
    nameEn: 'Malaysia',
    latitude: 4.2,
    longitude: 101.9,
  ),
  'NL': CountryMapPosition(
    code: 'NL',
    nameZh: '荷兰',
    nameEn: 'Netherlands',
    latitude: 52.1,
    longitude: 5.3,
  ),
  'NO': CountryMapPosition(
    code: 'NO',
    nameZh: '挪威',
    nameEn: 'Norway',
    latitude: 60.5,
    longitude: 8.5,
  ),
  'PH': CountryMapPosition(
    code: 'PH',
    nameZh: '菲律宾',
    nameEn: 'Philippines',
    latitude: 12.9,
    longitude: 121.8,
  ),
  'RU': CountryMapPosition(
    code: 'RU',
    nameZh: '俄罗斯',
    nameEn: 'Russia',
    latitude: 61.5,
    longitude: 105.3,
  ),
  'SE': CountryMapPosition(
    code: 'SE',
    nameZh: '瑞典',
    nameEn: 'Sweden',
    latitude: 60.1,
    longitude: 18.6,
  ),
  'SG': CountryMapPosition(
    code: 'SG',
    nameZh: '新加坡',
    nameEn: 'Singapore',
    latitude: 1.35,
    longitude: 103.82,
  ),
  'TH': CountryMapPosition(
    code: 'TH',
    nameZh: '泰国',
    nameEn: 'Thailand',
    latitude: 15.9,
    longitude: 100.99,
  ),
  'TR': CountryMapPosition(
    code: 'TR',
    nameZh: '土耳其',
    nameEn: 'Türkiye',
    latitude: 39.0,
    longitude: 35.2,
  ),
  'TW': CountryMapPosition(
    code: 'TW',
    nameZh: '中国台湾',
    nameEn: 'Taiwan',
    latitude: 23.7,
    longitude: 121.0,
  ),
  'US': CountryMapPosition(
    code: 'US',
    nameZh: '美国',
    nameEn: 'United States',
    latitude: 37.1,
    longitude: -95.7,
  ),
  'VN': CountryMapPosition(
    code: 'VN',
    nameZh: '越南',
    nameEn: 'Vietnam',
    latitude: 14.1,
    longitude: 108.3,
  ),
  'ZA': CountryMapPosition(
    code: 'ZA',
    nameZh: '南非',
    nameEn: 'South Africa',
    latitude: -30.6,
    longitude: 22.9,
  ),
};
