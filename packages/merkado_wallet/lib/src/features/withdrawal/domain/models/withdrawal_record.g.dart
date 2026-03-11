// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdrawal_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WithdrawalRecord _$WithdrawalRecordFromJson(Map<String, dynamic> json) =>
    WithdrawalRecord(
      id: json['id'] as String,
      walletId: json['walletId'] as String,
      bankAccountId: json['bankAccountId'] as String,
      amount: _parseDouble(json['amount']),
      currency: json['currency'] as String,
      status: $enumDecode(_$WithdrawalStatusEnumMap, json['status']),
      gatewayReference: json['gatewayReference'],
      failureReason: json['failureReason'],
      processedAt: json['processedAt'],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$WithdrawalRecordToJson(WithdrawalRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'walletId': instance.walletId,
      'bankAccountId': instance.bankAccountId,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': _$WithdrawalStatusEnumMap[instance.status]!,
      'gatewayReference': instance.gatewayReference,
      'failureReason': instance.failureReason,
      'processedAt': instance.processedAt,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$WithdrawalStatusEnumMap = {
  WithdrawalStatus.pending: 'pending',
  WithdrawalStatus.processing: 'processing',
  WithdrawalStatus.completed: 'completed',
  WithdrawalStatus.failed: 'failed',
};
