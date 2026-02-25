// merkado_ds/theme/merkado_theme_config.dart

import 'package:flutter/material.dart';

import '../tokens/semantic/colors/app_color_scheme.dart';

class MerkadoThemeConfig {
  /// The app's resolved color scheme (light or dark variant).
  final AppColorScheme colors;

  /// Override the default font family (defaults to Inter or whatever your primitives define).
  final String? fontFamilyOverride;

  /// Border radius override — some apps may want rounder or squarer corners.
  final double borderRadius;

  /// Sub-theme overrides — pass null to use the default, pass a value to replace.
  /// This is your "plug in / remove parts" mechanism.
  final AppBarTheme? appBarThemeOverride;
  final ElevatedButtonThemeData? elevatedButtonOverride;
  final InputDecorationTheme? inputDecorationOverride;
  final BottomSheetThemeData? bottomSheetOverride;
  final ChipThemeData? chipOverride;
  final CheckboxThemeData? checkboxOverride;

  const MerkadoThemeConfig({
    required this.colors,
    this.fontFamilyOverride,
    this.borderRadius = 12.0,
    this.appBarThemeOverride,
    this.elevatedButtonOverride,
    this.inputDecorationOverride,
    this.bottomSheetOverride,
    this.chipOverride,
    this.checkboxOverride,
  });
}