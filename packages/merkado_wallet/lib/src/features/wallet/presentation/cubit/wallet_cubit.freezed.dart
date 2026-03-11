// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WalletState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WalletState()';
}


}

/// @nodoc
class $WalletStateCopyWith<$Res>  {
$WalletStateCopyWith(WalletState _, $Res Function(WalletState) __);
}


/// Adds pattern-matching-related methods to [WalletState].
extension WalletStatePatterns on WalletState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Loaded value)?  loaded,TResult Function( _Updating value)?  updating,TResult Function( _FundInitiated value)?  fundInitiated,TResult Function( _DemoFundSuccess value)?  demoFundSuccess,TResult Function( _DemoWithdrawSuccess value)?  demoWithdrawSuccess,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Updating() when updating != null:
return updating(_that);case _FundInitiated() when fundInitiated != null:
return fundInitiated(_that);case _DemoFundSuccess() when demoFundSuccess != null:
return demoFundSuccess(_that);case _DemoWithdrawSuccess() when demoWithdrawSuccess != null:
return demoWithdrawSuccess(_that);case _Error() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Loaded value)  loaded,required TResult Function( _Updating value)  updating,required TResult Function( _FundInitiated value)  fundInitiated,required TResult Function( _DemoFundSuccess value)  demoFundSuccess,required TResult Function( _DemoWithdrawSuccess value)  demoWithdrawSuccess,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Loaded():
return loaded(_that);case _Updating():
return updating(_that);case _FundInitiated():
return fundInitiated(_that);case _DemoFundSuccess():
return demoFundSuccess(_that);case _DemoWithdrawSuccess():
return demoWithdrawSuccess(_that);case _Error():
return error(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Loaded value)?  loaded,TResult? Function( _Updating value)?  updating,TResult? Function( _FundInitiated value)?  fundInitiated,TResult? Function( _DemoFundSuccess value)?  demoFundSuccess,TResult? Function( _DemoWithdrawSuccess value)?  demoWithdrawSuccess,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Updating() when updating != null:
return updating(_that);case _FundInitiated() when fundInitiated != null:
return fundInitiated(_that);case _DemoFundSuccess() when demoFundSuccess != null:
return demoFundSuccess(_that);case _DemoWithdrawSuccess() when demoWithdrawSuccess != null:
return demoWithdrawSuccess(_that);case _Error() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( Wallet wallet,  bool balanceVisible)?  loaded,TResult Function( Wallet wallet,  bool balanceVisible,  String operation)?  updating,TResult Function( String checkoutUrl,  String reference,  String provider,  double amount)?  fundInitiated,TResult Function( double newAvailableBalance,  double newLedgerBalance,  double newWithdrawableBalance,  double amount)?  demoFundSuccess,TResult Function( double newWithdrawableBalance,  double amount)?  demoWithdrawSuccess,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.wallet,_that.balanceVisible);case _Updating() when updating != null:
return updating(_that.wallet,_that.balanceVisible,_that.operation);case _FundInitiated() when fundInitiated != null:
return fundInitiated(_that.checkoutUrl,_that.reference,_that.provider,_that.amount);case _DemoFundSuccess() when demoFundSuccess != null:
return demoFundSuccess(_that.newAvailableBalance,_that.newLedgerBalance,_that.newWithdrawableBalance,_that.amount);case _DemoWithdrawSuccess() when demoWithdrawSuccess != null:
return demoWithdrawSuccess(_that.newWithdrawableBalance,_that.amount);case _Error() when error != null:
return error(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( Wallet wallet,  bool balanceVisible)  loaded,required TResult Function( Wallet wallet,  bool balanceVisible,  String operation)  updating,required TResult Function( String checkoutUrl,  String reference,  String provider,  double amount)  fundInitiated,required TResult Function( double newAvailableBalance,  double newLedgerBalance,  double newWithdrawableBalance,  double amount)  demoFundSuccess,required TResult Function( double newWithdrawableBalance,  double amount)  demoWithdrawSuccess,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return loaded(_that.wallet,_that.balanceVisible);case _Updating():
return updating(_that.wallet,_that.balanceVisible,_that.operation);case _FundInitiated():
return fundInitiated(_that.checkoutUrl,_that.reference,_that.provider,_that.amount);case _DemoFundSuccess():
return demoFundSuccess(_that.newAvailableBalance,_that.newLedgerBalance,_that.newWithdrawableBalance,_that.amount);case _DemoWithdrawSuccess():
return demoWithdrawSuccess(_that.newWithdrawableBalance,_that.amount);case _Error():
return error(_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( Wallet wallet,  bool balanceVisible)?  loaded,TResult? Function( Wallet wallet,  bool balanceVisible,  String operation)?  updating,TResult? Function( String checkoutUrl,  String reference,  String provider,  double amount)?  fundInitiated,TResult? Function( double newAvailableBalance,  double newLedgerBalance,  double newWithdrawableBalance,  double amount)?  demoFundSuccess,TResult? Function( double newWithdrawableBalance,  double amount)?  demoWithdrawSuccess,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.wallet,_that.balanceVisible);case _Updating() when updating != null:
return updating(_that.wallet,_that.balanceVisible,_that.operation);case _FundInitiated() when fundInitiated != null:
return fundInitiated(_that.checkoutUrl,_that.reference,_that.provider,_that.amount);case _DemoFundSuccess() when demoFundSuccess != null:
return demoFundSuccess(_that.newAvailableBalance,_that.newLedgerBalance,_that.newWithdrawableBalance,_that.amount);case _DemoWithdrawSuccess() when demoWithdrawSuccess != null:
return demoWithdrawSuccess(_that.newWithdrawableBalance,_that.amount);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements WalletState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WalletState.initial()';
}


}




/// @nodoc


class _Loading implements WalletState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WalletState.loading()';
}


}




/// @nodoc


class _Loaded implements WalletState {
  const _Loaded({required this.wallet, required this.balanceVisible});
  

 final  Wallet wallet;
 final  bool balanceVisible;

/// Create a copy of WalletState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&(identical(other.wallet, wallet) || other.wallet == wallet)&&(identical(other.balanceVisible, balanceVisible) || other.balanceVisible == balanceVisible));
}


@override
int get hashCode => Object.hash(runtimeType,wallet,balanceVisible);

@override
String toString() {
  return 'WalletState.loaded(wallet: $wallet, balanceVisible: $balanceVisible)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $WalletStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 Wallet wallet, bool balanceVisible
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of WalletState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? wallet = null,Object? balanceVisible = null,}) {
  return _then(_Loaded(
wallet: null == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as Wallet,balanceVisible: null == balanceVisible ? _self.balanceVisible : balanceVisible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _Updating implements WalletState {
  const _Updating({required this.wallet, required this.balanceVisible, required this.operation});
  

 final  Wallet wallet;
 final  bool balanceVisible;
 final  String operation;

/// Create a copy of WalletState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatingCopyWith<_Updating> get copyWith => __$UpdatingCopyWithImpl<_Updating>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Updating&&(identical(other.wallet, wallet) || other.wallet == wallet)&&(identical(other.balanceVisible, balanceVisible) || other.balanceVisible == balanceVisible)&&(identical(other.operation, operation) || other.operation == operation));
}


@override
int get hashCode => Object.hash(runtimeType,wallet,balanceVisible,operation);

@override
String toString() {
  return 'WalletState.updating(wallet: $wallet, balanceVisible: $balanceVisible, operation: $operation)';
}


}

/// @nodoc
abstract mixin class _$UpdatingCopyWith<$Res> implements $WalletStateCopyWith<$Res> {
  factory _$UpdatingCopyWith(_Updating value, $Res Function(_Updating) _then) = __$UpdatingCopyWithImpl;
@useResult
$Res call({
 Wallet wallet, bool balanceVisible, String operation
});




}
/// @nodoc
class __$UpdatingCopyWithImpl<$Res>
    implements _$UpdatingCopyWith<$Res> {
  __$UpdatingCopyWithImpl(this._self, this._then);

  final _Updating _self;
  final $Res Function(_Updating) _then;

/// Create a copy of WalletState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? wallet = null,Object? balanceVisible = null,Object? operation = null,}) {
  return _then(_Updating(
wallet: null == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as Wallet,balanceVisible: null == balanceVisible ? _self.balanceVisible : balanceVisible // ignore: cast_nullable_to_non_nullable
as bool,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _FundInitiated implements WalletState {
  const _FundInitiated({required this.checkoutUrl, required this.reference, required this.provider, required this.amount});
  

 final  String checkoutUrl;
 final  String reference;
 final  String provider;
 final  double amount;

/// Create a copy of WalletState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FundInitiatedCopyWith<_FundInitiated> get copyWith => __$FundInitiatedCopyWithImpl<_FundInitiated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FundInitiated&&(identical(other.checkoutUrl, checkoutUrl) || other.checkoutUrl == checkoutUrl)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode => Object.hash(runtimeType,checkoutUrl,reference,provider,amount);

@override
String toString() {
  return 'WalletState.fundInitiated(checkoutUrl: $checkoutUrl, reference: $reference, provider: $provider, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$FundInitiatedCopyWith<$Res> implements $WalletStateCopyWith<$Res> {
  factory _$FundInitiatedCopyWith(_FundInitiated value, $Res Function(_FundInitiated) _then) = __$FundInitiatedCopyWithImpl;
@useResult
$Res call({
 String checkoutUrl, String reference, String provider, double amount
});




}
/// @nodoc
class __$FundInitiatedCopyWithImpl<$Res>
    implements _$FundInitiatedCopyWith<$Res> {
  __$FundInitiatedCopyWithImpl(this._self, this._then);

  final _FundInitiated _self;
  final $Res Function(_FundInitiated) _then;

/// Create a copy of WalletState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? checkoutUrl = null,Object? reference = null,Object? provider = null,Object? amount = null,}) {
  return _then(_FundInitiated(
checkoutUrl: null == checkoutUrl ? _self.checkoutUrl : checkoutUrl // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class _DemoFundSuccess implements WalletState {
  const _DemoFundSuccess({required this.newAvailableBalance, required this.newLedgerBalance, required this.newWithdrawableBalance, required this.amount});
  

 final  double newAvailableBalance;
 final  double newLedgerBalance;
 final  double newWithdrawableBalance;
 final  double amount;

/// Create a copy of WalletState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DemoFundSuccessCopyWith<_DemoFundSuccess> get copyWith => __$DemoFundSuccessCopyWithImpl<_DemoFundSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DemoFundSuccess&&(identical(other.newAvailableBalance, newAvailableBalance) || other.newAvailableBalance == newAvailableBalance)&&(identical(other.newLedgerBalance, newLedgerBalance) || other.newLedgerBalance == newLedgerBalance)&&(identical(other.newWithdrawableBalance, newWithdrawableBalance) || other.newWithdrawableBalance == newWithdrawableBalance)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode => Object.hash(runtimeType,newAvailableBalance,newLedgerBalance,newWithdrawableBalance,amount);

@override
String toString() {
  return 'WalletState.demoFundSuccess(newAvailableBalance: $newAvailableBalance, newLedgerBalance: $newLedgerBalance, newWithdrawableBalance: $newWithdrawableBalance, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$DemoFundSuccessCopyWith<$Res> implements $WalletStateCopyWith<$Res> {
  factory _$DemoFundSuccessCopyWith(_DemoFundSuccess value, $Res Function(_DemoFundSuccess) _then) = __$DemoFundSuccessCopyWithImpl;
@useResult
$Res call({
 double newAvailableBalance, double newLedgerBalance, double newWithdrawableBalance, double amount
});




}
/// @nodoc
class __$DemoFundSuccessCopyWithImpl<$Res>
    implements _$DemoFundSuccessCopyWith<$Res> {
  __$DemoFundSuccessCopyWithImpl(this._self, this._then);

  final _DemoFundSuccess _self;
  final $Res Function(_DemoFundSuccess) _then;

/// Create a copy of WalletState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? newAvailableBalance = null,Object? newLedgerBalance = null,Object? newWithdrawableBalance = null,Object? amount = null,}) {
  return _then(_DemoFundSuccess(
newAvailableBalance: null == newAvailableBalance ? _self.newAvailableBalance : newAvailableBalance // ignore: cast_nullable_to_non_nullable
as double,newLedgerBalance: null == newLedgerBalance ? _self.newLedgerBalance : newLedgerBalance // ignore: cast_nullable_to_non_nullable
as double,newWithdrawableBalance: null == newWithdrawableBalance ? _self.newWithdrawableBalance : newWithdrawableBalance // ignore: cast_nullable_to_non_nullable
as double,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class _DemoWithdrawSuccess implements WalletState {
  const _DemoWithdrawSuccess({required this.newWithdrawableBalance, required this.amount});
  

 final  double newWithdrawableBalance;
 final  double amount;

/// Create a copy of WalletState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DemoWithdrawSuccessCopyWith<_DemoWithdrawSuccess> get copyWith => __$DemoWithdrawSuccessCopyWithImpl<_DemoWithdrawSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DemoWithdrawSuccess&&(identical(other.newWithdrawableBalance, newWithdrawableBalance) || other.newWithdrawableBalance == newWithdrawableBalance)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode => Object.hash(runtimeType,newWithdrawableBalance,amount);

@override
String toString() {
  return 'WalletState.demoWithdrawSuccess(newWithdrawableBalance: $newWithdrawableBalance, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$DemoWithdrawSuccessCopyWith<$Res> implements $WalletStateCopyWith<$Res> {
  factory _$DemoWithdrawSuccessCopyWith(_DemoWithdrawSuccess value, $Res Function(_DemoWithdrawSuccess) _then) = __$DemoWithdrawSuccessCopyWithImpl;
@useResult
$Res call({
 double newWithdrawableBalance, double amount
});




}
/// @nodoc
class __$DemoWithdrawSuccessCopyWithImpl<$Res>
    implements _$DemoWithdrawSuccessCopyWith<$Res> {
  __$DemoWithdrawSuccessCopyWithImpl(this._self, this._then);

  final _DemoWithdrawSuccess _self;
  final $Res Function(_DemoWithdrawSuccess) _then;

/// Create a copy of WalletState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? newWithdrawableBalance = null,Object? amount = null,}) {
  return _then(_DemoWithdrawSuccess(
newWithdrawableBalance: null == newWithdrawableBalance ? _self.newWithdrawableBalance : newWithdrawableBalance // ignore: cast_nullable_to_non_nullable
as double,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class _Error implements WalletState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of WalletState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'WalletState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $WalletStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of WalletState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
