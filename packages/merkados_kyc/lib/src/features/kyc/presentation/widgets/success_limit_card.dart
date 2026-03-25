import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SuccessLimitCard extends StatelessWidget {
  const SuccessLimitCard({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.1)
            : const Color(0xFF1E3528),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DEAL TRANSACTION LIMIT',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '∞',
            style: TextStyle(fontSize: 32, color: AppColors.primary),
          ),
          Text(
            'No cap on deal value. Create, negotiate, and close deals of any size — from ₦1 to ₦1,000,000,000+.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.50),
              fontSize: 12.50,
              fontFamily: 'Instrument Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: ShapeDecoration(
              color: const Color(0x26B08D57),
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: const Color(0x4CB08D57)),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 6,
              children: [
                Icon(Icons.star, color: AppColors.primary, size: 14.0),
                Text(
                  'Unlimited Deals Unlocked',
                  style: TextStyle(
                    color: const Color(0xFFC9A96E),
                    fontSize: 12,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
