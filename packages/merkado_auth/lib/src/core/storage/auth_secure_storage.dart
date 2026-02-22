import 'dart:convert';
import 'package:common_utils2/common_utils2.dart';
import '../../../merkado_auth.dart';

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
  static Future<void> init({bool enableSharedKeychain = false}) async {
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
        // encryptedSharedPreferences: true,
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
        // encryptedSharedPreferences: true,
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
    final existing = await getKnownAccounts();
    final updated = existing.where((a) => a.userId != userId).toList();
    await _shared.setString(
      AuthStorageKeys.knownAccounts,
      jsonEncode(updated.map((a) => a.toJson()).toList()),
    );
  }

  /// Removes ALL known accounts. Use only for full device logout.
  Future<void> clearAllKnownAccounts() async {
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
    final expiresAt = DateTime.now()
        .add(Duration(seconds: expiresIn))
        .millisecondsSinceEpoch;

    await _local.setString(AuthStorageKeys.accessToken, token);
    await _local.setString(
      AuthStorageKeys.accessTokenExpiresAt,
      expiresAt.toString(),
    );
  }

  Future<String?> getAccessToken() => _local.getString(AuthStorageKeys.accessToken);

  Future<String?> getRefreshToken() => _local.getString(AuthStorageKeys.refreshToken);

  /// True if the stored access token has not yet expired.
  /// Uses a 30-second buffer to prevent sending a token that's about to die.
  Future<bool> isAccessTokenValid() async {
    final raw = await _local.getString(AuthStorageKeys.accessTokenExpiresAt);
    if (raw == null) return false;
    final expiresAt = int.tryParse(raw);
    if (expiresAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch < (expiresAt - 30000);
  }

  // ══════════════════════════════════════════════════════════════
  // SESSION & USER IDENTITY (local scope)
  // ══════════════════════════════════════════════════════════════

  Future<void> saveSessionId(String id) =>
      _local.setString(AuthStorageKeys.sessionId, id);

  Future<String?> getSessionId() => _local.getString(AuthStorageKeys.sessionId);

  Future<void> saveUserId(String id) async {
    await _local.setString(AuthStorageKeys.activeUserId, id);
    // Mirror active user ID to shared scope so other apps know who's active
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
  Future<void> savePendingVerificationEmail(String email) =>
      _local.setString(AuthStorageKeys.pendingVerificationEmail, email);

  Future<String?> getPendingVerificationEmail() =>
      _local.getString(AuthStorageKeys.pendingVerificationEmail);

  Future<void> clearPendingVerificationEmail() =>
      _local.remove(AuthStorageKeys.pendingVerificationEmail);

  Future<void> saveEmailVerified(bool verified) =>
      _local.setBool(AuthStorageKeys.isEmailVerified, verified);

  Future<bool> isEmailVerified() =>
      _local.getBoolOrDefault(AuthStorageKeys.isEmailVerified, false);

  Future<void> saveOnboardingCompleted(bool completed) =>
      _local.setBool(AuthStorageKeys.isOnboardingCompleted, completed);

  Future<bool> isOnboardingCompleted() =>
      _local.getBoolOrDefault(AuthStorageKeys.isOnboardingCompleted, false);

  // ══════════════════════════════════════════════════════════════
  // BIOMETRICS (local scope)
  // ══════════════════════════════════════════════════════════════

  Future<void> setBiometricsEnrolled(bool enrolled, {required String userId}) async {
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
    // Local scope
    await saveAccessToken(accessToken, expiresIn: expiresIn);
    await _local.setString(AuthStorageKeys.refreshToken, refreshToken);
    await saveSessionId(sessionId);
    await saveUserId(userId);
    await _local.setString(AuthStorageKeys.pendingVerificationEmail, email);
    await saveEmailVerified(verified);
    await saveOnboardingCompleted(onboardingCompleted);

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
  Future<void> clearLocalSession() => _local.clear();

  /// Full logout — clears local session AND removes this account from
  /// the shared SSO list. Other accounts in the list are unaffected.
  Future<void> fullLogout(String userId) async {
    await clearLocalSession();
    await removeKnownAccount(userId);
    await _shared.remove(AuthStorageKeys.activeUserId);
  }
}