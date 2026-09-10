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

String? resolveProxyCountryCode(Proxy proxy, Map<String, Proxy> proxiesByName) {
  Proxy? current = proxy;
  final visited = <String>{};
  while (current != null && visited.add(current.name)) {
    final directCode = ProxyDisplayName.parse(current.name).countryCode;
    if (directCode != null) return directCode;
    final selectedName = current.now;
    if (selectedName == null || selectedName.isEmpty) return null;
    final selectedCode = ProxyDisplayName.parse(selectedName).countryCode;
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
