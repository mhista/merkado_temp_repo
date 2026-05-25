// // merkado_auth/lib/src/features/auth/presentation/screens/auth_theme_x.dart

// import 'package:flutter/material.dart';

// // MyCutColors is part of merkado_ds which merkado_auth already depends on.
// // The host app (MyCut) seeds AuthShell's Theme with a full MycutTheme,
// // so Theme.of(context).extension<MyCutColors>() is always non-null there.
// import 'package:merkado_ds/merkado_ds.dart';

// extension AuthThemeX on BuildContext {
//   // ── Safe accessor ────────────────────────────────────────────────────────
//   // Falls back to a plain light-mode MyCutColors if the extension is missing
//   // (e.g. unit tests or apps that haven't seeded a MycutTheme).
//   MyCutColors get _c =>
//       Theme.of(this).extension<MyCutColors>() ?? MyCutColors.light;

//   // ── Surfaces ──────────────────────────────────────────────────────────────
//   Color get authScaffold   => _c.scaffold;
//   Color get authSurface    => _c.cardSurface;
//   Color get authElevated   => _c.elevated;
//   Color get authInputBorder => _c.inputBorder;
//   Color get authDivider    => _c.divider;

//   // ── Text ──────────────────────────────────────────────────────────────────
//   Color get authOnSurface  => _c.textPrimary;
//   Color get authSubtitle   => _c.textSecondary;
//   Color get authHint       => _c.textDisabled;
//   Color get authGold       => _c.textAccent;

//   // ── Brand ─────────────────────────────────────────────────────────────────
//   Color get authBrand      => _c.brandPrimary;
//   Color get authAccent     => _c.brandAccent;

//   // ── Status ────────────────────────────────────────────────────────────────
//   Color get authError      => _c.error;
//   Color get authSuccess    => _c.success;

//   // ── Utility ───────────────────────────────────────────────────────────────
//   bool  get authIsDark     =>
//       Theme.of(this).brightness == Brightness.dark;
// }