import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/merkado_wallet_config.dart';
import 'core/events/wallet_event_bus.dart';
import 'core/events/wallet_notification_event.dart';
import 'core/http/wallet_http_client.dart';
import 'core/logging/wallet_logger.dart';
import 'core/preview/wallet_preview_data.dart';
import 'core/preview/wallet_preview_scope.dart';
import 'core/storage/wallet_secure_storage.dart';
import 'features/user/presentation/cubit/user_cubit.dart';
import 'features/user/domain/models/wallet_user.dart';
import 'features/wallet/data/repository/wallet_repository_impl.dart';
import 'features/wallet/presentation/cubit/wallet_cubit.dart';
import 'features/withdrawal/data/repository/withdraw_repository_impl.dart';
import 'features/withdrawal/presentation/cubit/withdrawal_cubit.dart';
import 'features/pin/pin_cubit.dart';
import 'features/pin/pin_service.dart';
import 'features/wallet/presentation/screens/wallet_home_screen.dart';

/// MerkadoWalletScope
/// ==================
/// InheritedWidget that initializes the wallet package inside the widget tree.
///
/// KEY ADVANTAGE OVER merkado_auth:
/// Because initialization happens here (inside the widget tree, after
/// ScreenUtil.init() has been called), all wallet screens can freely use:
///   - flutter_screenutil (16.w, 24.h, 14.sp, etc.)
///   - MediaQuery
///   - Theme.of(context)
///
/// USAGE:
/// ```dart
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return ScreenUtilInit(
///       builder: (context, child) => MerkadoWalletScope(
///         config: MerkadoWalletConfig(
///           platformId: MerkadoPlatform.mycut,
///           baseUrl: 'https://wallet-api.merkado.site',
///           features: WalletFeatures(
///             exploreActions: [
///               WalletExploreAction(
///                 label: 'Create deal',
///                 icon: Icons.handshake_outlined,
///                 onTap: () => context.push('/deals/create'),
///               ),
///             ],
///           ),
///           onNotification: (event) {
///             CommonNotificationService.instance.show(
///               title: event.title,
///               body: event.body,
///               channelId: event.channelId,
///             );
///           },
///         ),
///         child: MaterialApp(...),
///       ),
///     );
///   }
/// }
/// ```
class MerkadoWalletScope extends StatefulWidget {
  final MerkadoWalletConfig config;
  final Widget child;

  const MerkadoWalletScope({
    super.key,
    required this.config,
    required this.child,
  });

  @override
  State<MerkadoWalletScope> createState() => _MerkadoWalletScopeState();

  /// Access MerkadoWallet from anywhere in the tree below this scope.
  static MerkadoWalletController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_WalletInheritedWidget>();
    assert(
      scope != null,
      'MerkadoWalletScope not found. Wrap your app with MerkadoWalletScope.',
    );
    return scope!.controller;
  }
}

class _MerkadoWalletScopeState extends State<MerkadoWalletScope> {
  late MerkadoWalletController _controller;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    // ── Wire logger FIRST so every subsequent call can log ────────────
    WalletLogger.i.configure(
      adapter: widget.config.logger,
      enabled: widget.config.enableLogging,
    );
    WalletLogger.i.info(
      'MerkadoWallet initialising | '
      'platform: ${widget.config.platformId} | '
      'baseUrl: ${widget.config.baseUrl} | '
      'demo: ${widget.config.features.demoMode} | '
      'logging: ${widget.config.enableLogging}',
    );

    WalletUrls.initialize(
      baseUrl: widget.config.baseUrl,
      alternateBaseUrl: widget.config.alternateBaseUrl,
    );

    // Initialize HTTP client
    WalletHttpClient.init(baseUrl: widget.config.baseUrl);

    // Build cubits
    final walletCubit = WalletCubit(repository: WalletRepositoryImpl())
      ..configure(
        currencySymbol: widget.config.currency.symbol,
        onNotification: widget.config.onNotification != null
            ? (e) => widget.config.onNotification!(e)
            : null,
        fundingRedirectUrl: widget.config.features.fundingRedirectUrl,
        demoMode: widget.config.features.demoMode,
      );

    final withdrawalCubit =
        WithdrawalCubit(repository: WithdrawalRepositoryImpl())..configure(
          currencySymbol: widget.config.currency.symbol,
          onNotification: widget.config.onNotification != null
              ? (e) => widget.config.onNotification!(e)
              : null,
        );

    final pinCubit = PinCubit();
    final userCubit = UserCubit();

    _controller = MerkadoWalletController._(
      config: widget.config,
      walletCubit: walletCubit,
      withdrawalCubit: withdrawalCubit,
      pinCubit: pinCubit,
      userCubit: userCubit,
    );

    // If preview mode is on, immediately inject demo data — no API needed
    if (widget.config.features.previewMode) {
      final data = widget.config.previewData ?? WalletPreviewData.defaults();
      WalletLogger.i.info('previewMode active — injecting demo data');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        userCubit.injectPreview(data.user);
        walletCubit.injectPreview(data.wallet);
        withdrawalCubit.injectPreview(
          bankAccounts: data.bankAccounts,
          withdrawalHistory: data.withdrawalHistory,
        );
      });
    }

    // Wire wallet event bus to app's onWalletEvent callback
    if (widget.config.onWalletEvent != null) {
      WalletEventBus.instance.stream.listen(widget.config.onWalletEvent!);
    }
  }

  @override
  void dispose() {
    _controller._dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _WalletInheritedWidget(
      controller: _controller,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _controller.walletCubit),
          BlocProvider.value(value: _controller.withdrawalCubit),
          BlocProvider.value(value: _controller.pinCubit),
        ],
        child: widget.child,
      ),
    );
  }
}

class _WalletInheritedWidget extends InheritedWidget {
  final MerkadoWalletController controller;

  const _WalletInheritedWidget({
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(_WalletInheritedWidget old) => false;
}

/// MerkadoWalletController
/// =======================
/// Public API surface — access via [MerkadoWalletScope.of(context)].
class MerkadoWalletController {
  final MerkadoWalletConfig config;
  final WalletCubit walletCubit;
  final WithdrawalCubit withdrawalCubit;
  final PinCubit pinCubit;
  final UserCubit userCubit;

  MerkadoWalletController._({
    required this.config,
    required this.walletCubit,
    required this.withdrawalCubit,
    required this.pinCubit,
    required this.userCubit,
  });

  // ── Token management ────────────────────────────────────────────────

  /// Call after AuthSuccess from merkado_auth.
  /// Automatically loads the user profile and wallet balance.
  ///
  /// EXAMPLE:
  /// ```dart
  /// MerkadoAuth.instance.authStream.listen((result) {
  ///   if (result is AuthSuccess) {
  ///     MerkadoWalletScope.of(context).setAccessToken(result.accessToken);
  ///     // Wallet and user profile load automatically.
  ///   }
  /// ```   }
  /// });
  /// ```
  void setAccessToken(String token) {
    WalletHttpClient.instance.setToken(token);
    WalletLogger.i.info('access token set');
  }

  /// Set the user profile from your app's auth response.
  /// Call this after a successful login alongside [setAccessToken].
  ///
  /// The package never fetches the user itself — you own the mapping.
  /// ```dart
  /// MerkadoWalletScope.of(context).setUser(
  ///   WalletUser(
  ///     id:            result.user.id,
  ///     firstName:     result.user.firstName,
  ///     lastName:      result.user.lastName,
  ///     email:         result.user.email,
  ///     avatarUrl:     result.user.avatarUrl,
  ///     phone:         result.user.phone,
  ///     emailVerified: result.user.emailVerified,
  ///     phoneVerified: result.user.phoneVerified,
  ///     country:       result.user.country,
  ///   ),
  /// );
  /// ```
  void setUser(WalletUser user) {
    userCubit.setUser(user);
    // Configure the PIN cubit with the user ID (used for PIN hash salt)
    pinCubit.configure(userId: user.id);
  }

  /// Convenience — set token + user + load balance in one call.
  /// ```dart
  /// MerkadoWalletScope.of(context).setSession(
  ///   token: result.accessToken,
  ///   user:  WalletUser(id: ..., firstName: ..., ...),
  /// );
  /// ```
  void setSession({required String token, required WalletUser user}) {
    setAccessToken(token);
    setUser(user);
    walletCubit.loadWallet();
    WalletLogger.i.info('session started — ${user.fullName}');
  }

  /// Call on logout or session clear.
  void clearSession() {
    WalletHttpClient.instance.clearToken();
    userCubit.clearUser();
    WalletEventBus.instance.emit(const WalletSessionCleared());
    WalletLogger.i.info('session cleared');
  }

  // ── Navigation helpers ──────────────────────────────────────────────

  /// Push the full wallet home screen.
  Future<void> pushWallet(BuildContext context) {
    if (config.customScreens?.homeScreenBuilder != null) {
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) =>
              config.customScreens!.homeScreenBuilder!(ctx, walletCubit),
        ),
      );
    }
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: walletCubit),
            BlocProvider.value(value: withdrawalCubit),
          ],
          child: WalletHomeScreen(
            config: config,
            cubit: walletCubit,
            withdrawalCubit: withdrawalCubit,
          ),
        ),
      ),
    );
  }

  // ── Event stream (state-management-agnostic) ────────────────────────

  Stream<WalletEvent> get walletStream => WalletEventBus.instance.stream;
  WalletEvent? get lastEvent => WalletEventBus.instance.lastEvent;

  // ── Convenience ─────────────────────────────────────────────────────

  Future<void> refreshBalance() => walletCubit.loadWallet();

  void _dispose() {
    walletCubit.close();
    withdrawalCubit.close();
    pinCubit.close();
    WalletEventBus.instance.dispose();
  }
}
