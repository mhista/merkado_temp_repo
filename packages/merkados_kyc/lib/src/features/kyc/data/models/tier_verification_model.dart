import 'package:flutter/material.dart';

class TierVerificationStatus {
  final String tier;
  final String title;
  final String subTitle;
  final IconData icon;
  final Color color;

  TierVerificationStatus({
    required this.tier,
    required this.title,
    required this.subTitle,
    required this.icon,
    required this.color,
  });
}

final TierVerificationStatus tier1 = TierVerificationStatus(
  tier: 'TIER 1',
  title: 'Basic Info',
  subTitle: 'DOB · NIN · Gender',
  icon: Icons.person,
  color: const Color(0xFFEEF2FB),
);

final TierVerificationStatus tier2 = TierVerificationStatus(
  tier: 'TIER 2',
  title: 'Enhanced KYC',
  subTitle: 'BVN · Biometric · Selfie',
  icon: Icons.lock_outlined,
  color: const Color(0xFFE4E2DC),
);

final TierVerificationStatus tier3 = TierVerificationStatus(
  tier: 'TIER 3',
  title: 'Identity Verified',
  subTitle: 'Address · Utility Bill',
  icon: Icons.star_outline_outlined,
  color: const Color(0xFFE6F2EC),
);
