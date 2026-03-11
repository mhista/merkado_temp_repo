part of 'withdrawal_cubit.dart';

@freezed
class WithdrawalState with _$WithdrawalState {
  const factory WithdrawalState.initial() = _Initial;
  const factory WithdrawalState.loading() = _Loading;

  const factory WithdrawalState.bankAccountsLoaded({
    required List<BankAccount> accounts,
  }) = _BankAccountsLoaded;

  const factory WithdrawalState.bankAccountAdded({
    required BankAccount account,
  }) = _BankAccountAdded;

  const factory WithdrawalState.historyLoaded({
    required List<WithdrawalRecord> records,
  }) = _HistoryLoaded;

  const factory WithdrawalState.withdrawalSuccess({
    required WithdrawalRecord record,
  }) = _WithdrawalSuccess;

  const factory WithdrawalState.error(String message) = _Error;
}