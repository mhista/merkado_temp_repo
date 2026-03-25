import 'package:flutter/material.dart';

import '../../data/models/tier_verification_model.dart';
import 'success_verify_tier.dart';

class SuccessVerificationBar extends StatelessWidget {
  const SuccessVerificationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final double devWidth = MediaQuery.sizeOf(context).width;

    return Container(
      width: devWidth,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: const Color(0xFFE4E2DC)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: const Color(0xFFE4E2DC)),
              ),
            ),
            child: Text(
              'VERIFICATION SUMMARY',
              style: TextStyle(
                color: const Color(0xFF9A9A9A),
                fontSize: 11,
                fontFamily: 'Instrument Sans',
                fontWeight: FontWeight.w700,
                letterSpacing: 1.10,
              ),
            ),
          ),
          VerifySummaryTier(tier: tier1),
          VerifySummaryTier(tier: tier2),
          VerifySummaryTier(tier: tier3),
        ],
      ),
    );
  }
}
