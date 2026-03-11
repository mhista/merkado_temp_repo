/// WalletStorageKeys
/// =================
/// Secure storage keys private to the merkado_wallet package.
/// Never conflicts with merkado_auth keys (different prefixes).
class WalletStorageKeys {
  WalletStorageKeys._();

  /// Whether the wallet balance is currently hidden by the user.
  static const String balanceVisible = 'mw_balance_visible';

  /// Whether the user has set up a wallet PIN.
  static const String isPinSet = 'mw_is_pin_set';

  /// Failed PIN attempt count (for brute-force lockout).
  static const String pinAttempts = 'mw_pin_attempts';

  /// Unix ms timestamp when PIN lockout expires (0 = not locked).
  static const String pinLockedUntil = 'mw_pin_locked_until';

  /// The active wallet ID (cached for quick access).
  static const String walletId = 'mw_wallet_id';

  /// Whether demo mode is active (for sandbox environments).
  static const String isDemoMode = 'mw_is_demo_mode';
}