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
import '../password/forgot_password_screen.dart';
import '../signup/signup_screen.dart';
import '../styles.dart';

/// LoginScreen
/// ===========
/// Built-in login screen. Shown when:
/// - No session exists and no known accounts are found
/// - User explicitly chooses "Use a different account" on the picker
/// - Session expired (shows [sessionExpiredMessage] if provided)
/// - Password was reset (shows [showPasswordResetSuccess] banner)
///
/// Replaces this screen entirely by providing [CustomAuthScreens.loginScreenBuilder].
class LoginScreen extends StatefulWidget {
  final MerkadoAuthConfig config;
  final String? errorMessage;
  final String? sessionExpiredMessage;
  final bool showPasswordResetSuccess;
  const LoginScreen({
    super.key,
    required this.config,
    this.errorMessage,
    this.sessionExpiredMessage,
    this.showPasswordResetSuccess = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(AuthCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    cubit.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final config = widget.config;
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          // Show error snackbar — cubit stays on login screen for error states
          state.whenOrNull(
            error: (message) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.red),
            ),
          );
        },
        builder: (context, state) {
          return Box(
            style: LoginPageStyler.onboardingBg(),
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: AppSpacing.sm,
                  children: [
                    // ── Session expired banner ─────────────────────────────
                    // if (widget.sessionExpiredMessage != null)
                    //   _Banner(
                    //     message: widget.sessionExpiredMessage!,
                    //     color: Colors.orange.shade50,
                    //     borderColor: Colors.orange,
                    //     icon: Icons.info_outline,
                    //   ),
                    // // ── Password reset success banner ──────────────────────
                    // if (widget.showPasswordResetSuccess)
                    //   const _Banner(
                    //     message: 'Password reset successfully. Please log in.',
                    //     color: Color(0xFFE8F5E9),
                    //     borderColor: Colors.green,
                    //     icon: Icons.check_circle_outline,
                    //   ),
                    // APP LOGO + NAME
                    Row(
                      spacing: AppSpacing.xs,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ImagePr
                        EdgeRoundedImages(
                          image: config.appLogo,
                          width: 52.74,
                          height: 52.74,
                          imageType: ImagesType.asset,
                          // useImageProvider: true,
                        ),
                        StyledText(
                          config.appName,
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
                          'Welcome back👋',
                          style: LoginPageStyler.textStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        StyledText(
                          'Access your ${config.appName} account',
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
                      canDispose: false,
                    ),

                    TextFieldForm(
                      controller: _passwordController,
                      fieldName: 'Password',
                      labelText: 'Your password',
                      // suffixIcon: HugeIcons.strokeRoundedLock,
                      useSuffixIcon: true,
                      validator: CommonValidators.passwordValidator,
                      enabled: true,
                      obscureText: true,
                      canDispose: false,
                    ),

                    // FORGOT PASSWORD
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: LoginPageStyler.textButtonStyle(),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider.value(
                                value: cubit,
                                child: ForgotPasswordScreen(config: config),
                              ),
                            ),
                          ),
                          child: StyledText(
                            'Forgot password?',
                            style: LoginPageStyler.textStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Column(
                      spacing: AppSpacing.xxs,

                      children: [
                        // SizedBox(height: (24).toDouble()),
                        // LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              return ElevatedButton(
                                onPressed: state.maybeWhen(
                                  orElse: () => () {
                                    _submit(cubit);
                                  },
                                  loading: null,
                                ),
                                child: state.maybeWhen(
                                  orElse: () => const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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

                        // SIGNUP REDIRECT
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StyledText(
                              'Don\'t have an account?',
                              style: LoginPageStyler.textStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => BlocProvider.value(
                                    value: cubit,
                                    child: SignupScreen(config: config),
                                  ),
                                ),
                              ),
                              child: StyledText(
                                'Sign Up',
                                style: LoginPageStyler.textStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // SOCIAL SIGN IN AND SSO
                        // Column(
                        //   spacing: AppSpacing.sm,
                        //   children: [
                        //     StyledText(
                        //       'You can continue to sign in with',
                        //       style: LoginPageStyler.textStyle(
                        //         fontSize: 12,
                        //         fontWeight: FontWeight.w300,
                        //       ),
                        //     ),

                        //     Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       spacing: 16,
                        //       children: [
                        //         EdgeRoundedImages(
                        //           imageType: ImagesType.asset,
                        //           image: ImageAssets.logo,
                        //           width: 40,
                        //           height: 40,
                        //         ),
                        //       ],
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
