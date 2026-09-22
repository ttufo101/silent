import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/feedback/models/diagnostic_task.dart';
import 'package:fl_clash/feedback/services/diagnostic_redactor.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:path/path.dart' as path;

class DiagnosticBundleBuilder {
  DiagnosticBundleBuilder({DiagnosticRedactor? redactor})
    : _redactor = redactor ?? DiagnosticRedactor();

  static const maxBundleSizeBytes = 10 * 1024 * 1024;
  final DiagnosticRedactor _redactor;

  Future<PendingDiagnosticTask> build({
    required String ownerUid,
    required List<Log> logs,
    required String description,
    required Map<String, Object?> runtimeState,
  }) async {
    final now = DateTime.now();
    final startedAt = logs.isEmpty
        ? now
        : DateTime.tryParse(logs.first.dateTime) ?? now;
    final endedAt = logs.isEmpty
        ? now
        : DateTime.tryParse(logs.last.dateTime) ?? now;
    final lines = logs.map(
      (log) => _redactor.redact(
        '[${log.dateTime}] [${log.logLevel.name}] ${log.payload}',
      ),
    );
    final manifest = {
      'app_version': globalState.packageInfo.version,
      'build_number': globalState.packageInfo.buildNumber,
      'platform': Platform.operatingSystem,
      'os_version': Platform.operatingSystemVersion,
      'log_started_at': startedAt.toUtc().toIso8601String(),
      'log_ended_at': endedAt.toUtc().toIso8601String(),
      'log_count': logs.length,
      'redaction_version': 1,
      'runtime': runtimeState,
    };
    final archive = Archive()
      ..addFile(
        ArchiveFile.string(
          'manifest.json',
          const JsonEncoder.withIndent('  ').convert(manifest),
        ),
      )
      ..addFile(ArchiveFile.string('runtime.log', lines.join('\n')));
    final encoded = ZipEncoder().encode(archive);
    if (encoded.length > maxBundleSizeBytes) {
      throw const FileSystemException('Diagnostic bundle is too large');
    }
    final idempotencyKey = utils.uuidV4;
    final directory = Directory(
      path.join(await appPath.homeDirPath, 'pending_diagnostics'),
    );
    await directory.create(recursive: true);
    final fileName = 'silent-diagnostic-${now.millisecondsSinceEpoch}.zip';
    final file = File(path.join(directory.path, fileName));
    await file.writeAsBytes(encoded, flush: true);
    final digest = sha256.convert(encoded).toString();
    return PendingDiagnosticTask(
      ownerUid: ownerUid,
      idempotencyKey: idempotencyKey,
      filePath: file.path,
      fileName: fileName,
      sizeBytes: encoded.length,
      sha256: digest,
      logStartedAt: startedAt.millisecondsSinceEpoch ~/ 1000,
      logEndedAt: endedAt.millisecondsSinceEpoch ~/ 1000,
      description: description,
    );
  }
}
