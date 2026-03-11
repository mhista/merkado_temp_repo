// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Wallet _$WalletFromJson(Map<String, dynamic> json) => Wallet(
  id: json['id'] as String,
  userId: json['userId'] as String,
  currency: json['currency'] as String,
  availableBalance: _parseDouble(json['availableBalance']),
  ledgerBalance: _parseDouble(json['ledgerBalance']),
  withdrawableBalance: _parseDouble(json['withdrawableBalance']),
  status: $enumDecode(_$WalletStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$WalletToJson(Wallet instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'currency': instance.currency,
  'availableBalance': instance.availableBalance,
  'ledgerBalance': instance.ledgerBalance,
  'withdrawableBalance': instance.withdrawableBalance,
  'status': _$WalletStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$WalletStatusEnumMap = {
  WalletStatus.active: 'active',
  WalletStatus.frozen: 'frozen',
  WalletStatus.suspended: 'suspended',
};

FundWalletResponse _$FundWalletResponseFromJson(Map<String, dynamic> json) =>
    FundWalletResponse(
      message: json['message'] as String,
      checkoutUrl: json['checkoutUrl'] as String,
      provider: json['provider'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      reference: json['reference'] as String,
    );

Map<String, dynamic> _$FundWalletResponseToJson(FundWalletResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'checkoutUrl': instance.checkoutUrl,
      'provider': instance.provider,
      'amount': instance.amount,
      'currency': instance.currency,
      'reference': instance.reference,
    };

DemoFundResponse _$DemoFundResponseFromJson(Map<String, dynamic> json) =>
    DemoFundResponse(
      message: json['message'] as String,
      walletId: json['walletId'] as String,
      availableBalance: _parseDouble(json['availableBalance']),
      ledgerBalance: _parseDouble(json['ledgerBalance']),
      withdrawableBalance: _parseDouble(json['withdrawableBalance']),
    );

Map<String, dynamic> _$DemoFundResponseToJson(DemoFundResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'walletId': instance.walletId,
      'availableBalance': instance.availableBalance,
      'ledgerBalance': instance.ledgerBalance,
      'withdrawableBalance': instance.withdrawableBalance,
    };

DemoWithdrawResponse _$DemoWithdrawResponseFromJson(
  Map<String, dynamic> json,
) => DemoWithdrawResponse(
  message: json['message'] as String,
  walletId: json['walletId'] as String,
  withdrawableBalance: _parseDouble(json['withdrawableBalance']),
);

Map<String, dynamic> _$DemoWithdrawResponseToJson(
  DemoWithdrawResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'walletId': instance.walletId,
  'withdrawableBalance': instance.withdrawableBalance,
};
