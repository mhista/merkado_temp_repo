// merkado_auth_interceptor.dart — FULL REPLACEMENT

import 'package:common_utils2/common_utils2.dart';
import 'package:dio/dio.dart';
import 'package:merkado_auth/merkado_auth.dart';

class MerkadoAuthInterceptor extends Interceptor {
  final AuthSecureStorageService _storage = AuthSecureStorageService.instance;
  LoggerService? _log;
  final String _refreshEndpoint;

  /// authBaseUrl MUST be passed in — this is the base for /auth/refresh.
  /// It is NOT the same as the app's apiBaseUrl.
  final String _authBaseUrl;

  MerkadoAuthInterceptor({
    required String authBaseUrl,          // ← NEW required param
    String refreshEndpoint = '/auth/refresh',
    LoggerService? logger,
  }) : _refreshEndpoint = refreshEndpoint,
       _authBaseUrl = authBaseUrl,
       _log = logger {
    _log = LoggerService.instance;
  }

  static const _publicPaths = [
    '/auth/login',
    '/auth/register',
    '/auth/password-reset/reset',
    'auth/password-reset/request',
    'auth/password-reset/verify-otp',
    '/auth/reset-password',
    '/auth/social/google',
    '/auth/social/apple',
    '/.well-known/jwks.json',
  ];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublicPath(options.path)) {
      _log?.debug('[Interceptor] Public path — no token attached: ${options.path}');
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
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Don't retry the refresh endpoint itself — that would loop forever
    if (err.requestOptions.path.contains(_refreshEndpoint)) {
      _log?.error('[Interceptor] Refresh endpoint itself returned 401 — session dead');
      ReLoginEventBus.instance.emit();
      return handler.next(err);
    }

    _log?.warning('[Interceptor] 401 on ${err.requestOptions.path} — attempting refresh');

    final refreshed = await _attemptRefresh();

    if (refreshed) {
      _log?.info('[Interceptor] Refresh succeeded — retrying ${err.requestOptions.path}');
      try {
        final newToken = await _storage.getAccessToken();
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newToken';

        // Use a fresh Dio pointed at the ORIGINAL request's baseUrl, not authBaseUrl
        final retryDio = Dio(BaseOptions(baseUrl: retryOptions.baseUrl));
        final response = await retryDio.fetch(retryOptions);
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

  Future<bool> _attemptRefresh() async {
    try {
      final activeUserId = await _storage.getUserId();
      if (activeUserId == null) return false;

      final accounts = await _storage.getKnownAccounts();
      final account = accounts.where((a) => a.userId == activeUserId).firstOrNull;
      if (account == null) return false;

      // Use _authBaseUrl — NEVER originalRequest.baseUrl for the refresh call
      final refreshDio = Dio(BaseOptions(baseUrl: _authBaseUrl));
      final response = await refreshDio.post(
        _refreshEndpoint,
        data: {'refreshToken': account.refreshToken},
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String?;
        final expiresIn = data['expiresIn'] as int? ?? 900;

        await _storage.saveAccessToken(newAccessToken, expiresIn: expiresIn);

        if (newRefreshToken != null && newRefreshToken != account.refreshToken) {
          await _storage.upsertKnownAccount(
            account.copyWith(refreshToken: newRefreshToken),
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      _log?.error('[Interceptor] _attemptRefresh threw', e);
      return false;
    }
  }

  bool _isPublicPath(String path) =>
      _publicPaths.any((p) => path.contains(p));
}