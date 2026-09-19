import 'package:collection/collection.dart';

enum UpdatePackageType { apk, exe, dmg, pkg, store }

class UpdateInfo {
  const UpdateInfo({
    required this.updateAvailable,
    required this.forceUpdate,
    required this.latestVersion,
    required this.minimumVersion,
    required this.updateUrl,
    required this.updateTitle,
    required this.updateDescription,
    required this.packageSizeBytes,
    required this.packageSha256,
    required this.packageType,
    required this.releaseId,
  });

  final bool updateAvailable;
  final bool forceUpdate;
  final String latestVersion;
  final String minimumVersion;
  final Uri? updateUrl;
  final String updateTitle;
  final String updateDescription;
  final int packageSizeBytes;
  final String packageSha256;
  final UpdatePackageType? packageType;
  final String releaseId;

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    final updateAvailable = _readBool(json, 'update_available');
    final forceUpdate = _readBool(json, 'force_update');
    final latestVersion = _readString(json, 'latest_version');
    final minimumVersion = _readString(json, 'minimum_version');
    final updateUrlValue = _readString(json, 'update_url');
    final updateTitle = _readString(json, 'update_title');
    final updateDescription = _readString(json, 'update_description');
    final packageSizeBytes = _readInt(json, 'package_size_bytes');
    final packageSha256 = _readString(json, 'package_sha256');
    final packageTypeValue = _readString(json, 'package_type');
    final releaseId = _readString(json, 'release_id');
    final updateUrl = updateUrlValue.isEmpty
        ? null
        : Uri.tryParse(updateUrlValue);
    final packageType = UpdatePackageType.values
        .where((value) => value.name == packageTypeValue.toLowerCase())
        .firstOrNull;

    if (!_isVersion(latestVersion) || !_isVersion(minimumVersion)) {
      throw const FormatException('Invalid update version');
    }
    if (forceUpdate && !updateAvailable) {
      throw const FormatException('Invalid forced update state');
    }
    if (updateAvailable) {
      final validScheme =
          updateUrl?.scheme == 'http' || updateUrl?.scheme == 'https';
      if (!validScheme ||
          updateUrl!.host.isEmpty ||
          packageSizeBytes <= 0 ||
          packageSizeBytes > 536870912 ||
          !RegExp(r'^[0-9a-f]{64}$').hasMatch(packageSha256) ||
          packageType == null ||
          releaseId.isEmpty ||
          releaseId.length > 128) {
        throw const FormatException('Invalid update package');
      }
    }
    return UpdateInfo(
      updateAvailable: updateAvailable,
      forceUpdate: forceUpdate,
      latestVersion: latestVersion,
      minimumVersion: minimumVersion,
      updateUrl: updateUrl,
      updateTitle: updateTitle,
      updateDescription: updateDescription,
      packageSizeBytes: packageSizeBytes,
      packageSha256: packageSha256,
      packageType: packageType,
      releaseId: releaseId,
    );
  }

  Map<String, dynamic> toJson() => {
    'update_available': updateAvailable,
    'force_update': forceUpdate,
    'latest_version': latestVersion,
    'minimum_version': minimumVersion,
    'update_url': updateUrl?.toString() ?? '',
    'update_title': updateTitle,
    'update_description': updateDescription,
    'package_size_bytes': packageSizeBytes,
    'package_sha256': packageSha256,
    'package_type': packageType?.name ?? '',
    'release_id': releaseId,
  };

  UpdateInfo asForcedUpdate() => UpdateInfo(
    updateAvailable: updateAvailable,
    forceUpdate: true,
    latestVersion: latestVersion,
    minimumVersion: minimumVersion,
    updateUrl: updateUrl,
    updateTitle: updateTitle,
    updateDescription: updateDescription,
    packageSizeBytes: packageSizeBytes,
    packageSha256: packageSha256,
    packageType: packageType,
    releaseId: releaseId,
  );

  static bool _readBool(Map<String, dynamic> json, String key) {
    final value = _readValue(json, key);
    if (value is bool) return value;
    throw FormatException('Invalid $key');
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = _readValue(json, key);
    if (value == null) return '';
    if (value is String) return value.trim();
    throw FormatException('Invalid $key');
  }

  static int _readInt(Map<String, dynamic> json, String key) {
    final value = _readValue(json, key);
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num && value == value.roundToDouble()) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    throw FormatException('Invalid $key');
  }

  static Object? _readValue(Map<String, dynamic> json, String key) {
    if (json.containsKey(key)) return json[key];
    final parts = key.split('_');
    final camelKey =
        parts.first +
        parts.skip(1).map((part) {
          if (part.isEmpty) return '';
          return '${part[0].toUpperCase()}${part.substring(1)}';
        }).join();
    return json[camelKey];
  }

  static bool _isVersion(String value) {
    return RegExp(r'^\d+\.\d+\.\d+$').hasMatch(value);
  }
}
