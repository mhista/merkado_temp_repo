import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark
        ? Colors.black.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.06);
    final Color borderColor = isDark
        ? Colors.black.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.18);
    final Color iconColor = isDark ? Colors.black : Colors.white;

    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 35.0,
        height: 35.0,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: bgColor,
          shape: CircleBorder(side: BorderSide(width: 1.0, color: borderColor)),
        ),
        child: Center(
          child: Icon(Icons.arrow_back_ios, color: iconColor, size: 16),
        ),
      ),
    );
  }
}
