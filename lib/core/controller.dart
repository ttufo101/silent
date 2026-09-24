import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:path/path.dart';

class CoreController {
  static CoreController? _instance;
  late CoreHandlerInterface _interface;

  CoreController._internal() {
    if (system.isAndroid) {
      _interface = coreLib!;
    } else {
      _interface = coreService!;
    }
  }

  @visibleForTesting
  CoreController.test(this._interface);

  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }

  factory CoreController() {
    _instance ??= CoreController._internal();
    return _instance!;
  }

  Future<CoreLifecycleResult> start() => _interface.start();

  Future<CoreLifecycleResult> restart() => _interface.restart();

  Future<CoreLifecycleResult> stop() => _interface.stop();

  Future<CoreLifecycleResult> close() => _interface.close();

  static Future<void>? _initGeoFuture;

  /// 由应用层注册的「核心预热」任务（登录页阶段就开始初始化核心）。
  /// 核心方法调用（如校验配置）会先等它完成，避免核心未就绪时白等超时。
  static Future<void>? warmUpFuture;

  static Future<void> initGeo() {
    return _initGeoFuture ??= _initGeoInternal();
  }

  /// 等待预热完成。没有预热任务、或预热失败/超时时直接返回，
  /// 由调用方的超时逻辑兜底，保证不会比预热前更差。
  static Future<void> waitForWarmUp() async {
    final pending = warmUpFuture;
    if (pending == null) {
      return;
    }
    try {
      await pending.timeout(const Duration(seconds: 30));
    } on Object catch (_) {
      return;
    }
  }

  static Future<void> _initGeoInternal() async {
    startupTiming.mark('geo copy start');
    final homePath = await appPath.homeDirPath;
    final homeDir = Directory(homePath);
    final isExists = await homeDir.exists();
    if (!isExists) {
      await homeDir.create(recursive: true);
    }
    const geoFileNameList = [MMDB, GEOSITE, ASN];
    var copiedCount = 0;
    var copiedBytes = 0;
    try {
      for (final geoFileName in geoFileNameList) {
        final geoFile = File(join(homePath, geoFileName));
        final isExists = await geoFile.exists();
        if (isExists) {
          continue;
        }
        final data = await rootBundle.load('assets/data/$geoFileName');
        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        final temporaryFile = File('${geoFile.path}.tmp');
        if (await temporaryFile.exists()) {
          await temporaryFile.delete();
        }
        await temporaryFile.writeAsBytes(bytes);
        await temporaryFile.rename(geoFile.path);
        copiedCount++;
        copiedBytes += bytes.lengthInBytes;
      }
      startupTiming.mark(
        'geo copy finished files=$copiedCount bytes=$copiedBytes',
      );
    } catch (e) {
      _initGeoFuture = null;
      commonPrint.log(
        'Failed to initialize geo data: $e',
        logLevel: LogLevel.error,
      );
      rethrow;
    }
  }

  Future<bool> init(int version) async {
    await initGeo();
    final homeDirPath = await appPath.homeDirPath;
    return _interface.init(InitParams(homeDir: homeDirPath, version: version));
  }

  FutureOr<bool> get isInit => _interface.isInit;

  Future<String> validateConfig(String path) async {
    await waitForWarmUp();
    final res = await _interface.validateConfig(path);
    return res;
  }

  Future<String> validateConfigWithData(String data) async {
    final path = await appPath.tempFilePath;
    final file = File(path);
    await file.safeWriteAsString(data);
    await waitForWarmUp();
    final res = await _interface.validateConfig(path);
    await File(path).safeDelete();
    return res;
  }

  Future<String> updateConfig(UpdateParams updateParams) async {
    return _interface.updateConfig(updateParams);
  }

  Future<String> setupConfig({
    required SetupParams params,
    Future<void> Function()? preloadInvoke,
  }) async {
    if (preloadInvoke == null) {
      return _interface.setupConfig(params);
    }
    final (result, _) = await (
      _interface.setupConfig(params),
      preloadInvoke(),
    ).wait;
    return result;
  }

  Future<List<Group>> getProxiesGroups({
    required ProxiesSortType sortType,
    required DelayMap delayMap,
    required Map<String, String> selectedMap,
    required String defaultTestUrl,
  }) async {
    final proxiesData = await _interface.getProxies();
    return toGroupsTask(
      ComputeGroupsState(
        proxiesData: proxiesData,
        sortType: sortType,
        delayMap: delayMap,
        selectedMap: selectedMap,
        defaultTestUrl: defaultTestUrl,
      ),
    );
  }

  FutureOr<String> changeProxy(ChangeProxyParams changeProxyParams) async {
    return await _interface.changeProxy(changeProxyParams);
  }

  Future<List<TrackerInfo>> getConnections() async {
    return _interface.getConnections();
  }

  Future<void> closeConnection(String id) async {
    await _interface.closeConnection(id);
  }

  Future<void> closeConnections() async {
    await _interface.closeConnections();
  }

  Future<void> resetConnections() async {
    await _interface.resetConnections();
  }

  Future<List<ExternalProvider>> getExternalProviders() async {
    return _interface.getExternalProviders();
  }

  Future<ExternalProvider?> getExternalProvider(
    String externalProviderName,
  ) async {
    return _interface.getExternalProvider(externalProviderName);
  }

  Future<String> updateGeoData(String type) {
    return _interface.updateGeoData(type);
  }

  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  }) {
    return _interface.sideLoadExternalProvider(
      providerName: providerName,
      data: data,
    );
  }

  Future<String> updateExternalProvider({required String providerName}) async {
    return _interface.updateExternalProvider(providerName);
  }

  Future<bool> startListener() async {
    return _interface.startListener();
  }

  Future<bool> stopListener() async {
    return _interface.stopListener();
  }

  Future<Delay> getDelay(String url, String proxyName) async {
    return _interface.asyncTestDelay(url, proxyName);
  }

  Future<Map<String, dynamic>> getConfig(int id) async {
    final profilePath = await appPath.getProfilePath(id.toString());
    final data = Map<String, dynamic>.from(
      await _interface.getConfig(profilePath),
    );
    data['rules'] = data['rule'];
    data.remove('rule');
    return data;
  }

  Future<Traffic> getTraffic(bool onlyStatisticsProxy) async {
    return _interface.getTraffic(onlyStatisticsProxy);
  }

  Future<IpInfo?> getCountryCode(String ip) async {
    final countryCode = await _interface.getCountryCode(ip);
    if (countryCode.isEmpty) {
      return null;
    }
    return IpInfo(ip: ip, countryCode: countryCode);
  }

  Future<Traffic> getTotalTraffic(bool onlyStatisticsProxy) async {
    return _interface.getTotalTraffic(onlyStatisticsProxy);
  }

  Future<int> getMemory() async {
    return _interface.getMemory();
  }

  Future<void> resetTraffic() async {
    await _interface.resetTraffic();
  }

  void startLog() {
    _interface.startLog();
  }

  void stopLog() {
    _interface.stopLog();
  }

  Future<void> requestGc() async {
    await _interface.forceGc();
  }

  Future<void> crash() async {
    await _interface.crash();
  }

  Future<String> clearEffect(int profileId) async {
    return _interface.clearEffect(profileId);
  }
}

final coreController = CoreController();
