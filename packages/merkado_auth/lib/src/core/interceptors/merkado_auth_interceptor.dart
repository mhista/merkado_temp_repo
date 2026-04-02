// merkado_auth_interceptor.dart — FULL REPLACEMENT

import 'package:common_utils2/common_utils2.dart';
import 'package:dio/dio.dart';
import 'package:merkado_auth/merkado_auth.dart';

class MerkadoAuthInterceptor extends Interceptor {
 final AuthSecureStorageService _storage = AuthSecureStorageService.instance;
  LoggerService? _log;
  final String _refreshEndpoint;
  final String _authBaseUrl;
  final String _platformId; // ← ADD THIS

  MerkadoAuthInterceptor({
    required String authBaseUrl,
    required String platformId, // ← ADD THIS
    String refreshEndpoint = '/auth/refresh',
    LoggerService? logger,
  }) : _refreshEndpoint = refreshEndpoint,
       _authBaseUrl = authBaseUrl,
       _platformId = platformId, // ← ADD THIS
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

    // ✅ FIX 1: Read the refresh token from LOCAL storage first —
    // this is always the most up-to-date token. The knownAccounts list
    // may have a stale token if rotation happened mid-session.
    final localRefreshToken = await _storage.getRefreshToken();
    if (localRefreshToken == null) return false;

    // ✅ FIX 2: Include platformId and scopes — your backend requires them.
    // Without these, the server either rejects the request or returns a
    // generic token not scoped to this platform, causing silent failures.
    final refreshDio = Dio(BaseOptions(baseUrl: _authBaseUrl));
    final response = await refreshDio.post(
      _refreshEndpoint,
      data: {
        'refreshToken': localRefreshToken,
        'platformId': _platformId,       // ← was missing
        'scopes': _scopesForPlatform(_platformId), // ← was missing
      },
    );

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data as Map<String, dynamic>;
      final newAccessToken = data['accessToken'] as String;
      final newRefreshToken = data['refreshToken'] as String?;
      final expiresIn = data['expiresIn'] as int? ?? 900;

      await _storage.saveAccessToken(newAccessToken, expiresIn: expiresIn);

      // ✅ FIX 3: Also update LOCAL refresh token storage, not just knownAccounts.
      // Without this, the next refresh cycle reads the old token again.
      if (newRefreshToken != null && newRefreshToken != localRefreshToken) {
        await _storage.saveRefreshToken(newRefreshToken); // ← add this method (see below)

        // Also keep knownAccounts in sync if the account exists there
        final accounts = await _storage.getKnownAccounts();
        final account = accounts.where((a) => a.userId == activeUserId).firstOrNull;
        if (account != null) {
          await _storage.upsertKnownAccount(
            account.copyWith(refreshToken: newRefreshToken),
          );
        }
      }
      return true;
    }
    return false;
  } catch (e) {
    _log?.error('[Interceptor] _attemptRefresh threw', e);
    return false;
  }
}

// Add the scopes helper (mirrors AuthCubit._scopesForPlatform)
List<String> _scopesForPlatform(String platformId) {
  return [
    'profile:read',
    'wallet:read',
    '${_platformSlug(platformId)}:read',
    '${_platformSlug(platformId)}:write',
  ];
}

String _platformSlug(String platformId) {
  const slugs = {
    '019c761c-d25e-7257-b5ec-8af95ddd202c': 'mycut',
    '019c761c-d265-7a25-a095-ec995157cb32': 'driply',
    '019c761c-d265-7a25-a095-ec9a7262b4fa': 'haulway',
    '019c761c-d265-7a25-a095-ec9bfcd940d6': 'feastfeed',
    '019c761c-d265-7a25-a095-ec9c5ad364f5': 'itsyourday',
  };
  return slugs[platformId] ?? 'merkado';
}

  bool _isPublicPath(String path) =>
      _publicPaths.any((p) => path.contains(p));
}