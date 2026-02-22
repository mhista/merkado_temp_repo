// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState()';
}


}

/// @nodoc
class $AuthStateCopyWith<$Res>  {
$AuthStateCopyWith(AuthState _, $Res Function(AuthState) __);
}


/// Adds pattern-matching-related methods to [AuthState].
extension AuthStatePatterns on AuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Authenticated value)?  authenticated,TResult Function( _AccountsDetected value)?  accountsDetected,TResult Function( _Unauthenticated value)?  unauthenticated,TResult Function( _EmailNotVerified value)?  emailNotVerified,TResult Function( _OtpVerified value)?  otpVerified,TResult Function( _OtpResent value)?  otpResent,TResult Function( _OnboardingRequired value)?  onboardingRequired,TResult Function( _MfaRequired value)?  mfaRequired,TResult Function( _PasswordResetSent value)?  passwordResetSent,TResult Function( _PasswordResetSuccess value)?  passwordResetSuccess,TResult Function( _SessionExpiredForAccount value)?  sessionExpiredForAccount,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Authenticated() when authenticated != null:
return authenticated(_that);case _AccountsDetected() when accountsDetected != null:
return accountsDetected(_that);case _Unauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _EmailNotVerified() when emailNotVerified != null:
return emailNotVerified(_that);case _OtpVerified() when otpVerified != null:
return otpVerified(_that);case _OtpResent() when otpResent != null:
return otpResent(_that);case _OnboardingRequired() when onboardingRequired != null:
return onboardingRequired(_that);case _MfaRequired() when mfaRequired != null:
return mfaRequired(_that);case _PasswordResetSent() when passwordResetSent != null:
return passwordResetSent(_that);case _PasswordResetSuccess() when passwordResetSuccess != null:
return passwordResetSuccess(_that);case _SessionExpiredForAccount() when sessionExpiredForAccount != null:
return sessionExpiredForAccount(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Authenticated value)  authenticated,required TResult Function( _AccountsDetected value)  accountsDetected,required TResult Function( _Unauthenticated value)  unauthenticated,required TResult Function( _EmailNotVerified value)  emailNotVerified,required TResult Function( _OtpVerified value)  otpVerified,required TResult Function( _OtpResent value)  otpResent,required TResult Function( _OnboardingRequired value)  onboardingRequired,required TResult Function( _MfaRequired value)  mfaRequired,required TResult Function( _PasswordResetSent value)  passwordResetSent,required TResult Function( _PasswordResetSuccess value)  passwordResetSuccess,required TResult Function( _SessionExpiredForAccount value)  sessionExpiredForAccount,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Authenticated():
return authenticated(_that);case _AccountsDetected():
return accountsDetected(_that);case _Unauthenticated():
return unauthenticated(_that);case _EmailNotVerified():
return emailNotVerified(_that);case _OtpVerified():
return otpVerified(_that);case _OtpResent():
return otpResent(_that);case _OnboardingRequired():
return onboardingRequired(_that);case _MfaRequired():
return mfaRequired(_that);case _PasswordResetSent():
return passwordResetSent(_that);case _PasswordResetSuccess():
return passwordResetSuccess(_that);case _SessionExpiredForAccount():
return sessionExpiredForAccount(_that);case _Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Authenticated value)?  authenticated,TResult? Function( _AccountsDetected value)?  accountsDetected,TResult? Function( _Unauthenticated value)?  unauthenticated,TResult? Function( _EmailNotVerified value)?  emailNotVerified,TResult? Function( _OtpVerified value)?  otpVerified,TResult? Function( _OtpResent value)?  otpResent,TResult? Function( _OnboardingRequired value)?  onboardingRequired,TResult? Function( _MfaRequired value)?  mfaRequired,TResult? Function( _PasswordResetSent value)?  passwordResetSent,TResult? Function( _PasswordResetSuccess value)?  passwordResetSuccess,TResult? Function( _SessionExpiredForAccount value)?  sessionExpiredForAccount,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Authenticated() when authenticated != null:
return authenticated(_that);case _AccountsDetected() when accountsDetected != null:
return accountsDetected(_that);case _Unauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _EmailNotVerified() when emailNotVerified != null:
return emailNotVerified(_that);case _OtpVerified() when otpVerified != null:
return otpVerified(_that);case _OtpResent() when otpResent != null:
return otpResent(_that);case _OnboardingRequired() when onboardingRequired != null:
return onboardingRequired(_that);case _MfaRequired() when mfaRequired != null:
return mfaRequired(_that);case _PasswordResetSent() when passwordResetSent != null:
return passwordResetSent(_that);case _PasswordResetSuccess() when passwordResetSuccess != null:
return passwordResetSuccess(_that);case _SessionExpiredForAccount() when sessionExpiredForAccount != null:
return sessionExpiredForAccount(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  authenticated,TResult Function( List<GrascopeSessionHint> accounts)?  accountsDetected,TResult Function()?  unauthenticated,TResult Function( String email)?  emailNotVerified,TResult Function( String message)?  otpVerified,TResult Function()?  otpResent,TResult Function()?  onboardingRequired,TResult Function( String userId,  String message)?  mfaRequired,TResult Function()?  passwordResetSent,TResult Function()?  passwordResetSuccess,TResult Function( String? userId,  String? displayName)?  sessionExpiredForAccount,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Authenticated() when authenticated != null:
return authenticated();case _AccountsDetected() when accountsDetected != null:
return accountsDetected(_that.accounts);case _Unauthenticated() when unauthenticated != null:
return unauthenticated();case _EmailNotVerified() when emailNotVerified != null:
return emailNotVerified(_that.email);case _OtpVerified() when otpVerified != null:
return otpVerified(_that.message);case _OtpResent() when otpResent != null:
return otpResent();case _OnboardingRequired() when onboardingRequired != null:
return onboardingRequired();case _MfaRequired() when mfaRequired != null:
return mfaRequired(_that.userId,_that.message);case _PasswordResetSent() when passwordResetSent != null:
return passwordResetSent();case _PasswordResetSuccess() when passwordResetSuccess != null:
return passwordResetSuccess();case _SessionExpiredForAccount() when sessionExpiredForAccount != null:
return sessionExpiredForAccount(_that.userId,_that.displayName);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  authenticated,required TResult Function( List<GrascopeSessionHint> accounts)  accountsDetected,required TResult Function()  unauthenticated,required TResult Function( String email)  emailNotVerified,required TResult Function( String message)  otpVerified,required TResult Function()  otpResent,required TResult Function()  onboardingRequired,required TResult Function( String userId,  String message)  mfaRequired,required TResult Function()  passwordResetSent,required TResult Function()  passwordResetSuccess,required TResult Function( String? userId,  String? displayName)  sessionExpiredForAccount,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Authenticated():
return authenticated();case _AccountsDetected():
return accountsDetected(_that.accounts);case _Unauthenticated():
return unauthenticated();case _EmailNotVerified():
return emailNotVerified(_that.email);case _OtpVerified():
return otpVerified(_that.message);case _OtpResent():
return otpResent();case _OnboardingRequired():
return onboardingRequired();case _MfaRequired():
return mfaRequired(_that.userId,_that.message);case _PasswordResetSent():
return passwordResetSent();case _PasswordResetSuccess():
return passwordResetSuccess();case _SessionExpiredForAccount():
return sessionExpiredForAccount(_that.userId,_that.displayName);case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  authenticated,TResult? Function( List<GrascopeSessionHint> accounts)?  accountsDetected,TResult? Function()?  unauthenticated,TResult? Function( String email)?  emailNotVerified,TResult? Function( String message)?  otpVerified,TResult? Function()?  otpResent,TResult? Function()?  onboardingRequired,TResult? Function( String userId,  String message)?  mfaRequired,TResult? Function()?  passwordResetSent,TResult? Function()?  passwordResetSuccess,TResult? Function( String? userId,  String? displayName)?  sessionExpiredForAccount,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Authenticated() when authenticated != null:
return authenticated();case _AccountsDetected() when accountsDetected != null:
return accountsDetected(_that.accounts);case _Unauthenticated() when unauthenticated != null:
return unauthenticated();case _EmailNotVerified() when emailNotVerified != null:
return emailNotVerified(_that.email);case _OtpVerified() when otpVerified != null:
return otpVerified(_that.message);case _OtpResent() when otpResent != null:
return otpResent();case _OnboardingRequired() when onboardingRequired != null:
return onboardingRequired();case _MfaRequired() when mfaRequired != null:
return mfaRequired(_that.userId,_that.message);case _PasswordResetSent() when passwordResetSent != null:
return passwordResetSent();case _PasswordResetSuccess() when passwordResetSuccess != null:
return passwordResetSuccess();case _SessionExpiredForAccount() when sessionExpiredForAccount != null:
return sessionExpiredForAccount(_that.userId,_that.displayName);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements AuthState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.initial()';
}


}




/// @nodoc


class _Loading implements AuthState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.loading()';
}


}




/// @nodoc


class _Authenticated implements AuthState {
  const _Authenticated();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Authenticated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.authenticated()';
}


}




/// @nodoc


class _AccountsDetected implements AuthState {
  const _AccountsDetected({required final  List<GrascopeSessionHint> accounts}): _accounts = accounts;
  

 final  List<GrascopeSessionHint> _accounts;
 List<GrascopeSessionHint> get accounts {
  if (_accounts is EqualUnmodifiableListView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accounts);
}


/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountsDetectedCopyWith<_AccountsDetected> get copyWith => __$AccountsDetectedCopyWithImpl<_AccountsDetected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountsDetected&&const DeepCollectionEquality().equals(other._accounts, _accounts));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_accounts));

@override
String toString() {
  return 'AuthState.accountsDetected(accounts: $accounts)';
}


}

/// @nodoc
abstract mixin class _$AccountsDetectedCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$AccountsDetectedCopyWith(_AccountsDetected value, $Res Function(_AccountsDetected) _then) = __$AccountsDetectedCopyWithImpl;
@useResult
$Res call({
 List<GrascopeSessionHint> accounts
});




}
/// @nodoc
class __$AccountsDetectedCopyWithImpl<$Res>
    implements _$AccountsDetectedCopyWith<$Res> {
  __$AccountsDetectedCopyWithImpl(this._self, this._then);

  final _AccountsDetected _self;
  final $Res Function(_AccountsDetected) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? accounts = null,}) {
  return _then(_AccountsDetected(
accounts: null == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<GrascopeSessionHint>,
  ));
}


}

/// @nodoc


class _Unauthenticated implements AuthState {
  const _Unauthenticated();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unauthenticated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.unauthenticated()';
}


}




/// @nodoc


class _EmailNotVerified implements AuthState {
  const _EmailNotVerified({required this.email});
  

 final  String email;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmailNotVerifiedCopyWith<_EmailNotVerified> get copyWith => __$EmailNotVerifiedCopyWithImpl<_EmailNotVerified>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmailNotVerified&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'AuthState.emailNotVerified(email: $email)';
}


}

/// @nodoc
abstract mixin class _$EmailNotVerifiedCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$EmailNotVerifiedCopyWith(_EmailNotVerified value, $Res Function(_EmailNotVerified) _then) = __$EmailNotVerifiedCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class __$EmailNotVerifiedCopyWithImpl<$Res>
    implements _$EmailNotVerifiedCopyWith<$Res> {
  __$EmailNotVerifiedCopyWithImpl(this._self, this._then);

  final _EmailNotVerified _self;
  final $Res Function(_EmailNotVerified) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(_EmailNotVerified(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _OtpVerified implements AuthState {
  const _OtpVerified({required this.message});
  

 final  String message;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpVerifiedCopyWith<_OtpVerified> get copyWith => __$OtpVerifiedCopyWithImpl<_OtpVerified>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpVerified&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AuthState.otpVerified(message: $message)';
}


}

/// @nodoc
abstract mixin class _$OtpVerifiedCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$OtpVerifiedCopyWith(_OtpVerified value, $Res Function(_OtpVerified) _then) = __$OtpVerifiedCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$OtpVerifiedCopyWithImpl<$Res>
    implements _$OtpVerifiedCopyWith<$Res> {
  __$OtpVerifiedCopyWithImpl(this._self, this._then);

  final _OtpVerified _self;
  final $Res Function(_OtpVerified) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_OtpVerified(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _OtpResent implements AuthState {
  const _OtpResent();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpResent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.otpResent()';
}


}




/// @nodoc


class _OnboardingRequired implements AuthState {
  const _OnboardingRequired();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingRequired);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.onboardingRequired()';
}


}




/// @nodoc


class _MfaRequired implements AuthState {
  const _MfaRequired({required this.userId, required this.message});
  

 final  String userId;
 final  String message;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MfaRequiredCopyWith<_MfaRequired> get copyWith => __$MfaRequiredCopyWithImpl<_MfaRequired>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MfaRequired&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,userId,message);

@override
String toString() {
  return 'AuthState.mfaRequired(userId: $userId, message: $message)';
}


}

/// @nodoc
abstract mixin class _$MfaRequiredCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$MfaRequiredCopyWith(_MfaRequired value, $Res Function(_MfaRequired) _then) = __$MfaRequiredCopyWithImpl;
@useResult
$Res call({
 String userId, String message
});




}
/// @nodoc
class __$MfaRequiredCopyWithImpl<$Res>
    implements _$MfaRequiredCopyWith<$Res> {
  __$MfaRequiredCopyWithImpl(this._self, this._then);

  final _MfaRequired _self;
  final $Res Function(_MfaRequired) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? message = null,}) {
  return _then(_MfaRequired(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _PasswordResetSent implements AuthState {
  const _PasswordResetSent();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordResetSent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.passwordResetSent()';
}


}




/// @nodoc


class _PasswordResetSuccess implements AuthState {
  const _PasswordResetSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordResetSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.passwordResetSuccess()';
}


}




/// @nodoc


class _SessionExpiredForAccount implements AuthState {
  const _SessionExpiredForAccount({this.userId, this.displayName});
  

 final  String? userId;
 final  String? displayName;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionExpiredForAccountCopyWith<_SessionExpiredForAccount> get copyWith => __$SessionExpiredForAccountCopyWithImpl<_SessionExpiredForAccount>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionExpiredForAccount&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}


@override
int get hashCode => Object.hash(runtimeType,userId,displayName);

@override
String toString() {
  return 'AuthState.sessionExpiredForAccount(userId: $userId, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class _$SessionExpiredForAccountCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$SessionExpiredForAccountCopyWith(_SessionExpiredForAccount value, $Res Function(_SessionExpiredForAccount) _then) = __$SessionExpiredForAccountCopyWithImpl;
@useResult
$Res call({
 String? userId, String? displayName
});




}
/// @nodoc
class __$SessionExpiredForAccountCopyWithImpl<$Res>
    implements _$SessionExpiredForAccountCopyWith<$Res> {
  __$SessionExpiredForAccountCopyWithImpl(this._self, this._then);

  final _SessionExpiredForAccount _self;
  final $Res Function(_SessionExpiredForAccount) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userId = freezed,Object? displayName = freezed,}) {
  return _then(_SessionExpiredForAccount(
userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Error implements AuthState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of AuthState
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
  return 'AuthState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
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

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
