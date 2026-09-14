import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'update_controller.dart';
import 'update_state.dart';

Future<void> checkForUpdateAndShow(BuildContext context, WidgetRef ref) async {
  try {
    final info = await ref.read(updateControllerProvider.notifier).check();
    if (!context.mounted) return;
    if (info == null) {
      context.showNotifier(context.appLocalizations.updateUpToDate);
      return;
    }
    if (info.forceUpdate) return;
    await showUpdatePrompt(context, rememberDismissal: false);
  } on Object {
    if (context.mounted) {
      context.showNotifier(context.appLocalizations.updateCheckFailed);
    }
  }
}

Future<void> showUpdatePrompt(
  BuildContext context, {
  required bool rememberDismissal,
}) {
  return globalState.showCommonDialog<void>(
    context: context,
    dismissible: false,
    child: _UpdateDialog(rememberDismissal: rememberDismissal),
  );
}

class UpdateGate extends ConsumerWidget {
  const UpdateGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updateControllerProvider);
    if (state.info?.forceUpdate != true) return child;
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: ColoredBox(
              color: context.tDesign.pageBackground,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: _UpdateContent(
                            state: state,
                            forceUpdate: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateDialog extends ConsumerWidget {
  const _UpdateDialog({required this.rememberDismissal});

  final bool rememberDismissal;

  Future<void> _close(BuildContext context, UpdateState state) async {
    if (rememberDismissal && state.info != null) {
      await preferences.saveIgnoredUpdateReleaseId(state.info!.releaseId);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updateControllerProvider);
    final title = state.info?.updateTitle.isNotEmpty == true
        ? state.info!.updateTitle
        : context.appLocalizations.updateAvailableTitle;
    return PopScope(
      canPop: false,
      child: CommonDialog(
        title: title,
        maxWidth: 520,
        actions: [
          if (state.phase != UpdatePhase.downloading &&
              state.phase != UpdatePhase.verifying &&
              state.phase != UpdatePhase.launchingInstaller)
            TextButton(
              onPressed: () => unawaited(_close(context, state)),
              child: Text(context.appLocalizations.updateLater),
            ),
        ],
        child: _UpdateContent(state: state, forceUpdate: false),
      ),
    );
  }
}

class _UpdateContent extends ConsumerWidget {
  const _UpdateContent({required this.state, required this.forceUpdate});

  final UpdateState state;
  final bool forceUpdate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = state.info;
    if (info == null) return const SizedBox.shrink();
    final appLocalizations = context.appLocalizations;
    final busy =
        state.phase == UpdatePhase.downloading ||
        state.phase == UpdatePhase.verifying ||
        state.phase == UpdatePhase.launchingInstaller;
    final status = switch (state.phase) {
      UpdatePhase.downloading => appLocalizations.updateDownloading,
      UpdatePhase.verifying => appLocalizations.updateVerifying,
      UpdatePhase.readyToInstall => appLocalizations.updateReadyToInstall,
      UpdatePhase.launchingInstaller => appLocalizations.updateInstallerOpened,
      UpdatePhase.failed => appLocalizations.updateDownloadFailed,
      _ => null,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (forceUpdate)
          Text(
            info.updateTitle.isNotEmpty
                ? info.updateTitle
                : appLocalizations.requiredUpdateTitle,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        if (forceUpdate) const SizedBox(height: 12),
        Text(
          appLocalizations.updateVersion(info.latestVersion),
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${appLocalizations.updatePackageSize}: ${_formatBytes(info.packageSizeBytes)}',
          style: context.textTheme.bodySmall,
        ),
        if (info.updateDescription.isNotEmpty) ...[
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: SingleChildScrollView(
              child: SelectableText(
                info.updateDescription,
                style: context.textTheme.bodyMedium,
              ),
            ),
          ),
        ],
        if (state.phase == UpdatePhase.downloading) ...[
          const SizedBox(height: 20),
          LinearProgressIndicator(value: state.progress),
          const SizedBox(height: 8),
          Text(
            '${_formatBytes(state.downloadedBytes)} / ${_formatBytes(state.totalBytes)}',
            style: context.textTheme.bodySmall,
          ),
        ],
        if (status != null) ...[
          const SizedBox(height: 12),
          Text(
            status,
            style: context.textTheme.bodyMedium?.copyWith(
              color: state.phase == UpdatePhase.failed
                  ? context.colorScheme.error
                  : null,
            ),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: busy
                ? null
                : () => unawaited(
                    ref
                        .read(updateControllerProvider.notifier)
                        .downloadAndInstall(),
                  ),
            child: Text(
              state.phase == UpdatePhase.failed
                  ? appLocalizations.retry
                  : state.phase == UpdatePhase.readyToInstall
                  ? appLocalizations.updateInstallNow
                  : appLocalizations.updateNow,
            ),
          ),
        ),
        if (state.phase == UpdatePhase.downloading) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: ref
                  .read(updateControllerProvider.notifier)
                  .cancelDownload,
              child: Text(appLocalizations.updateCancelDownload),
            ),
          ),
        ],
      ],
    );
  }
}

String _formatBytes(int value) {
  if (value >= 1073741824) {
    return '${(value / 1073741824).toStringAsFixed(1)} GB';
  }
  if (value >= 1048576) {
    return '${(value / 1048576).toStringAsFixed(1)} MB';
  }
  if (value >= 1024) return '${(value / 1024).toStringAsFixed(1)} KB';
  return '$value B';
}
