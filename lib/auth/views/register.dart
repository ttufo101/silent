import 'package:fl_clash/auth/auth_controller.dart';
import 'package:fl_clash/auth/widgets/auth_widgets.dart';
import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({required this.controller, super.key});

  final AuthController controller;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
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
      await widget.controller.register(
        email: _email.text.trim().toLowerCase(),
        password: _password.text,
      );
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AuthTextField(
              controller: _email,
              label: context.appLocalizations.authEmail,
              icon: Icons.mail_outline,
              enabled: !_loading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) => validateEmail(context, value),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _password,
              label: context.appLocalizations.authPassword,
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
              label: context.appLocalizations.authRegister,
              loading: _loading,
              onPressed:
                  _email.text.isEmpty ||
                      _password.text.isEmpty ||
                      _confirm.text.isEmpty
                  ? null
                  : _submit,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _loading ? null : () => Navigator.of(context).pop(),
                child: Text(context.appLocalizations.authBackToLogin),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
