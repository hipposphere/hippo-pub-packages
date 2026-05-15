import 'package:flutter/material.dart';

part 'parts/locale.dart';
part 'parts/theme_mode.dart';

class AppSettings {
  final AppThemeMode themeMode;
  final AppLocale locale;

  const AppSettings({required this.themeMode, required this.locale});

  static const AppSettings $default = AppSettings(
    themeMode: AppThemeMode.system,
    locale: AppLocale.system,
  );

  factory AppSettings.fromData(dynamic data) {
    if (data == null) {
      return $default;
    }
    return AppSettings(
      themeMode: AppThemeMode.values.byName(data['theme_mode']),
      locale: AppLocale.values.byName(data['locale']),
    );
  }

  Map<String, dynamic> toData() {
    return {'theme_mode': themeMode.name, 'locale': locale.name};
  }

  AppSettings copyWith({AppThemeMode? themeMode, AppLocale? locale}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}
