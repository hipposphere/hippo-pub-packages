import 'package:flutter/widgets.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
import 'app_settings.dart';
import 'app_settings_bloc.dart';

class AppSettingsBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, AppSettings? appSettings) builder;
  const AppSettingsBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final bloc = AppSettingsBloc.of(context);
    return DataSubjectBuilder(subject: bloc.settingsSubject, builder: builder);
  }
}

/// This is an unsafe version of [AppSettingsBuilder] that does not provide
/// type safety for the [AppSettings] object.
class AppSettingsUnsafeBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, AppSettings appSettings) builder;
  const AppSettingsUnsafeBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final bloc = AppSettingsBloc.of(context);
    return DataSubjectBuilder(
      subject: bloc.settingsSubject,
      builder: (context, appSettings) => builder(context, appSettings!),
    );
  }
}
