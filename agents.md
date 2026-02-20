# Agents & Tooling Context

This repository uses [Melos](https://melos.invertase.dev/) for managing Dart/Flutter monorepos.

## Useful Links

- **Melos Documentation:** [https://melos.invertase.dev/](https://melos.invertase.dev/)
- **Melos on pub.dev:** [https://pub.dev/packages/melos](https://pub.dev/packages/melos)
- **Dart API Docs:** [https://api.dart.dev/stable/](https://api.dart.dev/stable/)
- **Flutter API Docs:** [https://api.flutter.dev/](https://api.flutter.dev/)
- **Dart Packages:** [https://pub.dev/](https://pub.dev/)

## Getting Latest APIs as Context

- Use the above links to always access the latest Melos, Dart, and Flutter APIs.
- For Melos CLI usage and scripts, refer to the [Melos CLI Reference](https://melos.invertase.dev/cli/commands).

---

For more information, see the project README or the documentation for each package in the `packages/` directory.

## Dart Code Generation Guidance

- Prefer `package:code_builder` for generating Dart classes, constructors, members, and initializer lists instead of handwritten source string assembly.
- Run generated Dart output through `package:dart_style` (`DartFormatter`) before writing files.

## Refactorings

- Do not add legacy/manual fallback methods. Embrace Breaking Changes for an improved code basis and cleaner code quality.
