import 'package:fl_clash/auth/auth_controller.dart';
import 'package:fl_clash/auth/views/forgot_password.dart';
import 'package:fl_clash/auth/views/register.dart';
import 'package:fl_clash/auth/widgets/auth_widgets.dart';
import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({required this.controller, super.key});

  final AuthController controller;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _remember = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.controller.login(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
        remember: _remember,
      );
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
              controller: _emailController,
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
              controller: _passwordController,
              label: context.appLocalizations.authPassword,
              icon: Icons.lock_outline,
              password: true,
              enabled: !_loading,
              textInputAction: TextInputAction.done,
              validator: (value) => value?.isNotEmpty == true
                  ? null
                  : context.appLocalizations.authRequired,
              onFieldSubmitted: (_) => _submit(),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _loading
                          ? null
                          : () => setState(() => _remember = !_remember),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _remember,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            onChanged: _loading
                                ? null
                                : (value) => setState(
                                    () => _remember = value ?? false,
                                  ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.appLocalizations.authRemember,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: TextButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ForgotPasswordEmailView(
                                  api: widget.controller.api,
                                ),
                              ),
                            ),
                      child: Text(
                        context.appLocalizations.authForgotPassword,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: context.colorScheme.error)),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 64),
            AuthButton(
              label: context.appLocalizations.authLogin,
              loading: _loading,
              onPressed:
                  _emailController.text.isEmpty ||
                      _passwordController.text.isEmpty
                  ? null
                  : _submit,
            ),
            const SizedBox(height: 20),
            AuthButton(
              label: context.appLocalizations.authRegister,
              outlined: true,
              onPressed: _loading
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            RegisterView(controller: widget.controller),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
