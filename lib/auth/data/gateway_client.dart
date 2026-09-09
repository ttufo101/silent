import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:fl_clash/state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GatewayException implements Exception {
  const GatewayException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => message;
}

class GatewayClient {
  GatewayClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'http://47.120.10.73:12001',
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 15),
              contentType: Headers.jsonContentType,
              validateStatus: (status) =>
                  status != null && status >= 200 && status < 600,
            ),
          );

  static const _path = '/startlandapi';
  final Dio _dio;
  String? accessToken;
  Map<String, String>? _commonFields;

  Future<Map<String, dynamic>> call({
    required String module,
    required String method,
    required Map<String, dynamic> params,
    Duration? requestTimeout,
  }) async {
    final cancelToken = CancelToken();
    Timer? timeoutTimer;
    var requestTimedOut = false;
    if (requestTimeout != null) {
      timeoutTimer = Timer(requestTimeout, () {
        requestTimedOut = true;
        cancelToken.cancel();
      });
    }
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _path,
        cancelToken: cancelToken,
        data: {
          'com': {...await _getCommonFields(), 'jwt_token': accessToken ?? ''},
          'req': {'module': module, 'method': method, 'params': params},
        },
      );
      final body = response.data;
      if (body == null) {
        throw const GatewayException('Invalid gateway response');
      }
      final code = body['code'];
      final message = body['msg'];
      if (code is! int || message is! String || !body.containsKey('data')) {
        throw const GatewayException('Invalid gateway response envelope');
      }
      if (code != 0) {
        throw GatewayException(message, code: code);
      }
      final data = body['data'];
      if (data is! Map) {
        throw const GatewayException('Invalid gateway response data');
      }
      return Map<String, dynamic>.from(data);
    } on GatewayException {
      rethrow;
    } on DioException catch (error) {
      if (requestTimedOut) {
        throw const GatewayException('Request timed out');
      }
      throw GatewayException(_networkMessage(error));
    } on FormatException {
      throw const GatewayException('Invalid gateway response data');
    } finally {
      timeoutTimer?.cancel();
    }
  }

  Future<Map<String, String>> _getCommonFields() async {
    final existing = _commonFields;
    if (existing != null) return existing;
    final preferences = await SharedPreferences.getInstance();
    var deviceId = preferences.getString('authDeviceId');
    deviceId ??= _createDeviceId();
    await preferences.setString('authDeviceId', deviceId);
    final deviceInfo = DeviceInfoPlugin();
    final osVersion = switch (Platform.operatingSystem) {
      'android' => (await deviceInfo.androidInfo).version.release,
      'ios' => (await deviceInfo.iosInfo).systemVersion,
      _ => Platform.operatingSystemVersion,
    };
    return _commonFields = {
      'dev_id': deviceId,
      'dev_type': Platform.operatingSystem,
      'app_ver': globalState.packageInfo.version,
      'os_ver': osVersion,
    };
  }

  String _createDeviceId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  String _networkMessage(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout => 'Connection timed out',
      DioExceptionType.sendTimeout => 'Request timed out',
      DioExceptionType.receiveTimeout => 'Response timed out',
      DioExceptionType.connectionError => 'Network connection failed',
      _ => 'Network request failed',
    };
  }
}
