/// merkado_wallet
/// ==============
/// Merkado OS wallet package.
///
/// Provides balance management, funding, withdrawals, PIN security,
/// and notification bridging for any Grascope product app.
///
/// QUICK START:
/// ```dart
/// // 1. Wrap your app (inside ScreenUtilInit for proper sizing)
/// MerkadoWalletScope(
///   config: MerkadoWalletConfig(
///     platformId: MerkadoPlatform.mycut,
///     baseUrl: 'https://wallet-api.merkado.site',
///     features: WalletFeatures(
///       exploreActions: [
///         WalletExploreAction(
///           label: 'Create deal',
///           icon: Icons.handshake_outlined,
///           onTap: () => context.push('/deals/create'),
///         ),
///       ],
///     ),
///     onNotification: (event) {
///       CommonNotificationService.instance.show(
///         title: event.title,
///         body: event.body,
///         channelId: event.channelId,
///       );
///     },
///   ),
///   child: MyApp(),
/// )
///
/// // 2. After auth succeeds, set the token
/// MerkadoWalletScope.of(context).setAccessToken(accessToken);
///
/// // 3. Open the wallet screen
/// MerkadoWalletScope.of(context).pushWallet(context);
///
/// // 4. Or subscribe to events (any state management)
/// MerkadoWalletScope.of(context).walletStream.listen((event) {
///   if (event is WalletFunded) showToast('Wallet funded!');
/// });
/// ```
library;

// ── Public scope / entry point ─────────────────────────────────────────
export 'src/merkado_wallet_scope.dart';

// ── Config ─────────────────────────────────────────────────────────────
export 'src/core/config/merkado_wallet_config.dart';
export 'src/core/config/custom_wallet_screens.dart';

// ── Events (state-management-agnostic stream) ──────────────────────────
export 'src/core/events/wallet_event_bus.dart';
export 'src/core/events/wallet_notification_event.dart';

// ── Models ─────────────────────────────────────────────────────────────
export 'src/features/wallet/domain/models/wallet.dart';
export 'src/features/user/domain/models/wallet_user.dart';

export 'src/features/withdrawal/domain/models/bank_account.dart';
export 'src/features/withdrawal/domain/models/withdrawal_record.dart';

// ── Cubits (for custom screens) ────────────────────────────────────────
export 'src/features/wallet/presentation/cubit/wallet_cubit.dart';
export 'src/features/withdrawal/presentation/cubit/withdrawal_cubit.dart';
export 'src/features/pin/pin_cubit.dart';
export 'src/features/user/presentation/cubit/user_cubit.dart';


// ── Screens (individually usable) ─────────────────────────────────────
export 'src/features/wallet/presentation/screens/wallet_home_screen.dart';
export 'src/features/withdrawal/presentation/screens/add_money_screen.dart';
export 'src/features/withdrawal/presentation/screens/withdraw_screen.dart';
export 'src/features/withdrawal/presentation/screens/add_bank_account_screen.dart';
export 'src/features/withdrawal/presentation/screens/withdrawal_history_screen.dart';
export 'src/features/withdrawal/presentation/screens/pin_entry_sheet.dart';
// ── Services (usable independently) ───────────────────────────────────
export 'src/services/banks/nigerian_bank_service.dart';
export 'src/features/pin/pin_service.dart';

// ── Result wrapper ─────────────────────────────────────────────────────
export 'src/core/errors/wallet_result.dart';

// widget temporayr exposure
export 'src/shared/wallet_widgets.dart';
