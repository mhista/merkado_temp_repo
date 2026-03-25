import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/whats_next_model.dart';

class SuccessWhatsNextCard extends StatelessWidget {
  const SuccessWhatsNextCard({super.key, required this.whatsNext});

  final WhatsNext whatsNext;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: ShapeDecoration(
              color: const Color(0xFFE6F2EC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Icon(whatsNext.icon, color: AppColors.primary, size: 18.0),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  whatsNext.title,
                  style: TextStyle(
                    color: const Color(0xFF1A1A1A),
                    fontSize: 13.50,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),

                Text(
                  whatsNext.subTitle,
                  style: TextStyle(
                    color: const Color(0xFF6B6B6B),
                    fontSize: 12,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w400,
                    height: 1.45,
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
