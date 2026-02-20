// AUTO-GENERATED - DO NOT EDIT MANUALLY
// Generated from Merkado Design System Figma variables
// Last updated: 2026-02-20 00:35:40
// Category: Effects

import 'dart:ui';
import 'package:flutter/painting.dart';

/// Tier 1: Primitive Effect Tokens
/// DROP_SHADOW → BoxShadow  |  INNER_SHADOW → see comments (no native Flutter type)
class PrimitiveEffects {
  PrimitiveEffects._();

  // ── Effects ────────────────────────────────────────────

  // Inner showdow effect
  // INNER_SHADOW innerShowdowEffectInner:
  //   color: Color(0x1AF5FFFF)
  //   offset: Offset(0, 8.8)
  //   blurRadius: 2.93
  //   Implement via CustomPainter or a clip + container decoration.

  // boxShadow/default
  static const List<BoxShadow> boxShadowDefault = [
    BoxShadow(
      color: Color(0x33000000),
      offset: Offset(4, 4),
      blurRadius: 5,
      spreadRadius: 6,
    ),
    BoxShadow(
      color: Color(0x26000000),
      offset: Offset(5, 5),
      blurRadius: 5,
      spreadRadius: 3,
    ),
  ];

}
