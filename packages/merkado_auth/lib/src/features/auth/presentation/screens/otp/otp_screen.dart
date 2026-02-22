// ════════════════════════════════════════════════════════════════════════════
// OTP SCREEN
// lib/src/features/auth/presentation/screens/otp_screen.dart
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merkado_auth/merkado_auth.dart';

import '../../cubit/auth_cubit.dart';


/// OtpScreen
/// =========
/// Shown after signup when the user needs to verify their email.
/// Submits the 6-digit OTP and optionally shows a resend button.
/// Controlled by [AuthFeatures.emailOtpVerification] and [AuthFeatures.resendOtp].
class OtpScreen extends StatefulWidget {
  final String email;
  final MerkadoAuthConfig config;

  const OtpScreen({super.key, required this.email, required this.config});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool _resendEnabled = false;

  @override
  void initState() {
    super.initState();
    // Enable resend after 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) setState(() => _resendEnabled = true);
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Verify your email'), elevation: 0),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          state.whenOrNull(
            error: (msg) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red),
            ),
            otpResent: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP resent successfully')),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We sent a verification code to\n${widget.email}',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Enter 6-digit code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => cubit.verifyEmail(
                    email: widget.email,
                    otp: _otpController.text.trim(),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.config.primaryColor,
                  ),
                  child: const Text('Verify'),
                ),
              ),
              // ── Resend OTP ─────────────────────────────────────────────
              if (widget.config.features.resendOtp) ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _resendEnabled
                        ? () {
                            cubit.resendOtp(email: widget.email);
                            setState(() => _resendEnabled = false);
                            Future.delayed(const Duration(seconds: 30), () {
                              if (mounted) setState(() => _resendEnabled = true);
                            });
                          }
                        : null,
                    child: Text(
                      _resendEnabled ? 'Resend code' : 'Resend available in 30s',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

