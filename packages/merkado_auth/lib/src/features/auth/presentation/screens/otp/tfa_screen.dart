

// ════════════════════════════════════════════════════════════════════════════
// TWO FACTOR SCREEN
// lib/src/features/auth/presentation/screens/two_factor_screen.dart
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merkado_auth/merkado_auth.dart';

import '../../cubit/auth_cubit.dart';

/// TwoFactorScreen
/// ===============
/// Shown when backend returns [isMfa: true] in the login response.
/// Collects the 2FA OTP and submits to [AuthCubit.verifyTwoFactor].
/// Enabled/disabled via [AuthFeatures.twoFactorAuth].
class TwoFactorScreen extends StatefulWidget {
  final String userId;
  final String message;
  final MerkadoAuthConfig config;

  const TwoFactorScreen({
    super.key,
    required this.userId,
    required this.message,
    required this.config,
  });

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Two-factor authentication'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message),
            const SizedBox(height: 24),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Authentication code',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.security_outlined),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => cubit.verifyTwoFactor(
                  userId: widget.userId,
                  otp: _otpController.text.trim(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.config.primaryColor,
                ),
                child: const Text('Verify'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}