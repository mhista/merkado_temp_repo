import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../shared/wallet_widgets.dart';
import '../cubit/wallet_cubit.dart';
import '../../domain/models/wallet.dart';
import '../../../../core/config/merkado_wallet_config.dart';
import '../../../withdrawal/presentation/screens/withdrawal_history_screen.dart';
import '../../../withdrawal/presentation/screens/add_money_screen.dart';
import '../../../withdrawal/presentation/screens/withdraw_screen.dart';
import '../../../withdrawal/presentation/cubit/withdrawal_cubit.dart';

/// WalletHomeScreen
/// ================
/// The main wallet screen matching the Figma design:
///
///   ┌──────────────────────────────────────┐
///   │  TOTAL BALANCE  ▾                    │
///   │  ₦0.00  👁                           │
///   │  [Withdraw]  [Add money]             │
///   │                                      │
///   │  Explore Deals                       │
///   │  [Create deal] [Invite members] ...  │
///   │                                      │
///   │  RECENT TRANSACTIONS   See all →     │
///   │  ...transaction rows...              │
///   └──────────────────────────────────────┘
class WalletHomeScreen extends StatefulWidget {
  final MerkadoWalletConfig config;
  final WalletCubit cubit;
  final WithdrawalCubit withdrawalCubit;

  const WalletHomeScreen({
    super.key,
    required this.config,
    required this.cubit,
    required this.withdrawalCubit,
  });

  @override
  State<WalletHomeScreen> createState() => _WalletHomeScreenState();
}

class _WalletHomeScreenState extends State<WalletHomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.cubit.loadWallet();
    if (widget.config.features.recentActivityPreview) {
      widget.withdrawalCubit.loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.config.effectivePrimary;
    final symbol = widget.config.currency.symbol;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<WalletCubit, WalletState>(
        bloc: widget.cubit,
        listener: (context, state) {
          state.maybeMap(
            error: (s) => _showSnackBar(context, s.message, isError: true),
            demoFundSuccess: (s) => _showSnackBar(
              context,
              '$symbol${s.amount.toStringAsFixed(0)} added to your wallet!',
            ),
            demoWithdrawSuccess: (s) => _showSnackBar(
              context,
              '$symbol${s.amount.toStringAsFixed(0)} withdrawn successfully.',
            ),
            orElse: () {},
          );
        },
        builder: (context, state) {
          return RefreshIndicator(
            color: primary,
            onRefresh: () async {
              widget.cubit.loadWallet();
              widget.withdrawalCubit.loadHistory();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Balance section ────────────────────────────────────
                SliverToBoxAdapter(
                  child: _BalanceSection(
                    state: state,
                    config: widget.config,
                    cubit: widget.cubit,
                    withdrawalCubit: widget.withdrawalCubit,
                    primary: primary,
                    symbol: symbol,
                  ),
                ),

                // ── Explore Actions ────────────────────────────────────
                if (widget.config.features.exploreActions.isNotEmpty)
                  SliverToBoxAdapter(
                    child: ExploreActionsRow(
                      actions: widget.config.features.exploreActions,
                      primary: primary,
                    ),
                  ),

                // ── Recent activity ────────────────────────────────────
                if (widget.config.features.recentActivityPreview)
                  SliverToBoxAdapter(
                    child: _RecentActivitySection(
                      withdrawalCubit: widget.withdrawalCubit,
                      config: widget.config,
                      primary: primary,
                      symbol: symbol,
                    ),
                  ),

                SliverToBoxAdapter(child: SizedBox(height: 32.h)),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }
}

// ── Balance Section Widget ────────────────────────────────────────────────────

class _BalanceSection extends StatelessWidget {
  final WalletState state;
  final MerkadoWalletConfig config;
  final WalletCubit cubit;
  final WithdrawalCubit withdrawalCubit;
  final Color primary;
  final String symbol;

  const _BalanceSection({
    required this.state,
    required this.config,
    required this.cubit,
    required this.withdrawalCubit,
    required this.primary,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    final wallet = state.maybeMap(
      loaded: (s) => s.wallet,
      updating: (s) => s.wallet,
      orElse: () => null,
    );

    final balanceVisible = state.maybeMap(
      loaded: (s) => s.balanceVisible,
      updating: (s) => s.balanceVisible,
      orElse: () => true,
    );

    final isLoading = state.maybeMap(
      loading: (_) => true,
      orElse: () => false,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
      ),
      child: Stack(
        children: [
          // Subtle background curves
          Positioned(
            top: -20.h,
            right: -30.w,
            child: Container(
              width: 180.w,
              height: 180.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200.withOpacity(0.6),
              ),
            ),
          ),
          Positioned(
            bottom: 10.h,
            left: -40.w,
            child: Container(
              width: 140.w,
              height: 140.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200.withOpacity(0.4),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 32.h),
            child: Column(
              children: [
                // "TOTAL BALANCE" label
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'TOTAL BALANCE',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.keyboard_arrow_down,
                        size: 18.sp, color: Colors.grey.shade600),
                  ],
                ),

                SizedBox(height: 12.h),

                // Balance amount + visibility toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    isLoading
                        ? _BalanceShimmer()
                        : WalletAmountText(
                            amount: wallet?.availableBalance ?? 0,
                            symbol: symbol,
                            visible: balanceVisible,
                            style: TextStyle(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                    SizedBox(width: 8.w),
                    if (config.features.balanceVisibilityToggle)
                      GestureDetector(
                        onTap: cubit.toggleBalanceVisibility,
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Icon(
                            balanceVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 28.h),

                // Action buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (config.features.withdraw)
                      _ActionButton(
                        icon: Icons.north_east,
                        label: 'Withdraw',
                        primary: primary,
                        onTap: () => _onWithdraw(context),
                      ),
                    if (config.features.withdraw && config.features.addMoney)
                      SizedBox(width: 16.w),
                    if (config.features.addMoney)
                      _ActionButton(
                        icon: Icons.add,
                        label: 'Add money',
                        primary: primary,
                        onTap: () => _onAddMoney(context),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onWithdraw(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: withdrawalCubit,
        child: WithdrawScreen(config: config, withdrawalCubit: withdrawalCubit),
      ),
    ));
  }

  void _onAddMoney(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: AddMoneyScreen(config: config, walletCubit: cubit),
      ),
    ));
  }
}

// ── Recent Activity Section ───────────────────────────────────────────────────

class _RecentActivitySection extends StatelessWidget {
  final WithdrawalCubit withdrawalCubit;
  final MerkadoWalletConfig config;
  final Color primary;
  final String symbol;

  const _RecentActivitySection({
    required this.withdrawalCubit,
    required this.config,
    required this.primary,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT TRANSACTIONS',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.1,
                ),
              ),
              if (config.features.withdrawalHistory)
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: withdrawalCubit,
                      child: WithdrawalHistoryScreen(
                        config: config,
                        withdrawalCubit: withdrawalCubit,
                      ),
                    ),
                  )),
                  child: Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 12.h),

          // Transaction list
          BlocBuilder<WithdrawalCubit, WithdrawalState>(
            bloc: withdrawalCubit,
            builder: (context, state) {
              return state.maybeMap(
                historyLoaded: (s) {
                  final items = s.records
                      .take(config.features.recentActivityCount)
                      .toList();

                  if (items.isEmpty) {
                    return _EmptyTransactions(primary: primary);
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.grey.shade200,
                        indent: 16.w,
                        endIndent: 16.w,
                      ),
                      itemBuilder: (context, i) => WithdrawalListTile(
                        record: items[i],
                        symbol: symbol,
                      ),
                    ),
                  );
                },
                loading: (_) => _LoadingTransactions(),
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color primary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: Icon(icon, size: 22.sp, color: Colors.black87),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.w,
      height: 36.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  final Color primary;
  const _EmptyTransactions({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 40.sp, color: Colors.grey.shade400),
          SizedBox(height: 8.h),
          Text(
            'No transactions yet',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (i) => Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12.h,
                      width: 120.w,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      height: 10.h,
                      width: 80.w,
                      color: Colors.grey.shade200,
                    ),
                  ],
                ),
              ),
              Container(
                height: 14.h,
                width: 60.w,
                color: Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Import needed for WithdrawalCubit usage in this file