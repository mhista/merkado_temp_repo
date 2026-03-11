/// WalletUser
/// ==========
/// The user profile as the wallet package needs it.
///
/// DESIGN PHILOSOPHY — COMPOSABILITY OVER COUPLING:
///   This model does NOT parse your backend JSON directly.
///   Instead, the consuming app constructs a WalletUser from whatever
///   auth response shape it has, using the named constructor or factory.
///
///   This means if your user schema adds fields, renames fields, or
///   wraps responses differently, you update ONE mapping in your app —
///   never this package.
///
/// USAGE — in your app, after auth succeeds:
/// ```dart
///   // Map your auth response to WalletUser however you need:
///   final user = WalletUser(
///     id:          authUser.id,
///     firstName:   authUser.firstName,
///     lastName:    authUser.lastName,
///     email:       authUser.email,
///     avatarUrl:   authUser.avatarUrl,
///     phone:       authUser.phone,
///   );
///
///   // Then pass it to the wallet scope:
///   MerkadoWalletScope.of(context).setUser(user);
/// ```
///
/// If your auth model already has a toWalletUser() method, even cleaner:
/// ```dart
///   MerkadoWalletScope.of(context).setUser(authUser.toWalletUser());
/// ```
///
/// FIELD GUIDE:
///   Only fields the wallet package actually uses are declared here.
///   Do not add domain fields (e.g. kycTier, trustScore) unless a
///   wallet screen actually renders them.
class WalletUser {
  /// User's unique ID — used as PIN hash salt and for logging.
  final String id;

  /// Given name — shown in wallet greeting: "Hi, John 👋"
  final String firstName;

  /// Family name — used in full name display.
  final String lastName;

  /// Avatar image URL — shown in wallet home header.
  /// Null falls back to [initials] avatar placeholder.
  final String? avatarUrl;

  /// Email address — shown in account details section.
  final String? email;

  /// Whether email has been verified — used to gate certain actions.
  final bool emailVerified;

  /// Phone number in E.164 format — shown in account details.
  final String? phone;

  /// Whether phone has been verified.
  final bool phoneVerified;

  /// Whether the user has completed onboarding.
  final bool onboardingCompleted;

  /// ISO 3166-1 alpha-2 country code (e.g. "NG", "PH", "GB").
  /// Used to pre-select currency and bank form in withdrawal flows.
  final String? country;

  /// Any extra fields your app wants to carry through without the
  /// package caring about their shape. Add them here — the package
  /// never reads [extras], it just preserves them across copyWith calls.
  final Map<String, dynamic> extras;

  const WalletUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.email,
    this.emailVerified    = false,
    this.phone,
    this.phoneVerified    = false,
    this.onboardingCompleted = false,
    this.country,
    this.extras           = const {},
  });

  // ── Computed helpers used by wallet screens ──────────────────────────

  /// "John Doe" — used where full name is needed.
  String get fullName => '$firstName $lastName'.trim();

  /// "John" — used in greeting. Falls back to fullName if firstName empty.
  String get displayName => firstName.isNotEmpty ? firstName : fullName;

  /// "JD" — shown in avatar placeholder when [avatarUrl] is null or fails.
  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty  ? lastName[0].toUpperCase()  : '';
    return '$f$l'.isEmpty ? '?' : '$f$l';
  }

  // ── copyWith ─────────────────────────────────────────────────────────

  WalletUser copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? email,
    bool?   emailVerified,
    String? phone,
    bool?   phoneVerified,
    bool?   onboardingCompleted,
    String? country,
    Map<String, dynamic>? extras,
  }) =>
      WalletUser(
        id:                   id                   ?? this.id,
        firstName:            firstName            ?? this.firstName,
        lastName:             lastName             ?? this.lastName,
        avatarUrl:            avatarUrl            ?? this.avatarUrl,
        email:                email                ?? this.email,
        emailVerified:        emailVerified        ?? this.emailVerified,
        phone:                phone                ?? this.phone,
        phoneVerified:        phoneVerified        ?? this.phoneVerified,
        onboardingCompleted:  onboardingCompleted  ?? this.onboardingCompleted,
        country:              country              ?? this.country,
        extras:               extras               ?? this.extras,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is WalletUser && id == other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WalletUser($id, $fullName)';
}