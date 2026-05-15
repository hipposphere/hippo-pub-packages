part of '../app_settings.dart';

enum AppLocale {
  system,
  en,
  de,
  zh;

  Locale toLocale(Locale systemLocale) {
    return switch (this) {
      system => systemLocale,
      en => Locale('en'),
      de => Locale('de'),
      zh => Locale('zh'),
    };
  }

  String toLocaleName(BuildContext context) {
    return switch (this) {
      system => 'System',
      en => 'English',
      de => 'Deutsch',
      zh => '中文',
    };
  }
}
