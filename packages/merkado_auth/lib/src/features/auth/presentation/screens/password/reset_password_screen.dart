
// ════════════════════════════════════════════════════════════════════════════
// RESET PASSWORD SCREEN
// lib/src/features/auth/presentation/screens/reset_password_screen.dart
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merkado_auth/merkado_auth.dart';

import '../../cubit/auth_cubit.dart';

/// ResetPasswordScreen
/// ===================
/// Shown when the user follows the reset link from their email.
/// The reset [token] is extracted from the deep link and passed in.
/// Enabled/disabled via [AuthFeatures.resetPassword].

class ResetPasswordScreen extends StatefulWidget {
  final String token;
  final MerkadoAuthConfig config;

  const ResetPasswordScreen({
    super.key,
    required this.token,
    required this.config,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('New password'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: const InputDecoration(
                  labelText: 'New password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) => v == null || v.length < 8
                    ? 'Minimum 8 characters'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscure,
                decoration: const InputDecoration(
                  labelText: 'Confirm new password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) => v != _passwordController.text
                    ? 'Passwords do not match'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      cubit.resetPassword(
                        token: widget.token,
                        newPassword: _passwordController.text,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.config.primaryColor,
                  ),
                  child: const Text('Set new password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
