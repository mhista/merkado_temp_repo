import 'package:dio/dio.dart';

class NetworkConstants {
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Default base URL - normally this would be passed via config or environment
  static const String baseUrl = 'https://kyc-api.merkado.site';
}

class DioClient {
  final Dio _dio;
  String? _secretToken;
  String? _userFullName;

  void setSecretToken(String? token) {
    _secretToken = token;
  }

  void setUserFullName(String userFullName) {
    _userFullName = userFullName;
  }

  DioClient(this._dio) {
    _dio
      ..options.baseUrl = NetworkConstants.baseUrl
      ..options.connectTimeout = const Duration(
        milliseconds: NetworkConstants.connectTimeout,
      )
      ..options.receiveTimeout = const Duration(
        milliseconds: NetworkConstants.receiveTimeout,
      )
      ..options.responseType = ResponseType.json
      ..interceptors.addAll([
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (_secretToken != null) {
              options.headers['Authorization'] = 'Bearer $_secretToken';
            }
            return handler.next(options);
          },
        ),
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
        ),
      ]);
  }

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Add put, delete etc as needed
}
