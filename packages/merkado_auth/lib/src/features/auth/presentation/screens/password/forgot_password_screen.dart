

// ════════════════════════════════════════════════════════════════════════════
// FORGOT PASSWORD SCREEN
// lib/src/features/auth/presentation/screens/forgot_password_screen.dart
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merkado_auth/merkado_auth.dart';

import '../../cubit/auth_cubit.dart';

/// ForgotPasswordScreen
/// ====================
/// Shown when user taps "Forgot password?" on the login screen.
/// Collects email and triggers [AuthCubit.forgotPassword].
/// Enabled/disabled via [AuthFeatures.forgotPassword].
class ForgotPasswordScreen extends StatefulWidget {
  final MerkadoAuthConfig config;
  final bool resetSent;

  const ForgotPasswordScreen({
    super.key,
    required this.config,
    this.resetSent = false,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reset password'), elevation: 0),
      body: BlocListener<AuthCubit, AuthState>(
        // ForgotPasswordScreen is Navigator.pushed on top of AuthShell from LoginScreen.
        // When cubit emits passwordResetSent, AuthShell's body swaps to a confirmation
        // view underneath. Pop here so the confirmation becomes visible.
        listener: (context, state) {
          state.whenOrNull(
            passwordResetSent: () {
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            },
            error: (msg) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.resetSent)
              // Success state — instruction sent
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: Colors.green, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Check your email',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We\'ve sent password reset instructions to your email.',
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to login'),
                  ),
                ],
              )
            else
              // Input state — collect email
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter the email address associated with your account.',
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => cubit.forgotPassword(
                        email: _emailController.text.trim(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.config.primaryColor,
                      ),
                      child: const Text('Send reset instructions'),
                    ),
                  ),
                ],
              ),
          ],
        ),
        ),  // Padding
      ),    // BlocListener
    );
  }
}
