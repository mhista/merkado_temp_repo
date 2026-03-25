import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class AddressPowerTypeButton extends StatelessWidget {
  const AddressPowerTypeButton({
    super.key,
    required this.type,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  final String type;
  final IconData icon;
  final bool isSelected;
  final Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () => onSelected(type),
        icon: Icon(
          icon,
          size: 18,
          color: isSelected
              ? (isDark ? Colors.black : Colors.white)
              : Theme.of(context).textTheme.bodyLarge?.color,
        ),
        label: Text(
          type,
          style: TextStyle(
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected
              ? (isDark ? Colors.white : AppColors.primary)
              : Theme.of(context).dividerColor.withValues(alpha: 0.135),
          side: BorderSide(
            color: isSelected
                ? (isDark ? Colors.white : AppColors.primary)
                : Theme.of(context).dividerColor.withValues(alpha: 0.16),
          ),
        ),
      ),
    );
  }
}
