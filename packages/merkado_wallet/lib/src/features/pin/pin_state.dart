part of 'pin_cubit.dart';

@freezed
abstract class PinState with _$PinState {
  const factory PinState.idle() = _Idle;
  const factory PinState.loading() = _Loading;
  const factory PinState.pinAlreadySet() = _PinAlreadySet;
  const factory PinState.pinSet() = _PinSet;
  const factory PinState.pinVerified() = _PinVerified;

  const factory PinState.pinFailed({
    required int attemptsLeft,
  }) = _PinFailed;

  const factory PinState.locked({
    required DateTime unlocksAt,
  }) = _LockedState;

  const factory PinState.error(String message) = _Error;
}