/// AuthStorageKeys
/// ===============
/// Secure storage key constants that are private to the merkado_auth package.
///
/// These keys are INTENTIONALLY separate from [StorageKeys] in common_utils.
/// Reason: common_utils is a general utility package. Auth flow state,
/// token management, and SSO session data are auth domain concerns —
/// they don't belong in a shared utility layer.
///
/// CROSS-APP KEYS: Some keys here must be IDENTICAL across all Grascope apps
/// (the SSO keys under the shared keychain group). These are documented below.
///
/// RULE: Never rename a key after shipping. Write a migration instead.
class AuthStorageKeys {
  AuthStorageKeys._();

  // ── Cross-app shared keys ─────────────────────────────────────────────────
  // Stored in shared keychain group (iOS: com.grascope.sharedauth) or
  // shared encrypted prefs (Android: same signing keystore required).
  // ALL Grascope apps read these to power cross-app SSO account detection.
  // merkado_auth writes these. Apps must not write to them directly.

  /// JSON list of [GrascopeSessionHint] objects — one entry per known account.
  /// This is the SSO account list read by the account picker on startup.
  static const String knownAccounts = 'grascope_known_accounts';

  /// The userId of the account currently active in THIS specific app.
  /// Each Grascope app maintains its own active account independently.
  static const String activeUserId = 'grascope_active_user_id';

  // ── Per-app local token keys ──────────────────────────────────────────────
  // Stored in this app's private local secure storage.
  // Never visible to other Grascope apps.

  /// Short-lived access token scoped to this platform (expires ~900s).
  /// Re-issued via refresh token when expired.
  static const String accessToken = 'merkado_access_token';

  /// Unix timestamp (ms) of when the access token expires.
  /// Stored to avoid JWT decoding on every startup check.
  static const String accessTokenExpiresAt = 'merkado_access_token_expires_at';

  /// Long-lived refresh token. Used to issue new access tokens.
  /// Also stored inside [knownAccounts] for cross-app SSO token exchange.
  static const String refreshToken = 'merkado_refresh_token';

  /// Backend session ID. Sent to /auth/logout to invalidate the server-side session.
  static const String sessionId = 'merkado_session_id';

  // ── Incomplete flow resumption keys ──────────────────────────────────────
  // These are what make terminated-state resumption work.
  // They track exactly where the user is in the auth flow so that if the
  // app is killed mid-signup, the correct screen is shown on relaunch.
  //
  // Flow checkpoints:
  //   signup done     → accessToken saved, isEmailVerified=false
  //   OTP verified    → isEmailVerified=true, isOnboardingCompleted=false
  //   onboarding done → isOnboardingCompleted=true → fully authenticated

  /// Whether the current account's email has been OTP-verified.
  /// false = show OTP screen on relaunch.
  static const String isEmailVerified = 'merkado_is_email_verified';

  /// Whether the user has completed the onboarding profile step.
  /// false = show onboarding screen on relaunch.
  static const String isOnboardingCompleted = 'merkado_onboarding_completed';

  /// Email address pending OTP verification.
  /// Saved immediately after signup so the OTP screen can be pre-filled
  /// if the app is terminated before the user verifies.
  static const String pendingVerificationEmail =
      'merkado_pending_verification_email';

  // ── Biometric auth keys ───────────────────────────────────────────────────

  /// Whether biometric login is enrolled for this app on this device.
  /// Separate from the UI preference flag in common_utils StorageKeys.
  static const String biometricsEnrolled = 'merkado_biometrics_enrolled';

  /// The userId for whom biometrics is enrolled.
  static const String biometricUserId = 'merkado_biometric_user_id';
}