// merkado_ds/theme/merkado_theme_builder.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'merkado_theme_config.dart';
import '../tokens/semantic/colors/app_color_scheme.dart';
import '../tokens/semantic/typography_semantic.dart';

import '../tokens/semantic/spacing_semantic.dart';

class MerkadoThemeBuilder {
  MerkadoThemeBuilder._();

  static ThemeData build({
    required MerkadoThemeConfig config,
    required bool isDark,
  }) {
    final colors = config.colors;
    final radius = config.borderRadius;

    return ThemeData(
      fontFamily: config.fontFamilyOverride ?? 'inter',
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: colors.brandPrimary,
      scaffoldBackgroundColor: colors.backgroundPrimary,
      colorScheme: _buildColorScheme(colors, isDark),
      textTheme: _buildTextTheme(colors),
      appBarTheme: config.appBarThemeOverride ?? _buildAppBarTheme(colors, isDark),
      elevatedButtonTheme: config.elevatedButtonOverride ?? _buildElevatedButton(colors, radius),
      inputDecorationTheme: config.inputDecorationOverride ?? _buildInputDecoration(colors, radius),
      bottomSheetTheme: config.bottomSheetOverride ?? _buildBottomSheet(colors, radius),
      chipTheme: config.chipOverride ?? _buildChip(colors),
      checkboxTheme: config.checkboxOverride ?? _buildCheckbox(colors),
    );
  }

  static ColorScheme _buildColorScheme(AppColorScheme colors, bool isDark) {
    return ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: colors.brandPrimary,
      onPrimary: Colors.white,
      secondary: colors.brandSecondary,
      onSecondary: Colors.white,
      surface: colors.backgroundSurface,
      onSurface: colors.textPrimary,
      error: colors.stateError,
      onError: Colors.white,
    );
  }

  static TextTheme _buildTextTheme(AppColorScheme colors) {
    // Uses SemanticTypography tokens — same across all apps
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: SemanticTypography.displayLargeFontFamily,
        fontSize: SemanticTypography.displayLargeFontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: SemanticTypography.displayLargeLetterSpacing,
        height: SemanticTypography.displayLargeLineHeight / SemanticTypography.displayLargeFontSize,
        color: colors.textPrimary,
      ),
      headlineLarge: TextStyle(
        fontFamily: SemanticTypography.headingH1FontFamily,
        fontSize: SemanticTypography.headingH1FontSize,
        fontWeight: FontWeight.values[SemanticTypography.headingH1FontWeight ~/ 100 - 1],
        letterSpacing: SemanticTypography.headingH1LetterSpacing,
        height: SemanticTypography.headingH1LineHeight / SemanticTypography.headingH1FontSize,
        color: colors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontFamily: SemanticTypography.headingH2FontFamily,
        fontSize: SemanticTypography.headingH2FontSize,
        fontWeight: FontWeight.values[SemanticTypography.headingH2FontWeight ~/ 100 - 1],
        letterSpacing: SemanticTypography.headingH2LetterSpacing,
        height: SemanticTypography.headingH2LineHeight / SemanticTypography.headingH2FontSize,
        color: colors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontFamily: SemanticTypography.headingH3FontFamily,
        fontSize: SemanticTypography.headingH3FontSize,
        fontWeight: FontWeight.values[SemanticTypography.headingH3FontWeight ~/ 100 - 1],
        letterSpacing: SemanticTypography.headingH3LetterSpacing,
        height: SemanticTypography.headingH3LineHeight / SemanticTypography.headingH3FontSize,
        color: colors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontFamily: SemanticTypography.bodyLargeFontFamily,
        fontSize: SemanticTypography.bodyLargeFontSize,
        fontWeight: FontWeight.values[SemanticTypography.bodyLargeFontWeight ~/ 100 - 1],
        letterSpacing: SemanticTypography.bodyLargeLetterSpacing,
        height: SemanticTypography.bodyLargeLineHeight / SemanticTypography.bodyLargeFontSize,
        color: colors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: SemanticTypography.bodyFontFamily,
        fontSize: SemanticTypography.bodyFontSize,
        fontWeight: FontWeight.values[SemanticTypography.bodyFontWeight ~/ 100 - 1],
        letterSpacing: SemanticTypography.bodyLetterSpacing,
        height: SemanticTypography.bodyLineHeight / SemanticTypography.bodyFontSize,
        color: colors.textPrimary,
      ),
      bodySmall: TextStyle(
        fontFamily: SemanticTypography.bodySmallFontFamily,
        fontSize: SemanticTypography.bodySmallFontSize,
        fontWeight: FontWeight.values[SemanticTypography.bodySmallFontWeight ~/ 100 - 1],
        letterSpacing: SemanticTypography.bodySmallLetterSpacing,
        height: SemanticTypography.bodySmallLineHeight / SemanticTypography.bodySmallFontSize,
        color: colors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontFamily: SemanticTypography.labelFontFamily,
        fontSize: SemanticTypography.labelFontSize,
        fontWeight: FontWeight.values[SemanticTypography.labelFontWeight ~/ 100 - 1],
        letterSpacing: SemanticTypography.labelLetterSpacing,
        color: colors.textPrimary,
      ),
      labelSmall: TextStyle(
        fontFamily: SemanticTypography.captionFontFamily,
        fontSize: SemanticTypography.captionFontSize,
        fontWeight: FontWeight.values[SemanticTypography.captionFontWeight ~/ 100 - 1],
        color: colors.textSecondary,
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme(AppColorScheme colors, bool isDark) {
    return AppBarTheme(
      systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: colors.textPrimary, size: 24),
      actionsIconTheme: IconThemeData(color: colors.textPrimary, size: 24),
      titleTextStyle: TextStyle(
        fontFamily: SemanticTypography.headingH3FontFamily,
        fontSize: SemanticTypography.headingH3FontSize,
        fontWeight: FontWeight.values[SemanticTypography.headingH3FontWeight ~/ 100 - 1],
        color: colors.textPrimary,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButton(AppColorScheme colors, double radius) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: colors.brandPrimary,
        disabledForegroundColor: colors.textDisabled,
        disabledBackgroundColor: colors.borderDefault,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: TextStyle(
          fontFamily: SemanticTypography.buttonFontFamily,
          fontSize: SemanticTypography.buttonFontSize,
          fontWeight: FontWeight.values[SemanticTypography.buttonFontWeight ~/ 100 - 1],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecoration(AppColorScheme colors, double radius) {
    return InputDecorationTheme(
      errorMaxLines: 3,
      prefixIconColor: colors.textSecondary,
      suffixIconColor: colors.textSecondary,
      labelStyle: TextStyle(
        fontFamily: SemanticTypography.bodyFontFamily,
        fontSize: SemanticTypography.bodyFontSize,
        color: colors.textSecondary,
      ),
      hintStyle: TextStyle(
        fontFamily: SemanticTypography.bodyFontFamily,
        fontSize: SemanticTypography.bodyFontSize,
        color: colors.textDisabled,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: colors.borderDefault),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: colors.borderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: colors.borderFocused, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: colors.stateError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: colors.stateError, width: 1.5),
      ),
    );
  }

  static BottomSheetThemeData _buildBottomSheet(AppColorScheme colors, double radius) {
    return BottomSheetThemeData(
      showDragHandle: true,
      backgroundColor: colors.backgroundSurface,
      modalBackgroundColor: colors.backgroundSurface,
      constraints: const BoxConstraints(minWidth: double.infinity),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius * 1.5)),
      ),
    );
  }

  static ChipThemeData _buildChip(AppColorScheme colors) {
    return ChipThemeData(
      disabledColor: colors.textDisabled.withValues(alpha: 0.3),
      labelStyle: TextStyle(color: colors.textPrimary),
      selectedColor: colors.brandPrimary,
      padding: const EdgeInsets.symmetric(vertical: SemanticSpacing.chipPadding, horizontal: SemanticSpacing.chipPadding),
      checkmarkColor: Colors.white,
    );
  }

  static CheckboxThemeData _buildCheckbox(AppColorScheme colors) {
    return CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      checkColor: WidgetStateProperty.resolveWith((_) => Colors.white),
      fillColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? colors.brandPrimary : Colors.transparent;
      }),
    );
  }
}