import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccessView extends ConsumerStatefulWidget {
  const AccessView({super.key});

  @override
  ConsumerState<AccessView> createState() => _AccessViewState();
}

class _AccessViewState extends ConsumerState<AccessView> {
  final GlobalKey<CommonScaffoldState> _scaffoldKey = GlobalKey();
  late ScrollController _controller;
  List<String>? _pinedList;
  bool _isInit = false;
  AccessControlMode? _lastMode;

  bool _isLoadingPackages = true;
  bool _isPackagesError = false;
  bool _autoApplied = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    final accessControl = ref
        .read(vpnSettingProvider.select((state) => state.accessControlProps))
        .copyWith();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accessControlStateProvider.notifier).value = accessControl;
      _isInit = true;
    });
    _loadPackages();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadPackages({bool force = false}) async {
    final alreadyLoaded = ref.read(packagesProvider).isNotEmpty;
    if (!force && alreadyLoaded) {
      if (mounted) setState(() => _isLoadingPackages = false);
      _maybeAutoIntelligent();
      return;
    }
    if (mounted) setState(() => _isLoadingPackages = true);
    try {
      await ref.read(systemActionProvider.notifier).getPackages();
      if (mounted) {
        setState(() {
          _isLoadingPackages = false;
          _isPackagesError = false;
        });
        _maybeAutoIntelligent();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPackages = false;
          _isPackagesError = true;
        });
      }
    }
  }

  /// 首次开启且用户尚未手动选择时，自动应用智能选择，给出合理默认状态。
  void _maybeAutoIntelligent() {
    if (_autoApplied) return;
    final state = ref.read(accessControlStateProvider);
    if (!state.enable) return;
    if (state.currentList.isNotEmpty) return;
    if (ref.read(packagesProvider).isEmpty) return;
    _autoApplied = true;
    _intelligentSelected();
  }

  void _toggleSelectAll(List<String> allValueList) {
    ref.read(accessControlStateProvider.notifier).update((state) {
      final newSet = Set<String>.from(state.currentList);
      final isSelectedAll = newSet.containsAll(allValueList);
      if (isSelectedAll) {
        newSet.removeAll(allValueList);
      } else {
        newSet.addAll(allValueList);
      }
      return state.copyWithNewList(newSet.toList());
    });
  }

  Future<void> _intelligentSelected() async {
    final packageNames = ref.read(
      packagesProvider.select((state) => state.map((item) => item.packageName)),
    );
    if (packageNames.isEmpty) {
      return;
    }
    final selectedPackageNames =
        (await globalState.loadingRun<List<String>>(() async {
          return await app?.getChinaPackageNames() ?? [];
        }, tag: LoadingTag.access))?.toSet() ??
        {};
    final acceptList = packageNames
        .where((item) => !selectedPackageNames.contains(item))
        .toList();
    final rejectList = packageNames
        .where((item) => selectedPackageNames.contains(item))
        .toList();
    ref.read(accessControlStateProvider.notifier).update(
          (state) => state.copyWith(
            acceptList: acceptList,
            rejectList: rejectList,
          ),
        );
  }

  Future<void> _handleToSetting() async {
    await showSheet<int>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (context) {
        final appLocalizations = context.appLocalizations;
        return AdaptiveSheetScaffold(
          body: const AccessControlPanel(),
          title: appLocalizations.accessControlSettings,
        );
      },
    );
  }

  void _handleSelected(String packageName) {
    ref.read(accessControlStateProvider.notifier).update((state) {
      final newSet = Set<String>.from(state.currentList)
        ..addOrRemove(packageName);
      return state.copyWithNewList(newSet.toList());
    });
  }

  void _handleToggle() {
    final next = !ref.read(accessControlStateProvider).enable;
    ref.read(accessControlStateProvider.notifier).update((state) {
      return state.copyWith(enable: next);
    });
    if (next) {
      if (ref.read(packagesProvider).isEmpty) {
        _loadPackages(force: true);
      }
      _maybeAutoIntelligent();
    }
  }

  AccessControlProps _getRealAccessControlProps(
    AccessControlProps accessControl,
  ) {
    final packages = ref.read(packagesProvider);
    if (packages.isEmpty) {
      return accessControl;
    }
    final viewPackageNames = packages
        .getViewList(
          pinedList: [],
          sortType: accessControl.sort,
          isFilterSystemApp: accessControl.isFilterSystemApp,
          isFilterNonInternetApp: accessControl.isFilterNonInternetApp,
        )
        .map((item) => item.packageName)
        .toSet();
    return accessControl.copyWithNewList(
      accessControl.currentList
          .where((item) => viewPackageNames.contains(item))
          .toList()
        ..sort(),
    );
  }

  void _persist(AccessControlProps props) {
    ref.read(vpnSettingProvider.notifier).update(
      (state) => state.copyWith(
        accessControlProps: _getRealAccessControlProps(props),
      ),
    );
  }

  Future<void> _exportToClipboard() async {
    final currentList = ref.read(
      accessControlStateProvider.select((state) => state.currentList),
    );
    await globalState.safeRun(() {
      Clipboard.setData(ClipboardData(text: currentList.join('\n')));
    });
    if (mounted) {
      context.showSnackBar(
        context.appLocalizations.exportedToClipboard(currentList.length),
      );
    }
  }

  Future<void> _importFormClipboard() async {
    final text = await globalState.safeRun<String>(() async {
      final data = await Clipboard.getData('text/plain');
      return data?.text ?? '';
    });
    if (text == null || text.trim().isEmpty) {
      if (mounted) {
        context.showSnackBar(context.appLocalizations.clipboardEmpty);
      }
      return;
    }
    final list = text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e.contains('.') && !e.contains(' '))
        .toSet()
        .toList();
    final confirmed = await showDialog<bool>(
      context: context, // ignore: use_build_context_synchronously — showDialog 仅用 context 同步 push，不存在跨 await 使用
      builder: (ctx) => AlertDialog(
        title: Text(ctx.appLocalizations.clipboardImport),
        content: Text(ctx.appLocalizations.importOverwriteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(ctx.appLocalizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(ctx.appLocalizations.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    ref
        .read(accessControlStateProvider.notifier)
        .update((state) => state.copyWithNewList(list));
    if (mounted) {
      context.showSnackBar(
        context.appLocalizations.importedFromClipboard(list.length),
      );
    }
  }

  List<Widget> _buildActions(BuildContext context, {required bool enable}) {
    final appLocalizations = context.appLocalizations;
    return [
      CommonPopupBox(
        targetBuilder: (open) {
          return IconButton(
            onPressed: () {
              open(offset: const Offset(0, 0));
            },
            icon: const Icon(Icons.more_vert),
          );
        },
        popup: CommonPopupMenu(
          items: [
            PopupMenuItemData(
              icon: Icons.auto_awesome,
              label: appLocalizations.intelligentSelected,
              onPressed: _intelligentSelected,
            ),
            PopupMenuItemData(
              icon: Icons.tune,
              label: appLocalizations.settings,
              onPressed: _handleToSetting,
            ),
            PopupMenuItemData(
              icon: Icons.content_copy,
              label: appLocalizations.clipboardExport,
              onPressed: _exportToClipboard,
            ),
            PopupMenuItemData(
              icon: Icons.paste,
              label: appLocalizations.clipboardImport,
              onPressed: _importFormClipboard,
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildContent({
    required bool isLoading,
    required bool isError,
    required List<Package> packages,
    required List<String> valueList,
    required AccessControlMode mode,
    String? searchQuery,
  }) {
    final appLocalizations = context.appLocalizations;
    if (isLoading) {
      return const Center(child: CommonCircleLoading());
    }
    if (isError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(appLocalizations.packageLoadFailed),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _loadPackages(force: true),
              icon: const Icon(Icons.refresh),
              label: Text(appLocalizations.retry),
            ),
          ],
        ),
      );
    }
    if (packages.isEmpty) {
      return NullStatus(
        label: searchQuery != null && searchQuery.isNotEmpty
            ? appLocalizations.noMatchResult
            : appLocalizations.noData,
      );
    }
    return CommonScrollBar(
      controller: _controller,
      child: ListView.builder(
        controller: _controller,
        itemCount: packages.length,
        itemExtent: 72,
        padding: const EdgeInsets.only(bottom: 80),
        itemBuilder: (_, index) {
          final package = packages[index];
          final isSelected = valueList.contains(package.packageName);
          final tag = isSelected
              ? (mode == AccessControlMode.rejectSelected
                  ? appLocalizations.excludedFromVpnTag
                  : appLocalizations.includedToVpnTag)
              : null;
          return PackageListItem(
            key: Key(package.packageName),
            package: package,
            value: isSelected,
            tag: tag,
            onChanged: (_) => _handleSelected(package.packageName),
          );
        },
      ),
    );
  }

  Widget _buildMasterSwitchCard(bool enable) {
    final appLocalizations = context.appLocalizations;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      decoration: BoxDecoration(
        color: context.tDesign.container,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(
          Icons.shield_outlined,
          color: context.colorScheme.primary,
        ),
        title: Text(appLocalizations.appAccessControl),
        subtitle: Text(enable ? appLocalizations.on : appLocalizations.off),
        trailing: Switch(
          value: enable,
          onChanged: (_) => _handleToggle(),
        ),
      ),
    );
  }

  Widget _buildDisabledGuidance() {
    final appLocalizations = context.appLocalizations;
    final tokens = context.tDesign;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 48,
              color: tokens.textDisabled,
            ),
            const SizedBox(height: 12),
            Text(
              appLocalizations.accessControlDisabledHint,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: tokens.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar({
    required bool isSelectedAll,
    required List<String> allValueList,
    required int count,
  }) {
    final appLocalizations = context.appLocalizations;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: BoxDecoration(
          color: context.tDesign.container,
          border: Border(
            top: BorderSide(color: context.tDesign.componentStroke),
          ),
        ),
        child: Row(
          children: [
            FilledButton.icon(
              onPressed: () => _toggleSelectAll(allValueList),
              icon: Icon(
                isSelectedAll ? Icons.deselect : Icons.select_all,
              ),
              label: Text(
                isSelectedAll
                    ? appLocalizations.cancelSelectAll
                    : appLocalizations.selectAll,
              ),
            ),
            const Spacer(),
            Text(
              '${appLocalizations.selected} $count',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearch(String value) {
    ref.read(queryProvider(QueryTag.access).notifier).value = value;
    _pinedList = null;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider(LoadingTag.access));
    final query = ref.watch(queryProvider(QueryTag.access)).toLowerCase();
    final packages = ref.watch(packagesProvider);
    final accessControl = ref.watch(accessControlStateProvider);
    final enable = accessControl.enable;
    ref.listen(accessControlStateProvider, (_, next) {
      if (_isInit) _persist(next);
    });
    ref.listen(
      accessControlStateProvider.select((s) => s.mode),
      (prev, next) {
        if (prev != null && prev != next && enable) {
          final count =
              ref.read(accessControlStateProvider).currentList.length;
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.showSnackBar(
              context.appLocalizations.modeSwitchedHint(
                next == AccessControlMode.rejectSelected
                    ? context.appLocalizations.blacklistMode
                    : context.appLocalizations.whitelistMode,
                count,
              ),
            );
          });
        }
      },
    );
    if (_isInit) {
      if (_lastMode != accessControl.mode) {
        _lastMode = accessControl.mode;
        _pinedList = accessControl.currentList;
      } else {
        _pinedList ??= accessControl.currentList;
      }
    }
    final viewPackages = packages
        .getViewList(
          pinedList: _pinedList ?? [],
          sortType: accessControl.sort,
          isFilterNonInternetApp: accessControl.isFilterNonInternetApp,
          isFilterSystemApp: accessControl.isFilterSystemApp,
        )
        .where(
          (package) =>
              package.label.toLowerCase().contains(query) ||
              package.packageName.contains(query),
        )
        .toList();
    final mode = accessControl.mode;
    final currentList = accessControl.currentList;
    final viewPackageNameList = viewPackages.map((e) => e.packageName).toList();
    final valueList = currentList.intersection(viewPackageNameList);
    final isSelectedAll = viewPackageNameList.isNotEmpty &&
        valueList.length == viewPackageNameList.length;
    return CommonScaffold(
      key: _scaffoldKey,
      isLoading: isLoading,
      searchState:
          AppBarSearchState(onSearch: _onSearch, autoAddSearch: enable),
      title: context.appLocalizations.appAccessControl,
      actions: _buildActions(context, enable: enable),
      body: Column(
        children: [
          _buildMasterSwitchCard(enable),
          const SizedBox(height: 8),
          Expanded(
            child: enable
                ? _buildContent(
                    isLoading: _isLoadingPackages,
                    isError: _isPackagesError,
                    packages: viewPackages,
                    valueList: valueList,
                    mode: mode,
                    searchQuery: query,
                  )
                : _buildDisabledGuidance(),
          ),
          if (enable)
            _buildBottomBar(
              isSelectedAll: isSelectedAll,
              allValueList: viewPackageNameList,
              count: valueList.length,
            ),
        ],
      ),
    );
  }
}

class PackageListItem extends StatelessWidget {
  final Package package;
  final bool value;
  final String? tag;
  final void Function(bool?) onChanged;

  const PackageListItem({
    super.key,
    required this.package,
    required this.value,
    this.tag,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tag = this.tag;
    return ListItem.checkbox(
      leading: PackageIcon(packageName: package.packageName, size: 48),
      title: Row(
        children: [
          Expanded(
            child: Text(
              package.label,
              style: const TextStyle(overflow: TextOverflow.ellipsis),
              maxLines: 1,
            ),
          ),
          if (tag != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: context.tDesign.componentStroke,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tag,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.tDesign.textPlaceholder,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        package.packageName,
        style: const TextStyle(overflow: TextOverflow.ellipsis),
        maxLines: 1,
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

class AccessControlPanel extends ConsumerStatefulWidget {
  const AccessControlPanel({super.key});

  @override
  ConsumerState createState() => _AccessControlPanelState();
}

class _AccessControlPanelState extends ConsumerState<AccessControlPanel> {
  IconData _getIconWithAccessControlMode(AccessControlMode mode) {
    return switch (mode) {
      AccessControlMode.acceptSelected => Icons.adjust_outlined,
      AccessControlMode.rejectSelected => Icons.block_outlined,
    };
  }

  String _getTextWithAccessControlMode(AccessControlMode mode) {
    final appLocalizations = context.appLocalizations;
    return switch (mode) {
      AccessControlMode.acceptSelected => appLocalizations.whitelistMode,
      AccessControlMode.rejectSelected => appLocalizations.blacklistMode,
    };
  }

  String _getTextWithAccessSortType(AccessSortType type) {
    final appLocalizations = context.appLocalizations;
    return switch (type) {
      AccessSortType.none => appLocalizations.defaultText,
      AccessSortType.name => appLocalizations.name,
      AccessSortType.time => appLocalizations.time,
    };
  }

  IconData _getIconWithProxiesSortType(AccessSortType type) {
    return switch (type) {
      AccessSortType.none => Icons.sort,
      AccessSortType.name => Icons.sort_by_alpha,
      AccessSortType.time => Icons.timeline,
    };
  }

  List<Widget> _buildModeSetting() {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      isFirst: true,
      title: appLocalizations.mode,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Consumer(
            builder: (_, ref, _) {
              final accessControlMode = ref.watch(
                accessControlStateProvider.select((state) => state.mode),
              );
              return Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  for (final item in AccessControlMode.values)
                    SettingInfoCard(
                      Info(
                        label: _getTextWithAccessControlMode(item),
                        iconData: _getIconWithAccessControlMode(item),
                      ),
                      isSelected: accessControlMode == item,
                      onPressed: () {
                        ref
                            .read(accessControlStateProvider.notifier)
                            .update((state) => state.copyWith(mode: item));
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSortSetting() {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      title: appLocalizations.sort,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Consumer(
            builder: (_, ref, _) {
              final accessSortType = ref.watch(
                accessControlStateProvider.select((state) => state.sort),
              );
              return Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  for (final item in AccessSortType.values)
                    SettingInfoCard(
                      Info(
                        label: _getTextWithAccessSortType(item),
                        iconData: _getIconWithProxiesSortType(item),
                      ),
                      isSelected: accessSortType == item,
                      onPressed: () {
                        ref
                            .read(accessControlStateProvider.notifier)
                            .update((state) => state.copyWith(sort: item));
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSourceSetting() {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      title: appLocalizations.source,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Consumer(
            builder: (_, ref, _) {
              final vm2 = ref.watch(
                accessControlStateProvider.select(
                  (state) => VM2(
                    state.isFilterSystemApp,
                    state.isFilterNonInternetApp,
                  ),
                ),
              );
              return Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  SettingTextCard(
                    appLocalizations.systemApp,
                    isSelected: vm2.a == false,
                    onPressed: () {
                      ref
                          .read(accessControlStateProvider.notifier)
                          .update(
                            (state) =>
                                state.copyWith(isFilterSystemApp: !vm2.a),
                          );
                    },
                  ),
                  SettingTextCard(
                    appLocalizations.noNetworkApp,
                    isSelected: vm2.b == false,
                    onPressed: () {
                      ref
                          .read(accessControlStateProvider.notifier)
                          .update(
                            (state) =>
                                state.copyWith(isFilterNonInternetApp: !vm2.b),
                          );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._buildModeSetting(),
            ..._buildSortSetting(),
            ..._buildSourceSetting(),
          ],
        ),
      ),
    );
  }
}
