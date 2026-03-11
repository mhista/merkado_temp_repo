import '../../domain/models/bank_account.dart';
import '../../domain/models/withdrawal_record.dart';
import '../../../../core/errors/wallet_result.dart';

/// WithdrawalRepository — abstract interface
abstract interface class WithdrawalRepository {
  Future<WalletResult<List<SupportedBank>>> getSupportedBanks({String currency});
  Future<WalletResult<List<BankAccount>>> getBankAccounts();
  Future<WalletResult<BankAccount>> addBankAccount({
    required BankCurrency currency,
    required Map<String, dynamic> data,
  });
  Future<WalletResult<void>> deleteBankAccount(String id);
  Future<WalletResult<List<WithdrawalRecord>>> getWithdrawalHistory();
  Future<WalletResult<WithdrawalRecord>> requestWithdrawal({
    required String bankAccountId,
    required double amount,
  });
}