import 'package:dio/dio.dart';
import '../events/wallet_event_bus.dart';
import '../logging/wallet_logger.dart';

class WalletHttpClient {
  WalletHttpClient._();

  static WalletHttpClient? _instance;
  static WalletHttpClient get instance {
    assert(
      _instance != null,
      'WalletHttpClient not initialized. Call WalletHttpClient.init()',
    );
    return _instance!;
  }

  late final Dio _dio;
  String? _accessToken;

  static void init({required String baseUrl}) {
    _instance = WalletHttpClient._();
    _instance!._dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _instance!._dio.interceptors.addAll([
      WalletAuthInterceptor(_instance!),
      WalletLoggingInterceptor(),
    ]);
  }

  /// Update base URL — used by datasources to switch between service hosts.
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  void setToken(String token) => _accessToken = token;
  void clearToken() => _accessToken = null;
  String? get token => _accessToken;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);
}

class WalletAuthInterceptor extends Interceptor {
  final WalletHttpClient _client;
  static const _publicPaths = ['/v1/withdrawal/banks'];

  WalletAuthInterceptor(this._client);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final isPublic = _publicPaths.any((p) => options.path.contains(p));
    if (!isPublic) {
      final token = _client.token;
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      WalletEventBus.instance.emit(const WalletSessionExpired());
    }
    handler.next(err);
  }
}

/// WalletLoggingInterceptor
/// ========================
/// Logs every request, response, and error via [WalletLogger].
/// - Stamps request start time for duration tracking
/// - Redacts Authorization header
/// - Sanitizes PIN/password fields from request bodies
class WalletLoggingInterceptor extends Interceptor {
  static const _startTimeKey = '_wallet_request_start';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;
    WalletLogger.i.http(
      options.method,
      options.path,
      body: _sanitizeBody(options.data),
      headers: _redactHeaders(options.headers),
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    WalletLogger.i.response(
      response.requestOptions.method,
      response.requestOptions.path,
      response.statusCode ?? 0,
      body: _sanitizeBody(response.data),
      duration: _elapsed(response.requestOptions),
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    WalletLogger.i.httpError(
      err.requestOptions.method,
      err.requestOptions.path,
      status: err.response?.statusCode,
      message: _extractMessage(err.response?.data) ?? err.message,
      body: err.response?.data,
    );
    handler.next(err);
  }

  Duration? _elapsed(RequestOptions options) {
    final start = options.extra[_startTimeKey] as int?;
    if (start == null) return null;
    return Duration(
      milliseconds: DateTime.now().millisecondsSinceEpoch - start,
    );
  }

  Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    final copy = Map<String, dynamic>.from(headers);
    if (copy.containsKey('Authorization'))
      copy['Authorization'] = 'Bearer [REDACTED]';
    return copy;
  }

  dynamic _sanitizeBody(dynamic body) {
    if (body is Map<String, dynamic>) {
      final copy = Map<String, dynamic>.from(body);
      for (final key in ['pin', 'pinHash', 'password']) {
        if (copy.containsKey(key)) copy[key] = '[REDACTED]';
      }
      return copy;
    }
    return body;
  }

  String? _extractMessage(dynamic data) {
    if (data is Map)
      return data['message']?.toString() ?? data['error']?.toString();
    return null;
  }
}
