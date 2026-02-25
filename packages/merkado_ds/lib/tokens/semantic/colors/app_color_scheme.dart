import 'package:flutter/widgets.dart';

import 'driply_dark_colors.dart';
import 'driply_light_colors.dart';
import 'mycut_dark_colors.dart';
import 'mycut_light_colors.dart';

/// Normalized color contract every app must fulfill.
/// Maps semantic intent → concrete color.
/// The theme builder only ever reads this.
class AppColorScheme {
  // Brand
  final Color brandPrimary;
  final Color brandSecondary;

  // Background
  final Color backgroundPrimary;
  final Color backgroundSurface;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;

  // Border
  final Color borderDefault;
  final Color borderFocused;

  // State
  final Color stateSuccess;
  final Color stateWarning;
  final Color stateError;

  // Surface
  final Color surfaceContainer;
  final Color surfaceCard;

  const AppColorScheme({
    required this.brandPrimary,
    this.brandSecondary = const Color(0xFF000000), // sensible defaults
    required this.backgroundPrimary,
    required this.backgroundSurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.borderDefault,
    required this.borderFocused,
    required this.stateSuccess,
    required this.stateWarning,
    required this.stateError,
    required this.surfaceContainer,
    required this.surfaceCard,
  });

  /// Each app's semantic file provides a factory.
  /// Mycut just maps its tokens into this contract.
  factory AppColorScheme.fromMycut({required bool isDark}) {
    if (isDark) {
      return AppColorScheme(
        brandPrimary: MycutLightColors.brandPrimary, // brand doesn't flip
        backgroundPrimary: MycutDarkColors.backgroundPrimary,
        backgroundSurface: MycutDarkColors.backgroundSurface,
        textPrimary: MycutDarkColors.textPrimary,
        textSecondary: MycutDarkColors.textSecondary,
        textDisabled: MycutDarkColors.textSecondary.withValues(alpha:0.4),
        borderDefault: MycutDarkColors.borderDefault,
        borderFocused: MycutLightColors.brandPrimary,
        stateSuccess: MycutLightColors.accentGreen,
        stateWarning: MycutLightColors.accentBlue,
        stateError: MycutLightColors.stateError,
        surfaceContainer: MycutLightColors.surfaceContainer,
        surfaceCard: MycutDarkColors.backgroundSurface,
      );
    }
    return AppColorScheme(
      brandPrimary: MycutLightColors.brandPrimary,
      backgroundPrimary: MycutLightColors.backgroundPrimary,
      backgroundSurface: MycutLightColors.surfaceContainer,
      textPrimary: MycutLightColors.textPrimary,
      textSecondary: MycutLightColors.textPrimary.withValues(alpha:0.6),
      textDisabled: MycutLightColors.stateInactive,
      borderDefault: MycutLightColors.stateInactive,
      borderFocused: MycutLightColors.brandPrimary,
      stateSuccess: MycutLightColors.accentGreen,
      stateWarning: MycutLightColors.stateNegotiating,
      stateError: MycutLightColors.stateError,
      surfaceContainer: MycutLightColors.surfaceContainer,
      surfaceCard: MycutLightColors.accentWhite,
    );
  }

  factory AppColorScheme.fromDriply({required bool isDark}) {
    if (isDark) {
      return AppColorScheme(
        brandPrimary: DriplyLightColors.brandPrimary,
        brandSecondary: DriplyLightColors.brandSecondary,
        backgroundPrimary: DriplyDarkColors.backgroundPrimary,
        backgroundSurface: DriplyDarkColors.backgroundSurface,
        textPrimary: DriplyDarkColors.textPrimary,
        textSecondary: DriplyDarkColors.textSecondary,
        textDisabled: DriplyDarkColors.textSecondary.withValues(alpha:0.4),
        borderDefault: DriplyDarkColors.borderDefault,
        borderFocused: DriplyLightColors.brandPrimary,
        stateSuccess: DriplyLightColors.stateSuccess,
        stateWarning: DriplyLightColors.stateWarning,
        stateError: DriplyLightColors.brandPrimary,
        surfaceContainer: DriplyDarkColors.backgroundSurface,
        surfaceCard: DriplyDarkColors.backgroundSurface,
      );
    }
    return AppColorScheme(
      brandPrimary: DriplyLightColors.brandPrimary,
      brandSecondary: DriplyLightColors.brandSecondary,
      backgroundPrimary: DriplyLightColors.backgroundPrimary,
      backgroundSurface: DriplyLightColors.backgroundPrimary,
      textPrimary: DriplyLightColors.textPrimary,
      textSecondary: DriplyLightColors.textSecondary,
      textDisabled: DriplyLightColors.textSecondary.withValues(alpha:0.4),
      borderDefault: DriplyLightColors.textSecondary.withValues(alpha:0.2),
      borderFocused: DriplyLightColors.brandPrimary,
      stateSuccess: DriplyLightColors.stateSuccess,
      stateWarning: DriplyLightColors.stateWarning,
      stateError: DriplyLightColors.brandPrimary,
      surfaceContainer: DriplyLightColors.backgroundPrimary,
      surfaceCard: Color(0xFFFFFFFF), // Driply doesn't have a surfaceCard token, so we use white for both themes to maintain contrast with text. This is a good example of why we need this semantic layer — the theme tokens alone don't fulfill all our needs.  
    );
  }
}