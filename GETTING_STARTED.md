# Getting Started with Hippo Packages

This guide will walk you through setting up the Hippo Packages monorepo for development, whether you're contributing to existing packages or creating new ones.

## Prerequisites

Before you begin, ensure you have the following tools installed on your system:

### Required Tools

#### 1. **Dart SDK** (≥3.9.2 <4.0.0)
- **Download**: [dart.dev/get-dart](https://dart.dev/get-dart)
- **Verify installation**: `dart --version`
- **Note**: Flutter includes Dart SDK, so if you have Flutter, you may already have Dart

#### 2. **Flutter SDK** (≥3.35.0)
- **Download**: [docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
- **Verify installation**: `flutter --version`
- **Required for**: Working with `hippo_components` and other Flutter packages

#### 3. **Git**
- **Download**: [git-scm.com](https://git-scm.com/)
- **Verify installation**: `git --version`
- **Required for**: Version control and repository management

### Recommended Tools

#### 4. **IDE with Dart/Flutter Support**
Choose one of the following:

- **VS Code** (Recommended)
  - Install [Dart extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code)
  - Install [Flutter extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
  
## Initial Setup

### 1. Clone the Repository

```bash
# Clone the repository
git clone https://github.com/hipposphere/hippo-packages.git
cd hippo-packages
```

### 2. Verify Prerequisites

Check that all required tools are properly installed:

```bash
# Check Dart version
dart --version

# Check Flutter version (if working with Flutter packages)
flutter --version

# Check Git version
git --version
```

Expected output should show versions meeting the minimum requirements.

### 3. Bootstrap the Workspace

The monorepo uses **Melos** for workspace management. Bootstrap the workspace to install dependencies and link packages:

```bash
# Install dependencies and link packages
dart run melos bootstrap
```

This command will:
- Install dependencies for all packages
- Create symlinks between local packages
- Generate necessary files
- Ensure consistent dependency resolution

### 4. Verify Setup

Confirm everything is working correctly:

```bash
# List all packages in the workspace
dart run melos list

# Run analysis to check for issues
dart analyze .

# Check formatting
dart run melos run check-format
```

If all commands complete without errors, your setup is ready!

## Development Environment Configuration

### VS Code Setup (Recommended)

1. **Open the workspace**:
   ```bash
   code hippo-packages
   ```

2. **Install recommended extensions**:
   - Dart
   - Flutter
   - Error Lens (optional, for better error highlighting)



## Understanding the Workspace Structure

```
hippo-packages/
├── packages/                     # All packages
├── build/                       # Build artifacts
├── pubspec.yaml                # Root workspace configuration
├── melos.yaml                  # Melos configuration (future)
├── README.md                   # Project overview
├── CONTRIBUTING.md             # Contribution guidelines
├── GETTING_STARTED.md          # This file
└── LICENSE                     # License information
```

## Common Development Tasks

### Working with Packages

#### Running Commands Across All Packages
```bash
# Run analysis on all packages
dart run melos exec -- dart analyze .

# Format all packages
dart run melos run format

# Run tests (when available)
dart run melos run test
```

#### Working with Individual Packages
```bash
# Navigate to a specific package
cd packages/hippo_components

# Run package-specific commands
flutter test
dart analyze .
dart format . --set-exit-if-changed
```

#### Adding Dependencies

To add a dependency to a specific package:

1. Edit the package's `pubspec.yaml`
2. Run `dart pub get` in the package directory, or
3. Run `dart run melos bootstrap` from the root to update all packages

### Development Workflow

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Edit code in relevant packages
   - Update documentation as needed
   - Add or update tests

3. **Test your changes**:
   ```bash
   # Run quality checks
   dart run melos run ci
   
   # Run analysis
   dart analyze .
   ```

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat(package_name): add new feature"
   ```

## Troubleshooting Common Issues

### Issue: `dart run melos bootstrap` fails

**Solutions**:
- Ensure Dart SDK is properly installed and in PATH
- Check internet connectivity for package downloads
- Clear pub cache: `dart pub cache clean`
- Delete `.dart_tool` directories and try again

### Issue: IDE doesn't recognize packages

**Solutions**:
- Restart your IDE
- Re-run `dart run melos bootstrap`
- Check IDE Dart/Flutter SDK configuration
- Ensure workspace is opened at the root level

### Issue: Import errors between local packages

**Solutions**:
- Verify packages are listed in root `pubspec.yaml` workspace
- Re-run `dart run melos bootstrap`
- Check package dependencies in individual `pubspec.yaml` files

### Issue: Flutter version conflicts

**Solutions**:
- Ensure Flutter version meets minimum requirements (≥3.35.0)
- Update Flutter: `flutter upgrade`
- Check Flutter doctor: `flutter doctor`

## Melos Commands Reference

Melos is the tool that manages this monorepo. Here are the most commonly used commands:

```bash
# Workspace management
dart run melos bootstrap      # Install dependencies and link packages
dart run melos clean         # Clean all packages
dart run melos list          # List all packages

# Code quality
dart run melos run format    # Format all code
dart run melos run ci        # Run CI checks (format + test)

# Package operations
dart run melos exec -- <cmd> # Run command in all packages
dart run melos version       # Version packages (future)
dart run melos publish       # Publish packages (future)
```

## Next Steps

After completing the setup:

1. **Explore the packages**: Look at the README files in individual packages
2. **Read the contributing guide**: See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines
3. **Check out the examples**: Many packages include example applications
4. **Join the development**: Create your first feature or fix!

## Getting Help

If you encounter issues during setup:

- **Check the troubleshooting section** above
- **Review the contributing guide**: [CONTRIBUTING.md](CONTRIBUTING.md)
- **Open an issue**: For setup problems or documentation improvements
- **Internal teams**: Reach out in the Hipposphere developer channel

---

Happy coding with Hippo Packages! 🦛
