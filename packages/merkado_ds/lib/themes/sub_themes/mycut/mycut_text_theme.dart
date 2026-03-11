// AUTO-GENERATED — update when Figma typography tokens change.
// Last updated: 2026-03-04
// Font strategy: Cormorant Garamond (display/body) + DM Sans (UI chrome)
//
// MyCut uses a two-font system:
//   • Cormorant Garamond — all editorial text: greetings, deal titles,
//     financial figures, body copy.  High-contrast old-style serif.
//   • DM Sans          — all UI chrome: caps labels, badges, timestamps,
//     navigation, metadata, tab labels.  Neutral, legible at 10–12 px.
//
// Weight note: Cormorant Garamond has extreme stroke contrast.
// At sizes ≤ 13 px use w600 minimum so the thin strokes don't disappear.
// At display sizes (≥ 24 px) w300–w400 is more elegant and matches the design.
//
// Required font assets in merkado_ds/fonts/ (and re-declared in mycut/pubspec.yaml):
//   CormorantGaramond-Light.ttf         (w300)
//   CormorantGaramond-Regular.ttf       (w400)
//   CormorantGaramond-Medium.ttf        (w500)
//   CormorantGaramond-SemiBold.ttf      (w600)
//   CormorantGaramond-Bold.ttf          (w700)
//   CormorantGaramond-LightItalic.ttf   (w300 italic)
//   CormorantGaramond-Italic.ttf        (w400 italic)
//   DMSans-Regular.ttf                  (w400)
//   DMSans-Medium.ttf                   (w500)
//   DMSans-SemiBold.ttf                 (w600)

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Font family constants
// ─────────────────────────────────────────────────────────────────────────────

/// Serif — editorial text, deal titles, greeting, financial figures.
const String kMycutSerif = 'CormorantGaramond';

/// Sans-serif — UI chrome: caps labels, badges, timestamps, nav, metadata.
const String kMycutSans = 'InstrumentSans';

// ─────────────────────────────────────────────────────────────────────────────
// MycutTextTheme
// ─────────────────────────────────────────────────────────────────────────────

/// MyCut's full [TextTheme] mapping — both light and dark variants.
///
/// Plug this directly into [MerkadoThemeBuilder] via [MerkadoThemeConfig]:
/// ```dart
/// config: MerkadoThemeConfig(
///   colors: AppColorScheme.fromMycut(isDark: false),
///   textThemeOverride: MycutTextTheme.light,
/// )
/// ```
abstract final class MycutTextTheme {
  MycutTextTheme._();

  // ── Light ──────────────────────────────────────────────────────────────────

  static TextTheme light = _build(
    primary: const Color(0xFF1A1F2E),    // MycutLightColors.textPrimary
    secondary: const Color(0xFF6B7280),  // muted — section labels, previews
    disabled: const Color(0xFFB0B7C3),   // timestamps, inactive
    accent: const Color(0xFFB08D57),     // gold — "YOUR CUT" figures
  );

  // ── Dark ───────────────────────────────────────────────────────────────────

  static TextTheme dark = _build(
    primary: const Color(0xFFF5F5F0),
    secondary: const Color(0xFFB0B7C3),
    disabled: const Color(0xFF6B7280),
    accent: const Color(0xFFB08D57),
  );

  // ── Builder ────────────────────────────────────────────────────────────────

  static TextTheme _build({
    required Color primary,
    required Color secondary,
    required Color disabled,
    required Color accent,
  }) {
    return TextTheme(
      // ── Display ─────────────────────────────────────────────────────────
      //
      // "Good morning, Drew."  — greeting hero text
      // "₦62M"                 — portfolio value hero
      //
      // Cormorant Garamond shines at this size. Light weight keeps it
      // elegant and matches the editorial tone visible in the design.
      displayLarge: TextStyle(
        fontFamily: kMycutSerif,
        fontSize: 36,
        fontWeight: FontWeight.w300,    // Light — maximum elegance at large sizes
        letterSpacing: -0.5,
        height: 1.15,
        color: primary,
      ),

      // "₦62M" portfolio figure — slightly more presence than the greeting
      displayMedium: TextStyle(
        fontFamily: kMycutSerif,
        fontSize: 30,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.2,
        color: primary,
      ),

      // "Good morning, Drew." — as used in the design (~28 px)
      displaySmall: TextStyle(
        fontFamily: kMycutSerif,
        fontSize: 28,
        fontWeight: FontWeight.w400,    // Regular — readable without feeling heavy
        letterSpacing: -0.25,
        height: 1.25,
        color: primary,
      ),

      // ── Headline ────────────────────────────────────────────────────────
      //
      // Stat numbers: "7" (active deals), "14" (partners), "+24%" (avg return)
      headlineLarge: TextStyle(
        fontFamily: kMycutSerif,
        fontSize: 24,
        fontWeight: FontWeight.w500,    // Medium — numbers need more weight than text
        letterSpacing: -0.2,
        height: 1.25,
        color: primary,
      ),

      // Contract card title (inbox): "Samsung & LG Import Q1" — list headline
      headlineMedium: TextStyle(
        fontFamily: kMycutSerif,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.15,
        height: 1.3,
        color: primary,
      ),

      // Section card title: "Samsung & LG Appliances — Bulk Import Q1"
      headlineSmall: TextStyle(
        fontFamily: kMycutSerif,
        fontSize: 17,
        fontWeight: FontWeight.w600,    // SemiBold — card title needs to anchor the card
        letterSpacing: -0.1,
        height: 1.35,
        color: primary,
      ),

      // ── Title ────────────────────────────────────────────────────────────
      //
      // Quick action primary label: "New Deal", "Browse Feed", "Wallet"
      titleLarge: TextStyle(
        fontFamily: kMycutSerif,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.35,
        color: primary,
      ),

      // Inbox thread name: "Samsung & LG Import Q1" (the bold title in list)
      titleMedium: TextStyle(
        fontFamily: kMycutSerif,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: primary,
      ),

      // Activity row title: "Deal confirmed — Distribution complete"
      titleSmall: TextStyle(
        fontFamily: kMycutSerif,
        fontSize: 14,
        fontWeight: FontWeight.w600,    // SemiBold — holds up at this size for Cormorant
        letterSpacing: 0,
        height: 1.4,
        color: primary,
      ),

      // ── Body ─────────────────────────────────────────────────────────────
      //
      // Financial figures: "₦24,000,000" (deal value), "₦127,350 available"
      bodyLarge: TextStyle(
        fontFamily: kMycutSerif,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.45,
        color: primary,
      ),

      // Inbox message preview: "Adaeze: I've reviewed version 1.1..."
      // Activity subtitle: "Cassava Export · Ogun State"
      bodyMedium: TextStyle(
        fontFamily: kMycutSerif,
        fontSize: 13,
        fontWeight: FontWeight.w500,    // w500 — Cormorant needs this at 13 px to stay legible
        letterSpacing: 0.1,
        height: 1.5,
        color: secondary,
      ),

      // Quick action subtitle: "Create contract", "Discover deals"
      // "+₦4.2M this month", "3 contracts need attention"
      bodySmall: TextStyle(
        fontFamily: kMycutSerif,
        fontSize: 12,
        fontWeight: FontWeight.w600,    // w600 minimum at 12 px for Cormorant's thin strokes
        letterSpacing: 0.1,
        height: 1.5,
        color: secondary,
      ),

      // ── Label ────────────────────────────────────────────────────────────
      //
      // ALL LABELS SWITCH TO DM SANS — these are pure UI chrome:
      // "PORTFOLIO VALUE", "ACTIVE DEALS", "QUICK ACTIONS", "RECENT ACTIVITY"
      // "DEAL VALUE", "YOUR CUT", "Confirmation Progress"
      // "ACTIVE", "PENDING", "CONFIRMATION" badges
      // "2m ago", "1h ago", "Mar 1" timestamps
      // "3 participants", "Deal #12345"
      // Nav bar labels: "Dashboard", "Contracts", "Inbox", "Wallet", "Profile"
      //
      // DM Sans at 10–12 px is clean and legible where Cormorant would struggle.
      labelLarge: TextStyle(
        fontFamily: kMycutSans,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.4,
        color: primary,
      ),

      // Tabs and sub-labels: "Deal Threads", "Notifications", "Archived"
      // "All (7)", "Active (4)", "Pending (2)", "Executed (1)"
      labelMedium: TextStyle(
        fontFamily: kMycutSans,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.4,
        color: secondary,
      ),

      // Caps micro-labels: "PORTFOLIO VALUE", "ACTIVE DEALS", "YOUR CUT"
      // Status badges: "ACTIVE", "PENDING", "HELD"
      // Timestamps: "2m ago", "Mar 1", "10:02 AM"
      // Navigation: "Dashboard", "Contracts", "Inbox"
      labelSmall: TextStyle(
        fontFamily: kMycutSans,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,             // Wide tracking for caps labels
        height: 1.4,
        color: disabled,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MycutTextStyles — named semantic shortcuts
// ─────────────────────────────────────────────────────────────────────────────
//
// Use these named styles in widgets instead of raw TextTheme lookups.
// They communicate intent and make it easy to update one place.
//
// Usage:
//   Text('Good morning, Drew.', style: MycutTextStyles.greeting(context))
//   Text('₦62M', style: MycutTextStyles.portfolioValue(context))
//   Text('PORTFOLIO VALUE', style: MycutTextStyles.capsLabel(context))

abstract final class MycutTextStyles {
  MycutTextStyles._();

  // ── Greeting / hero ───────────────────────────────────────────────────────

  /// "Good morning, Drew." — hero greeting on dashboard.
  static TextStyle greeting(BuildContext context) =>
      Theme.of(context).textTheme.displaySmall!;

  /// "₦62M" — portfolio value hero figure.
  static TextStyle portfolioHero(BuildContext context) =>
      Theme.of(context).textTheme.displayMedium!;

  // ── Stats bar ─────────────────────────────────────────────────────────────

  /// "7", "14", "+24%" — stat numbers in the dashboard stats bar.
  static TextStyle statNumber(BuildContext context) =>
      Theme.of(context).textTheme.headlineLarge!;

  // ── Contract cards ────────────────────────────────────────────────────────

  /// "Samsung & LG Appliances — Bulk Import Q1" — contract card title.
  static TextStyle contractTitle(BuildContext context) =>
      Theme.of(context).textTheme.headlineSmall!;

  /// "₦24,000,000" — deal value figure in contract cards.
  static TextStyle dealValue(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!;

  /// "₦15,000,000" — "YOUR CUT" figure — gold accent colour applied at call-site.
  static TextStyle yourCut(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: const Color(0xFFB08D57),   // MycutLightColors.accentGold
        fontWeight: FontWeight.w600,
      );

  /// "Confirmation Progress", "2 of 3" — progress metadata.
  static TextStyle progressMeta(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium!;

  // ── Inbox / threads ───────────────────────────────────────────────────────

  /// "Samsung & LG Import Q1" — thread list title (bold).
  static TextStyle threadTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!;

  /// "Adaeze: I've reviewed..." — message preview line.
  static TextStyle messagePreview(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!;

  // ── Activity feed ─────────────────────────────────────────────────────────

  /// "Deal confirmed — Distribution complete" — activity row title.
  static TextStyle activityTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall!;

  /// "Cassava Export · Ogun State" — activity row subtitle.
  static TextStyle activitySubtitle(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!;

  // ── Quick actions ─────────────────────────────────────────────────────────

  /// "New Deal", "Browse Feed" — quick action card primary label.
  static TextStyle actionTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!;

  /// "Create contract", "Discover deals" — quick action card subtitle.
  static TextStyle actionSubtitle(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!;

  // ── Labels & chrome (DM Sans) ─────────────────────────────────────────────

  /// "PORTFOLIO VALUE", "ACTIVE DEALS", "YOUR CUT", "DEAL VALUE"
  /// — uppercase section and field labels.
  static TextStyle capsLabel(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!.copyWith(
        letterSpacing: 1.0,
        fontWeight: FontWeight.w600,
      );

  /// "ACTIVE", "PENDING", "HELD", "REVIEW" — status badge text.
  static TextStyle statusBadge(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!.copyWith(
        letterSpacing: 0.8,
        fontWeight: FontWeight.w700,
      );

  /// "2m ago", "1h ago", "Mar 1", "10:02 AM" — all timestamps.
  static TextStyle timestamp(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!;

  /// "3 participants", "Deal #12345 · Active" — thread/deal metadata.
  static TextStyle metadata(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium!;

  /// "Dashboard", "Contracts", "Inbox" — bottom navigation labels.
  static TextStyle navLabel(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium!.copyWith(
        fontSize: 10,
        letterSpacing: 0.1,
      );

  // ── Tabs ──────────────────────────────────────────────────────────────────

  /// "Deal Threads", "Notifications", "Archived" — tab labels.
  static TextStyle tabLabel(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge!;

  // ── Chat / poll (in-deal thread) ──────────────────────────────────────────

  /// "Looking good. When does the supplier..." — chat bubble body.
  static TextStyle chatBody(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!;

  /// "POLL · 2 VOTES" — poll header meta line (DM Sans).
  static TextStyle pollMeta(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!.copyWith(letterSpacing: 1.0);

  /// "When should we set the final delivery deadline?" — poll question.
  static TextStyle pollQuestion(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall!;

  /// "March 15, 2026" — poll option text.
  static TextStyle pollOption(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!;
}

// ─────────────────────────────────────────────────────────────────────────────
// pubspec.yaml font declarations
// ─────────────────────────────────────────────────────────────────────────────
//
// Declare in BOTH merkado_ds/pubspec.yaml AND mycut/pubspec.yaml.
// (Flutter does not inherit font assets from packages automatically.)
//
// merkado_ds/pubspec.yaml:
//
// flutter:
//   fonts:
//     - family: CormorantGaramond
//       fonts:
//         - asset: fonts/CormorantGaramond-Light.ttf
//           weight: 300
//         - asset: fonts/CormorantGaramond-LightItalic.ttf
//           weight: 300
//           style: italic
//         - asset: fonts/CormorantGaramond-Regular.ttf
//           weight: 400
//         - asset: fonts/CormorantGaramond-Italic.ttf
//           weight: 400
//           style: italic
//         - asset: fonts/CormorantGaramond-Medium.ttf
//           weight: 500
//         - asset: fonts/CormorantGaramond-SemiBold.ttf
//           weight: 600
//         - asset: fonts/CormorantGaramond-Bold.ttf
//           weight: 700
//     - family: DMSans
//       fonts:
//         - asset: fonts/DMSans-Regular.ttf
//           weight: 400
//         - asset: fonts/DMSans-Medium.ttf
//           weight: 500
//         - asset: fonts/DMSans-SemiBold.ttf
//           weight: 600
//
// mycut/pubspec.yaml  (re-declare with packages/ prefix):
//
// flutter:
//   fonts:
//     - family: CormorantGaramond
//       fonts:
//         - asset: packages/merkado_ds/fonts/CormorantGaramond-Light.ttf
//           weight: 300
//         - asset: packages/merkado_ds/fonts/CormorantGaramond-LightItalic.ttf
//           weight: 300
//           style: italic
//         - asset: packages/merkado_ds/fonts/CormorantGaramond-Regular.ttf
//           weight: 400
//         - asset: packages/merkado_ds/fonts/CormorantGaramond-Italic.ttf
//           weight: 400
//           style: italic
//         - asset: packages/merkado_ds/fonts/CormorantGaramond-Medium.ttf
//           weight: 500
//         - asset: packages/merkado_ds/fonts/CormorantGaramond-SemiBold.ttf
//           weight: 600
//         - asset: packages/merkado_ds/fonts/CormorantGaramond-Bold.ttf
//           weight: 700
//     - family: DMSans
//       fonts:
//         - asset: packages/merkado_ds/fonts/DMSans-Regular.ttf
//           weight: 400
//         - asset: packages/merkado_ds/fonts/DMSans-Medium.ttf
//           weight: 500
//         - asset: packages/merkado_ds/fonts/DMSans-SemiBold.ttf
//           weight: 600