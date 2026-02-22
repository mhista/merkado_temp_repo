import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:common_utils2/common_utils2.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:merkado_auth/merkado_auth.dart';
import '../../domain/usecases/auth_usecases.dart';

part 'auth_state.dart';
part 'auth_cubit.freezed.dart';

/// AuthCubit
/// =========
/// The central state machine for the merkado_auth package.
///
/// INTERNAL ONLY — consuming apps interact via [AuthEventBus.instance.stream]
/// which emits [AuthResult] events. Apps never call cubit methods directly
/// unless they supply custom screens via [CustomAuthScreens].
///
/// TERMINATED STATE RESUMPTION:
/// On every app launch, [_checkStartupSession] reads stored flags to determine
/// exactly where the user left off:
///
///   No tokens stored           → unauthenticated (check SSO first)
///   Tokens + verified=false    → navigate to OTP screen (pre-fill email)
///   Tokens + verified=true
///     + onboarding=false       → navigate to onboarding screen
///   Tokens + verified=true
///     + onboarding=true
///     + token valid            → authenticated
///   Tokens + verified=true
///     + onboarding=true
///     + token expired          → attempt refresh → authenticated or expired
@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  // ── Use cases ──────────────────────────────────────────────────────────────
  final LoginUseCase _loginUseCase;
  final SignUpUseCase _signUpUseCase;
  final LogoutUseCase _logoutUseCase;
  final ResendOtpUseCase _resendOtpUseCase;
  final VerifyEmailUseCase _verifyEmailUseCase;
  final CompleteOnboardingUseCase _completeOnboardingUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final VerifyTwoFactorUseCase _verifyTwoFactorUseCase;
  final ExchangeRefreshTokenUseCase _exchangeRefreshTokenUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;

  // ── Services ───────────────────────────────────────────────────────────────
  final AuthSecureStorageService _storage = AuthSecureStorageService.instance;
  final AuthEventBus _eventBus = AuthEventBus.instance;

  // ── Config ─────────────────────────────────────────────────────────────────
  late final MerkadoAuthConfig _config;

  StreamSubscription? _reLoginSubscription;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required SignUpUseCase signUpUseCase,
    required LogoutUseCase logoutUseCase,
    required ResendOtpUseCase resendOtpUseCase,
    required VerifyEmailUseCase verifyEmailUseCase,
    required CompleteOnboardingUseCase completeOnboardingUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required VerifyTwoFactorUseCase verifyTwoFactorUseCase,
    required ExchangeRefreshTokenUseCase exchangeRefreshTokenUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignInWithAppleUseCase signInWithAppleUseCase,
  }) : _loginUseCase = loginUseCase,
       _signUpUseCase = signUpUseCase,
       _logoutUseCase = logoutUseCase,
       _resendOtpUseCase = resendOtpUseCase,
       _verifyEmailUseCase = verifyEmailUseCase,
       _completeOnboardingUseCase = completeOnboardingUseCase,
       _forgotPasswordUseCase = forgotPasswordUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       _verifyTwoFactorUseCase = verifyTwoFactorUseCase,
       _exchangeRefreshTokenUseCase = exchangeRefreshTokenUseCase,
       _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _signInWithAppleUseCase = signInWithAppleUseCase,
       super(const AuthState.initial());

  // ══════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ══════════════════════════════════════════════════════════════

  Future<void> init(MerkadoAuthConfig config) async {
    _config = config;

    _reLoginSubscription = ReLoginEventBus.instance.stream.listen(
      (userId) => _handleSessionExpired(userId: userId),
    );

    await _checkStartupSession();
  }

  /// Determines the correct startup state by reading stored flags.
  ///
  /// This handles every terminated-state scenario:
  ///
  /// SCENARIO 1 — No tokens at all:
  ///   Check for cross-app SSO accounts → show picker or login
  ///
  /// SCENARIO 2 — Tokens exist, email not verified:
  ///   User signed up, left before/during OTP screen
  ///   → Navigate directly to OTP screen with stored email pre-filled
  ///   → Access token may still be valid (900s), doesn't matter — OTP
  ///     verification doesn't need a valid access token
  ///
  /// SCENARIO 3 — Tokens exist, email verified, onboarding not complete:
  ///   User verified email, left before completing onboarding
  ///   → Navigate directly to onboarding screen
  ///
  /// SCENARIO 4 — Tokens exist, verified, onboarded, token valid:
  ///   Normal resumption → emit authenticated
  ///
  /// SCENARIO 5 — Tokens exist, verified, onboarded, token expired:
  ///   → Attempt refresh → if successful, authenticated
  ///   → If refresh fails, token is truly dead → session expired
  Future<void> _checkStartupSession() async {
    _emit(const AuthState.loading());
    _eventBus.emit(const AuthLoading());

    final accessToken = await _storage.getAccessToken();

    // ── No tokens — check SSO or show login ───────────────────────────────
    if (accessToken == null) {
      await _checkForCrossAppAccounts();
      return;
    }

    final emailVerified = await _storage.isEmailVerified();

    // ── SCENARIO 2: Tokens exist but email not verified ───────────────────
    // User was mid-verification when app was killed. Resume OTP screen.
    if (!emailVerified) {
      final pendingEmail = await _storage.getPendingVerificationEmail();
      final storedEmail = await _storage.getUserEmail();
      final email = pendingEmail ?? storedEmail ?? '';

      _emit(AuthState.emailNotVerified(email: email));
      _eventBus.emit(AuthEmailNotVerified(email: email));
      return;
    }

    final onboardingDone = await _storage.isOnboardingCompleted();

    // ── SCENARIO 3: Verified but onboarding incomplete ────────────────────
    // User verified email, left before finishing profile setup. Resume onboarding.
    if (!onboardingDone) {
      _emit(const AuthState.onboardingRequired());
      _eventBus.emit(const AuthOnboardingRequired());
      return;
    }

    // ── SCENARIO 4 & 5: Fully signed up — check token validity ───────────
    final tokenValid = await _storage.isAccessTokenValid();

    if (tokenValid) {
      // Token is still alive — emit authenticated immediately
      _emit(const AuthState.authenticated());
      _eventBus.emit(AuthSuccess(accessToken: accessToken));
      return;
    }

    // Token expired — attempt refresh before giving up
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      // No refresh token either — session is completely dead
      await _storage.clearLocalSession();
      await _checkForCrossAppAccounts();
      return;
    }

    await _attemptRefreshOnStartup(refreshToken);
  }

  /// Attempts to refresh the access token on startup.
  /// On success: saves new tokens, emits authenticated.
  /// On failure: clears session, shows SSO picker or login.
  Future<void> _attemptRefreshOnStartup(String refreshToken) async {
    final result = await _exchangeRefreshTokenUseCase(
      refreshToken: refreshToken,
      platformId: _config.platformId,
      scopes: _scopesForPlatform(_config.platformId),
    );

    result.when(
      failure: (error, _) async {
        // Refresh token is dead — clear everything and restart
        final userId = await _storage.getUserId();
        await _storage.clearLocalSession();
        if (userId != null) {
          await _storage.removeKnownAccount(userId);
        }
        await _checkForCrossAppAccounts();
      },
      success: (data) async {
        // Save the new tokens
        await _storage.saveAccessToken(
          data['accessToken'] as String,
          expiresIn: data['expiresIn'] as int? ?? 900,
        );

        // Update refresh token if rotated
        if (data['refreshToken'] != null) {
          final userId = await _storage.getUserId() ?? '';
          final email = await _storage.getUserEmail() ?? '';
          await _storage.upsertKnownAccount(
            GrascopeSessionHint.create(
              userId: userId,
              displayName: await _storage.getUserDisplayName() ?? email,
              avatarUrl: await _storage.getUserAvatarUrl() ?? '',
              email: email,
              refreshToken: data['refreshToken'] as String,
              sourcePlatformId: _config.platformId,
            ),
          );
        }

        final newToken = data['accessToken'] as String;
        _emit(const AuthState.authenticated());
        _eventBus.emit(AuthSuccess(accessToken: newToken));
      },
    );
  }

  /// Reads known accounts from shared storage.
  /// Emits account picker if accounts found, login screen if none.
  Future<void> _checkForCrossAppAccounts() async {
    if (!_config.features.crossAppSso) {
      _emit(const AuthState.unauthenticated());
      _eventBus.emit(const AuthUnauthenticated());
      return;
    }

    final accounts = await _storage.getKnownAccounts();
    if (accounts.isEmpty) {
      _emit(const AuthState.unauthenticated());
      _eventBus.emit(const AuthUnauthenticated());
    } else {
      _emit(AuthState.accountsDetected(accounts: accounts));
      _eventBus.emit(AuthAccountsDetected(accounts: accounts));
    }
  }

  // ══════════════════════════════════════════════════════════════
  // LOGIN
  // ══════════════════════════════════════════════════════════════

  Future<void> login({
    required String email,
    required String password,
    String? fcmToken,
    String? deviceName,
    String? deviceOs,
  }) async {
    _emit(const AuthState.loading());
    _eventBus.emit(const AuthLoading());

    final result = await _loginUseCase(
      data: {
        'email': email,
        'password': password,
        'platformId': _config.platformId,
        'deviceName': deviceName ?? 'Unknown Device',
        'deviceType': 'mobile',
        'deviceOs': deviceOs ?? 'Unknown',
        'fcmToken': fcmToken ?? '',
      },
    );

    result.when(
      failure: (error, _) {
        _emit(AuthState.error(error));
        _eventBus.emit(AuthFailure(message: error));
      },
      success: (data) async {
        await _handleAuthResponse(data, email: email);
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SOCIAL LOGIN
  // ══════════════════════════════════════════════════════════════

  /// Sign in with Google.
  ///
  /// The consuming app handles the native Google Sign-In flow and passes
  /// the [idToken] here. The package sends it to POST /auth/social/google
  /// and processes the response exactly like a normal login.
  ///
  /// USAGE IN CONSUMING APP:
  /// ```dart
  /// // 1. Trigger Google Sign-In (consuming app's responsibility)
  /// final googleUser = await GoogleSignIn().signIn();
  /// final auth = await googleUser!.authentication;
  ///
  /// // 2. Hand the token to the package
  /// MerkadoAuth.instance.cubit.signInWithGoogle(
  ///   idToken: auth.idToken!,
  ///   deviceName: deviceInfo.name,
  ///   deviceOs: deviceInfo.os,
  /// );
  /// ```
  Future<void> signInWithGoogle({
    required String idToken,
    String? fcmToken,
    String? deviceName,
    String? deviceOs,
  }) async {
    _emit(const AuthState.loading());
    _eventBus.emit(const AuthLoading());

    final result = await _signInWithGoogleUseCase(
      idToken: idToken,
      deviceInfo: {
        'platformId': _config.platformId,
        'deviceName': deviceName ?? 'Unknown Device',
        'deviceType': 'mobile',
        'deviceOs': deviceOs ?? 'Unknown',
        'fcmToken': fcmToken ?? '',
      },
    );

    result.when(
      failure: (error, _) {
        _emit(AuthState.error(error));
        _eventBus.emit(AuthFailure(message: error));
      },
      success: (data) async {
        // Social login response follows the same shape as email login
        await _handleAuthResponse(data, email: data['email'] as String? ?? '');
      },
    );
  }

  /// Sign in with Apple.
  ///
  /// The consuming app handles the native Apple Sign In flow and passes the
  /// tokens here. IMPORTANT: Apple only provides [firstName] and [lastName]
  /// on the very first authentication. Cache them before calling this if needed.
  ///
  /// USAGE IN CONSUMING APP:
  /// ```dart
  /// // 1. Trigger Apple Sign In (consuming app's responsibility)
  /// final credential = await SignInWithApple.getAppleIDCredential(
  ///   scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
  /// );
  ///
  /// // 2. Hand tokens to the package
  /// MerkadoAuth.instance.cubit.signInWithApple(
  ///   identityToken: credential.identityToken!,
  ///   authorizationCode: credential.authorizationCode,
  ///   firstName: credential.givenName,
  ///   lastName: credential.familyName,
  /// );
  /// ```
  Future<void> signInWithApple({
    required String identityToken,
    required String authorizationCode,
    String? firstName,
    String? lastName,
    String? fcmToken,
    String? deviceName,
    String? deviceOs,
  }) async {
    _emit(const AuthState.loading());
    _eventBus.emit(const AuthLoading());

    final result = await _signInWithAppleUseCase(
      identityToken: identityToken,
      authorizationCode: authorizationCode,
      firstName: firstName,
      lastName: lastName,
      deviceInfo: {
        'platformId': _config.platformId,
        'deviceName': deviceName ?? 'Unknown Device',
        'deviceType': 'mobile',
        'deviceOs': deviceOs ?? 'Unknown',
        'fcmToken': fcmToken ?? '',
      },
    );

    result.when(
      failure: (error, _) {
        _emit(AuthState.error(error));
        _eventBus.emit(AuthFailure(message: error));
      },
      success: (data) async {
        await _handleAuthResponse(data, email: data['email'] as String? ?? '');
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SHARED AUTH RESPONSE HANDLER
  // ══════════════════════════════════════════════════════════════

  /// Handles any auth response that returns the standard token payload.
  /// Used by login, social login, 2FA, and refresh flows.
  ///
  /// Decision tree:
  ///   isMfa=true              → MFA screen
  ///   verified=false          → OTP screen (save tokens for resumption)
  ///   onboardingCompleted=false → onboarding screen (save tokens for resumption)
  ///   all good                → persist final session → authenticated
  Future<void> _handleAuthResponse(
    Map<String, dynamic> data, {
    required String email,
  }) async {
    // ── 2FA ───────────────────────────────────────────────────────────────
    if (data['isMfa'] == true) {
      final userId = data['userId'] as String;
      final message = data['message'] as String? ?? 'Enter your 2FA code';
      _emit(AuthState.mfaRequired(userId: userId, message: message));
      _eventBus.emit(AuthMfaRequired(userId: userId, message: message));
      return;
    }
    LoggerService.instance.info('[AuthCubit] Auth response data: $data');
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;
    final expiresIn = data['expiresIn'] as int? ?? 900;
    final sessionId = data['sessionId'] as String? ?? '';
    final userId = data['userId'] as String? ?? '';
    final verified = data['verified'] as bool? ?? false;
    final onboardingCompleted = data['onboardingCompleted'] as bool? ?? false;

    // Save tokens immediately — regardless of verification status.
    // This is what enables terminated state resumption. The user has tokens,
    // we just track what stage they're at with the flag fields.
    await _storage.saveInitialSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
      sessionId: sessionId,
      userId: userId,
      email: email,
      verified: verified,
      onboardingCompleted: onboardingCompleted,
      platformId: _config.platformId,
    );

    // ── Email not verified ─────────────────────────────────────────────────
    if (!verified) {
      // Save email so OTP screen can be resumed after app termination
      await _storage.savePendingVerificationEmail(email);

      _emit(AuthState.emailNotVerified(email: email));
      _eventBus.emit(AuthEmailNotVerified(email: email));
      return;
    }

    // ── Onboarding required ────────────────────────────────────────────────
    if (!onboardingCompleted) {
      _emit(const AuthState.onboardingRequired());
      _eventBus.emit(const AuthOnboardingRequired());
      return;
    }

    // ── Fully authenticated ────────────────────────────────────────────────
    _emit(const AuthState.authenticated());
    _eventBus.emit(AuthSuccess(accessToken: accessToken));
  }

  // ══════════════════════════════════════════════════════════════
  // SIGN UP
  // ══════════════════════════════════════════════════════════════

  Future<void> signUp({
    required String email,
    required String password,
    String? fcmToken,
    String? deviceName,
    String? deviceOs,
  }) async {
    _emit(const AuthState.loading());
    _eventBus.emit(const AuthLoading());

    final result = await _signUpUseCase(
      email: email,
      password: password,
      deviceInfo: {
        'platformId': _config.platformId,
        'deviceName': deviceName ?? 'Unknown Device',
        'deviceType': 'mobile',
        'deviceOs': deviceOs ?? 'Unknown',
        'fcmToken': fcmToken ?? '',
      },
    );

    result.when(
      failure: (error, _) {
        _emit(AuthState.error(error));
        _eventBus.emit(AuthFailure(message: error));
      },
      success: (data) async {
        // Signup returns tokens immediately — handle through shared pipeline
        await _handleAuthResponse(data, email: email);
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // OTP VERIFICATION
  // ══════════════════════════════════════════════════════════════

  Future<void> verifyEmail({required String email, required String otp}) async {
    _emit(const AuthState.loading());

    final result = await _verifyEmailUseCase(email: email, otp: otp);

    result.when(
      failure: (error, _) {
        _emit(AuthState.error(error));
        _eventBus.emit(AuthFailure(message: error));
      },
      success: (data) async {
        // Verification response: { message: "Email verified successfully" }
        // No tokens returned — they were already saved during signup.
        // Update the verified flag and clear the pending email.
        await _storage.saveEmailVerified(true);
        await _storage.clearPendingVerificationEmail();

        final message =
            data['message'] as String? ?? 'Email verified successfully';
        _emit(AuthState.otpVerified(message: message));
        _eventBus.emit(AuthOtpVerified(message: message));

        // Navigate to onboarding next
        _emit(const AuthState.onboardingRequired());
        _eventBus.emit(const AuthOnboardingRequired());
      },
    );
  }

  Future<void> resendOtp({required String email}) async {
    _emit(const AuthState.loading());

    final result = await _resendOtpUseCase(email: email);

    result.when(
      failure: (error, _) {
        _emit(AuthState.error(error));
        _eventBus.emit(AuthFailure(message: error));
      },
      success: (_) => _emit(const AuthState.otpResent()),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ONBOARDING
  // ══════════════════════════════════════════════════════════════

  /// Complete the onboarding step after email verification.
  ///
  /// This is the final gate before the user is considered authenticated.
  /// After this succeeds, we update the shared SSO hint with real display
  /// name and avatar so other Grascope apps can show "Continue as Amara"
  /// instead of the email address.
  Future<void> completeOnboarding({
    required String firstName,
    required String lastName,
    required String country,
    String? avatarUrl,
  }) async {
    _emit(const AuthState.loading());

    final result = await _completeOnboardingUseCase(
      firstName: firstName,
      lastName: lastName,
      country: country,
      avatarUrl: avatarUrl,
    );

    result.when(
      failure: (error, _) {
        _emit(AuthState.error(error));
        _eventBus.emit(AuthFailure(message: error));
      },
      success: (data) async {
        final displayName = '$firstName $lastName'.trim();
        final userId = await _storage.getUserId() ?? '';
        final refreshToken = await _storage.getRefreshToken() ?? '';

        // Update shared SSO hint with real name now that we have it
        await _storage.updateSharedAccountHint(
          userId: userId,
          displayName: displayName,
          avatarUrl: avatarUrl ?? '',
          refreshToken: refreshToken,
        );

        final accessToken = await _storage.getAccessToken() ?? '';
        _emit(const AuthState.authenticated());
        _eventBus.emit(AuthSuccess(accessToken: accessToken));
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // CROSS-APP SSO
  // ══════════════════════════════════════════════════════════════

  /// Called when user selects a known account from the account picker.
  /// Exchanges the stored refresh token for a scoped access token for this app.
  /// Handles expired tokens gracefully with targeted error messaging.
  Future<void> continueAsAccount(GrascopeSessionHint hint) async {
    _emit(const AuthState.loading());
    _eventBus.emit(const AuthLoading());

    final result = await _exchangeRefreshTokenUseCase(
      refreshToken: hint.refreshToken,
      platformId: _config.platformId,
      scopes: _scopesForPlatform(_config.platformId),
    );

    result.when(
      failure: (error, _) async {
        // Refresh token dead — remove stale account from shared list
        await _storage.removeKnownAccount(hint.userId);

        _emit(
          AuthState.sessionExpiredForAccount(
            userId: hint.userId,
            displayName: hint.displayName,
          ),
        );
        _eventBus.emit(
          AuthExpired(userId: hint.userId, displayName: hint.displayName),
        );
      },
      success: (data) async {
        final accessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String?;
        final expiresIn = data['expiresIn'] as int? ?? 900;

        await _storage.saveAccessToken(accessToken, expiresIn: expiresIn);
        await _storage.saveUserId(hint.userId);
        await _storage.saveUserEmail(hint.email);
        await _storage.saveEmailVerified(true);
        await _storage.saveOnboardingCompleted(true);

        // Update refresh token in shared storage if rotated
        if (newRefreshToken != null && newRefreshToken != hint.refreshToken) {
          await _storage.upsertKnownAccount(
            hint.copyWith(refreshToken: newRefreshToken),
          );
        }

        _emit(const AuthState.authenticated());
        _eventBus.emit(
          AuthSuccess(accessToken: accessToken, fromCrossAppSso: true),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 2FA
  // ══════════════════════════════════════════════════════════════

  Future<void> verifyTwoFactor({
    required String userId,
    required String otp,
  }) async {
    _emit(const AuthState.loading());

    final result = await _verifyTwoFactorUseCase(userId: userId, otp: otp);

    result.when(
      failure: (error, _) {
        _emit(AuthState.error(error));
        _eventBus.emit(AuthFailure(message: error));
      },
      success: (data) async {
        final email = data['email'] as String? ?? '';
        await _handleAuthResponse(data, email: email);
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PASSWORD RESET
  // ══════════════════════════════════════════════════════════════

  Future<void> forgotPassword({required String email}) async {
    _emit(const AuthState.loading());

    final result = await _forgotPasswordUseCase(email: email);

    result.when(
      failure: (error, _) {
        _emit(AuthState.error(error));
        _eventBus.emit(AuthFailure(message: error));
      },
      success: (_) => _emit(const AuthState.passwordResetSent()),
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _emit(const AuthState.loading());

    final result = await _resetPasswordUseCase(
      token: token,
      newPassword: newPassword,
    );

    result.when(
      failure: (error, _) {
        _emit(AuthState.error(error));
        _eventBus.emit(AuthFailure(message: error));
      },
      success: (_) => _emit(const AuthState.passwordResetSuccess()),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // LOGOUT
  // ══════════════════════════════════════════════════════════════

  /// Logs out the current account in this app.
  /// Removes this account from shared storage — other accounts unaffected.
  Future<void> logout() async {
    _emit(const AuthState.loading());

    final sessionId = await _storage.getSessionId();
    final userId = await _storage.getUserId();

    if (sessionId != null) {
      await _logoutUseCase(sessionId: sessionId);
    }

    if (userId != null) {
      await _storage.fullLogout(userId);
    } else {
      await _storage.clearLocalSession();
    }

    _emit(const AuthState.unauthenticated());
    _eventBus.emit(const AuthLoggedOut());
  }

  /// Logs out ALL known Grascope accounts on this device.
  Future<void> logoutAll() async {
    _emit(const AuthState.loading());

    final sessionId = await _storage.getSessionId();
    if (sessionId != null) {
      await _logoutUseCase(sessionId: sessionId);
    }

    await _storage.clearLocalSession();
    await _storage.clearAllKnownAccounts();

    _emit(const AuthState.unauthenticated());
    _eventBus.emit(const AuthLoggedOut());
  }

  // ══════════════════════════════════════════════════════════════
  // SESSION EXPIRY (from interceptor)
  // ══════════════════════════════════════════════════════════════

  Future<void> _handleSessionExpired({String? userId}) async {
    String? displayName;

    if (userId != null) {
      final accounts = await _storage.getKnownAccounts();
      displayName = accounts
          .where((a) => a.userId == userId)
          .map((a) => a.displayName)
          .firstOrNull;

      await _storage.removeKnownAccount(userId);
    }

    await _storage.clearLocalSession();

    _emit(
      AuthState.sessionExpiredForAccount(
        userId: userId,
        displayName: displayName,
      ),
    );
    _eventBus.emit(AuthExpired(userId: userId, displayName: displayName));
  }

  // ══════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════

  List<String> _scopesForPlatform(String platformId) {
    return [
      'profile:read',
      'wallet:read',
      '${_platformSlug(platformId)}:read',
      '${_platformSlug(platformId)}:write',
    ];
  }

  String _platformSlug(String platformId) {
    const slugs = {
      '019c761c-d25e-7257-b5ec-8af95ddd202c': 'mycut',
      '019c761c-d265-7a25-a095-ec995157cb32': 'driply',
      '019c761c-d265-7a25-a095-ec9a7262b4fa': 'haulway',
      '019c761c-d265-7a25-a095-ec9bfcd940d6': 'feastfeed',
      '019c761c-d265-7a25-a095-ec9c5ad364f5': 'itsyourday',
    };
    return slugs[platformId] ?? 'merkado';
  }

  void _emit(AuthState state) {
    if (!isClosed) emit(state);
  }

  @override
  Future<void> close() {
    _reLoginSubscription?.cancel();
    return super.close();
  }
}
