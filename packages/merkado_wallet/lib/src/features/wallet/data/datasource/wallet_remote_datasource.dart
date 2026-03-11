import 'package:dio/dio.dart';
import '../../domain/models/wallet.dart';
import '../../../../core/http/wallet_http_client.dart';

/// WalletRemoteDatasource
/// ======================
/// All wallet API calls.
///
/// API base: https://wallet-api.merkado.site
///
/// Endpoints:
///   GET  /v1/wallet                — fetch wallet
///   POST /v1/wallet/fund           — initiate real funding (returns checkout URL)
///   POST /v1/wallet/demo/fund      — fund in demo/sandbox mode
///   POST /v1/wallet/demo/withdraw  — withdraw in demo/sandbox mode
abstract interface class WalletRemoteDatasource {
  Future<Wallet> getWallet();

  Future<FundWalletResponse> fundWallet({
    required double amount,
    required String redirectUrl,
  });

  Future<DemoFundResponse> demoFundWallet({
    required double amount,
    String? reference,
  });

  Future<DemoWithdrawResponse> demoWithdrawWallet({required double amount});
}

class WalletRemoteDatasourceImpl implements WalletRemoteDatasource {
  final WalletHttpClient _http = WalletHttpClient.instance;

  // ── GET /v1/wallet ──────────────────────────────────────────────────
  @override
  Future<Wallet> getWallet() async {
    try {
      final response = await _http.get('/v1/wallet');
      _assertSuccess(response, '/v1/wallet GET');
      final data = response.data is Map ? response.data as Map<String, dynamic> : {'':''};
      return Wallet.fromJson(data);
    } on DioException catch (e) {
      throw _dioError(e, '/v1/wallet GET');
    }
  }

  // ── POST /v1/wallet/fund ────────────────────────────────────────────
  /// Initiates a real funding flow.
  /// Returns a [FundWalletResponse] containing a [checkoutUrl] to open
  /// in a WebView or browser.
  @override
  Future<FundWalletResponse> fundWallet({
    required double amount,
    required String redirectUrl,
  }) async {
    try {
      final response = await _http.post(
        '/v1/wallet/fund',
        data: {'amount': amount, 'redirectUrl': redirectUrl},
      );
      _assertSuccess(response, '/v1/wallet/fund POST');
      return FundWalletResponse.fromJson(
        response.data is Map ? response.data as Map<String, dynamic> : {},
      );
    } on DioException catch (e) {
      throw _dioError(e, '/v1/wallet/fund POST');
    }
  }

  // ── POST /v1/wallet/demo/fund ───────────────────────────────────────
  /// Instantly credits the wallet in demo/sandbox mode.
  /// No payment gateway involved.
  @override
  Future<DemoFundResponse> demoFundWallet({
    required double amount,
    String? reference,
  }) async {
    try {
      final response = await _http.post(
        '/v1/wallet/demo/fund',
        data: {
          'amount': amount,
          if (reference != null) 'reference': reference,
        },
      );
      _assertSuccess(response, '/v1/wallet/demo/fund POST');
      return DemoFundResponse.fromJson(
        response.data is Map ? response.data as Map<String, dynamic> : {},
      );
    } on DioException catch (e) {
      throw _dioError(e, '/v1/wallet/demo/fund POST');
    }
  }

  // ── POST /v1/wallet/demo/withdraw ───────────────────────────────────
  @override
  Future<DemoWithdrawResponse> demoWithdrawWallet({required double amount}) async {
    try {
      final response = await _http.post(
        '/v1/wallet/demo/withdraw',
        data: {'amount': amount},
      );
      _assertSuccess(response, '/v1/wallet/demo/withdraw POST');
      return DemoWithdrawResponse.fromJson(
        response.data is Map ? response.data as Map<String, dynamic> : {},
      );
    } on DioException catch (e) {
      throw _dioError(e, '/v1/wallet/demo/withdraw POST');
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  void _assertSuccess(Response response, String label) {
    final code = response.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      final msg = _extractMessage(response.data);
      throw Exception('$label failed [$code]: $msg');
    }
  }

  String _extractMessage(dynamic data) {
    if (data is Map) {
      return data['message']?.toString() ?? data['error']?.toString() ?? 'Unknown error';
    }
    return data?.toString() ?? 'Unknown error';
  }

  Exception _dioError(DioException e, String label) {
    final code = e.response?.statusCode;
    final msg = _extractMessage(e.response?.data);
    return Exception('$label error [$code]: $msg');
  }
}