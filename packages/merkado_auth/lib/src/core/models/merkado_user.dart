/// MerkadoUser
/// ===========
/// Represents an authenticated user in the Merkado OS ecosystem.
/// Returned inside [AuthSuccess] — the consuming app maps this to its
/// own user model if needed.
class MerkadoUser {
  final String id;
  final String email;
  final String? phone;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final bool emailVerified;
  final bool phoneVerified;
  final bool identityVerified;
  final int trustScore;
  final List<String> roles;

  const MerkadoUser({
    required this.id,
    required this.email,
    this.phone,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.identityVerified = false,
    this.trustScore = 0,
    this.roles = const [],
  });

  /// Full display name.
  String get displayName => '$firstName $lastName'.trim();

  factory MerkadoUser.fromJson(Map<String, dynamic> json) {
    return MerkadoUser(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      identityVerified: json['identityVerified'] as bool? ?? false,
      trustScore: json['trustScore'] as int? ?? 0,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phone': phone,
        'firstName': firstName,
        'lastName': lastName,
        'avatarUrl': avatarUrl,
        'emailVerified': emailVerified,
        'phoneVerified': phoneVerified,
        'identityVerified': identityVerified,
        'trustScore': trustScore,
        'roles': roles,
      };
}