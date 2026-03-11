import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../core/storage/wallet_secure_storage.dart';

/// PinService
/// ==========
/// Handles all PIN security logic entirely within the package.
///
/// SECURITY MODEL:
///   - PIN is SHA-256 hashed (salted with userId) before any API call
///   - Raw PIN never stored, never logged, never transmitted
///   - 5 failed attempts → 30-minute lockout
///   - Lockout persists across app restarts via secure storage
class PinService {
  PinService._();

  static PinService? _instance;
  static PinService get instance {
    _instance ??= PinService._();
    return _instance!;
  }

  static const int _maxAttempts = 5;
  static const Duration _lockDuration = Duration(minutes: 30);

  final WalletSecureStorage _storage = WalletSecureStorage.instance;

  /// SHA-256 hash a PIN, salted with [userId].
  /// This is the only form of the PIN that ever leaves this service.
  String hashPin(String pin, String userId) {
    final salted = '$pin:$userId:merkado_wallet_pin_v1';
    final bytes  = utf8.encode(salted);
    return sha256.convert(bytes).toString();
  }

  Future<PinLockStatus> checkLockStatus() async {
    final lockedUntil = await _storage.getPinLockedUntil();
    if (lockedUntil != null) return PinLockedStatus(lockedUntil);
    return const PinUnlockedStatus();
  }

  Future<PinLockStatus> recordFailedAttempt() async {
    await _storage.incrementPinAttempts();
    final attempts    = await _storage.getPinAttempts();
    final attemptsLeft = _maxAttempts - attempts;

    if (attemptsLeft <= 0) {
      final lockedUntil = DateTime.now().add(_lockDuration);
      await _storage.lockPinUntil(lockedUntil);
      return PinLockedStatus(lockedUntil);
    }

    return PinFailedStatus(attemptsLeft: attemptsLeft);
  }

  Future<void> resetAttempts() => _storage.resetPinAttempts();
  Future<void> markPinSet()    => _storage.setIsPinSet(true);
  Future<bool> isPinSet()      => _storage.isPinSet();
}

// ─────────────────────────────────────────────────────────────────────────────
// PinLockStatus — sealed class hierarchy
//
// All subclasses are PUBLIC and use descriptive names.
// This is intentional: pin_cubit.dart imports this file and must be able
// to exhaustively pattern-match without dynamic casts or shadow classes.
//
// switch (status) {
//   case PinLockedStatus(:final until):  ...  // locked — show countdown
//   case PinFailedStatus(:final attemptsLeft): ... // wrong PIN, still unlocked
//   case PinUnlockedStatus():            ...  // ok to attempt
// }
// ─────────────────────────────────────────────────────────────────────────────

sealed class PinLockStatus {
  const PinLockStatus();
  bool get isLocked   => this is PinLockedStatus;
  bool get isFailed   => this is PinFailedStatus;
  bool get isUnlocked => this is PinUnlockedStatus;
}

/// PIN is unlocked — entry attempts are allowed.
final class PinUnlockedStatus extends PinLockStatus {
  const PinUnlockedStatus();
}

/// PIN locked due to 5 consecutive failures. Lasts 30 minutes.
final class PinLockedStatus extends PinLockStatus {
  /// When the lockout expires.
  final DateTime until;
  const PinLockedStatus(this.until);

  /// Minutes remaining, rounded up (always >= 1 while active).
  int get minutesRemaining =>
      until.difference(DateTime.now()).inMinutes + 1;
}

/// A PIN attempt failed — account not yet locked.
final class PinFailedStatus extends PinLockStatus {
  /// Remaining attempts before lockout triggers.
  final int attemptsLeft;
  const PinFailedStatus({required this.attemptsLeft});
}