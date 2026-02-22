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

  AuthRepositoryImpl({required this.authRemoteDatasource});

  /// POST /auth/register
  @override
  Future<Result<Map<String, dynamic>>> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> deviceInfo,
  }) async {
    try {
      final result = await authRemoteDatasource.signUp(
        email: email,
        password: password,
        deviceInfo: deviceInfo,
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// POST /auth/verify-email
  @override
  Future<Result<Map<String, dynamic>>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final result =
          await authRemoteDatasource.verifyEmail(email: email, otp: otp);
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// POST /auth/resend-otp
  @override
  Future<Result<Map<String, dynamic>>> resendOtp({
    required String email,
  }) async {
    try {
      final result = await authRemoteDatasource.resendOtp(email: email);
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// POST /auth/login
  @override
  Future<Result<Map<String, dynamic>>> login({
    required Map<String, dynamic> data,
  }) async {
    try {
      final result = await authRemoteDatasource.login(data: data);
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// POST /auth/logout
  @override
  Future<Result<void>> logout({required String sessionId}) async {
    try {
      await authRemoteDatasource.logout(sessionId: sessionId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// POST /auth/forgot-password
  @override
  Future<Result<Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    try {
      final result = await authRemoteDatasource.forgotPassword(email: email);
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// POST /auth/reset-password
  @override
  Future<Result<Map<String, dynamic>>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final result = await authRemoteDatasource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// POST /auth/verify-2fa
  @override
  Future<Result<Map<String, dynamic>>> verifyTwoFactor({
    required String userId,
    required String otp,
  }) async {
    try {
      final result = await authRemoteDatasource.verifyTwoFactor(
        userId: userId,
        otp: otp,
      );
      return Result.success(result);
    } catch (e) {
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
    try {
      final result = await authRemoteDatasource.exchangeRefreshToken(
        refreshToken: refreshToken,
        platformId: platformId,
        scopes: scopes,
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// POST /auth/social/google
  @override
  Future<Result<Map<String, dynamic>>> signInWithGoogle({
    required String idToken,
    required Map<String, dynamic> deviceInfo,
  }) async {
    try {
      final result = await authRemoteDatasource.loginWithGoogle(
        idToken: idToken,
        deviceInfo: deviceInfo,
      );
      return Result.success(result);
    } catch (e) {
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
    try {
      final result = await authRemoteDatasource.loginWithApple(
        identityToken: identityToken,
        authorizationCode: authorizationCode,
        firstName: firstName,
        lastName: lastName,
        deviceInfo: deviceInfo,
      );
      return Result.success(result);
    } catch (e) {
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
    String? avatarUrl,
  }) async {
    try {
      final result = await authRemoteDatasource.completeOnboarding(data: {
        'firstName': firstName,
        'lastName': lastName,
        'country': country,
        'avatarUrl': ?avatarUrl,
      });
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}