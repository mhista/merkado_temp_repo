import 'package:common_utils2/common_utils2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:merkado_auth/merkado_auth.dart';
import 'package:merkado_auth/src/features/auth/data/auth_repo_impl/auth_repository_implementation.dart';
import 'core/interceptors/merkado_auth_interceptor.dart';
import 'features/auth/data/datasource/auth_remote_datasource.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/screens/auth_shell.dart';
import 'google/google_sign_in_config.dart';
import 'google/google_sign_in_service.dart';

class MerkadoAuth {
  MerkadoAuth._();

  static MerkadoAuth? _instance;
  static LoggerService? _log;

  static MerkadoAuth get instance {
    assert(_instance != null, 'MerkadoAuth not initialized.');
    return _instance!;
  }

  late final MerkadoAuthConfig _config;
  late final AuthCubit _cubit;

  static Future<void> initialize({
    required MerkadoAuthConfig config,
    LoggerService? logger,
  }) async {
    _instance = MerkadoAuth._();
    _instance!._config = config;
    _log = logger;
    AuthEventBus.setLogger(logger);
    ReLoginEventBus.setLogger(logger);

    _log?.info('[MerkadoAuth] Initializing — platform: ${config.platformName}');

    await AuthSecureStorageService.init(
      enableSharedKeychain: config.enableSharedKeychain,
      logger: logger,
    );
    _log?.debug('[MerkadoAuth] Storage initialized');

    await _instance!._setupDependencies();
    _log?.debug('[MerkadoAuth] Dependencies registered');

    _instance!._cubit = GetIt.instance<AuthCubit>();
    await _instance!._cubit.init(config);
    _log?.info('[MerkadoAuth] Initialization complete');

    AuthMediaService.init(
      mediaBaseUrl: config.mediaUrl,
      authBaseUrl: config.authUrl,
    );

    if (!HttpClient.isInitialized) {
      HttpClient.init(baseUrl: config.authUrl);
    }

    HttpClient.instance.addInterceptor(
      MerkadoAuthInterceptor(logger: logger, authBaseUrl: config.authUrl, platformId: config.platformId),
    );
  }

  Future<void> _setupDependencies() async {
    final getIt = GetIt.instance;

    if (getIt.isRegistered<AuthCubit>()) {
      _log?.debug('[MerkadoAuth] Already registered — skipping');
      return;
    }

    // ── 1. Data source (no dependencies) ─────────────────────────────────────
    // In your injection_container / module — wherever AuthRemoteDatasourceImpl is registered
    getIt.registerLazySingleton<AuthRemoteDatasource>(
      () => AuthRemoteDatasourceImpl(
        authBaseUrl: _config.authUrl,
        appBaseUrl: _config.baseUrl,
      ),
    );

    // ── 2. Repository (depends on datasource) ─────────────────────────────────
    // MUST be before use cases — they all inject AuthRepository
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        authRemoteDatasource: getIt<AuthRemoteDatasource>(),
        logger: _log,
      ),
    );

    // ── 3. Use cases (all depend on AuthRepository) ───────────────────────────
    getIt
      ..registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()))
      ..registerLazySingleton(() => SignUpUseCase(getIt<AuthRepository>()))
      ..registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()))
      ..registerLazySingleton(() => ResendOtpUseCase(getIt<AuthRepository>()))
      ..registerLazySingleton(() => VerifyEmailUseCase(getIt<AuthRepository>()))
      ..registerLazySingleton(
        () => CompleteOnboardingUseCase(getIt<AuthRepository>()),
      )
      ..registerLazySingleton(
        () => RequestPasswordResetUseCase(getIt<AuthRepository>()),
      )
      ..registerLazySingleton(
        () => VerifyPasswordResetUseCase(getIt<AuthRepository>()),
      )
      ..registerLazySingleton(
        () => ResetPasswordUseCase(getIt<AuthRepository>()),
      )
      ..registerLazySingleton(
        () => VerifyTwoFactorUseCase(getIt<AuthRepository>()),
      )
      ..registerLazySingleton(
        () => ExchangeRefreshTokenUseCase(getIt<AuthRepository>()),
      )
      ..registerLazySingleton(
        () => SignInWithGoogleUseCase(getIt<AuthRepository>()),
      )
      ..registerLazySingleton(
        () => SignInWithAppleUseCase(getIt<AuthRepository>()),
      );

    // getIt.registerSingletonAsync<GoogleSignInService>(() async {
    //   final service = GoogleSignInService();
    //   await service.initialize(GoogleSignInConfig.firebase());
    //   return service;
    // });

    // ── 4. Cubit (top of chain, depends on all use cases) ─────────────────────
    getIt.registerLazySingleton<AuthCubit>(
      () => AuthCubit(
        loginUseCase: getIt(),
        signUpUseCase: getIt(),
        logoutUseCase: getIt(),
        resendOtpUseCase: getIt(),
        verifyEmailUseCase: getIt(),
        completeOnboardingUseCase: getIt(),
        requestPasswordResetUseCase: getIt(),
        verifyPasswordResetUseCase: getIt(),
        resetPasswordUseCase: getIt(),
        verifyTwoFactorUseCase: getIt(),
        exchangeRefreshTokenUseCase: getIt(),
        signInWithGoogleUseCase: getIt(),
        signInWithAppleUseCase: getIt(),
        logger: _log,
      ),
    );
  }

  Stream<AuthResult> get authStream => AuthEventBus.instance.stream;
  AuthResult? get currentAuthResult => AuthEventBus.instance.lastResult;
  MerkadoAuthConfig get config => _config;
  AuthCubit get cubit => _cubit;

  /// Returns all known accounts stored on this device for this app.
  /// Sorted by most recently used first.
  /// Use this to build an in-app account switcher UI.
  ///
  /// EXAMPLE:
  /// ```dart
  /// final accounts = await MerkadoAuth.instance.getKnownAccounts();
  /// // accounts is List<GrascopeSessionHint>
  /// // Show a picker, then call:
  /// MerkadoAuth.instance.cubit.switchAccount(selectedAccount);
  /// ```
  Future<List<GrascopeSessionHint>> getKnownAccounts() {
    return AuthSecureStorageService.instance.getKnownAccounts();
  }

  /// Pushes the auth shell — for login / signup from scratch.
  Future<void> pushAuth(BuildContext context) async {
    _log?.info('[MerkadoAuth] Pushing auth shell');
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AuthShell(config: _config, cubit: _cubit),
        fullscreenDialog: true,
      ),
    );
  }

  /// Pushes a standalone account switcher sheet showing all known accounts
  /// on this device. The user can switch to any account or add a new one.
  ///
  /// Call this from a profile screen, a long-press on the avatar, etc.
  ///
  /// EXAMPLE:
  /// ```dart
  /// ElevatedButton(
  ///   onPressed: () => MerkadoAuth.instance.pushAccountSwitcher(context),
  ///   child: const Text('Switch account'),
  /// )
  /// ```
  Future<void> pushAccountSwitcher(BuildContext context) async {
    _log?.info('[MerkadoAuth] Pushing account switcher');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AccountSwitcherSheet(cubit: _cubit, config: _config),
    );
  }

  void dispose() {
    _log?.info('[MerkadoAuth] Disposing');
    _cubit.close();
    AuthEventBus.instance.dispose();
    ReLoginEventBus.instance.dispose();
    _instance = null;
    _log = null;
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _AccountSwitcherSheet
//
// Internal modal bottom sheet shown by pushAccountSwitcher().
// Lists all known accounts. User can switch or tap "Add account" to trigger
// a fresh login. The consuming app never imports this directly.
// ════════════════════════════════════════════════════════════════════════════
class _AccountSwitcherSheet extends StatefulWidget {
  final AuthCubit cubit;
  final MerkadoAuthConfig config;

  const _AccountSwitcherSheet({required this.cubit, required this.config});

  @override
  State<_AccountSwitcherSheet> createState() => _AccountSwitcherSheetState();
}

class _AccountSwitcherSheetState extends State<_AccountSwitcherSheet> {
  late Future<List<GrascopeSessionHint>> _accountsFuture;

  @override
  void initState() {
    super.initState();
    _accountsFuture = AuthSecureStorageService.instance.getKnownAccounts();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.config.primaryColor ?? Theme.of(context).colorScheme.primary;

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    Text(
                      'Switch account',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Account list
              Expanded(
                child: FutureBuilder<List<GrascopeSessionHint>>(
                  future: _accountsFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final accounts = snapshot.data!;

                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        // Known accounts
                        ...accounts.map(
                          (hint) => _AccountTile(
                            hint: hint,
                            isActive:
                                hint.userId ==
                                AuthSecureStorageService.instance.cachedUserId,
                            primaryColor: color,
                            onTap: () async {
                              Navigator.of(context).pop();
                              widget.cubit.switchAccount(hint);
                            },
                          ),
                        ),

                        const Divider(height: 24),

                        // Add account — triggers fresh login
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.12),
                            child: Icon(Icons.add, color: color),
                          ),
                          title: const Text('Add account'),
                          subtitle: const Text(
                            'Sign in with a different email',
                          ),
                          onTap: () async {
                            Navigator.of(context).pop();
                            // Push auth shell in login-only mode
                            await Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => AuthShell(
                                  config: widget.config,
                                  cubit: widget.cubit,
                                ),
                                fullscreenDialog: true,
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AccountTile extends StatelessWidget {
  final GrascopeSessionHint hint;
  final bool isActive;
  final Color primaryColor;
  final VoidCallback onTap;

  const _AccountTile({
    required this.hint,
    required this.isActive,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: isActive ? null : onTap,
      leading: CircleAvatar(
        backgroundImage: hint.avatarUrl.isNotEmpty
            ? NetworkImage(hint.avatarUrl)
            : null,
        backgroundColor: primaryColor.withValues(alpha: .15),
        child: hint.avatarUrl.isEmpty
            ? Text(
                hint.displayName.isNotEmpty
                    ? hint.displayName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        hint.displayName,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        hint.email,
        style: Theme.of(context).textTheme.bodySmall,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isActive
          ? Icon(Icons.check_circle, color: primaryColor, size: 20)
          : null,
    );
  }
}
