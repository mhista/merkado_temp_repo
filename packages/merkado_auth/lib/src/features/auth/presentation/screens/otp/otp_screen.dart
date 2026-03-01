// ════════════════════════════════════════════════════════════════════════════
// OTP SCREEN
// lib/src/features/auth/presentation/screens/otp_screen.dart
// ════════════════════════════════════════════════════════════════════════════

import 'package:common_designs/common_designs.dart';
import 'package:common_utils2/common_utils2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:merkado_auth/merkado_auth.dart';
import 'package:merkado_auth/src/features/auth/presentation/screens/otp/otp_timer.dart';
import 'package:mix/mix.dart';
import 'package:pinput/pinput.dart';

import '../../cubit/auth_cubit.dart';
import '../styles.dart';

/// OtpScreen
/// =========
/// Shown after signup when the user needs to verify their email.
/// Submits the 6-digit OTP and optionally shows a resend button.
/// Controlled by [AuthFeatures.emailOtpVerification] and [AuthFeatures.resendOtp]

class OtpScreen extends StatefulWidget {
  final String email;
  final MerkadoAuthConfig config;
  final bool canResend, isAuthReset;

  const OtpScreen({
    super.key,
    required this.email,
    required this.config,
    this.canResend = true,
    this.isAuthReset = false,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // bool _resendEnabled = false;
  String _otp = '';
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // _resendEnabled = widget.canResend;
  }

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
            otpResent: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP resent successfully')),
            ),
          );
        },
        child: SingleChildScrollView(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),

            child: Box(
              style: LoginPageStyler.onboardingBg().paddingY(kToolbarHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.huge + AppSpacing.xxs,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      DeviceInfoHelper.instance.isIOS
                          ? Icons.arrow_back_ios_new
                          : Icons.arrow_back,
                      size: 20,
                    ),
                  ),
                  Column(
                    spacing: AppSpacing.sm,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisSize: MainAxisSize.min ,
                    children: [
                      StyledText(
                        'Verify Your Email',
                        style: LoginPageStyler.textStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ).textAlign(TextAlign.center),
                      ),
                      StyledText(
                        'We emailed you a 6 digit code to ${widget.email}',
                        style: LoginPageStyler.textStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ).textAlign(TextAlign.center),
                      ),
                      Pinput(
                        length: 6,
                        defaultPinTheme: PinTheme(
                          width: 48,
                          height: 56,
                          textStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Color(0xffe5e7eb)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onCompleted: (pin) async {
                          // Handle OTP completion
                          setState(() {
                            loading = true;
                            _otp = pin;
                          });
                          if (widget.isAuthReset) {
                           await cubit.verifyResetPasswordRequest(
                              email: widget.email,
                              otp: _otp,
                            );
                          } else {
                           await cubit.verifyEmail(email: widget.email, otp: _otp);
                          }
                          setState(() {
                            loading = false;
                          });
                        },
                      ),
                      // DIDN'T RECEIVE OTP
                      if (widget.canResend)
                        OtpResendTimer(
                          duration: Duration(seconds: 50),
                          onResend: () async {
                            await cubit.resendOtp(email: widget.email);
                          },
                        ),

                      // VERIFY BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: state.maybeWhen(
                                orElse: () => () {
                                  if (widget.isAuthReset) {
                                    cubit.verifyResetPasswordRequest(
                                      email: widget.email,
                                      otp: _otp,
                                    );
                                  } else {
                                    cubit.verifyEmail(
                                      email: widget.email,
                                      otp: _otp,
                                    );
                                  }
                                },
                                loading: () => null,
                              ),
                              child: state.maybeWhen(
                                orElse: () => const Text('Verify'),
                                loading: () =>
                                    LoadingAnimationWidget.fallingDot(
                                      color: Colors.white,
                                      size: 24,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
