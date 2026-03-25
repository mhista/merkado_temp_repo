import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class BasicInfoBar extends StatelessWidget {
  const BasicInfoBar({
    super.key,
    required this.formKey,
    required this.label,
    required this.title,
    required this.subTitle,
    required this.cardBody,
  });

  final GlobalKey<FormState> formKey;
  final String label;
  final String title;
  final String subTitle;
  final Widget cardBody;

  @override
  Widget build(BuildContext context) {
    final double devWidth = MediaQuery.sizeOf(context).width;
    return Container(
      width: devWidth,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.only(
        top: 0.0,
        left: 0.0,
        right: 0.0,
        bottom: AppSpacing.md + 20.0,
      ),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: const Color(0x3F2A6049)),
          borderRadius: BorderRadius.circular(14),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x112A6049),
            blurRadius: 16,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        spacing: AppSpacing.md,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 14,
              left: 16,
              right: 16,
              bottom: 13,
            ),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: const Color(0xFFE4E2DC)),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 11,
              children: [
                Container(
                  width: 28.0,
                  height: 28.0,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFEEF1F8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF3B5FA0),
                      fontSize: 12,
                      fontFamily: 'Instrument Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 1,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: const Color(0xFF1A1A1A),
                        fontSize: 14,
                        fontFamily: 'Instrument Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subTitle,
                      style: TextStyle(
                        color: const Color(0xFF9A9A9A),
                        fontSize: 12,
                        fontFamily: 'Instrument Sans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: cardBody,
          ),
        ],
      ),
    );
  }
}
