part of '../app_settings.dart';

enum AppThemeMode {
  system,
  light,
  dark;

  Brightness toBrightness(Brightness systemBrightness) {
    return switch (this) {
      system => systemBrightness,
      light => Brightness.light,
      dark => Brightness.dark,
    };
  }
}
