import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_selector.dart';

class ProxiesView extends ConsumerWidget {
  const ProxiesView({super.key});

  Group? _currentGroup(WidgetRef ref, List<Group> groups) {
    final currentGroupName = ref.watch(
      currentProfileProvider.select((state) => state?.currentGroupName),
    );
    return groups.getGroup(currentGroupName ?? '') ??
        (groups.isEmpty ? null : groups.first);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(currentGroupsStateProvider).value;
    final group = _currentGroup(ref, groups);
    return HomeProxySelectorView(groupName: group?.name ?? '');
  }
}
