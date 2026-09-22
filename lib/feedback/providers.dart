import 'package:fl_clash/auth/providers.dart';
import 'package:fl_clash/feedback/data/diagnostic_upload_client.dart';
import 'package:fl_clash/feedback/data/feedback_api.dart';
import 'package:fl_clash/feedback/services/feedback_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final feedbackApiProvider = Provider<FeedbackApi>((ref) {
  return FeedbackApi(ref.read(gatewayClientProvider));
});

final diagnosticUploadClientProvider = Provider<DiagnosticUploadClient>((ref) {
  return DiagnosticUploadClient();
});

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return FeedbackService(
    api: ref.read(feedbackApiProvider),
    uploadClient: ref.read(diagnosticUploadClientProvider),
    authController: ref.read(authControllerProvider),
  );
});
