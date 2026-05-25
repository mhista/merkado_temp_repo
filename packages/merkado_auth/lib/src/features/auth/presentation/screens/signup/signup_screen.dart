import 'package:common_designs/common_designs.dart';
import 'package:common_utils2/common_utils2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:merkado_auth/src/features/auth/presentation/screens/login/login_screen.dart';
import 'package:merkado_ds/merkado_ds.dart';
import '../../../../../../merkado_auth.dart';
import '../../widgets/terms_and_service_widget.dart';
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

  void _submit(AuthCubit cubit) async {
    final deviceInfo = DeviceInfoHelper.instance;
    final deviceOs = await deviceInfo.getPlatformInfo();
    final deviceName = await deviceInfo.getDeviceInfo();
    final fcmToken = CommonNotificationService.instance.token ?? '';
    if (_formKey.currentState!.validate()) {
      cubit.signUp(
        fcmToken: fcmToken,
        deviceName: deviceName,
        deviceOs: deviceOs,
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

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
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 17.5,
                vertical: kToolbarHeight,
              ),
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
                        color: context.authOnSurface,
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
                                Text(
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
                                Text(
                                  'Welcome to ${config.appName}👋',
                                  style: LoginPageStyler.textStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
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
                              suffixIcon: Icons.mail_outline,
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
                                          _submit(cubit);
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
                                    Text(
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
                                      child: Text(
                                        ' Login',
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
