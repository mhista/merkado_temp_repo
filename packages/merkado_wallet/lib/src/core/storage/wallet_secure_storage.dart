import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'wallet_storage_keys.dart';

/// WalletSecureStorage
/// ===================
/// Local secure storage for wallet-specific preferences and security state.
/// Uses flutter_secure_storage directly (no dependency on common_utils).
///
/// Does NOT store access tokens — those live in merkado_auth's storage.
/// This service handles:
///   - Balance visibility preference
///   - PIN state (set/not set, attempt tracking, lockout)
///   - Cached wallet ID
///   - Demo mode flag
class WalletSecureStorage {
  WalletSecureStorage._();

  static WalletSecureStorage? _instance;
  static WalletSecureStorage get instance {
    _instance ??= WalletSecureStorage._();
    return _instance!;
  }

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  // ── Balance visibility ──────────────────────────────────────────────

  Future<bool> isBalanceVisible() async {
    final val = await _storage.read(key: WalletStorageKeys.balanceVisible);
    return val != 'false'; // Default: visible
  }

  Future<void> setBalanceVisible(bool visible) =>
      _storage.write(key: WalletStorageKeys.balanceVisible, value: visible.toString());

  // ── PIN state ───────────────────────────────────────────────────────

  Future<bool> isPinSet() async {
    final val = await _storage.read(key: WalletStorageKeys.isPinSet);
    return val == 'true';
  }

  Future<void> setIsPinSet(bool value) =>
      _storage.write(key: WalletStorageKeys.isPinSet, value: value.toString());

  Future<int> getPinAttempts() async {
    final val = await _storage.read(key: WalletStorageKeys.pinAttempts);
    return int.tryParse(val ?? '0') ?? 0;
  }

  Future<void> incrementPinAttempts() async {
    final current = await getPinAttempts();
    await _storage.write(
      key: WalletStorageKeys.pinAttempts,
      value: (current + 1).toString(),
    );
  }

  Future<void> resetPinAttempts() async {
    await _storage.write(key: WalletStorageKeys.pinAttempts, value: '0');
    await _storage.write(key: WalletStorageKeys.pinLockedUntil, value: '0');
  }

  Future<void> lockPinUntil(DateTime until) =>
      _storage.write(
        key: WalletStorageKeys.pinLockedUntil,
        value: until.millisecondsSinceEpoch.toString(),
      );

  Future<DateTime?> getPinLockedUntil() async {
    final val = await _storage.read(key: WalletStorageKeys.pinLockedUntil);
    final ms = int.tryParse(val ?? '0') ?? 0;
    if (ms == 0) return null;
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return dt.isAfter(DateTime.now()) ? dt : null;
  }

  // ── Wallet ID cache ─────────────────────────────────────────────────

  Future<String?> getWalletId() => _storage.read(key: WalletStorageKeys.walletId);

  Future<void> saveWalletId(String id) =>
      _storage.write(key: WalletStorageKeys.walletId, value: id);

  // ── Demo mode ───────────────────────────────────────────────────────

  Future<bool> isDemoMode() async {
    final val = await _storage.read(key: WalletStorageKeys.isDemoMode);
    return val == 'true';
  }

  Future<void> setDemoMode(bool value) =>
      _storage.write(key: WalletStorageKeys.isDemoMode, value: value.toString());

  // ── Clear ───────────────────────────────────────────────────────────

  Future<void> clearAll() => _storage.deleteAll();
}