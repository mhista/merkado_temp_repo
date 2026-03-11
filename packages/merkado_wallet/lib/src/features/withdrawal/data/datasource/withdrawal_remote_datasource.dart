import 'package:dio/dio.dart';
import '../../domain/models/bank_account.dart';
import '../../domain/models/withdrawal_record.dart';
import '../../../../core/http/wallet_http_client.dart';

/// WithdrawalRemoteDatasource
/// ==========================
/// All withdrawal and bank account API calls.
///
/// Endpoints:
///   GET    /v1/withdrawal/banks               — list supported banks by currency
///   GET    /v1/withdrawal/bank-accounts       — user's saved bank accounts
///   POST   /v1/withdrawal/bank-account        — generic add bank account
///   POST   /v1/withdrawal/bank-account/ngn    — add NGN bank account
///   POST   /v1/withdrawal/bank-account/gbp    — add GBP bank account
///   POST   /v1/withdrawal/bank-account/eur    — add EUR bank account
///   POST   /v1/withdrawal/bank-account/usd    — add USD bank account
///   DELETE /v1/withdrawal/bank-account/{id}   — remove bank account
///   GET    /v1/withdrawal/history             — withdrawal history
///   POST   /v1/withdrawal/request             — request a withdrawal
abstract interface class WithdrawalRemoteDatasource {
  Future<List<SupportedBank>> getSupportedBanks({String currency = 'NGN'});
  Future<List<BankAccount>> getBankAccounts();
  Future<BankAccount> addBankAccountGeneric(Map<String, dynamic> data);
  Future<BankAccount> addNgnBankAccount(Map<String, dynamic> data);
  Future<BankAccount> addGbpBankAccount(Map<String, dynamic> data);
  Future<BankAccount> addEurBankAccount(Map<String, dynamic> data);
  Future<BankAccount> addUsdBankAccount(Map<String, dynamic> data);
  Future<void> deleteBankAccount(String id);
  Future<List<WithdrawalRecord>> getWithdrawalHistory();
  Future<WithdrawalRecord> requestWithdrawal({
    required String bankAccountId,
    required double amount,
  });
}

class WithdrawalRemoteDatasourceImpl implements WithdrawalRemoteDatasource {
  final WalletHttpClient _http = WalletHttpClient.instance;

  // ── GET /v1/withdrawal/banks ────────────────────────────────────────
  @override
  Future<List<SupportedBank>> getSupportedBanks({String currency = 'NGN'}) async {
    try {
      final response = await _http.get(
        '/v1/withdrawal/banks',
        queryParameters: {'currency': currency},
      );
      _assertSuccess(response, '/v1/withdrawal/banks GET');
      final raw = response.data;
      if (raw is List) {
        return raw
            .map((e) => SupportedBank.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      // If the API wraps in { data: [...] }
      if (raw is Map && raw['data'] is List) {
        return (raw['data'] as List)
            .map((e) => SupportedBank.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _dioError(e, '/v1/withdrawal/banks GET');
    }
  }

  // ── GET /v1/withdrawal/bank-accounts ───────────────────────────────
  @override
  Future<List<BankAccount>> getBankAccounts() async {
    try {
      final response = await _http.get('/v1/withdrawal/bank-accounts');
      _assertSuccess(response, '/v1/withdrawal/bank-accounts GET');
      final raw = response.data;
      final list = raw is List ? raw : (raw is Map ? raw['data'] as List? ?? [] : []);
      return (list as List)
          .map((e) => BankAccount.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _dioError(e, '/v1/withdrawal/bank-accounts GET');
    }
  }

  // ── POST /v1/withdrawal/bank-account ───────────────────────────────
  @override
  Future<BankAccount> addBankAccountGeneric(Map<String, dynamic> data) async {
    return _postBankAccount('/v1/withdrawal/bank-account', data);
  }

  // ── POST /v1/withdrawal/bank-account/ngn ───────────────────────────
  @override
  Future<BankAccount> addNgnBankAccount(Map<String, dynamic> data) async {
    return _postBankAccount('/v1/withdrawal/bank-account/ngn', data);
  }

  // ── POST /v1/withdrawal/bank-account/gbp ───────────────────────────
  @override
  Future<BankAccount> addGbpBankAccount(Map<String, dynamic> data) async {
    return _postBankAccount('/v1/withdrawal/bank-account/gbp', data);
  }

  // ── POST /v1/withdrawal/bank-account/eur ───────────────────────────
  @override
  Future<BankAccount> addEurBankAccount(Map<String, dynamic> data) async {
    return _postBankAccount('/v1/withdrawal/bank-account/eur', data);
  }

  // ── POST /v1/withdrawal/bank-account/usd ───────────────────────────
  @override
  Future<BankAccount> addUsdBankAccount(Map<String, dynamic> data) async {
    return _postBankAccount('/v1/withdrawal/bank-account/usd', data);
  }

  Future<BankAccount> _postBankAccount(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _http.post(endpoint, data: data);
      _assertSuccess(response, '$endpoint POST');
      return BankAccount.fromJson(
        response.data is Map ? response.data as Map<String, dynamic> : {},
      );
    } on DioException catch (e) {
      throw _dioError(e, '$endpoint POST');
    }
  }

  // ── DELETE /v1/withdrawal/bank-account/{id} ─────────────────────────
  @override
  Future<void> deleteBankAccount(String id) async {
    try {
      final response = await _http.delete('/v1/withdrawal/bank-account/$id');
      _assertSuccess(response, '/v1/withdrawal/bank-account/$id DELETE');
    } on DioException catch (e) {
      throw _dioError(e, '/v1/withdrawal/bank-account/$id DELETE');
    }
  }

  // ── GET /v1/withdrawal/history ──────────────────────────────────────
  @override
  Future<List<WithdrawalRecord>> getWithdrawalHistory() async {
    try {
      final response = await _http.get('/v1/withdrawal/history');
      _assertSuccess(response, '/v1/withdrawal/history GET');
      final raw = response.data;
      final list = raw is List ? raw : (raw is Map ? raw['data'] as List? ?? [] : []);
      return (list as List)
          .map((e) => WithdrawalRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _dioError(e, '/v1/withdrawal/history GET');
    }
  }

  // ── POST /v1/withdrawal/request ─────────────────────────────────────
  @override
  Future<WithdrawalRecord> requestWithdrawal({
    required String bankAccountId,
    required double amount,
  }) async {
    try {
      final response = await _http.post(
        '/v1/withdrawal/request',
        data: {'bankAccountId': bankAccountId, 'amount': amount},
      );
      _assertSuccess(response, '/v1/withdrawal/request POST');
      return WithdrawalRecord.fromJson(
        response.data is Map ? response.data as Map<String, dynamic> : {},
      );
    } on DioException catch (e) {
      throw _dioError(e, '/v1/withdrawal/request POST');
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  void _assertSuccess(dynamic response, String label) {
    if (response is! Response) return;
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