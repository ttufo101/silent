import 'package:fl_clash/feedback/data/diagnostic_upload_client.dart';

class PendingDiagnosticTask {
  const PendingDiagnosticTask({
    required this.ownerUid,
    required this.idempotencyKey,
    required this.filePath,
    required this.fileName,
    required this.sizeBytes,
    required this.sha256,
    required this.logStartedAt,
    required this.logEndedAt,
    required this.description,
    this.uploadedFile,
  });

  final String ownerUid;
  final String idempotencyKey;
  final String filePath;
  final String fileName;
  final int sizeBytes;
  final String sha256;
  final int logStartedAt;
  final int logEndedAt;
  final String description;
  final UploadedDiagnosticFile? uploadedFile;

  PendingDiagnosticTask copyWith({UploadedDiagnosticFile? uploadedFile}) {
    return PendingDiagnosticTask(
      ownerUid: ownerUid,
      idempotencyKey: idempotencyKey,
      filePath: filePath,
      fileName: fileName,
      sizeBytes: sizeBytes,
      sha256: sha256,
      logStartedAt: logStartedAt,
      logEndedAt: logEndedAt,
      description: description,
      uploadedFile: uploadedFile ?? this.uploadedFile,
    );
  }

  Map<String, dynamic> toJson() => {
    'owner_uid': ownerUid,
    'idempotency_key': idempotencyKey,
    'file_path': filePath,
    'file_name': fileName,
    'size_bytes': sizeBytes,
    'sha256': sha256,
    'log_started_at': logStartedAt,
    'log_ended_at': logEndedAt,
    'description': description,
    'uploaded_file': uploadedFile?.toJson(),
  };

  factory PendingDiagnosticTask.fromJson(Map<String, dynamic> json) {
    final uploaded = json['uploaded_file'];
    return PendingDiagnosticTask(
      ownerUid: json['owner_uid'] as String,
      idempotencyKey: json['idempotency_key'] as String,
      filePath: json['file_path'] as String,
      fileName: json['file_name'] as String,
      sizeBytes: (json['size_bytes'] as num).toInt(),
      sha256: json['sha256'] as String,
      logStartedAt: (json['log_started_at'] as num).toInt(),
      logEndedAt: (json['log_ended_at'] as num).toInt(),
      description: json['description'] as String,
      uploadedFile: uploaded is Map
          ? UploadedDiagnosticFile.fromJson(
              Map<String, dynamic>.from(uploaded),
            )
          : null,
    );
  }
}
