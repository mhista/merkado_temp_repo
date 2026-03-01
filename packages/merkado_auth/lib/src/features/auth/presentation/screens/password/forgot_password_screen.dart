import 'package:common_designs/common_designs.dart';
import 'package:common_utils2/common_utils2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:merkado_auth/merkado_auth.dart';
import 'package:merkado_ds/merkado_ds.dart';
import 'package:mix/mix.dart';

import '../../cubit/auth_cubit.dart';
import '../styles.dart';

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

/// ForgotPasswordScreen
/// ====================
/// Shown when user taps "Forgot password?" on the login screen.
/// Collects email and triggers [AuthCubit.forgotPassword].
/// Enabled/disabled via [AuthFeatures.forgotPassword].
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();

    return Scaffold(
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
        child: Box(
          style: LoginPageStyler.onboardingBg().paddingY(kToolbarHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.huge,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  DeviceInfoHelper.instance.isIOS
                      ? Icons.arrow_back_ios_new
                      : Icons.arrow_back,
                  size: 20,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: AppSpacing.sm,
                children: [
                  // APP LOGO + NAME
                  Row(
                    spacing: AppSpacing.xs,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      EdgeRoundedImages(
                        // useImageProvider: true,
                        image: widget.config.appLogo,
                        width: 52.74,
                        height: 52.74,
                        imageType: ImagesType.asset,
                      ),
                      StyledText(
                        widget.config.appName,
                        style: LoginPageStyler.textStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  // WELCOME MESSAGE
                  Column(
                    spacing: 8,
                    children: [
                      StyledText(
                        'Forgot Password',
                        style: LoginPageStyler.textStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      StyledText(
                        'Enter your email to receive a password reset link',
                        style: LoginPageStyler.textStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  // TEXT FIELDS
                  TextFieldForm(
                    controller: _emailController,
                    fieldName: 'Email',
                    labelText: 'Your email',
                    suffixIcon: HugeIcons.strokeRoundedMail01,
                    useSuffixIcon: true,
                    validator: CommonValidators.emailValidator,
                    enabled: true,
                  ),

                  Column(
                    children: [
                      SizedBox(height: (24).toDouble()),
                      // LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: state.maybeWhen(
                                loading: () => null,
                                orElse: () =>
                                    () => cubit.forgotPassword(
                                      email: _emailController.text.trim(),
                                    ),
                              ),
                              child: state.maybeWhen(
                                loading: () =>
                                    LoadingAnimationWidget.fallingDot(
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                orElse: () => const Text(
                                  'Send reset instructions',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // SIGNUP REDIRECT
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StyledText(
                            'Remember your password?',
                            style: LoginPageStyler.textStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            // Navigator.of(context).push(
                            //   MaterialPageRoute<void>(
                            //     builder: (_) => BlocProvider.value(
                            //       value: cubit,
                            //       child: LoginScreen(config: widget.config),
                            //     ),
                            //   ),
                            // ),
                            child: StyledText(
                              'Back to Login',
                              style: LoginPageStyler.textStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
