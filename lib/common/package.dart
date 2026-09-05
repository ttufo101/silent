import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

import 'common.dart';

extension PackageInfoExtension on PackageInfo {
  String get ua => [
    'clash-verge/v2.5.2',
    '$appName/v$version',
    'Platform/${Platform.operatingSystem}',
  ].join(' ');
}
