import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'pin_service.dart';
import '../../core/events/wallet_event_bus.dart';
import '../../core/events/wallet_notification_event.dart';
import '../../core/logging/wallet_logger.dart';

part 'pin_state.dart';
part 'pin_cubit.freezed.dart';

typedef VoidCallback = void Function();

/// PinCubit
/// ========
/// Manages PIN setup and verification UI state.
/// Delegates all PIN hashing and lockout logic to [PinService].
/// The raw PIN value is NEVER stored — it is hashed the moment
/// the user confirms entry and the hash is what gets sent to the backend.
class PinCubit extends Cubit<PinState> {
  final PinService _pinService = PinService.instance;
  final WalletEventBus _eventBus = WalletEventBus.instance;

  void Function(WalletNotificationEvent)? _onNotification;
  String? _userId;

  PinCubit() : super(const PinState.idle());

  void configure({
    String? userId,
    void Function(WalletNotificationEvent)? onNotification,
  }) {
    _userId = userId;
    if (onNotification != null) _onNotification = onNotification;
  }

  // ── Check initial state ─────────────────────────────────────────────

  Future<void> checkPinStatus() async {
    WalletLogger.i.pin('checkPinStatus');
    final isPinSet   = await _pinService.isPinSet();
    final lockStatus = await _pinService.checkLockStatus();

    switch (lockStatus) {
      case PinLockedStatus(:final until):
        WalletLogger.i.pin('locked until $until');
        _emitSafe(PinState.locked(unlocksAt: until));
        return;
      case PinUnlockedStatus() || PinFailedStatus():
        break;
    }

    _emitSafe(isPinSet ? const PinState.pinAlreadySet() : const PinState.idle());
  }

  // ── Setup PIN ───────────────────────────────────────────────────────

  /// [pin] is the raw 4–6 digit string. It is hashed here and never leaves
  /// this scope in plaintext.
  Future<void> setupPin({required String pin}) async {
    WalletLogger.i.pin('setupPin — hashing and marking set');
    if (_userId == null) {
      _emitSafe(const PinState.error('User ID not configured'));
      return;
    }

    _emitSafe(const PinState.loading());
    // Hash immediately — raw PIN never stored or logged
    final hash = _pinService.hashPin(pin, _userId!);
    // TODO: send `hash` to /wallet/pin/setup endpoint when available
    // _ = hash;
    await _pinService.markPinSet();
    _emitSafe(const PinState.pinSet());
    _eventBus.emit(const WalletPinSet());
    WalletLogger.i.pin('pinSet — success');
  }

  // ── Verify PIN ──────────────────────────────────────────────────────

  Future<void> verifyPin({
    required String pin,
    VoidCallback? onVerified,
  }) async {
    WalletLogger.i.pin('verifyPin — checking lockout');
    if (_userId == null) {
      _emitSafe(const PinState.error('User ID not configured'));
      return;
    }

    final lockStatus = await _pinService.checkLockStatus();
    switch (lockStatus) {
      case PinLockedStatus(:final until):
        WalletLogger.i.pin('verifyPin blocked — locked until $until');
        _emitSafe(PinState.locked(unlocksAt: until));
        return;
      case PinUnlockedStatus() || PinFailedStatus():
        break;
    }

    _emitSafe(const PinState.loading());
    final hash = _pinService.hashPin(pin, _userId!);
    // TODO: send `hash` to backend for server-side verification
    // _ = hash;

    await _pinService.resetAttempts();
    _emitSafe(const PinState.pinVerified());
    _eventBus.emit(const WalletPinVerified());
    WalletLogger.i.pin('verifyPin — success');
    onVerified?.call();
  }

  // ── Record a failed attempt (call when backend returns 401 on PIN) ──

  Future<void> recordFailedAttempt() async {
    WalletLogger.i.pin('recordFailedAttempt');
    final status = await _pinService.recordFailedAttempt();

    switch (status) {
      case PinLockedStatus(:final until):
        WalletLogger.i.pin('PIN locked until $until');
        _emitSafe(PinState.locked(unlocksAt: until));
        _eventBus.emit(WalletPinLocked(unlocksAt: until));
        _onNotification?.call(
          WalletNotificationEvent.pinLocked(unlocksAt: until),
        );

      case PinFailedStatus(:final attemptsLeft):
        WalletLogger.i.pin('PIN failed — $attemptsLeft attempts left');
        _emitSafe(PinState.pinFailed(attemptsLeft: attemptsLeft));
        _eventBus.emit(WalletPinFailed(attemptsLeft: attemptsLeft));

      case PinUnlockedStatus():
        // Shouldn't happen after a failure, but handle gracefully
        WalletLogger.i.warning('recordFailedAttempt returned Unlocked — unexpected');
        break;
    }
  }

  void _emitSafe(PinState s) {
    if (!isClosed) {
      WalletLogger.i.pin('state → ${s.runtimeType}');
      emit(s);
    }
  }
}