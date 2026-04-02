/// GrascopeSessionHint
/// ====================
/// Represents a known Grascope account detected in shared secure storage.
/// These are read by any Grascope app on startup to power the
/// cross-app "Continue as [name]" / account picker experience.
///
/// One hint is written per account per device. Multiple accounts
/// (e.g. a personal and a business account) appear as separate hints.
class GrascopeSessionHint {
  /// The Merkado OS user ID for this account.
  final String userId;

  /// Display name shown in the account picker.
  final String displayName;

  /// Avatar URL shown in the account picker (may be empty).
  final String avatarUrl;

  /// Email address of this account.
  final String email;

  /// The refresh token used to exchange for a product-scoped access token.
  /// This is the single token that represents the user's identity —
  /// it is shared across all apps and exchanged per-app for a scoped access token.
  final String refreshToken;

  /// When this account was last actively used (most recently used appears first).
  final DateTime lastUsedAt;

  /// The platform ID of the app where this account was originally created.
  /// Informational — used for logging and analytics.
  final String? sourcePlatformId;

  const GrascopeSessionHint({
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.email,
    required this.refreshToken,
    DateTime? lastUsedAt,
    this.sourcePlatformId,
  }) : lastUsedAt = lastUsedAt ?? const _NowPlaceholder();

  // NOTE: Dart doesn't allow DateTime.now() in const constructors.
  // Use GrascopeSessionHint.create() for non-const construction.
  factory GrascopeSessionHint.create({
    required String userId,
    required String displayName,
    required String avatarUrl,
    required String email,
    required String refreshToken,
    String? sourcePlatformId,
  }) {
    return GrascopeSessionHint(
      userId: userId,
      displayName: displayName,
      avatarUrl: avatarUrl,
      email: email,
      refreshToken: refreshToken,
      lastUsedAt: DateTime.now(),
      sourcePlatformId: sourcePlatformId,
    );
  }

  /// Returns a copy with updated fields. Used when rotating refresh tokens.
GrascopeSessionHint copyWith({
  String? refreshToken,
  DateTime? lastUsedAt,
  String? displayName,
  String? avatarUrl,
  String? sourcePlatformId, // ← ADD THIS
}) {
  return GrascopeSessionHint(
    userId: userId,
    displayName: displayName ?? this.displayName,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    email: email,
    refreshToken: refreshToken ?? this.refreshToken,
    lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    sourcePlatformId: sourcePlatformId ?? this.sourcePlatformId, // ← FIX
  );
}

  factory GrascopeSessionHint.fromJson(Map<String, dynamic> json) {
    return GrascopeSessionHint(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      email: json['email'] as String? ?? '',
      refreshToken: json['refreshToken'] as String,
      lastUsedAt: DateTime.fromMillisecondsSinceEpoch(
        json['lastUsedAt'] as int,
      ),
      sourcePlatformId: json['sourcePlatformId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'email': email,
        'refreshToken': refreshToken,
        'lastUsedAt': lastUsedAt.millisecondsSinceEpoch,
        'sourcePlatformId': sourcePlatformId,
      };
}

/// Internal placeholder to satisfy const constructor requirement.
/// Never actually used — GrascopeSessionHint.create() sets real DateTime.
class _NowPlaceholder implements DateTime {
  const _NowPlaceholder();
  // This class is never instantiated in real usage.
  // All noSuchMethod calls would throw — this is intentional dead code.
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}