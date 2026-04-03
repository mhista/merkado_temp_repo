import 'dart:async';
import 'dart:io';
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
  final RequestPasswordResetUseCase _requestPasswordResetUseCase;
  final VerifyPasswordResetUseCase _verifyPasswordResetUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final VerifyTwoFactorUseCase _verifyTwoFactorUseCase;
  final ExchangeRefreshTokenUseCase _exchangeRefreshTokenUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;

  // ── Services ───────────────────────────────────────────────────────────────
  final AuthSecureStorageService _storage = AuthSecureStorageService.instance;
  final AuthEventBus _eventBus = AuthEventBus.instance;

  // ── Logger (optional — injected from app via MerkadoAuth.initialize) ───────
  // Never creates its own LoggerService. If null, logging is silently skipped.
  final LoggerService? _log;

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
    required RequestPasswordResetUseCase requestPasswordResetUseCase,
    required VerifyPasswordResetUseCase verifyPasswordResetUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required VerifyTwoFactorUseCase verifyTwoFactorUseCase,
    required ExchangeRefreshTokenUseCase exchangeRefreshTokenUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignInWithAppleUseCase signInWithAppleUseCase,
    LoggerService? logger,
  }) : _loginUseCase = loginUseCase,
       _signUpUseCase = signUpUseCase,
       _logoutUseCase = logoutUseCase,
       _resendOtpUseCase = resendOtpUseCase,
       _verifyEmailUseCase = verifyEmailUseCase,
       _completeOnboardingUseCase = completeOnboardingUseCase,
       _requestPasswordResetUseCase = requestPasswordResetUseCase,
       _verifyPasswordResetUseCase = verifyPasswordResetUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       _verifyTwoFactorUseCase = verifyTwoFactorUseCase,
       _exchangeRefreshTokenUseCase = exchangeRefreshTokenUseCase,
       _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _signInWithAppleUseCase = signInWithAppleUseCase,
       _log = logger,
       super(const AuthState.initial());

  // ══════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ══════════════════════════════════════════════════════════════

  Future<void> init(MerkadoAuthConfig config) async {
    _config = config;
    _log?.info('[AuthCubit] init — platform: ${config.platformName}');

    _reLoginSubscription = ReLoginEventBus.instance.stream.listen(
      (userId) => _handleSessionExpired(userId: userId),
    );

    await _checkStartupSession();
  }

  // ── Timeout durations ─────────────────────────────────────────────────────
  // OTP: 15 minutes (matches access token lifetime — expired token = rejected OTP anyway)
  // Onboarding: 30 minutes (profile setup takes longer, no token risk)
  static const _otpTimeout = Duration(minutes: 15);
  static const _onboardingTimeout = Duration(minutes: 30);

  Future<void> _checkStartupSession() async {
    _log?.debug('[AuthCubit] Checking startup session...');
    _emit(const AuthState.loading());
    _eventBus.emit(const AuthLoading());

    final accessToken = await _storage.getAccessToken();

    if (accessToken == null) {
      _log?.debug('[AuthCubit] No token found — checking cross-app accounts');
      await _checkForCrossAppAccounts();
      return;
    }

    final emailVerified = await _storage.isEmailVerified();

    if (!emailVerified) {
      // ── OTP timeout check ────────────────────────────────────────────────
      // If the user left mid-verification and it's been > 15 minutes,
      // the OTP they received has expired and the backend will reject it.
      // Route to login so they can re-enter credentials — login will detect
      // verified=false and send them a fresh OTP.
      final otpExpired = await _storage.isOtpWindowExpired(
        timeout: _otpTimeout,
      );
      if (otpExpired) {
        _log?.warning(
          '[AuthCubit] OTP window expired after ${_otpTimeout.inMinutes}min — clearing session, routing to login',
        );
        await _storage.clearLocalSession();
        await _checkForCrossAppAccounts();
        return;
      }

      final pendingEmail = await _storage.getPendingVerificationEmail();
      final storedEmail = await _storage.getUserEmail();
      final email = pendingEmail ?? storedEmail ?? '';
      _log?.info(
        '[AuthCubit] Token valid, email not verified — resuming OTP for $email',
      );
      _emit(AuthState.emailNotVerified(email: email));
      _eventBus.emit(AuthEmailNotVerified(email: email));
      return;
    }

    final onboardingDone = await _storage.isOnboardingCompleted();

    if (!onboardingDone) {
      // ── Onboarding timeout check ─────────────────────────────────────────
      // If the user left mid-onboarding and it's been > 30 minutes,
      // route to login. Their account exists and is verified — login will
      // detect onboardingCompleted=false and send them back to onboarding.
      final onboardingExpired = await _storage.isOnboardingWindowExpired(
        timeout: _onboardingTimeout,
      );
      if (onboardingExpired) {
        _log?.warning(
          '[AuthCubit] Onboarding window expired after ${_onboardingTimeout.inMinutes}min — clearing session, routing to login',
        );
        await _storage.clearLocalSession();
        await _checkForCrossAppAccounts();
        return;
      }

      _log?.info(
        '[AuthCubit] Email verified, onboarding incomplete — resuming onboarding',
      );
      _emit(const AuthState.onboardingRequired());
      _eventBus.emit(const AuthOnboardingRequired());
      return;
    }

    final tokenValid = await _storage.isAccessTokenValid();

    if (tokenValid) {
      _log?.info('[AuthCubit] Valid session found — authenticated');
      _emit(const AuthState.authenticated());
      _eventBus.emit(AuthSuccess(accessToken: accessToken));
      return;
    }

    _log?.debug('[AuthCubit] Token expired — attempting refresh');
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      _log?.warning('[AuthCubit] No refresh token — clearing session');
      await _storage.clearLocalSession();
      await _checkForCrossAppAccounts();
      return;
    }

    await _attemptRefreshOnStartup(refreshToken);
  }

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

  Future<void> _attemptRefreshOnStartup(String refreshToken) async {
    _log?.debug('[AuthCubit] Attempting token refresh on startup');
    final result = await _exchangeRefreshTokenUseCase(
      refreshToken: refreshToken,
      platformId: _config.platformId,
      scopes: _scopesForPlatform(_config.platformId),
    );

    result.when(
      failure: (error, _) async {
        _log?.warning('[AuthCubit] Startup refresh failed — clearing session');
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
          expiresIn: data['expiresIn'] as int? ?? 1800,
        );

        // ✅ ADD THIS — persist new refresh token to local storage.
        // Without it, _storage.getRefreshToken() still returns the old token,
        // so the interceptor's second refresh attempt sends a stale token → 401.
        if (data['refreshToken'] != null) {
          await _storage.saveRefreshToken(data['refreshToken'] as String);
        }

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

  /// This ensures a user who has multiple accounts on THIS app always
  /// sees the local switcher, not the cross-app SSO picker.
  Future<void> _checkForCrossAppAccounts() async {
    final allAccounts = await _storage.getKnownAccounts();

    // ── Step 1: Local accounts for this app ─────────────────────────────────
    final localAccounts = allAccounts
        .where((a) => a.sourcePlatformId == _config.platformId)
        .toList();

    if (localAccounts.isNotEmpty) {
      _log?.debug(
        '[AuthCubit] Found \${localAccounts.length} local account(s) for ${_config.platformId}',
      );
      _emit(AuthState.localAccountsDetected(accounts: localAccounts));
      _eventBus.emit(AuthAccountsDetected(accounts: localAccounts));
      return;
    }

    // ── Step 2: Cross-app SSO accounts (other Grascope apps) ────────────────
    if (_config.features.crossAppSso) {
      final crossAppAccounts = allAccounts
          .where((a) => a.sourcePlatformId != _config.platformId)
          .toList();

      if (crossAppAccounts.isNotEmpty) {
        _log?.debug(
          '[AuthCubit] Found \${crossAppAccounts.length} cross-app account(s)',
        );
        _emit(AuthState.accountsDetected(accounts: crossAppAccounts));
        _eventBus.emit(AuthAccountsDetected(accounts: crossAppAccounts));
        return;
      }
    }

    // ── Step 3: No accounts found anywhere ───────────────────────────────────
    _log?.debug('[AuthCubit] No known accounts — emitting unauthenticated');
    _emit(const AuthState.unauthenticated());
    _eventBus.emit(const AuthUnauthenticated());
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
    _log?.info('[AuthCubit] Login attempt — $email');
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
    _log?.info('[AuthCubit] Sign in with Google');
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
    _log?.info('[AuthCubit] Sign in with Apple');
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
    _log?.debug('[AuthCubit] _handleAuthResponse — isMfa: ${data['isMfa']}');
    if (data['isMfa'] == true) {
      final userId = data['userId'] as String;
      final message = data['message'] as String? ?? 'Enter your 2FA code';
      _log?.info('[AuthCubit] 2FA required for userId: $userId');
      _emit(AuthState.mfaRequired(userId: userId, message: message));
      _eventBus.emit(AuthMfaRequired(userId: userId, message: message));
      return;
    }

    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;
    final expiresIn = data['expiresIn'] as int? ?? 900;
    final sessionId = data['sessionId'] as String? ?? '';
    final userId = data['userId'] as String? ?? '';
    final verified = data['verified'] as bool? ?? false;
    final onboardingCompleted = data['onboardingCompleted'] as bool? ?? false;

    _log?.debug(
      '[AuthCubit] Auth response — verified: $verified, onboardingCompleted: $onboardingCompleted, userId: $userId',
    );

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

    if (!verified) {
      _log?.info(
        '[AuthCubit] Email not verified — saving pending email: $email',
      );
      await _storage.savePendingVerificationEmail(email);
      _emit(AuthState.emailNotVerified(email: email));
      _eventBus.emit(AuthEmailNotVerified(email: email));
      return;
    }

    if (!onboardingCompleted) {
      _log?.info('[AuthCubit] Onboarding not complete');
      _emit(const AuthState.onboardingRequired());
      _eventBus.emit(const AuthOnboardingRequired());
      return;
    }

    _log?.info('[AuthCubit] Auth successful — emitting AuthSuccess');
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
    _log?.info('[AuthCubit] Signup attempt — $email');
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
    _log?.info('[AuthCubit] Verifying OTP for $email');
    _emit(const AuthState.loading());

    final result = await _verifyEmailUseCase(email: email, otp: otp);

    result.when(
      failure: (error, _) {
        _log?.error('[AuthCubit] OTP verification failed — $error');
        _emit(AuthState.error(error));
        _eventBus.emit(AuthFailure(message: error));
      },
      success: (data) async {
        _log?.info('[AuthCubit] OTP verified successfully');
        await _storage.saveEmailVerified(true);
        await _storage.clearPendingVerificationEmail();

        final message =
            data['message'] as String? ?? 'Email verified successfully';
        _emit(AuthState.otpVerified(message: message));
        _eventBus.emit(AuthOtpVerified(message: message));

        _emit(const AuthState.onboardingRequired());
        _eventBus.emit(const AuthOnboardingRequired());
      },
    );
  }

  Future<void> resendOtp({required String email}) async {
    _log?.info('[AuthCubit] Resending OTP — $email');
    _emit(const AuthState.loading());

    final result = await _resendOtpUseCase(email: email);

    result.when(
      failure: (error, _) {
        _log?.error('[AuthCubit] Resend OTP failed — $error');
        _emit(AuthState.error(error));
        _eventBus.emit(AuthFailure(message: error));
      },
      success: (_) {
        _log?.info('[AuthCubit] OTP resent successfully');
        _emit(const AuthState.otpResent());
      },
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
    required String phone,
    File? avatarFile, // renamed for clarity
  }) async {
    _log?.info(
      '[AuthCubit] Starting onboarding with avatar: ${avatarFile != null}',
    );

    // Step 1: Emit uploading state if there's an avatar
    if (avatarFile != null) {
      _emit(
        AuthState.onboardingUploading(
          progress: 0.0,
          message: 'Uploading avatar...',
        ),
      );
    } else {
      _emit(const AuthState.loading());
    }

    String? uploadedAvatarUrl;

    // Step 2: Upload avatar with progress
    if (avatarFile != null) {
      final uploadResult = await AuthMediaService.instance.upload(
        file: avatarFile,
        onProgress: (progress) {
          _emit(
            AuthState.onboardingUploading(
              progress: progress,
              message:
                  'Uploading avatar... ${(progress * 100).toStringAsFixed(0)}%',
            ),
          );
        },
      );

      uploadedAvatarUrl = uploadResult.when(
        success: (media) {
          _log?.info('[AuthCubit] Avatar uploaded → ${media.mediaId}');
          return media.contentUrl;
        },
        failure: (error, _) {
          _log?.error('[AuthCubit] Avatar upload failed: $error');
          // Continue onboarding even if avatar fails (non-blocking)
          return null;
        },
      );
    }

    // Step 3: Complete onboarding
    _emit(const AuthState.loading()); // or keep uploading state if you prefer

    final result = await _completeOnboardingUseCase(
      firstName: firstName,
      lastName: lastName,
      country: country,
      phone: phone,
      avatarUrl: uploadedAvatarUrl,
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

        await _storage.updateSharedAccountHint(
          userId: userId,
          displayName: displayName,
          avatarUrl: uploadedAvatarUrl ?? '',
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
    _log?.info(
      '[AuthCubit] continueAsAccount — ${hint.displayName} (${hint.userId})',
    );
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
    _log?.info('[AuthCubit] Verifying 2FA — userId: $userId');
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

  Future<void> requestResetPassword({required String email}) async {
    _log?.info('[AuthCubit] Forgot password — $email');
    _emit(const AuthState.loading());

    final result = await _requestPasswordResetUseCase(email: email);

    result.when(
      failure: (error, _) {
        _log?.error('[AuthCubit] Forgot password failed — $error');
        _emit(AuthState.error(error));
        _eventBus.emit(AuthFailure(message: error));
      },
      success: (_) {
        _log?.info('[AuthCubit] Password reset email sent');
        _emit(AuthState.passwordResetRequestSent(email: email));
      },
    );
  }

  Future<void> verifyResetPasswordRequest({
    required String email,
    required String otp,
  }) async {
    _log?.info('[AuthCubit] Forgot password — $email');
    _emit(const AuthState.loading());

    final result = await _verifyPasswordResetUseCase(email: email, otp: otp);

    result.when(
      failure: (error, _) {
        _log?.error('[AuthCubit] Forgot password failed — $error');
        _emit(AuthState.error(error));
        _eventBus.emit(AuthFailure(message: error));
      },
      success: (result) {
        _log?.info('[AuthCubit] Password request reset verified');
        _emit(AuthState.passwordResetSent(token: result['resetToken']));
      },
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _log?.info('[AuthCubit] Resetting password');
    _emit(const AuthState.loading());

    final result = await _resetPasswordUseCase(
      token: token,
      newPassword: newPassword,
    );

    result.when(
      failure: (error, _) {
        _log?.error('[AuthCubit] Reset password failed — $error');
        _emit(AuthState.error(error));
        _eventBus.emit(AuthFailure(message: error));
      },
      success: (_) {
        _log?.info('[AuthCubit] Password reset successful');
        _emit(const AuthState.passwordResetSuccess());
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // LOGOUT
  // ══════════════════════════════════════════════════════════════

  /// Logs out the current account in this app.
  /// Removes this account from shared storage — other accounts unaffected.
  Future<void> logout() async {
    _log?.info('[AuthCubit] Logout requested');
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

    _log?.info('[AuthCubit] Logout complete');
    _emit(const AuthState.unauthenticated());
    _eventBus.emit(const AuthLoggedOut());
  }

  /// Logs out ALL known Grascope accounts on this device.
  Future<void> logoutAll() async {
    _log?.info('[AuthCubit] Logging out all accounts');
    _emit(const AuthState.loading());

    final sessionId = await _storage.getSessionId();
    if (sessionId != null) {
      await _logoutUseCase(sessionId: sessionId);
    }

    await _storage.clearLocalSession();
    await _storage.clearAllKnownAccounts();

    _log?.info('[AuthCubit] All accounts logged out');
    _emit(const AuthState.unauthenticated());
    _eventBus.emit(const AuthLoggedOut());
  }

  // ══════════════════════════════════════════════════════════════
  // ACCOUNT SWITCHING (same app, multiple accounts)
  // ══════════════════════════════════════════════════════════════

  /// Switches to a different account that already exists in the known
  /// accounts list for this app — without requiring the user to re-enter
  /// credentials.
  ///
  /// Unlike [continueAsAccount] (used on startup for cross-app SSO),
  /// [switchAccount] is called while a session is already active.
  /// It:
  ///   1. Ends the current session locally (no network call — the old
  ///      session remains valid server-side but the local tokens are replaced).
  ///   2. Exchanges the target account's stored refresh token for a new
  ///      platform-scoped access token.
  ///   3. Saves the new session and emits [AuthSuccess].
  ///
  /// If the target account's refresh token has expired, removes it from
  /// the known list and emits [AuthState.error] so the caller can inform
  /// the user to log in to that account again.
  ///
  /// USAGE (from profile / account switcher screen):
  /// ```dart
  /// final accounts = await MerkadoAuth.instance.getKnownAccounts();
  /// // Show picker, user picks one:
  /// MerkadoAuth.instance.cubit.switchAccount(selectedHint);
  /// ```
  Future<void> switchAccount(GrascopeSessionHint targetHint) async {
    _log?.info(
      '[AuthCubit] switchAccount → ${targetHint.displayName} (${targetHint.userId})',
    );

    final currentUserId = await _storage.getUserId();
    if (currentUserId == targetHint.userId) {
      _log?.debug(
        '[AuthCubit] switchAccount — already active account, ignoring',
      );
      return;
    }

    _emit(const AuthState.loading());
    _eventBus.emit(const AuthLoading());

    // Step 1 — clear current session tokens locally.
    // We keep the current account in knownAccounts so it can be switched back to.
    await _storage.clearLocalSession();
    _log?.debug('[AuthCubit] switchAccount — local session cleared');

    // Step 2 — exchange the target account's refresh token
    final result = await _exchangeRefreshTokenUseCase(
      refreshToken: targetHint.refreshToken,
      platformId: _config.platformId,
      scopes: _scopesForPlatform(_config.platformId),
    );

    result.when(
      failure: (error, _) async {
        _log?.error(
          '[AuthCubit] switchAccount — token exchange failed for ${targetHint.userId}: $error',
        );

        // Token is dead — remove stale account from the list
        await _storage.removeKnownAccount(targetHint.userId);

        _emit(
          AuthState.error(
            'Session for ${targetHint.displayName} has expired. '
            'Please log in to that account again.',
          ),
        );
        _eventBus.emit(
          AuthFailure(
            message: 'Session for ${targetHint.displayName} has expired.',
          ),
        );
      },
      success: (data) async {
        final accessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String?;
        final expiresIn = data['expiresIn'] as int? ?? 900;

        await _storage.saveAccessToken(accessToken, expiresIn: expiresIn);
        await _storage.saveUserId(targetHint.userId);
        await _storage.saveUserEmail(targetHint.email);
        await _storage.saveEmailVerified(true);
        await _storage.saveOnboardingCompleted(true);

        // Update lastUsedAt and refresh token if rotated
        final updatedHint =
            newRefreshToken != null &&
                newRefreshToken != targetHint.refreshToken
            ? targetHint.copyWith(refreshToken: newRefreshToken)
            : targetHint;
        await _storage.upsertKnownAccount(updatedHint);

        _log?.info(
          '[AuthCubit] switchAccount — success for ${targetHint.displayName}',
        );
        _emit(const AuthState.authenticated());
        _eventBus.emit(
          AuthSuccess(accessToken: accessToken, fromCrossAppSso: false),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SESSION EXPIRY (from interceptor)
  // ══════════════════════════════════════════════════════════════

  Future<void> _handleSessionExpired({String? userId}) async {
    _log?.warning('[AuthCubit] Session expired for userId: $userId');
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
    _log?.debug('[AuthCubit] Closing cubit');
    _reLoginSubscription?.cancel();
    return super.close();
  }
}
