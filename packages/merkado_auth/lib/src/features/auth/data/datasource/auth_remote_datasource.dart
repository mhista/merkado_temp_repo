import 'package:common_utils2/common_utils2.dart';

/// AuthRemoteDatasource
/// ====================
/// Abstract interface — all remote auth API calls.
/// All methods throw on failure. The repository layer catches and wraps into Result[T].
abstract interface class AuthRemoteDatasource {
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> deviceInfo,
  });

  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otp,
  });

  Future<Map<String, dynamic>> resendOtp({required String email});

  Future<Map<String, dynamic>> login({required Map<String, dynamic> data});

  Future<String> logout({required String sessionId});

  Future<Map<String, dynamic>> forgotPassword({required String email});

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<Map<String, dynamic>> verifyTwoFactor({
    required String userId,
    required String otp,
  });

  Future<Map<String, dynamic>> exchangeRefreshToken({
    required String refreshToken,
    required String platformId,
    required List<String> scopes,
  });

  Future<Map<String, dynamic>> loginWithGoogle({
    required String idToken,
    required Map<String, dynamic> deviceInfo,
  });

  Future<Map<String, dynamic>> loginWithApple({
    required String identityToken,
    required String authorizationCode,
    String? firstName,
    String? lastName,
    required Map<String, dynamic> deviceInfo,
  });

  Future<Map<String, dynamic>> completeOnboarding({
    required Map<String, dynamic> data,
  });
}

/// AuthRemoteDatasourceImpl
/// ========================
/// Concrete HTTP implementation using [HttpClient] from common_utils2.
/// Logs every request and response via the injected [LoggerService].
/// The logger is optional — if null, all logging is silently skipped.
class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final HttpClient _http = HttpClient.instance;
  final LoggerService? _log;

  AuthRemoteDatasourceImpl({LoggerService? logger}) : _log = logger;

  // ── POST /auth/register ───────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> deviceInfo,
  }) async {
    _log?.info('[AuthDatasource] POST /auth/register — $email $deviceInfo');
    try {
      final result = await _http.post('/auth/register', data: {
        'email': email,
        'password': password,
        // ...deviceInfo,
      });

      if (_isSuccess(result.statusCode)) {
        _log?.debug('[AuthDatasource] /auth/register ✅ ${result.statusCode}');
        return result.data;
      }
      _log?.error('[AuthDatasource] /auth/register ❌ ${result.statusCode} — ${result.message}');
      throw Exception('Sign up failed: ${result.message}');
    } catch (e, st) {
      _log?.error('[AuthDatasource] /auth/register threw', e, st);
      rethrow;
    }
  }

  // ── POST /auth/verify-email ───────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    _log?.info('[AuthDatasource] POST /auth/verify-email — $email');
    try {
      // _http.
      final result = await _http.post('/auth/verify-email', data: {
        // 'email': email,
        'code': otp,
      });

      if (_isSuccess(result.statusCode)) {
        _log?.debug('[AuthDatasource] /auth/verify-email ✅');
        return result.data;
      }
      _log?.error('[AuthDatasource] /auth/verify-email ❌ ${result.statusCode}');
      throw Exception('Email verification failed: ${result.message}');
    } catch (e, st) {
      _log?.error('[AuthDatasource] /auth/verify-email threw', e, st);
      rethrow;
    }
  }

  // ── POST /auth/resend-otp ─────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> resendOtp({required String email}) async {
    _log?.info('[AuthDatasource] POST /auth/resend-otp — $email');
    try {
      final result = await _http.post('/auth/resend-otp', data: {});

      if (_isSuccess(result.statusCode)) {
        _log?.debug('[AuthDatasource] /auth/resend-otp ✅');
        return result.data;
      }
      _log?.error('[AuthDatasource] /auth/resend-otp ❌ ${result.statusCode}');
      throw Exception('Resend OTP failed: ${result.message}');
    } catch (e, st) {
      _log?.error('[AuthDatasource] /auth/resend-otp threw', e, st);
      rethrow;
    }
  }

  // ── POST /auth/login ──────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> login({required Map<String, dynamic> data}) async {
    final email = data['email'] ?? 'unknown';
    _log?.info('[AuthDatasource] POST /auth/login — $email');
    try {
      final result = await _http.post('/auth/login', data: data);

      if (_isSuccess(result.statusCode)) {
        _log?.debug('[AuthDatasource] /auth/login ✅ ${result.statusCode}');
        return result.data;
      }
      _log?.error('[AuthDatasource] /auth/login ❌ ${result.statusCode} — ${result.message}');
      throw Exception('Login failed: ${result.message}');
    } catch (e, st) {
      _log?.error('[AuthDatasource] /auth/login threw', e, st);
      rethrow;
    }
  }

  // ── POST /auth/logout ─────────────────────────────────────────────────────

  @override
  Future<String> logout({required String sessionId}) async {
    _log?.info('[AuthDatasource] POST /auth/logout — sessionId: $sessionId');
    try {
      final result = await _http.post('/auth/logout', data: {'sessionId': sessionId});

      if (_isSuccess(result.statusCode)) {
        _log?.debug('[AuthDatasource] /auth/logout ✅');
        return 'Logout successful';
      }
      _log?.warning('[AuthDatasource] /auth/logout returned ${result.statusCode} — treating as success');
      return 'Logout completed';
    } catch (e, st) {
      // Logout errors are non-critical — storage is cleared regardless.
      // Log as warning rather than error so it doesn't trigger alerts.
      _log?.warning('[AuthDatasource] /auth/logout threw (non-critical)', e, st);
      return 'Logout completed with remote error';
    }
  }

  // ── POST /auth/forgot-password ────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    _log?.info('[AuthDatasource] POST /auth/forgot-password — $email');
    try {
      final result = await _http.post('/auth/forgot-password', data: {'email': email});

      if (_isSuccess(result.statusCode)) {
        _log?.debug('[AuthDatasource] /auth/forgot-password ✅');
        return result.data;
      }
      _log?.error('[AuthDatasource] /auth/forgot-password ❌ ${result.statusCode}');
      throw Exception('Forgot password failed: ${result.message}');
    } catch (e, st) {
      _log?.error('[AuthDatasource] /auth/forgot-password threw', e, st);
      rethrow;
    }
  }

  // ── POST /auth/reset-password ─────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _log?.info('[AuthDatasource] POST /auth/reset-password');
    try {
      final result = await _http.post('/auth/reset-password', data: {
        'token': token,
        'password': newPassword,
      });

      if (_isSuccess(result.statusCode)) {
        _log?.debug('[AuthDatasource] /auth/reset-password ✅');
        return result.data;
      }
      _log?.error('[AuthDatasource] /auth/reset-password ❌ ${result.statusCode}');
      throw Exception('Reset password failed: ${result.message}');
    } catch (e, st) {
      _log?.error('[AuthDatasource] /auth/reset-password threw', e, st);
      rethrow;
    }
  }

  // ── POST /auth/verify-2fa ─────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> verifyTwoFactor({
    required String userId,
    required String otp,
  }) async {
    _log?.info('[AuthDatasource] POST /auth/verify-2fa — userId: $userId');
    try {
      final result = await _http.post('/auth/verify-2fa', data: {
        'userId': userId,
        'otp': otp,
      });

      if (_isSuccess(result.statusCode)) {
        _log?.debug('[AuthDatasource] /auth/verify-2fa ✅');
        return result.data;
      }
      _log?.error('[AuthDatasource] /auth/verify-2fa ❌ ${result.statusCode}');
      throw Exception('2FA verification failed: ${result.message}');
    } catch (e, st) {
      _log?.error('[AuthDatasource] /auth/verify-2fa threw', e, st);
      rethrow;
    }
  }

  // ── POST /auth/refresh ────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> exchangeRefreshToken({
    required String refreshToken,
    required String platformId,
    required List<String> scopes,
  }) async {
    _log?.info('[AuthDatasource] POST /auth/refresh — platformId: $platformId');
    try {
      final result = await _http.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
        'platformId': platformId,
        'scopes': scopes,
      });

      if (_isSuccess(result.statusCode)) {
        _log?.debug('[AuthDatasource] /auth/refresh ✅');
        return result.data;
      }
      _log?.error('[AuthDatasource] /auth/refresh ❌ ${result.statusCode}');
      throw Exception('Token refresh failed: ${result.message}');
    } catch (e, st) {
      _log?.error('[AuthDatasource] /auth/refresh threw', e, st);
      rethrow;
    }
  }

  // ── POST /auth/social/google ──────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> loginWithGoogle({
    required String idToken,
    required Map<String, dynamic> deviceInfo,
  }) async {
    _log?.info('[AuthDatasource] POST /auth/social/google');
    try {
      final result = await _http.post('/auth/social/google', data: {
        'idToken': idToken,
        ...deviceInfo,
      });

      if (_isSuccess(result.statusCode)) {
        _log?.debug('[AuthDatasource] /auth/social/google ✅');
        return result.data;
      }
      _log?.error('[AuthDatasource] /auth/social/google ❌ ${result.statusCode}');
      throw Exception('Google sign in failed: ${result.message}');
    } catch (e, st) {
      _log?.error('[AuthDatasource] /auth/social/google threw', e, st);
      rethrow;
    }
  }

  // ── POST /auth/social/apple ───────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> loginWithApple({
    required String identityToken,
    required String authorizationCode,
    String? firstName,
    String? lastName,
    required Map<String, dynamic> deviceInfo,
  }) async {
    _log?.info('[AuthDatasource] POST /auth/social/apple');
    try {
      final result = await _http.post('/auth/social/apple', data: {
        'identityToken': identityToken,
        'authorizationCode': authorizationCode,
        'firstName': ?firstName,
        'lastName': ?lastName,
        ...deviceInfo,
      });

      if (_isSuccess(result.statusCode)) {
        _log?.debug('[AuthDatasource] /auth/social/apple ✅');
        return result.data;
      }
      _log?.error('[AuthDatasource] /auth/social/apple ❌ ${result.statusCode}');
      throw Exception('Apple sign in failed: ${result.message}');
    } catch (e, st) {
      _log?.error('[AuthDatasource] /auth/social/apple threw', e, st);
      rethrow;
    }
  }

  // ── POST /onboarding/complete ─────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> completeOnboarding({
    required Map<String, dynamic> data,
  }) async {
    _log?.info('[AuthDatasource] POST /onboarding/complete');
    try {
      final result = await _http.post('/onboarding/complete', data: data);

      if (_isSuccess(result.statusCode)) {
        _log?.debug('[AuthDatasource] /onboarding/complete ✅');
        return result.data;
      }
      _log?.error('[AuthDatasource] /onboarding/complete ❌ ${result.statusCode}');
      throw Exception('Onboarding failed: ${result.message}');
    } catch (e, st) {
      _log?.error('[AuthDatasource] /onboarding/complete threw', e, st);
      rethrow;
    }
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  bool _isSuccess(int? statusCode) {
    final code = statusCode ?? 404;
    return code >= 200 && code < 300;
  }
}