#!/usr/bin/env node

/**
 * Merkado Design System — Variables Transformer
 *
 * Reads a Figma variables export (variables.json) and generates:
 *   lib/tokens/primitives/   → colors, typography, spacing, radii, effects
 *   lib/tokens/semantic/     → per-app color semantics, typography, spacing
 *   lib/tokens/tokens.dart   → barrel export
 *
 * Script: packages/merkado_design_system/script/transform_variables.js
 *
 * EXTENSIBILITY
 * ─────────────
 * This script is designed to be extended without touching core logic.
 * To add support for a new Figma variable type (e.g. gradient):
 *   1. Add a builder function: buildPrimitive<Type>() and buildSemantic<Type>()
 *   2. Register it in VARIABLE_HANDLERS at the bottom of the config section
 *   3. Add the collection to INCLUDED_COLLECTIONS
 *
 * Currently handles: color, typography, number (spacing/radii), effect
 * Ready for: gradient (stub included), boolean, dimension
 */

const fs   = require("fs");
const path = require("path");

// ═══════════════════════════════════════════════════════════════════════════════
// CONFIGURATION — edit this section to control the transformer
// ═══════════════════════════════════════════════════════════════════════════════

const SCRIPT_DIR   = __dirname;
const PACKAGE_ROOT = path.resolve(SCRIPT_DIR, "..");

const CONFIG = {
  inputFile:  path.join(PACKAGE_ROOT, "figma_tokens", "variables.json"),
  primDir:    path.join(PACKAGE_ROOT, "lib", "tokens", "primitives"),
  semDir:     path.join(PACKAGE_ROOT, "lib", "tokens", "semantic"),
  barrelFile: path.join(PACKAGE_ROOT, "lib", "tokens", "tokens.dart"),
  timestamp:  new Date().toISOString().replace("T", " ").split(".")[0],
};

// Collections to process. Add/remove entries freely.
// Exact string = exact match. /regex/ = pattern match.
// To include core, uncomment that line.
const INCLUDED_COLLECTIONS = [
  "Driply/theme/light",
  "Driply/theme/dark",
  "Mycut/theme/light",
  "Driply/typography/mobile",
  "Driply/typography/desktop",
  "Typography",
  "Spacing",
  "Corner_radius",
  "Effects",
  // "core",
];

// These are always excluded even if they match INCLUDED_COLLECTIONS above.
// Use this for legacy / duplicate collections from old token sets.
const EXCLUDED_COLLECTIONS = [
  /^Driply\/Light theme values/,
  /^Driply\/Dark theme values/,
  /^Mycut\/light theme values/,
  /^Driply Typography\//,
];

// Namespace prefix per collection (used on primitive constant names).
// Collections not listed here get a prefix derived from their name.
const COLLECTION_NAMESPACE = {
  "Driply/theme/light":  "driply",
  "Driply/theme/dark":   "driplyDark",
  "Mycut/theme/light":   "mycut",
  "Typography":          "",
  "Spacing":             "",
  "Corner_radius":       "",
  "Effects":             "",
};

// ═══════════════════════════════════════════════════════════════════════════════
// SEMANTIC INFERENCE RULES
// ═══════════════════════════════════════════════════════════════════════════════

// Color semantic rules — matched against the "leaf" name (path and brand prefix stripped).
// Order matters: first match wins. Add rules here to cover new token naming patterns.
const COLOR_SEMANTIC_RULES = [
  // Background
  { pat: /primary.?bg|bg.?primary|background.?primary|primay.?bg/i, cat: "background", token: "primary"    },
  { pat: /bg.?surface|surface/i,                                     cat: "background", token: "surface"   },
  { pat: /bg.?secondary|background.?secondary/i,                     cat: "background", token: "secondary" },
  // Text
  { pat: /^text.?primary$|^primary.?text$/i,                         cat: "text",       token: "primary"   },
  { pat: /^text.?secondary$|^secondary.?text$/i,                     cat: "text",       token: "secondary" },
  { pat: /text.?inverse|inverse.?text/i,                             cat: "text",       token: "inverse"   },
  { pat: /text.?muted|muted.?text/i,                                 cat: "text",       token: "muted"     },
  // Border
  { pat: /border.?default|^border$/i,                                cat: "border",     token: "default"   },
  { pat: /border.?secondary/i,                                       cat: "border",     token: "secondary" },
  // Brand
  { pat: /primary.?color|brand.?primary|^primary$/i,                 cat: "brand",      token: "primary"   },
  { pat: /support.?color|brand.?secondary/i,                         cat: "brand",      token: "secondary" },
  { pat: /logo/i,                                                    cat: "brand",      token: "logo"      },
  // States
  { pat: /success|commerce.?success/i,                               cat: "state",      token: "success"   },
  { pat: /energy.?accent|^warning$/i,                                cat: "state",      token: "warning"   },
  { pat: /pending.?red|^error$|^danger$/i,                           cat: "state",      token: "error"     },
  { pat: /pending.?yellow/i,                                         cat: "state",      token: "pending"   },
  { pat: /negotiat/i,                                                cat: "state",      token: "negotiating"},
  { pat: /complet/i,                                                 cat: "state",      token: "completed" },
  { pat: /^draft/i,                                                  cat: "state",      token: "draft"     },
  { pat: /inactive/i,                                                cat: "state",      token: "inactive"  },
  // Accent
  { pat: /accent.?green|green.?accent/i,                             cat: "accent",     token: "green"     },
  { pat: /blue.?accent|accent.?blue/i,                               cat: "accent",     token: "blue"      },
  { pat: /white.?accent|accent.?white/i,                             cat: "accent",     token: "white"     },
  // Surface
  { pat: /container/i,                                               cat: "surface",    token: "container" },
];

// Semantic spacing intents — mapped by scale key (xs, sm, md ...)
const SPACING_SEMANTIC_INTENTS = {
  xs:   ["iconGap", "chipPadding"],
  sm:   ["inputPaddingV", "listItemGap"],
  md:   ["cardPadding", "sectionGap"],
  lg:   ["pagePaddingH", "sectionPaddingV"],
  xl:   ["pageSection"],
  xxl:  ["heroSection"],
};

// Typography semantic rules — matched against style name, picks canonical weight variant
const TYPO_SEMANTIC_RULES = [
  { pat: /^display.?large|^Disply.?large/i, sem: "displayLarge", preferWeight: "semibold" },
  { pat: /^H1\b/i,                          sem: "headingH1",    preferWeight: "semibold" },
  { pat: /^H2\b/i,                          sem: "headingH2",    preferWeight: "semibold" },
  { pat: /^H3\b/i,                          sem: "headingH3",    preferWeight: "semibold" },
  { pat: /^Body.?large/i,                   sem: "bodyLarge",    preferWeight: "regular"  },
  { pat: /^Body\s*sm/i,                     sem: "bodySmall",    preferWeight: "regular"  },
  { pat: /^Body\b/i,                        sem: "body",         preferWeight: "regular"  },
  { pat: /^Button/i,                        sem: "button",       preferWeight: "semibold" },
  { pat: /^Label/i,                         sem: "label",        preferWeight: "medium"   },
  { pat: /^Nav\b/i,                         sem: "nav",          preferWeight: "medium"   },
  { pat: /^meta/i,                          sem: "meta",         preferWeight: "regular"  },
  { pat: /^caption/i,                       sem: "caption",      preferWeight: "regular"  },
  { pat: /^overline/i,                      sem: "overline",     preferWeight: "regular"  },
  { pat: /^Dashboard\/card.?title/i,        sem: "cardTitle",    preferWeight: "semibold" },
  { pat: /^Dashboard\/card.?body/i,         sem: "cardBody",     preferWeight: "regular"  },
  { pat: /^Dashboard\/card.?label/i,        sem: "cardLabel",    preferWeight: "medium"   },
  { pat: /^Dashboard\/metric/i,             sem: "metricValue",  preferWeight: "semibold" },
];

// ═══════════════════════════════════════════════════════════════════════════════
// UTILITIES
// ═══════════════════════════════════════════════════════════════════════════════

function toCamelCase(str) {
  return str
    .replace(/[&()'".]+/g, " ")
    .replace(/[-_\/\s]+(.)?/g, (_, c) => (c ? c.toUpperCase() : ""))
    .replace(/^[A-Z]/, (c) => c.toLowerCase())
    .replace(/[^a-zA-Z0-9]/g, "");
}

function toPascalCase(str) {
  const c = toCamelCase(str);
  return c.charAt(0).toUpperCase() + c.slice(1);
}

function generateHeader(category, imports = ["import 'dart:ui';"]) {
  return `// AUTO-GENERATED - DO NOT EDIT MANUALLY
// Generated from Merkado Design System Figma variables
// Last updated: ${CONFIG.timestamp}
// Category: ${category}

${imports.join("\n")}
`;
}

function writeFile(filePath, content) {
  if (fs.existsSync(filePath)) {
    const strip = (s) => s.replace(/\/\/ Last updated: .+/, "//ts");
    if (strip(fs.readFileSync(filePath, "utf8")) === strip(content)) return "skipped";
  }
  fs.writeFileSync(filePath, content, "utf8");
  return "written";
}

function log(tag, msg) {
  const icons = { ok: "✓", skip: "⏭", warn: "⚠", err: "✗" };
  console.log(`  ${icons[tag] ?? " "} ${msg}`);
}

// ═══════════════════════════════════════════════════════════════════════════════
// COLLECTION FILTERING & LOADING
// ═══════════════════════════════════════════════════════════════════════════════

function isIncluded(name) {
  if (EXCLUDED_COLLECTIONS.some(p => (p instanceof RegExp ? p.test(name) : p === name))) return false;
  return INCLUDED_COLLECTIONS.some(p => (p instanceof RegExp ? p.test(name) : p === name));
}

function load() {
  return Object.values(JSON.parse(fs.readFileSync(CONFIG.inputFile, "utf8")).collections || {});
}

function resolveAlias(aliasValue, allCollections) {
  if (!aliasValue || typeof aliasValue !== "object") return null;
  const col = allCollections.find(c => c.name === aliasValue.collection);
  if (!col) return null;
  for (const mode of Object.values(col.modes)) {
    const found = mode.variables.find(v => v.name === aliasValue.name);
    if (found) return found.isAlias ? resolveAlias(found.value, allCollections) : found.value;
  }
  return null;
}

// ═══════════════════════════════════════════════════════════════════════════════
// NAME CLEANING
// ═══════════════════════════════════════════════════════════════════════════════

/**
 * Returns the human-readable "leaf" of a variable name for semantic inference.
 * Strips path segments and brand prefix so rules can match cleanly.
 *   "color/light/bg/Primary color" → "Primary color"
 *   "text/Text-primary"            → "Text-primary"
 *   "My cut Pending Red"           → "Pending Red"
 */
function leafName(rawName, collectionName) {
  let n = rawName;
  if (collectionName.toLowerCase().includes("mycut")) n = n.replace(/^My\s*[Cc]ut\s*/g, "");
  if (n.includes("/")) n = n.split("/").pop();
  return n.trim();
}

/**
 * Returns a valid Dart camelCase identifier for a variable, with namespace prefix.
 */
function varName(rawName, namespace, collectionName) {
  let n = rawName;
  if (collectionName.toLowerCase().includes("mycut")) n = n.replace(/^My\s*[Cc]ut\s*/g, "");
  n = n.replace(/^color\/[^/]+\/[^/]+\//, "")
       .replace(/^color\/[^/]+\//, "")
       .replace(/^color\//, "")
       .replace(/^Spacing-?/i, "")
       .replace(/^New group\/.*\//, "")
       .replace(/^Fonts\//, "")
       .replace(/^typography\//, "");
  const c = toCamelCase(n);
  return namespace ? toCamelCase(`${namespace}_${n}`) : c;
}

// ═══════════════════════════════════════════════════════════════════════════════
// COLOR HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

function hexToColor(hex) {
  if (!hex || typeof hex !== "string" || hex.startsWith("{") || hex.startsWith("rgba")) return null;
  let c = hex.replace("#", "").trim();
  if (c.length === 6) c = "FF" + c;
  if (c.length !== 8) return null;
  return `Color(0x${c.toUpperCase()})`;
}

// Figma exports effect/shadow colors as {r,g,b,a} where r/g/b are 0-255, a is 0-1
function effectColorToHex({ r, g, b, a }) {
  const av = Math.round((a ?? 1) * 255);
  const rv = Math.round(r ?? 0);
  const gv = Math.round(g ?? 0);
  const bv = Math.round(b ?? 0);
  return [av, rv, gv, bv].map(v => v.toString(16).padStart(2, "0")).join("").toUpperCase();
}

function inferSemanticCategory(leaf) {
  for (const rule of COLOR_SEMANTIC_RULES) {
    if (rule.pat.test(leaf)) return { cat: rule.cat, token: rule.token };
  }
  return null;
}

const WEIGHT_MAP = {
  thin:100, extralight:200, light:300, regular:400, normal:400,
  medium:500, semibold:600, "semi bold":600, bold:700, extrabold:800, black:900,
};
function weightToInt(w) {
  if (!w) return 400;
  const n = parseInt(w);
  if (!isNaN(n)) return n;
  return WEIGHT_MAP[w.toLowerCase().replace(/[-\s]/g, "")] ?? 400;
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRIMITIVE BUILDERS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Colors ───────────────────────────────────────────────────────────────────

function buildPrimitiveColors(collections) {
  let dart = generateHeader("Colors");
  dart += "\n/// Tier 1: Primitive Color Tokens\nclass PrimitiveColors {\n  PrimitiveColors._();\n";

  const colorCols = collections.filter(c =>
    isIncluded(c.name) &&
    Object.values(c.modes).some(m => m.variables.some(v => v.type === "color"))
  );

  for (const col of colorCols) {
    const ns = COLLECTION_NAMESPACE[col.name] ?? toCamelCase(col.name.split("/").pop());
    for (const [, mode] of Object.entries(col.modes)) {
      const colorVars = mode.variables.filter(v => v.type === "color");
      if (!colorVars.length) continue;
      dart += `\n  // ── ${col.name} / ${mode.name} ────────────────────────────────\n`;
      const seen = new Set();
      for (const v of colorVars) {
        const value = v.isAlias ? resolveAlias(v.value, collections) : v.value;
        const dc = hexToColor(value);
        if (!dc) continue;
        const vn = varName(v.name, ns, col.name);
        if (seen.has(vn)) continue;
        seen.add(vn);
        dart += `  static const Color ${vn} = ${dc};\n`;
      }
    }
  }

  dart += "}\n";
  return dart;
}

// ── Typography ───────────────────────────────────────────────────────────────

function buildPrimitiveTypography(collections) {
  let dart = generateHeader("Typography");
  dart += "\n/// Tier 1: Primitive Typography Tokens\nclass PrimitiveTypography {\n  PrimitiveTypography._();\n\n";

  const typoCols = collections.filter(c =>
    isIncluded(c.name) &&
    Object.values(c.modes).some(m => m.variables.some(v => v.type === "typography"))
  );

  for (const col of typoCols) {
    for (const [, mode] of Object.entries(col.modes)) {
      const vars = mode.variables.filter(v => v.type === "typography");
      if (!vars.length) continue;
      dart += `  // ── ${col.name} ────────────────────────────────────────────\n\n`;
      const seen = new Set();
      for (const v of vars) {
        if (!v.value || typeof v.value !== "object") continue;
        const key = toCamelCase(v.name);
        if (seen.has(key)) continue;
        seen.add(key);
        const val = v.value;
        const base = toCamelCase(v.name.replace(/\//g, "_"));
        dart += `  // ${v.name}\n`;
        if (val.fontFamily) dart += `  static const String ${base}FontFamily = '${val.fontFamily}';\n`;
        if (val.fontSize   !== undefined) dart += `  static const double ${base}FontSize = ${val.fontSize};\n`;
        dart += `  static const int ${base}FontWeight = ${weightToInt(val.fontWeight)};\n`;
        if (val.lineHeight !== undefined) {
          const lhUnit = val.lineHeightUnit ?? "PIXELS";
          const lh = lhUnit === "PERCENT" ? parseFloat((val.lineHeight / 100).toFixed(3)) : val.lineHeight;
          dart += `  static const double ${base}LineHeight = ${lh}; // ${lhUnit.toLowerCase()}\n`;
        }
        if (val.letterSpacing !== undefined) dart += `  static const double ${base}LetterSpacing = ${val.letterSpacing};\n`;
        dart += "\n";
      }
    }
  }

  dart += "}\n";
  return dart;
}

// ── Spacing ──────────────────────────────────────────────────────────────────

function buildPrimitiveSpacing(collections) {
  let dart = generateHeader("Spacing");
  dart += "\n/// Tier 1: Primitive Spacing Tokens\nclass PrimitiveSpacing {\n  PrimitiveSpacing._();\n\n";

  const spacingCol = collections.find(c => c.name === "Spacing" && isIncluded(c.name));
  if (spacingCol) {
    dart += "  // Spacing Scale\n";
    for (const v of Object.values(spacingCol.modes)[0].variables) {
      if (v.type !== "number") continue;
      const val = v.isAlias ? resolveAlias(v.value, collections) : v.value;
      const vn  = toCamelCase("spacing_" + v.name.replace(/^Spacing-?/i, ""));
      dart += `  static const double ${vn} = ${val};\n`;
    }
  }

  const coreCol = collections.find(c => c.name === "core" && isIncluded(c.name));
  if (coreCol) {
    const vars = Object.values(coreCol.modes)[0].variables
      .filter(v => v.name.startsWith("spacing/") || v.name.startsWith("dimension/"));
    if (vars.length) {
      dart += "\n  // Core Scale\n";
      for (const v of vars) {
        const val = v.isAlias ? resolveAlias(v.value, collections) : v.value;
        if (val == null) continue;
        dart += `  static const double ${toCamelCase(v.name.replace("/", "_"))} = ${val};\n`;
      }
    }
  }

  dart += "}\n";
  return dart;
}

// ── Radii ────────────────────────────────────────────────────────────────────

function buildPrimitiveRadii(collections) {
  let dart = generateHeader("Border Radius");
  dart += "\n/// Tier 1: Primitive Border Radius Tokens\nclass PrimitiveRadii {\n  PrimitiveRadii._();\n\n";

  const col = collections.find(c => c.name === "Corner_radius" && isIncluded(c.name));
  if (col) {
    for (const v of Object.values(col.modes)[0].variables) {
      if (v.type !== "number") continue;
      dart += `  static const double ${toCamelCase("radius_" + v.name)} = ${v.value};\n`;
    }
  }

  dart += "}\n";
  return dart;
}

// ── Effects ──────────────────────────────────────────────────────────────────
//
// Figma effect types → Flutter equivalents:
//   DROP_SHADOW  → BoxShadow (direct)
//   INNER_SHADOW → No native Flutter type; emitted as a comment with raw values
//                  so the developer can implement via custom painter / clip
//   LAYER_BLUR   → ImageFilter.blur (not a BoxShadow)
//   BACKGROUND_BLUR → BackdropFilter (not a BoxShadow)
//
// Multi-effect tokens emit List<BoxShadow>.
// Non-BoxShadow effects are emitted as descriptive comments with raw values.

function buildPrimitiveEffects(collections) {
  const effectsCols = collections.filter(c =>
    isIncluded(c.name) &&
    Object.values(c.modes).some(m => m.variables.some(v => v.type === "effect"))
  );
  if (!effectsCols.length) return null;

  let dart = generateHeader("Effects", [
    "import 'dart:ui';",
    "import 'package:flutter/painting.dart';",
  ]);
  dart += "\n/// Tier 1: Primitive Effect Tokens\n";
  dart += "/// DROP_SHADOW → BoxShadow  |  INNER_SHADOW → see comments (no native Flutter type)\n";
  dart += "class PrimitiveEffects {\n  PrimitiveEffects._();\n\n";

  for (const col of effectsCols) {
    for (const [, mode] of Object.entries(col.modes)) {
      const vars = mode.variables.filter(v => v.type === "effect");
      if (!vars.length) continue;

      dart += `  // ── ${col.name} ────────────────────────────────────────────\n\n`;

      for (const v of vars) {
        if (!v.value?.effects?.length) continue;
        const ns = COLLECTION_NAMESPACE[col.name] ?? "";
        const vn = varName(v.name, ns, col.name);

        const dropShadows = v.value.effects.filter(e => e.type === "DROP_SHADOW");
        const innerShadows = v.value.effects.filter(e => e.type === "INNER_SHADOW");
        const blurs = v.value.effects.filter(e => e.type === "LAYER_BLUR" || e.type === "BACKGROUND_BLUR");

        dart += `  // ${v.name}\n`;

        // Drop shadows → BoxShadow
        if (dropShadows.length === 1) {
          const s = dropShadows[0];
          dart += `  static const BoxShadow ${vn} = BoxShadow(\n`;
          dart += `    color: Color(0x${effectColorToHex(s.color)}),\n`;
          dart += `    offset: Offset(${s.offset.x}, ${s.offset.y}),\n`;
          dart += `    blurRadius: ${parseFloat(s.radius.toFixed(2))},\n`;
          dart += `    spreadRadius: ${parseFloat((s.spread ?? 0).toFixed(2))},\n`;
          dart += `  );\n`;
        } else if (dropShadows.length > 1) {
          dart += `  static const List<BoxShadow> ${vn} = [\n`;
          for (const s of dropShadows) {
            dart += `    BoxShadow(\n`;
            dart += `      color: Color(0x${effectColorToHex(s.color)}),\n`;
            dart += `      offset: Offset(${s.offset.x}, ${s.offset.y}),\n`;
            dart += `      blurRadius: ${parseFloat(s.radius.toFixed(2))},\n`;
            dart += `      spreadRadius: ${parseFloat((s.spread ?? 0).toFixed(2))},\n`;
            dart += `    ),\n`;
          }
          dart += `  ];\n`;
        }

        // Inner shadows → descriptive comment (Flutter has no inset BoxShadow)
        for (const s of innerShadows) {
          dart += `  // INNER_SHADOW ${vn}Inner:\n`;
          dart += `  //   color: Color(0x${effectColorToHex(s.color)})\n`;
          dart += `  //   offset: Offset(${s.offset.x}, ${parseFloat(s.offset.y.toFixed(2))})\n`;
          dart += `  //   blurRadius: ${parseFloat(s.radius.toFixed(2))}\n`;
          dart += `  //   Implement via CustomPainter or a clip + container decoration.\n`;
        }

        // Blurs → ImageFilter comment
        for (const s of blurs) {
          dart += `  // ${s.type} ${vn}Blur: sigma=${parseFloat(s.radius.toFixed(2))}\n`;
          dart += `  //   Use ImageFilter.blur(sigmaX:${parseFloat(s.radius.toFixed(2))}, sigmaY:${parseFloat(s.radius.toFixed(2))})\n`;
          dart += `  //   Wrap widget with BackdropFilter or ImageFiltered.\n`;
        }

        dart += "\n";
      }
    }
  }

  dart += "}\n";
  return dart;
}

// ── Gradient (stub) ──────────────────────────────────────────────────────────
// Not yet in the variables file but ready to handle when Figma adds gradient support.
// Add "Gradients" to INCLUDED_COLLECTIONS and this will activate automatically.

function buildPrimitiveGradients(collections) {
  const gradientCols = collections.filter(c =>
    isIncluded(c.name) &&
    Object.values(c.modes).some(m => m.variables.some(v => v.type === "gradient"))
  );
  if (!gradientCols.length) return null;

  let dart = generateHeader("Gradients", ["import 'dart:ui';"]);
  dart += "\n/// Tier 1: Primitive Gradient Tokens\nclass PrimitiveGradients {\n  PrimitiveGradients._();\n\n";

  for (const col of gradientCols) {
    for (const [, mode] of Object.entries(col.modes)) {
      const vars = mode.variables.filter(v => v.type === "gradient");
      if (!vars.length) continue;
      dart += `  // ── ${col.name} ────────────────────────────────────────────\n\n`;
      for (const v of vars) {
        const val = v.value;
        if (!val?.stops?.length) continue;
        const ns  = COLLECTION_NAMESPACE[col.name] ?? "";
        const vn  = varName(v.name, ns, col.name);
        const stops = val.stops.map(s => {
          const hex = effectColorToHex(s.color);
          return `ColorStop(Color(0x${hex}), ${parseFloat(s.position.toFixed(3))})`;
        }).join(", ");
        // LinearGradient example — extend for radial/angular as needed
        dart += `  // ${v.name}\n`;
        dart += `  static const LinearGradient ${vn} = LinearGradient(\n`;
        dart += `    colors: [${val.stops.map(s => `Color(0x${effectColorToHex(s.color)})`).join(", ")}],\n`;
        dart += `    stops: [${val.stops.map(s => parseFloat(s.position.toFixed(3))).join(", ")}],\n`;
        dart += `  );\n\n`;
      }
    }
  }

  dart += "}\n";
  return dart;
}

// ═══════════════════════════════════════════════════════════════════════════════
// SEMANTIC BUILDERS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Colors ───────────────────────────────────────────────────────────────────

function buildSemanticColors(collections, primitiveVarNames) {
  const themeCols = collections.filter(c =>
    isIncluded(c.name) &&
    c.name.toLowerCase().includes("theme") &&
    Object.values(c.modes).some(m => m.variables.some(v => v.type === "color"))
  );

  const files = {};

  for (const col of themeCols) {
    const ns     = COLLECTION_NAMESPACE[col.name] ?? toCamelCase(col.name.split("/").pop());
    const parts  = col.name.split("/");
    const app    = parts[0];
    const theme  = parts[2] ?? parts[1];
    const cls    = `${toPascalCase(app)}${toPascalCase(theme)}Colors`;

    const categorized = {};

    for (const [, mode] of Object.entries(col.modes)) {
      // Resolve all color variables, then sort flat names first
      // (so "Primary color" is preferred over "color/light/bg/Primary color" for same hex)
      const resolved = mode.variables
        .filter(v => v.type === "color")
        .map(v => ({
          ...v,
          resolved: v.isAlias ? resolveAlias(v.value, collections) : v.value,
        }))
        .filter(v => v.resolved)
        .sort((a, b) => (a.name.match(/\//g) || []).length - (b.name.match(/\//g) || []).length);

      const seenHex = new Set();

      for (const v of resolved) {
        const hex = v.resolved.toUpperCase();
        if (seenHex.has(hex)) continue; // skip path-duplicate of already-mapped color
        seenHex.add(hex);

        const pn = varName(v.name, ns, col.name);
        if (!primitiveVarNames.has(pn)) continue;

        const leaf = leafName(v.name, col.name);
        const inf  = inferSemanticCategory(leaf);
        if (!inf) continue;

        const { cat, token } = inf;
        if (!categorized[cat]) categorized[cat] = [];
        if (!categorized[cat].find(e => e.token === token)) {
          categorized[cat].push({ token, pn });
        }
      }
    }

    if (!Object.keys(categorized).length) continue;

    let dart = generateHeader(
      `Semantic Colors — ${col.name}`,
      ["import 'dart:ui';", "import '../primitives/colors.dart';"]
    );
    dart += `\n/// Tier 2: Semantic Color Tokens — ${col.name}\n`;
    dart += `/// Auto-generated from primitives. Safe to re-run.\n`;
    dart += `class ${cls} {\n  ${cls}._();\n\n`;

    for (const [cat, entries] of Object.entries(categorized)) {
      dart += `  // ${cat.charAt(0).toUpperCase() + cat.slice(1)}\n`;
      for (const { token, pn } of entries) {
        dart += `  static const Color ${toCamelCase(`${cat}_${token}`)} = PrimitiveColors.${pn};\n`;
      }
      dart += "\n";
    }

    dart += "}\n";
    files[`${toCamelCase(app)}_${theme}_colors.dart`] = { dart, cls };
  }

  return files;
}

// ── Typography ───────────────────────────────────────────────────────────────

function buildSemanticTypography(collections) {
  const col = collections.find(c => c.name === "Typography" && isIncluded(c.name));
  if (!col) return null;

  const vars = Object.values(col.modes)[0].variables.filter(v => v.type === "typography");
  const semMap = {};

  for (const v of vars) {
    for (const rule of TYPO_SEMANTIC_RULES) {
      if (!rule.pat.test(v.name)) continue;
      const existing = semMap[rule.sem];
      const w = (v.value?.fontWeight ?? "").toLowerCase().replace(/[\s-]/g, "");
      const better = !existing || w === rule.preferWeight;
      if (better) semMap[rule.sem] = { name: v.name, value: v.value };
      break;
    }
  }

  if (!Object.keys(semMap).length) return null;

  let dart = generateHeader("Semantic Typography", ["import '../primitives/typography.dart';"]);
  dart += "\n/// Tier 2: Semantic Typography Tokens\n";
  dart += "/// Auto-generated — maps canonical style variants to semantic names.\n";
  dart += "class SemanticTypography {\n  SemanticTypography._();\n\n";

  for (const [sem, { name, value: val }] of Object.entries(semMap)) {
    const base = toCamelCase(name.replace(/\//g, "_"));
    dart += `  // ${sem} — sourced from "${name}"\n`;
    if (val.fontFamily)    dart += `  static const String ${sem}FontFamily = PrimitiveTypography.${base}FontFamily;\n`;
    dart +=                         `  static const double ${sem}FontSize = PrimitiveTypography.${base}FontSize;\n`;
    dart +=                         `  static const int ${sem}FontWeight = PrimitiveTypography.${base}FontWeight;\n`;
    if (val.lineHeight !== undefined) dart += `  static const double ${sem}LineHeight = PrimitiveTypography.${base}LineHeight;\n`;
    if (val.letterSpacing !== undefined) dart += `  static const double ${sem}LetterSpacing = PrimitiveTypography.${base}LetterSpacing;\n`;
    dart += "\n";
  }

  dart += "}\n";
  return dart;
}

// ── Spacing ───────────────────────────────────────────────────────────────────

function buildSemanticSpacing(collections) {
  const col = collections.find(c => c.name === "Spacing" && isIncluded(c.name));
  if (!col) return null;

  let dart = generateHeader("Semantic Spacing", ["import '../primitives/spacing.dart';"]);
  dart += "\n/// Tier 2: Semantic Spacing Tokens\n";
  dart += "/// Named intents mapped from the spacing scale.\n";
  dart += "class SemanticSpacing {\n  SemanticSpacing._();\n\n";

  for (const v of Object.values(col.modes)[0].variables) {
    if (v.type !== "number") continue;
    const scale   = v.name.replace(/^Spacing-?/i, "").toLowerCase();
    const primName = toCamelCase("spacing_" + scale);
    const intents  = SPACING_SEMANTIC_INTENTS[scale];
    dart += `  // ${v.name} = ${v.value}px\n`;
    if (intents) {
      for (const intent of intents) dart += `  static const double ${intent} = PrimitiveSpacing.${primName};\n`;
    } else {
      dart += `  static const double spacing${toPascalCase(scale)} = PrimitiveSpacing.${primName};\n`;
    }
    dart += "\n";
  }

  dart += "}\n";
  return dart;
}

// ── Effects (semantic) ───────────────────────────────────────────────────────

function buildSemanticEffects(collections) {
  const col = collections.find(c => c.name === "Effects" && isIncluded(c.name));
  if (!col) return null;

  const vars = Object.values(col.modes)[0].variables.filter(v => v.type === "effect");
  if (!vars.length) return null;

  let dart = generateHeader("Semantic Effects", [
    "import 'package:flutter/painting.dart';",
    "import '../primitives/effects.dart';",
  ]);
  dart += "\n/// Tier 2: Semantic Effect Tokens\n";
  dart += "/// Maps raw effect tokens to named design intents.\n";
  dart += "class SemanticEffects {\n  SemanticEffects._();\n\n";

  // Infer semantic name from effect variable name
  const EFFECT_INTENTS = [
    { pat: /shadow.*default|default.*shadow/i, sem: "shadowDefault" },
    { pat: /card.*shadow|shadow.*card/i,       sem: "shadowCard"    },
    { pat: /inner.*shadow|inset/i,             sem: "shadowInner"   },
    { pat: /elevation/i,                       sem: "elevation"     },
    { pat: /blur/i,                            sem: "blur"          },
  ];

  for (const v of vars) {
    const ns = COLLECTION_NAMESPACE[col.name] ?? "";
    const pn = varName(v.name, ns, col.name);
    let semName = pn;
    for (const { pat, sem } of EFFECT_INTENTS) {
      if (pat.test(v.name)) { semName = sem; break; }
    }

    const dropShadows = (v.value?.effects ?? []).filter(e => e.type === "DROP_SHADOW");
    if (!dropShadows.length) {
      dart += `  // ${v.name} — no BoxShadow equivalent, see primitives/effects.dart\n\n`;
      continue;
    }

    dart += `  // ${v.name}\n`;
    if (dropShadows.length === 1) {
      dart += `  static const BoxShadow ${semName} = PrimitiveEffects.${pn};\n\n`;
    } else {
      dart += `  static const List<BoxShadow> ${semName} = PrimitiveEffects.${pn};\n\n`;
    }
  }

  dart += "}\n";
  return dart;
}

// ═══════════════════════════════════════════════════════════════════════════════
// BARREL
// ═══════════════════════════════════════════════════════════════════════════════

function buildBarrel(semColorFiles, hasEffects, hasGradients) {
  let s = `// AUTO-GENERATED BARREL - DO NOT EDIT MANUALLY
// Regenerated: ${CONFIG.timestamp}

// ── Primitives ───────────────────────────────────────────────────────────────
export 'primitives/colors.dart';
export 'primitives/typography.dart';
export 'primitives/spacing.dart';
export 'primitives/radii.dart';
`;
  if (hasEffects)   s += `export 'primitives/effects.dart';\n`;
  if (hasGradients) s += `export 'primitives/gradients.dart';\n`;

  s += `
// ── Semantic Layer ───────────────────────────────────────────────────────────
export 'semantic/typography_semantic.dart';
export 'semantic/spacing_semantic.dart';
`;
  if (hasEffects) s += `export 'semantic/effects_semantic.dart';\n`;
  for (const filename of Object.keys(semColorFiles)) {
    s += `export 'semantic/${filename}';\n`;
  }
  return s;
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════════════════════

function main() {
  console.log("Merkado Design System — Variables Transformer\n");

  if (!fs.existsSync(CONFIG.inputFile)) {
    console.error(`ERROR: input file not found:\n  ${CONFIG.inputFile}`);
    process.exit(1);
  }

  console.log("Loading collections...");
  const collections = load();
  const included = collections.filter(c => isIncluded(c.name));
  const skipped  = collections.filter(c => !isIncluded(c.name));

  console.log(`\n  Included (${included.length}):`);
  included.forEach(c => log("ok",   c.name));
  console.log(`\n  Skipped (${skipped.length}):`);
  skipped.forEach(c  => log("skip", c.name));

  [CONFIG.primDir, CONFIG.semDir].forEach(d => {
    if (!fs.existsSync(d)) fs.mkdirSync(d, { recursive: true });
  });

  // ── Primitives ──────────────────────────────────────────────────────────────
  console.log("\nBuilding primitives...");

  const primColors = buildPrimitiveColors(collections);
  const primitiveVarNames = new Set(
    [...primColors.matchAll(/static const \w+ (\w+) =/g)].map(m => m[1])
  );

  const primEffects   = buildPrimitiveEffects(collections);
  const primGradients = buildPrimitiveGradients(collections);

  const primitives = [
    { name: "colors",     content: primColors,                         file: "colors.dart"     },
    { name: "typography", content: buildPrimitiveTypography(collections), file: "typography.dart" },
    { name: "spacing",    content: buildPrimitiveSpacing(collections),    file: "spacing.dart"    },
    { name: "radii",      content: buildPrimitiveRadii(collections),      file: "radii.dart"      },
    { name: "effects",    content: primEffects,                        file: "effects.dart"    },
    { name: "gradients",  content: primGradients,                      file: "gradients.dart"  },
  ];

  for (const { content, file } of primitives) {
    if (!content) { log("skip", `${file} — no data in included collections`); continue; }
    const fp = path.join(CONFIG.primDir, file);
    const r  = writeFile(fp, content);
    log(r === "skipped" ? "skip" : "ok", `${file} ${r === "skipped" ? "(no changes)" : "(updated)"}`);
  }

  // ── Semantics ───────────────────────────────────────────────────────────────
  console.log("\nBuilding semantics...");

  const semColorFiles = buildSemanticColors(collections, primitiveVarNames);
  for (const [filename, { dart }] of Object.entries(semColorFiles)) {
    const fp = path.join(CONFIG.semDir, filename);
    const r  = writeFile(fp, dart);
    log(r === "skipped" ? "skip" : "ok", `semantic/${filename} ${r === "skipped" ? "(no changes)" : "(updated)"}`);
  }

  const semantics = [
    { content: buildSemanticTypography(collections), file: "typography_semantic.dart" },
    { content: buildSemanticSpacing(collections),    file: "spacing_semantic.dart"    },
    { content: buildSemanticEffects(collections),    file: "effects_semantic.dart"    },
  ];

  for (const { content, file } of semantics) {
    if (!content) { log("skip", `semantic/${file} — no data`); continue; }
    const fp = path.join(CONFIG.semDir, file);
    const r  = writeFile(fp, content);
    log(r === "skipped" ? "skip" : "ok", `semantic/${file} ${r === "skipped" ? "(no changes)" : "(updated)"}`);
  }

  // ── Barrel ──────────────────────────────────────────────────────────────────
  const barrel = buildBarrel(semColorFiles, !!primEffects, !!primGradients);
  const br = writeFile(CONFIG.barrelFile, barrel);
  log(br === "skipped" ? "skip" : "ok", `tokens.dart ${br === "skipped" ? "(no changes)" : "(updated)"}`);

  console.log(`\nDone → ${PACKAGE_ROOT}/lib/tokens/`);
  console.log("\nTo add/remove collections: edit INCLUDED_COLLECTIONS at the top of this script.");
  console.log("To add new token types: add a buildPrimitive<Type>() + buildSemantic<Type>() and register them.\n");
}

main();