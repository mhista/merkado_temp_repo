import 'package:json_annotation/json_annotation.dart';

part 'withdrawal_record.g.dart';

enum WithdrawalStatus {
  @JsonValue('pending') pending,
  @JsonValue('processing') processing,
  @JsonValue('completed') completed,
  @JsonValue('failed') failed,
}

/// A withdrawal record from GET /v1/withdrawal/history
@JsonSerializable()
class WithdrawalRecord {
  final String id;
  final String walletId;
  final String bankAccountId;

  @JsonKey(fromJson: _parseDouble)
  final double amount;

  final String currency;
  final WithdrawalStatus status;
  final dynamic gatewayReference;
  final dynamic failureReason;
  final dynamic processedAt;
  final DateTime createdAt;

  const WithdrawalRecord({
    required this.id,
    required this.walletId,
    required this.bankAccountId,
    required this.amount,
    required this.currency,
    required this.status,
    this.gatewayReference,
    this.failureReason,
    this.processedAt,
    required this.createdAt,
  });

  bool get isCompleted => status == WithdrawalStatus.completed;
  bool get isFailed => status == WithdrawalStatus.failed;
  bool get isPending => status == WithdrawalStatus.pending || status == WithdrawalStatus.processing;

  factory WithdrawalRecord.fromJson(Map<String, dynamic> json) =>
      _$WithdrawalRecordFromJson(json);
  Map<String, dynamic> toJson() => _$WithdrawalRecordToJson(this);
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

/// Request payload for POST /v1/withdrawal/request
class WithdrawalRequest {
  final String bankAccountId;
  final double amount;

  const WithdrawalRequest({
    required this.bankAccountId,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    'bankAccountId': bankAccountId,
    'amount': amount,
  };
}