// lib/src/core/events/token_refresh_bus.dart  (merkado_auth package)
//
// Broadcasts every new access token — whether produced by a silent
// interceptor refresh or a startup refresh — so ALL HTTP clients in
// the app (HttpClient, WalletHttpClient, raw Dio instances) can stay
// in sync without needing BuildContext.
//
// Usage in consuming app (call once, e.g. in initDependencies):
//   TokenRefreshBus.instance.stream.listen((token) {
//     HttpClient.instance.setAuthToken(token);
//     WalletHttpClient.instance.setToken(token);
//   });

import 'dart:async';
import 'package:common_utils2/common_utils2.dart';

class TokenRefreshBus {
  TokenRefreshBus._();

  static TokenRefreshBus? _instance;
  static TokenRefreshBus get instance => _instance ??= TokenRefreshBus._();

  static LoggerService? _log;
  static void setLogger(LoggerService? logger) => _log = logger;

  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  Stream<String> get stream => _controller.stream;

  /// Call this after every successful token refresh — interceptor OR cubit.
  void emit(String newAccessToken) {
    if (!_controller.isClosed && newAccessToken.isNotEmpty) {
      _log?.debug('[TokenRefreshBus] Broadcasting new access token');
      _controller.add(newAccessToken);
    }
  }

  void dispose() {
    _controller.close();
    _instance = null;
    _log = null;
  }
}