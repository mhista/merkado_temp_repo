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
///
/// ERROR MESSAGE EXTRACTION:
/// ─────────────────────────
/// HttpClient wraps errors in ApiResponse.error(). The actual server-returned
/// message lives in result.error?.message (extracted from the response body by
/// HttpClient._extractErrorMessage). result.message is the HTTP status text
/// ("Unauthorized", "Bad Request") — never use it for user-facing errors.
///
/// Pattern used throughout:
///   if (result.isSuccess && result.data != null) return result.data!;
///   throw Exception(_errorMsg(result, 'Fallback message'));
///
/// _errorMsg() prefers result.error?.message (server body) and falls back
/// gracefully so the caller always gets a readable string.
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
    required String authBaseUrl,
    required String appBaseUrl,
    LoggerService? logger,
  })  : _authBaseUrl = authBaseUrl,
        _appBaseUrl = appBaseUrl,
        _log = logger;

  // ── URL-switching wrapper ─────────────────────────────────────────────────

  /// Switches to [_authBaseUrl], runs [call], then always restores [_appBaseUrl].
  Future<T> _withAuthUrl<T>(Future<T> Function() call) async {
    _http.updateBaseUrl(_authBaseUrl);
    try {
      return await call();
    } finally {
      _http.updateBaseUrl(_appBaseUrl);
    }
  }

  // ── Error message helper ──────────────────────────────────────────────────

  /// Extracts the most useful error message from an [ApiResponse].
  ///
  /// Priority:
  ///   1. result.error?.message  — parsed from the server JSON body
  ///      (e.g. "Invalid email or password", "Email already registered")
  ///   2. fallback                — caller-supplied context string
  ///
  /// Never uses result.message — that is the raw HTTP status text
  /// ("Unauthorized", "Bad Request") which is not useful to the user.
  String _errorMsg(ApiResponse<dynamic> result, String fallback) {
    final serverMsg = result.error?.message;
    if (serverMsg != null && serverMsg.isNotEmpty) return serverMsg;
    return fallback;
  }

  // ── POST /auth/register ───────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> deviceInfo,
  }) =>
      _withAuthUrl(() async {
        _log?.info('[AuthDatasource] POST /auth/register — $email');
        final result = await _http.post(
          '/auth/register',
          data: {'email': email, 'password': password, ...deviceInfo},
        );
        if (result.isSuccess && result.data != null) return result.data!;
        throw Exception(_errorMsg(result, 'Sign up failed'));
      });

  // ── POST /auth/verify-email ───────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otp,
  }) =>
      _withAuthUrl(() async {
        _log?.info('[AuthDatasource] POST /auth/verify-email — $email');
        final result =
            await _http.post('/auth/verify-email', data: {'code': otp});
        if (result.isSuccess && result.data != null) return result.data!;
        throw Exception(_errorMsg(result, 'Email verification failed'));
      });

  // ── POST /auth/resend-otp ─────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> resendOtp({required String email}) =>
      _withAuthUrl(() async {
        _log?.info('[AuthDatasource] POST /auth/resend-otp — $email');
        final result = await _http.post('/auth/resend-otp', data: {});
        if (result.isSuccess && result.data != null) return result.data!;
        throw Exception(_errorMsg(result, 'Resend OTP failed'));
      });

  // ── POST /auth/login ──────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> login({
    required Map<String, dynamic> data,
  }) =>
      _withAuthUrl(() async {
        _log?.info('[AuthDatasource] POST /auth/login — ${data['email']}');
        final result = await _http.post('/auth/login', data: data);
        if (result.isSuccess && result.data != null) return result.data!;
        throw Exception(_errorMsg(result, 'Login failed'));
      });

  // ── POST /auth/logout ─────────────────────────────────────────────────────

  @override
  Future<String> logout({required String sessionId}) =>
      _withAuthUrl(() async {
        _log?.info(
            '[AuthDatasource] POST /auth/logout — sessionId: $sessionId');
        try {
          final result = await _http.post(
            '/auth/logout',
            data: {'sessionId': sessionId},
          );
          if (result.isSuccess) return 'Logout successful';
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
  Future<Map<String, dynamic>> requestPasswordReset(
          {required String email}) =>
      _withAuthUrl(() async {
        _log?.info('[AuthDatasource] POST /auth/password-reset/request');
        final result = await _http.post(
          '/auth/password-reset/request',
          data: {'email': email},
        );
        if (result.isSuccess && result.data != null) return result.data!;
        throw Exception(_errorMsg(result, 'Password reset request failed'));
      });

  // ── POST /auth/password-reset/verify-otp ─────────────────────────────────

  @override
  Future<Map<String, dynamic>> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) =>
      _withAuthUrl(() async {
        _log?.info('[AuthDatasource] POST /auth/password-reset/verify-otp');
        final result = await _http.post(
          '/auth/password-reset/verify-otp',
          data: {'code': otp, 'email': email},
        );
        if (result.isSuccess && result.data != null) return result.data!;
        throw Exception(_errorMsg(result, 'OTP verification failed'));
      });

  // ── POST /auth/password-reset/reset ──────────────────────────────────────

  @override
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) =>
      _withAuthUrl(() async {
        _log?.info('[AuthDatasource] POST /auth/password-reset/reset');
        final result = await _http.post(
          '/auth/password-reset/reset',
          data: {'token': token, 'password': newPassword},
        );
        if (result.isSuccess && result.data != null) return result.data!;
        throw Exception(_errorMsg(result, 'Password reset failed'));
      });

  // ── POST /auth/verify-2fa ─────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> verifyTwoFactor({
    required String userId,
    required String otp,
  }) =>
      _withAuthUrl(() async {
        _log?.info(
            '[AuthDatasource] POST /auth/verify-2fa — userId: $userId');
        final result = await _http.post(
          '/auth/verify-2fa',
          data: {'userId': userId, 'otp': otp},
        );
        if (result.isSuccess && result.data != null) return result.data!;
        throw Exception(_errorMsg(result, '2FA verification failed'));
      });

  // ── POST /auth/refresh ────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> exchangeRefreshToken({
    required String refreshToken,
    required String platformId,
    required List<String> scopes, // kept for interface compat, not sent
  }) =>
      _withAuthUrl(() async {
        _log?.info(
            '[AuthDatasource] POST /auth/refresh — platformId: $platformId');
        final result = await _http.post(
          '/auth/refresh',
          data: {
            'refreshToken': refreshToken,
            'platformId': platformId,
            'deviceType': 'mobile',
            // 'scopes' intentionally omitted — not in the API schema
          },
        );
        if (result.isSuccess && result.data != null) return result.data!;
        throw Exception(_errorMsg(result, 'Token refresh failed'));
      });

  // ── POST /auth/social/google ──────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> loginWithGoogle({
    required String idToken,
    required Map<String, dynamic> deviceInfo,
  }) =>
      _withAuthUrl(() async {
        _log?.info('[AuthDatasource] POST /auth/social/google');
        final result = await _http.post(
          '/auth/social/google',
          data: {'idToken': idToken, ...deviceInfo},
        );
        if (result.isSuccess && result.data != null) return result.data!;
        throw Exception(_errorMsg(result, 'Google sign in failed'));
      });

  // ── POST /auth/social/apple ───────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> loginWithApple({
    required String identityToken,
    required String authorizationCode,
    String? firstName,
    String? lastName,
    required Map<String, dynamic> deviceInfo,
  }) =>
      _withAuthUrl(() async {
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
        if (result.isSuccess && result.data != null) return result.data!;
        throw Exception(_errorMsg(result, 'Apple sign in failed'));
      });

  // ── POST /onboarding/complete ─────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> completeOnboarding({
    required Map<String, dynamic> data,
  }) =>
      _withAuthUrl(() async {
        _log?.info('[AuthDatasource] POST /onboarding/complete');
        final result = await _http.post('/onboarding/complete', data: data);
        if (result.isSuccess && result.data != null) return result.data!;
        throw Exception(_errorMsg(result, 'Onboarding failed'));
      });
}