import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

class LoginPageStyler {
  // BoxStylers
  static BoxStyler onboardingBg() => BoxStyler()
      .color(Color(0xFFF5FFFF))
      .paddingX(17.5)
      .onDark(BoxStyler().color(const Color(0xFF0D0D0D)));

  // TextStylers
  static TextStyler textStyle({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.bold,
  }) =>
      TextStyler().fontSize(fontSize).fontWeight(fontWeight);


  // TextButtonStylers
  static ButtonStyle textButtonStyle() => TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
}



// In styles.dart — add alongside LoginPageStyler
extension AuthThemeX on BuildContext {
  Color get authOnSurface => Theme.of(this).colorScheme.onSurface;
  Color get authSurface    => Theme.of(this).colorScheme.surface;
  Color get authOutline    => Theme.of(this).colorScheme.outline;
  bool  get authIsDark     => Theme.of(this).brightness == Brightness.dark;
}