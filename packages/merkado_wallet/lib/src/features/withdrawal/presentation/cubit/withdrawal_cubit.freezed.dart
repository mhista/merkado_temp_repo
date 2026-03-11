// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'withdrawal_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WithdrawalState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WithdrawalState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WithdrawalState()';
}


}

/// @nodoc
class $WithdrawalStateCopyWith<$Res>  {
$WithdrawalStateCopyWith(WithdrawalState _, $Res Function(WithdrawalState) __);
}


/// Adds pattern-matching-related methods to [WithdrawalState].
extension WithdrawalStatePatterns on WithdrawalState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _BankAccountsLoaded value)?  bankAccountsLoaded,TResult Function( _BankAccountAdded value)?  bankAccountAdded,TResult Function( _HistoryLoaded value)?  historyLoaded,TResult Function( _WithdrawalSuccess value)?  withdrawalSuccess,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _BankAccountsLoaded() when bankAccountsLoaded != null:
return bankAccountsLoaded(_that);case _BankAccountAdded() when bankAccountAdded != null:
return bankAccountAdded(_that);case _HistoryLoaded() when historyLoaded != null:
return historyLoaded(_that);case _WithdrawalSuccess() when withdrawalSuccess != null:
return withdrawalSuccess(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _BankAccountsLoaded value)  bankAccountsLoaded,required TResult Function( _BankAccountAdded value)  bankAccountAdded,required TResult Function( _HistoryLoaded value)  historyLoaded,required TResult Function( _WithdrawalSuccess value)  withdrawalSuccess,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _BankAccountsLoaded():
return bankAccountsLoaded(_that);case _BankAccountAdded():
return bankAccountAdded(_that);case _HistoryLoaded():
return historyLoaded(_that);case _WithdrawalSuccess():
return withdrawalSuccess(_that);case _Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _BankAccountsLoaded value)?  bankAccountsLoaded,TResult? Function( _BankAccountAdded value)?  bankAccountAdded,TResult? Function( _HistoryLoaded value)?  historyLoaded,TResult? Function( _WithdrawalSuccess value)?  withdrawalSuccess,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _BankAccountsLoaded() when bankAccountsLoaded != null:
return bankAccountsLoaded(_that);case _BankAccountAdded() when bankAccountAdded != null:
return bankAccountAdded(_that);case _HistoryLoaded() when historyLoaded != null:
return historyLoaded(_that);case _WithdrawalSuccess() when withdrawalSuccess != null:
return withdrawalSuccess(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<BankAccount> accounts)?  bankAccountsLoaded,TResult Function( BankAccount account)?  bankAccountAdded,TResult Function( List<WithdrawalRecord> records)?  historyLoaded,TResult Function( WithdrawalRecord record)?  withdrawalSuccess,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _BankAccountsLoaded() when bankAccountsLoaded != null:
return bankAccountsLoaded(_that.accounts);case _BankAccountAdded() when bankAccountAdded != null:
return bankAccountAdded(_that.account);case _HistoryLoaded() when historyLoaded != null:
return historyLoaded(_that.records);case _WithdrawalSuccess() when withdrawalSuccess != null:
return withdrawalSuccess(_that.record);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<BankAccount> accounts)  bankAccountsLoaded,required TResult Function( BankAccount account)  bankAccountAdded,required TResult Function( List<WithdrawalRecord> records)  historyLoaded,required TResult Function( WithdrawalRecord record)  withdrawalSuccess,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _BankAccountsLoaded():
return bankAccountsLoaded(_that.accounts);case _BankAccountAdded():
return bankAccountAdded(_that.account);case _HistoryLoaded():
return historyLoaded(_that.records);case _WithdrawalSuccess():
return withdrawalSuccess(_that.record);case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<BankAccount> accounts)?  bankAccountsLoaded,TResult? Function( BankAccount account)?  bankAccountAdded,TResult? Function( List<WithdrawalRecord> records)?  historyLoaded,TResult? Function( WithdrawalRecord record)?  withdrawalSuccess,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _BankAccountsLoaded() when bankAccountsLoaded != null:
return bankAccountsLoaded(_that.accounts);case _BankAccountAdded() when bankAccountAdded != null:
return bankAccountAdded(_that.account);case _HistoryLoaded() when historyLoaded != null:
return historyLoaded(_that.records);case _WithdrawalSuccess() when withdrawalSuccess != null:
return withdrawalSuccess(_that.record);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements WithdrawalState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WithdrawalState.initial()';
}


}




/// @nodoc


class _Loading implements WithdrawalState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WithdrawalState.loading()';
}


}




/// @nodoc


class _BankAccountsLoaded implements WithdrawalState {
  const _BankAccountsLoaded({required final  List<BankAccount> accounts}): _accounts = accounts;
  

 final  List<BankAccount> _accounts;
 List<BankAccount> get accounts {
  if (_accounts is EqualUnmodifiableListView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accounts);
}


/// Create a copy of WithdrawalState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BankAccountsLoadedCopyWith<_BankAccountsLoaded> get copyWith => __$BankAccountsLoadedCopyWithImpl<_BankAccountsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BankAccountsLoaded&&const DeepCollectionEquality().equals(other._accounts, _accounts));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_accounts));

@override
String toString() {
  return 'WithdrawalState.bankAccountsLoaded(accounts: $accounts)';
}


}

/// @nodoc
abstract mixin class _$BankAccountsLoadedCopyWith<$Res> implements $WithdrawalStateCopyWith<$Res> {
  factory _$BankAccountsLoadedCopyWith(_BankAccountsLoaded value, $Res Function(_BankAccountsLoaded) _then) = __$BankAccountsLoadedCopyWithImpl;
@useResult
$Res call({
 List<BankAccount> accounts
});




}
/// @nodoc
class __$BankAccountsLoadedCopyWithImpl<$Res>
    implements _$BankAccountsLoadedCopyWith<$Res> {
  __$BankAccountsLoadedCopyWithImpl(this._self, this._then);

  final _BankAccountsLoaded _self;
  final $Res Function(_BankAccountsLoaded) _then;

/// Create a copy of WithdrawalState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? accounts = null,}) {
  return _then(_BankAccountsLoaded(
accounts: null == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<BankAccount>,
  ));
}


}

/// @nodoc


class _BankAccountAdded implements WithdrawalState {
  const _BankAccountAdded({required this.account});
  

 final  BankAccount account;

/// Create a copy of WithdrawalState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BankAccountAddedCopyWith<_BankAccountAdded> get copyWith => __$BankAccountAddedCopyWithImpl<_BankAccountAdded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BankAccountAdded&&(identical(other.account, account) || other.account == account));
}


@override
int get hashCode => Object.hash(runtimeType,account);

@override
String toString() {
  return 'WithdrawalState.bankAccountAdded(account: $account)';
}


}

/// @nodoc
abstract mixin class _$BankAccountAddedCopyWith<$Res> implements $WithdrawalStateCopyWith<$Res> {
  factory _$BankAccountAddedCopyWith(_BankAccountAdded value, $Res Function(_BankAccountAdded) _then) = __$BankAccountAddedCopyWithImpl;
@useResult
$Res call({
 BankAccount account
});




}
/// @nodoc
class __$BankAccountAddedCopyWithImpl<$Res>
    implements _$BankAccountAddedCopyWith<$Res> {
  __$BankAccountAddedCopyWithImpl(this._self, this._then);

  final _BankAccountAdded _self;
  final $Res Function(_BankAccountAdded) _then;

/// Create a copy of WithdrawalState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? account = null,}) {
  return _then(_BankAccountAdded(
account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as BankAccount,
  ));
}


}

/// @nodoc


class _HistoryLoaded implements WithdrawalState {
  const _HistoryLoaded({required final  List<WithdrawalRecord> records}): _records = records;
  

 final  List<WithdrawalRecord> _records;
 List<WithdrawalRecord> get records {
  if (_records is EqualUnmodifiableListView) return _records;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_records);
}


/// Create a copy of WithdrawalState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoryLoadedCopyWith<_HistoryLoaded> get copyWith => __$HistoryLoadedCopyWithImpl<_HistoryLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoryLoaded&&const DeepCollectionEquality().equals(other._records, _records));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_records));

@override
String toString() {
  return 'WithdrawalState.historyLoaded(records: $records)';
}


}

/// @nodoc
abstract mixin class _$HistoryLoadedCopyWith<$Res> implements $WithdrawalStateCopyWith<$Res> {
  factory _$HistoryLoadedCopyWith(_HistoryLoaded value, $Res Function(_HistoryLoaded) _then) = __$HistoryLoadedCopyWithImpl;
@useResult
$Res call({
 List<WithdrawalRecord> records
});




}
/// @nodoc
class __$HistoryLoadedCopyWithImpl<$Res>
    implements _$HistoryLoadedCopyWith<$Res> {
  __$HistoryLoadedCopyWithImpl(this._self, this._then);

  final _HistoryLoaded _self;
  final $Res Function(_HistoryLoaded) _then;

/// Create a copy of WithdrawalState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? records = null,}) {
  return _then(_HistoryLoaded(
records: null == records ? _self._records : records // ignore: cast_nullable_to_non_nullable
as List<WithdrawalRecord>,
  ));
}


}

/// @nodoc


class _WithdrawalSuccess implements WithdrawalState {
  const _WithdrawalSuccess({required this.record});
  

 final  WithdrawalRecord record;

/// Create a copy of WithdrawalState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WithdrawalSuccessCopyWith<_WithdrawalSuccess> get copyWith => __$WithdrawalSuccessCopyWithImpl<_WithdrawalSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WithdrawalSuccess&&(identical(other.record, record) || other.record == record));
}


@override
int get hashCode => Object.hash(runtimeType,record);

@override
String toString() {
  return 'WithdrawalState.withdrawalSuccess(record: $record)';
}


}

/// @nodoc
abstract mixin class _$WithdrawalSuccessCopyWith<$Res> implements $WithdrawalStateCopyWith<$Res> {
  factory _$WithdrawalSuccessCopyWith(_WithdrawalSuccess value, $Res Function(_WithdrawalSuccess) _then) = __$WithdrawalSuccessCopyWithImpl;
@useResult
$Res call({
 WithdrawalRecord record
});




}
/// @nodoc
class __$WithdrawalSuccessCopyWithImpl<$Res>
    implements _$WithdrawalSuccessCopyWith<$Res> {
  __$WithdrawalSuccessCopyWithImpl(this._self, this._then);

  final _WithdrawalSuccess _self;
  final $Res Function(_WithdrawalSuccess) _then;

/// Create a copy of WithdrawalState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? record = null,}) {
  return _then(_WithdrawalSuccess(
record: null == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as WithdrawalRecord,
  ));
}


}

/// @nodoc


class _Error implements WithdrawalState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of WithdrawalState
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
  return 'WithdrawalState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $WithdrawalStateCopyWith<$Res> {
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

/// Create a copy of WithdrawalState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
