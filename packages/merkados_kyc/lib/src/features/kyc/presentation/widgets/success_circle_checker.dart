import 'package:flutter/material.dart';

class SuccessCircleChecker extends StatelessWidget {
  const SuccessCircleChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 10),
      child: Stack(
        children: [
          Positioned(
            left: -10,
            top: 0,
            child: Container(
              width: 116,
              height: 116,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: const Color(0x59B08D57)),
                  borderRadius: BorderRadius.circular(58),
                ),
              ),
            ),
          ),
          Container(
            width: 96,
            height: 96,
            decoration: ShapeDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.10, -0.07),
                end: Alignment(0.90, 1.07),
                colors: [const Color(0xFF2A5C3F), const Color(0xFF1A3828)],
              ),
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 3, color: const Color(0x7FB08D57)),
                borderRadius: BorderRadius.circular(48),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: ShapeDecoration(
                      color: Colors.white.withValues(alpha: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(48),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x59000000),
                          blurRadius: 32,
                          offset: Offset(0, 12),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Color(0x19B08D57),
                          blurRadius: 0,
                          offset: Offset(0, 0),
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Image.asset(
                    'assets/images/checked.png',
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    package: 'merkados_kyc',
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
