# hippo_components

Reusable, opinionated Flutter UI building blocks used across Hipposphere apps: base primitives, layout containers, charts, composite widgets, theming helpers, localization, and animated assets.

## Features

- Consistent design‑system primitives (buttons, cards, modals, slivers, themes)
- Layout containers (dashboard, master/detail, page scaffolds)
- Charts & visualizations (stacked bar, heatmap, studyplan timeline – expanding)
- Animation assets for empty states, success, onboarding (Lottie JSON in `assets/`)
- Centralized constants & theme tokens
- Localization ready (ARB + generated localizations)
- Utility tooling (list view controller, etc.)

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
	hippo_components.dart        # Barrel export
	src/
		base/                      # Core primitives (buttons, etc.)
		complex/                   # Composite widgets
		charts/                    # Chart implementations
		container/                 # High‑level layout containers
		assets/                    # Asset referencing helper(s)
		tools/                     # Misc utilities (controllers, helpers)
	localizations/               # Generated localization files
l10n/                          # ARB source files
assets/                        # Lottie animations and other shared assets
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

```dart
import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

class DashboardScreen extends StatelessWidget {
	const DashboardScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return HippoDashboardContainer(
			header: const Text('Overview'),
			body: ListView(
				children: const [
					// Hypothetical primitives / composites
					HippoStatCard(title: 'Sessions', value: '42'),
					SizedBox(height: 12),
					HippoStackedBarChart(/* data */),
				],
			),
		);
	}
}
```

> NOTE: Class names above are illustrative; adjust to actual exported symbols present in `src/`.

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

## Roadmap (Abridged)

- Storybook / demo showcase
- Theme token extraction & design sync
- More chart types & accessibility review
- Visual regression testing pipeline

---

Happy building with `hippo_components`! 🦛