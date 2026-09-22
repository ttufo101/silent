import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fl_clash/auth/auth_controller.dart';
import 'package:fl_clash/feedback/data/diagnostic_upload_client.dart';
import 'package:fl_clash/feedback/data/feedback_api.dart';
import 'package:fl_clash/feedback/models/diagnostic_task.dart';
import 'package:fl_clash/feedback/services/diagnostic_bundle_builder.dart';
import 'package:fl_clash/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DiagnosticSubmissionStage { preparing, uploading, registering }

typedef DiagnosticProgress =
    void Function(DiagnosticSubmissionStage stage, double progress);

class FeedbackService {
  FeedbackService({
    required FeedbackApi api,
    required DiagnosticUploadClient uploadClient,
    required AuthController authController,
    DiagnosticBundleBuilder? bundleBuilder,
  }) : _api = api,
       _uploadClient = uploadClient,
       _authController = authController,
       _bundleBuilder = bundleBuilder ?? DiagnosticBundleBuilder();

  static const _pendingTaskKey = 'pendingDiagnosticUpload';
  final FeedbackApi _api;
  final DiagnosticUploadClient _uploadClient;
  final AuthController _authController;
  final DiagnosticBundleBuilder _bundleBuilder;
  CancelToken? _cancelToken;

  Future<FeedbackSubmission> submitFeedback({
    required String category,
    required String content,
    required String contact,
    required String clientRequestId,
  }) async {
    await _authController.ensureValidAccessToken();
    return _api.submitFeedback(
      category: category,
      content: content,
      contact: contact,
      clientRequestId: clientRequestId,
    );
  }

  Future<PendingDiagnosticTask?> loadPendingTask() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_pendingTaskKey);
    if (value == null) return null;
    try {
      final task = PendingDiagnosticTask.fromJson(
        Map<String, dynamic>.from(jsonDecode(value) as Map),
      );
      if (task.ownerUid != _authController.session?.uid ||
          !await File(task.filePath).exists()) {
        final file = File(task.filePath);
        if (await file.exists()) await file.delete();
        await preferences.remove(_pendingTaskKey);
        return null;
      }
      return task;
    } on Object {
      await preferences.remove(_pendingTaskKey);
      return null;
    }
  }

  Future<FeedbackSubmission> submitDiagnostic({
    required List<Log> logs,
    required String description,
    required Map<String, Object?> runtimeState,
    required DiagnosticProgress onProgress,
  }) async {
    await _authController.ensureValidAccessToken();
    var task = await loadPendingTask();
    if (task == null) {
      onProgress(DiagnosticSubmissionStage.preparing, 0);
      task = await _bundleBuilder.build(
        ownerUid: _authController.session!.uid,
        logs: logs,
        description: description,
        runtimeState: runtimeState,
      );
      await _saveTask(task);
    }
    var uploaded = task.uploadedFile;
    if (uploaded == null) {
      onProgress(DiagnosticSubmissionStage.uploading, 0);
      uploaded = await _upload(task, onProgress);
      task = task.copyWith(uploadedFile: uploaded);
      await _saveTask(task);
    }
    onProgress(DiagnosticSubmissionStage.registering, 1);
    await _authController.ensureValidAccessToken();
    final result = await _api.submitDiagnosticLog(
      fileId: uploaded.fileId,
      fileName: uploaded.fileName,
      sizeBytes: uploaded.sizeBytes,
      sha256: uploaded.sha256,
      logStartedAt: task.logStartedAt,
      logEndedAt: task.logEndedAt,
      description: task.description,
      clientRequestId: task.idempotencyKey,
    );
    await discardPendingTask();
    return result;
  }

  Future<UploadedDiagnosticFile> _upload(
    PendingDiagnosticTask task,
    DiagnosticProgress onProgress,
  ) async {
    await _authController.ensureValidAccessToken();
    _cancelToken = CancelToken();
    try {
      return await _uploadClient.upload(
        file: File(task.filePath),
        accessToken: _authController.session!.accessToken,
        idempotencyKey: task.idempotencyKey,
        sizeBytes: task.sizeBytes,
        sha256: task.sha256,
        cancelToken: _cancelToken,
        onSendProgress: (sent, total) {
          onProgress(
            DiagnosticSubmissionStage.uploading,
            total <= 0 ? 0 : sent / total,
          );
        },
      );
    } on DiagnosticUploadException catch (error) {
      if (!error.authenticationFailed) rethrow;
      await _authController.ensureValidAccessToken(forceRefresh: true);
      return _uploadClient.upload(
        file: File(task.filePath),
        accessToken: _authController.session!.accessToken,
        idempotencyKey: task.idempotencyKey,
        sizeBytes: task.sizeBytes,
        sha256: task.sha256,
        cancelToken: _cancelToken,
        onSendProgress: (sent, total) {
          onProgress(
            DiagnosticSubmissionStage.uploading,
            total <= 0 ? 0 : sent / total,
          );
        },
      );
    } finally {
      _cancelToken = null;
    }
  }

  void cancelUpload() {
    _cancelToken?.cancel('Cancelled by user');
  }

  Future<void> discardPendingTask() async {
    final task = await loadPendingTask();
    if (task != null) {
      final file = File(task.filePath);
      if (await file.exists()) await file.delete();
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_pendingTaskKey);
  }

  Future<void> _saveTask(PendingDiagnosticTask task) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_pendingTaskKey, jsonEncode(task.toJson()));
  }
}
