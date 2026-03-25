import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class GenderButton extends StatelessWidget {
  const GenderButton({
    super.key,
    required this.gender,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  final String gender;
  final IconData icon;
  final bool isSelected;
  final Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () => onSelected(gender),
        icon: Icon(
          icon,
          size: 18,
          color: isSelected
              ? (isDark ? Colors.black : Colors.white)
              : Theme.of(context).textTheme.bodyLarge?.color,
        ),
        label: Text(
          gender,
          style: TextStyle(
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected
              ? (isDark ? Colors.white : AppColors.primary)
              : Colors.transparent,
          side: BorderSide(
            color: isSelected
                ? (isDark ? Colors.white : AppColors.primary)
                : Theme.of(context).dividerColor,
          ),
        ),
      ),
    );
  }
}
