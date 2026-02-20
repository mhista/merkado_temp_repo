#!/bin/bash

# Merkado Design System - Complete Setup Script
# Run this to initialize your design system package
# Safe to run multiple times - only creates what's missing

set -e  # Exit on error

echo "🎨 Merkado Design System Setup"
echo "=============================="
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter 3.13.0+"
    exit 1
fi
echo "✅ Flutter: $(flutter --version | head -n 1)"

# Check Dart
if ! command -v dart &> /dev/null; then
    echo "❌ Dart not found. Please install Dart 3.5.0+"
    exit 1
fi
DART_VERSION=$(dart --version 2>&1 | head -n 1)
echo "✅ Dart: $DART_VERSION"

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "⚠️  Node.js not found. Installing is recommended for token transformation."
    echo "   Install from: https://nodejs.org"
else
    echo "✅ Node.js: $(node --version)"
fi

# Install Melos globally if not already installed
echo ""
if command -v melos &> /dev/null; then
    echo "✅ Melos already installed: $(melos --version 2>&1 | head -n 1)"
else
    echo "📦 Installing Melos globally..."
    dart pub global activate melos 7.4.0
    echo "✅ Melos installed"
fi

# Add pub-cache bin to PATH if not already there
PUB_CACHE_BIN="$HOME/.pub-cache/bin"
if [[ ":$PATH:" != *":$PUB_CACHE_BIN:"* ]]; then
    echo "⚠️  Adding pub-cache to PATH for this session..."
    export PATH="$PATH:$PUB_CACHE_BIN"
fi

echo ""
echo "📁 Creating Merkado Design System structure..."

# Create directories only if they don't exist
create_dir_if_missing() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo "  ✓ Created: $1"
    else
        echo "  ⏭️  Exists: $1"
    fi
}

create_dir_if_missing "packages/merkado_design_system/lib/tokens/primitives"
create_dir_if_missing "packages/merkado_design_system/lib/tokens/semantic"
create_dir_if_missing "packages/merkado_design_system/lib/themes"
create_dir_if_missing "packages/merkado_design_system/lib/components/atoms"
create_dir_if_missing "packages/merkado_design_system/lib/components/molecules"
create_dir_if_missing "packages/merkado_design_system/lib/components/organisms"
create_dir_if_missing "packages/merkado_design_system/scripts"
create_dir_if_missing "packages/merkado_design_system/figma_tokens"
create_dir_if_missing "packages/merkado_design_system/docs/generated"
create_dir_if_missing "packages/merkado_design_system/test"
create_dir_if_missing "apps"

echo "✅ Directory structure complete"

# Create or update files only if they don't exist
echo ""
echo "📝 Creating configuration files..."

# Create package pubspec.yaml
if [ ! -f "packages/merkado_design_system/pubspec.yaml" ]; then
cat > packages/merkado_design_system/pubspec.yaml << 'EOF'
name: merkado_design_system
description: Merkado Design System - Centralized design system for all Merkado projects
version: 1.0.0
publish_to: none

environment:
  sdk: ^3.10.0
  flutter: ">=3.13.0"

dependencies:
  flutter:
    sdk: flutter
  
  # Mix Framework - Core styling engine
  mix: ^1.0.0
  
  # Utilities
  equatable: ^2.0.5
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code generation
  build_runner: ^2.4.6
  json_serializable: ^6.7.1
  
  # Linting
  flutter_lints: ^3.0.0
  
  # Testing
  mocktail: ^1.0.0

flutter:
  uses-material-design: true
EOF
    echo "  ✓ Created: packages/merkado_design_system/pubspec.yaml"
else
    echo "  ⏭️  Exists: packages/merkado_design_system/pubspec.yaml"
fi

# Create root pubspec.yaml with workspace configuration (Melos 7.4.0 format)
if [ ! -f "pubspec.yaml" ]; then
cat > pubspec.yaml << 'EOF'
name: merkado_monorepo
description: Merkado Design System Monorepo
publish_to: none

environment:
  sdk: ^3.10.0

workspace:
  - packages/merkado_design_system

dev_dependencies:
  melos: ^7.4.0

melos:
  scripts:
    # Token pipeline
    tokens:transform:
      description: "Transform Figma tokens to Dart"
      run: node packages/merkado_design_system/scripts/figma_to_tokens.js
      
    tokens:validate:
      description: "Validate token consistency"
      run: dart packages/merkado_design_system/scripts/token_validator.dart
      
    tokens:pipeline:
      description: "Complete token pipeline"
      run: |
        echo "🎨 Running Merkado token pipeline..."
        melos run tokens:transform
        echo "✅ Token pipeline complete!"
        
    # Development
    analyze:
      run: melos exec -- flutter analyze
      
    test:
      run: melos exec -- flutter test
      
    format:
      run: melos exec -- dart format .
      
    build:
      run: melos exec -- flutter pub run build_runner build --delete-conflicting-outputs
      
    clean:
      run: melos exec -- flutter clean
      
    get:
      run: melos exec -- flutter pub get
      
    # Pre-commit
    pre-commit:
      description: "Run before committing"
      run: |
        melos run format
        melos run analyze
        melos run test
EOF
    echo "  ✓ Created: pubspec.yaml (with workspace config)"
else
    echo "  ⏭️  Exists: pubspec.yaml"
fi

# Create main export file
if [ ! -f "packages/merkado_design_system/lib/merkado_design_system.dart" ]; then
cat > packages/merkado_design_system/lib/merkado_design_system.dart << 'EOF'
library merkado_design_system;

// Tokens
export 'tokens/tokens.dart';

// Themes
export 'themes/themes.dart';

// Components
export 'components/components.dart';
EOF
    echo "  ✓ Created: lib/merkado_design_system.dart"
else
    echo "  ⏭️  Exists: lib/merkado_design_system.dart"
fi

# Create barrel files
if [ ! -f "packages/merkado_design_system/lib/tokens/tokens.dart" ]; then
cat > packages/merkado_design_system/lib/tokens/tokens.dart << 'EOF'
// Barrel export for all tokens
export 'primitives/colors.dart';
export 'primitives/typography.dart';
export 'primitives/spacing.dart';
export 'primitives/radii.dart';
export 'primitives/opacity.dart';
export 'semantic/color_semantic.dart';
export 'semantic/text_semantic.dart';
EOF
    echo "  ✓ Created: lib/tokens/tokens.dart"
else
    echo "  ⏭️  Exists: lib/tokens/tokens.dart"
fi

if [ ! -f "packages/merkado_design_system/lib/themes/themes.dart" ]; then
cat > packages/merkado_design_system/lib/themes/themes.dart << 'EOF'
// Barrel export for themes
export 'base_theme.dart';
export 'brand_themes.dart';
EOF
    echo "  ✓ Created: lib/themes/themes.dart"
else
    echo "  ⏭️  Exists: lib/themes/themes.dart"
fi

if [ ! -f "packages/merkado_design_system/lib/components/components.dart" ]; then
cat > packages/merkado_design_system/lib/components/components.dart << 'EOF'
// Barrel export for components
// Add your component exports here as you create them
// export 'atoms/ds_button.dart';
// export 'molecules/ds_card.dart';
EOF
    echo "  ✓ Created: lib/components/components.dart"
else
    echo "  ⏭️  Exists: lib/components/components.dart"
fi

# Create semantic color template
if [ ! -f "packages/merkado_design_system/lib/tokens/semantic/color_semantic.dart" ]; then
cat > packages/merkado_design_system/lib/tokens/semantic/color_semantic.dart << 'EOF'
import 'dart:ui';
import '../primitives/colors.dart';

/// Tier 2: Semantic Color Tokens for Merkado Design System
/// Maps primitive colors to semantic intent
/// 
/// MANUALLY MAINTAINED - Update these mappings as needed
class SemanticColors {
  SemanticColors._();

  // Background Colors
  static const Color backgroundPrimary = PrimitiveColors.white;
  static const Color backgroundSecondary = PrimitiveColors.gray100;
  
  // Text Colors
  static const Color textPrimary = PrimitiveColors.black;
  static const Color textSecondary = PrimitiveColors.gray700;
  static const Color textMuted = PrimitiveColors.gray500;
  
  // Brand Colors (update these based on your core.json)
  static const Color brandPrimary = PrimitiveColors.indigo400;
  static const Color brandSecondary = PrimitiveColors.indigo600;
  
  // State Colors
  static const Color stateSuccess = PrimitiveColors.green500;
  static const Color stateError = PrimitiveColors.red500;
  static const Color stateWarning = PrimitiveColors.orange500;
  static const Color stateInfo = PrimitiveColors.blue500;
  
  // Border Colors
  static const Color borderPrimary = PrimitiveColors.gray300;
  static const Color borderSecondary = PrimitiveColors.gray200;
  
  // Surface Colors
  static const Color surfaceDefault = PrimitiveColors.white;
  static const Color surfaceMuted = PrimitiveColors.gray100;
}
EOF
    echo "  ✓ Created: lib/tokens/semantic/color_semantic.dart"
else
    echo "  ⏭️  Exists: lib/tokens/semantic/color_semantic.dart"
fi

# Create semantic text template
if [ ! -f "packages/merkado_design_system/lib/tokens/semantic/text_semantic.dart" ]; then
cat > packages/merkado_design_system/lib/tokens/semantic/text_semantic.dart << 'EOF'
import '../primitives/typography.dart';

/// Tier 2: Semantic Typography Tokens for Merkado Design System
/// Maps primitive typography to semantic intent
class SemanticTypography {
  SemanticTypography._();

  // Font Families
  static const String headingFontFamily = PrimitiveTypography.fontFamily_heading;
  static const String bodyFontFamily = PrimitiveTypography.fontFamily_body;

  // Font Sizes
  static const double headingH1Size = PrimitiveTypography.fontSize_h1;
  static const double headingH2Size = PrimitiveTypography.fontSize_h2;
  static const double bodySize = PrimitiveTypography.fontSize_body;
  
  // Font Weights
  static const int headingWeight = PrimitiveTypography.fontWeight_headingBold;
  static const int bodyWeight = PrimitiveTypography.fontWeight_bodyRegular;
  
  // Line Heights
  static const double headingLineHeight = PrimitiveTypography.lineHeight_heading;
  static const double bodyLineHeight = PrimitiveTypography.lineHeight_body;
}
EOF
    echo "  ✓ Created: lib/tokens/semantic/text_semantic.dart"
else
    echo "  ⏭️  Exists: lib/tokens/semantic/text_semantic.dart"
fi

# Create README
if [ ! -f "packages/merkado_design_system/README.md" ]; then
cat > packages/merkado_design_system/README.md << 'EOF'
# 🎨 Merkado Design System

Centralized design system for all Merkado projects built with Flutter and Mix framework.

## 🚀 Quick Start

```dart
import 'package:merkado_design_system/merkado_design_system.dart';

void main() {
  runApp(
    MixTheme(
      data: DSTheme.base,
      child: MaterialApp(
        home: MyApp(),
      ),
    ),
  );
}
```

## 📁 Project Structure

```
lib/
├── tokens/          # Token engine
│   ├── primitives/  # AUTO-GENERATED from Figma
│   └── semantic/    # Manually maintained
├── themes/          # Mix theme configs
└── components/      # Widget library
```

## 🔄 Token Workflow

1. Designer exports tokens from Figma
2. Place JSON files in `figma_tokens/`
3. Run: `melos run tokens:pipeline`
4. Primitive tokens auto-generate
5. Update semantic mappings if needed

## 📚 Documentation

See `/docs` folder for detailed guides.
EOF
    echo "  ✓ Created: README.md"
else
    echo "  ⏭️  Exists: README.md"
fi

echo "✅ Configuration files complete"

# Run dart pub get first (before melos bootstrap)
echo ""
echo "📦 Getting dependencies..."
dart pub get

# Now run melos bootstrap
echo ""
echo "📦 Running melos bootstrap..."

if command -v melos &> /dev/null; then
    melos bootstrap
else
    echo "⚠️  Running melos via 'dart pub global run melos'..."
    dart pub global run melos bootstrap
fi

echo ""
echo "✅ Merkado Design System setup complete!"
echo ""
echo "🎯 Next steps:"
echo ""
echo "1. Copy your Figma token JSON files to:"
echo "   packages/merkado_design_system/figma_tokens/"
echo "   (core.json, light.json, dark.json, theme.json, etc.)"
echo ""
echo "2. Copy the transformation script:"
echo "   cp merkado_figma_to_tokens.js packages/merkado_design_system/scripts/figma_to_tokens.js"
echo ""
echo "3. Run the token pipeline:"
echo "   melos run tokens:pipeline"
echo ""
echo "4. Review generated files in:"
echo "   packages/merkado_design_system/lib/tokens/primitives/"
echo ""
echo "5. Update semantic mappings in:"
echo "   packages/merkado_design_system/lib/tokens/semantic/"
echo ""
echo "💡 Note: This script is safe to run multiple times."
echo "   It only creates what's missing."
echo ""
echo "🎨 Happy building!"