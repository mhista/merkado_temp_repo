import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'google_sign_in_state.freezed.dart';

@freezed
abstract class GoogleSignInState with _$GoogleSignInState {
  const factory GoogleSignInState({
    GoogleSignInAccount? user,
    @Default(false) bool isInitialized,
    @Default(false) bool isLoading,
    String? error,
  }) = _GoogleSignInState;

  const GoogleSignInState._();

  bool get isSignedIn => user != null;
}