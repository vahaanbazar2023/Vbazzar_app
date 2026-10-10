import 'package:flutter/material.dart';
import '../molecules/app_textfield.dart';
import '../molecules/primary_button.dart';
import '../tokens/app_spacing.dart';
import '../../extensions/context_extensions.dart';

/// Login form organism
/// Complex reusable component combining multiple molecules
class LoginForm extends StatefulWidget {
  final VoidCallback? onLoginPressed;
  final VoidCallback? onForgotPasswordPressed;
  final bool isLoading;

  const LoginForm({
    super.key,
    this.onLoginPressed,
    this.onForgotPasswordPressed,
    this.isLoading = false,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool isValid = true;

    // Email validation
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = context.l10n.emailRequired);
      isValid = false;
    } else if (!email.contains('@')) {
      setState(() => _emailError = context.l10n.coreEnterValidEmail);
      isValid = false;
    }

    // Password validation
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _passwordError = context.l10n.corePasswordRequired);
      isValid = false;
    } else if (password.length < 6) {
      setState(() => _passwordError = context.l10n.corePasswordMinLength);
      isValid = false;
    }

    return isValid;
  }

  void _handleLogin() {
    if (_validateForm()) {
      widget.onLoginPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          AppTextField(
            controller: _emailController,
            label: context.l10n.email,
            hint: context.l10n.enterEmail,
            errorText: _emailError,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.email_outlined,
            enabled: !widget.isLoading,
            onChanged: (_) {
              if (_emailError != null) {
                setState(() => _emailError = null);
              }
            },
          ),

          SizedBox(height: AppSpacing.lg),

          // Password field
          PasswordTextField(
            controller: _passwordController,
            label: context.l10n.password,
            hint: context.l10n.coreEnterYourPassword,
            errorText: _passwordError,
            onChanged: (_) {
              if (_passwordError != null) {
                setState(() => _passwordError = null);
              }
            },
            onSubmitted: (_) => _handleLogin(),
          ),

          SizedBox(height: AppSpacing.md),

          // Forgot password link
          Align(
            alignment: Alignment.centerRight,
            child: AppTextButton(
              text: context.l10n.forgotPassword,
              onPressed: widget.onForgotPasswordPressed,
              isDisabled: widget.isLoading,
            ),
          ),

          SizedBox(height: AppSpacing.xl),

          // Login button
          PrimaryButton.large(
            text: context.l10n.login,
            onPressed: _handleLogin,
            isLoading: widget.isLoading,
          ),
        ],
      ),
    );
  }
}
