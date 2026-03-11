import 'dart:convert';
import 'package:dio/dio.dart';
import '../../features/withdrawal/domain/models/bank_account.dart';

/// NigerianBankService
/// ===================
/// Fetches the list of Nigerian banks from Paystack's public API.
/// This is a free, public endpoint that requires no authentication
/// and provides the most comprehensive, up-to-date list of Nigerian banks.
///
/// Used as a fallback / supplement to the wallet API's bank list.
/// Results are cached in-memory for the session.
///
/// Paystack public banks endpoint:
///   GET https://api.paystack.co/bank?country=nigeria&currency=NGN
///
/// This is intentionally a standalone service with no dependency on
/// the wallet HTTP client — it uses its own Dio instance with no auth.
class NigerianBankService {
  NigerianBankService._();

  static NigerianBankService? _instance;
  static NigerianBankService get instance {
    _instance ??= NigerianBankService._();
    return _instance!;
  }

  static const _paystackBanksUrl =
      'https://api.paystack.co/bank?country=nigeria&currency=NGN&perPage=200';

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  List<SupportedBank>? _cache;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(hours: 6);

  bool get _isCacheValid =>
      _cache != null &&
      _cacheTime != null &&
      DateTime.now().difference(_cacheTime!) < _cacheDuration;

  /// Fetch list of Nigerian banks.
  /// Returns cached list if fresh, otherwise fetches from Paystack.
  Future<List<SupportedBank>> getBanks() async {
    if (_isCacheValid) return _cache!;

    try {
      final response = await _dio.get(_paystackBanksUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['status'] == true && data['data'] is List) {
          _cache = (data['data'] as List)
              .map((b) => SupportedBank(
                    name: b['name']?.toString() ?? '',
                    code: b['code']?.toString() ?? '',
                    slug: b['slug']?.toString(),
                    country: 'NG',
                    currency: 'NGN',
                  ))
              .where((b) => b.name.isNotEmpty && b.code.isNotEmpty)
              .toList();
          _cacheTime = DateTime.now();
          return _cache!;
        }
      }
    } catch (_) {
      // Fall through to hardcoded fallback
    }

    // Hardcoded fallback — major Nigerian banks always available offline
    _cache = _fallbackNigerianBanks;
    _cacheTime = DateTime.now();
    return _cache!;
  }

  /// Look up a bank by code.
  Future<SupportedBank?> findByCode(String code) async {
    final banks = await getBanks();
    try {
      return banks.firstWhere((b) => b.code == code);
    } catch (_) {
      return null;
    }
  }

  void clearCache() {
    _cache = null;
    _cacheTime = null;
  }

  // ── Hardcoded fallback for major Nigerian banks ──────────────────────
  static final List<SupportedBank> _fallbackNigerianBanks = [
    const SupportedBank(name: 'Access Bank', code: '044', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Citibank Nigeria', code: '023', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Diamond Bank', code: '063', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Ecobank Nigeria', code: '050', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Fidelity Bank', code: '070', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'First Bank of Nigeria', code: '011', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'First City Monument Bank', code: '214', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Globus Bank', code: '00103', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Guaranty Trust Bank', code: '058', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Heritage Bank', code: '030', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Jaiz Bank', code: '301', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Keystone Bank', code: '082', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Kuda Microfinance Bank', code: '50211', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Moniepoint MFB', code: '50515', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'OPay', code: '999992', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'PalmPay', code: '999991', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Polaris Bank', code: '076', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Providus Bank', code: '101', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Stanbic IBTC Bank', code: '039', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Standard Chartered Bank', code: '068', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Sterling Bank', code: '232', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Suntrust Bank Nigeria', code: '100', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'TITAN Trust Bank', code: '00333', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Union Bank of Nigeria', code: '032', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'United Bank for Africa', code: '033', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Unity Bank', code: '215', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'VFD Microfinance Bank', code: '566', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Wema Bank', code: '035', country: 'NG', currency: 'NGN'),
    const SupportedBank(name: 'Zenith Bank', code: '057', country: 'NG', currency: 'NGN'),
  ];
}