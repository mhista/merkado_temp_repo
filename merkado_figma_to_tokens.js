#!/usr/bin/env node

/**
 * Merkado Design System - Token Transformer
 * Converts Tokens Studio JSON exports to Dart constants
 * 
 * Supports W3C Design Tokens format with $type and $value
 */

const fs = require('fs');
const path = require('path');

// Configuration
const CONFIG = {
  inputDir: './figma_tokens',
  outputDir: './lib/tokens/primitives',
  timestamp: new Date().toISOString().replace('T', ' ').split('.')[0],
};

// Token value resolver (handles references like {colors.blue.500})
function resolveTokenValue(value, allTokens, visited = new Set()) {
  if (typeof value !== 'string') return value;
  
  // Check if it's a reference (e.g., "{colors.blue.500}")
  const refMatch = value.match(/^\{([^}]+)\}$/);
  if (!refMatch) return value;
  
  const refPath = refMatch[1];
  if (visited.has(refPath)) {
    console.warn(`⚠️  Circular reference detected: ${refPath}`);
    return value;
  }
  
  visited.add(refPath);
  
  // Navigate through the token structure
  const parts = refPath.split('.');
  let current = allTokens;
  
  for (const part of parts) {
    if (current && typeof current === 'object' && part in current) {
      current = current[part];
    } else {
      return value; // Can't resolve, return as-is
    }
  }
  
  // If we found a token object, get its $value
  if (current && typeof current === 'object' && '$value' in current) {
    return resolveTokenValue(current.$value, allTokens, visited);
  }
  
  return current;
}

// Evaluate math expressions
function evaluateMath(expression, allTokens) {
  // First resolve any token references
  let resolved = String(expression);
  const refMatches = resolved.match(/\{[^}]+\}/g);
  
  if (refMatches) {
    for (const ref of refMatches) {
      const value = resolveTokenValue(ref, allTokens);
      resolved = resolved.replace(ref, value);
    }
  }
  
  // Handle roundTo() function
  if (resolved.includes('roundTo(')) {
    resolved = resolved.replace(/roundTo\(([^)]+)\)/g, (_, expr) => {
      try {
        return Math.round(eval(expr));
      } catch {
        return expr;
      }
    });
  }
  
  // Evaluate remaining math
  try {
    const result = eval(resolved);
    return isNaN(result) ? expression : result;
  } catch {
    return expression;
  }
}

// Hex to Color converter
function hexToColor(hex) {
  let cleaned = hex.replace('#', '');
  if (cleaned.length === 6) {
    cleaned = 'FF' + cleaned;
  }
  return `Color(0x${cleaned.toUpperCase()})`;
}

// Convert to camelCase
function toCamelCase(str) {
  return str
    .replace(/[-_\s]+(.)?/g, (_, c) => c ? c.toUpperCase() : '')
    .replace(/^[A-Z]/, c => c.toLowerCase());
}

// Convert to PascalCase
function toPascalCase(str) {
  const camel = toCamelCase(str);
  return camel.charAt(0).toUpperCase() + camel.slice(1);
}

// File header generator
function generateDartFileHeader(category) {
  return `// AUTO-GENERATED - DO NOT EDIT MANUALLY
// Generated from Merkado Design System Figma tokens
// Last updated: ${CONFIG.timestamp}
// Category: ${category}

import 'dart:ui';
`;
}

// Load all token files
function loadAllTokens() {
  const allTokens = {};
  const tokenFiles = ['core.json', 'light.json', 'dark.json', 'theme.json'];
  
  for (const filename of tokenFiles) {
    const filePath = path.join(CONFIG.inputDir, filename);
    if (fs.existsSync(filePath)) {
      const content = JSON.parse(fs.readFileSync(filePath, 'utf8'));
      Object.assign(allTokens, content);
    }
  }
  
  return allTokens;
}

// Transform colors from core.json
function transformColors(coreTokens, allTokens) {
  let dartCode = generateDartFileHeader('Colors');
  dartCode += '\n/// Tier 1: Primitive Color Tokens\n';
  dartCode += '/// Raw color values from Merkado Design System\n';
  dartCode += 'class PrimitiveColors {\n';
  dartCode += '  PrimitiveColors._();\n\n';
  
  const colors = coreTokens.colors || {};
  
  // Process each color family
  for (const [colorFamily, shades] of Object.entries(colors)) {
    if (typeof shades !== 'object' || shades.$type) continue;
    
    dartCode += `  // ${toPascalCase(colorFamily)} Scale\n`;
    
    for (const [shade, token] of Object.entries(shades)) {
      if (token.$type === 'color') {
        const value = resolveTokenValue(token.$value, allTokens);
        const varName = toCamelCase(`${colorFamily}${shade}`);
        const colorValue = hexToColor(value);
        dartCode += `  static const Color ${varName} = ${colorValue};\n`;
      }
    }
    
    dartCode += '\n';
  }
  
  // Add standalone colors (black, white)
  if (colors.black && colors.black.$type === 'color') {
    const value = resolveTokenValue(colors.black.$value, allTokens);
    dartCode += `  // Neutral Colors\n`;
    dartCode += `  static const Color black = ${hexToColor(value)};\n`;
  }
  
  if (colors.white && colors.white.$type === 'color') {
    const value = resolveTokenValue(colors.white.$value, allTokens);
    dartCode += `  static const Color white = ${hexToColor(value)};\n\n`;
  }
  
  dartCode += '}\n';
  return dartCode;
}

// Transform typography from core.json
function transformTypography(coreTokens, allTokens) {
  let dartCode = generateDartFileHeader('Typography');
  dartCode += '\n/// Tier 1: Primitive Typography Tokens\n';
  dartCode += 'class PrimitiveTypography {\n';
  dartCode += '  PrimitiveTypography._();\n\n';
  
  // Font Families
  if (coreTokens.fontFamilies) {
    dartCode += '  // Font Families\n';
    for (const [key, token] of Object.entries(coreTokens.fontFamilies)) {
      if (token.$type === 'fontFamilies') {
        const value = resolveTokenValue(token.$value, allTokens);
        const varName = toCamelCase(`fontFamily_${key}`);
        dartCode += `  static const String ${varName} = '${value}';\n`;
      }
    }
    dartCode += '\n';
  }
  
  // Font Sizes
  if (coreTokens.fontSizes) {
    dartCode += '  // Font Sizes\n';
    for (const [key, token] of Object.entries(coreTokens.fontSizes)) {
      if (token.$type === 'fontSizes') {
        let value = resolveTokenValue(token.$value, allTokens);
        value = evaluateMath(value, allTokens);
        const varName = toCamelCase(`fontSize_${key}`);
        dartCode += `  static const double ${varName} = ${parseFloat(value)};\n`;
      }
    }
    dartCode += '\n';
  }
  
  // Font Weights
  if (coreTokens.fontWeights) {
    dartCode += '  // Font Weights\n';
    for (const [key, token] of Object.entries(coreTokens.fontWeights)) {
      if (token.$type === 'fontWeights') {
        const value = resolveTokenValue(token.$value, allTokens);
        const varName = toCamelCase(`fontWeight_${key}`);
        // Convert weight names to numbers
        const weightMap = {
          'Regular': '400',
          'Medium': '500',
          'SemiBold': '600',
          'Bold': '700',
        };
        const weight = weightMap[value] || value;
        dartCode += `  static const int ${varName} = ${weight};\n`;
      }
    }
    dartCode += '\n';
  }
  
  // Line Heights
  if (coreTokens.lineHeights) {
    dartCode += '  // Line Heights\n';
    for (const [key, token] of Object.entries(coreTokens.lineHeights)) {
      if (token.$type === 'lineHeights') {
        const value = resolveTokenValue(token.$value, allTokens);
        const varName = toCamelCase(`lineHeight_${key}`);
        // Convert percentage to decimal (110% -> 1.1)
        const decimal = value.includes('%') 
          ? (parseFloat(value) / 100).toFixed(2)
          : parseFloat(value);
        dartCode += `  static const double ${varName} = ${decimal};\n`;
      }
    }
    dartCode += '\n';
  }
  
  // Letter Spacing
  if (coreTokens.letterSpacing) {
    dartCode += '  // Letter Spacing\n';
    for (const [key, token] of Object.entries(coreTokens.letterSpacing)) {
      if (token.$type === 'letterSpacing') {
        const value = resolveTokenValue(token.$value, allTokens);
        const varName = toCamelCase(`letterSpacing_${key}`);
        // Convert percentage to decimal
        const decimal = value.includes('%') 
          ? (parseFloat(value) / 100).toFixed(2)
          : parseFloat(value);
        dartCode += `  static const double ${varName} = ${decimal};\n`;
      }
    }
    dartCode += '\n';
  }
  
  dartCode += '}\n';
  return dartCode;
}

// Transform spacing from core.json
function transformSpacing(coreTokens, allTokens) {
  let dartCode = generateDartFileHeader('Spacing');
  dartCode += '\n/// Tier 1: Primitive Spacing Tokens\n';
  dartCode += 'class PrimitiveSpacing {\n';
  dartCode += '  PrimitiveSpacing._();\n\n';
  
  const spacing = coreTokens.spacing || {};
  const dimension = coreTokens.dimension || {};
  
  // Process spacing tokens
  for (const [key, token] of Object.entries(spacing)) {
    if (token.$type === 'spacing') {
      let value = resolveTokenValue(token.$value, allTokens);
      value = evaluateMath(value, allTokens);
      const varName = toCamelCase(`spacing_${key}`);
      dartCode += `  static const double ${varName} = ${parseFloat(value)};\n`;
    }
  }
  
  dartCode += '\n  // Dimensions\n';
  
  // Process dimension tokens
  for (const [key, token] of Object.entries(dimension)) {
    if (token.$type === 'dimension') {
      let value = resolveTokenValue(token.$value, allTokens);
      value = evaluateMath(value, allTokens);
      const varName = toCamelCase(`dimension_${key}`);
      dartCode += `  static const double ${varName} = ${parseFloat(value)};\n`;
    }
  }
  
  dartCode += '}\n';
  return dartCode;
}

// Transform border radius
function transformBorderRadius(coreTokens, allTokens) {
  let dartCode = generateDartFileHeader('Border Radius');
  dartCode += '\n/// Tier 1: Primitive Border Radius Tokens\n';
  dartCode += 'class PrimitiveRadii {\n';
  dartCode += '  PrimitiveRadii._();\n\n';
  
  const borderRadius = coreTokens.borderRadius || {};
  
  for (const [key, token] of Object.entries(borderRadius)) {
    if (token.$type === 'borderRadius') {
      let value = resolveTokenValue(token.$value, allTokens);
      value = evaluateMath(value, allTokens);
      const varName = toCamelCase(`radius_${key}`);
      dartCode += `  static const double ${varName} = ${parseFloat(value)};\n`;
    }
  }
  
  dartCode += '}\n';
  return dartCode;
}

// Transform opacity
function transformOpacity(coreTokens, allTokens) {
  let dartCode = generateDartFileHeader('Opacity');
  dartCode += '\n/// Tier 1: Primitive Opacity Tokens\n';
  dartCode += 'class PrimitiveOpacity {\n';
  dartCode += '  PrimitiveOpacity._();\n\n';
  
  const opacity = coreTokens.opacity || {};
  
  for (const [key, token] of Object.entries(opacity)) {
    if (token.$type === 'opacity') {
      const value = resolveTokenValue(token.$value, allTokens);
      const varName = toCamelCase(`opacity_${key}`);
      // Convert percentage to decimal (10% -> 0.1)
      const decimal = value.includes('%') 
        ? (parseFloat(value) / 100).toFixed(2)
        : parseFloat(value);
      dartCode += `  static const double ${varName} = ${decimal};\n`;
    }
  }
  
  dartCode += '}\n';
  return dartCode;
}

// Main execution
function main() {
  try {
    console.log('🎨 Merkado Design System - Token Transformation\n');
    
    // Load all tokens
    const allTokens = loadAllTokens();
    const coreTokens = JSON.parse(
      fs.readFileSync(path.join(CONFIG.inputDir, 'core.json'), 'utf8')
    );
    
    // Create output directory
    if (!fs.existsSync(CONFIG.outputDir)) {
      fs.mkdirSync(CONFIG.outputDir, { recursive: true });
    }
    
    // Transform each category
    const transformations = [
      { name: 'colors', fn: () => transformColors(coreTokens, allTokens), file: 'colors.dart' },
      { name: 'typography', fn: () => transformTypography(coreTokens, allTokens), file: 'typography.dart' },
      { name: 'spacing', fn: () => transformSpacing(coreTokens, allTokens), file: 'spacing.dart' },
      { name: 'borderRadius', fn: () => transformBorderRadius(coreTokens, allTokens), file: 'radii.dart' },
      { name: 'opacity', fn: () => transformOpacity(coreTokens, allTokens), file: 'opacity.dart' },
    ];
    
    for (const { name, fn, file } of transformations) {
      console.log(`✓ Transforming ${name}...`);
      const dartCode = fn();
      const filePath = path.join(CONFIG.outputDir, file);
      fs.writeFileSync(filePath, dartCode);
      console.log(`  → Generated ${file}`);
    }
    
    // Generate barrel file
    const barrelPath = path.join(path.dirname(CONFIG.outputDir), 'tokens.dart');
    const barrelContent = `// AUTO-GENERATED - Barrel export for all tokens
export 'primitives/colors.dart';
export 'primitives/typography.dart';
export 'primitives/spacing.dart';
export 'primitives/radii.dart';
export 'primitives/opacity.dart';
export 'semantic/color_semantic.dart';
export 'semantic/text_semantic.dart';
`;
    fs.writeFileSync(barrelPath, barrelContent);
    console.log(`✓ Generated tokens.dart barrel file`);
    
    console.log('\n✅ Token transformation complete!');
    console.log(`📁 Generated files in: ${CONFIG.outputDir}`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

main();