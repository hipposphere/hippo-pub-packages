import 'package:flutter/widgets.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
import 'app_settings.dart';

class AppSettingsBloc extends BlocBase {
  final StoreController<AppSettings> _storeController;

  AppSettingsBloc({
    required KeyValueStore keyValueStore,
    AppSettings? initialAppSettings,
  }) : _storeController = StoreController<AppSettings>(
         keyValueStore: keyValueStore,
         storeKey: 'app_settings',
         defaultValue: AppSettings.$default,
         itemDecoder: (data) => AppSettings.fromData(data),
         itemEncoder: (appSettings) => appSettings.toData(),
         initialValue: initialAppSettings,
       );

  DataSubject<AppSettings?> get settingsSubject => _storeController.subject;

  Future<void> updateAppSettings(AppSettings newSettings) async {
    await _storeController.update(newSettings);
  }

  Future<void> updateAppSettingsBuilder(
    AppSettings Function(AppSettings currentSettings) settingsBuilder,
  ) async {
    await _storeController.updateBuilder(builder: settingsBuilder);
  }

  @override
  void dispose() {
    _storeController.dispose();
  }

  static AppSettingsBloc of(BuildContext context) =>
      BlocProvider.of<AppSettingsBloc>(context);
}
