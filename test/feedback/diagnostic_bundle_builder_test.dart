import 'dart:io';

import 'package:fl_clash/common/path.dart';
import 'package:fl_clash/feedback/services/diagnostic_bundle_builder.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('builds a diagnostic archive from current logs', () async {
    final directory = await Directory.systemTemp.createTemp(
      'silent-diagnostic-test-',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => directory.path,
        );
    await appPath.dataDir.future;
    globalState.packageInfo = PackageInfo(
      appName: 'silent',
      packageName: 'fl_clash',
      version: '0.3.0',
      buildNumber: '1',
    );

    final task = await DiagnosticBundleBuilder().build(
      ownerUid: '123',
      logs: [Log.app('test log')],
      description: 'test',
      runtimeState: const {
        'core_status': 'disconnected',
        'core_logs_enabled': true,
        'auto_run': false,
      },
    );

    final file = File(task.filePath);
    expect(await file.exists(), isTrue);
    expect(await file.length(), task.sizeBytes);
    expect(task.sha256, hasLength(64));

    await directory.delete(recursive: true);
  });
}
