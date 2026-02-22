import 'dart:async';
import '../models/auth_result.dart';

/// AuthEventBus
/// ============
/// The primary bridge between the package's internal [AuthCubit] and
/// the consuming app's state management system.
///
/// Whatever state management the consuming app uses (Bloc, Riverpod,
/// Provider, GetX, setState), it listens to [AuthEventBus.instance.stream]
/// and reacts to [AuthResult] events.
///
/// The package emits to this bus after every auth operation. The consuming
/// app NEVER calls emit directly — it only listens.
///
/// EXAMPLE — listening in a Riverpod app:
/// ```dart
/// ref.listen(authStreamProvider, (_, result) {
///   if (result is AuthSuccess) router.go('/home');
/// });
/// ```
///
/// EXAMPLE — listening in a plain StatefulWidget:
/// ```dart
/// late StreamSubscription _sub;
///
/// @override
/// void initState() {
///   _sub = MerkadoAuth.instance.authStream.listen((result) {
///     if (result is AuthSuccess) Navigator.pushReplacementNamed(context, '/home');
///   });
/// }
///
/// @override
/// void dispose() { _sub.cancel(); super.dispose(); }
/// ```
class AuthEventBus {
  AuthEventBus._();

  static AuthEventBus? _instance;

  /// Singleton instance.
  static AuthEventBus get instance => _instance ??= AuthEventBus._();

  final StreamController<AuthResult> _controller =
      StreamController<AuthResult>.broadcast();

  /// Stream of [AuthResult] events.
  /// Subscribe to this from any state management solution.
  Stream<AuthResult> get stream => _controller.stream;

  /// The most recent auth result. Null before any event is emitted.
  AuthResult? _lastResult;
  AuthResult? get lastResult => _lastResult;

  /// Emit an [AuthResult] to all listeners.
  /// Called internally by [AuthCubit] — do not call from consuming apps.
  void emit(AuthResult result) {
    if (!_controller.isClosed) {
      _lastResult = result;
      _controller.add(result);
    }
  }

  /// Dispose the stream. Called by [MerkadoAuth.dispose()].
  void dispose() {
    _controller.close();
    _instance = null;
  }
}