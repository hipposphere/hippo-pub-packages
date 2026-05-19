import 'package:flutter/widgets.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
import 'package:hippo_flutter_app_architecture/src/app_state/app_state_loader.dart';

class AppStateBloc<T> extends BlocBase {
  final AppStateLoader<T> appStateLoader;

  AppStateBloc(this.appStateLoader) {
    stateSubject.add(appStateLoader.initialAppState);
  }

  final stateSubject = DataSubject<T>.empty();

  static AppStateBloc<T> of<T>(BuildContext context) {
    return BlocProvider.of<AppStateBloc<T>>(context);
  }

  @override
  void dispose() {
    stateSubject.close();
  }
}
