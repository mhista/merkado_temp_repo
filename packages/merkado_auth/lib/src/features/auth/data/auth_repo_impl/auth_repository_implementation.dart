import 'package:common_utils2/common_utils2.dart' hide User, Result;
import 'package:injectable/injectable.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

/// AuthRepositoryImpl
/// ==================
/// Concrete implementation of [AuthRepository].
/// Bridges the datasource (HTTP) to the domain layer using [Result] wrapping.
/// Follows your existing try/catch-at-the-boundary pattern exactly.
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource authRemoteDatasource;
  final LoggerService? _log;

  AuthRepositoryImpl({
    required this.authRemoteDatasource,
    LoggerService? logger,
  }) : _log = logger;

  /// POST /auth/register
  @override
  Future<Result<Map<String, dynamic>>> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> deviceInfo,
  }) async {
    _log?.debug('[AuthRepo] signUp — $email');
    try {
      final result = await authRemoteDatasource.signUp(
        email: email,
        password: password,
        deviceInfo: deviceInfo,
      );
      _log?.info('[AuthRepo] signUp success — $email');
      return Result.success(result);
    } catch (e, st) {
      _log?.error('[AuthRepo] signUp failed — $email', e, st);
      return Result.failure(e.toString());
    }
  }

  /// POST /auth/verify-email
  @override
  Future<Result<Map<String, dynamic>>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    _log?.debug('[AuthRepo] verifyEmail — $email');
    try {
      final result = await authRemoteDatasource.verifyEmail(
        email: email,
        otp: otp,
      );
      _log?.info('[AuthRepo] verifyEmail success — $email');
      return Result.success(result);
    } catch (e, st) {
      _log?.error('[AuthRepo] verifyEmail failed — $email', e, st);
      return Result.failure(e.toString());
    }
  }

  /// POST /auth/resend-otp
  @override
  Future<Result<Map<String, dynamic>>> resendOtp({
    required String email,
  }) async {
    _log?.debug('[AuthRepo] resendOtp — $email');
    try {
      final result = await authRemoteDatasource.resendOtp(email: email);
      _log?.info('[AuthRepo] resendOtp success — $email');
      return Result.success(result);
    } catch (e, st) {
      _log?.error('[AuthRepo] resendOtp failed — $email', e, st);
      return Result.failure(e.toString());
    }
  }

  /// POST /auth/login
  @override
  Future<Result<Map<String, dynamic>>> login({
    required Map<String, dynamic> data,
  }) async {
    _log?.debug('[AuthRepo] login — ${data['email']}');
    try {
      final result = await authRemoteDatasource.login(data: data);
      _log?.info('[AuthRepo] login success');
      return Result.success(result);
    } catch (e, st) {
      _log?.error('[AuthRepo] login failed', e, st);
      return Result.failure(e.toString());
    }
  }

  /// POST /auth/logout
  @override
  Future<Result<void>> logout({required String sessionId}) async {
    _log?.debug('[AuthRepo] logout — sessionId: $sessionId');
    try {
      await authRemoteDatasource.logout(sessionId: sessionId);
      _log?.info('[AuthRepo] logout success');
      return Result.success(null);
    } catch (e, st) {
      _log?.warning('[AuthRepo] logout failed (non-critical)', e, st);
      return Result.failure(e.toString());
    }
  }

  /// POST /auth/forgot-password
  // @override
  // Future<Result<Map<String, dynamic>>> forgotPassword({
  //   required String email,
  // }) async {
  //   _log?.debug('[AuthRepo] forgotPassword — $email');
  //   try {
  //     final result = await authRemoteDatasource.forgotPassword(email: email);
  //     _log?.info('[AuthRepo] forgotPassword success — $email');
  //     return Result.success(result);
  //   } catch (e, st) {
  //     _log?.error('[AuthRepo] forgotPassword failed', e, st);
  //     return Result.failure(e.toString());
  //   }
  // }

  /// POST /auth/password-reset/request
  @override
  Future<Result<Map<String, dynamic>>> requestPasswordReset({
    required String email,
  }) async {
    _log?.debug('[AuthRepo] resetPassword');
    try {
      final result = await authRemoteDatasource.requestPasswordReset(
        email: email,
      );
      _log?.info('[AuthRepo] reset password reset success');
      return Result.success(result);
    } catch (e, st) {
      _log?.error('[AuthRepo] reset password reset failed', e, st);
      return Result.failure(e.toString());
    }
  }

  /// POST /auth/password-reset/verify-otp

  @override
  Future<Result<Map<String, dynamic>>> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    _log?.debug('[AuthRepo] resetPassword');
    try {
      final result = await authRemoteDatasource.verifyPasswordResetOtp(
        otp: otp,
        email: email,
      );
      _log?.info('[AuthRepo] Verify password reset success');
      return Result.success(result);
    } catch (e, st) {
      _log?.error('[AuthRepo] Verify password reset failed', e, st);
      return Result.failure(e.toString());
    }
  }

  /// POST /auth/password-reset/reset
  @override
  Future<Result<Map<String, dynamic>>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _log?.debug('[AuthRepo] resetPassword');
    try {
      final result = await authRemoteDatasource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      _log?.info('[AuthRepo] resetPassword success');
      return Result.success(result);
    } catch (e, st) {
      _log?.error('[AuthRepo] resetPassword failed', e, st);
      return Result.failure(e.toString());
    }
  }

  /// POST /auth/verify-2fa
  @override
  Future<Result<Map<String, dynamic>>> verifyTwoFactor({
    required String userId,
    required String otp,
  }) async {
    _log?.debug('[AuthRepo] verifyTwoFactor — userId: $userId');
    try {
      final result = await authRemoteDatasource.verifyTwoFactor(
        userId: userId,
        otp: otp,
      );
      _log?.info('[AuthRepo] verifyTwoFactor success');
      return Result.success(result);
    } catch (e, st) {
      _log?.error('[AuthRepo] verifyTwoFactor failed', e, st);
      return Result.failure(e.toString());
    }
  }

  /// POST /auth/refresh
  @override
  Future<Result<Map<String, dynamic>>> exchangeRefreshToken({
    required String refreshToken,
    required String platformId,
    required List<String> scopes,
  }) async {
    _log?.debug('[AuthRepo] exchangeRefreshToken — platformId: $platformId');
    try {
      final result = await authRemoteDatasource.exchangeRefreshToken(
        refreshToken: refreshToken,
        platformId: platformId,
        scopes: scopes,
      );
      _log?.info('[AuthRepo] exchangeRefreshToken success');
      return Result.success(result);
    } catch (e, st) {
      _log?.error('[AuthRepo] exchangeRefreshToken failed', e, st);
      return Result.failure(e.toString());
    }
  }

  /// POST /auth/social/google
  @override
  Future<Result<Map<String, dynamic>>> signInWithGoogle({
    required String idToken,
    required Map<String, dynamic> deviceInfo,
  }) async {
    _log?.debug('[AuthRepo] signInWithGoogle');
    try {
      final result = await authRemoteDatasource.loginWithGoogle(
        idToken: idToken,
        deviceInfo: deviceInfo,
      );
      _log?.info('[AuthRepo] signInWithGoogle success');
      return Result.success(result);
    } catch (e, st) {
      _log?.error('[AuthRepo] signInWithGoogle failed', e, st);
      return Result.failure(e.toString());
    }
  }

  /// POST /auth/social/apple
  @override
  Future<Result<Map<String, dynamic>>> signInWithApple({
    required String identityToken,
    required String authorizationCode,
    String? firstName,
    String? lastName,
    required Map<String, dynamic> deviceInfo,
  }) async {
    _log?.debug('[AuthRepo] signInWithApple');
    try {
      final result = await authRemoteDatasource.loginWithApple(
        identityToken: identityToken,
        authorizationCode: authorizationCode,
        firstName: firstName,
        lastName: lastName,
        deviceInfo: deviceInfo,
      );
      _log?.info('[AuthRepo] signInWithApple success');
      return Result.success(result);
    } catch (e, st) {
      _log?.error('[AuthRepo] signInWithApple failed', e, st);
      return Result.failure(e.toString());
    }
  }

  /// POST /onboarding/complete
  /// Builds [data] map from individual fields and passes to datasource.
  @override
  Future<Result<Map<String, dynamic>>> completeOnboarding({
    required String firstName,
    required String lastName,
    required String country,
    required String phone,
    String? avatarUrl,
  }) async {
    _log?.debug(
      '[AuthRepo] completeOnboarding — $firstName $lastName, country: $country, phone: $phone',
    );
    try {
      final result = await authRemoteDatasource.completeOnboarding(
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'country': country,
          'phone': phone,
          if (avatarUrl != null) 'avatarUrl': avatarUrl,
        },
      );
      _log?.info('[AuthRepo] completeOnboarding success');
      return Result.success(result);
    } catch (e, st) {
      _log?.error('[AuthRepo] completeOnboarding failed', e, st);
      return Result.failure(e.toString());
    }
  }
}
