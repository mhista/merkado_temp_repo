// ════════════════════════════════════════════════════════════════════════════
// SIGNUP SCREEN
// lib/src/features/auth/presentation/screens/signup_screen.dart
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merkado_auth/merkado_auth.dart';


import '../../cubit/auth_cubit.dart';


/// SignupScreen
/// ============
/// Pushed by [LoginScreen] via Navigator.push — it sits ON TOP of [AuthShell]
/// in the navigator stack, not inside it.
///
/// NAVIGATION CONTRACT:
/// When cubit emits [AuthState.emailNotVerified], [AuthShell]'s body rebuilds
/// to [OtpScreen] underneath this screen. This screen MUST pop itself so the
/// OtpScreen becomes visible. The BlocListener below handles this.
///
/// Do NOT add navigation logic for any other state here — [AuthShell] handles
/// all other transitions (onboarding, authenticated, etc.).
class SignupScreen extends StatefulWidget {
  final MerkadoAuthConfig config;
  const SignupScreen({super.key, required this.config});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final config = widget.config;

    return Scaffold(
      appBar: AppBar(title: Text('Join ${config.appName}'), elevation: 0),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          state.whenOrNull(
            // Pop this screen so AuthShell's body (OtpScreen) becomes visible.
            // This is the correct fix — the shell has already rebuilt its body
            // to OtpScreen, this screen just needs to get out of the way.
            emailNotVerified: (_) {
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            },
            error: (msg) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red),
            ),
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => v == null || v.length < 8
                      ? 'Password must be at least 8 characters'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscure,
                  decoration: const InputDecoration(
                    labelText: 'Confirm password',
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
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) => ElevatedButton(
                      onPressed: state.maybeWhen(
                        loading: () => null,
                        orElse: () => () {
                          if (_formKey.currentState!.validate()) {
                            cubit.signUp(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            );
                          }
                        },
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: config.primaryColor,
                      ),
                      child: state.maybeWhen(
                        loading: () => const CircularProgressIndicator(
                            color: Colors.white),
                        orElse: () => const Text(
                          'Create account',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (config.termsUrl != null || config.privacyUrl != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}