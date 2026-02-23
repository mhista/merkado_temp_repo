import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/merkado_auth_config.dart';
import '../cubit/auth_cubit.dart';
import 'account_picker_screen.dart';
import 'login/login_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'otp/otp_screen.dart';
import 'otp/tfa_screen.dart';
import 'password/forgot_password_screen.dart';

/// AuthShell
/// =========
/// The root widget of the package's built-in auth flow.
/// Wraps a [BlocConsumer] that maps [AuthState] to the correct screen.
/// The package manages all navigation internally — consuming apps only
/// call [MerkadoAuth.instance.pushAuth(context)] and listen to authStream.
///
/// Screen routing table:
///   initial / loading              → _LoadingScreen
///   unauthenticated                → LoginScreen (or custom)
///   accountsDetected               → AccountPickerScreen (or custom)
///   emailNotVerified               → OtpScreen (or custom)
///   onboardingRequired             → OnboardingScreen (or custom)   ← rendered here
///   mfaRequired                    → TwoFactorScreen (or custom)
///   passwordResetSent              → ForgotPasswordScreen (or custom)
///   passwordResetSuccess           → LoginScreen with success banner
///   sessionExpiredForAccount       → LoginScreen with expiry message
///   authenticated                  → shell pops (listener)
///   error                          → LoginScreen with error message
///
/// If [MerkadoAuthConfig.customScreens] supplies a builder for a given
/// state, that builder is used instead of the built-in screen.
class AuthShell extends StatelessWidget {
  final MerkadoAuthConfig config;
  final AuthCubit cubit;

  const AuthShell({super.key, required this.config, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          // Pop the entire auth shell once the user is fully authenticated.
          // All other states are handled by the builder below.
          state.maybeWhen(
            authenticated: () => Navigator.of(context).pop(),
            orElse: () {},
          );
        },
        builder: (context, state) => _buildScreen(context, state),
      ),
    );
  }

  Widget _buildScreen(BuildContext context, AuthState state) {
    return state.when(
      // ── Transient / loading states ─────────────────────────────────────────
      initial:    () => const _LoadingScreen(),
      loading:    () => const _LoadingScreen(),
      otpVerified: (_) => const _LoadingScreen(),
      otpResent:  () => const _LoadingScreen(),
      authenticated: () => const _LoadingScreen(), // actual pop is in listener

      // ── Account picker (cross-app SSO) ──────────────────────────────────
      accountsDetected: (accounts) {
        if (config.customScreens?.accountPickerScreenBuilder != null) {
          return config.customScreens!.accountPickerScreenBuilder!(
            context, cubit, accounts,
          );
        }
        return AccountPickerScreen(accounts: accounts, config: config);
      },

      // ── Unauthenticated → login ──────────────────────────────────────────
      unauthenticated: () {
        if (config.customScreens?.loginScreenBuilder != null) {
          return config.customScreens!.loginScreenBuilder!(context, cubit);
        }
        return LoginScreen(config: config);
      },

      // ── Email not verified → OTP ─────────────────────────────────────────
      emailNotVerified: (email) {
        if (config.customScreens?.otpScreenBuilder != null) {
          return config.customScreens!.otpScreenBuilder!(context, cubit, email);
        }
        return OtpScreen(email: email, config: config);
      },

      // ── Onboarding required → OnboardingScreen ───────────────────────────
      //
      // PREVIOUSLY BROKEN: this branch was calling Navigator.pop() and
      // returning a _LoadingScreen, which left the app stuck on splash.
      //
      // FIX: render OnboardingScreen (or the custom builder) directly inside
      // the shell, exactly like every other state. When completeOnboarding()
      // succeeds, the cubit emits authenticated → listener pops the shell.
      // No manual navigation needed.
      onboardingRequired: () {
        if (config.customScreens?.onboardingScreenBuilder != null) {
          return config.customScreens!.onboardingScreenBuilder!(context, cubit);
        }
        return OnboardingScreen(config: config);
      },

      // ── 2FA ─────────────────────────────────────────────────────────────
      mfaRequired: (userId, message) {
        if (config.customScreens?.twoFactorScreenBuilder != null) {
          return config.customScreens!.twoFactorScreenBuilder!(
            context, cubit, userId, message,
          );
        }
        return TwoFactorScreen(userId: userId, message: message, config: config);
      },

      // ── Forgot password — show confirmation state ─────────────────────────
      passwordResetSent: () {
        if (config.customScreens?.forgotPasswordScreenBuilder != null) {
          return config.customScreens!.forgotPasswordScreenBuilder!(
            context, cubit,
          );
        }
        return ForgotPasswordScreen(config: config, resetSent: true);
      },

      // ── Reset password success → back to login ────────────────────────────
      passwordResetSuccess: () {
        if (config.customScreens?.loginScreenBuilder != null) {
          return config.customScreens!.loginScreenBuilder!(context, cubit);
        }
        return LoginScreen(config: config, showPasswordResetSuccess: true);
      },

      // ── Session expired for a specific account ────────────────────────────
      sessionExpiredForAccount: (userId, displayName) {
        if (config.customScreens?.loginScreenBuilder != null) {
          return config.customScreens!.loginScreenBuilder!(context, cubit);
        }
        return LoginScreen(
          config: config,
          sessionExpiredMessage: displayName != null
              ? 'Your session for $displayName has expired. Please log in again.'
              : 'Your session has expired. Please log in again.',
        );
      },

      // ── Error — stay on login with inline message ─────────────────────────
      error: (message) {
        if (config.customScreens?.loginScreenBuilder != null) {
          return config.customScreens!.loginScreenBuilder!(context, cubit);
        }
        return LoginScreen(config: config, errorMessage: message);
      },
    );
  }
}

/// Simple full-screen loading indicator shown during state transitions.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}