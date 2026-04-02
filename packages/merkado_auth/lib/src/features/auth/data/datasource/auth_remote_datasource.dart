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

  // Future<Map<String, dynamic>> forgotPassword({required String email});

  Future<Map<String, dynamic>> requestPasswordReset({required String email});

  Future<Map<String, dynamic>> verifyPasswordResetOtp({
    required String email,
    required String otp,
  });

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
// auth_remote_datasource.dart — replace AuthRemoteDatasourceImpl

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final HttpClient _http = HttpClient.instance;
  final LoggerService? _log;

  /// The auth service base URL — switched to before every call, and
  /// restored to [_appBaseUrl] in the finally block after every call.
  final String _authBaseUrl;

  /// The main app API base URL — restored after every auth call so the
  /// rest of the app continues hitting the right server.
  final String _appBaseUrl;

  AuthRemoteDatasourceImpl({
    required String authBaseUrl, // ← NEW
    required String appBaseUrl, // ← NEW
    LoggerService? logger,
  }) : _authBaseUrl = authBaseUrl,
       _appBaseUrl = appBaseUrl,
       _log = logger;

  // ── URL-switching wrapper ─────────────────────────────────────────────────

  /// Switches to [_authBaseUrl], runs [call], then always restores [_appBaseUrl].
  /// This ensures the single HttpClient instance is always left pointing at
  /// the correct base URL regardless of success or failure.
  Future<T> _withAuthUrl<T>(Future<T> Function() call) async {
    _http.updateBaseUrl(_authBaseUrl);
    try {
      return await call();
    } finally {
      _http.updateBaseUrl(_appBaseUrl); 
    }
  }

  // ── POST /auth/register ───────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> deviceInfo,
  }) => _withAuthUrl(() async {
    _log?.info('[AuthDatasource] POST /auth/register — $email');
    final result = await _http.post(
      '/auth/register',
      data: {'email': email, 'password': password},
    );
    if (_isSuccess(result.statusCode)) return result.data;
    throw Exception('Sign up failed: ${result.message}');
  });

  // ── POST /auth/verify-email ───────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otp,
  }) => _withAuthUrl(() async {
    _log?.info('[AuthDatasource] POST /auth/verify-email — $email');
    final result = await _http.post('/auth/verify-email', data: {'code': otp});
    if (_isSuccess(result.statusCode)) return result.data;
    throw Exception('Email verification failed: ${result.message}');
  });

  // ── POST /auth/resend-otp ─────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> resendOtp({required String email}) =>
      _withAuthUrl(() async {
        _log?.info('[AuthDatasource] POST /auth/resend-otp — $email');
        final result = await _http.post('/auth/resend-otp', data: {});
        if (_isSuccess(result.statusCode)) return result.data;
        throw Exception('Resend OTP failed: ${result.message}');
      });

  // ── POST /auth/login ──────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> login({required Map<String, dynamic> data}) =>
      _withAuthUrl(() async {
        _log?.info('[AuthDatasource] POST /auth/login — ${data['email']}');
        final result = await _http.post('/auth/login', data: data);
        if (_isSuccess(result.statusCode)) return result.data;
        throw Exception('Login failed: ${result.message}');
      });

  // ── POST /auth/logout ─────────────────────────────────────────────────────

  @override
  Future<String> logout({required String sessionId}) => _withAuthUrl(() async {
    _log?.info('[AuthDatasource] POST /auth/logout — sessionId: $sessionId');
    try {
      final result = await _http.post(
        '/auth/logout',
        data: {'sessionId': sessionId},
      );
      if (_isSuccess(result.statusCode)) return 'Logout successful';
      return 'Logout completed';
    } catch (e, st) {
      _log?.warning(
        '[AuthDatasource] /auth/logout threw (non-critical)',
        e,
        st,
      );
      return 'Logout completed with remote error';
    }
  });

  // ── POST /auth/password-reset/request ────────────────────────────────────

  @override
  Future<Map<String, dynamic>> requestPasswordReset({required String email}) =>
      _withAuthUrl(() async {
        _log?.info('[AuthDatasource] POST /auth/password-reset/request');
        final result = await _http.post(
          '/auth/password-reset/request',
          data: {'email': email},
        );
        if (_isSuccess(result.statusCode)) return result.data;
        throw Exception('Request password reset failed: ${result.message}');
      });

  // ── POST /auth/password-reset/verify-otp ─────────────────────────────────

  @override
  Future<Map<String, dynamic>> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) => _withAuthUrl(() async {
    _log?.info('[AuthDatasource] POST /auth/password-reset/verify-otp');
    final result = await _http.post(
      '/auth/password-reset/verify-otp',
      data: {'code': otp, 'email': email},
    );
    if (_isSuccess(result.statusCode)) return result.data;
    throw Exception('Verify password reset failed: ${result.message}');
  });

  // ── POST /auth/password-reset/reset ──────────────────────────────────────

  @override
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) => _withAuthUrl(() async {
    _log?.info('[AuthDatasource] POST /auth/password-reset/reset');
    final result = await _http.post(
      '/auth/password-reset/reset',
      data: {'token': token, 'password': newPassword},
    );
    if (_isSuccess(result.statusCode)) return result.data;
    throw Exception('Reset password failed: ${result.message}');
  });

  // ── POST /auth/verify-2fa ─────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> verifyTwoFactor({
    required String userId,
    required String otp,
  }) => _withAuthUrl(() async {
    _log?.info('[AuthDatasource] POST /auth/verify-2fa — userId: $userId');
    final result = await _http.post(
      '/auth/verify-2fa',
      data: {'userId': userId, 'otp': otp},
    );
    if (_isSuccess(result.statusCode)) return result.data;
    throw Exception('2FA verification failed: ${result.message}');
  });

  // ── POST /auth/refresh ────────────────────────────────────────────────────

 @override
Future<Map<String, dynamic>> exchangeRefreshToken({
  required String refreshToken,
  required String platformId,
  required List<String> scopes, // kept for interface compat, not sent
}) => _withAuthUrl(() async {
  _log?.info('[AuthDatasource] POST /auth/refresh — platformId: $platformId');
  final result = await _http.post(
    '/auth/refresh',
    data: {
      'refreshToken': refreshToken,
      'platformId': platformId,    // ✅ required by backend
      'deviceType': 'mobile',      // ✅ optional but good practice
      // ❌ 'scopes' removed — not in the schema, causes 404/rejection
    },
  );
  if (_isSuccess(result.statusCode)) return result.data;
  throw Exception('Token refresh failed: ${result.message}');
});
  // ── POST /auth/social/google ──────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> loginWithGoogle({
    required String idToken,
    required Map<String, dynamic> deviceInfo,
  }) => _withAuthUrl(() async {
    _log?.info('[AuthDatasource] POST /auth/social/google');
    final result = await _http.post(
      '/auth/social/google',
      data: {'idToken': idToken, ...deviceInfo},
    );
    if (_isSuccess(result.statusCode)) return result.data;
    throw Exception('Google sign in failed: ${result.message}');
  });

  // ── POST /auth/social/apple ───────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> loginWithApple({
    required String identityToken,
    required String authorizationCode,
    String? firstName,
    String? lastName,
    required Map<String, dynamic> deviceInfo,
  }) => _withAuthUrl(() async {
    _log?.info('[AuthDatasource] POST /auth/social/apple');
    final result = await _http.post(
      '/auth/social/apple',
      data: {
        'identityToken': identityToken,
        'authorizationCode': authorizationCode,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        ...deviceInfo,
      },
    );
    if (_isSuccess(result.statusCode)) return result.data;
    throw Exception('Apple sign in failed: ${result.message}');
  });

  // ── POST /onboarding/complete ─────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> completeOnboarding({
    required Map<String, dynamic> data,
  }) => _withAuthUrl(() async {
    _log?.info('[AuthDatasource] POST /onboarding/complete');
    final result = await _http.post('/onboarding/complete', data: data);
    if (_isSuccess(result.statusCode)) return result.data;
    throw Exception('Onboarding failed: ${result.message}');
  });

  // ── Helper ────────────────────────────────────────────────────────────────

  bool _isSuccess(int? statusCode) {
    final code = statusCode ?? 404;
    return code >= 200 && code < 300;
  }
}
