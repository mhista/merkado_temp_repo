import 'dart:convert';
import 'package:common_utils2/common_utils2.dart';
import 'package:merkado_auth/merkado_auth.dart';
import 'auth_storage_keys.dart';

/// AuthSecureStorageService
/// ========================
/// The merkado_auth package's storage layer. Delegates all raw read/write
/// operations to [SecureStorageService] from common_utils — there is only
/// one secure storage implementation in the Grascope ecosystem.
///
/// This class adds auth-specific logic on top:
///   - TWO logical storage scopes (shared cross-app vs. local per-app)
///   - Token expiry tracking
///   - Multi-account SSO list management
///   - Interrupted flow resumption state
///
/// IMPORTANT — TWO SCOPE MODEL:
///
/// SHARED scope — written with keys from the shared keychain group config.
/// All Grascope apps read this to detect each other's sessions.
/// Contains: known accounts list, active user ID.
///
/// LOCAL scope — written with standard (non-shared) config.
/// Private to this app only.
/// Contains: access token, refresh token, session ID, flow flags.
///
/// Both scopes use the same [SecureStorageService] instance but are
/// distinguished by which [AuthStorageKeys] constants are used with which
/// storage instance. The two FlutterSecureStorage instances are configured
/// with different options at init time.
class AuthSecureStorageService {
  AuthSecureStorageService._();

  static AuthSecureStorageService? _instance;
  static LoggerService? _log;

  static AuthSecureStorageService get instance {
    assert(
      _instance != null,
      'AuthSecureStorageService not initialized. '
      'Call AuthSecureStorageService.init() via MerkadoAuth.initialize().',
    );
    return _instance!;
  }

  /// The shared-scope storage instance (cross-app SSO data).
  late final SecureStorageService _shared;

  /// The local-scope storage instance (per-app private data).
  late final SecureStorageService _local;

  /// Initialize with two scoped [SecureStorageService] instances.
  ///
  /// [enableSharedKeychain] — set true once all Grascope apps share the same
  /// iOS keychain group (com.grascope.sharedauth) AND Android signing keystore.
  /// Safe to leave false — SSO still works via token exchange; the shared
  /// account list just won't persist across apps until this is enabled.
  static Future<void> init({bool enableSharedKeychain = false, LoggerService? logger}) async {
    _log = logger;
    _log?.info('[AuthStorage] Initializing (sharedKeychain=$enableSharedKeychain)');
    _instance = AuthSecureStorageService._();

    // Shared scope — cross-app account list lives here
    _instance!._shared = SecureStorageService.withOptions(
      iOSOptions: enableSharedKeychain
          ? const IOSOptions(
              // This is a keychain ACCESS GROUP, not your bundle ID.
              // Your bundle ID stays com.grascope.mycut (or whichever app).
              // This group is declared in Xcode under:
              // Signing & Capabilities → Keychain Sharing → com.grascope.sharedauth
              // Apple prefixes it with your Team ID internally.
              groupId: 'com.grascope.sharedauth',
              accountName: 'grascope_session',
              accessibility: KeychainAccessibility.first_unlock,
            )
          : const IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
      androidOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        sharedPreferencesName: enableSharedKeychain
            ? 'grascope_shared_secure'    // same name across ALL Grascope apps
            : 'grascope_shared_local',
        preferencesKeyPrefix: 'grascope_',
      ),
    );

    // Local scope — only this app reads this
    _instance!._local = SecureStorageService.withOptions(
      iOSOptions: const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
      androidOptions: const AndroidOptions(
        encryptedSharedPreferences: true,
        // Unique per-app name — no prefix needed since it's not shared
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // MULTI-ACCOUNT SSO (shared scope)
  // ══════════════════════════════════════════════════════════════

  /// Returns all known Grascope accounts on this device.
  /// Sorted by most recently used first.
  /// Returns an empty list if none found or on parse error.
  Future<List<GrascopeSessionHint>> getKnownAccounts() async {
    _log?.debug('[AuthStorage] getKnownAccounts');
    try {
      final raw = await _shared.getString(AuthStorageKeys.knownAccounts);
      if (raw == null || raw.isEmpty) return [];

      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => GrascopeSessionHint.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
    } catch (_) {
      return [];
    }
  }

  /// Adds or updates a known account entry.
  /// Matches on [GrascopeSessionHint.userId] — updates in place if found.
  /// Always call after a successful login or refresh token rotation.
  Future<void> upsertKnownAccount(GrascopeSessionHint account) async {
    _log?.debug('[AuthStorage] upsertKnownAccount — ${account.userId} (${account.displayName})');
    final existing = await getKnownAccounts();
    final updated = [
      ...existing.where((a) => a.userId != account.userId),
      account.copyWith(lastUsedAt: DateTime.now()),
    ];
    await _shared.setString(
      AuthStorageKeys.knownAccounts,
      jsonEncode(updated.map((a) => a.toJson()).toList()),
    );
  }

  /// Removes one account from the known list.
  /// Call on single-account logout. Does not affect other accounts.
  Future<void> removeKnownAccount(String userId) async {
    _log?.debug('[AuthStorage] removeKnownAccount — $userId');
    final existing = await getKnownAccounts();
    final updated = existing.where((a) => a.userId != userId).toList();
    await _shared.setString(
      AuthStorageKeys.knownAccounts,
      jsonEncode(updated.map((a) => a.toJson()).toList()),
    );
  }

  /// Removes ALL known accounts. Use only for full device logout.
  Future<void> clearAllKnownAccounts() async {
    _log?.debug('[AuthStorage] clearAllKnownAccounts');
    await _shared.remove(AuthStorageKeys.knownAccounts);
    await _shared.remove(AuthStorageKeys.activeUserId);
  }

  // ══════════════════════════════════════════════════════════════
  // ACCESS TOKEN (local scope)
  // ══════════════════════════════════════════════════════════════

  /// Save the access token and its expiry.
  /// [expiresIn] is seconds from now (typically 900 = 15 min).
  /// Storing the timestamp avoids JWT decoding on every startup.
  Future<void> saveAccessToken(String token, {required int expiresIn}) async {
    _log?.debug('[AuthStorage] saveAccessToken — expiresIn: ${expiresIn}s');
    final expiresAt = DateTime.now()
        .add(Duration(seconds: expiresIn))
        .millisecondsSinceEpoch;

    await _local.setString(AuthStorageKeys.accessToken, token);
    await _local.setString(
      AuthStorageKeys.accessTokenExpiresAt,
      expiresAt.toString(),
    );
    _log?.debug('[AuthStorage] Access token saved (expiresIn: ${expiresIn}s)');
  }

  Future<String?> getAccessToken() => _local.getString(AuthStorageKeys.accessToken);

  Future<String?> getRefreshToken() => _local.getString(AuthStorageKeys.refreshToken);

  /// True if the stored access token has not yet expired.
  /// Uses a 30-second buffer to prevent sending a token that's about to die.
  Future<bool> isAccessTokenValid() async {
    final raw = await _local.getString(AuthStorageKeys.accessTokenExpiresAt);
    if (raw == null) {
      _log?.debug('[AuthStorage] isAccessTokenValid: no expiry stored → false');
      return false;
    }
    final expiresAt = int.tryParse(raw);
    if (expiresAt == null) {
      _log?.debug('[AuthStorage] isAccessTokenValid: corrupt expiry → false');
      return false;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final valid = now < (expiresAt - 30000);
    final remaining = Duration(milliseconds: expiresAt - now);
    _log?.debug('[AuthStorage] isAccessTokenValid: $valid (${remaining.inSeconds}s remaining)');
    return valid;
  }

  // ══════════════════════════════════════════════════════════════
  // SESSION & USER IDENTITY (local scope)
  // ══════════════════════════════════════════════════════════════

  Future<void> saveSessionId(String id) =>
      _local.setString(AuthStorageKeys.sessionId, id);

  Future<String?> getSessionId() => _local.getString(AuthStorageKeys.sessionId);

  Future<void> saveUserId(String id) async {
    _log?.debug('[AuthStorage] saveUserId: $id');
    await _local.setString(AuthStorageKeys.activeUserId, id);
    await _shared.setString(AuthStorageKeys.activeUserId, id);
  }

  Future<String?> getUserId() => _local.getString(AuthStorageKeys.activeUserId);

  Future<void> saveUserEmail(String email) =>
      _local.setString(AuthStorageKeys.pendingVerificationEmail, email);

  Future<String?> getUserEmail() =>
      _local.getString(AuthStorageKeys.pendingVerificationEmail);

  Future<String?> getUserDisplayName() =>
      _local.getString(StorageKeys.userDisplayName);

  Future<String?> getUserAvatarUrl() =>
      _local.getString(StorageKeys.userAvatarUrl);

  // ══════════════════════════════════════════════════════════════
  // INTERRUPTED FLOW RESUMPTION (local scope)
  // ══════════════════════════════════════════════════════════════

  /// Save the email pending OTP verification.
  /// Allows OTP screen to be resumed with pre-filled email after app kill.
  Future<void> savePendingVerificationEmail(String email) async {
    _log?.debug('[AuthStorage] savePendingVerificationEmail: $email');
    await _local.setString(AuthStorageKeys.pendingVerificationEmail, email);
  }

  Future<String?> getPendingVerificationEmail() =>
      _local.getString(AuthStorageKeys.pendingVerificationEmail);

  Future<void> clearPendingVerificationEmail() async {
    _log?.debug('[AuthStorage] clearPendingVerificationEmail');
    await _local.remove(AuthStorageKeys.pendingVerificationEmail);
  }

  Future<void> saveEmailVerified(bool verified) async {
    _log?.debug('[AuthStorage] saveEmailVerified: $verified');
    await _local.setBool(AuthStorageKeys.isEmailVerified, verified);
  }

  Future<bool> isEmailVerified() async {
    final v = await _local.getBoolOrDefault(AuthStorageKeys.isEmailVerified, false);
    _log?.debug('[AuthStorage] isEmailVerified: $v');
    return v;
  }

  Future<void> saveOnboardingCompleted(bool completed) async {
    _log?.debug('[AuthStorage] saveOnboardingCompleted: $completed');
    await _local.setBool(AuthStorageKeys.isOnboardingCompleted, completed);
  }

  Future<bool> isOnboardingCompleted() async {
    final v = await _local.getBoolOrDefault(AuthStorageKeys.isOnboardingCompleted, false);
    _log?.debug('[AuthStorage] isOnboardingCompleted: $v');
    return v;
  }

  // ══════════════════════════════════════════════════════════════
  // FLOW TIMEOUT (local scope)
  // ══════════════════════════════════════════════════════════════

  /// Save the timestamp when OTP verification started.
  /// Called in [saveInitialSession] automatically after signup/login that
  /// returns verified=false. Used by startup check to enforce timeout.
  Future<void> saveOtpStartedAt() async {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    await _local.setString(AuthStorageKeys.otpStartedAt, now);
    _log?.debug('[AuthStorage] OTP started at: $now');
  }

  Future<void> saveOnboardingStartedAt() async {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    await _local.setString(AuthStorageKeys.onboardingStartedAt, now);
    _log?.debug('[AuthStorage] Onboarding started at: $now');
  }

  Future<int?> getOtpStartedAt() async {
    final raw = await _local.getString(AuthStorageKeys.otpStartedAt);
    final val = raw != null ? int.tryParse(raw) : null;
    _log?.debug('[AuthStorage] getOtpStartedAt: ${val != null ? DateTime.fromMillisecondsSinceEpoch(val).toIso8601String() : "null"}');
    return val;
  }

  Future<int?> getOnboardingStartedAt() async {
    final raw = await _local.getString(AuthStorageKeys.onboardingStartedAt);
    final val = raw != null ? int.tryParse(raw) : null;
    _log?.debug('[AuthStorage] getOnboardingStartedAt: ${val != null ? DateTime.fromMillisecondsSinceEpoch(val).toIso8601String() : "null"}');
    return val;
  }

  Future<void> clearOtpStartedAt() =>
      _local.remove(AuthStorageKeys.otpStartedAt);

  Future<void> clearOnboardingStartedAt() =>
      _local.remove(AuthStorageKeys.onboardingStartedAt);

  /// Returns true if the OTP verification window has expired.
  /// [timeout] defaults to 15 minutes — matching the access token lifetime.
  ///
  /// If expired: caller should clear the unverified session and route to login.
  /// If not expired: caller should resume the OTP screen as normal.
  Future<bool> isOtpWindowExpired({Duration timeout = const Duration(minutes: 15)}) async {
    final startedAt = await getOtpStartedAt();
    if (startedAt == null) {
      // No timestamp saved — treat as expired (safe default)
      _log?.debug('[AuthStorage] isOtpWindowExpired: no timestamp → treating as expired');
      return true;
    }
    final elapsed = DateTime.now().millisecondsSinceEpoch - startedAt;
    final expired = elapsed > timeout.inMilliseconds;
    _log?.debug('[AuthStorage] isOtpWindowExpired: $expired (elapsed: ${elapsed ~/ 1000}s, timeout: ${timeout.inSeconds}s)');
    return expired;
  }

  /// Returns true if the onboarding window has expired.
  /// [timeout] defaults to 30 minutes — onboarding takes longer than OTP.
  Future<bool> isOnboardingWindowExpired({Duration timeout = const Duration(minutes: 30)}) async {
    final startedAt = await getOnboardingStartedAt();
    if (startedAt == null) {
      _log?.debug('[AuthStorage] isOnboardingWindowExpired: no timestamp → treating as expired');
      return true;
    }
    final elapsed = DateTime.now().millisecondsSinceEpoch - startedAt;
    final expired = elapsed > timeout.inMilliseconds;
    _log?.debug('[AuthStorage] isOnboardingWindowExpired: $expired (elapsed: ${elapsed ~/ 1000}s)');
    return expired;
  }

  // ══════════════════════════════════════════════════════════════
  // BIOMETRICS (local scope)
  // ══════════════════════════════════════════════════════════════

  Future<void> setBiometricsEnrolled(bool enrolled, {required String userId}) async {
    _log?.debug('[AuthStorage] setBiometricsEnrolled: $enrolled — userId: $userId');
    await _local.setBool(AuthStorageKeys.biometricsEnrolled, enrolled);
    if (enrolled) {
      await _local.setString(AuthStorageKeys.biometricUserId, userId);
    }
  }

  Future<bool> isBiometricsEnrolled() =>
      _local.getBoolOrDefault(AuthStorageKeys.biometricsEnrolled, false);

  Future<String?> getBiometricUserId() =>
      _local.getString(AuthStorageKeys.biometricUserId);

  // ══════════════════════════════════════════════════════════════
  // SESSION LIFECYCLE
  // ══════════════════════════════════════════════════════════════

  /// Full session write — called immediately after any auth response
  /// that returns tokens (signup, login, social login, token exchange).
  ///
  /// Saves all tokens and flow state flags to local scope, and writes
  /// the account hint to shared scope for cross-app SSO detection.
  ///
  /// displayName and avatarUrl will be empty strings before onboarding
  /// completes — call [updateSharedAccountHint] after /onboarding/complete
  /// to fill them in so the account picker shows the real name.
  Future<void> saveInitialSession({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required String sessionId,
    required String userId,
    required String email,
    required bool verified,
    required bool onboardingCompleted,
    required String platformId,
    String displayName = '',
    String avatarUrl = '',
  }) async {
    _log?.info('[AuthStorage] saveInitialSession — userId: $userId, verified: $verified, onboardingCompleted: $onboardingCompleted');
    // Local scope
    await saveAccessToken(accessToken, expiresIn: expiresIn);
    await _local.setString(AuthStorageKeys.refreshToken, refreshToken);
    await saveSessionId(sessionId);
    await saveUserId(userId);
    await _local.setString(AuthStorageKeys.pendingVerificationEmail, email);
    await saveEmailVerified(verified);
    await saveOnboardingCompleted(onboardingCompleted);

    // Save flow start timestamps for timeout enforcement.
    // These gate how long the user can leave and return to mid-flow screens.
    if (!verified) {
      await saveOtpStartedAt();
      _log?.debug('[AuthStorage] OTP timeout window started');
    } else if (!onboardingCompleted) {
      await saveOnboardingStartedAt();
      _log?.debug('[AuthStorage] Onboarding timeout window started');
    }

    // Shared scope — SSO hint
    // Use email as display name placeholder until onboarding provides the real name
    await upsertKnownAccount(GrascopeSessionHint.create(
      userId: userId,
      displayName: displayName.isNotEmpty ? displayName : email,
      avatarUrl: avatarUrl,
      email: email,
      refreshToken: refreshToken,
      sourcePlatformId: platformId,
    ));
  }

  /// Update the shared SSO hint after onboarding completes.
  ///
  /// Before this is called, the account picker shows the user's email.
  /// After this, it shows "Continue as Amara Okafor" with their avatar.
  /// Also writes display name and avatar to common_utils StorageKeys so
  /// the consuming app can read them without going through merkado_auth.
  Future<void> updateSharedAccountHint({
    required String userId,
    required String displayName,
    required String avatarUrl,
    required String refreshToken,
  }) async {
    _log?.info('[AuthStorage] updateSharedAccountHint — $userId ($displayName)');
    // Update the SSO account list entry
    final existing = await getKnownAccounts();
    final hint = existing.where((a) => a.userId == userId).firstOrNull;
    if (hint != null) {
      await upsertKnownAccount(hint.copyWith(
        displayName: displayName,
        avatarUrl: avatarUrl,
        refreshToken: refreshToken,
      ));
    }

    // Write to common_utils StorageKeys so the consuming app can read
    // user identity without coupling to merkado_auth internals
    await _local.setString(StorageKeys.userDisplayName, displayName);
    await _local.setString(StorageKeys.userAvatarUrl, avatarUrl);
    await saveOnboardingCompleted(true);
  }

  /// Clears only local session data. Shared SSO hint is preserved so other
  /// Grascope apps (and future relaunches of this app) can still detect
  /// and offer "Continue as [name]" without the user re-entering credentials.
  Future<void> clearLocalSession() async {
    _log?.info('[AuthStorage] Clearing local session');
    await _local.clear();
  }

  /// Full logout — clears local session AND removes this account from
  /// the shared SSO list. Other accounts in the list are unaffected.
  Future<void> fullLogout(String userId) async {
    _log?.info('[AuthStorage] Full logout — userId: $userId');
    await clearLocalSession();
    await removeKnownAccount(userId);
    await _shared.remove(AuthStorageKeys.activeUserId);
    _log?.info('[AuthStorage] Full logout complete');
  }
}