import 'package:flutter/material.dart';
import 'package:merkado_ds/merkado_ds.dart';
import 'mycut_text_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MycutTheme
// ─────────────────────────────────────────────────────────────────────────────
//
// The ONLY file MyCut writes for its theme.
// Everything else is handled by MerkadoThemeBuilder in the shared package.
//
// Font change log:
//   v1   Inter (body + display, single font)
//   v2   Cormorant Garamond (display/editorial) + DM Sans (UI chrome)
//        → textThemeOverride: MycutTextTheme.light / .dark

abstract final class MycutTheme {
  MycutTheme._();

  static ThemeData get light => MerkadoThemeBuilder.build(
        isDark: false,
        config: MerkadoThemeConfig(
          colors: AppColorScheme.fromMycut(isDark: false),

          // ── Typography ───────────────────────────────────────────────────
          // Switch from the default Inter to Cormorant Garamond + DM Sans.
          // The base fontFamily drives any TextStyle that doesn't specify
          // its own fontFamily — set to the serif so un-themed text
          // defaults to Cormorant Garamond rather than the system font.
          fontFamilyOverride: kMycutSerif,
          textThemeOverride: MycutTextTheme.light,

          // All other sub-themes (appBar, buttons, inputs, chips…) use
          // MerkadoThemeBuilder defaults, which already read from
          // AppColorScheme — no overrides needed here.
        ),
      );

  static ThemeData get dark => light;
  
  //  MerkadoThemeBuilder.build(
  //       isDark: true,
  //       config: MerkadoThemeConfig(
  //         colors: AppColorScheme.fromMycut(isDark: true),
  //         fontFamilyOverride: kMycutSerif,
  //         textThemeOverride: MycutTextTheme.dark,
  //       ),
  //     );
}