import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../merkado_wallet.dart';

/// WalletAmountText — formatted balance display with visibility support.
class WalletAmountText extends StatelessWidget {
  final double amount;
  final String symbol;
  final bool visible;
  final TextStyle? style;

  const WalletAmountText({
    super.key,
    required this.amount,
    required this.symbol,
    required this.visible,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = visible
        ? '$symbol${_format(amount)}'
        : '$symbol•••••';

    // Split integer and decimal for styled rendering
    if (!visible) {
      return Text(formatted, style: style);
    }

    final parts = _format(amount).split('.');
    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: '$symbol${parts[0]}'),
          TextSpan(
            text: '.${parts.length > 1 ? parts[1] : '00'}',
            style: style?.copyWith(
              fontSize: (style?.fontSize ?? 32) * 0.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _format(double v) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(v);
  }
}

// ── ExploreActionsRow ──────────────────────────────────────────────────────────

/// Renders the "Explore Deals" section with horizontally scrollable pill buttons.
/// Only rendered when the consuming app injects [WalletExploreAction]s.
class ExploreActionsRow extends StatelessWidget {
  final List<WalletExploreAction> actions;
  final Color primary;

  const ExploreActionsRow({
    super.key,
    required this.actions,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Deals',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 44.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: actions.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (context, i) {
                final action = actions[i];
                return _ExploreActionPill(action: action, primary: primary);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreActionPill extends StatelessWidget {
  final WalletExploreAction action;
  final Color primary;

  const _ExploreActionPill({required this.action, required this.primary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(action.icon, size: 16.sp, color: Colors.black87),
                SizedBox(width: 6.w),
                Text(
                  action.label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // Badge
          if (action.badge != null && action.badge! > 0)
            Positioned(
              top: -6.h,
              right: -4.w,
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.w),
                child: Text(
                  '${action.badge}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── WithdrawalListTile ────────────────────────────────────────────────────────

class WithdrawalListTile extends StatelessWidget {
  final WithdrawalRecord record;
  final String symbol;

  const WithdrawalListTile({
    super.key,
    required this.record,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    final isDebit = true; // Withdrawals are always debits
    final amountColor = Colors.black87;
    final sign = '-';
    final dateStr = DateFormat('dd MMMM, yyyy').format(record.createdAt);
    final shortId = record.id.length >= 8
        ? record.id.substring(0, 8).toUpperCase()
        : record.id.toUpperCase();

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ),
      leading: _InitialsAvatar(text: shortId),
      title: Text(
        'Withdrawal • $shortId',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        dateStr,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey.shade500,
        ),
      ),
      trailing: Text(
        '$sign$symbol${_formatAmount(record.amount)}',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: amountColor,
        ),
      ),
    );
  }

  String _formatAmount(double v) {
    return NumberFormat('#,##0.00').format(v);
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String text;
  const _InitialsAvatar({required this.text});

  @override
  Widget build(BuildContext context) {
    final letters = text.length >= 2 ? text.substring(0, 2) : text;
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
      ),
      alignment: Alignment.center,
      child: Text(
        letters,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}