import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../../merkado_wallet.dart' show WalletUrls;
import '../../domain/models/bank_account.dart';
import '../../domain/models/withdrawal_record.dart';
import '../../../../core/http/wallet_http_client.dart';

/// WithdrawalRemoteDatasource
/// ==========================
/// All withdrawal and bank account API calls with detailed logging.
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

  // ── URL Switcher with Logging ─────────────────────────────────────
  Future<T> _withWalletUrl<T>(Future<T> Function() call, String operation) async {
    final baseUrl = WalletUrls.instance.baseUrl;
    final alternateUrl = WalletUrls.instance.alternateBaseUrl;

    debugPrint('🔄 [$operation] Switching to base URL: $baseUrl');
    
    _http.updateBaseUrl(baseUrl);

    try {
      final result = await call();
      debugPrint('✅ [$operation] Completed successfully');
      return result;
    } catch (e) {
      debugPrint('❌ [$operation] Failed with error: $e');
      rethrow;
    } finally {
      _http.updateBaseUrl(alternateUrl);
      debugPrint('🔄 [$operation] Restored alternate URL: $alternateUrl');
    }
  }

  // ── GET /v1/withdrawal/banks ────────────────────────────────────────
  @override
  Future<List<SupportedBank>> getSupportedBanks({String currency = 'NGN'}) =>
      _withWalletUrl(() async {
        debugPrint('📡 GET /v1/withdrawal/banks?currency=$currency');

        try {
          final response = await _http.get(
            '/v1/withdrawal/banks',
            queryParameters: {'currency': currency},
          );

          _logResponse(response, '/v1/withdrawal/banks GET');

          final raw = response.data;
          final List<SupportedBank> banks;

          if (raw is List) {
            banks = raw
                .map((e) => SupportedBank.fromJson(e as Map<String, dynamic>))
                .toList();
          } else if (raw is Map && raw['data'] is List) {
            banks = (raw['data'] as List)
                .map((e) => SupportedBank.fromJson(e as Map<String, dynamic>))
                .toList();
          } else {
            banks = [];
          }

          debugPrint('📊 Fetched ${banks.length} supported banks for $currency');
          return banks;
        } on DioException catch (e) {
          throw _dioError(e, '/v1/withdrawal/banks GET');
        }
      }, 'getSupportedBanks');

  // ── GET /v1/withdrawal/bank-accounts ───────────────────────────────
  @override
  Future<List<BankAccount>> getBankAccounts() =>
      _withWalletUrl(() async {
        debugPrint('📡 GET /v1/withdrawal/bank-accounts');

        try {
          final response = await _http.get('/v1/withdrawal/bank-accounts');
          _logResponse(response, '/v1/withdrawal/bank-accounts GET');

          final raw = response.data;
          final list = raw is List
              ? raw
              : (raw is Map ? raw['data'] as List? ?? [] : []);

          final accounts = (list as List)
              .map((e) => BankAccount.fromJson(e as Map<String, dynamic>))
              .toList();

          debugPrint('📊 Fetched ${accounts.length} bank accounts');
          return accounts;
        } on DioException catch (e) {
          throw _dioError(e, '/v1/withdrawal/bank-accounts GET');
        }
      }, 'getBankAccounts');

  // ── POST Bank Account Helpers ─────────────────────────────────────
  @override
  Future<BankAccount> addBankAccountGeneric(Map<String, dynamic> data) async =>
      _postBankAccount('/v1/withdrawal/bank-account', data, 'addBankAccountGeneric');

  @override
  Future<BankAccount> addNgnBankAccount(Map<String, dynamic> data) async =>
      _postBankAccount('/v1/withdrawal/bank-account/ngn', data, 'addNgnBankAccount');

  @override
  Future<BankAccount> addGbpBankAccount(Map<String, dynamic> data) async =>
      _postBankAccount('/v1/withdrawal/bank-account/gbp', data, 'addGbpBankAccount');

  @override
  Future<BankAccount> addEurBankAccount(Map<String, dynamic> data) async =>
      _postBankAccount('/v1/withdrawal/bank-account/eur', data, 'addEurBankAccount');

  @override
  Future<BankAccount> addUsdBankAccount(Map<String, dynamic> data) async =>
      _postBankAccount('/v1/withdrawal/bank-account/usd', data, 'addUsdBankAccount');

  Future<BankAccount> _postBankAccount(
    String endpoint,
    Map<String, dynamic> data,
    String operationName,
  ) =>
      _withWalletUrl(() async {
        debugPrint('📡 POST $endpoint');
        debugPrint('📦 Request Body: $data');

        try {
          final response = await _http.post(endpoint, data: data);
          _logResponse(response, '$endpoint POST');

          final bankAccount = BankAccount.fromJson(
            response.data is Map ? response.data as Map<String, dynamic> : {},
          );

          debugPrint('✅ Bank account added successfully: ${bankAccount.id}');
          return bankAccount;
        } on DioException catch (e) {
          throw _dioError(e, '$endpoint POST');
        }
      }, operationName);

  // ── DELETE /v1/withdrawal/bank-account/{id} ─────────────────────────
  @override
  Future<void> deleteBankAccount(String id) =>
      _withWalletUrl(() async {
        debugPrint('🗑️ DELETE /v1/withdrawal/bank-account/$id');

        try {
          final response = await _http.delete('/v1/withdrawal/bank-account/$id');
          _logResponse(response, '/v1/withdrawal/bank-account/$id DELETE');
          debugPrint('✅ Bank account deleted successfully: $id');
        } on DioException catch (e) {
          throw _dioError(e, '/v1/withdrawal/bank-account/$id DELETE');
        }
      }, 'deleteBankAccount');

  // ── GET /v1/withdrawal/history ──────────────────────────────────────
  @override
  Future<List<WithdrawalRecord>> getWithdrawalHistory() =>
      _withWalletUrl(() async {
        debugPrint('📡 GET /v1/withdrawal/history');

        try {
          final response = await _http.get('/v1/withdrawal/history');
          _logResponse(response, '/v1/withdrawal/history GET');

          final raw = response.data;
          final list = raw is List
              ? raw
              : (raw is Map ? raw['data'] as List? ?? [] : []);

          final records = (list as List)
              .map((e) => WithdrawalRecord.fromJson(e as Map<String, dynamic>))
              .toList();

          debugPrint('📊 Fetched ${records.length} withdrawal records');
          return records;
        } on DioException catch (e) {
          throw _dioError(e, '/v1/withdrawal/history GET');
        }
      }, 'getWithdrawalHistory');

  // ── POST /v1/withdrawal/request ─────────────────────────────────────
  @override
  Future<WithdrawalRecord> requestWithdrawal({
    required String bankAccountId,
    required double amount,
  }) =>
      _withWalletUrl(() async {
        final payload = {'bankAccountId': bankAccountId, 'amount': amount};
        debugPrint('📡 POST /v1/withdrawal/request');
        debugPrint('📦 Request Body: $payload');

        try {
          final response = await _http.post(
            '/v1/withdrawal/request',
            data: payload,
          );
          _logResponse(response, '/v1/withdrawal/request POST');

          final record = WithdrawalRecord.fromJson(
            response.data is Map ? response.data as Map<String, dynamic> : {},
          );

          debugPrint('✅ Withdrawal request successful: ${record.id} | Amount: $amount');
          return record;
        } on DioException catch (e) {
          throw _dioError(e, '/v1/withdrawal/request POST');
        }
      }, 'requestWithdrawal');

  // ── Logging Helpers ─────────────────────────────────────────────────

  void _logResponse(Response response, String label) {
    final statusCode = response.statusCode ?? 0;
    debugPrint('📥 $label → Status: $statusCode');

    if (kDebugMode) {
      debugPrint('📦 Response Data: ${response.data}');
    }
  }

  void _assertSuccess(Response? response, String label) {
    if (response == null) return;

    final code = response.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      debugPrint('⚠️ $label failed with status [$code]');
      if (kDebugMode) {
        debugPrint('📦 Error Response: ${response.data}');
      }

      final msg = _extractMessage(response.data);
      throw Exception('$label failed [$code]: $msg');
    }
  }

  String _extractMessage(dynamic data) {
    if (data is Map) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          data['detail']?.toString() ??
          'Unknown error';
    }
    return data?.toString() ?? 'Unknown error';
  }

  Exception _dioError(DioException e, String label) {
    final statusCode = e.response?.statusCode;
    final msg = _extractMessage(e.response?.data);

    debugPrint('🚨 DioError in $label → Status: $statusCode | Message: $msg');
    if (kDebugMode && e.response?.data != null) {
      debugPrint('📦 Error Body: ${e.response?.data}');
    }

    return Exception(' $msg');
  }
}