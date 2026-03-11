import 'dart:async';

/// ══════════════════════════════════════════════════════════════════════════════
/// WalletEventBus
/// ==============
/// State-management-agnostic event stream for the merkado_wallet package.
///
/// Consuming apps subscribe to this stream regardless of whether they use
/// BLoC, Riverpod, Provider, GetX, or setState.
///
/// EXAMPLE (Riverpod):
/// ```dart
/// final walletEventProvider = StreamProvider<WalletEvent>((ref) {
///   return MerkadoWallet.of(ref.read(contextProvider)).walletStream;
/// });
/// ```
///
/// EXAMPLE (plain Dart):
/// ```dart
/// MerkadoWallet.of(context).walletStream.listen((event) {
///   if (event is WalletFunded) showToast('₦${event.amount} added!');
/// });
/// ```
/// ══════════════════════════════════════════════════════════════════════════════
class WalletEventBus {
  WalletEventBus._();

  static WalletEventBus? _instance;
  static WalletEventBus get instance => _instance ??= WalletEventBus._();

  final StreamController<WalletEvent> _controller =
      StreamController<WalletEvent>.broadcast();

  Stream<WalletEvent> get stream => _controller.stream;

  WalletEvent? _lastEvent;
  WalletEvent? get lastEvent => _lastEvent;

  void emit(WalletEvent event) {
    if (!_controller.isClosed) {
      _lastEvent = event;
      _controller.add(event);
    }
  }

  void dispose() {
    _controller.close();
    _instance = null;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// WalletEvent — sealed event hierarchy
// ══════════════════════════════════════════════════════════════════════════════

sealed class WalletEvent {
  const WalletEvent();
}

/// Any async wallet operation is in progress.
class WalletLoading extends WalletEvent {
  const WalletLoading();
}

/// Wallet data has been loaded or refreshed.
class WalletLoaded extends WalletEvent {
  final String walletId;
  final double availableBalance;
  final double ledgerBalance;
  final double withdrawableBalance;
  final String currency;

  const WalletLoaded({
    required this.walletId,
    required this.availableBalance,
    required this.ledgerBalance,
    required this.withdrawableBalance,
    required this.currency,
  });
}

/// Fund flow initiated — checkout URL is ready.
class WalletFundInitiated extends WalletEvent {
  final String checkoutUrl;
  final String reference;
  final String provider;
  final double amount;

  const WalletFundInitiated({
    required this.checkoutUrl,
    required this.reference,
    required this.provider,
    required this.amount,
  });
}

/// Wallet successfully funded (demo mode or webhook confirmation).
class WalletFunded extends WalletEvent {
  final double amount;
  final double newAvailableBalance;

  const WalletFunded({
    required this.amount,
    required this.newAvailableBalance,
  });
}

/// Withdrawal successfully requested.
class WalletWithdrawalRequested extends WalletEvent {
  final double amount;
  final String currency;
  final String bankName;
  final String status;

  const WalletWithdrawalRequested({
    required this.amount,
    required this.currency,
    required this.bankName,
    required this.status,
  });
}

/// Bank account was added successfully.
class WalletBankAccountAdded extends WalletEvent {
  final String bankName;
  final String accountNumber;
  final String currency;

  const WalletBankAccountAdded({
    required this.bankName,
    required this.accountNumber,
    required this.currency,
  });
}

/// Bank account was removed.
class WalletBankAccountRemoved extends WalletEvent {
  final String bankAccountId;
  const WalletBankAccountRemoved({required this.bankAccountId});
}

/// PIN was set up successfully.
class WalletPinSet extends WalletEvent {
  const WalletPinSet();
}

/// PIN was verified successfully.
class WalletPinVerified extends WalletEvent {
  const WalletPinVerified();
}

/// PIN verification failed.
class WalletPinFailed extends WalletEvent {
  final int attemptsLeft;
  const WalletPinFailed({required this.attemptsLeft});
}

/// PIN locked due to too many failed attempts.
class WalletPinLocked extends WalletEvent {
  final DateTime unlocksAt;
  const WalletPinLocked({required this.unlocksAt});
}

/// Session expired — consuming app should trigger re-auth via merkado_auth.
class WalletSessionExpired extends WalletEvent {
  const WalletSessionExpired();
}

/// Any wallet operation failed.
class WalletError extends WalletEvent {
  final String message;
  const WalletError({required this.message});
}

/// Session cleared (on logout).
class WalletSessionCleared extends WalletEvent {
  const WalletSessionCleared();
}