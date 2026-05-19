import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hippo_flutter_app_architecture/src/app_state/app_state_bloc.dart';

class AppStateBuilder<T, TData> extends StatefulWidget {
  final AppStateBloc<T> appStateBloc;
  final Future<TData> Function(T appState) dataBuilder;
  final bool Function(T appState, T oldAppState) shouldRebuild;
  final Widget Function(BuildContext context, TData? data) builder;

  const AppStateBuilder({
    super.key,
    required this.appStateBloc,
    required this.dataBuilder,
    required this.builder,
    required this.shouldRebuild,
  });

  @override
  State<AppStateBuilder> createState() => _AppStateBuilderState();
}

class _AppStateBuilderState<T, TData> extends State<AppStateBuilder<T, TData>> {
  TData? _data;

  StreamSubscription? _streamSubscription;

  @override
  void initState() async {
    super.initState();

    _setData(await widget.dataBuilder(widget.appStateBloc.stateSubject.value));

    _streamSubscription = widget.appStateBloc.stateSubject.listen((
      appState,
    ) async {
      _setData(await widget.dataBuilder(appState));
    });
  }

  void _setData(TData data) {
    setState(() {
      _data = data;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _data);
  }
}
