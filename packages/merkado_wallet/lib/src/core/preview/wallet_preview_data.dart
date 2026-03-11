import '../../features/user/domain/models/wallet_user.dart';
import '../../features/wallet/domain/models/wallet.dart';
import '../../features/withdrawal/domain/models/bank_account.dart';
import '../../features/withdrawal/domain/models/withdrawal_record.dart';

/// WalletPreviewData
/// =================
/// Static demo data that populates all wallet screens in preview/edit mode.
///
/// When [WalletFeatures.previewMode] is true, every screen renders
/// immediately using this data — no API calls, no tokens, no waiting.
///
/// HOW TO USE:
/// ```dart
/// WalletFeatures(
///   previewMode: true,
///   previewData: WalletPreviewData.defaults(),  // or build your own
/// )
/// ```
///
/// HOW TO CUSTOMISE — override individual fields without touching the rest:
/// ```dart
/// WalletPreviewData.defaults().copyWith(
///   user: WalletPreviewData.defaultUser.copyWith(
///     firstName: 'Tunde',
///     avatarUrl: 'https://i.pravatar.cc/150?img=12',
///   ),
///   wallet: WalletPreviewData.defaultWallet.copyWith(
///     availableBalance: 0.0,  // test empty balance state
///   ),
/// )
/// ```
class WalletPreviewData {
  final WalletUser user;
  final Wallet wallet;
  final List<BankAccount> bankAccounts;
  final List<WithdrawalRecord> withdrawalHistory;

  const WalletPreviewData({
    required this.user,
    required this.wallet,
    required this.bankAccounts,
    required this.withdrawalHistory,
  });

  // ── Defaults — realistic Nigerian user, active wallet ────────────────

  static WalletUser get defaultUser => const WalletUser(
        id:                  'preview-user-001',
        firstName:           'Chika',
        lastName:            'Okonkwo',
        email:               'chika.okonkwo@example.com',
        emailVerified:       true,
        phone:               '+2348012345678',
        phoneVerified:       true,
        avatarUrl:           'https://i.pravatar.cc/150?img=47',
        onboardingCompleted: true,
        country:             'NG',
      );

  static Wallet get defaultWallet => Wallet(
        id:                  'preview-wallet-001',
        userId:              'preview-user-001',
        currency:            'NGN',
        availableBalance:    125800.00,
        ledgerBalance:       148300.00,
        withdrawableBalance: 110000.00,
        status:              WalletStatus.active,
        createdAt:           DateTime(2025, 1, 1),
        updatedAt:           DateTime.now(),
      );

  static List<BankAccount> get defaultBankAccounts => [
        BankAccount(
          id:              'preview-bank-001',
          userId:          'preview-user-001',
          bankName:        'Guaranty Trust Bank',
          bankCode:        '058',
          accountNumber:   '0123456789',
          accountName:     'CHIKA OKONKWO',
          currency:        'NGN',
          country:         'NG',
          beneficiaryType: 'individual',
          isDefault:       true,
          firstName:       'Chika',
          lastName:        'Okonkwo',
          email:           'chika.okonkwo@example.com',
          phone:           '+2348012345678',
          createdAt:       DateTime(2025, 6, 1),
        ),
        BankAccount(
          id:              'preview-bank-002',
          userId:          'preview-user-001',
          bankName:        'Kuda Bank',
          bankCode:        '090267',
          accountNumber:   '9876543210',
          accountName:     'CHIKA OKONKWO',
          currency:        'NGN',
          country:         'NG',
          beneficiaryType: 'individual',
          isDefault:       false,
          firstName:       'Chika',
          lastName:        'Okonkwo',
          createdAt:       DateTime(2025, 9, 15),
        ),
      ];

  static List<WithdrawalRecord> get defaultWithdrawalHistory => [
        WithdrawalRecord(
          id:             'preview-wd-001',
          walletId:       'preview-wallet-001',
          bankAccountId:  'preview-bank-001',
          amount:         15000.00,
          currency:       'NGN',
          status:         WithdrawalStatus.completed,
          gatewayReference: 'GW-REF-001',
          processedAt:    DateTime.now().subtract(const Duration(days: 2, hours: 3)),
          createdAt:      DateTime.now().subtract(const Duration(days: 2, hours: 4)),
        ),
        WithdrawalRecord(
          id:             'preview-wd-002',
          walletId:       'preview-wallet-001',
          bankAccountId:  'preview-bank-002',
          amount:         8500.00,
          currency:       'NGN',
          status:         WithdrawalStatus.completed,
          gatewayReference: 'GW-REF-002',
          processedAt:    DateTime.now().subtract(const Duration(days: 5, hours: 1)),
          createdAt:      DateTime.now().subtract(const Duration(days: 5, hours: 2)),
        ),
        WithdrawalRecord(
          id:             'preview-wd-003',
          walletId:       'preview-wallet-001',
          bankAccountId:  'preview-bank-001',
          amount:         50000.00,
          currency:       'NGN',
          status:         WithdrawalStatus.processing,
          createdAt:      DateTime.now().subtract(const Duration(hours: 3)),
        ),
        WithdrawalRecord(
          id:             'preview-wd-004',
          walletId:       'preview-wallet-001',
          bankAccountId:  'preview-bank-001',
          amount:         20000.00,
          currency:       'NGN',
          status:         WithdrawalStatus.failed,
          failureReason:  'Insufficient withdrawable balance',
          createdAt:      DateTime.now().subtract(const Duration(days: 10)),
        ),
        WithdrawalRecord(
          id:             'preview-wd-005',
          walletId:       'preview-wallet-001',
          bankAccountId:  'preview-bank-002',
          amount:         5000.00,
          currency:       'NGN',
          status:         WithdrawalStatus.pending,
          createdAt:      DateTime.now().subtract(const Duration(minutes: 20)),
        ),
      ];

  /// Full realistic dataset — use this for normal UI editing.
  factory WalletPreviewData.defaults() => WalletPreviewData(
        user:              defaultUser,
        wallet:            defaultWallet,
        bankAccounts:      defaultBankAccounts,
        withdrawalHistory: defaultWithdrawalHistory,
      );

  /// Zero / empty states — use this to test empty state widgets and skeletons.
  factory WalletPreviewData.empty() => WalletPreviewData(
        user: const WalletUser(
          id:        'preview-empty-user',
          firstName: 'New',
          lastName:  'User',
        ),
        wallet: Wallet(
          id:                  'preview-empty-wallet',
          userId:              'preview-empty-user',
          currency:            'NGN',
          availableBalance:    0.0,
          ledgerBalance:       0.0,
          withdrawableBalance: 0.0,
          status:              WalletStatus.active,
          createdAt:           DateTime.now(),
          updatedAt:           DateTime.now(),
        ),
        bankAccounts:      [],
        withdrawalHistory: [],
      );

  WalletPreviewData copyWith({
    WalletUser? user,
    Wallet? wallet,
    List<BankAccount>? bankAccounts,
    List<WithdrawalRecord>? withdrawalHistory,
  }) =>
      WalletPreviewData(
        user:              user              ?? this.user,
        wallet:            wallet            ?? this.wallet,
        bankAccounts:      bankAccounts      ?? this.bankAccounts,
        withdrawalHistory: withdrawalHistory ?? this.withdrawalHistory,
      );
}