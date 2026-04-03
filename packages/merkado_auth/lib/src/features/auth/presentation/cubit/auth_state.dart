part of 'auth_cubit.dart';

/// AuthState
/// =========
/// Internal states used by [AuthCubit] to drive the package's own UI screens.
///
/// These are NOT directly exposed to consuming apps — apps receive [AuthResult]
/// events via [AuthEventBus.instance.stream] instead.
@freezed
class AuthState with _$AuthState {
  /// Before startup session check completes.
  const factory AuthState.initial() = _Initial;

  /// Any async operation in progress.
  const factory AuthState.loading() = _Loading;

  /// User is fully authenticated (verified + onboarded + valid token).
  const factory AuthState.authenticated() = _Authenticated;

  /// Accounts from THIS app detected in local shared storage.
  /// Shown after logout or on startup when the user has previously
  /// signed into this app with one or more accounts.
  /// UI: "Switch account" / "Sign in to a different account".
  /// Takes precedence over [accountsDetected] (cross-app SSO).
  const factory AuthState.localAccountsDetected({
    required List<GrascopeSessionHint> accounts,
  }) = _LocalAccountsDetected;

  /// Known Grascope accounts detected from CROSS-APP shared storage.
  /// Only shown when no local accounts exist for this app but other
  /// Grascope apps on this device have active sessions.
  /// UI: "Continue as [name]" — cross-app SSO flow.
  const factory AuthState.accountsDetected({
    required List<GrascopeSessionHint> accounts,
  }) = _AccountsDetected;

  /// No session and no known accounts. Show login/signup.
  const factory AuthState.unauthenticated() = _Unauthenticated;

  /// Signup or login returned [verified: false].
  /// Navigate to OTP screen. [email] pre-fills the screen.
  const factory AuthState.emailNotVerified({required String email}) =
      _EmailNotVerified;

  /// OTP verified successfully. Onboarding screen follows immediately.
  const factory AuthState.otpVerified({required String message}) = _OtpVerified;

  /// OTP resent successfully. Stay on OTP screen, show confirmation.
  const factory AuthState.otpResent() = _OtpResent;

  /// Email verified but onboarding not complete.
  /// Navigate to onboarding screen (firstName, lastName, country, avatar).
  const factory AuthState.onboardingRequired() = _OnboardingRequired;

  /// Backend requires 2FA before granting access.
  const factory AuthState.mfaRequired({
    required String userId,
    required String message,
  }) = _MfaRequired;

  /// Password reset request sent successfully.
  const factory AuthState.passwordResetRequestSent({required String email}) =
      _PasswordResetRequestSent;

  /// Password reset email/OTP sent successfully.
  const factory AuthState.passwordResetSent({required String token}) =
      _PasswordResetSent;

  /// Password successfully reset. Show login with success banner.
  const factory AuthState.passwordResetSuccess() = _PasswordResetSuccess;

  // In auth_state.dart (inside @freezed)
  const factory AuthState.onboardingUploading({
    required double progress, // 0.0 to 1.0
    required String message,
  }) = _OnboardingUploading;

  /// A known account's session has expired.
  /// [displayName] allows showing "Your session for Amara has expired."
  /// rather than a generic message.
  const factory AuthState.sessionExpiredForAccount({
    String? userId,
    String? displayName,
  }) = _SessionExpiredForAccount;

  /// Any auth operation failed.
  const factory AuthState.error(String message) = _Error;
}
