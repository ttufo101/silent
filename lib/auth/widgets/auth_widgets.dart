import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String? validateEmail(BuildContext context, String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return context.appLocalizations.authRequired;
  final at = email.lastIndexOf('@');
  if (at <= 0 || at == email.length - 1) {
    return context.appLocalizations.authInvalidEmail;
  }
  final domain = email.substring(at + 1);
  if (email.indexOf('@') != at ||
      domain.startsWith('.') ||
      domain.endsWith('.') ||
      !domain.contains('.') ||
      email.length > 254) {
    return context.appLocalizations.authInvalidEmail;
  }
  return null;
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.child,
    this.title,
    this.showLogo = true,
    super.key,
  });

  final Widget child;
  final String? title;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              centerTitle: true,
              leading: const BackButton(),
            ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 327),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showLogo) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/icon.png',
                        width: 150,
                        height: 150,
                      ),
                    ),
                    const SizedBox(height: 117),
                  ],
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.password = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final bool password;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: widget.password && _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: null,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon),
        suffixIcon: widget.password
            ? IconButton(
                tooltip: _obscure ? 'Show password' : 'Hide password',
                onPressed: widget.enabled
                    ? () => setState(() => _obscure = !_obscure)
                    : null,
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility,
                ),
              )
            : null,
      ),
    );
  }
}

class AuthVerificationCodeField extends StatefulWidget {
  const AuthVerificationCodeField({
    required this.controller,
    required this.enabled,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  State<AuthVerificationCodeField> createState() =>
      _AuthVerificationCodeFieldState();
}

class _AuthVerificationCodeFieldState extends State<AuthVerificationCodeField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
  }

  void _handleFocusChanged() => setState(() {});

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: '邮箱验证码',
          textField: true,
          child: SizedBox(
            height: 56,
            child: Stack(
              fit: StackFit.expand,
              children: [
                IgnorePointer(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: widget.controller,
                    builder: (_, value, _) {
                      final code = value.text;
                      return Row(
                        children: List.generate(6, (index) {
                          final isActive =
                              widget.enabled &&
                              _focusNode.hasFocus &&
                              index == code.length;
                          final color = isError
                              ? context.colorScheme.error
                              : isActive
                              ? context.colorScheme.primary
                              : context.tDesign.componentStroke;
                          return Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                right: index == 5 ? 0 : 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: color,
                                    width: isActive || isError ? 2 : 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                index < code.length ? code[index] : '',
                                style: context.textTheme.headlineSmall,
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
                Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(counterText: ''),
                    onChanged: widget.onChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class AuthButton extends StatelessWidget {
  const AuthButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.outlined = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: outlined
                  ? context.colorScheme.primary
                  : context.colorScheme.onPrimary,
            ),
          )
        : Text(label);
    final callback = loading ? null : onPressed;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: outlined
          ? OutlinedButton(onPressed: callback, child: child)
          : FilledButton(onPressed: callback, child: child),
    );
  }
}

String maskEmail(String email) {
  final at = email.indexOf('@');
  if (at <= 1) return email;
  final visible = email.substring(0, at.clamp(1, 2));
  return '$visible*****${email.substring(at)}';
}
