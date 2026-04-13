import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

// ── Sign Up ────────────────────────────────────────────────────────────────

@lazySingleton
class SignUpUseCase {
  final AuthRepository _repository;
  SignUpUseCase(this._repository);

  Future<Result<Map<String, dynamic>>> call({
    required String email,
    required String password,
    required Map<String, dynamic> deviceInfo,
  }) async {
    return await _repository.signUp(
      email: email,
      password: password,
      deviceInfo: deviceInfo,
    );
  }
}

// ── Login ──────────────────────────────────────────────────────────────────

@lazySingleton
class LoginUseCase {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  Future<Result<Map<String, dynamic>>> call({
    required Map<String, dynamic> data,
  }) async {
    return await _repository.login(data: data);
  }
}

// ── OTP Verification ───────────────────────────────────────────────────────

@lazySingleton
class VerifyEmailUseCase {
  final AuthRepository _repository;
  VerifyEmailUseCase(this._repository);

  Future<Result<Map<String, dynamic>>> call({
    required String email,
    required String otp,
    required String platformId,
  }) async {
    return await _repository.verifyEmail(
      email: email,
      otp: otp,
      platformId: platformId,
    );
  }
}

@lazySingleton
class ResendOtpUseCase {
  final AuthRepository _repository;
  ResendOtpUseCase(this._repository);

  Future<Result<Map<String, dynamic>>> call({
    required String email,

    required String platformId,
  }) async {
    return await _repository.resendOtp(email: email, platformId: platformId);
  }
}

// ── Onboarding ─────────────────────────────────────────────────────────────

/// Completes the onboarding step after email verification.
///
/// This is the final step in the signup flow. Only after this succeeds
/// should [_persistSession] be called and the user considered authenticated.
/// Collects firstName, lastName, country, and optional avatarUrl.
@lazySingleton
class CompleteOnboardingUseCase {
  final AuthRepository _repository;
  CompleteOnboardingUseCase(this._repository);

  Future<Result<Map<String, dynamic>>> call({
    required String firstName,
    required String lastName,
    required String country,
    required String platformId,
    required String phone,
    String? avatarUrl,
  }) async {
    return await _repository.completeOnboarding(
      firstName: firstName,
      lastName: lastName,
      country: country,
      platformId: platformId,
      phone: phone,
      avatarUrl: avatarUrl,
    );
  }
}

// ── Password Reset ─────────────────────────────────────────────────────────

@lazySingleton
class RequestPasswordResetUseCase {
  final AuthRepository _repository;
  RequestPasswordResetUseCase(this._repository);

  Future<Result<Map<String, dynamic>>> call({
    required String email,
    required String platformId,
  }) async {
    return await _repository.requestPasswordReset(
      email: email,
      platformId: platformId,
    );
  }
}

@lazySingleton
class VerifyPasswordResetUseCase {
  final AuthRepository _repository;
  VerifyPasswordResetUseCase(this._repository);

  Future<Result<Map<String, dynamic>>> call({
    required String email,
    required String otp,
    required String platformId,
  }) async {
    return await _repository.verifyPasswordResetOtp(
      email: email,
      otp: otp,
      platformId: platformId,
    );
  }
}

@lazySingleton
class ResetPasswordUseCase {
  final AuthRepository _repository;
  ResetPasswordUseCase(this._repository);

  Future<Result<Map<String, dynamic>>> call({
    required String token,
    required String newPassword,
    required String platformId,
  }) async {
    return await _repository.resetPassword(
      token: token,
      newPassword: newPassword,
      platformId: platformId,
    );
  }
}

// ── 2FA ────────────────────────────────────────────────────────────────────

@lazySingleton
class VerifyTwoFactorUseCase {
  final AuthRepository _repository;
  VerifyTwoFactorUseCase(this._repository);

  Future<Result<Map<String, dynamic>>> call({
    required String userId,
    required String otp,
    required String platformId,
  }) async {
    return await _repository.verifyTwoFactor(
      userId: userId,
      otp: otp,
      platformId: platformId,
    );
  }
}

// ── Logout ─────────────────────────────────────────────────────────────────

@lazySingleton
class LogoutUseCase {
  final AuthRepository _repository;
  LogoutUseCase(this._repository);

  Future<Result<void>> call({required String sessionId}) async {
    return await _repository.logout(sessionId: sessionId);
  }
}

// ── Cross-App SSO ──────────────────────────────────────────────────────────

/// Exchanges a shared refresh token for a product-scoped access token.
/// Called when user taps a known account in the account picker.
@lazySingleton
class ExchangeRefreshTokenUseCase {
  final AuthRepository _repository;
  ExchangeRefreshTokenUseCase(this._repository);

  Future<Result<Map<String, dynamic>>> call({
    required String refreshToken,
    required String platformId,
    required List<String> scopes,
  }) async {
    return await _repository.exchangeRefreshToken(
      refreshToken: refreshToken,
      platformId: platformId,
      scopes: scopes,
    );
  }
}

// ── Social Login ───────────────────────────────────────────────────────────

/// Sign in or register via Google.
///
/// The consuming app is responsible for triggering the native Google Sign-In
/// flow and obtaining the [idToken]. This use case sends it to the backend
/// at POST /auth/social/google and handles the response the same way as login.
@lazySingleton
class SignInWithGoogleUseCase {
  final AuthRepository _repository;
  SignInWithGoogleUseCase(this._repository);

  Future<Result<Map<String, dynamic>>> call({
    required String idToken,
    required Map<String, dynamic> deviceInfo,
    required String platformId,
  }) async {
    return await _repository.signInWithGoogle(
      idToken: idToken,
      deviceInfo: deviceInfo,
      platformId: platformId,
    );
  }
}

/// Sign in or register via Apple.
///
/// The consuming app is responsible for triggering the native Apple Sign In
/// flow (via sign_in_with_apple package) and obtaining the tokens.
/// Apple only provides [firstName] and [lastName] on the FIRST sign-in —
/// cache them before calling this use case if needed.
@lazySingleton
class SignInWithAppleUseCase {
  final AuthRepository _repository;
  SignInWithAppleUseCase(this._repository);

  Future<Result<Map<String, dynamic>>> call({
    required String identityToken,
    required String authorizationCode,
    required String platformId,
    String? firstName,
    String? lastName,
    required Map<String, dynamic> deviceInfo,
  }) async {
    return await _repository.signInWithApple(
      identityToken: identityToken,
      authorizationCode: authorizationCode,
      firstName: firstName,
      lastName: lastName,
      deviceInfo: deviceInfo,
      platformId: platformId,
    );
  }
}
