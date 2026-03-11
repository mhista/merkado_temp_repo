import 'package:flutter/material.dart';
import '../../features/wallet/domain/models/wallet.dart';
import '../../features/withdrawal/domain/models/bank_account.dart';
import '../../features/withdrawal/domain/models/withdrawal_record.dart';

/// CustomWalletScreens
/// ===================
/// Override any built-in screen while the package manages ALL data
/// and state internally. Custom screens receive the relevant cubit
/// and can call its methods directly.
///
/// EXAMPLE — replace only the wallet home screen:
/// ```dart
/// CustomWalletScreens(
///   homeScreenBuilder: (context, cubit) => MyCustomWalletHome(cubit: cubit),
/// )
/// ```
class CustomWalletScreens {
  /// Replace the wallet home screen.
  /// Receives the wallet cubit for reading balance and triggering actions.
  final Widget Function(BuildContext context, dynamic walletCubit)?
      homeScreenBuilder;

  /// Replace the "Add Money" flow screen.
  final Widget Function(BuildContext context, dynamic walletCubit)?
      addMoneyScreenBuilder;

  /// Replace the full withdrawal screen.
  final Widget Function(BuildContext context, dynamic withdrawalCubit)?
      withdrawScreenBuilder;

  /// Replace the withdrawal history / recent activity screen.
  final Widget Function(BuildContext context, List<WithdrawalRecord> history)?
      historyScreenBuilder;

  /// Replace the bank accounts management screen.
  final Widget Function(BuildContext context, List<BankAccount> accounts,
      dynamic withdrawalCubit)? bankAccountsScreenBuilder;

  /// Replace the "Add Bank Account" screen.
  final Widget Function(BuildContext context, dynamic withdrawalCubit,
      String currency)? addBankAccountScreenBuilder;

  /// Replace the PIN setup screen.
  final Widget Function(BuildContext context, dynamic pinCubit)?
      pinSetupScreenBuilder;

  /// Replace the PIN verify screen.
  /// [onVerified] must be called when PIN is verified successfully.
  final Widget Function(
          BuildContext context, dynamic pinCubit, VoidCallback onVerified)?
      pinVerifyScreenBuilder;

  const CustomWalletScreens({
    this.homeScreenBuilder,
    this.addMoneyScreenBuilder,
    this.withdrawScreenBuilder,
    this.historyScreenBuilder,
    this.bankAccountsScreenBuilder,
    this.addBankAccountScreenBuilder,
    this.pinSetupScreenBuilder,
    this.pinVerifyScreenBuilder,
  });
}