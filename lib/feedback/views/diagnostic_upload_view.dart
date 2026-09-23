import 'package:dio/dio.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/feedback/data/diagnostic_upload_client.dart';
import 'package:fl_clash/feedback/models/diagnostic_task.dart';
import 'package:fl_clash/feedback/providers.dart';
import 'package:fl_clash/feedback/services/feedback_service.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiagnosticUploadView extends ConsumerStatefulWidget {
  const DiagnosticUploadView({super.key});

  @override
  ConsumerState<DiagnosticUploadView> createState() =>
      _DiagnosticUploadViewState();
}

class _DiagnosticUploadViewState
    extends ConsumerState<DiagnosticUploadView> {
  final _descriptionController = TextEditingController();
  PendingDiagnosticTask? _pendingTask;
  DiagnosticSubmissionStage? _stage;
  var _progress = 0.0;
  var _submitting = false;
  var _loadingPending = true;
  String? _errorText;
  String? _submittedId;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    final task = await ref.read(feedbackServiceProvider).loadPendingTask();
    if (!mounted) return;
    setState(() {
      _pendingTask = task;
      _loadingPending = false;
      if (task != null) _descriptionController.text = task.description;
    });
  }

  Future<void> _discardPending() async {
    await ref.read(feedbackServiceProvider).discardPendingTask();
    if (!mounted) return;
    setState(() {
      _pendingTask = null;
      _descriptionController.clear();
      _errorText = null;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _errorText = null;
      _submittedId = null;
    });
    final appSetting = ref.read(appSettingProvider);
    final coreStatus = ref.read(coreStatusProvider);
    try {
      final result = await ref.read(feedbackServiceProvider).submitDiagnostic(
        logs: List.of(ref.read(logsProvider).list),
        description: _descriptionController.text.trim(),
        runtimeState: {
          'core_status': coreStatus.name,
          'core_logs_enabled': appSetting.openLogs,
          'auto_run': appSetting.autoRun,
        },
        onProgress: (stage, progress) {
          if (!mounted) return;
          setState(() {
            _stage = stage;
            _progress = progress.clamp(0.0, 1.0);
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _submittedId = result.id;
        _pendingTask = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      commonPrint.log('Diagnostic upload failed: $error');
      setState(() => _errorText = _errorMessage(error));
      await _loadPending();
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
          _stage = null;
        });
      }
    }
  }

  String _stageLabel(BuildContext context) {
    final l10n = context.appLocalizations;
    return switch (_stage) {
      DiagnosticSubmissionStage.preparing => l10n.diagnosticPreparing,
      DiagnosticSubmissionStage.uploading => l10n.diagnosticUploading,
      DiagnosticSubmissionStage.registering => l10n.diagnosticRegistering,
      null => l10n.uploadDiagnosticLogs,
    };
  }

  String _errorMessage(Object error) {
    final l10n = context.appLocalizations;
    if (error is DioException && CancelToken.isCancel(error)) {
      return l10n.diagnosticCancelled;
    }
    if (error is DiagnosticUploadException) {
      return switch (error.code) {
        'FILE_TOO_LARGE' => l10n.diagnosticFileTooLarge,
        'UNSUPPORTED_FILE_TYPE' => l10n.diagnosticUnsupportedFile,
        'FILE_SIZE_MISMATCH' ||
        'CHECKSUM_MISMATCH' ||
        'UPLOAD_VERIFICATION_FAILED' => l10n.diagnosticVerificationFailed,
        'UPLOAD_IN_PROGRESS' => l10n.diagnosticUploadInProgress,
        'IDEMPOTENCY_CONFLICT' => l10n.diagnosticTaskConflict,
        'STORAGE_UNAVAILABLE' => l10n.diagnosticStorageUnavailable,
        _ => l10n.diagnosticUploadFailed,
      };
    }
    return l10n.diagnosticUploadFailed;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final logCount = ref.watch(logsProvider.select((logs) => logs.length));
    return CommonScaffold(
      title: l10n.uploadDiagnosticLogs,
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.privacy_tip_outlined,
                              color: context.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.diagnosticPrivacyTitle,
                                style: context.textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(l10n.diagnosticPrivacyDescription),
                        const SizedBox(height: 12),
                        Text(l10n.diagnosticLogCount(logCount)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: SwitchListTile(
                    title: Text(l10n.logcat),
                    subtitle: Text(l10n.logcatDesc),
                    value: ref.watch(
                      appSettingProvider.select((state) => state.openLogs),
                    ),
                    onChanged: (value) {
                      ref
                          .read(appSettingProvider.notifier)
                          .update((state) => state.copyWith(openLogs: value));
                    },
                  ),
                ),
                if (!_loadingPending && _pendingTask != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: context.colorScheme.secondaryContainer,
                    child: ListTile(
                      leading: const Icon(Icons.restore_outlined),
                      title: Text(l10n.diagnosticPendingTitle),
                      subtitle: Text(l10n.diagnosticPendingDescription),
                      trailing: TextButton(
                        onPressed: _submitting ? null : _discardPending,
                        child: Text(l10n.discard),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  enabled: !_submitting && _pendingTask == null,
                  minLines: 4,
                  maxLines: 8,
                  inputFormatters: [LengthLimitingTextInputFormatter(1000)],
                  decoration: InputDecoration(
                    labelText: l10n.diagnosticDescription,
                    hintText: l10n.diagnosticDescriptionHint,
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
                if (_submitting) ...[
                  const SizedBox(height: 24),
                  LinearProgressIndicator(
                    value: _stage == DiagnosticSubmissionStage.uploading
                        ? _progress
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(_stageLabel(context), textAlign: TextAlign.center),
                ],
                if (_errorText != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorText!,
                    style: TextStyle(color: context.colorScheme.error),
                  ),
                ],
                if (_submittedId != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: context.colorScheme.primaryContainer,
                    child: ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(l10n.diagnosticSubmitted),
                      subtitle: Text(l10n.diagnosticNumber(_submittedId!)),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _submitting || _loadingPending ? null : _submit,
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: Text(
                    _pendingTask == null
                        ? l10n.uploadDiagnosticLogs
                        : l10n.retry,
                  ),
                ),
                if (_submitting) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      ref.read(feedbackServiceProvider).cancelUpload();
                    },
                    child: Text(l10n.cancel),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
