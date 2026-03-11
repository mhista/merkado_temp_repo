import '../../domain/models/bank_account.dart';
import '../../domain/models/withdrawal_record.dart';
import '../../domain/repositories/withdrawal_repository.dart';
import '../datasource/withdrawal_remote_datasource.dart';
import '../../../../core/errors/wallet_result.dart';
import '../../../../services/banks/nigerian_bank_service.dart';

class WithdrawalRepositoryImpl implements WithdrawalRepository {
  final WithdrawalRemoteDatasource _datasource;

  WithdrawalRepositoryImpl({WithdrawalRemoteDatasource? datasource})
      : _datasource = datasource ?? WithdrawalRemoteDatasourceImpl();

  @override
  Future<WalletResult<List<SupportedBank>>> getSupportedBanks({
    String currency = 'NGN',
  }) async {
    try {
      // For NGN, prefer Paystack's public API (more complete, always fresh)
      // then fall back to the wallet API.
      if (currency.toUpperCase() == 'NGN') {
        final paystackBanks = await NigerianBankService.instance.getBanks();
        if (paystackBanks.isNotEmpty) {
          return WalletResult.success(paystackBanks);
        }
      }
      // For other currencies or if Paystack fails, use the wallet API
      final banks = await _datasource.getSupportedBanks(currency: currency);
      return WalletResult.success(banks);
    } catch (e) {
      return WalletResult.failure(_clean(e));
    }
  }

  @override
  Future<WalletResult<List<BankAccount>>> getBankAccounts() async {
    try {
      final accounts = await _datasource.getBankAccounts();
      return WalletResult.success(accounts);
    } catch (e) {
      return WalletResult.failure(_clean(e));
    }
  }

  @override
  Future<WalletResult<BankAccount>> addBankAccount({
    required BankCurrency currency,
    required Map<String, dynamic> data,
  }) async {
    try {
      final BankAccount account;
      switch (currency) {
        case BankCurrency.ngn:
          account = await _datasource.addNgnBankAccount(data);
        case BankCurrency.gbp:
          account = await _datasource.addGbpBankAccount(data);
        case BankCurrency.eur:
          account = await _datasource.addEurBankAccount(data);
        case BankCurrency.usd:
          account = await _datasource.addUsdBankAccount(data);
      }
      return WalletResult.success(account);
    } catch (e) {
      return WalletResult.failure(_clean(e));
    }
  }

  @override
  Future<WalletResult<void>> deleteBankAccount(String id) async {
    try {
      await _datasource.deleteBankAccount(id);
      return WalletResult.success(null);
    } catch (e) {
      return WalletResult.failure(_clean(e));
    }
  }

  @override
  Future<WalletResult<List<WithdrawalRecord>>> getWithdrawalHistory() async {
    try {
      final history = await _datasource.getWithdrawalHistory();
      return WalletResult.success(history);
    } catch (e) {
      return WalletResult.failure(_clean(e));
    }
  }

  @override
  Future<WalletResult<WithdrawalRecord>> requestWithdrawal({
    required String bankAccountId,
    required double amount,
  }) async {
    try {
      final record = await _datasource.requestWithdrawal(
        bankAccountId: bankAccountId,
        amount: amount,
      );
      return WalletResult.success(record);
    } catch (e) {
      return WalletResult.failure(_clean(e));
    }
  }

  String _clean(Object e) => e.toString().replaceFirst('Exception: ', '');
}