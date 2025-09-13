# Contributing to Hippo Packages

Thank you for your interest in contributing to the Hippo Packages monorepo! This guide will help you get started with contributing to our Flutter and Dart packages.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Package Guidelines](#package-guidelines)
- [Code Standards](#code-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Submitting Changes](#submitting-changes)
- [Release Process](#release-process)

## Code of Conduct

We are committed to providing a welcoming and inclusive environment for all contributors. Please be respectful and professional in all interactions.

## Getting Started

### Prerequisites

- **Dart SDK**: `>=3.9.2 <4.0.0` (as defined in `pubspec.yaml`)
- **Flutter**: Latest stable version (for Flutter packages)
- **Git**: Version control
- **IDE**: VS Code, IntelliJ, or Android Studio with Dart/Flutter plugins

### Initial Setup

1. **Fork and Clone**
   ```bash
   git clone https://github.com/hipposphere/hippo-packages.git
   cd hippo-packages
   ```

2. **Bootstrap the Workspace**
   ```bash
   dart run melos bootstrap
   ```

3. **Verify Setup**
   ```bash
   dart run melos list
   dart analyze .
   ```

## Development Workflow

### Branch Strategy

- **`main`**: Stable production branch
- **Feature branches**: `feature/description` or `feat/package-name/feature`
- **Bug fixes**: `fix/description` or `fix/package-name/issue`
- **Documentation**: `docs/description`

### Making Changes

1. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Your Changes**
   - Follow our [Code Standards](#code-standards)
   - Update relevant documentation
   - Add or update tests

3. **Test Your Changes**
   ```bash
   dart run melos run ci  # Runs format check and tests
   ```

4. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat(package_name): add new feature"
   ```

### Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Scopes:**
- Package names: `hippo_components`, `hippo_utils`, etc.
- `workspace`: For monorepo-wide changes
- `ci`: For CI/CD changes

**Examples:**
```
feat(hippo_components): add new modal component
fix(hippo_utils): resolve file picker issue on iOS
docs(hippo_components): update component usage examples
chore(workspace): update dependencies
```

## Package Guidelines

### Package Structure

Each package should follow this structure:
```
packages/package_name/
├── lib/
│   ├── package_name.dart          # Barrel export file
│   └── src/                       # Internal implementation
├── test/                          # Unit tests
├── example/                       # Usage examples (optional)
├── README.md                      # Package documentation
├── CHANGELOG.md                   # Version history
├── pubspec.yaml                   # Dependencies and metadata
└── analysis_options.yaml         # Linting rules
```

### Naming Conventions

- **Packages**: `hippo_` prefix, lowercase with underscores
- **Files**: lowercase with underscores (`my_widget.dart`)
- **Classes**: PascalCase (`MyWidget`)
- **Functions/Variables**: camelCase (`myFunction`)
- **Constants**: UPPER_SNAKE_CASE (`MY_CONSTANT`)

### API Design Principles

1. **Consistency**: Follow Flutter/Dart conventions
2. **Simplicity**: Keep APIs minimal and focused
3. **Extensibility**: Design for future enhancements
4. **Documentation**: Every public API should be documented
5. **Breaking Changes**: Avoid when possible, document when necessary

## Code Standards

### Formatting

- **Dart Format**: Use `dart format` for consistent formatting
- **Line Length**: 80 characters (configurable in IDE)
- **Imports**: Organize as dart, flutter, package, relative

```dart
// Dart core libraries
import 'dart:async';

// Flutter libraries
import 'package:flutter/material.dart';

// External packages
import 'package:provider/provider.dart';

// Internal packages
import 'package:hippo_utils/hippo_utils.dart';

// Relative imports
import '../widgets/my_widget.dart';
```

### Documentation

- **Public APIs**: Must have documentation comments
- **Complex Logic**: Add inline comments for clarity
- **Examples**: Include usage examples in documentation

```dart
/// A modal dialog that displays information to the user.
/// 
/// This widget creates a platform-adaptive modal that can display
/// a title, message, and optional actions.
/// 
/// Example:
/// ```dart
/// showInfoModal(
///   context,
///   title: 'Welcome',
///   message: 'Welcome to the app!',
/// );
/// ```
class InfoModal extends StatelessWidget {
  /// Creates an information modal.
  /// 
  /// The [title] and [message] parameters are required.
  const InfoModal({
    super.key,
    required this.title,
    required this.message,
    this.actions,
  });

  /// The title of the modal.
  final String title;

  /// The message content of the modal.
  final String message;

  /// Optional action buttons for the modal.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    // Implementation...
  }
}
```

### Error Handling

- Use appropriate exception types
- Provide meaningful error messages
- Handle edge cases gracefully

```dart
/// Loads user data from the API.
/// 
/// Throws [NetworkException] if the request fails.
/// Throws [ValidationException] if the data is invalid.
Future<User> loadUser(String userId) async {
  if (userId.isEmpty) {
    throw ArgumentError('User ID cannot be empty');
  }

  try {
    final response = await api.getUser(userId);
    return User.fromJson(response.data);
  } on NetworkException {
    rethrow;
  } catch (e) {
    throw NetworkException('Failed to load user: $e');
  }
}
```

## Testing

### Test Structure

- **Unit Tests**: Test individual functions and classes
- **Widget Tests**: Test UI components in isolation
- **Integration Tests**: Test complete user flows (future)

### Test Guidelines

1. **Coverage**: Aim for high test coverage on public APIs
2. **Naming**: Descriptive test names that explain the scenario
3. **Arrange-Act-Assert**: Structure tests clearly
4. **Mocking**: Use mocks for external dependencies

```dart
void main() {
  group('InfoModal', () {
    testWidgets('displays title and message', (tester) async {
      // Arrange
      const title = 'Test Title';
      const message = 'Test Message';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: InfoModal(
            title: title,
            message: message,
          ),
        ),
      );

      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('calls onPressed when action is tapped', (tester) async {
      // Test implementation...
    });
  });
}
```

### Running Tests

```bash
# Run all tests
dart run melos run test

# Run tests for specific package
cd packages/hippo_components
flutter test

# Run with coverage
flutter test --coverage
```

## Documentation

### README Requirements

Each package must have a comprehensive README.md including:

1. **Package Description**: What the package does
2. **Installation**: How to add the dependency
3. **Usage Examples**: Code examples showing key features
4. **API Documentation**: Links to generated docs
5. **Contributing**: Link to this file

### Changelog

- Follow [Keep a Changelog](https://keepachangelog.com/) format
- Document all changes in `CHANGELOG.md`
- Update version in `pubspec.yaml`

```markdown
## [0.2.0] - 2024-09-13

### Added
- New modal component with customizable actions
- Support for dark theme in all components

### Changed
- Improved performance of chart rendering
- Updated minimum Flutter version to 3.35.0

### Fixed
- Fixed memory leak in list view controller
- Resolved theme inconsistencies on iOS

### Breaking Changes
- Renamed `showDialog` to `showModal` for consistency
```

## Submitting Changes

### Pull Request Process

1. **Update Documentation**
   - Update README.md if API changes
   - Update CHANGELOG.md with your changes
   - Ensure all code is documented

2. **Run Quality Checks**
   ```bash
   dart run melos run ci
   dart analyze .
   ```

3. **Create Pull Request**
   - Use descriptive title following conventional commits
   - Fill out the PR template completely
   - Link related issues
   - Request review from maintainers

4. **Address Feedback**
   - Respond to review comments promptly
   - Make requested changes
   - Update tests if needed

### PR Template

```markdown
## Description
Brief description of the changes made.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Widget tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
```

## Release Process

### Version Management

We use [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Steps

1. **Update Version**
   ```yaml
   # pubspec.yaml
   version: 1.2.3
   ```

2. **Update Changelog**
   ```markdown
   ## [1.2.3] - 2024-09-13
   ```

3. **Create Release PR**
   - Title: `release: v1.2.3`
   - Include all changes since last release

4. **Tag Release**
   ```bash
   git tag v1.2.3
   git push origin v1.2.3
   ```

### Publishing Packages

```bash
# Dry run to check for issues
dart pub publish --dry-run

# Publish to registry
dart pub publish
```

## Getting Help

- **Questions**: Open a discussion in the repository
- **Bugs**: Create an issue with reproduction steps
- **Feature Requests**: Open an issue with detailed requirements
- **Internal Teams**: Reach out in the Hipposphere developer channel

## Additional Resources

- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Widget Testing](https://docs.flutter.dev/testing/widget-tests)
- [Melos Documentation](https://melos.invertase.dev/)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

Thank you for contributing to Hippo Packages! Your contributions help make our Flutter development ecosystem better for everyone. 🦛