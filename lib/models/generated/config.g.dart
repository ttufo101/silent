// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettingProps _$AppSettingPropsFromJson(Map<String, dynamic> json) =>
    _AppSettingProps(
      locale: json['locale'] as String?,
      themeMode:
          $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
          ThemeMode.light,
      onlyStatisticsProxy: json['onlyStatisticsProxy'] as bool? ?? false,
      autoLaunch: json['autoLaunch'] as bool? ?? false,
      silentLaunch: json['silentLaunch'] as bool? ?? false,
      autoRun: json['autoRun'] as bool? ?? false,
      openLogs: json['openLogs'] as bool? ?? false,
      closeConnections: json['closeConnections'] as bool? ?? true,
      testUrl: json['testUrl'] as String? ?? defaultTestUrl,
      isAnimateToPage: json['isAnimateToPage'] as bool? ?? true,
      autoCheckUpdate: json['autoCheckUpdate'] as bool? ?? true,
      showLabel: json['showLabel'] as bool? ?? false,
      minimizeOnExit: json['minimizeOnExit'] as bool? ?? true,
      hidden: json['hidden'] as bool? ?? false,
      developerMode: json['developerMode'] as bool? ?? false,
      restoreStrategy:
          $enumDecodeNullable(
            _$RestoreStrategyEnumMap,
            json['restoreStrategy'],
          ) ??
          RestoreStrategy.compatible,
      showTrayTitle: json['showTrayTitle'] as bool? ?? true,
      customUserAgent: json['customUserAgent'] as String? ?? '',
    );

Map<String, dynamic> _$AppSettingPropsToJson(_AppSettingProps instance) =>
    <String, dynamic>{
      'locale': instance.locale,
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'onlyStatisticsProxy': instance.onlyStatisticsProxy,
      'autoLaunch': instance.autoLaunch,
      'silentLaunch': instance.silentLaunch,
      'autoRun': instance.autoRun,
      'openLogs': instance.openLogs,
      'closeConnections': instance.closeConnections,
      'testUrl': instance.testUrl,
      'isAnimateToPage': instance.isAnimateToPage,
      'autoCheckUpdate': instance.autoCheckUpdate,
      'showLabel': instance.showLabel,
      'minimizeOnExit': instance.minimizeOnExit,
      'hidden': instance.hidden,
      'developerMode': instance.developerMode,
      'restoreStrategy': _$RestoreStrategyEnumMap[instance.restoreStrategy]!,
      'showTrayTitle': instance.showTrayTitle,
      'customUserAgent': instance.customUserAgent,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$RestoreStrategyEnumMap = {
  RestoreStrategy.compatible: 'compatible',
  RestoreStrategy.override: 'override',
};

_AccessControlProps _$AccessControlPropsFromJson(Map<String, dynamic> json) =>
    _AccessControlProps(
      enable: json['enable'] as bool? ?? false,
      mode:
          $enumDecodeNullable(_$AccessControlModeEnumMap, json['mode']) ??
          AccessControlMode.rejectSelected,
      acceptList:
          (json['acceptList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      rejectList:
          (json['rejectList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sort:
          $enumDecodeNullable(_$AccessSortTypeEnumMap, json['sort']) ??
          AccessSortType.none,
      isFilterSystemApp: json['isFilterSystemApp'] as bool? ?? true,
      isFilterNonInternetApp: json['isFilterNonInternetApp'] as bool? ?? true,
    );

Map<String, dynamic> _$AccessControlPropsToJson(_AccessControlProps instance) =>
    <String, dynamic>{
      'enable': instance.enable,
      'mode': _$AccessControlModeEnumMap[instance.mode]!,
      'acceptList': instance.acceptList,
      'rejectList': instance.rejectList,
      'sort': _$AccessSortTypeEnumMap[instance.sort]!,
      'isFilterSystemApp': instance.isFilterSystemApp,
      'isFilterNonInternetApp': instance.isFilterNonInternetApp,
    };

const _$AccessControlModeEnumMap = {
  AccessControlMode.acceptSelected: 'acceptSelected',
  AccessControlMode.rejectSelected: 'rejectSelected',
};

const _$AccessSortTypeEnumMap = {
  AccessSortType.none: 'none',
  AccessSortType.name: 'name',
  AccessSortType.time: 'time',
};

_WindowProps _$WindowPropsFromJson(Map<String, dynamic> json) => _WindowProps(
  width: (json['width'] as num?)?.toDouble() ?? 0,
  height: (json['height'] as num?)?.toDouble() ?? 0,
  top: (json['top'] as num?)?.toDouble(),
  left: (json['left'] as num?)?.toDouble(),
);

Map<String, dynamic> _$WindowPropsToJson(_WindowProps instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'top': instance.top,
      'left': instance.left,
    };

_VpnProps _$VpnPropsFromJson(Map<String, dynamic> json) => _VpnProps(
  enable: json['enable'] as bool? ?? true,
  systemProxy: json['systemProxy'] as bool? ?? true,
  ipv6: json['ipv6'] as bool? ?? false,
  allowBypass: json['allowBypass'] as bool? ?? true,
  dnsHijacking: json['dnsHijacking'] as bool? ?? false,
  accessControlProps: json['accessControlProps'] == null
      ? defaultAccessControlProps
      : AccessControlProps.fromJson(
          json['accessControlProps'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$VpnPropsToJson(_VpnProps instance) => <String, dynamic>{
  'enable': instance.enable,
  'systemProxy': instance.systemProxy,
  'ipv6': instance.ipv6,
  'allowBypass': instance.allowBypass,
  'dnsHijacking': instance.dnsHijacking,
  'accessControlProps': instance.accessControlProps,
};

_NetworkProps _$NetworkPropsFromJson(Map<String, dynamic> json) =>
    _NetworkProps(
      systemProxy: json['systemProxy'] as bool? ?? true,
      bypassDomain:
          (json['bypassDomain'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          defaultBypassDomain,
      routeMode:
          $enumDecodeNullable(_$RouteModeEnumMap, json['routeMode']) ??
          RouteMode.config,
      autoSetSystemDns: json['autoSetSystemDns'] as bool? ?? true,
      appendSystemDns: json['appendSystemDns'] as bool? ?? false,
    );

Map<String, dynamic> _$NetworkPropsToJson(_NetworkProps instance) =>
    <String, dynamic>{
      'systemProxy': instance.systemProxy,
      'bypassDomain': instance.bypassDomain,
      'routeMode': _$RouteModeEnumMap[instance.routeMode]!,
      'autoSetSystemDns': instance.autoSetSystemDns,
      'appendSystemDns': instance.appendSystemDns,
    };

const _$RouteModeEnumMap = {
  RouteMode.bypassPrivate: 'bypassPrivate',
  RouteMode.config: 'config',
};

_Config _$ConfigFromJson(Map<String, dynamic> json) => _Config(
  currentProfileId: (json['currentProfileId'] as num?)?.toInt(),
  overrideDns: json['overrideDns'] as bool? ?? false,
  hotKeyActions:
      (json['hotKeyActions'] as List<dynamic>?)
          ?.map((e) => HotKeyAction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  appSettingProps: json['appSettingProps'] == null
      ? defaultAppSettingProps
      : AppSettingProps.safeFromJson(
          json['appSettingProps'] as Map<String, Object?>?,
        ),
  davProps: json['davProps'] == null
      ? null
      : DAVProps.fromJson(json['davProps'] as Map<String, dynamic>),
  networkProps: json['networkProps'] == null
      ? defaultNetworkProps
      : NetworkProps.fromJson(json['networkProps'] as Map<String, dynamic>?),
  vpnProps: json['vpnProps'] == null
      ? defaultVpnProps
      : VpnProps.fromJson(json['vpnProps'] as Map<String, dynamic>?),
  windowProps: json['windowProps'] == null
      ? defaultWindowProps
      : WindowProps.fromJson(json['windowProps'] as Map<String, dynamic>?),
  patchClashConfig: json['patchClashConfig'] == null
      ? defaultClashConfig
      : PatchClashConfig.fromJson(
          json['patchClashConfig'] as Map<String, dynamic>,
        ),
  excludeSSIDs:
      (json['excludeSSIDs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$ConfigToJson(_Config instance) => <String, dynamic>{
  'currentProfileId': instance.currentProfileId,
  'overrideDns': instance.overrideDns,
  'hotKeyActions': instance.hotKeyActions,
  'appSettingProps': instance.appSettingProps,
  'davProps': instance.davProps,
  'networkProps': instance.networkProps,
  'vpnProps': instance.vpnProps,
  'windowProps': instance.windowProps,
  'patchClashConfig': instance.patchClashConfig,
  'excludeSSIDs': instance.excludeSSIDs,
};
