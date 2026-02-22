import 'package:common_utils2/common_utils2.dart';
import 'package:dio/dio.dart';
import 'package:merkado_auth/merkado_auth.dart';


/// MerkadoAuthInterceptor
/// ======================
/// Dio interceptor that handles token attachment and automatic token refresh
/// for all API calls made through this package's HTTP client.
///
/// Lifecycle:
///   [onRequest] — checks token validity before every request.
///                 Attaches Bearer token or pre-emptively refreshes if close to expiry.
///   [onError]   — catches 401 responses, attempts refresh, retries original request.
///                 On refresh failure, emits via [ReLoginEventBus] so [AuthCubit]
///                 can clear session and navigate user to login.
///
/// Registered automatically during [MerkadoAuth.initialize()].
/// Consuming apps do NOT add this manually.
class MerkadoAuthInterceptor extends Interceptor {
  /// Uses [AuthSecureStorageService] — the auth package's own storage layer.
  /// Never touches [SecureStorageService] from common_utils directly.
  final AuthSecureStorageService _storage = AuthSecureStorageService.instance;
  final LoggerService? _log;
  final String _refreshEndpoint;

  MerkadoAuthInterceptor({
    String refreshEndpoint = '/auth/refresh',
    LoggerService? logger,
  })  : _refreshEndpoint = refreshEndpoint,
        _log = logger;

  /// Paths that never receive an Authorization header.
  /// Matches by substring so path prefixes like '/api/v1/auth/login' also match.
  /// Paths that NEVER receive an Authorization header.
  ///
  /// Rules:
  /// — Only include paths the backend explicitly accepts WITHOUT a token.
  /// — /auth/verify-email, /auth/resend-otp, /onboarding/complete all require
  ///   the access token issued at signup — do NOT list them here.
  /// — /auth/login, /auth/register, /auth/forgot-password, /auth/reset-password
  ///   are the only truly public endpoints in the Merkado identity service.
  ///
  /// Matched by substring so /api/v1/auth/login also matches.
  static const _publicPaths = [
    '/auth/login',
    '/auth/register',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/auth/social/google',
    '/auth/social/apple',
    '/.well-known/jwks.json',
    // NOTE: /auth/refresh is handled separately by _attemptRefresh()
    // on a fresh Dio instance — it must NOT be in this list or the
    // interceptor will skip token attachment on retry calls.
  ];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublicPath(options.path)) {
      _log?.debug('[Interceptor] Public path — no token attached: \${options.path}');
      return handler.next(options);
    }

    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      _log?.debug('[Interceptor] Token attached: ${options.path}');
    } else {
      _log?.warning('[Interceptor] No token available for protected path: ${options.path}');
    }

    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    _log?.warning('[Interceptor] 401 on \${err.requestOptions.path} — attempting refresh');

    // 401 received — attempt a token refresh before giving up
    final refreshed = await _attemptRefresh(err.requestOptions);

    if (refreshed) {
      _log?.info('[Interceptor] Refresh succeeded — retrying \${err.requestOptions.path}');
      try {
        final newToken = await _storage.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await Dio().fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        _log?.error('[Interceptor] Retry failed after refresh', e);
        return handler.next(err);
      }
    } else {
      _log?.error('[Interceptor] Refresh failed — session dead, emitting re-login');
      ReLoginEventBus.instance.emit();
      return handler.next(err);
    }
  }

  /// Attempts to refresh the access token using the stored refresh token.
  ///
  /// Uses [AuthSecureStorageService.getKnownAccounts] to find the active
  /// account's refresh token — no direct storage access needed.
  /// Returns true if refresh succeeded and the new token was saved.
  Future<bool> _attemptRefresh(RequestOptions originalRequest) async {
    try {
      // Read active userId through the public API — no private field access
      final activeUserId = await _storage.getUserId();
      if (activeUserId == null) return false;

      // Find the matching account in the shared SSO list to get its refresh token
      final accounts = await _storage.getKnownAccounts();
      final account = accounts
          .where((a) => a.userId == activeUserId)
          .firstOrNull;

      if (account == null) return false;

      // Make the refresh call on a fresh Dio instance to avoid interceptor loop
      final response = await Dio().post(
        '${originalRequest.baseUrl}$_refreshEndpoint',
        data: {'refreshToken': account.refreshToken},
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String?;
        final expiresIn = data['expiresIn'] as int? ?? 900;

        // Save new access token with its expiry
        await _storage.saveAccessToken(newAccessToken, expiresIn: expiresIn);

        // If backend rotated the refresh token, update the shared SSO hint
        if (newRefreshToken != null && newRefreshToken != account.refreshToken) {
          await _storage.upsertKnownAccount(
            account.copyWith(refreshToken: newRefreshToken),
          );
        }

        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  bool _isPublicPath(String path) {
    return _publicPaths.any((p) => path.contains(p));
  }
}