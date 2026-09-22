import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class DiagnosticUploadException implements Exception {
  const DiagnosticUploadException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  bool get authenticationFailed => statusCode == 401;

  @override
  String toString() => message;
}

class UploadedDiagnosticFile {
  const UploadedDiagnosticFile({
    required this.fileId,
    required this.fileName,
    required this.sizeBytes,
    required this.sha256,
  });

  final String fileId;
  final String fileName;
  final int sizeBytes;
  final String sha256;

  Map<String, dynamic> toJson() => {
    'file_id': fileId,
    'file_name': fileName,
    'size_bytes': sizeBytes,
    'sha256': sha256,
  };

  factory UploadedDiagnosticFile.fromJson(Map<String, dynamic> json) {
    return UploadedDiagnosticFile(
      fileId: json['file_id'] as String,
      fileName: json['file_name'] as String,
      sizeBytes: (json['size_bytes'] as num).toInt(),
      sha256: json['sha256'] as String,
    );
  }
}

class DiagnosticUploadClient {
  DiagnosticUploadClient({Dio? dio}) : _dio = dio ?? _createDio();

  static const baseUrl = 'http://106.52.77.108';
  final Dio _dio;

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) =>
            status != null && status >= 200 && status < 600,
      ),
    );
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (_) => 'DIRECT';
        return client;
      },
    );
    return dio;
  }

  Future<UploadedDiagnosticFile> upload({
    required File file,
    required String accessToken,
    required String idempotencyKey,
    required int sizeBytes,
    required String sha256,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/log-files',
        data: FormData.fromMap({
          'file': await MultipartFile.fromFile(
            file.path,
            filename: file.uri.pathSegments.last,
          ),
        }),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        options: Options(
          followRedirects: false,
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $accessToken',
            'Idempotency-Key': idempotencyKey,
            'X-File-Size': '$sizeBytes',
            'X-File-SHA256': sha256,
          },
        ),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _responseException(response);
      }
      final data = response.data;
      if (data == null) {
        throw const DiagnosticUploadException('Invalid upload response');
      }
      final fileId = data['file_id'];
      final fileName = data['filename'];
      final size = data['size'];
      final digest = data['sha256'];
      if (fileId is! String ||
          fileId.isEmpty ||
          fileName is! String ||
          size is! num ||
          digest is! String) {
        throw const DiagnosticUploadException('Invalid upload response');
      }
      if (size.toInt() != sizeBytes || digest.toLowerCase() != sha256) {
        throw const DiagnosticUploadException(
          'Uploaded file verification failed',
          code: 'UPLOAD_VERIFICATION_FAILED',
        );
      }
      return UploadedDiagnosticFile(
        fileId: fileId,
        fileName: fileName,
        sizeBytes: size.toInt(),
        sha256: digest.toLowerCase(),
      );
    } on DiagnosticUploadException {
      rethrow;
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw DiagnosticUploadException(_networkMessage(error));
    }
  }

  DiagnosticUploadException _responseException(
    Response<Map<String, dynamic>> response,
  ) {
    final data = response.data;
    final code = data?['code'];
    final message = data?['message'];
    return DiagnosticUploadException(
      message is String ? message : 'Upload failed',
      code: code is String ? code : null,
      statusCode: response.statusCode,
    );
  }

  String _networkMessage(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout => 'Connection timed out',
      DioExceptionType.sendTimeout => 'Upload timed out',
      DioExceptionType.receiveTimeout => 'Response timed out',
      DioExceptionType.connectionError => 'Network connection failed',
      _ => 'Upload failed',
    };
  }
}
