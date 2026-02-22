/// AuthFeatures
/// ============
/// Controls which authentication screens and capabilities are active
/// for a given platform. Pass this inside [MerkadoAuthConfig] to
/// enable or disable features per app without touching the package.
///
/// EXAMPLE — enable only login, signup, and OTP for MyCut:
/// ```dart
/// AuthFeatures(
///   emailOtpVerification: true,
///   forgotPassword: true,
///   resetPassword: true,
///   twoFactorAuth: false,
///   biometrics: false,
///   crossAppSso: true,
/// )
/// ```
class AuthFeatures {
  /// Show OTP email verification screen after signup.
  /// Default: true
  final bool emailOtpVerification;

  /// Show "Forgot Password" link on login screen and its flow.
  /// Default: true
  final bool forgotPassword;

  /// Allow user to reset password via email link/OTP.
  /// Default: true
  final bool resetPassword;

  /// Enable 2FA screen when backend returns [isMfa: true].
  /// Default: false
  final bool twoFactorAuth;

  /// Enable biometric (Face ID / Fingerprint) login on subsequent opens.
  /// Requires device support — package checks capability at runtime.
  /// Default: false
  final bool biometrics;

  /// Detect existing Grascope accounts from other apps on device and
  /// show the account picker / "Continue as [name]" prompt.
  /// Default: true
  final bool crossAppSso;

  /// Show "Resend OTP" button on the OTP screen.
  /// Default: true
  final bool resendOtp;

  /// Allow social login providers (Google, Apple).
  /// Individual providers are toggled via [socialProviders].
  /// Default: false
  final bool socialLogin;

  /// Which social providers to show when [socialLogin] is true.
  final Set<SocialProvider> socialProviders;

  const AuthFeatures({
    this.emailOtpVerification = true,
    this.forgotPassword = true,
    this.resetPassword = true,
    this.twoFactorAuth = false,
    this.biometrics = false,
    this.crossAppSso = true,
    this.resendOtp = true,
    this.socialLogin = false,
    this.socialProviders = const {},
  });

  /// Convenience preset — bare minimum (login + signup only).
  const AuthFeatures.minimal()
      : emailOtpVerification = false,
        forgotPassword = false,
        resetPassword = false,
        twoFactorAuth = false,
        biometrics = false,
        crossAppSso = true,
        resendOtp = false,
        socialLogin = false,
        socialProviders = const {};

  /// Convenience preset — all features enabled.
  const AuthFeatures.full()
      : emailOtpVerification = true,
        forgotPassword = true,
        resetPassword = true,
        twoFactorAuth = true,
        biometrics = true,
        crossAppSso = true,
        resendOtp = true,
        socialLogin = true,
        socialProviders = const {SocialProvider.google, SocialProvider.apple};
}

/// Supported social login providers.
enum SocialProvider {
  google,
  apple,
}