import 'package:flutter/material.dart';

class ShowLimitActivated extends StatelessWidget {
  const ShowLimitActivated({super.key, this.limit = 'Up to ₦500,000'});

  final String limit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 43,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: ShapeDecoration(
        color: const Color(0xFFEEF1F8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Unlocks deal limit',
            style: TextStyle(
              color: const Color(0xFF3B5FA0),
              fontSize: 12,
              fontFamily: 'Instrument Sans',
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            limit,
            style: TextStyle(
              color: const Color(0xFF3B5FA0),
              fontSize: 13,
              fontFamily: 'Instrument Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
