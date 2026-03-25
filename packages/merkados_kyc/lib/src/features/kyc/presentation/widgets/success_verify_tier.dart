import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/tier_verification_model.dart';

class VerifySummaryTier extends StatelessWidget {
  const VerifySummaryTier({super.key, required this.tier});

  final TierVerificationStatus tier;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: const Color(0xFFE4E2DC)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 12,
        children: [
          Container(
            width: 36.0,
            height: 36.0,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: tier.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Icon(tier.icon, color: AppColors.primary, size: 18.0),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 1,
              children: [
                Text(
                  tier.tier,
                  style: TextStyle(
                    color: const Color(0xFF2D5BE3),
                    fontSize: 9.50,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.14,
                  ),
                ),
                Text(
                  tier.title,
                  style: TextStyle(
                    color: const Color(0xFF1A1A1A),
                    fontSize: 13.50,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  tier.subTitle,
                  style: TextStyle(
                    color: const Color(0xFF9A9A9A),
                    fontSize: 11.50,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: const Color(0xFFE6F2EC),
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: const Color(0x3F2A6049)),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Icon(Icons.check, color: AppColors.primary, size: 18.0),
          ),
        ],
      ),
    );
  }
}
