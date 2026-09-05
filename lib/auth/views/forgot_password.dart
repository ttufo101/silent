import 'dart:async';

import 'package:fl_clash/auth/data/auth_api.dart';
import 'package:fl_clash/auth/data/gateway_client.dart';
import 'package:fl_clash/auth/widgets/auth_widgets.dart';
import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

class ForgotPasswordEmailView extends StatefulWidget {
  const ForgotPasswordEmailView({required this.api, super.key});

  final AuthApi api;

  @override
  State<ForgotPasswordEmailView> createState() =>
      _ForgotPasswordEmailViewState();
}

class _ForgotPasswordEmailViewState extends State<ForgotPasswordEmailView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final email = _email.text.trim().toLowerCase();
    try {
      final result = await widget.api.sendPasswordRecoveryCode(email);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ForgotPasswordCodeView(
            api: widget.api,
            email: email,
            expireSeconds: result.expireSeconds,
            showSentFeedback: true,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.appLocalizations.authNetworkError);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: context.appLocalizations.authResetPassword,
      showLogo: false,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.appLocalizations.authEnterEmailTitle,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              context.appLocalizations.authEnterEmailDescription,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            AuthTextField(
              controller: _email,
              label: context.appLocalizations.authEmail,
              icon: Icons.mail_outline,
              enabled: !_loading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: (value) => validateEmail(context, value),
              onFieldSubmitted: (_) => _submit(),
              onChanged: (_) => setState(() {}),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: context.colorScheme.error)),
            ],
            const SizedBox(height: 51),
            AuthButton(
              label: context.appLocalizations.authSendCode,
              loading: _loading,
              onPressed: _email.text.isEmpty ? null : _submit,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _loading
                    ? null
                    : () => Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst),
                child: Text(context.appLocalizations.authBackToLogin),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordCodeView extends StatefulWidget {
  const ForgotPasswordCodeView({
    required this.api,
    required this.email,
    required this.expireSeconds,
    this.showSentFeedback = false,
    super.key,
  });

  final AuthApi api;
  final String email;
  final int expireSeconds;
  final bool showSentFeedback;

  @override
  State<ForgotPasswordCodeView> createState() => _ForgotPasswordCodeViewState();
}

class _ForgotPasswordCodeViewState extends State<ForgotPasswordCodeView> {
  final _code = TextEditingController();
  Timer? _timer;
  late int _seconds;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCountdown(widget.expireSeconds);
    if (widget.showSentFeedback) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.showSnackBar(
            context.appLocalizations.authCodeSent(maskEmail(widget.email)),
          );
        }
      });
    }
  }

  void _startCountdown(int seconds) {
    _timer?.cancel();
    _seconds = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_seconds <= 1) {
        timer.cancel();
        setState(() => _seconds = 0);
      } else {
        setState(() => _seconds--);
      }
    });
  }

  Future<void> _verify() async {
    if (_code.text.length != 6 || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final restToken = await widget.api.getRestToken(
        email: widget.email,
        code: _code.text,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ResetPasswordView(
            api: widget.api,
            email: widget.email,
            restToken: restToken,
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _error = _verificationErrorMessage(error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_seconds > 0 || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await widget.api.sendPasswordRecoveryCode(widget.email);
      if (mounted) {
        _code.clear();
        setState(() {
          _error = null;
          _startCountdown(result.expireSeconds);
        });
        context.showSnackBar(
          context.appLocalizations.authCodeSent(maskEmail(widget.email)),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _error = _networkErrorMessage());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  String _verificationErrorMessage(Object error) {
    if (_isNetworkError(error)) {
      return context.appLocalizations.authNetworkError;
    }
    if (error is GatewayException &&
        error.message == 'Invalid verification code') {
      return context.appLocalizations.authInvalidCode;
    }
    return context.appLocalizations.authServiceUnavailable;
  }

  String _networkErrorMessage() => context.appLocalizations.authNetworkError;

  bool _isNetworkError(Object error) {
    return error is GatewayException &&
        (error.message.contains('Network') ||
            error.message.contains('Connection') ||
            error.message.contains('timed out'));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: context.appLocalizations.authResetPassword,
      showLogo: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.appLocalizations.authEnterCodeTitle,
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text(
            context.appLocalizations.authCodeSent(maskEmail(widget.email)),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          AuthVerificationCodeField(
            controller: _code,
            enabled: !_loading,
            errorText: _error,
            onChanged: (value) {
              setState(() => _error = null);
              if (value.length == 6) _verify();
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (_seconds > 0)
                Text(
                  context.appLocalizations.authResendIn(_seconds),
                  style: TextStyle(color: context.colorScheme.error),
                ),
              const Spacer(),
              TextButton(
                onPressed: _seconds == 0 && !_loading ? _resend : null,
                child: Text(context.appLocalizations.authResend),
              ),
            ],
          ),
          if (_loading) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({
    required this.api,
    required this.email,
    required this.restToken,
    super.key,
  });

  final AuthApi api;
  final String email;
  final String restToken;

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.api.resetPassword(
        email: widget.email,
        restToken: widget.restToken,
        password: _password.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.appLocalizations.authResetSuccess)),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.appLocalizations.authNetworkError);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: context.appLocalizations.authResetPassword,
      showLogo: false,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.appLocalizations.authSetPasswordTitle,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 28),
            AuthTextField(
              controller: _password,
              label: context.appLocalizations.authNewPassword,
              icon: Icons.lock_outline,
              password: true,
              enabled: !_loading,
              textInputAction: TextInputAction.next,
              validator: (value) => value?.isNotEmpty == true
                  ? null
                  : context.appLocalizations.authRequired,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _confirm,
              label: context.appLocalizations.authConfirmPassword,
              icon: Icons.lock_outline,
              password: true,
              enabled: !_loading,
              textInputAction: TextInputAction.done,
              validator: (value) => value != _password.text
                  ? context.appLocalizations.authPasswordMismatch
                  : null,
              onFieldSubmitted: (_) => _submit(),
              onChanged: (_) => setState(() {}),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: context.colorScheme.error)),
            ],
            const SizedBox(height: 50),
            AuthButton(
              label: context.appLocalizations.authResetPassword,
              loading: _loading,
              onPressed: _password.text.isEmpty || _confirm.text.isEmpty
                  ? null
                  : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
