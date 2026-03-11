import '../models/wallet.dart';
import '../../../../core/errors/wallet_result.dart';

/// WalletRepository — abstract interface
abstract interface class WalletRepository {
  Future<WalletResult<Wallet>> getWallet();
  Future<WalletResult<FundWalletResponse>> fundWallet({
    required double amount,
    required String redirectUrl,
  });
  Future<WalletResult<DemoFundResponse>> demoFundWallet({
    required double amount,
    String? reference,
  });
  Future<WalletResult<DemoWithdrawResponse>> demoWithdrawWallet({
    required double amount,
  });
}