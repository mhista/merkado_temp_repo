part of 'user_cubit.dart';

@freezed
class UserState with _$UserState {
  /// No user set yet — waiting for app to call setUser().
  const factory UserState.empty() = _Empty;

  /// User profile is available.
  const factory UserState.loaded({required WalletUser user}) = _Loaded;
}