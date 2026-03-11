import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'wallet_preview_data.dart';
import '../../features/user/presentation/cubit/user_cubit.dart';
import '../../features/user/domain/models/wallet_user.dart';
import '../../features/wallet/presentation/cubit/wallet_cubit.dart';
import '../../features/wallet/domain/models/wallet.dart';
import '../../features/withdrawal/presentation/cubit/withdrawal_cubit.dart';
import '../../features/withdrawal/domain/models/bank_account.dart';
import '../../features/withdrawal/domain/models/withdrawal_record.dart';

/// WalletPreviewScope
/// ==================
/// When [WalletFeatures.previewMode] is true, this widget wraps every
/// wallet screen and immediately injects demo data into all cubits.
///
/// No API calls are made. No access token is needed. The screens render
/// fully hydrated so you can inspect and edit the UI without having to
/// go through auth or wait for real data.
///
/// A visible orange banner is shown at the top of every screen so you
/// always know you're in preview mode.
///
/// USAGE — this is set up automatically by [MerkadoWalletScope] when
/// [WalletFeatures.previewMode] is true. You don't use it directly.
class WalletPreviewScope extends StatefulWidget {
  final WalletPreviewData data;
  final UserCubit userCubit;
  final WalletCubit walletCubit;
  final WithdrawalCubit withdrawalCubit;
  final Widget child;

  const WalletPreviewScope({
    super.key,
    required this.data,
    required this.userCubit,
    required this.walletCubit,
    required this.withdrawalCubit,
    required this.child,
  });

  @override
  State<WalletPreviewScope> createState() => _WalletPreviewScopeState();
}

class _WalletPreviewScopeState extends State<WalletPreviewScope> {
  @override
  void initState() {
    super.initState();
    // Inject demo data into all cubits immediately — no API calls
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _injectPreviewData();
    });
  }

  void _injectPreviewData() {
    widget.userCubit.injectPreview(widget.data.user);
    widget.walletCubit.injectPreview(widget.data.wallet);
    widget.withdrawalCubit.injectPreview(
      bankAccounts:      widget.data.bankAccounts,
      withdrawalHistory: widget.data.withdrawalHistory,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Preview mode banner ─────────────────────────────────────
        _PreviewBanner(onRefresh: _injectPreviewData),
        Expanded(child: widget.child),
      ],
    );
  }
}

class _PreviewBanner extends StatelessWidget {
  final VoidCallback onRefresh;
  const _PreviewBanner({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFF6B00),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'PREVIEW MODE — Demo data only, no API calls',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onRefresh,
                child: const Icon(Icons.refresh, size: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extension on WalletUser preview so it can be called on UserCubit directly.
extension UserCubitPreview on UserCubit {
  void injectPreview(WalletUser user) {
    if (!isClosed) emit(UserState.loaded(user: user));
  }
}