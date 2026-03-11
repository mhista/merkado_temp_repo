/// WalletNotificationEvent
/// =======================
/// Emitted by the package for every notification-worthy action.
/// Bridge this into your CommonNotificationService, FCM, or any local
/// notification plugin via [MerkadoWalletConfig.onNotification].
///
/// EXAMPLE:
/// ```dart
/// MerkadoWalletConfig(
///   onNotification: (event) {
///     CommonNotificationService.instance.show(
///       title: event.title,
///       body: event.body,
///       channelId: event.channelId,
///     );
///   },
/// )
/// ```
class WalletNotificationEvent {
  final WalletNotificationType type;
  final String title;
  final String body;

  /// Channel ID for routing in your notification plugin.
  /// Values: 'wallet_credit' | 'wallet_debit' | 'wallet_escrow' | 'wallet_system'
  final String channelId;

  /// Deep link route to navigate when user taps the notification.
  /// Example: '/wallet/history'
  final String? deepLinkRoute;

  /// Raw data for any custom handling.
  final Map<String, dynamic>? payload;

  const WalletNotificationEvent({
    required this.type,
    required this.title,
    required this.body,
    required this.channelId,
    this.deepLinkRoute,
    this.payload,
  });

  // ── Factories ──────────────────────────────────────────────────────

  factory WalletNotificationEvent.fundInitiated({
    required double amount,
    required String currency,
  }) {
    return WalletNotificationEvent(
      type: WalletNotificationType.fundInitiated,
      title: 'Complete your payment',
      body: 'Tap to finish funding your wallet with $currency ${amount.toStringAsFixed(0)}',
      channelId: 'wallet_system',
      deepLinkRoute: '/wallet',
    );
  }

  factory WalletNotificationEvent.fundSuccess({
    required double amount,
    required String currencySymbol,
  }) {
    return WalletNotificationEvent(
      type: WalletNotificationType.fundSuccess,
      title: 'Wallet funded!',
      body: '$currencySymbol${amount.toStringAsFixed(2)} has been added to your wallet.',
      channelId: 'wallet_credit',
      deepLinkRoute: '/wallet/history',
      payload: {'amount': amount},
    );
  }

  factory WalletNotificationEvent.withdrawalRequested({
    required double amount,
    required String currencySymbol,
    required String bankName,
  }) {
    return WalletNotificationEvent(
      type: WalletNotificationType.withdrawalRequested,
      title: 'Withdrawal in progress',
      body: '$currencySymbol${amount.toStringAsFixed(2)} is being sent to $bankName.',
      channelId: 'wallet_debit',
      deepLinkRoute: '/wallet/history',
      payload: {'amount': amount, 'bankName': bankName},
    );
  }

  factory WalletNotificationEvent.withdrawalFailed({
    required double amount,
    required String currencySymbol,
    String? reason,
  }) {
    return WalletNotificationEvent(
      type: WalletNotificationType.withdrawalFailed,
      title: 'Withdrawal failed',
      body: reason ?? '$currencySymbol${amount.toStringAsFixed(2)} withdrawal could not be processed.',
      channelId: 'wallet_system',
      deepLinkRoute: '/wallet/history',
    );
  }

  factory WalletNotificationEvent.pinLocked({required DateTime unlocksAt}) {
    final minutes = unlocksAt.difference(DateTime.now()).inMinutes + 1;
    return WalletNotificationEvent(
      type: WalletNotificationType.pinLocked,
      title: 'PIN locked',
      body: 'Too many failed attempts. Try again in $minutes minutes.',
      channelId: 'wallet_system',
    );
  }
}

enum WalletNotificationType {
  fundInitiated,
  fundSuccess,
  withdrawalRequested,
  withdrawalSuccess,
  withdrawalFailed,
  pinLocked,
  sessionExpired,
  bankAccountAdded,
  lowBalance,
}