import 'package:fl_clash/auth/providers.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonalCenterView extends ConsumerStatefulWidget {
  const PersonalCenterView({super.key});

  @override
  ConsumerState<PersonalCenterView> createState() => _PersonalCenterViewState();
}

class _PersonalCenterViewState extends ConsumerState<PersonalCenterView> {
  bool _loggingOut = false;

  Future<void> _logout() async {
    if (_loggingOut) return;
    final confirmed = await globalState.showMessage(
      title: '退出登录',
      message: const TextSpan(text: '退出后将停止当前代理连接。'),
      confirmText: '退出登录',
    );
    if (confirmed != true || !mounted) return;
    setState(() => _loggingOut = true);
    try {
      await ref.read(authControllerProvider).logout();
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: context.appLocalizations.personalCenter,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _loggingOut ? null : _logout,
                style: FilledButton.styleFrom(
                  backgroundColor: context.colorScheme.error,
                  foregroundColor: context.colorScheme.onError,
                ),
                icon: _loggingOut
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                label: const Text('退出登录'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
