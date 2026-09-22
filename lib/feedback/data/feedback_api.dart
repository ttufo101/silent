import 'package:fl_clash/auth/data/gateway_client.dart';

class FeedbackSubmission {
  const FeedbackSubmission({
    required this.id,
    required this.createdAt,
  });

  final String id;
  final int createdAt;
}

class FeedbackApi {
  FeedbackApi(this._client);

  static const _module = 'starland.feedback.com';
  final GatewayClient _client;

  Future<FeedbackSubmission> submitFeedback({
    required String category,
    required String content,
    required String contact,
    required String clientRequestId,
  }) async {
    final data = await _client.call(
      module: _module,
      method: 'SubmitFeedback',
      params: {
        'category': category,
        'content': content,
        'contact': contact,
        'client_request_id': clientRequestId,
      },
      requestTimeout: const Duration(seconds: 15),
    );
    return _submission(data, 'feedback_id');
  }

  Future<FeedbackSubmission> submitDiagnosticLog({
    required String fileId,
    required String fileName,
    required int sizeBytes,
    required String sha256,
    required int logStartedAt,
    required int logEndedAt,
    required String description,
    required String clientRequestId,
  }) async {
    final data = await _client.call(
      module: _module,
      method: 'SubmitDiagnosticLog',
      params: {
        'file_id': fileId,
        'file_name': fileName,
        'size_bytes': sizeBytes,
        'sha256': sha256,
        'log_started_at': logStartedAt,
        'log_ended_at': logEndedAt,
        'description': description,
        'client_request_id': clientRequestId,
      },
      requestTimeout: const Duration(seconds: 15),
    );
    return _submission(data, 'diagnostic_id');
  }

  FeedbackSubmission _submission(Map<String, dynamic> data, String idKey) {
    final id = data[idKey];
    final createdAtValue = data['created_at'];
    final createdAt = switch (createdAtValue) {
      final num value => value.toInt(),
      final String value => int.tryParse(value),
      _ => null,
    };
    if (id is! String || id.isEmpty || createdAt == null) {
      throw GatewayException('Invalid response: $idKey');
    }
    return FeedbackSubmission(id: id, createdAt: createdAt);
  }
}
