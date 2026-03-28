import 'package:json_annotation/json_annotation.dart';

part 'wallet.g.dart';

/// WalletStatus — mirrors backend status enum
enum WalletStatus {
  @JsonValue('active') active,
  @JsonValue('frozen') frozen,
  @JsonValue('suspended') suspended,
}

/// Wallet — the user's Merkado OS wallet.
///
/// The backend returns three balance fields:
///   [availableBalance]   — funds the user can spend right now
///   [ledgerBalance]      — total balance (available + escrowed)
///   [withdrawableBalance]— subset of available that can be cashed out
///
/// All balance values come as strings from the API ("5000.00") and are
/// parsed to double here for arithmetic convenience.
@JsonSerializable()
class Wallet {
  final String id;
  final String userId;
  final String currency;

  @JsonKey(name: 'availableBalance', fromJson: _parseDouble)
  final double availableBalance;

  @JsonKey(name: 'ledgerBalance', fromJson: _parseDouble)
  final double ledgerBalance;

  @JsonKey(name: 'withdrawableBalance', fromJson: _parseDouble)
  final double withdrawableBalance;

  final WalletStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wallet({
    required this.id,
    required this.userId,
    required this.currency,
    required this.availableBalance,
    required this.ledgerBalance,
    required this.withdrawableBalance,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // ── Derived ──────────────────────────────────────────────────────────
  bool get isActive => status == WalletStatus.active;

  /// Funds locked in escrow (ledger - available)
  double get escrowedBalance => ledgerBalance - availableBalance;

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
  Map<String, dynamic> toJson() => _$WalletToJson(this);

  Wallet copyWith({
    double? availableBalance,
    double? ledgerBalance,
    double? withdrawableBalance,
    WalletStatus? status,
    DateTime? updatedAt,
  }) {
    return Wallet(
      id: id,
      userId: userId,
      currency: currency,
      availableBalance: availableBalance ?? this.availableBalance,
      ledgerBalance: ledgerBalance ?? this.ledgerBalance,
      withdrawableBalance: withdrawableBalance ?? this.withdrawableBalance,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

/// Response from POST /v1/wallet/fund
@JsonSerializable()
class FundWalletResponse {
  final String message;
  final String checkoutUrl;
  final String provider;
  final double amount;
  final String currency;
  final String reference;

  const FundWalletResponse({
    required this.message,
    required this.checkoutUrl,
    required this.provider,
    required this.amount,
    required this.currency,
    required this.reference,
  });

  factory FundWalletResponse.fromJson(Map<String, dynamic> json) =>
      _$FundWalletResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FundWalletResponseToJson(this);
}

/// Response from POST /v1/wallet/demo/fund
@JsonSerializable()
class DemoFundResponse {
  final String message;
  final String walletId;

  @JsonKey(fromJson: _parseDouble)
  final double availableBalance;

  @JsonKey(fromJson: _parseDouble)
  final double ledgerBalance;

  @JsonKey(fromJson: _parseDouble)
  final double withdrawableBalance;

  const DemoFundResponse({
    required this.message,
    required this.walletId,
    required this.availableBalance,
    required this.ledgerBalance,  
    required this.withdrawableBalance,
  });

  factory DemoFundResponse.fromJson(Map<String, dynamic> json) =>
      _$DemoFundResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DemoFundResponseToJson(this);
}

/// Response from POST /v1/wallet/demo/withdraw
@JsonSerializable()
class DemoWithdrawResponse {
  final String message;
  final String walletId;

  @JsonKey(fromJson: _parseDouble)
  final double withdrawableBalance;

  const DemoWithdrawResponse({
    required this.message,
    required this.walletId,
    required this.withdrawableBalance,
  });

  factory DemoWithdrawResponse.fromJson(Map<String, dynamic> json) =>
      _$DemoWithdrawResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DemoWithdrawResponseToJson(this);
}