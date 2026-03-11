import '../../domain/models/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasource/wallet_remote_datasource.dart';
import '../../../../core/errors/wallet_result.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDatasource _datasource;

  WalletRepositoryImpl({WalletRemoteDatasource? datasource})
      : _datasource = datasource ?? WalletRemoteDatasourceImpl();

  @override
  Future<WalletResult<Wallet>> getWallet() async {
    try {
      final wallet = await _datasource.getWallet();
      return WalletResult.success(wallet);
    } catch (e) {
      return WalletResult.failure(_clean(e));
    }
  }

  @override
  Future<WalletResult<FundWalletResponse>> fundWallet({
    required double amount,
    required String redirectUrl,
  }) async {
    try {
      final res = await _datasource.fundWallet(
        amount: amount,
        redirectUrl: redirectUrl,
      );
      return WalletResult.success(res);
    } catch (e) {
      return WalletResult.failure(_clean(e));
    }
  }

  @override
  Future<WalletResult<DemoFundResponse>> demoFundWallet({
    required double amount,
    String? reference,
  }) async {
    try {
      final res = await _datasource.demoFundWallet(
        amount: amount,
        reference: reference,
      );
      return WalletResult.success(res);
    } catch (e) {
      return WalletResult.failure(_clean(e));
    }
  }

  @override
  Future<WalletResult<DemoWithdrawResponse>> demoWithdrawWallet({
    required double amount,
  }) async {
    try {
      final res = await _datasource.demoWithdrawWallet(amount: amount);
      return WalletResult.success(res);
    } catch (e) {
      return WalletResult.failure(_clean(e));
    }
  }

  String _clean(Object e) => e.toString().replaceFirst('Exception: ', '');
}