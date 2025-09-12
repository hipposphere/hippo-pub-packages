import 'package:flutter/material.dart';
import 'package:hippo_utils/hippo_utils.dart';

/// A Bloc definer doesn't have a child compared to a usual BlocProvider.
/// It requires the child to be given when converting it to a BlocProvider using
/// [toBlocProvider] or with a [MultiBlocProvider].
class BlocDefiner<T extends BlocBase> {
  const BlocDefiner({required this.bloc});

  final T bloc;

  BlocProvider<T> toBlocProvider(Widget child) {
    return BlocProvider<T>(bloc: bloc, child: child);
  }
}
