part of 'wallet_cubit.dart';

@freezed
class WalletState with _$WalletState {
  const factory WalletState.initial() = _Initial;
  const factory WalletState.loading() = _Loading;

  const factory WalletState.loaded({
    required Wallet wallet,
    required bool balanceVisible,
  }) = _Loaded;

  /// An operation is running but we still have wallet data to show.
  const factory WalletState.updating({
    required Wallet wallet,
    required bool balanceVisible,
    required String operation,
  }) = _Updating;

  /// Real funding flow — checkout URL ready to open in WebView/browser.
  const factory WalletState.fundInitiated({
    required String checkoutUrl,
    required String reference,
    required String provider,
    required double amount,
  }) = _FundInitiated;

  /// Demo fund completed.
  const factory WalletState.demoFundSuccess({
    required double newAvailableBalance,
    required double newLedgerBalance,
    required double newWithdrawableBalance,
    required double amount,
  }) = _DemoFundSuccess;

  /// Demo withdraw completed.
  const factory WalletState.demoWithdrawSuccess({
    required double newWithdrawableBalance,
    required double amount,
  }) = _DemoWithdrawSuccess;

  const factory WalletState.error(String message) = _Error;
}