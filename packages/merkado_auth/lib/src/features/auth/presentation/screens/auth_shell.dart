import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/merkado_auth_config.dart';

import '../cubit/auth_cubit.dart';
import 'account_picker_screen.dart';
import 'login/login_screen.dart';
import 'otp/otp_screen.dart';
import 'otp/tfa_screen.dart';
import 'password/forgot_password_screen.dart';

/// AuthShell
/// =========
/// The root widget of the package's built-in auth flow.
/// Wraps a [Navigator] that the package manages internally, keeping its
/// navigation stack completely separate from the consuming app's stack.
///
/// Uses [BlocConsumer] to listen to [AuthState] and push/pop the correct
/// screen. When auth is complete (authenticated), it pops the entire shell,
/// returning control to the consuming app.
///
/// If [MerkadoAuthConfig.customScreens] is provided, each step uses the
/// custom screen builder instead of the built-in screen.
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
          // Pop the entire auth shell when authenticated
          state.maybeWhen(
            authenticated: () => Navigator.of(context).pop(),
            orElse: () {},
          );
        },
        builder: (context, state) {
          return _buildScreen(context, state);
        },
      ),
    );
  }

  Widget _buildScreen(BuildContext context, AuthState state) {
    return state.when(
      initial: () => const _LoadingScreen(),
      loading: () => const _LoadingScreen(),

      // ── Account picker (cross-app SSO) ──────────────────────────────────
      accountsDetected: (accounts) {
        if (config.customScreens?.accountPickerScreenBuilder != null) {
          return config.customScreens!.accountPickerScreenBuilder!(
            context,
            cubit,
            accounts,
          );
        }
        return AccountPickerScreen(accounts: accounts, config: config);
      },

      // ── Unauthenticated → show login ─────────────────────────────────────
      unauthenticated: () {
        if (config.customScreens?.loginScreenBuilder != null) {
          return config.customScreens!.loginScreenBuilder!(context, cubit);
        }
        return LoginScreen(config: config);
      },

      // ── Email not verified → show OTP ────────────────────────────────────
      emailNotVerified: (email) {
        if (config.customScreens?.otpScreenBuilder != null) {
          return config.customScreens!.otpScreenBuilder!(context, cubit, email);
        }
        return OtpScreen(email: email, config: config);
      },

      // ── OTP verified → loading (session persistence in progress) ─────────
      otpVerified: (_) => const _LoadingScreen(),
      otpResent: () => const _LoadingScreen(),

      // ── 2FA required ─────────────────────────────────────────────────────
      mfaRequired: (userId, message) {
        if (config.customScreens?.twoFactorScreenBuilder != null) {
          return config.customScreens!.twoFactorScreenBuilder!(
            context,
            cubit,
            userId,
            message,
          );
        }
        return TwoFactorScreen(
          userId: userId,
          message: message,
          config: config,
        );
      },

      // ── Onboarding required ───────────────────────────────────────────────
      onboardingRequired: () {
        // Pop auth shell — consuming app handles onboarding routing
        // via AuthOnboardingRequired emitted on authStream
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) Navigator.of(context).pop();
        });
        return const _LoadingScreen();
      },

      // ── Forgot password ───────────────────────────────────────────────────
      passwordResetSent: () {
        if (config.customScreens?.forgotPasswordScreenBuilder != null) {
          return config.customScreens!.forgotPasswordScreenBuilder!(
            context,
            cubit,
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
        // Show login with a targeted message
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

      // ── Error ─────────────────────────────────────────────────────────────
      authenticated: () => const _LoadingScreen(), // handled in listener
      error: (message) {
        // Stay on login screen — error is shown via snackbar by the screen itself
        if (config.customScreens?.loginScreenBuilder != null) {
          return config.customScreens!.loginScreenBuilder!(context, cubit);
        }
        return LoginScreen(config: config, errorMessage: message);
      },
    );
  }
}

/// Simple full-screen loading indicator shown during transitions.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
