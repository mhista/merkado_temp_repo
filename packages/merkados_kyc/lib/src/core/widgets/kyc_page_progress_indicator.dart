import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

const int totalSteps = 4;

class KycPageProgressIndicator extends StatelessWidget {
  const KycPageProgressIndicator({
    super.key,
    required this.isDark,
    required this.currentStep,
  });

  final bool isDark;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        totalSteps,
        (index) => Expanded(
          child: Container(
            height: 4.0,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: index == currentStep
                  ? AppColors.primary
                  : Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
