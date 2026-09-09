import 'dart:convert';

import 'package:fl_clash/auth/providers.dart';
import 'package:fl_clash/auth/widgets/auth_widgets.dart';
import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordView extends ConsumerStatefulWidget {
  const ChangePasswordView({super.key});

  @override
  ConsumerState<ChangePasswordView> createState() =>
      _ChangePasswordViewState();
}

class _ChangePasswordViewState extends ConsumerState<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String? _validateNewPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return context.appLocalizations.authRequired;
    final length = utf8.encode(password).length;
    if (length < 8 || length > 72) {
      return context.appLocalizations.personalPasswordLength;
    }
    return null;
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider).ensureValidAccessToken();
      await ref.read(starcoreApiProvider).changePassword(
        oldPassword: _oldPassword.text,
        newPassword: _newPassword.text,
      );
      if (!mounted) return;
      context.showSnackBar(
        context.appLocalizations.personalChangePasswordSuccess,
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = context.appLocalizations.personalChangePasswordFailed;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: context.appLocalizations.personalChangePassword,
      showLogo: false,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              controller: _oldPassword,
              label: context.appLocalizations.personalOldPassword,
              icon: Icons.lock_outline,
              password: true,
              enabled: !_loading,
              textInputAction: TextInputAction.next,
              validator: (value) => value?.isNotEmpty == true
                  ? null
                  : context.appLocalizations.authRequired,
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _newPassword,
              label: context.appLocalizations.authNewPassword,
              icon: Icons.lock_outline,
              password: true,
              enabled: !_loading,
              textInputAction: TextInputAction.next,
              validator: _validateNewPassword,
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _confirmPassword,
              label: context.appLocalizations.authConfirmPassword,
              icon: Icons.lock_outline,
              password: true,
              enabled: !_loading,
              textInputAction: TextInputAction.done,
              validator: (value) => value == _newPassword.text
                  ? null
                  : context.appLocalizations.authPasswordMismatch,
              onFieldSubmitted: (_) => _submit(),
              onChanged: (_) => setState(() => _error = null),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: context.colorScheme.error),
              ),
            ],
            const SizedBox(height: 32),
            AuthButton(
              label: context.appLocalizations.personalConfirmChange,
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
