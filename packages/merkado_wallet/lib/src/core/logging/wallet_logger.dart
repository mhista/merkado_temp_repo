/// WalletLogger
/// ============
/// Singleton that routes all wallet package logs to the consuming app's
/// [LoggerService] via the [WalletLoggerAdapter] interface.
///
/// The wallet package NEVER depends on Talker directly. The app wraps its
/// already-initialised [LoggerService] in a [LoggerServiceAdapter] and
/// passes it into [MerkadoWalletConfig]. This means:
///   - No double-initialisation of Talker
///   - No circular dependency
///   - Silent no-op if logging is disabled or no adapter is provided
///
/// SETUP in MerkadoWalletConfig:
/// ```dart
/// MerkadoWalletConfig(
///   logger: LoggerServiceAdapter(LoggerService.instance),
///   enableLogging: true,
/// )
/// ```
///
/// USAGE inside the package:
/// ```dart
/// WalletLogger.i.debug('loaded wallet');
/// WalletLogger.i.http('GET', '/v1/wallet', body: data);
/// WalletLogger.i.response('GET', '/v1/wallet', 200, duration: d);
/// WalletLogger.i.httpError('GET', '/v1/wallet', status: 401);
/// WalletLogger.i.action('WalletCubit.loadWallet', data: {'amount': 5000});
/// WalletLogger.i.pin('verifyPin — checking lockout');
/// WalletLogger.i.state('WalletCubit', 'WalletLoaded');
/// WalletLogger.i.event('WalletFunded', data: {'amount': 5000});
/// ```
library wallet_logger;

/// Abstract interface — decouples the package from any concrete logger.
abstract interface class WalletLoggerAdapter {
  void debug(dynamic message, [Object? exception, StackTrace? stackTrace]);
  void info(dynamic message, [Object? exception, StackTrace? stackTrace]);
  void warning(dynamic message, [Object? exception, StackTrace? stackTrace]);
  void error(dynamic message, [Object? exception, StackTrace? stackTrace]);

  void logHttpRequest(
    String method,
    String url, {
    Map<String, dynamic>? headers,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });

  void logHttpResponse(
    String method,
    String url,
    int statusCode, {
    dynamic data,
    Duration? duration,
    Map<String, dynamic>? headers,
  });

  void logHttpError(
    String method,
    String url, {
    int? statusCode,
    String? error,
    dynamic data,
  });

  void logAction(String action, {Map<String, dynamic>? data, String? screen});
}

/// The internal singleton used throughout the package.
class WalletLogger {
  WalletLogger._();

  static final WalletLogger i = WalletLogger._();

  WalletLoggerAdapter? _adapter;
  bool _enabled = false;

  /// Called once by [MerkadoWalletScope] during widget initialisation.
  void configure({required WalletLoggerAdapter? adapter, required bool enabled}) {
    _adapter = adapter;
    _enabled = enabled;
  }

  bool get _active => _enabled && _adapter != null;

  // ── Basic levels ────────────────────────────────────────────────────

  void debug(String message) {
    if (_active) _adapter!.debug('[wallet] $message');
  }

  void info(String message) {
    if (_active) _adapter!.info('[wallet] $message');
  }

  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    if (_active) _adapter!.warning('[wallet] $message', error, stackTrace);
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (_active) _adapter!.error('[wallet] $message', error, stackTrace);
  }

  // ── HTTP ─────────────────────────────────────────────────────────────

  void http(String method, String path, {dynamic body, Map<String, dynamic>? headers}) {
    if (_active) {
      _adapter!.logHttpRequest(method, path, headers: headers, data: body);
    }
  }

  void response(String method, String path, int status, {dynamic body, Duration? duration}) {
    if (_active) {
      _adapter!.logHttpResponse(method, path, status, data: body, duration: duration);
    }
  }

  void httpError(String method, String path, {int? status, String? message, dynamic body}) {
    if (_active) {
      _adapter!.logHttpError(method, path, statusCode: status, error: message, data: body);
    }
  }

  // ── Domain helpers ────────────────────────────────────────────────────

  /// Log a user/system action (maps to LoggerService.logAction).
  void action(String name, {Map<String, dynamic>? data, String? screen}) {
    if (_active) _adapter!.logAction(name, data: data, screen: screen);
  }

  /// Log a cubit state transition.
  void state(String cubit, String stateName, {Map<String, dynamic>? data}) {
    if (_active) {
      _adapter!.logAction(
        '$cubit → $stateName',
        data: data,
        screen: cubit,
      );
    }
  }

  /// Log a wallet domain event emitted to the event bus.
  void event(String eventName, {Map<String, dynamic>? data}) {
    if (_active) {
      _adapter!.logAction('WalletEvent: $eventName', data: data);
    }
  }

  /// Log a PIN-related action. Never pass a PIN value — action names only.
  void pin(String action) {
    if (_active) _adapter!.logAction('PIN: $action');
  }
}