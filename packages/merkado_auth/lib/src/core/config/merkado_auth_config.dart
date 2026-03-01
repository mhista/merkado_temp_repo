import 'package:flutter/widgets.dart';
import 'auth_features.dart';
import 'custom_auth_screens.dart';
import 'merkado_platform.dart';

/// MerkadoAuthConfig
/// =================
/// The single configuration object passed to [MerkadoAuth.initialize()].
///
/// Each consuming app creates one of these and passes its platform-specific
/// values. The package uses this config for every auth operation and UI render.
///
/// EXAMPLE:
/// ```dart
/// await MerkadoAuth.initialize(
///   config: MerkadoAuthConfig(
///     platformId: MerkadoPlatform.mycut,
///     baseUrl: 'https://auth-api.merkado.site',
///     appName: 'MyCut',
///     appLogo: AssetImage('assets/images/logo.png'),
///     termsUrl: 'https://mycut.app/terms',
///     privacyUrl: 'https://mycut.app/privacy',
///     features: AuthFeatures(
///       biometrics: true,
///       twoFactorAuth: true,
///     ),
///   ),
/// );
/// ```
class MerkadoAuthConfig {
  /// The platform UUID for this app. Use [MerkadoPlatform] constants.
  /// Sent with every auth request to scope tokens and track session origin.
  final String platformId;

  /// Base URL of the Merkado Identity Service.
  /// Example: 'https://auth-api.merkado.site'
  final String baseUrl;

  /// Human-readable name of this app. Shown in UI headings and error messages.
  final String appName;

  /// Logo image displayed on login/signup screens.
  /// Accepts any [ImageProvider] — asset, network, memory, etc.
  final String? appLogo;

  /// Height of the logo widget on auth screens. Default: 80.
  final double logoHeight;

  /// URL opened when user taps "Terms of Service".
  /// Opens in an in-package WebView screen if provided.
  final String? termsUrl;

  /// URL opened when user taps "Privacy Policy".
  final String? privacyUrl;

  /// Feature flags — control which screens/flows are active.
  final AuthFeatures features;

  /// Optional custom UI screen builders.
  /// When provided, the package uses your screens instead of its own
  /// but still manages all state, tokens, and navigation internally.
  final CustomAuthScreens? customScreens;

  /// Primary brand color used in package UI (buttons, accents).
  /// Defaults to Merkado OS brand color if null.
  final Color? primaryColor;

  /// Whether to enable verbose package-level logging.
  /// Recommended: true in debug, false in release.
  final bool enableLogging;

  /// Whether cross-app SSO uses the shared keychain group.
  /// Set to true ONLY after all apps share the same Android keystore
  /// and iOS Keychain Sharing is configured in Xcode.
  /// Default: false (safe default — SSO still works via Firebase).
  final bool enableSharedKeychain;

  const MerkadoAuthConfig({
    required this.platformId,
    required this.baseUrl,
    required this.appName,
    this.appLogo,
    this.logoHeight = 80,
    this.termsUrl,
    this.privacyUrl,
    this.features = const AuthFeatures(),
    this.customScreens,
    this.primaryColor,
    this.enableLogging = false,
    this.enableSharedKeychain = false,
  }) : assert(
          platformId.length > 0,
          'platformId must not be empty. Use MerkadoPlatform constants.',
        );

  /// Human-readable name of this platform, derived from [platformId].
  String get platformName => MerkadoPlatform.nameOf(platformId);
}