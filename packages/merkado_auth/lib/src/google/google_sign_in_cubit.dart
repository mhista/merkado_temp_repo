import 'package:flutter_bloc/flutter_bloc.dart';
import 'google_sign_in_service.dart';
import 'google_sign_in_state.dart';
import 'google_sign_in_config.dart';
import 'google_sign_in_exception.dart';

class GoogleSignInCubit extends Cubit<GoogleSignInState> {
  final GoogleSignInService service;

  GoogleSignInCubit({required this.service}) : super(const GoogleSignInState()) {
    service.stateStream.listen((newState) {
      if (!isClosed) emit(newState);
    });
  }

  Future<void> initialize([GoogleSignInConfig? config]) async {
    emit(state.copyWith(isLoading: true));
    try {
      await service.initialize(config);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> signIn({List<String>? additionalScopes}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await service.signIn(additionalScopes: additionalScopes);
    } on GoogleAuthException catch (e) {
      emit(state.copyWith(isLoading: false, error: e.message));
    }
  }

  Future<void> attemptSilentSignIn() async {
    try {
      await service.attemptSilentSignIn();
    } catch (_) {}
  }

  Future<void> signOut() async {
    emit(state.copyWith(isLoading: true));
    try {
      await service.signOut();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    service.dispose();
    return super.close();
  }
}