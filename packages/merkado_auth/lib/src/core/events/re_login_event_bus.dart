import 'dart:async';
import 'package:common_utils2/common_utils2.dart';

/// ReLoginEventBus
/// ===============
/// Broadcasts a signal when the auth interceptor detects that the refresh
/// token has expired or been revoked. The [AuthCubit] listens to this and
/// emits [AuthState.sessionExpired], which the package router uses to
/// navigate the user back to the login screen.
///
/// This decouples the Dio interceptor (which has no BuildContext) from
/// the Cubit/UI layer.
class ReLoginEventBus {
  ReLoginEventBus._();

  static ReLoginEventBus? _instance;

  /// Singleton instance.
  static ReLoginEventBus get instance => _instance ??= ReLoginEventBus._();

  static LoggerService? _log;

  static void setLogger(LoggerService? logger) => _log = logger;

  final StreamController<String?> _controller =
      StreamController<String?>.broadcast();

  /// Stream of re-login signals.
  /// Payload is the userId whose session expired, if known. May be null.
  Stream<String?> get stream => _controller.stream;

  /// Emit a re-login required signal.
  /// [userId] is optional — provide it to show a specific "session expired
  /// for [name]" message rather than a generic one.
  void emit({String? userId}) {
    if (!_controller.isClosed) {
      _log?.warning('[ReLoginEventBus] Session expired signal — userId: ${userId ?? 'unknown'}');
      _controller.add(userId);
    }
  }

  /// Dispose the stream. Called by [MerkadoAuth.dispose()].
  void dispose() {
    _log?.debug('[ReLoginEventBus] Disposed');
    _controller.close();
    _instance = null;
    _log = null;
  }
}