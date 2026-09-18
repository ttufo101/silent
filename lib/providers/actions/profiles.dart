part of '../action.dart';

@Riverpod(keepAlive: true)
class ProfilesAction extends _$ProfilesAction {
  @override
  void build() {}

  void updateSelectedNode({
    required String groupName,
    required String proxyName,
    required String selectedNodeName,
  }) {
    final currentProfile = ref.read(currentProfileProvider);
    if (currentProfile == null) return;
    final selectedMap = Map<String, String>.from(currentProfile.selectedMap)
      ..[groupName] = proxyName
      ..[GroupName.GLOBAL.name] = selectedNodeName;
    ref
        .read(profilesProvider.notifier)
        .put(
          currentProfile.copyWith(
            selectedNodeName: selectedNodeName,
            selectedMap: selectedMap,
          ),
        );
  }

  void clearSelectedNode() {
    final currentProfile = ref.read(currentProfileProvider);
    if (currentProfile == null || currentProfile.selectedNodeName == null) {
      return;
    }
    final selectedMap = Map<String, String>.from(currentProfile.selectedMap)
      ..remove(GroupName.GLOBAL.name);
    ref
        .read(profilesProvider.notifier)
        .put(
          currentProfile.copyWith(
            selectedNodeName: null,
            selectedMap: selectedMap,
          ),
        );
  }
}
