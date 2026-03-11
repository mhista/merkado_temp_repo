import 'package:json_annotation/json_annotation.dart';

part 'bank_account.g.dart';

/// BankAccount — a saved withdrawal destination.
///
/// Supports NGN (Nigerian bank), GBP (UK), EUR (SEPA), and USD (SWIFT).
/// The [currency] field determines which add-account flow to use.
@JsonSerializable()
class BankAccount {
  final String id;
  final String userId;
  final String bankName;
  final String bankCode;
  final String accountNumber;
  final String accountName;
  final String currency;
  final String country;
  final String beneficiaryType; // 'individual' | 'business'
  final bool isDefault;

  // Optional personal details
  final dynamic firstName;
  final dynamic lastName;
  final dynamic email;
  final dynamic phone;

  // International fields
  final dynamic paymentScheme;    // 'sepa' | 'fps' | 'swift'
  final dynamic bankSwiftCode;
  final dynamic sortCode;
  final dynamic beneficiaryAddress;
  final dynamic bankAddress;
  final dynamic metadata;

  final DateTime createdAt;

  const BankAccount({
    required this.id,
    required this.userId,
    required this.bankName,
    required this.bankCode,
    required this.accountNumber,
    required this.accountName,
    required this.currency,
    required this.country,
    required this.beneficiaryType,
    required this.isDefault,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.paymentScheme,
    this.bankSwiftCode,
    this.sortCode,
    this.beneficiaryAddress,
    this.bankAddress,
    this.metadata,
    required this.createdAt,
  });

  /// Display label e.g. "First Bank • •••• 7890"
  String get displayLabel => '$bankName • ••••${accountNumber.length >= 4 ? accountNumber.substring(accountNumber.length - 4) : accountNumber}';

  factory BankAccount.fromJson(Map<String, dynamic> json) =>
      _$BankAccountFromJson(json);
  Map<String, dynamic> toJson() => _$BankAccountToJson(this);
}

/// Supported bank from GET /v1/withdrawal/banks
@JsonSerializable()
class SupportedBank {
  final String name;
  final String code;
  final String? slug;
  final String? country;
  final String? currency;

  const SupportedBank({
    required this.name,
    required this.code,
    this.slug,
    this.country,
    this.currency,
  });

  factory SupportedBank.fromJson(Map<String, dynamic> json) =>
      _$SupportedBankFromJson(json);
  Map<String, dynamic> toJson() => _$SupportedBankToJson(this);
}

/// Currency type for bank account flows
enum BankCurrency {
  ngn('NGN', 'Nigerian Naira', 'NG', '₦'),
  gbp('GBP', 'British Pound', 'GB', '£'),
  eur('EUR', 'Euro', '', '€'),
  usd('USD', 'US Dollar', 'US', '\$');

  const BankCurrency(this.code, this.label, this.country, this.symbol);
  final String code;
  final String label;
  final String country;
  final String symbol;

  String get endpoint => '/v1/withdrawal/bank-account/${code.toLowerCase()}';
}