import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../cubit/withdrawal_cubit.dart';
import '../../domain/models/withdrawal_record.dart';
import '../../../../core/config/merkado_wallet_config.dart';

/// WithdrawalHistoryScreen
/// =======================
/// Full list of withdrawal records, grouped by date.
class WithdrawalHistoryScreen extends StatefulWidget {
  final MerkadoWalletConfig config;
  final WithdrawalCubit withdrawalCubit;

  const WithdrawalHistoryScreen({
    super.key,
    required this.config,
    required this.withdrawalCubit,
  });

  @override
  State<WithdrawalHistoryScreen> createState() =>
      _WithdrawalHistoryScreenState();
}

class _WithdrawalHistoryScreenState extends State<WithdrawalHistoryScreen> {
  @override
  void initState() {
    super.initState();
    widget.withdrawalCubit.loadHistory();
  }

  String get _symbol => widget.config.currency.symbol;
  Color get _primary => widget.config.effectivePrimary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Transaction History',
            style:
                TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: BlocBuilder<WithdrawalCubit, WithdrawalState>(
        bloc: widget.withdrawalCubit,
        builder: (context, state) {
          return state.maybeMap(
            loading: (_) => Center(
                child: CircularProgressIndicator(color: _primary)),
            error: (s) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 40.sp, color: Colors.red.shade300),
                  SizedBox(height: 12.h),
                  Text(s.message,
                      style: TextStyle(color: Colors.grey.shade600)),
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: widget.withdrawalCubit.loadHistory,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            historyLoaded: (s) {
              if (s.records.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 48.sp, color: Colors.grey.shade300),
                      SizedBox(height: 12.h),
                      Text('No withdrawal history yet',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 15.sp)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: _primary,
                onRefresh: () async => widget.withdrawalCubit.loadHistory(),
                child: ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: s.records.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, i) {
                    final r = s.records[i];
                    return _HistoryTile(
                        record: r, symbol: _symbol, primary: _primary);
                  },
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final WithdrawalRecord record;
  final String symbol;
  final Color primary;

  const _HistoryTile({
    required this.record,
    required this.symbol,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (record.status) {
      WithdrawalStatus.completed => Colors.green,
      WithdrawalStatus.failed => Colors.red,
      _ => Colors.orange,
    };

    final statusLabel = switch (record.status) {
      WithdrawalStatus.completed => 'Completed',
      WithdrawalStatus.failed => 'Failed',
      WithdrawalStatus.processing => 'Processing',
      _ => 'Pending',
    };

    return ListTile(
      contentPadding:
          EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      leading: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          record.isCompleted
              ? Icons.check_circle_outline
              : record.isFailed
                  ? Icons.error_outline
                  : Icons.hourglass_empty,
          color: statusColor,
          size: 20.sp,
        ),
      ),
      title: Text(
        '-$symbol${NumberFormat('#,##0.00').format(record.amount)}',
        style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87),
      ),
      subtitle: Text(
        DateFormat('dd MMM yyyy, HH:mm').format(record.createdAt),
        style:
            TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
      ),
      trailing: Container(
        padding:
            EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Text(
          statusLabel,
          style: TextStyle(
              fontSize: 11.sp,
              color: statusColor,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}