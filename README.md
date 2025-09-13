# Hippo Packages Monorepo

This repository contains commonly used Dart & Flutter packages maintained by **Hipposphere**. It is a managed monorepo using **Melos** for dependency version alignment, script orchestration, and workspace management.

## Contents

- `packages/hippo_components` – Reusable Flutter UI components, themes, containers, charts, localization helpers, and higher-level composite widgets.
- `packages/hippo_utils` – Cross‑platform utility wrappers and convenience exports for frequently used packages (files, sharing, purchases, URL launching, reactive streams, BLoC helpers, etc.).

## Prerequisites

- Dart SDK: As defined in `pubspec.yaml` (currently `sdk: ">=3.9.2 <4.0.0"`).
- Flutter (if working on `hippo_components`). Make sure your Flutter version supports the declared Dart SDK.
- Git & a POSIX shell (PowerShell is fine on Windows).

## Melos

Melos is already declared as a `dev_dependency` in the root `pubspec.yaml`:

```yaml
dev_dependencies:
  melos: ^7.1.1
```

You can run Melos via:

1. `dart run melos <command>` (preferred – uses the pinned version)
2. Or install it globally (optional):
	```shell
	dart pub global activate melos
	melos --help
	```

### Bootstrap the Workspace

Install all package dependencies and generate inter‑package links:

```shell
dart run melos bootstrap
```

What this does:
- Gets dependencies for each package in `workspace`.
- Creates symlinks so local packages reference each other without publishing.
- Ensures consistent dependency resolution.

After a successful bootstrap you generally do NOT need to run `dart pub get` inside individual package folders unless you change that specific package's `pubspec.yaml` and want an incremental refresh.

If you installed Melos globally you may instead run:

```shell
melos bootstrap
```

### Common Melos Commands

```shell
dart run melos list            # List all workspace packages
dart run melos bootstrap       # Install/link dependencies
dart run melos clean           # Clean all build & .dart_tool dirs
dart run melos exec -- <cmd>   # Run <cmd> in each package
dart run melos run <script>    # Run a script defined in melos.yaml (future)
```

> Note: A dedicated `melos.yaml` is not yet present; Melos also reads the `workspace:` and `melos:` keys from root `pubspec.yaml` (supported since newer Melos versions). Add a `melos.yaml` later if you need custom scripts, versioning, or publication settings.

## Package Overview

### `hippo_components`  [→ detailed README](packages/hippo_components/README.md)
Focus: Design‑system level building blocks and higher‑level UI constructs.

Highlights:
- Modular directories: `base`, `complex`, `charts`, `container`, `assets`, `tools`.
- Localization ARB files under `l10n/` with generated localizations in `lib/localizations/`.
- Animated assets (Lottie JSON) for empty states, feedback, onboarding, etc.
- Export barrel: import everything via:
  ```dart
  import 'package:hippo_components/hippo_components.dart';
  ```
Feature ideas / scope (current & evolving):
- Reusable button, card, modal, sliver & navigation primitives.
- Dashboard & master/detail container scaffolds.
- Chart widgets (stacked bar, heatmap, study plan timeline, etc.).
- Theming constants to ensure visual consistency across apps.

Potential additions (future): Storybook/demo app, screenshot tests, theme tokens extraction.

### `hippo_utils`  [→ detailed README](packages/hippo_utils/README.md)
Focus: Unified wrappers and curated exports around widely used third‑party packages plus internal utilities.

Highlights:
- Convenience re‑exports (e.g. `filesize`, `url_launcher`, `share_plus`, `rxdart`).
- BLoC facilitation utilities (`bloc_provider`, `multi_bloc_provider`, typed base classes).
- Storage abstractions (`store`, `file_store`, `key_value_store`).
- Reactive data subjects & stream extensions.
Additional aims:
- Reduce repetitive import clutter in app packages.
- Centralize upgrade surface for 3rd‑party libs.
- Provide thin abstraction layers where cross‑platform differences exist.

Typical import:
```dart
import 'package:hippo_utils/hippo_utils.dart';
```

## Development Workflow

1. Clone the repository:
	```shell
	git clone https://github.com/hipposphere/hippo-packages.git
	cd hippo-packages
	```
2. Bootstrap:
	```shell
	dart run melos bootstrap
	```
3. Run analysis (example):
	```shell
	dart analyze .
	```
4. (Optional) Run package‑wide command:
	```shell
	dart run melos exec -- dart analyze .
	```

Add tests or scripts as the monorepo grows. Once a `melos.yaml` with `scripts:` is added you can centralize tasks (e.g. `melos run analyze`).

### Testing (Planned)

If/when tests are added to packages, typical patterns will be:

```shell
dart run melos exec -- dart test                 # Run tests in all packages
dart run melos exec --fail-fast -- dart test     # Stop on first failure
```

After adding a `melos.yaml` with scripts:

```yaml
scripts:
	test: dart run melos exec -- dart test
```

Then:
```shell
dart run melos run test
```

## Contribution Guidelines

1. Keep public APIs stable; document breaking changes in each package `CHANGELOG.md`.
2. Prefer small, focused commits.
3. Ensure `dart format` and `dart analyze` pass before opening a PR.
4. Update localization ARB + regenerate when adding user‑visible strings.

## Creating a New Package / Plugin

Follow this workflow to add a new package under `packages/`.

### 1. Choose Name & Type

Decide whether you need a plain Dart package or a Flutter plugin (with native platforms):

- Pure Dart (no Flutter UI, no native code): `--template=package`
- Flutter (widgets / depends on Flutter SDK only): `--template=package` (inside a Flutter SDK checkout is fine)
- Plugin (needs platform channel or native implementations): `--template=plugin`

Naming conventions:
- Prefix with `hippo_` unless there is a strong reason not to.
- Use lowercase_with_underscores.
- Keep scope narrow (e.g. `hippo_auth`, not `hippo_everything`).

### 2. Create the Skeleton

From repository root (same level as this README):

```pwsh
# For a pure/Flutter package
flutter create --template=package packages/hippo_newthing

# For a plugin (adds platform folders). Specify only needed platforms to reduce noise.
flutter create --template=plugin \
	--platforms=android,ios,macos,web \
	packages/hippo_newplugin
```

If you truly don't need Flutter, you can also use plain Dart:
```pwsh
dart create -t package packages/hippo_newthing
```

### 3. Update the Workspace

Add the new path to the `workspace:` list in root `pubspec.yaml` (Melos reads this):

```yaml
workspace:
	- packages/hippo_components
	- packages/hippo_utils
	- packages/hippo_newthing   # <-- add
```

Then re-bootstrap so Melos links it:

```pwsh
dart run melos bootstrap
```

### 4. Configure `pubspec.yaml`

Inside the new package:
- Set a meaningful `description:`.
- Add a starting `version: 0.1.0` (or `0.0.1` if experimental).
- If publishing later, omit `publish_to: none`.
- Add dependencies referencing sibling packages with normal package names (Melos + path linking handles it automatically after bootstrap).

Example (inside `packages/hippo_newthing/pubspec.yaml`):
```yaml
name: hippo_newthing
description: New feature focused utilities.
version: 0.1.0
environment:
	sdk: ">=3.9.2 <4.0.0"
dependencies:
	hippo_utils: any      # local workspace reference
dev_dependencies:
	flutter_lints: ^6.0.0 # (if Flutter)
```

### 5. Analysis & Lints

Reuse existing analysis options by copying one from an existing package or by creating a minimal file:
```pwsh
Copy-Item packages/hippo_utils/analysis_options.yaml packages/hippo_newthing/
```
Adjust only if the package has unique needs.

### 6. Exports (Barrel File)

Create a `lib/hippo_newthing.dart` export barrel to keep imports tidy. Export only intentional public APIs.

### 7. Adding a Plugin Implementation (If Plugin)

Implement platform code under the generated `android/`, `ios/`, etc. Keep platform features optional & guarded by capability checks. Document any setup (e.g. Info.plist permissions) in the new package README.

### 8. Local Development

After editing code run:
```pwsh
dart analyze packages/hippo_newthing
dart format packages/hippo_newthing -o write
```
Or run across all packages:
```pwsh
dart run melos exec -- dart analyze .
```

### 9. Tests (When Added)

Add a `test/` directory even if starting with a placeholder to encourage coverage.

### 10. Documentation

Create / update:
- `README.md` inside the new package (purpose, quick start, example code)
- `CHANGELOG.md` (start with `## 0.1.0 - Initial release`)
- `LICENSE` (copy an existing one if same license)

### 11. Publishing (Optional / Future)

When ready to publish a package (not plugins with unpublished native code):
```pwsh
cd packages/hippo_newthing
dart pub publish --dry-run
```
Fix any warnings, then publish (ensure version & changelog updated).

### 12. CI / Scripts (Future Enhancements)

Once a `melos.yaml` is introduced, add scripts (e.g. `analyze`, `format`, `test`) so contributors only learn one command. For now use direct `dart` / `flutter` commands.

### Quick Checklist

1. Create with correct template.
2. Add to root `workspace:`.
3. Bootstrap.
4. Copy `analysis_options.yaml`.
5. Add barrel export.
6. Write README + CHANGELOG + LICENSE.
7. Add tests.
8. Analyze & format clean.
9. (Optional) Publish.

---

Need help deciding between package vs plugin? Rule of thumb: If you only depend on Dart & Flutter SDK APIs (widgets, rendering, http, etc.) use a package. Only choose a plugin if you must call platform/native code or need platform registrars.

## Licensing

Each package includes its own `LICENSE`. Unless otherwise noted, they are published under their respective licenses. Verify individual package terms before external redistribution.

## Support & Questions

For internal teams: reach out in the Hipposphere developer channel. For external discussions, open an issue or a discussion thread in this repository.

---

Happy building with Hipposphere components & utilities! 🦛

