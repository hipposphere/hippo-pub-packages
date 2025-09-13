# hippo_components

A comprehensive Flutter UI component library providing reusable, opinionated building blocks for Hipposphere applications. Features modals, charts, themes, sliver utilities, and cross-platform adaptive widgets.

## Features

### 🎯 Core Components
- **Modal System**: Cupertino-style modals, info dialogs, confirmation prompts, text input modals, file selection, and multi-select interfaces
- **Button Components**: Customizable buttons, symbols, tappable areas, and text buttons with consistent styling
- **Cards & Layout**: Gradient cards, tiles, sections, and layout containers
- **Form Elements**: Styled text fields, pencil input fields, color pickers, and PIN input components

### 📊 Charts & Visualizations  
- **Study Plan Charts**: Timeline visualizations for learning progress
- **Year Heatmaps**: Calendar-style activity visualizations
- **Stacked Bar Charts**: Multi-category data visualization

### 🎨 Theme System
- **Adaptive Theming**: Cross-platform theme support with `HippoThemeBuilder`
- **Color System**: Comprehensive color palette and theme extensions
- **Design Tokens**: Centralized constants for consistent styling

### 🛠️ Sliver Utilities
- **Layout Slivers**: `SliverColumn`, `SliverGap`, `SliverChild`, `SliverExpansion`
- **Advanced Slivers**: `SliverFillAligned`, `SliverExpansionTile` for complex layouts

### 🌍 Internationalization
- **Multi-language Support**: ARB-based localization with generated localizations
- **Component Strings**: Built-in translations for UI component text

### 🎭 Assets & Animations
- **Lottie Animations**: Ready-to-use animations for empty states, loading, and feedback
- **Asset Management**: Centralized asset referencing and management utilities

### 🔧 Developer Tools
- **List View Controller**: Enhanced list view management with scroll-to-index support
- **Toast System**: Notification and feedback system with `ToastBuilder` and `ToastRunner`
- **Utility Widgets**: Gap spacing, app versioning, time formatting, and more

## Getting Started

Add the dependency in your app `pubspec.yaml` (after publishing) or use a path reference inside the monorepo:

```yaml
dependencies:
	hippo_components: ^0.1.0    # when published
	# OR (inside this monorepo consumer outside root)
	# hippo_components:
	#   path: ../hippo-packages/packages/hippo_components
```

Import the barrel:
```dart
import 'package:hippo_components/hippo_components.dart';
```

## Directory Structure

```
lib/
  hippo_components.dart          # Barrel export - main entry point
  src/
    base/                        # Core UI primitives
      actions/                   # Modal dialogs and user interactions
      buttons/                   # Button components and variations
      cards/                     # Card layouts and containers
      cupertino_modal/          # iOS-style modal system
      modals/                   # Modal utilities and common bodies
      other/                    # Miscellaneous UI components
      slivers/                  # Custom sliver implementations
      themes/                   # Theme system and color schemes
      utils/                    # Base utility widgets and helpers
    charts/                     # Chart and visualization widgets
      studyplan/               # Study plan timeline charts
    complex/                    # Composite and advanced widgets
    container/                  # High-level layout containers
    assets/                     # Asset management utilities
    tools/                      # Developer tools and controllers
    constants.dart              # Design tokens and constants
  localizations/                # Generated localization files
l10n/                          # ARB source files for translations
assets/                        # Lottie animations and shared assets
  other/                       # Animation files and resources
```

## Localization

Source ARB files live in `l10n/` (e.g. `components_en.arb`). Generated localization code is committed in `lib/localizations/`.

To regenerate after editing ARB files:
```pwsh
flutter gen-l10n
```
If you introduce a new locale, add the appropriate ARB and rerun generation.

### (Optional) Automated Translation
We previously experimented with `arb_translate`. If you want to re‑enable:
```pwsh
dart pub global activate --source git https://github.com/flowhorn/arb_translate.git
arb_translate
```
Review machine output manually before committing.

## Example Usage

### Modal Components
```dart
import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

// Info Modal
showInfoModal(
  context,
  title: 'Welcome',
  message: 'Welcome to the app!',
);

// Confirmation Modal
final confirmed = await showConfirmModal(
  context,
  title: 'Delete Item',
  message: 'Are you sure you want to delete this item?',
);

// Text Input Modal
final text = await showGetTextModal(
  context,
  title: 'Enter Name',
  placeholder: 'Your name...',
);

// Selection Modal
final selected = await showSelectModal<String>(
  context,
  title: 'Choose Option',
  items: SelectItemsList(['Option 1', 'Option 2', 'Option 3']),
  itemBuilder: (item) => Text(item),
);
```

### Chart Components
```dart
// Study Plan Chart
StudyplanChart(
  data: studyPlanData,
  onDayTapped: (date) => print('Tapped: $date'),
)

// Year Heatmap
YearHeatmap(
  year: 2024,
  data: activityData,
  colorScheme: YearHeatmapColorScheme.green,
)

// Stacked Bar Chart  
StackedBarChart(
  data: chartData,
  maxValue: 100,
  height: 200,
)
```

### Theme & Layout
```dart
// Theme Builder
HippoThemeBuilder(
  builder: (context, theme) => MaterialApp(
    theme: theme,
    home: MyHomePage(),
  ),
)

// Sliver Layout
CustomScrollView(
  slivers: [
    SliverColumn(
      children: [
        SliverChild(child: Text('Header')),
        SliverGap(height: 16),
        SliverExpansionTile(
          title: Text('Expandable Section'),
          children: [
            Text('Content 1'),
            Text('Content 2'),
          ],
        ),
      ],
    ),
  ],
)
```

### Utility Components
```dart
// Toast Notifications
ToastBuilder.success(
  context,
  title: 'Success!',
  description: 'Operation completed successfully',
).show();

// Smart Time Display
SmartTimeagoText(
  date: DateTime.now().subtract(Duration(hours: 2)),
)

// Adaptive Builder
AdaptiveBuilder(
  ios: (context) => CupertinoButton(child: Text('iOS')),
  material: (context) => ElevatedButton(child: Text('Material')),
)
```

## Asset Usage

Animations (Lottie) under `assets/other/` can be referenced through provided asset helpers (see `lib/src/assets/`). Ensure you add them to your app's `pubspec.yaml` if consumed externally.

## Theming

Theme constants live under `src/constants.dart` and themed components under `src/base/themes/`. Extend or override via standard Flutter `ThemeExtension`s where possible.

## Development

Inside monorepo root:
```pwsh
dart run melos bootstrap      # once
dart analyze packages/hippo_components
flutter test                  # (when tests are added)
```

Format & analyze before PRs:
```pwsh
dart format . -o write
dart analyze .
```

## Contributing

1. Add/modify widgets with clear, focused commits.
2. Keep public API surface lean; prefer internal helpers staying in `src/`.
3. Document breaking changes in `CHANGELOG.md`.
4. Add examples and (future) golden/screenshot tests where visual regressions matter.

## Roadmap

### Short Term
- **Storybook Integration**: Interactive component showcase and documentation
- **Accessibility Audit**: Enhanced screen reader and keyboard navigation support
- **Performance Optimization**: Widget performance profiling and improvements

### Medium Term  
- **Design System Documentation**: Comprehensive design token and usage guidelines
- **Visual Regression Testing**: Automated screenshot testing for UI consistency
- **Advanced Chart Types**: Line charts, pie charts, and custom visualizations
- **Theme Customization**: Enhanced theming API with runtime theme switching

### Long Term
- **Component Testing Suite**: Comprehensive widget testing framework
- **Animation Library Expansion**: More Lottie animations and custom transitions
- **Platform-Specific Optimizations**: Enhanced iOS and Android native integrations
- **Developer Tooling**: VS Code extension for component scaffolding

---

Happy building with `hippo_components`! 🦛