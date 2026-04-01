// merkado_ds/theme/merkado_theme_config.dart

import 'package:flutter/material.dart';

import '../tokens/semantic/colors/app_color_scheme.dart';

class MerkadoThemeConfig {
  /// The app's resolved color scheme (light or dark variant).
  final AppColorScheme colors;

  /// Override the default font family (defaults to Inter or whatever your primitives define).
  final String? fontFamilyOverride;

  /// Border radius override per component theme — some apps may want rounder or squarer corners.
  final double buttonBorderRadius;
  final double inputBorderRadius;
  final double bottomSheetBorderRadius;
  final double checkBoxBorderRadius;


  /// Sub-theme overrides — pass null to use the default, pass a value to replace.
  /// This is your "plug in / remove parts" mechanism.
  final AppBarTheme? appBarThemeOverride;
  final ElevatedButtonThemeData? elevatedButtonOverride;
  final OutlinedButtonThemeData? outlinedButtonOverride;
  final InputDecorationTheme? inputDecorationOverride;
  final BottomSheetThemeData? bottomSheetOverride;
  final ChipThemeData? chipOverride;
  final CheckboxThemeData? checkboxOverride;
  final TextTheme? textThemeOverride;
  final Color? scaffoldBackgroundColor;

  MerkadoThemeConfig({
    required this.colors,
    this.fontFamilyOverride,
    this.buttonBorderRadius = 999.0,
    this.inputBorderRadius = 12.0,
    this.bottomSheetBorderRadius = 16.0,
    this.checkBoxBorderRadius = 4.0,
    this.appBarThemeOverride,
    this.elevatedButtonOverride,
    this.outlinedButtonOverride,
    this.inputDecorationOverride,
    this.bottomSheetOverride,
    this.chipOverride,
    this.checkboxOverride,
    this.textThemeOverride,
    this.scaffoldBackgroundColor,
  });
}