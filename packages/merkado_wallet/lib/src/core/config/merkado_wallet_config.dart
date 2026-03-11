import 'package:flutter/material.dart';
import '../logging/wallet_logger.dart';
import '../preview/wallet_preview_data.dart';
import 'custom_wallet_screens.dart';

/// Feature flags — every capability is individually toggleable.
class WalletFeatures {
  final bool addMoney;
  final bool demoMode;
  final bool withdraw;
  final bool withdrawalHistory;
  final bool recentActivityPreview;
  final int  recentActivityCount;
  final bool balanceVisibilityToggle;
  final bool pinLock;
  final bool biometricUnlock;
  final String? fundingRedirectUrl;
  final List<WalletExploreAction> exploreActions;
  final List<String> supportedWithdrawalCurrencies;

  /// When true, all wallet screens render immediately using [previewData]
  /// with no API calls and no access token required.
  /// Use this during UI development so you can edit widgets freely.
  /// A visible orange banner is shown on every screen as a reminder.
  final bool previewMode;

  const WalletFeatures({
    this.addMoney                    = true,
    this.demoMode                    = false,
    this.withdraw                    = true,
    this.withdrawalHistory           = true,
    this.recentActivityPreview       = true,
    this.recentActivityCount         = 5,
    this.balanceVisibilityToggle     = true,
    this.pinLock                     = true,
    this.biometricUnlock             = false,
    this.fundingRedirectUrl,
    this.exploreActions              = const [],
    this.supportedWithdrawalCurrencies = const ['NGN'],
    this.previewMode                 = false,
  });
}

/// A single pill button in the "Explore Deals" section.
/// Pass an empty list (or omit) to hide the section entirely.
class WalletExploreAction {
  final String    label;
  final IconData  icon;
  final VoidCallback onTap;
  final int?      badge;

  const WalletExploreAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.badge,
  });
}

/// MerkadoWalletConfig
/// ===================
/// The single object passed to [MerkadoWalletScope] to configure the
/// entire wallet package.
///
/// ────────────────────────────────────────────────────────────────────
/// LOGGING
/// ────────────────────────────────────────────────────────────────────
/// The package uses your existing [LoggerService] — Talker is never
/// initialised twice. Wrap your instance in [LoggerServiceAdapter] and
/// pass it here:
///
/// ```dart
/// import 'package:your_app/core/logger/logger_service.dart';
/// import 'package:your_app/core/logger/logger_service_adapter.dart';
///
/// MerkadoWalletConfig(
///   logger: LoggerServiceAdapter(LoggerService.instance),
///   enableLogging: true,          // false in production if preferred
///   ...
/// )
/// ```
///
/// What gets logged:
///   • Every HTTP request  → LoggerService.logHttpRequest(...)
///   • Every HTTP response → LoggerService.logHttpResponse(...)
///   • Every HTTP error    → LoggerService.logHttpError(...)
///   • Cubit state changes → LoggerService.logAction(...)
///   • Wallet events       → LoggerService.logAction(...)
///   • PIN actions         → LoggerService.logAction(...)  (NO pin values)
///   • Initialisation      → LoggerService.info(...)
///
/// Set [enableLogging] = false to silence all wallet logs in production
/// without removing the adapter.
class MerkadoWalletConfig {
  final String platformId;
  final String baseUrl;
  final Color? primaryColor;
  final WalletFeatures features;
  final CustomWalletScreens? customScreens;
  final void Function(dynamic event)? onNotification;
  final void Function(dynamic event)? onWalletEvent;
  final WalletCurrencyConfig currency;

  /// Set true to emit wallet logs into your Talker history.
  /// Defaults to false so production builds stay quiet.
  final bool enableLogging;

  /// Your [LoggerService] wrapped in [LoggerServiceAdapter].
  /// Pass null to disable all logging regardless of [enableLogging].
  final WalletLoggerAdapter? logger;

  /// Demo data used when [WalletFeatures.previewMode] is true.
  /// Defaults to [WalletPreviewData.defaults()] if not provided.
  final WalletPreviewData? previewData;

  const MerkadoWalletConfig({
    required this.platformId,
    required this.baseUrl,
    this.primaryColor,
    this.features      = const WalletFeatures(),
    this.customScreens,
    this.onNotification,
    this.onWalletEvent,
    this.currency      = const WalletCurrencyConfig(),
    this.enableLogging = false,
    this.logger,
    this.previewData,
  });

  Color get effectivePrimary => primaryColor ?? const Color(0xFF1A3C34);
}

/// Currency display configuration.
class WalletCurrencyConfig {
  final String code;
  final String symbol;
  final String locale;

  const WalletCurrencyConfig({
    this.code   = 'NGN',
    this.symbol = '₦',
    this.locale = 'en_NG',
  });
}