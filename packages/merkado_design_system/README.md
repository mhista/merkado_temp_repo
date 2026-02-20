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
