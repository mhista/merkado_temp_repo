// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'google_sign_in_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GoogleSignInState {

 GoogleSignInAccount? get user; bool get isInitialized; bool get isLoading; String? get error;
/// Create a copy of GoogleSignInState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoogleSignInStateCopyWith<GoogleSignInState> get copyWith => _$GoogleSignInStateCopyWithImpl<GoogleSignInState>(this as GoogleSignInState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoogleSignInState&&const DeepCollectionEquality().equals(other.user, user)&&(identical(other.isInitialized, isInitialized) || other.isInitialized == isInitialized)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(user),isInitialized,isLoading,error);

@override
String toString() {
  return 'GoogleSignInState(user: $user, isInitialized: $isInitialized, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class $GoogleSignInStateCopyWith<$Res>  {
  factory $GoogleSignInStateCopyWith(GoogleSignInState value, $Res Function(GoogleSignInState) _then) = _$GoogleSignInStateCopyWithImpl;
@useResult
$Res call({
 GoogleSignInAccount? user, bool isInitialized, bool isLoading, String? error
});




}
/// @nodoc
class _$GoogleSignInStateCopyWithImpl<$Res>
    implements $GoogleSignInStateCopyWith<$Res> {
  _$GoogleSignInStateCopyWithImpl(this._self, this._then);

  final GoogleSignInState _self;
  final $Res Function(GoogleSignInState) _then;

/// Create a copy of GoogleSignInState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = freezed,Object? isInitialized = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as GoogleSignInAccount?,isInitialized: null == isInitialized ? _self.isInitialized : isInitialized // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GoogleSignInState].
extension GoogleSignInStatePatterns on GoogleSignInState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoogleSignInState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoogleSignInState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoogleSignInState value)  $default,){
final _that = this;
switch (_that) {
case _GoogleSignInState():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoogleSignInState value)?  $default,){
final _that = this;
switch (_that) {
case _GoogleSignInState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GoogleSignInAccount? user,  bool isInitialized,  bool isLoading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoogleSignInState() when $default != null:
return $default(_that.user,_that.isInitialized,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GoogleSignInAccount? user,  bool isInitialized,  bool isLoading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _GoogleSignInState():
return $default(_that.user,_that.isInitialized,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GoogleSignInAccount? user,  bool isInitialized,  bool isLoading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _GoogleSignInState() when $default != null:
return $default(_that.user,_that.isInitialized,_that.isLoading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _GoogleSignInState extends GoogleSignInState {
  const _GoogleSignInState({this.user, this.isInitialized = false, this.isLoading = false, this.error}): super._();
  

@override final  GoogleSignInAccount? user;
@override@JsonKey() final  bool isInitialized;
@override@JsonKey() final  bool isLoading;
@override final  String? error;

/// Create a copy of GoogleSignInState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoogleSignInStateCopyWith<_GoogleSignInState> get copyWith => __$GoogleSignInStateCopyWithImpl<_GoogleSignInState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoogleSignInState&&const DeepCollectionEquality().equals(other.user, user)&&(identical(other.isInitialized, isInitialized) || other.isInitialized == isInitialized)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(user),isInitialized,isLoading,error);

@override
String toString() {
  return 'GoogleSignInState(user: $user, isInitialized: $isInitialized, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$GoogleSignInStateCopyWith<$Res> implements $GoogleSignInStateCopyWith<$Res> {
  factory _$GoogleSignInStateCopyWith(_GoogleSignInState value, $Res Function(_GoogleSignInState) _then) = __$GoogleSignInStateCopyWithImpl;
@override @useResult
$Res call({
 GoogleSignInAccount? user, bool isInitialized, bool isLoading, String? error
});




}
/// @nodoc
class __$GoogleSignInStateCopyWithImpl<$Res>
    implements _$GoogleSignInStateCopyWith<$Res> {
  __$GoogleSignInStateCopyWithImpl(this._self, this._then);

  final _GoogleSignInState _self;
  final $Res Function(_GoogleSignInState) _then;

/// Create a copy of GoogleSignInState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = freezed,Object? isInitialized = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_GoogleSignInState(
user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as GoogleSignInAccount?,isInitialized: null == isInitialized ? _self.isInitialized : isInitialized // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
