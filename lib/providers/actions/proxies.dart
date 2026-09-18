part of '../action.dart';

@Riverpod(keepAlive: true)
class ProxiesAction extends _$ProxiesAction {
  @override
  void build() {}

  void updateGroupsDebounce([Duration? duration]) {
    debouncer.call(FunctionTag.updateGroups, updateGroups, duration: duration);
  }

  void changeSelectedNodeDebounce({
    required String groupName,
    required String proxyName,
    required String selectedNodeName,
  }) {
    debouncer.call(FunctionTag.changeProxy, (
      String groupName,
      String proxyName,
      String selectedNodeName,
    ) async {
      await changeSelectedNode(
        groupName: groupName,
        proxyName: proxyName,
        selectedNodeName: selectedNodeName,
      );
      updateGroupsDebounce();
    }, args: [groupName, proxyName, selectedNodeName]);
  }

  Future<void> updateGroups() async {
    try {
      commonPrint.log('updateGroups');
      final groups = await retry(
        task: () async {
          final delayMap = ref.read(delayDataSourceProvider);
          final testUrl = ref.read(
            appSettingProvider.select((state) => state.testUrl),
          );
          final selectedMap = ref.read(
            currentProfileProvider.select((state) => state?.selectedMap ?? {}),
          );
          return coreController.getProxiesGroups(
            selectedMap: selectedMap,
            sortType: ProxiesSortType.none,
            delayMap: delayMap,
            defaultTestUrl: testUrl,
          );
        },
        retryIf: (res) => res.isEmpty,
      );
      ref.read(groupsProvider.notifier).value = groups;
      await _restoreSelectedNode(groups);
    } catch (e) {
      commonPrint.log(
        'updateGroups error: $e',
        logLevel: coreFailureLogLevel(e),
      );
      ref.read(groupsProvider.notifier).value = [];
    }
  }

  void updateCurrentGroupName(String groupName) {
    final profile = ref.read(currentProfileProvider);
    if (profile == null || profile.currentGroupName == groupName) return;
    ref
        .read(profilesProvider.notifier)
        .put(profile.copyWith(currentGroupName: groupName));
  }

  void setDelay(Delay delay) {
    ref.read(delayDataSourceProvider.notifier).setDelay(delay);
  }

  Future<void> changeProxy({
    required String groupName,
    required String proxyName,
  }) async {
    await coreController.changeProxy(
      ChangeProxyParams(groupName: groupName, proxyName: proxyName),
    );
    await _resetConnections();
  }

  Future<void> _restoreSelectedNode(List<Group> groups) async {
    final profile = ref.read(currentProfileProvider);
    if (profile == null || groups.isEmpty) return;
    final groupNames = groups.map((group) => group.name).toSet();
    final nodeNames = groups
        .expand((group) => group.all)
        .map((proxy) => proxy.name)
        .where((name) => !groupNames.contains(name))
        .where((name) => !RuleTarget.baseTargets.contains(name))
        .toSet();
    final preferredGroup = profile.currentGroupName == GroupName.GLOBAL.name
        ? null
        : groups.getGroup(profile.currentGroupName ?? '');
    final group =
        preferredGroup ??
        groups
            .where(
              (item) =>
                  item.name != GroupName.GLOBAL.name && item.hidden == false,
            )
            .firstOrNull;
    if (group != null) {
      updateCurrentGroupName(group.name);
    }
    final selectedNodeName = profile.selectedNodeName;
    if (selectedNodeName != null && selectedNodeName.isNotEmpty) {
      if (!nodeNames.contains(selectedNodeName)) {
        ref.read(profilesActionProvider.notifier).clearSelectedNode();
      }
      return;
    }
    if (group == null) return;
    final proxyName = group.getCurrentSelectedName(
      profile.selectedMap[group.name] ?? '',
    );
    if (proxyName.isEmpty) return;
    final realProxyName = computeRealSelectedProxyState(
      proxyName,
      groups: groups,
      selectedMap: profile.selectedMap,
    ).proxyName;
    if (realProxyName.isEmpty || !nodeNames.contains(realProxyName)) return;
    ref
        .read(profilesActionProvider.notifier)
        .updateSelectedNode(
          groupName: group.name,
          proxyName: proxyName,
          selectedNodeName: realProxyName,
        );
    if (ref.read(coreStatusProvider) == CoreStatus.connected) {
      try {
        await coreController.changeProxy(
          ChangeProxyParams(
            groupName: GroupName.GLOBAL.name,
            proxyName: realProxyName,
          ),
        );
      } catch (error) {
        commonPrint.log(
          'restore selected node error: $error',
          logLevel: coreFailureLogLevel(error),
        );
      }
    }
  }

  Future<void> changeSelectedNode({
    required String groupName,
    required String proxyName,
    required String selectedNodeName,
  }) async {
    await coreController.changeProxy(
      ChangeProxyParams(groupName: groupName, proxyName: proxyName),
    );
    if (groupName != GroupName.GLOBAL.name) {
      await coreController.changeProxy(
        ChangeProxyParams(
          groupName: GroupName.GLOBAL.name,
          proxyName: selectedNodeName,
        ),
      );
    }
    await _resetConnections();
  }

  Future<void> _resetConnections() async {
    if (ref.read(appSettingProvider).closeConnections) {
      await coreController.closeConnections();
    } else {
      await coreController.resetConnections();
    }
  }

  Future<String> updateProvider(
    ExternalProvider provider, {
    bool showLoading = false,
  }) async {
    try {
      if (showLoading) {
        ref.read(isUpdatingProvider(provider.updatingKey).notifier).value =
            true;
      }
      final message = await coreController.updateExternalProvider(
        providerName: provider.name,
      );
      if (message.isNotEmpty) return message;
      ref
          .read(providersProvider.notifier)
          .setProvider(await coreController.getExternalProvider(provider.name));
      return '';
    } finally {
      ref.read(isUpdatingProvider(provider.updatingKey).notifier).value = false;
    }
  }
}
