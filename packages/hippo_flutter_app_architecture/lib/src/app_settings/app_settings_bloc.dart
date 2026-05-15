import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
import 'app_settings.dart';

const _appSettingsKey = 'app_settings';

class AppSettingsBloc extends BlocBase {
  final KeyValueStore keyValueStore;

  AppSettingsBloc({
    required this.keyValueStore,
    AppSettings? initialAppSettings,
  }) {
    if (initialAppSettings != null) {
      settingsSubject.add(initialAppSettings);
    }
    _initBloc();
  }

  final settingsSubject = DataSubject<AppSettings?>.seeded(null);

  void _initBloc() async {
    final settings = await _getStoredAppSettings();
    settingsSubject.add(settings);
  }

  Future<void> updateAppSettings(AppSettings newSettings) async {
    settingsSubject.add(newSettings);
    await _storeAppSettings(newSettings);
  }

  Future<void> updateAppSettingsBuilder(
    AppSettings Function(AppSettings currentSettings) settingsBuilder,
  ) async {
    final currentSettings = settingsSubject.value;
    if (currentSettings == null) {
      return;
    }
    final newSettings = settingsBuilder(currentSettings);
    await updateAppSettings(newSettings);
  }

  Future<AppSettings> _getStoredAppSettings() async {
    final data = await keyValueStore.getString(_appSettingsKey);
    if (data == null) {
      return AppSettings.$default;
    }
    return AppSettings.fromData(jsonDecode(data));
  }

  Future<void> _storeAppSettings(AppSettings appSettings) async {
    await keyValueStore.setString(
      _appSettingsKey,
      jsonEncode(appSettings.toData()),
    );
  }

  @override
  void dispose() {
    settingsSubject.close();
  }

  static AppSettingsBloc of(BuildContext context) =>
      BlocProvider.of<AppSettingsBloc>(context);
}
