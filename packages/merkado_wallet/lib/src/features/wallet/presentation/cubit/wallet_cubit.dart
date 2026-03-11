import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../data/repository/wallet_repository_impl.dart';
import '../../../../core/events/wallet_event_bus.dart';
import '../../../../core/events/wallet_notification_event.dart';
import '../../../../core/logging/wallet_logger.dart';
import '../../../../core/storage/wallet_secure_storage.dart';

part 'wallet_state.dart';
part 'wallet_cubit.freezed.dart';

/// WalletCubit
/// ===========
/// State machine for the wallet home screen.
/// Manages balance fetching, funding initiation, and demo operations.
class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _repository;
  final WalletEventBus _eventBus = WalletEventBus.instance;
  final WalletSecureStorage _storage = WalletSecureStorage.instance;

  // Config references — set after init
  String _currencySymbol = '₦';
  void Function(WalletNotificationEvent)? _onNotification;
  String _fundingRedirectUrl = 'https://app.merkado.site/wallet/fund/callback';
  bool _demoMode = false;

  WalletCubit({WalletRepository? repository})
      : _repository = repository ?? WalletRepositoryImpl(),
        super(const WalletState.initial());

  void configure({
    String? currencySymbol,
    void Function(WalletNotificationEvent)? onNotification,
    String? fundingRedirectUrl,
    bool? demoMode,
  }) {
    if (currencySymbol != null) _currencySymbol = currencySymbol;
    if (onNotification != null) _onNotification = onNotification;
    if (fundingRedirectUrl != null) _fundingRedirectUrl = fundingRedirectUrl;
    if (demoMode != null) _demoMode = demoMode;
  }

  // ── Load wallet ─────────────────────────────────────────────────────

  Future<void> loadWallet() async {
    WalletLogger.i.state('WalletCubit', 'loadWallet');
    _emitSafe(const WalletState.loading());
    _eventBus.emit(const WalletLoading());

    final balanceVisible = await _storage.isBalanceVisible();

    final result = await _repository.getWallet();
    result.when(
      success: (wallet) async {
        await _storage.saveWalletId(wallet.id);
        WalletLogger.i.state('WalletCubit', 'loaded', data: {
          'available': wallet.availableBalance,
          'ledger': wallet.ledgerBalance,
          'withdrawable': wallet.withdrawableBalance,
          'currency': wallet.currency,
        });
        _emitSafe(WalletState.loaded(
          wallet: wallet,
          balanceVisible: balanceVisible,
        ));
        _eventBus.emit(WalletLoaded(
          walletId: wallet.id,
          availableBalance: wallet.availableBalance,
          ledgerBalance: wallet.ledgerBalance,
          withdrawableBalance: wallet.withdrawableBalance,
          currency: wallet.currency,
        ));
      },
      failure: (error, _) {
        _emitSafe(WalletState.error(error));
        _eventBus.emit(WalletError(message: error));
      },
    );
  }

  // ── Fund wallet (real / production) ────────────────────────────────

  Future<void> initiateAddMoney({required double amount}) async {
    WalletLogger.i.state('WalletCubit', 'initiateAddMoney', data: {'amount': amount, 'demo': _demoMode});
    if (_demoMode) {
      await demoAddMoney(amount: amount);
      return;
    }

    _emitSafe(_withUpdating('add_money'));
    final result = await _repository.fundWallet(
      amount: amount,
      redirectUrl: _fundingRedirectUrl,
    );
    result.when(
      success: (res) {
        _emitSafe(WalletState.fundInitiated(
          checkoutUrl: res.checkoutUrl,
          reference: res.reference,
          provider: res.provider,
          amount: res.amount,
        ));
        _eventBus.emit(WalletFundInitiated(
          checkoutUrl: res.checkoutUrl,
          reference: res.reference,
          provider: res.provider,
          amount: res.amount,
        ));
        _onNotification?.call(
          WalletNotificationEvent.fundInitiated(
            amount: amount,
            currency: res.currency,
          ),
        );
      },
      failure: (error, _) {
        _emitSafe(WalletState.error(error));
        _eventBus.emit(WalletError(message: error));
      },
    );
  }

  // ── Demo fund (sandbox) ─────────────────────────────────────────────

  Future<void> demoAddMoney({required double amount}) async {
    _emitSafe(_withUpdating('add_money'));
    final result = await _repository.demoFundWallet(amount: amount);
    result.when(
      success: (res) {
        _emitSafe(WalletState.demoFundSuccess(
          newAvailableBalance: res.availableBalance,
          newLedgerBalance: res.ledgerBalance,
          newWithdrawableBalance: res.withdrawableBalance,
          amount: amount,
        ));
        _eventBus.emit(WalletFunded(
          amount: amount,
          newAvailableBalance: res.availableBalance,
        ));
        _onNotification?.call(
          WalletNotificationEvent.fundSuccess(
            amount: amount,
            currencySymbol: _currencySymbol,
          ),
        );
        // Reload wallet to get fresh data
        loadWallet();
      },
      failure: (error, _) {
        _emitSafe(WalletState.error(error));
        _eventBus.emit(WalletError(message: error));
      },
    );
  }

  // ── Demo withdraw (sandbox) ─────────────────────────────────────────

  Future<void> demoWithdraw({required double amount}) async {
    _emitSafe(_withUpdating('withdraw'));
    final result = await _repository.demoWithdrawWallet(amount: amount);
    result.when(
      success: (res) {
        _emitSafe(WalletState.demoWithdrawSuccess(
          newWithdrawableBalance: res.withdrawableBalance,
          amount: amount,
        ));
        _eventBus.emit(WalletWithdrawalRequested(
          amount: amount,
          currency: _currencySymbol,
          bankName: 'Demo',
          status: 'completed',
        ));
        loadWallet();
      },
      failure: (error, _) {
        _emitSafe(WalletState.error(error));
        _eventBus.emit(WalletError(message: error));
      },
    );
  }

  // ── Balance visibility ──────────────────────────────────────────────

  Future<void> toggleBalanceVisibility() async {
    final current = state.maybeMap(
      loaded: (s) => s.balanceVisible,
      orElse: () => true,
    );
    final newValue = !current;
    await _storage.setBalanceVisible(newValue);
    state.maybeMap(
      loaded: (s) => _emitSafe(s.copyWith(balanceVisible: newValue)),
      orElse: () {},
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  WalletState _withUpdating(String operation) {
    return state.maybeMap(
      loaded: (s) => WalletState.updating(
        wallet: s.wallet,
        balanceVisible: s.balanceVisible,
        operation: operation,
      ),
      orElse: () => const WalletState.loading(),
    );
  }

  void _emitSafe(WalletState s) {
    if (!isClosed) {
      WalletLogger.i.state('WalletCubit', 'state→${s.runtimeType}');
      emit(s);
    }
  }

  /// Preview mode only — inject a [Wallet] directly without an API call.
  void injectPreview(Wallet wallet) {
    if (!isClosed) emit(WalletState.loaded(wallet: wallet, balanceVisible: true));
  }
}