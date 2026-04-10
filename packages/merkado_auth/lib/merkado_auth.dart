/// merkado_auth
/// ============
/// Shared authentication package for all Grascope/Merkado OS apps.
///
/// USAGE:
/// ```dart
/// // 1. Initialize in main()
/// await MerkadoAuth.initialize(
///   config: MerkadoAuthConfig(
///     platformId: MerkadoPlatform.mycut,
///     baseUrl: 'https://auth-api.merkado.site',
///     appLogo: AssetImage('assets/logo.png'),
///     termsUrl: 'https://mycut.app/terms',
///     privacyUrl: 'https://mycut.app/privacy',
///   ),
/// );
///
/// // 2. Navigate to auth (works with ANY router)
/// MerkadoAuth.instance.pushAuth(context);
///
/// // 3. Listen to auth results (state-management agnostic)
/// MerkadoAuth.instance.authStream.listen((result) {
///   if (result is AuthSuccess) { /* navigate home */ }
/// });
/// ```
library;

// Config & entry point
export 'src/core/config/merkado_auth_config.dart';
export 'src/core/config/merkado_platform.dart';
export 'src/merkado_auth.dart';

// Auth results (state-management agnostic output)
export 'src/core/models/auth_result.dart';
export 'src/core/models/grascope_session_hints.dart';
export 'src/core/models/merkado_user.dart';

// Feature flags
export 'src/core/config/auth_features.dart';

// Custom UI contract (implement this to supply your own screens)
export 'src/core/config/custom_auth_screens.dart';

// Storage (exposed so apps can read auth state — e.g. getUserDisplayName)
export 'src/core/storage/auth_secure_storage.dart';
export 'src/core/storage/auth_storage_keys.dart';

// Events (cross-app session bus)
export 'src/core/events/re_login_event_bus.dart';
export 'src/core/events/auth_event_bus.dart';

// Auth media service
export 'src/service/auth_media_service.dart';

// Google service
export 'src/google/google.dart';

// auth cubit
export 'src/features/auth/presentation/cubit/auth_cubit.dart';