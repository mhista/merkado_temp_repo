import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'google_sign_in_config.dart';
import 'google_sign_in_exception.dart';
import 'google_sign_in_state.dart';

class GoogleSignInService {
  GoogleSignIn? _googleSignIn;
  GoogleSignInAccount? _currentUser;
  GoogleSignInState _state = const GoogleSignInState();

  final StreamController<GoogleSignInState> _stateController =
      StreamController<GoogleSignInState>.broadcast();

  Stream<GoogleSignInState> get stateStream => _stateController.stream;
  GoogleSignInState get state => _state;
  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;
  bool get isInitialized => _state.isInitialized;

  // ── V7.0: REQUIRED async initialization ──────────────────────────────────

  Future<void> initialize([GoogleSignInConfig? config]) async {
    if (_state.isInitialized) {
      debugPrint('⚠️ Already initialized');
      return;
    }

    _updateState(_state.copyWith(isLoading: true));

    try {
      final cfg = config ?? GoogleSignInConfig.defaultConfig();

      _googleSignIn = GoogleSignIn.instance;
      await _googleSignIn!.initialize(
        hostedDomain: cfg.hostedDomain,
        serverClientId: cfg.serverClientId,
      ); // V7.0: async!

      _updateState(_state.copyWith(isInitialized: true, isLoading: false));
      debugPrint('✅ Google Sign-In initialized');
    } catch (e) {
      _updateState(_state.copyWith(isLoading: false, error: e.toString()));
      throw GoogleAuthException.generic('Initialization failed', e);
    }
  }

  // ── V7.0: authenticate() replaces signIn() ────────────────────────────────

  Future<GoogleSignInAccount> signIn({List<String>? additionalScopes}) async {
    await _ensureInitialized();

    if (!_googleSignIn!.supportsAuthenticate()) {
      // V7.0: synchronous
      throw GoogleAuthException.platformNotSupported();
    }

    _updateState(_state.copyWith(isLoading: true, error: null));

    try {
      final account = await _googleSignIn!.authenticate(
        // V7.0: new method
        scopeHint: ['email', ...additionalScopes ?? []],
      );

      _currentUser = account;
      _updateState(_state.copyWith(user: account, isLoading: false));
      debugPrint('✅ Signed in as ${account.email}');
      return account;
    } on GoogleSignInException catch (e) {
      final ex = GoogleAuthException.fromGoogleSignInException(e);
      _updateState(_state.copyWith(isLoading: false, error: ex.message));
      throw ex;
    } catch (e) {
      final ex = GoogleAuthException.generic('Sign-in failed', e);
      _updateState(_state.copyWith(isLoading: false, error: ex.message));
      throw ex;
    }
  }

  // ── V7.0: attemptLightweightAuthentication replaces signInSilently ────────

  Future<GoogleSignInAccount?> attemptSilentSignIn() async {
    await _ensureInitialized();

    try {
      final result = _googleSignIn!.attemptLightweightAuthentication();

      // V7.0: Can return Future or immediate result
      GoogleSignInAccount? account;
      if (result is Future<GoogleSignInAccount?>) {
        account = await result;
      } else {
        account = result as GoogleSignInAccount?;
      }

      if (account != null) {
        _currentUser = account;
        _updateState(_state.copyWith(user: account));
        debugPrint('✅ Silent sign-in: ${account.email}');
      }

      return account;
    } catch (e) {
      debugPrint('⚠️ Silent sign-in failed: $e');
      return null;
    }
  }

  // ── Sign Out / Disconnect ─────────────────────────────────────────────────

  Future<void> signOut() async {
    await _ensureInitialized();
    await _googleSignIn!.signOut();
    _currentUser = null;
    _updateState(_state.copyWith(user: null));
    debugPrint('✅ Signed out');
  }

  Future<void> disconnect() async {
    await _ensureInitialized();
    await _googleSignIn!.disconnect();
    _currentUser = null;
    _updateState(_state.copyWith(user: null));
    debugPrint('✅ Disconnected');
  }

  // ── V7.0: Tokens (now synchronous!) ───────────────────────────────────────

  GoogleSignInAuthentication getAuthTokens(GoogleSignInAccount account) {
    return account.authentication; // V7.0: No await needed!
  }

  // ── V7.0: Enhanced scope management ───────────────────────────────────────

  Future<String?> getAccessTokenForScopes(List<String> scopes) async {
    await _ensureInitialized();

    try {
      final authClient = _googleSignIn!.authorizationClient;

      var auth = await authClient.authorizationForScopes(scopes);
      auth ??= await authClient.authorizeScopes(scopes);

      return auth?.accessToken;
    } catch (e) {
      debugPrint('❌ Scope authorization failed: $e');
      return null;
    }
  }

  Future<bool> hasScopes(List<String> scopes) async {
    await _ensureInitialized();
    try {
      final auth = await _googleSignIn!.authorizationClient
          .authorizationForScopes(scopes);
      return auth != null;
    } catch (e) {
      return false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _ensureInitialized() async {
    if (!_state.isInitialized) {
      throw GoogleAuthException.notInitialized();
    }
  }

  void _updateState(GoogleSignInState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  void dispose() {
    _stateController.close();
  }
}
