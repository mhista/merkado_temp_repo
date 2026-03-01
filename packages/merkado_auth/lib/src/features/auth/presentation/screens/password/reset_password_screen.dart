import 'package:common_designs/common_designs.dart';
import 'package:common_utils2/common_utils2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:merkado_auth/merkado_auth.dart';
import 'package:merkado_ds/merkado_ds.dart';
import 'package:mix/mix.dart';

import '../../cubit/auth_cubit.dart';
import '../styles.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  final MerkadoAuthConfig config;
  const ResetPasswordScreen({
    super.key,
    required this.config,
    required this.token,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

/// ResetPasswordScreen
/// ====================
/// Shown when user taps "Forgot password?" on the login screen.
/// Collects email and triggers [AuthCubit.forgotPassword].
/// Enabled/disabled via [AuthFeatures.forgotPassword].
class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        // ResetPasswordScreen is Navigator.pushed on top of AuthShell from LoginScreen.
        // When cubit emits passwordResetSent, AuthShell's body swaps to a confirmation
        // view underneath. Pop here so the confirmation becomes visible.
        listener: (context, state) {
          state.whenOrNull(
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
                        image: widget.config.appLogo,
                        // useImageProvider: true,
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
                        'Reset Password',
                        style: LoginPageStyler.textStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      StyledText(
                        'Enter your new password',
                        style: LoginPageStyler.textStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  // TEXT FIELDS
                  TextFieldForm(
                    controller: _passwordController,
                    fieldName: 'Password',
                    labelText: 'Your new password',
                    useSuffixIcon: true,
                    validator: CommonValidators.strongPasswordValidator,
                    enabled: true,
                    obscureText: true,
                  ),

                  TextFieldForm(
                    controller: _confirmController,
                    fieldName: 'Confirm Password',
                    labelText: 'Confirm your new password',
                    useSuffixIcon: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    enabled: true,
                    obscureText: true,
                  ),

                  Column(
                    children: [
                      SizedBox(height: (24).toDouble()),
                      // RESET PASSWORD BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: state.maybeWhen(
                                loading: () => null,
                                orElse: () {
                                  return () => () {
                                    if (_formKey.currentState!.validate()) {
                                      cubit.resetPassword(
                                        token: widget.token,
                                        newPassword: _passwordController.text,
                                      );
                                    }
                                  };
                                },
                              ),
                              child: state.maybeWhen(
                                loading: () =>
                                    LoadingAnimationWidget.fallingDot(
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                orElse: () => const Text(
                                  'Set New Password',
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
