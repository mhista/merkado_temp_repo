import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SuccessProfileSnippet extends StatelessWidget {
  final String userFullName;
  const SuccessProfileSnippet({super.key, required this.userFullName});

  @override
  Widget build(BuildContext context) {
    final initials = userFullName
        .trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFFE4E2DC)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.00, 0.00),
                end: Alignment(1.00, 1.00),
                colors: [const Color(0xFF2A5C3F), const Color(0xFF1A3828)],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              initials.isEmpty ? '?' : initials,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFC9A96E),
                fontSize: 18,
                fontFamily: 'Cormorant Garamond',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userFullName.isEmpty ? 'User' : userFullName,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'MyCut Member • Verified', //  since today
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.check, size: 12, color: AppColors.success),
                SizedBox(width: 4),
                Text(
                  'Verified',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
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
