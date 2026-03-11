// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pin_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PinState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PinState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PinState()';
}


}

/// @nodoc
class $PinStateCopyWith<$Res>  {
$PinStateCopyWith(PinState _, $Res Function(PinState) __);
}


/// Adds pattern-matching-related methods to [PinState].
extension PinStatePatterns on PinState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Idle value)?  idle,TResult Function( _Loading value)?  loading,TResult Function( _PinAlreadySet value)?  pinAlreadySet,TResult Function( _PinSet value)?  pinSet,TResult Function( _PinVerified value)?  pinVerified,TResult Function( _PinFailed value)?  pinFailed,TResult Function( _LockedState value)?  locked,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle(_that);case _Loading() when loading != null:
return loading(_that);case _PinAlreadySet() when pinAlreadySet != null:
return pinAlreadySet(_that);case _PinSet() when pinSet != null:
return pinSet(_that);case _PinVerified() when pinVerified != null:
return pinVerified(_that);case _PinFailed() when pinFailed != null:
return pinFailed(_that);case _LockedState() when locked != null:
return locked(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Idle value)  idle,required TResult Function( _Loading value)  loading,required TResult Function( _PinAlreadySet value)  pinAlreadySet,required TResult Function( _PinSet value)  pinSet,required TResult Function( _PinVerified value)  pinVerified,required TResult Function( _PinFailed value)  pinFailed,required TResult Function( _LockedState value)  locked,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Idle():
return idle(_that);case _Loading():
return loading(_that);case _PinAlreadySet():
return pinAlreadySet(_that);case _PinSet():
return pinSet(_that);case _PinVerified():
return pinVerified(_that);case _PinFailed():
return pinFailed(_that);case _LockedState():
return locked(_that);case _Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Idle value)?  idle,TResult? Function( _Loading value)?  loading,TResult? Function( _PinAlreadySet value)?  pinAlreadySet,TResult? Function( _PinSet value)?  pinSet,TResult? Function( _PinVerified value)?  pinVerified,TResult? Function( _PinFailed value)?  pinFailed,TResult? Function( _LockedState value)?  locked,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle(_that);case _Loading() when loading != null:
return loading(_that);case _PinAlreadySet() when pinAlreadySet != null:
return pinAlreadySet(_that);case _PinSet() when pinSet != null:
return pinSet(_that);case _PinVerified() when pinVerified != null:
return pinVerified(_that);case _PinFailed() when pinFailed != null:
return pinFailed(_that);case _LockedState() when locked != null:
return locked(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  loading,TResult Function()?  pinAlreadySet,TResult Function()?  pinSet,TResult Function()?  pinVerified,TResult Function( int attemptsLeft)?  pinFailed,TResult Function( DateTime unlocksAt)?  locked,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle();case _Loading() when loading != null:
return loading();case _PinAlreadySet() when pinAlreadySet != null:
return pinAlreadySet();case _PinSet() when pinSet != null:
return pinSet();case _PinVerified() when pinVerified != null:
return pinVerified();case _PinFailed() when pinFailed != null:
return pinFailed(_that.attemptsLeft);case _LockedState() when locked != null:
return locked(_that.unlocksAt);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  loading,required TResult Function()  pinAlreadySet,required TResult Function()  pinSet,required TResult Function()  pinVerified,required TResult Function( int attemptsLeft)  pinFailed,required TResult Function( DateTime unlocksAt)  locked,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Idle():
return idle();case _Loading():
return loading();case _PinAlreadySet():
return pinAlreadySet();case _PinSet():
return pinSet();case _PinVerified():
return pinVerified();case _PinFailed():
return pinFailed(_that.attemptsLeft);case _LockedState():
return locked(_that.unlocksAt);case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  loading,TResult? Function()?  pinAlreadySet,TResult? Function()?  pinSet,TResult? Function()?  pinVerified,TResult? Function( int attemptsLeft)?  pinFailed,TResult? Function( DateTime unlocksAt)?  locked,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle();case _Loading() when loading != null:
return loading();case _PinAlreadySet() when pinAlreadySet != null:
return pinAlreadySet();case _PinSet() when pinSet != null:
return pinSet();case _PinVerified() when pinVerified != null:
return pinVerified();case _PinFailed() when pinFailed != null:
return pinFailed(_that.attemptsLeft);case _LockedState() when locked != null:
return locked(_that.unlocksAt);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Idle implements PinState {
  const _Idle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Idle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PinState.idle()';
}


}




/// @nodoc


class _Loading implements PinState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PinState.loading()';
}


}




/// @nodoc


class _PinAlreadySet implements PinState {
  const _PinAlreadySet();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PinAlreadySet);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PinState.pinAlreadySet()';
}


}




/// @nodoc


class _PinSet implements PinState {
  const _PinSet();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PinSet);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PinState.pinSet()';
}


}




/// @nodoc


class _PinVerified implements PinState {
  const _PinVerified();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PinVerified);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PinState.pinVerified()';
}


}




/// @nodoc


class _PinFailed implements PinState {
  const _PinFailed({required this.attemptsLeft});
  

 final  int attemptsLeft;

/// Create a copy of PinState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PinFailedCopyWith<_PinFailed> get copyWith => __$PinFailedCopyWithImpl<_PinFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PinFailed&&(identical(other.attemptsLeft, attemptsLeft) || other.attemptsLeft == attemptsLeft));
}


@override
int get hashCode => Object.hash(runtimeType,attemptsLeft);

@override
String toString() {
  return 'PinState.pinFailed(attemptsLeft: $attemptsLeft)';
}


}

/// @nodoc
abstract mixin class _$PinFailedCopyWith<$Res> implements $PinStateCopyWith<$Res> {
  factory _$PinFailedCopyWith(_PinFailed value, $Res Function(_PinFailed) _then) = __$PinFailedCopyWithImpl;
@useResult
$Res call({
 int attemptsLeft
});




}
/// @nodoc
class __$PinFailedCopyWithImpl<$Res>
    implements _$PinFailedCopyWith<$Res> {
  __$PinFailedCopyWithImpl(this._self, this._then);

  final _PinFailed _self;
  final $Res Function(_PinFailed) _then;

/// Create a copy of PinState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? attemptsLeft = null,}) {
  return _then(_PinFailed(
attemptsLeft: null == attemptsLeft ? _self.attemptsLeft : attemptsLeft // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _LockedState implements PinState {
  const _LockedState({required this.unlocksAt});
  

 final  DateTime unlocksAt;

/// Create a copy of PinState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LockedStateCopyWith<_LockedState> get copyWith => __$LockedStateCopyWithImpl<_LockedState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LockedState&&(identical(other.unlocksAt, unlocksAt) || other.unlocksAt == unlocksAt));
}


@override
int get hashCode => Object.hash(runtimeType,unlocksAt);

@override
String toString() {
  return 'PinState.locked(unlocksAt: $unlocksAt)';
}


}

/// @nodoc
abstract mixin class _$LockedStateCopyWith<$Res> implements $PinStateCopyWith<$Res> {
  factory _$LockedStateCopyWith(_LockedState value, $Res Function(_LockedState) _then) = __$LockedStateCopyWithImpl;
@useResult
$Res call({
 DateTime unlocksAt
});




}
/// @nodoc
class __$LockedStateCopyWithImpl<$Res>
    implements _$LockedStateCopyWith<$Res> {
  __$LockedStateCopyWithImpl(this._self, this._then);

  final _LockedState _self;
  final $Res Function(_LockedState) _then;

/// Create a copy of PinState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? unlocksAt = null,}) {
  return _then(_LockedState(
unlocksAt: null == unlocksAt ? _self.unlocksAt : unlocksAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class _Error implements PinState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of PinState
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
  return 'PinState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $PinStateCopyWith<$Res> {
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

/// Create a copy of PinState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
