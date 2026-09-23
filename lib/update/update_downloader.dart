import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fl_clash/auth/data/gateway_client.dart';
import 'package:fl_clash/common/path.dart';
import 'package:path/path.dart' as path;

import 'update_info.dart';

class UpdateDownloader {
  UpdateDownloader({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(minutes: 10),
        sendTimeout: const Duration(seconds: 15),
      ),
    );
    // 更新服务器使用自签名证书：仅对内置更新服务器放行，
    // 且要求证书 SHA-256 指纹与固定值完全一致（pinning）。
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) {
          return GatewayClient.isUpdateServerHost(host) &&
              sha256.convert(cert.der).toString() ==
                  GatewayClient.updateServerCertSha256;
        };
        return client;
      },
    );
    return dio;
  }

  Future<String> download(
    UpdateInfo info, {
    required CancelToken cancelToken,
    required void Function(int received, int total) onProgress,
    required void Function() onVerifying,
  }) async {
    final updateUrl = info.updateUrl!;
    if (!GatewayClient.isTrustedUpdateUri(updateUrl)) {
      throw const FormatException('Untrusted update host');
    }
    final cacheDirectory = await appPath.cacheDir.future;
    final updatesDirectory = Directory(
      path.join(cacheDirectory.path, 'updates'),
    );
    await updatesDirectory.create(recursive: true);
    final releaseDirectoryName = sha256
        .convert(utf8.encode(info.releaseId))
        .toString();
    await _removeOtherReleases(updatesDirectory, releaseDirectoryName);
    final releaseDirectory = Directory(
      path.join(updatesDirectory.path, releaseDirectoryName),
    );
    await releaseDirectory.create(recursive: true);
    final extension = info.packageType == UpdatePackageType.apk ? 'apk' : 'exe';
    final packageFile = File(
      path.join(releaseDirectory.path, 'package.$extension'),
    );
    if (await packageFile.exists() &&
        await packageFile.length() == info.packageSizeBytes) {
      onVerifying();
    }
    if (await _matches(info, packageFile)) {
      onProgress(info.packageSizeBytes, info.packageSizeBytes);
      return packageFile.path;
    }
    final partialFile = File('${packageFile.path}.part');
    await partialFile.delete().catchError((_) => partialFile);
    final response = await _dio.get<ResponseBody>(
      updateUrl.toString(),
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        followRedirects: false,
        validateStatus: (status) => status == HttpStatus.ok,
      ),
    );
    final body = response.data;
    if (body == null) throw const FormatException('Empty update package');
    final contentLength = body.contentLength;
    if (contentLength != -1 && contentLength != info.packageSizeBytes) {
      throw const FormatException('Unexpected update package size');
    }
    final sink = partialFile.openWrite();
    var received = 0;
    try {
      try {
        await for (final chunk in body.stream) {
          received += chunk.length;
          if (received > info.packageSizeBytes) {
            throw const FormatException('Update package is too large');
          }
          sink.add(chunk);
          onProgress(received, info.packageSizeBytes);
        }
      } finally {
        await sink.close();
      }
    } catch (_) {
      await partialFile.delete().catchError((_) => partialFile);
      rethrow;
    }
    if (received != info.packageSizeBytes) {
      await partialFile.delete().catchError((_) => partialFile);
      throw const FormatException('Incomplete update package');
    }
    onVerifying();
    if (!await _matches(info, partialFile)) {
      await partialFile.delete().catchError((_) => partialFile);
      throw const FormatException('Update package checksum mismatch');
    }
    if (await packageFile.exists()) await packageFile.delete();
    await partialFile.rename(packageFile.path);
    return packageFile.path;
  }

  Future<bool> _matches(UpdateInfo info, File file) async {
    if (!await file.exists() || await file.length() != info.packageSizeBytes) {
      return false;
    }
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString() == info.packageSha256;
  }

  Future<void> _removeOtherReleases(
    Directory updatesDirectory,
    String currentRelease,
  ) async {
    await for (final entity in updatesDirectory.list()) {
      if (entity is Directory && path.basename(entity.path) != currentRelease) {
        await entity.delete(recursive: true);
      }
    }
  }
}
