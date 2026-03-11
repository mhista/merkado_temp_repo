import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/repository/withdraw_repository_impl.dart';
import '../../domain/models/bank_account.dart';
import '../../domain/models/withdrawal_record.dart';
import '../../domain/repositories/withdrawal_repository.dart';
import '../../../../core/events/wallet_event_bus.dart';
import '../../../../core/events/wallet_notification_event.dart';
import '../../../../core/logging/wallet_logger.dart';
import '../../../../features/pin/pin_service.dart';

part 'withdrawal_state.dart';
part 'withdrawal_cubit.freezed.dart';

/// WithdrawalCubit
/// ===============
/// Manages withdrawal flow: bank accounts, history, and withdrawal requests.
/// PIN verification is handled before calling [requestWithdrawal].
class WithdrawalCubit extends Cubit<WithdrawalState> {
  final WithdrawalRepository _repository;
  final WalletEventBus _eventBus = WalletEventBus.instance;
  final PinService _pinService = PinService.instance;

  String _currencySymbol = '₦';
  void Function(WalletNotificationEvent)? _onNotification;

  WithdrawalCubit({WithdrawalRepository? repository})
      : _repository = repository ?? WithdrawalRepositoryImpl(),
        super(const WithdrawalState.initial());

  void configure({
    String? currencySymbol,
    void Function(WalletNotificationEvent)? onNotification,
  }) {
    if (currencySymbol != null) _currencySymbol = currencySymbol;
    if (onNotification != null) _onNotification = onNotification;
  }

  // ── Load bank accounts ──────────────────────────────────────────────

  Future<void> loadBankAccounts() async {
    WalletLogger.i.state('WithdrawalCubit', 'loadBankAccounts');
    _emitSafe(const WithdrawalState.loading());
    final result = await _repository.getBankAccounts();
    result.when(
      success: (accounts) => _emitSafe(
        WithdrawalState.bankAccountsLoaded(accounts: accounts),
      ),
      failure: (error, _) {
        _emitSafe(WithdrawalState.error(error));
        _eventBus.emit(WalletError(message: error));
      },
    );
  }

  // ── Load supported banks ─────────────────────────────────────────────

  Future<List<SupportedBank>> getSupportedBanks({String currency = 'NGN'}) async {
    final result = await _repository.getSupportedBanks(currency: currency);
    return result.valueOrNull ?? [];
  }

  // ── Add bank account ─────────────────────────────────────────────────

  Future<void> addBankAccount({
    required BankCurrency currency,
    required Map<String, dynamic> data,
  }) async {
    _emitSafe(const WithdrawalState.loading());
    final result = await _repository.addBankAccount(
      currency: currency,
      data: data,
    );
    result.when(
      success: (account) {
        _emitSafe(WithdrawalState.bankAccountAdded(account: account));
        _eventBus.emit(WalletBankAccountAdded(
          bankName: account.bankName,
          accountNumber: account.accountNumber,
          currency: account.currency,
        ));
        _onNotification?.call(WalletNotificationEvent(
          type: WalletNotificationType.bankAccountAdded,
          title: 'Bank account added',
          body: '${account.bankName} has been added for withdrawals.',
          channelId: 'wallet_system',
        ));
        // Reload accounts list
        loadBankAccounts();
      },
      failure: (error, _) {
        _emitSafe(WithdrawalState.error(error));
        _eventBus.emit(WalletError(message: error));
      },
    );
  }

  // ── Delete bank account ───────────────────────────────────────────────

  Future<void> deleteBankAccount(String id) async {
    _emitSafe(const WithdrawalState.loading());
    final result = await _repository.deleteBankAccount(id);
    result.when(
      success: (_) {
        _eventBus.emit(WalletBankAccountRemoved(bankAccountId: id));
        loadBankAccounts();
      },
      failure: (error, _) {
        _emitSafe(WithdrawalState.error(error));
        _eventBus.emit(WalletError(message: error));
      },
    );
  }

  // ── Request withdrawal ──────────────────────────────────────────────
  /// Call this AFTER PIN has been verified (PinCubit.verifyPin succeeded).
  Future<void> requestWithdrawal({
    required String bankAccountId,
    required double amount,
    required BankAccount bankAccount,
  }) async {
    WalletLogger.i.state('WithdrawalCubit', 'requestWithdrawal', data: {
      'amount': amount,
      'bankName': bankAccount.bankName,
      'currency': bankAccount.currency,
    });
    _emitSafe(const WithdrawalState.loading());

    final result = await _repository.requestWithdrawal(
      bankAccountId: bankAccountId,
      amount: amount,
    );
    result.when(
      success: (record) {
        _emitSafe(WithdrawalState.withdrawalSuccess(record: record));
        _eventBus.emit(WalletWithdrawalRequested(
          amount: amount,
          currency: record.currency,
          bankName: bankAccount.bankName,
          status: record.status.name,
        ));
        _onNotification?.call(
          WalletNotificationEvent.withdrawalRequested(
            amount: amount,
            currencySymbol: _currencySymbol,
            bankName: bankAccount.bankName,
          ),
        );
      },
      failure: (error, _) {
        _emitSafe(WithdrawalState.error(error));
        _eventBus.emit(WalletError(message: error));
        _onNotification?.call(
          WalletNotificationEvent.withdrawalFailed(
            amount: amount,
            currencySymbol: _currencySymbol,
            reason: error,
          ),
        );
      },
    );
  }

  // ── Load withdrawal history ─────────────────────────────────────────

  Future<void> loadHistory() async {
    _emitSafe(const WithdrawalState.loading());
    final result = await _repository.getWithdrawalHistory();
    result.when(
      success: (history) => _emitSafe(
        WithdrawalState.historyLoaded(records: history),
      ),
      failure: (error, _) {
        _emitSafe(WithdrawalState.error(error));
        _eventBus.emit(WalletError(message: error));
      },
    );
  }

  void _emitSafe(WithdrawalState s) {
    if (!isClosed) {
      WalletLogger.i.state('WithdrawalCubit', 'state→${s.runtimeType}');
      emit(s);
    }
  }

  /// Preview mode only — inject bank accounts and history without API calls.
  void injectPreview({
    required List<BankAccount> bankAccounts,
    required List<WithdrawalRecord> withdrawalHistory,
  }) {
    if (!isClosed) emit(WithdrawalState.bankAccountsLoaded(accounts: bankAccounts));
  }
}