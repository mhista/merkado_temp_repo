import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class KycTierCard extends StatelessWidget {
  final String title;
  final String description;
  final Iterable<String> tags;
  final String unlockLimit;
  final VoidCallback? onTap;
  final bool isLocked;
  final bool isCompleted;
  final bool isStartHere;

  const KycTierCard({
    super.key,
    required this.title,
    required this.description,
    required this.tags,
    required this.unlockLimit,
    this.onTap,
    this.isLocked = false,
    this.isCompleted = false,
    this.isStartHere = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(
          color: isStartHere
              ? Theme.of(context).dividerColor.withValues(alpha: 0.135)
              : AppColors.primary.withValues(alpha: 0.35),
          width: isStartHere ? 1.5 : 1,
        ),
      ),
      shadowColor: isLocked ? Colors.transparent : Color(0x142A6049),
      child: InkWell(
        onTap: (isLocked || isCompleted) ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40.0,
                        height: 40.0,
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                          color: isLocked
                              ? Theme.of(
                                  context,
                                ).dividerColor.withValues(alpha: 0.31)
                              : const Color(0xFFEEF1F8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                        child: Icon(
                          isLocked
                              ? Icons.lock_outline
                              : (isCompleted
                                    ? Icons.check
                                    : Icons.person_outline),
                          color: isLocked ? Colors.grey : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isLocked
                                      ? Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color
                                      : Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                ),
                          ),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isStartHere)
                    StartButton(
                      onTap: onTap,
                      isDark: isDark,
                      title: 'Start here',
                      isLocked: isLocked,
                    )
                  else if (isLocked)
                    StartButton(
                      onTap: null,
                      isDark: isDark,
                      title: 'Locked',
                      isLocked: isLocked,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 4,
                runSpacing: 1,
                children: tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 0.0,
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.13),
                        side: BorderSide(
                          width: 1,
                          color: const Color(0xFFCCCAC2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Unlocks deal limit',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    unlockLimit,
                    style: TextStyle(
                      color: isLocked
                          ? AppColors.primary
                          : Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StartButton extends StatelessWidget {
  const StartButton({
    super.key,
    required this.onTap,
    required this.isDark,
    required this.title,
    required this.isLocked,
  });

  final VoidCallback? onTap;
  final bool isDark;
  final String title;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: isLocked
              ? Theme.of(context).dividerColor.withValues(alpha: 0.135)
              : isDark
              ? AppColors.primary
              : const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            isLocked
                ? Icon(Icons.lock, size: 14, color: AppColors.cardBg)
                : const SizedBox.shrink(),
            isLocked ? const SizedBox(width: 4) : const SizedBox.shrink(),
            Text(
              title,
              style: TextStyle(
                color: isLocked
                    ? Theme.of(context).textTheme.bodySmall?.color
                    : Colors.white,
                fontSize: 11,
                fontFamily: 'Instrument Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
