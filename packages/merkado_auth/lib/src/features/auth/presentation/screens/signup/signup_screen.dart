import 'package:common_designs/common_designs.dart';
import 'package:common_utils2/common_utils2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:merkado_auth/src/features/auth/presentation/screens/login/login_screen.dart';
import 'package:merkado_ds/merkado_ds.dart';
import 'package:mix/mix.dart';
import '../../../../../../merkado_auth.dart';
import '../../cubit/auth_cubit.dart';
import '../styles.dart';

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
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final config = widget.config;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<AuthCubit, AuthState>(
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
        builder: (context, state) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Box(
              style: LoginPageStyler.onboardingBg().paddingY(kToolbarHeight),
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: AppSpacing.xl,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
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
                                  image: config.appLogo,
                                  width: 52.74,
                                  height: 52.74,
                                  imageType: ImagesType.asset,
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
                                  'Welcome to ${config.appName}👋',
                                  style: LoginPageStyler.textStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                StyledText(
                                  'Register your account',
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

                            TextFieldForm(
                              controller: _passwordController,
                              fieldName: 'Password',
                              labelText: 'Your password',
                              // suffixIcon: HugeIcons.strokeRoundedLock,
                              useSuffixIcon: true,
                              validator: CommonValidators.passwordValidator,
                              enabled: true,
                              obscureText: true,
                            ),

                            Column(
                              spacing: AppSpacing.xxxs,
                              children: [
                                SizedBox(height: (24).toDouble()),
                                // LOGIN BUTTON
                                SizedBox(
                                  width: double.infinity,
                                  child: BlocBuilder<AuthCubit, AuthState>(
                                    builder: (context, state) => ElevatedButton(
                                      onPressed: state.maybeWhen(
                                        loading: () => null,
                                        orElse: () => () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            cubit.signUp(
                                              email: _emailController.text
                                                  .trim(),
                                              password:
                                                  _passwordController.text,
                                            );
                                          }
                                        },
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: config.primaryColor,
                                      ),
                                      child: state.maybeWhen(
                                        loading: () =>
                                            LoadingAnimationWidget.fallingDot(
                                              color: Colors.white,
                                              size: 24,
                                            ),
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

                                // SIGNUP REDIRECT
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    StyledText(
                                      'Already have an account?',
                                      style: LoginPageStyler.textStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    TextButton(
                                      style: LoginPageStyler.textButtonStyle(),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      // Navigator.of(context).push(
                                      //   MaterialPageRoute<void>(
                                      //     builder: (_) =>
                                      //         BlocProvider.value(
                                      //           value: cubit,
                                      //           child: LoginScreen(
                                      //             config: config,
                                      //           ),
                                      //         ),
                                      //   ),
                                      // ),
                                      child: StyledText(
                                        ' Login',
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
                                //       'You can also to sign up with',
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
                      ],
                    ),

                    // TERMS AND CONDITIONS
                    TermsAndServiceWidget(config: config),
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

class TermsAndServiceWidget extends StatelessWidget {
  const TermsAndServiceWidget({super.key, required this.config});
  final MerkadoAuthConfig config;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kToolbarHeight),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Divider(),
          StyledText(
            'By continuing, you agree to ${config.appName} ',
            style: LoginPageStyler.textStyle(
              fontSize: 10,
              fontWeight: FontWeight.w300,
            ),
          ),

          TextButton(
            style: LoginPageStyler.textButtonStyle(),
            onPressed: () {
              // getIt<AppRouter>().pushNamed(Routes.terms);
            },
            child: StyledText(
              'Terms ',
              style: LoginPageStyler.textStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          StyledText(
            '&',
            style: LoginPageStyler.textStyle(
              fontSize: 10,
              fontWeight: FontWeight.w300,
            ),
          ),
          TextButton(
            style: LoginPageStyler.textButtonStyle(),
            onPressed: () {
              // getIt<AppRouter>().pushNamed(Routes.privacy);
            },
            child: StyledText(
              ' Privacy Policy',
              style: LoginPageStyler.textStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
