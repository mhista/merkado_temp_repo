import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merkado_auth/src/features/auth/presentation/screens/password/reset_password_screen.dart';

import '../../../../core/config/merkado_auth_config.dart';
import '../cubit/auth_cubit.dart';
import 'account_picker_screen.dart';
import 'login/login_screen.dart';
import 'mycut_theme.dart';
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
///   initial                        → _LoadingScreen (first-load only)
///   loading                        → stays on last visible screen (button handles indicator)
///   unauthenticated                → LoginScreen (or custom)
///   accountsDetected               → AccountPickerScreen (or custom)
///   emailNotVerified               → OtpScreen (or custom)
///   onboardingRequired             → OnboardingScreen (or custom)
///   mfaRequired                    → TwoFactorScreen (or custom)
///   passwordResetSent              → ForgotPasswordScreen (or custom)
///   passwordResetSuccess           → LoginScreen with success banner
///   sessionExpiredForAccount       → LoginScreen with expiry message
///   authenticated                  → shell pops (listener)
///   error                          → stays on current screen (snackbar shown)
///   otpVerified / otpResent        → stays on current screen (transient)
///
/// If [MerkadoAuthConfig.customScreens] supplies a builder for a given
/// state, that builder is used instead of the built-in screen.
///
/// LOADING BEHAVIOUR:
/// `loading` and other transient states (otpVerified, otpResent, error) do NOT
/// replace the current screen with a fullscreen spinner. The last stable screen
/// is cached in [_lastStableScreen] and re-rendered during transient states.
/// Each screen's own button handles its local loading indicator via BlocBuilder.
/// The fullscreen spinner only appears for the very first [initial] state before
/// any screen has been shown.
class AuthShell extends StatefulWidget {
  final MerkadoAuthConfig config;
  final AuthCubit cubit;

  const AuthShell({super.key, required this.config, required this.cubit});

  @override
  State<AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends State<AuthShell> {
  /// The last screen widget produced by a stable (non-transient) state.
  /// Re-used during loading/transient states so the UI doesn't flash.
  Widget? _lastStableScreen;

  /// States that produce a real, stable screen the user interacts with.
  /// Any other state is transient — we hold the last stable screen instead.
  bool _isStableState(AuthState state) {
    return state.maybeWhen(
      unauthenticated: () => true,
      localAccountsDetected: (_) => true,
      accountsDetected: (_) => true,
      emailNotVerified: (_) => true,
      onboardingRequired: () => true,
      mfaRequired: (_, __) => true,
      passwordResetSent: (_) => true,
      passwordResetRequestSent: (_) => true,
      passwordResetSuccess: () => true,
      sessionExpiredForAccount: (_, __) => true,
      orElse: () => false,
    );
  }

  /// Whether the current state is a "root" screen — one where pressing
  /// back should exit the auth shell entirely (or close the app) rather
  /// than navigating within the shell.
  bool _isRootScreen(AuthState state) {
    return state.maybeWhen(
      unauthenticated: () => true,
      localAccountsDetected: (_) => true,
      accountsDetected: (_) => true,
      sessionExpiredForAccount: (_, __) => true,
      orElse: () => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      // ✅ Force light brightness regardless of device setting.
      // This ensures system-derived colors (input decorations, overlays)
      // also respect your forced light theme inside the auth shell.
      data: MediaQuery.of(
        context,
      ).copyWith(platformBrightness: widget.config.brightness),
      child: Theme(
        data:
            widget.config.theme ??
            ThemeData.fallback(), // wrap in our custom theme

        child: BlocProvider.value(
          value: widget.cubit,
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              state.maybeWhen(
                authenticated: () => Navigator.of(context).pop(),
                orElse: () {},
              );
            },
            builder: (context, state) {
              final screen = _buildScreen(context, state);

              // Cache the screen if this is a stable state
              if (_isStableState(state)) {
                _lastStableScreen = screen;
              }

              // PopScope wraps each rebuild so it always has the current state.
              //
              // Back button behaviour:
              //   • Root screens (login, account pickers) — canPop: false.
              //     onPopInvokedWithResult fires but we DON'T pop the shell.
              //     Instead we let the OS handle it (minimise the app) by
              //     calling Navigator.of(context).pop() only when on a
              //     sub-screen so the user can go BACK to login, not exit auth.
              //   • Sub-screens (OTP, onboarding, 2FA, forgot password) —
              //     canPop: false + pop the shell back to login/account picker
              //     so the user can correct their email or choose differently.
              //     We never allow a raw pop that would land on splash/_LoginGate.
              return PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, _) {
                  if (didPop) return;
                  if (_isRootScreen(state)) {
                    // On root screen — user wants to leave the auth flow entirely.
                    // Pop the shell so the app goes to whatever is below
                    // (splash/login gate handles it from there).
                    SystemNavigator.pop();
                  } else {
                    // On a sub-screen — go back to login/account picker
                    // without popping the shell.
                    widget.cubit.emit(const AuthState.unauthenticated());
                  }
                },
                child: screen,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildScreen(BuildContext context, AuthState state) {
    return state.when(
      // ── NEW: Onboarding Upload Progress State ───────────────────────
      onboardingUploading: (progress, message) {
        // Show the onboarding screen with upload progress overlay
        // We pass the progress so OnboardingScreen can display it nicely
        if (widget.config.customScreens?.onboardingScreenBuilder != null) {
          return widget.config.customScreens!.onboardingScreenBuilder!(
            context,
            widget.cubit,
          );
        }
        return OnboardingScreen(config: widget.config);
      },
      // ── First-load only: no stable screen cached yet ──────────────────────
      initial: () => _lastStableScreen ?? const _LoadingScreen(),

      // ── Transient states: hold the last stable screen ─────────────────────
      // The button already shows its own loading indicator via BlocBuilder.
      // Replacing the whole screen here would cause a jarring flash.
      loading: () => _lastStableScreen ?? const _LoadingScreen(),
      otpVerified: (_) => _lastStableScreen ?? const _LoadingScreen(),
      otpResent: () => _lastStableScreen ?? const _LoadingScreen(),
      authenticated: () =>
          _lastStableScreen ?? const _LoadingScreen(), // pop is in listener
      error: (message) {
        // Stay on the current screen — the screen's own BlocConsumer listener
        // shows the snackbar. We don't rebuild to a new screen for errors.
        return _lastStableScreen ?? _buildLoginScreen(context);
      },

      // ── Stable screens ────────────────────────────────────────────────────

      // Local accounts for THIS app — shown after logout or on startup
      // when the user has previously signed in here.
      localAccountsDetected: (accounts) {
        if (widget.config.customScreens?.accountPickerScreenBuilder != null) {
          return widget.config.customScreens!.accountPickerScreenBuilder!(
            context,
            widget.cubit,
            accounts,
          );
        }
        return AccountPickerScreen(
          accounts: accounts,
          config: widget.config,
          isLocalAccounts:
              true, // drives copy: "Switch account" vs "Continue as"
        );
      },

      accountsDetected: (accounts) {
        if (widget.config.customScreens?.accountPickerScreenBuilder != null) {
          return widget.config.customScreens!.accountPickerScreenBuilder!(
            context,
            widget.cubit,
            accounts,
          );
        }
        return AccountPickerScreen(accounts: accounts, config: widget.config);
      },

      unauthenticated: () => _buildLoginScreen(context),

      emailNotVerified: (email) {
        if (widget.config.customScreens?.otpScreenBuilder != null) {
          return widget.config.customScreens!.otpScreenBuilder!(
            context,
            widget.cubit,
            email,
          );
        }
        return OtpScreen(email: email, config: widget.config, canResend: true);
      },

      onboardingRequired: () {
        if (widget.config.customScreens?.onboardingScreenBuilder != null) {
          return widget.config.customScreens!.onboardingScreenBuilder!(
            context,
            widget.cubit,
          );
        }
        return OnboardingScreen(config: widget.config);
      },

      mfaRequired: (userId, message) {
        if (widget.config.customScreens?.twoFactorScreenBuilder != null) {
          return widget.config.customScreens!.twoFactorScreenBuilder!(
            context,
            widget.cubit,
            userId,
            message,
          );
        }
        return TwoFactorScreen(
          userId: userId,
          message: message,
          config: widget.config,
        );
      },

      passwordResetRequestSent: (email) {
        if (widget.config.customScreens?.forgotPasswordScreenBuilder != null) {
          return widget.config.customScreens!.forgotPasswordScreenBuilder!(
            context,
            widget.cubit,
          );
        }
        return OtpScreen(
          config: widget.config,
          canResend: false,
          email: email,
          isAuthReset: true,
        );
      },

      passwordResetSent: (token) {
        if (widget.config.customScreens?.forgotPasswordScreenBuilder != null) {
          return widget.config.customScreens!.forgotPasswordScreenBuilder!(
            context,
            widget.cubit,
          );
        }
        return ResetPasswordScreen(config: widget.config, token: token);
      },

      passwordResetSuccess: () {
        if (widget.config.customScreens?.loginScreenBuilder != null) {
          return widget.config.customScreens!.loginScreenBuilder!(
            context,
            widget.cubit,
          );
        }
        return LoginScreen(
          config: widget.config,
          showPasswordResetSuccess: true,
        );
      },

      sessionExpiredForAccount: (userId, displayName) {
        if (widget.config.customScreens?.loginScreenBuilder != null) {
          return widget.config.customScreens!.loginScreenBuilder!(
            context,
            widget.cubit,
          );
        }
        return LoginScreen(
          config: widget.config,
          sessionExpiredMessage: displayName != null
              ? 'Your session for $displayName has expired. Please log in again.'
              : 'Your session has expired. Please log in again.',
        );
      },
    );
  }

  Widget _buildLoginScreen(BuildContext context) {
    if (widget.config.customScreens?.loginScreenBuilder != null) {
      return widget.config.customScreens!.loginScreenBuilder!(
        context,
        widget.cubit,
      );
    }
    return LoginScreen(config: widget.config);
  }
}

/// Simple full-screen loading indicator shown during state transitions.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
