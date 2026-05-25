
import 'package:flutter/material.dart';

class LoginPageStyler {
  // TextStyles
  static TextStyle textStyle({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.bold,
  }) =>
      TextStyle(fontSize: fontSize, fontWeight: fontWeight);


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
