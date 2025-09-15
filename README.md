# Hippo Pub Packages Monorepo

[![Open in Hippo-Cloud-Coder](https://img.shields.io/badge/Dev%20Containers-Open%20in%20Coder-red?logo=visualstudiocode)](https://coder.hippolabs.org/templates/YOUR_TEMPLATE/workspace)

[![Open in Dev Containers](https://img.shields.io/badge/Dev%20Containers-Open%20in%20VS%20Code-blue?logo=visualstudiocode)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/hipposphere/hippo-pub-packages)



This repository contains commonly used Dart & Flutter packages maintained by **Hipposphere**. It is a managed monorepo using **Melos** for dependency version alignment, script orchestration, and workspace management.

📖 **New here?** Start with the [Getting Started Guide](GETTING_STARTED.md) for setup instructions.

## Contents

- **`packages/hippo_components`** – Comprehensive Flutter UI component library with modals, charts, themes, sliver utilities, and cross-platform adaptive widgets.
- **`packages/hippo_utils`** – Cross‑platform utility wrappers and convenience exports for frequently used packages (files, sharing, purchases, URL launching, reactive streams, BLoC helpers, etc.).
- **`packages/hippo_auth`** – Authentication and authorization utilities for Hipposphere applications.
- **`packages/hippo_ui`** – Additional UI components and design system extensions.
- **`packages/dictation_support`** – Support dictation devices using the hid_api package.
- **`packages/hid_api`** – Human Interface Device (HID) API bindings for native device communication.
- **`packages/postgres_base_models`** – Base models and utilities for PostgreSQL database interactions.
- **`packages/postgres_models_builder`** – Code generation tools for PostgreSQL model creation and management.

## Quick Start

New to the project? Start with our [Getting Started Guide](GETTING_STARTED.md) for detailed setup instructions.

**TL;DR for experienced developers:**
```bash
# Clone and setup
git clone https://github.com/flowhorn/hippo-packages.git
cd hippo-packages
dart run melos bootstrap

# Verify setup
dart analyze .
dart run melos run ci
```

## Package Overview

## Package Overview

### `hippo_components`  [→ detailed README](packages/hippo_components/README.md)
**Focus**: Comprehensive UI component library and design system building blocks.

**Highlights**:
- **Modal System**: Info dialogs, confirmations, text input, file selection, and multi-select interfaces
- **UI Components**: Buttons, cards, form elements, theme system, and adaptive widgets
- **Charts & Visualizations**: Study plan timelines, year heatmaps, and stacked bar charts
- **Sliver Utilities**: Advanced scrollable layouts with `SliverColumn`, `SliverGap`, `SliverExpansion`
- **Internationalization**: ARB-based localization with generated translations
- **Asset Management**: Lottie animations and centralized asset handling
- **Developer Tools**: Toast system, list controllers, and utility components

**Import**:
```dart
import 'package:hippo_components/hippo_components.dart';
```

### `hippo_utils`  [→ detailed README](packages/hippo_utils/README.md)
**Focus**: Unified wrappers and curated exports around widely used third‑party packages plus internal utilities.

**Highlights**:
- **Convenience Re-exports**: `filesize`, `url_launcher`, `share_plus`, `rxdart`, and more
- **BLoC Utilities**: Provider facilitation, typed base classes, and reactive patterns
- **Storage Abstractions**: `store`, `file_store`, `key_value_store` interfaces
- **Stream Extensions**: Reactive data subjects and stream manipulation utilities
- **Cross-platform Helpers**: Unified APIs for platform-specific functionality

**Import**:
```dart
import 'package:hippo_utils/hippo_utils.dart';
```

### `hippo_auth`  [→ detailed README](packages/hippo_auth/README.md)
**Focus**: Authentication and authorization utilities for secure application access.

**Features**: User authentication, session management, and security utilities for Hipposphere applications.

### `hippo_ui`  [→ detailed README](packages/hippo_ui/README.md)
**Focus**: Extended UI components and design system additions.

**Features**: Additional UI components that complement the core `hippo_components` library.

### `dictation_support`  [→ detailed README](packages/dictation_support/README.md)
**Focus**: Speech recognition and dictation capabilities.

**Features**: Flutter integration for speech-to-text functionality and voice input support.

### `hid_api`  [→ detailed README](packages/hid_api/README.md)
**Focus**: Human Interface Device (HID) API bindings for native device communication.

**Features**: 
- **Native Bindings**: FFI-based integration with HID APIs
- **Device Communication**: Direct communication with USB and Bluetooth HID devices
- **Cross-platform Support**: Windows, macOS, and Linux compatibility

### `postgres_base_models`  [→ detailed README](packages/postgres_base_models/README.md)
**Focus**: Foundation models and utilities for PostgreSQL database operations.

**Features**: Base classes, interfaces, and utilities for PostgreSQL data modeling and database interactions.

### `postgres_models_builder`  [→ detailed README](packages/postgres_models_builder/README.md)
**Focus**: Code generation tools for PostgreSQL model creation.

**Features**: Automated model generation, database schema management, and type-safe database operations.

## Development

For detailed development instructions, see:
- **[Getting Started Guide](GETTING_STARTED.md)** - Setup instructions and prerequisites
- **[Contributing Guide](CONTRIBUTING.md)** - Development workflow and guidelines

**Common Commands:**
```bash
dart run melos bootstrap      # Setup workspace
dart run melos run ci         # Run quality checks
dart run melos exec -- <cmd>  # Run command in all packages
```

## Contribution Guidelines

Please read our [Contributing Guide](CONTRIBUTING.md) for detailed information about:

- Development workflow and branch strategy
- Code standards and formatting requirements
- Testing guidelines and coverage expectations
- Documentation requirements
- Pull request process and review guidelines
- Package creation and API design principles

### Quick Start for Contributors

1. **Keep public APIs stable**: Document breaking changes in each package `CHANGELOG.md`
2. **Follow commit conventions**: Use [Conventional Commits](https://www.conventionalcommits.org/) format
3. **Ensure quality**: Run `dart run melos run ci` before submitting PRs
4. **Update documentation**: Keep README files and inline documentation current
5. **Add tests**: Include unit tests for new functionality

For detailed guidelines, see [CONTRIBUTING.md](CONTRIBUTING.md).

## Creating New Packages

To add a new package to the monorepo, see the detailed guide in [CONTRIBUTING.md](CONTRIBUTING.md#creating-a-new-package--plugin).

**Quick steps:**
1. Create package with appropriate template
2. Add to workspace in root `pubspec.yaml`
3. Run `dart run melos bootstrap`
4. Follow package structure guidelines

## Licensing

Each package includes its own `LICENSE`. Unless otherwise noted, they are published under their respective licenses. Verify individual package terms before external redistribution.

## Support & Questions

For internal teams: reach out in the Hipposphere developer channel. For external discussions, open an issue or a discussion thread in this repository.

---

Happy building with Hipposphere components & utilities! 🦛

