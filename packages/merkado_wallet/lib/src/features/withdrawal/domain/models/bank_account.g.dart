// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BankAccount _$BankAccountFromJson(Map<String, dynamic> json) => BankAccount(
  id: json['id'] as String,
  userId: json['userId'] as String,
  bankName: json['bankName'] as String,
  bankCode: json['bankCode'] as String,
  accountNumber: json['accountNumber'] as String,
  accountName: json['accountName'] as String,
  currency: json['currency'] as String,
  country: json['country'] as String,
  beneficiaryType: json['beneficiaryType'] as String,
  isDefault: json['isDefault'] as bool,
  firstName: json['firstName'],
  lastName: json['lastName'],
  email: json['email'],
  phone: json['phone'],
  paymentScheme: json['paymentScheme'],
  bankSwiftCode: json['bankSwiftCode'],
  sortCode: json['sortCode'],
  beneficiaryAddress: json['beneficiaryAddress'],
  bankAddress: json['bankAddress'],
  metadata: json['metadata'],
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$BankAccountToJson(BankAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'bankName': instance.bankName,
      'bankCode': instance.bankCode,
      'accountNumber': instance.accountNumber,
      'accountName': instance.accountName,
      'currency': instance.currency,
      'country': instance.country,
      'beneficiaryType': instance.beneficiaryType,
      'isDefault': instance.isDefault,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
      'paymentScheme': instance.paymentScheme,
      'bankSwiftCode': instance.bankSwiftCode,
      'sortCode': instance.sortCode,
      'beneficiaryAddress': instance.beneficiaryAddress,
      'bankAddress': instance.bankAddress,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
    };

SupportedBank _$SupportedBankFromJson(Map<String, dynamic> json) =>
    SupportedBank(
      name: json['name'] as String,
      code: json['code'] as String,
      slug: json['slug'] as String?,
      country: json['country'] as String?,
      currency: json['currency'] as String?,
    );

Map<String, dynamic> _$SupportedBankToJson(SupportedBank instance) =>
    <String, dynamic>{
      'name': instance.name,
      'code': instance.code,
      'slug': instance.slug,
      'country': instance.country,
      'currency': instance.currency,
    };
