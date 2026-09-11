import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DarkModeItem extends ConsumerWidget {
  const DarkModeItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final isDarkMode =
        ref.watch(appSettingProvider.select((state) => state.themeMode)) ==
        ThemeMode.dark;
    return ListItem.toggle(
      leading: const Icon(Icons.dark_mode_outlined),
      title: Text(appLocalizations.darkMode),
      subtitle: Text(appLocalizations.darkModeDesc),
      value: isDarkMode,
      onChanged: (value) {
        ref
            .read(appSettingProvider.notifier)
            .update(
              (state) => state.copyWith(
                themeMode: value ? ThemeMode.dark : ThemeMode.light,
              ),
            );
      },
    );
  }
}

class CloseConnectionsItem extends ConsumerWidget {
  const CloseConnectionsItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final closeConnections = ref.watch(
      appSettingProvider.select((state) => state.closeConnections),
    );
    return ListItem.toggle(
      leading: const Icon(Icons.link_off_outlined),
      title: Text(appLocalizations.autoCloseConnections),
      subtitle: Text(appLocalizations.autoCloseConnectionsDesc),
      value: closeConnections,
      onChanged: (value) async {
        ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(closeConnections: value));
      },
    );
  }
}

class UsageItem extends ConsumerWidget {
  const UsageItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final onlyStatisticsProxy = ref.watch(
      appSettingProvider.select((state) => state.onlyStatisticsProxy),
    );
    return ListItem.toggle(
      leading: const Icon(Icons.data_usage_outlined),
      title: Text(appLocalizations.onlyStatisticsProxy),
      subtitle: Text(appLocalizations.onlyStatisticsProxyDesc),
      value: onlyStatisticsProxy,
      onChanged: (bool value) async {
        ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(onlyStatisticsProxy: value));
      },
    );
  }
}

class MinimizeItem extends ConsumerWidget {
  const MinimizeItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final minimizeOnExit = ref.watch(
      appSettingProvider.select((state) => state.minimizeOnExit),
    );
    return ListItem.toggle(
      leading: const Icon(Icons.minimize_outlined),
      title: Text(appLocalizations.minimizeOnExit),
      subtitle: Text(appLocalizations.minimizeOnExitDesc),
      value: minimizeOnExit,
      onChanged: (bool value) {
        ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(minimizeOnExit: value));
      },
    );
  }
}

class AutoLaunchItem extends ConsumerWidget {
  const AutoLaunchItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final autoLaunch = ref.watch(
      appSettingProvider.select((state) => state.autoLaunch),
    );
    return ListItem.toggle(
      leading: const Icon(Icons.rocket_launch_outlined),
      title: Text(appLocalizations.autoLaunch),
      subtitle: Text(appLocalizations.autoLaunchDesc),
      value: autoLaunch,
      onChanged: (bool value) {
        ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(autoLaunch: value));
      },
    );
  }
}

class SilentLaunchItem extends ConsumerWidget {
  const SilentLaunchItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final silentLaunch = ref.watch(
      appSettingProvider.select((state) => state.silentLaunch),
    );
    return ListItem.toggle(
      leading: const Icon(Icons.visibility_off_outlined),
      title: Text(appLocalizations.silentLaunch),
      subtitle: Text(appLocalizations.silentLaunchDesc),
      value: silentLaunch,
      onChanged: (bool value) {
        ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(silentLaunch: value));
      },
    );
  }
}

class AutoRunItem extends ConsumerWidget {
  const AutoRunItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final autoRun = ref.watch(
      appSettingProvider.select((state) => state.autoRun),
    );
    return ListItem.toggle(
      leading: const Icon(Icons.play_circle_outline),
      title: Text(appLocalizations.autoRun),
      subtitle: Text(appLocalizations.autoRunDesc),
      value: autoRun,
      onChanged: (bool value) {
        ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(autoRun: value));
      },
    );
  }
}

class OpenLogsItem extends ConsumerWidget {
  const OpenLogsItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final openLogs = ref.watch(
      appSettingProvider.select((state) => state.openLogs),
    );
    return ListItem.toggle(
      leading: const Icon(Icons.receipt_long_outlined),
      title: Text(appLocalizations.logcat),
      subtitle: Text(appLocalizations.logcatDesc),
      value: openLogs,
      onChanged: (bool value) {
        ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(openLogs: value));
      },
    );
  }
}

class AutoCheckUpdateItem extends ConsumerWidget {
  const AutoCheckUpdateItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final autoCheckUpdate = ref.watch(
      appSettingProvider.select((state) => state.autoCheckUpdate),
    );
    return ListItem.toggle(
      leading: const Icon(Icons.system_update_outlined),
      title: Text(appLocalizations.autoCheckUpdate),
      subtitle: Text(appLocalizations.autoCheckUpdateDesc),
      value: autoCheckUpdate,
      onChanged: (bool value) {
        ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(autoCheckUpdate: value));
      },
    );
  }
}
