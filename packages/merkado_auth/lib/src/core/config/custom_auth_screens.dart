import 'package:flutter/widgets.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

/// CustomAuthScreens
/// =================
/// Allows the consuming app to replace any or all built-in auth screens
/// with its own UI while the package continues to manage ALL logic:
/// tokens, API calls, state transitions, navigation, and SSO.
///
/// IMPORTANT: Custom screens receive an [AuthCubit] and must call its
/// methods to trigger auth actions. The package handles the results —
/// your screen only needs to render state and call actions.
///
/// EXAMPLE — replace only the login screen:
/// ```dart
/// CustomAuthScreens(
///   loginScreenBuilder: (context, cubit) => MyCustomLoginScreen(cubit: cubit),
/// )
/// ```
///
/// EXAMPLE — replace all screens:
/// ```dart
/// CustomAuthScreens(
///   loginScreenBuilder:      (context, cubit) => MyLoginScreen(cubit: cubit),
///   signupScreenBuilder:     (context, cubit) => MySignupScreen(cubit: cubit),
///   otpScreenBuilder:        (context, cubit, email) => MyOtpScreen(cubit: cubit, email: email),
///   onboardingScreenBuilder: (context, cubit) => MyOnboardingScreen(cubit: cubit),
/// )
/// ```
class CustomAuthScreens {
  /// Custom login screen.
  /// Receives [cubit] — call [cubit.login()] to trigger login.
  final Widget Function(BuildContext context, AuthCubit cubit)?
      loginScreenBuilder;

  /// Custom signup screen.
  /// Receives [cubit] — call [cubit.signUp()] to trigger signup.
  final Widget Function(BuildContext context, AuthCubit cubit)?
      signupScreenBuilder;

  /// Custom OTP verification screen.
  /// Receives [cubit] and the [email] the OTP was sent to.
  final Widget Function(BuildContext context, AuthCubit cubit, String email)?
      otpScreenBuilder;

  /// Custom onboarding screen.
  /// Shown after OTP verification when onboarding is not yet complete.
  /// Receives [cubit] — call [cubit.completeOnboarding()] to finish setup.
  ///
  /// CONTRACT: This screen is rendered inside [AuthShell] like all other
  /// screens. When [cubit.completeOnboarding()] succeeds, the cubit emits
  /// [AuthState.authenticated] and [AuthShell] pops itself automatically.
  /// You do NOT need to navigate manually — just call the cubit method.
  final Widget Function(BuildContext context, AuthCubit cubit)?
      onboardingScreenBuilder;

  /// Custom forgot password screen.
  final Widget Function(BuildContext context, AuthCubit cubit)?
      forgotPasswordScreenBuilder;

  /// Custom reset password screen.
  /// Receives [cubit] and the reset [token] from the email link.
  final Widget Function(BuildContext context, AuthCubit cubit, String token)?
      resetPasswordScreenBuilder;

  /// Custom 2FA screen.
  /// Receives [cubit], the [userId], and the [message] from backend.
  final Widget Function(
          BuildContext context, AuthCubit cubit, String userId, String message)?
      twoFactorScreenBuilder;

  /// Custom account picker screen for cross-app SSO.
  /// Receives [cubit] and the list of [hints] (known Grascope accounts on device).
  final Widget Function(
          BuildContext context, AuthCubit cubit, List<dynamic> hints)?
      accountPickerScreenBuilder;

  const CustomAuthScreens({
    this.loginScreenBuilder,
    this.signupScreenBuilder,
    this.otpScreenBuilder,
    this.onboardingScreenBuilder,
    this.forgotPasswordScreenBuilder,
    this.resetPasswordScreenBuilder,
    this.twoFactorScreenBuilder,
    this.accountPickerScreenBuilder,
  });
}