import 'wallet_logger.dart';

/// LoggerServiceAdapter
/// ====================
/// Bridges the consuming app's [LoggerService] to [WalletLoggerAdapter].
///
/// The wallet package cannot import [LoggerService] directly (it would
/// create a hard coupling). Instead, the app creates one of these at
/// startup and passes it into [MerkadoWalletConfig.logger].
///
/// Every method call is forwarded 1:1 to the matching [LoggerService]
/// method — the signatures are identical by design.
///
/// USAGE:
/// ```dart
/// // In your app, when configuring MerkadoWalletConfig:
/// MerkadoWalletConfig(
///   logger: LoggerServiceAdapter(LoggerService.instance),
///   enableLogging: true,
///   ...
/// )
/// ```
class LoggerServiceAdapter implements WalletLoggerAdapter {
  final dynamic _service;

  /// [service] must be your app's [LoggerService] instance.
  /// Typed as [dynamic] so this file compiles without importing
  /// the concrete class — duck-typed forwarding only.
  const LoggerServiceAdapter(this._service);

  // ── Basic levels — exact match to LoggerService.debug/info/warning/error ──

  @override
  void debug(dynamic message, [Object? exception, StackTrace? stackTrace]) =>
      _service.debug(message, exception, stackTrace);

  @override
  void info(dynamic message, [Object? exception, StackTrace? stackTrace]) =>
      _service.info(message, exception, stackTrace);

  @override
  void warning(dynamic message, [Object? exception, StackTrace? stackTrace]) =>
      _service.warning(message, exception, stackTrace);

  @override
  void error(dynamic message, [Object? exception, StackTrace? stackTrace]) =>
      _service.error(message, exception, stackTrace);

  // ── HTTP — exact match to LoggerService.logHttpRequest/Response/Error ──

  @override
  void logHttpRequest(
    String method,
    String url, {
    Map<String, dynamic>? headers,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) =>
      _service.logHttpRequest(
        method,
        url,
        headers: headers,
        data: data,
        queryParameters: queryParameters,
      );

  @override
  void logHttpResponse(
    String method,
    String url,
    int statusCode, {
    dynamic data,
    Duration? duration,
    Map<String, dynamic>? headers,
  }) =>
      _service.logHttpResponse(
        method,
        url,
        statusCode,
        data: data,
        duration: duration,
        headers: headers,
      );

  @override
  void logHttpError(
    String method,
    String url, {
    int? statusCode,
    String? error,
    dynamic data,
  }) =>
      _service.logHttpError(
        method,
        url,
        statusCode: statusCode,
        error: error,
        data: data,
      );

  // ── Actions — exact match to LoggerService.logAction ──

  @override
  void logAction(String action, {Map<String, dynamic>? data, String? screen}) =>
      _service.logAction(action, data: data, screen: screen);
}