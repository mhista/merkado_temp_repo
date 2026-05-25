

// ════════════════════════════════════════════════════════════════════════════
// TWO FACTOR SCREEN
// lib/src/features/auth/presentation/screens/two_factor_screen.dart
// ════════════════════════════════════════════════════════════════════════════

/// TwoFactorScreen
/// ===============
/// Shown when backend returns [isMfa: true] in the login response.
/// Collects the 2FA OTP and submits to [AuthCubit.verifyTwoFactor].
/// Enabled/disabled via [AuthFeatures.twoFactorAuth].
import 'package:common_designs/common_designs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:merkado_auth/merkado_auth.dart';
import 'package:pinput/pinput.dart';

import '../styles.dart';

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
  String _otp = '';

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          state.whenOrNull(
            error: (msg) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red),
            ),
          );
        },
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(
            horizontal: 17.5,
            vertical: kToolbarHeight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.huge,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: context.authOnSurface,
                ),
              ),
              Column(
                spacing: AppSpacing.sm,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Two-Factor Auth',
                    style: LoginPageStyler.textStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    widget.message,
                    style: LoginPageStyler.textStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Pinput(
                    length: 6,
                    defaultPinTheme: PinTheme(
                      width: 48,
                      height: 56,
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: context.authOnSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: BoxDecoration(
                        color: context.authSurface,
                        border: Border.all(color: context.authOutline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onCompleted: (pin) {
                      setState(() => _otp = pin);
                      cubit.verifyTwoFactor(
                        userId: widget.userId,
                        otp: pin,
                      );
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) => ElevatedButton(
                        onPressed: state.maybeWhen(
                          loading: () => null,
                          orElse: () => () => cubit.verifyTwoFactor(
                                userId: widget.userId,
                                otp: _otp,
                              ),
                        ),
                        child: state.maybeWhen(
                          loading: () => LoadingAnimationWidget.fallingDot(
                            color: Colors.white,
                            size: 24,
                          ),
                          orElse: () => const Text(
                            'Verify',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}