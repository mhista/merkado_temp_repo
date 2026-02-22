/// AuthResult
/// ==========
/// State-management-agnostic events emitted on [AuthEventBus.instance.stream].
///
/// Consuming apps subscribe to this stream regardless of their state management
/// solution and react to these sealed subclasses.
///
/// EXAMPLE:
/// ```dart
/// MerkadoAuth.instance.authStream.listen((result) {
///   switch (result) {
///     case AuthSuccess():          router.go('/home');
///     case AuthLoggedOut():        router.go('/');
///     case AuthExpired():          router.go('/');
///     case AuthOnboardingRequired(): router.go('/onboarding');
///     case AuthFailure(:final message): showSnackBar(message);
///     default: break;
///   }
/// });
/// ```
sealed class AuthResult {
  const AuthResult();
}

/// Emitted while any auth operation is in progress.
class AuthLoading extends AuthResult {
  const AuthLoading();
}

/// Emitted when the user is fully authenticated.
///
/// [accessToken] is the short-lived platform-scoped token for API calls.
/// The consuming app stores this in its own state layer if needed.
/// [fromCrossAppSso] indicates this came from selecting a known account.
class AuthSuccess extends AuthResult {
  final String accessToken;
  final bool fromCrossAppSso;

  const AuthSuccess({
    required this.accessToken,
    this.fromCrossAppSso = false,
  });
}

/// Emitted when signup or login returns [verified: false].
/// Navigate user to OTP verification screen.
class AuthEmailNotVerified extends AuthResult {
  final String email;
  const AuthEmailNotVerified({required this.email});
}

/// Emitted when OTP is verified successfully.
/// Onboarding screen follows — this event is informational.
class AuthOtpVerified extends AuthResult {
  final String message;
  const AuthOtpVerified({required this.message});
}

/// Emitted when email is verified but onboarding is not complete.
/// Navigate user to onboarding flow (firstName, lastName, country, avatar).
class AuthOnboardingRequired extends AuthResult {
  const AuthOnboardingRequired();
}

/// Emitted when backend requires 2FA before granting access.
class AuthMfaRequired extends AuthResult {
  final String userId;
  final String message;
  const AuthMfaRequired({required this.userId, required this.message});
}

/// Emitted on any auth failure.
class AuthFailure extends AuthResult {
  final String message;
  const AuthFailure({required this.message});
}

/// Emitted when a session has expired (refresh token dead).
/// [displayName] enables targeted messaging: "Session expired for Amara."
class AuthExpired extends AuthResult {
  final String? userId;
  final String? displayName;
  const AuthExpired({this.userId, this.displayName});
}

/// Emitted when the user is fully logged out.
class AuthLoggedOut extends AuthResult {
  const AuthLoggedOut();
}

/// Emitted when known Grascope accounts are detected on this device.
/// The package UI shows the account picker automatically.
/// This event lets the consuming app know SSO detection occurred.
class AuthAccountsDetected extends AuthResult {
  final List<dynamic> accounts;
  const AuthAccountsDetected({required this.accounts});
}

/// Emitted when no session and no known accounts exist.
class AuthUnauthenticated extends AuthResult {
  const AuthUnauthenticated();
}