import 'package:flutter/material.dart';

class KycPageTitle {
  final IconData icon;
  final String title;
  final String subTitle;
  final String? badge;
  final String? buttonCaption;
  final void Function()? pageButton;
  final int step;

  KycPageTitle({
    required this.icon,
    required this.title,
    required this.subTitle,
    this.badge,
    this.buttonCaption,
    this.pageButton,
    required this.step,
  });

  KycPageTitle copyWith({
    IconData? icon,
    String? title,
    String? subTitle,
    String? badge,
    String? buttonCaption,
    void Function()? pageButton,
    int? step,
  }) {
    return KycPageTitle(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      subTitle: subTitle ?? this.subTitle,
      badge: badge ?? this.badge,
      buttonCaption: buttonCaption ?? this.buttonCaption,
      pageButton: pageButton ?? this.pageButton,
      step: step ?? this.step,
    );
  }
}

const int totalStep = 4;

final KycPageTitle firstTierPageTitle = KycPageTitle(
  icon: Icons.star_outline_outlined,
  title: 'Overview',
  subTitle: '',
  badge: 'TIER 1 · BASIC INFO',
  buttonCaption: 'Begin verification',
  pageButton: () {},
  step: 0,
);

final KycPageTitle secondPageTitle = KycPageTitle(
  icon: Icons.person_outline,
  title: 'Basic Info',
  subTitle: 'Verify your identity to unlock up to ₦500,000 in deal limits.',
  badge: 'TIER 1 · BASIC INFO',
  buttonCaption: 'Submit & verify',
  pageButton: () {},
  step: 1,
);

final KycPageTitle thirdPageTitle = KycPageTitle(
  icon: Icons.lock_outline,
  title: 'Enhanced KYC',
  subTitle: 'Add your BVN and a selfie for biometric matching to unlock ₦5M.',
  badge: 'TIER 2 · ENHANCED KYC',
  buttonCaption: 'Submit & verify',
  pageButton: () {},
  step: 2,
);

final KycPageTitle fourthPageTitle = KycPageTitle(
  icon: Icons.check,
  title: 'Address Verification',
  subTitle:
      'Verify your address via utility bill to unlock unlimited deal limits.',
  badge: 'TIER 3 · IDENTITY VERIFIED',
  buttonCaption: 'Complete verification',
  step: 3,
);
