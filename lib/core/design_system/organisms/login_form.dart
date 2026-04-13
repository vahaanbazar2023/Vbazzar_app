import 'package:flutter/material.dart';
import '../molecules/app_textfield.dart';
import '../molecules/primary_button.dart';
import '../tokens/app_spacing.dart';

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
      setState(() => _emailError = 'Email is required');
      isValid = false;
    } else if (!email.contains('@')) {
      setState(() => _emailError = 'Please enter a valid email');
      isValid = false;
    }

    // Password validation
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    } else if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
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
            label: 'Email',
            hint: 'Enter your email',
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
            label: 'Password',
            hint: 'Enter your password',
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
              text: 'Forgot Password?',
              onPressed: widget.onForgotPasswordPressed,
              isDisabled: widget.isLoading,
            ),
          ),

          SizedBox(height: AppSpacing.xl),

          // Login button
          PrimaryButton.large(
            text: 'Login',
            onPressed: _handleLogin,
            isLoading: widget.isLoading,
          ),
        ],
      ),
    );
  }
}
