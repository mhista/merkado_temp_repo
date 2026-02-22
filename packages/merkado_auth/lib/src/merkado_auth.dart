import 'package:common_utils2/common_utils2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:merkado_auth/merkado_auth.dart';


import 'features/auth/data/auth_repo_impl/auth_repository_implementation.dart';
import 'features/auth/data/datasource/auth_remote_datasource.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/screens/auth_shell.dart';

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

    _log?.info('[MerkadoAuth] Initializing — platform: ${config.platformName}');

    await AuthSecureStorageService.init(
      enableSharedKeychain: config.enableSharedKeychain,
    );
    _log?.debug('[MerkadoAuth] Storage initialized');

    await _instance!._setupDependencies();
    _log?.debug('[MerkadoAuth] Dependencies registered');

    _instance!._cubit = GetIt.instance<AuthCubit>();
    await _instance!._cubit.init(config);
    _log?.info('[MerkadoAuth] Initialization complete');
  }

  Future<void> _setupDependencies() async {
    final getIt = GetIt.instance;

    if (getIt.isRegistered<AuthCubit>()) {
      _log?.debug('[MerkadoAuth] Already registered — skipping');
      return;
    }

    // ── 1. Data source (no dependencies) ─────────────────────────────────────
    getIt.registerLazySingleton<AuthRemoteDatasource>(
      () => AuthRemoteDatasourceImpl(logger: _log),
    );

    // ── 2. Repository (depends on datasource) ─────────────────────────────────
    // MUST be before use cases — they all inject AuthRepository
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        authRemoteDatasource: getIt<AuthRemoteDatasource>(),
      ),
    );

    // ── 3. Use cases (all depend on AuthRepository) ───────────────────────────
    getIt
      ..registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()))
      ..registerLazySingleton(() => SignUpUseCase(getIt<AuthRepository>()))
      ..registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()))
      ..registerLazySingleton(() => ResendOtpUseCase(getIt<AuthRepository>()))
      ..registerLazySingleton(() => VerifyEmailUseCase(getIt<AuthRepository>()))
      ..registerLazySingleton(() => CompleteOnboardingUseCase(getIt<AuthRepository>()))
      ..registerLazySingleton(() => ForgotPasswordUseCase(getIt<AuthRepository>()))
      ..registerLazySingleton(() => ResetPasswordUseCase(getIt<AuthRepository>()))
      ..registerLazySingleton(() => VerifyTwoFactorUseCase(getIt<AuthRepository>()))
      ..registerLazySingleton(() => ExchangeRefreshTokenUseCase(getIt<AuthRepository>()))
      ..registerLazySingleton(() => SignInWithGoogleUseCase(getIt<AuthRepository>()))
      ..registerLazySingleton(() => SignInWithAppleUseCase(getIt<AuthRepository>()));

    // ── 4. Cubit (top of chain, depends on all use cases) ─────────────────────
    getIt.registerLazySingleton<AuthCubit>(
      () => AuthCubit(
        loginUseCase: getIt(),
        signUpUseCase: getIt(),
        logoutUseCase: getIt(),
        resendOtpUseCase: getIt(),
        verifyEmailUseCase: getIt(),
        completeOnboardingUseCase: getIt(),
        forgotPasswordUseCase: getIt(),
        resetPasswordUseCase: getIt(),
        verifyTwoFactorUseCase: getIt(),
        exchangeRefreshTokenUseCase: getIt(),
        signInWithGoogleUseCase: getIt(),
        signInWithAppleUseCase: getIt(),
        // logger: _log,
      ),
    );
  }

  Stream<AuthResult> get authStream => AuthEventBus.instance.stream;
  AuthResult? get currentAuthResult => AuthEventBus.instance.lastResult;
  MerkadoAuthConfig get config => _config;
  AuthCubit get cubit => _cubit;

  Future<void> pushAuth(BuildContext context) async {
    _log?.info('[MerkadoAuth] Pushing auth shell');
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AuthShell(config: _config, cubit: _cubit),
        fullscreenDialog: true,
      ),
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