import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/kyc_page_progress_indicator.dart';
import 'success_circle_checker.dart';

class SuccessAppBar extends StatelessWidget {
  const SuccessAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final double devWidth = MediaQuery.of(context).size.width;
    final double devHeight = MediaQuery.of(context).size.height;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: devWidth,
      height: 383.0,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: const Color(0xFF1A2E1A)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        spacing: AppSpacing.sm,
        children: [
          Container(
            height: 27.0,
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(top: devHeight * 0.05, right: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
              decoration: ShapeDecoration(
                color: const Color(0x2DB08D57),
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: const Color(0x66B08D57)),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'ALL TIERS COMPLETE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFC9A96E),
                  fontSize: 10,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.30,
                ),
              ),
            ),
          ),
          Center(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'MY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontFamily: 'Cormorant Garamond',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.05,
                    ),
                  ),
                  TextSpan(
                    text: 'CUT',
                    style: TextStyle(
                      color: const Color(0xFFB08D57),
                      fontSize: 21,
                      fontFamily: 'Cormorant Garamond',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.05,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SuccessCircleChecker(),
          Container(
            // width: 355,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 4),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "You're fully\n",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontFamily: 'Cormorant Garamond',
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  TextSpan(
                    text: 'verified.',
                    style: TextStyle(
                      color: const Color(0xFFC9A96E),
                      fontSize: 28,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Cormorant Garamond',
                      fontWeight: FontWeight.w300,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Your identity has been confirmed across all three tiers. You're ready to create and close deals on MyCut.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.60),
                fontSize: 13,
                fontFamily: 'Instrument Sans',
                fontWeight: FontWeight.w400,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: KycPageProgressIndicator(isDark: isDark, currentStep: 4),
          ),
        ],
      ),
    );
  }
}
