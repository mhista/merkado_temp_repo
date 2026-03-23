class GoogleSignInConfig {
  final List<String> scopes;
  final String? serverClientId;
  final String? hostedDomain;
  final bool forceCodeForRefreshToken;

  const GoogleSignInConfig({
    this.scopes = const ['email'],
    this.serverClientId,
    this.hostedDomain,
    this.forceCodeForRefreshToken = false,
  });

  factory GoogleSignInConfig.defaultConfig() => const GoogleSignInConfig();

  factory GoogleSignInConfig.firebase({
    String? serverClientId,
    List<String> additionalScopes = const [],
  }) =>
      GoogleSignInConfig(
        scopes: ['email', ...additionalScopes],
        serverClientId: serverClientId,
        forceCodeForRefreshToken: true,
      );
}