import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

List<Group> getCurrentGroups() {
  return globalState.container.read(currentGroupsStateProvider).value;
}

List<Group> getGroups() {
  return globalState.container.read(groupsProvider);
}

void changeProxySelection({
  required String groupName,
  required GroupType groupType,
  required Proxy proxy,
}) {
  final ref = globalState.container;
  final isComputedSelected = groupType.isComputedSelected;
  final isSelector = groupType == GroupType.Selector;
  if (!isComputedSelected && !isSelector) {
    globalState.showNotifier(currentAppLocalizations.notSelectedTip);
    return;
  }
  final currentProxyName = ref.read(proxyNameProvider(groupName));
  final nextProxyName = isComputedSelected && currentProxyName == proxy.name
      ? ''
      : proxy.name;
  ref
      .read(profilesActionProvider.notifier)
      .updateCurrentSelectedMap(groupName, nextProxyName);
  ref
      .read(proxiesActionProvider.notifier)
      .changeProxyDebounce(groupName, nextProxyName);
}

Future<void> proxyDelayTest(Proxy proxy, [String? testUrl]) async {
  final ref = globalState.container;
  final groups = getGroups();
  final selectedMap = ref.read(
    currentProfileProvider.select((state) => state?.selectedMap ?? {}),
  );
  final state = computeRealSelectedProxyState(
    proxy.name,
    groups: groups,
    selectedMap: selectedMap,
  );
  final currentTestUrl = state.testUrl.takeFirstValid([
    ref.read(realTestUrlProvider(testUrl)),
  ]);
  if (state.proxyName.isEmpty) {
    return;
  }
  ref
      .read(proxiesActionProvider.notifier)
      .setDelay(Delay(url: currentTestUrl, name: state.proxyName, value: 0));
  try {
    final delay = await coreController.getDelay(
      currentTestUrl,
      state.proxyName,
    );
    ref.read(proxiesActionProvider.notifier).setDelay(delay);
  } catch (error) {
    commonPrint.log(
      'Delay test failed for ${state.proxyName}: $error',
      logLevel: coreFailureLogLevel(error),
    );
    ref
        .read(proxiesActionProvider.notifier)
        .setDelay(Delay(url: currentTestUrl, name: state.proxyName, value: -1));
  }
}

Future<void> delayTest(List<Proxy> proxies, [String? testUrl]) async {
  final batches = proxies.batch(maxConcurrentDelayTests);
  for (final batch in batches) {
    await Future.wait(
      batch.map((proxy) async {
        await proxyDelayTest(proxy, testUrl);
      }),
    );
  }
}

class ProxyDisplayName {
  final String name;
  final String? countryCode;

  const ProxyDisplayName({required this.name, this.countryCode});

  factory ProxyDisplayName.parse(String value) {
    if (value.length >= 4 &&
        value[2] == ':' &&
        _isAsciiLetter(value.codeUnitAt(0)) &&
        _isAsciiLetter(value.codeUnitAt(1))) {
      final name = value.substring(3).trimLeft();
      return ProxyDisplayName(
        name: name.isEmpty ? value : name,
        countryCode: value.substring(0, 2).toLowerCase(),
      );
    }
    return ProxyDisplayName(name: value);
  }

  static bool _isAsciiLetter(int codeUnit) {
    return (codeUnit >= 65 && codeUnit <= 90) ||
        (codeUnit >= 97 && codeUnit <= 122);
  }
}

/// 常见国家/地区关键词（中英文 + 常用机场命名），按序匹配，
/// 注意顺序敏感：'id'（印度尼西亚）须在 'in'（印度）之前，避免"印度尼西亚"误判
const _countryKeywords = <String, List<String>>{
  'hk': ['香港', 'hongkong', 'hong kong'],
  'tw': ['台湾', '臺灣', '台北', '臺北', '新北', 'taiwan', 'taipei'],
  'jp': ['日本', '东京', '東京', '大阪', '埼玉', 'japan', 'tokyo', 'osaka'],
  'kr': ['韩国', '韓國', '首尔', '首爾', 'korea', 'seoul'],
  'sg': ['新加坡', '狮城', '獅城', 'singapore'],
  'us': [
    '美国', '美國', '洛杉矶', '洛杉磯', '圣何塞', '聖何塞', '西雅图', '西雅圖',
    '凤凰城', '鳳凰城', '芝加哥', '纽约', '紐約', '达拉斯', '達拉斯',
    'united states', 'los angeles', 'san jose', 'seattle', 'chicago',
    'new york', 'dallas', 'phoenix', 'usa', 'america',
  ],
  'gb': ['英国', '英國', '伦敦', '倫敦', 'united kingdom', 'london'],
  'de': ['德国', '德國', '法兰克福', '法蘭克福', 'germany', 'frankfurt'],
  'fr': ['法国', '法國', '巴黎', 'france', 'paris'],
  'nl': ['荷兰', '荷蘭', '阿姆斯特丹', 'netherlands', 'amsterdam'],
  'ru': ['俄罗斯', '俄羅斯', '莫斯科', 'russia', 'moscow'],
  'au': ['澳大利亚', '澳洲', '悉尼', 'australia', 'sydney'],
  'ca': ['加拿大', 'canada'],
  'my': ['马来西亚', '馬來西亞', 'malaysia'],
  'th': ['泰国', '泰國', 'thailand'],
  'vn': ['越南', 'vietnam'],
  'ph': ['菲律宾', '菲律賓', 'philippines'],
  'id': ['印尼', '印度尼西亚', 'indonesia'],
  'in': ['印度', 'india'],
  'tr': ['土耳其', 'turkey'],
  'br': ['巴西', 'brazil'],
  'ar': ['阿根廷', 'argentina'],
  'ch': ['瑞士', 'switzerland'],
  'it': ['意大利', '義大利', 'italy'],
  'es': ['西班牙', 'spain'],
  'se': ['瑞典', 'sweden'],
  'no': ['挪威', 'norway'],
  'fi': ['芬兰', '芬蘭', 'finland'],
  'dk': ['丹麦', '丹麥', 'denmark'],
  'ie': ['爱尔兰', '愛爾蘭', 'ireland'],
  'za': ['南非', 'south africa'],
};

final _countryAbbrRegExp = RegExp(
  r'\b(hk|tw|jp|kr|sg|us|uk|gb|de|fr|nl|ru|au|ca|my|th|vn|ph|id|in|tr|br|ar'
  r'|ch|it|es|se|no|fi|dk|ie|za)\b',
  caseSensitive: false,
);

/// 从节点名称推断国家码（小写两位）。依次尝试：
/// 1. 国旗 emoji（区域指示符对，很多订阅节点名自带）
/// 2. 中英文国家关键词（香港/日本/US/Singapore 等）
/// 3. 独立的两位国家码缩写（词边界匹配，避免误伤普通单词）
/// 注意：'uk' 归一化为 'gb'（国旗 emoji 用 GB）
String? countryCodeFromName(String name) {
  final flagCode = _countryCodeFromFlagEmoji(name);
  if (flagCode != null) return flagCode;
  final lower = name.toLowerCase();
  for (final entry in _countryKeywords.entries) {
    for (final keyword in entry.value) {
      if (lower.contains(keyword)) return entry.key;
    }
  }
  final abbrMatch = _countryAbbrRegExp.firstMatch(name);
  if (abbrMatch != null) {
    final abbr = abbrMatch.group(0)!.toLowerCase();
    return abbr == 'uk' ? 'gb' : abbr;
  }
  return null;
}

/// 从名称中的国旗 emoji 提取两位国家码
String? _countryCodeFromFlagEmoji(String name) {
  final units = name.runes.toList();
  for (var i = 0; i + 1 < units.length; i++) {
    final a = units[i];
    final b = units[i + 1];
    final isIndicatorA = a >= 0x1F1E6 && a <= 0x1F1FF;
    final isIndicatorB = b >= 0x1F1E6 && b <= 0x1F1FF;
    if (isIndicatorA && isIndicatorB) {
      return (String.fromCharCode(65 + a - 0x1F1E6) +
              String.fromCharCode(65 + b - 0x1F1E6))
          .toLowerCase();
    }
  }
  return null;
}

/// 归一化外部来源的国家字段（出口 IP 查询可能是两位码或英文全名）
String? normalizeCountryCode(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return null;
  if (v.length == 2 && RegExp(r'^[A-Za-z]{2}$').hasMatch(v)) {
    return v.toLowerCase();
  }
  return countryCodeFromName(v);
}

String? resolveProxyCountryCode(Proxy proxy, Map<String, Proxy> proxiesByName) {
  Proxy? current = proxy;
  final visited = <String>{};
  while (current != null && visited.add(current.name)) {
    final directCode = ProxyDisplayName.parse(current.name).countryCode ??
        countryCodeFromName(current.name);
    if (directCode != null) return directCode;
    final selectedName = current.now;
    if (selectedName == null || selectedName.isEmpty) return null;
    final selectedCode = ProxyDisplayName.parse(selectedName).countryCode ??
        countryCodeFromName(selectedName);
    if (selectedCode != null) return selectedCode;
    current = proxiesByName[selectedName];
  }
  return null;
}

class ProxyFlag extends StatelessWidget {
  const ProxyFlag({
    required this.countryCode,
    required this.size,
    this.fallbackIcon = Icons.public,
    this.emphasized = false,
    super.key,
  });

  static const _assets = {
    'sg': 'assets/flags/sg.svg',
    'us': 'assets/flags/us.svg',
  };

  final String? countryCode;
  final double size;
  final IconData fallbackIcon;
  final bool emphasized;

  /// 由两位国家码生成国旗 emoji（区域指示符对），非法码返回 null
  static String? _flagEmoji(String? countryCode) {
    if (countryCode == null || countryCode.length != 2) return null;
    final units = countryCode.toUpperCase().codeUnits;
    if (units[0] < 65 || units[0] > 90 || units[1] < 65 || units[1] > 90) {
      return null;
    }
    return String.fromCharCode(0x1F1E6 + units[0] - 65) +
        String.fromCharCode(0x1F1E6 + units[1] - 65);
  }

  @override
  Widget build(BuildContext context) {
    final asset = _assets[countryCode];
    if (asset != null) {
      return SvgPicture.asset(
        asset,
        width: size,
        height: size,
        excludeFromSemantics: true,
      );
    }
    final emoji = _flagEmoji(countryCode);
    if (emoji != null) {
      // 用内置 Twemoji 渲染国旗，Windows 等无系统国旗 emoji 的平台也可用
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(
              fontFamily: FontFamily.twEmoji.value,
              fontSize: size * 0.72,
              height: 1,
            ),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: emphasized
          ? context.colorScheme.primary
          : context.colorScheme.primaryContainer,
      child: Icon(
        fallbackIcon,
        size: size * 0.56,
        color: emphasized
            ? context.colorScheme.onPrimary
            : context.colorScheme.primary,
      ),
    );
  }
}
