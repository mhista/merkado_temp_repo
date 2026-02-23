
/// AuthRepository
/// ==============
/// Contract for all authentication data operations.
/// The domain layer depends only on this interface — never on the implementation.
///
/// SCOPE: Authentication only. This repository does NOT fetch user profiles.
/// Profile loading is the responsibility of the consuming app's own data layer.
/// The auth system only handles: credentials, tokens, session lifecycle,
/// OTP verification, password reset, onboarding completion, and social login.
abstract interface class AuthRepository {
  /// Register a new user with email and password.
  ///
  /// Response includes tokens (issued immediately, before verification),
  /// [verified: false], and [onboardingCompleted: false].
  Future<Result<Map<String, dynamic>>> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> deviceInfo,
  });

  /// Verify email OTP after signup.
  ///
  /// Response: { message: "Email verified successfully" }
  /// No tokens returned — tokens were already issued during signup.
  Future<Result<Map<String, dynamic>>> verifyEmail({
    required String email,
    required String otp,
  });

  /// Resend OTP to the given email.
  ///
  /// Response: { message: "OK" }
  Future<Result<Map<String, dynamic>>> resendOtp({required String email});

  /// Login with email and password.
  ///
  /// Response includes tokens, [verified], [onboarded], [onboardingCompleted].
  Future<Result<Map<String, dynamic>>> login({
    required Map<String, dynamic> data,
  });

  /// Complete the onboarding step after email verification.
  ///
  /// Collects firstName, lastName, country, avatarUrl.
  /// Called at POST /onboarding/complete.
  /// This is the final step before the user is considered fully authenticated.
  Future<Result<Map<String, dynamic>>> completeOnboarding({
    required String firstName,
    required String lastName,
    required String country,
    required String phone,
    String? avatarUrl,
  });

  /// Logout and invalidate the session on the backend.
  Future<Result<void>> logout({required String sessionId});

  /// Request a password reset email.
  Future<Result<Map<String, dynamic>>> forgotPassword({required String email});

  /// Reset password using the token from the reset email.
  Future<Result<Map<String, dynamic>>> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Verify a 2FA OTP when backend returns [isMfa: true] on login.
  Future<Result<Map<String, dynamic>>> verifyTwoFactor({
    required String userId,
    required String otp,
  });

  /// Exchange a shared refresh token for a product-scoped access token.
  /// Called during cross-app SSO account picker selection.
  Future<Result<Map<String, dynamic>>> exchangeRefreshToken({
    required String refreshToken,
    required String platformId,
    required List<String> scopes,
  });

  /// Sign in or register via Google.
  ///
  /// [idToken] is obtained from the native Google Sign-In SDK.
  /// Backend creates or retrieves the account and returns the same
  /// response shape as [login].
  Future<Result<Map<String, dynamic>>> signInWithGoogle({
    required String idToken,
    required Map<String, dynamic> deviceInfo,
  });

  /// Sign in or register via Apple.
  ///
  /// [identityToken] and [authorizationCode] are obtained from the
  /// native Apple Sign In SDK (sign_in_with_apple package).
  /// Backend creates or retrieves the account and returns the same
  /// response shape as [login].
  Future<Result<Map<String, dynamic>>> signInWithApple({
    required String identityToken,
    required String authorizationCode,
    String? firstName,
    String? lastName,
    required Map<String, dynamic> deviceInfo,
  });
}

// ══════════════════════════════════════════════════════════════
// Result<T> — Generic sealed result wrapper
// ══════════════════════════════════════════════════════════════

/// Generic Result wrapper matching the pattern used across the codebase.
/// Success carries a value; failure carries an error message and optional exception.
sealed class Result<T> {
  const Result();

  factory Result.success(T value) = _Success<T>;
  factory Result.failure(String message, [Exception? exception]) = _Failure<T>;

  void when({
    required void Function(T value) success,
    required void Function(String error, Exception? exception) failure,
  }) {
    switch (this) {
      case _Success<T>(:final value):
        success(value);
      case _Failure<T>(:final message, :final exception):
        failure(message, exception);
    }
  }

  R map<R>({
    required R Function(T value) success,
    required R Function(String error, Exception? exception) failure,
  }) {
    switch (this) {
      case _Success<T>(:final value):
        return success(value);
      case _Failure<T>(:final message, :final exception):
        return failure(message, exception);
    }
  }
}

final class _Success<T> extends Result<T> {
  final T value;
  const _Success(this.value);
}

final class _Failure<T> extends Result<T> {
  final String message;
  final Exception? exception;
  const _Failure(this.message, [this.exception]);
}