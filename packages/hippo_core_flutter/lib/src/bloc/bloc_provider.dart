/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter/widgets.dart';
import 'package:hippo_core/hippo_core.dart';

class BlocProvider<T extends BlocBase> extends InheritedWidget {
  const BlocProvider({super.key, required this.bloc, required super.child});

  final T bloc;

  static T? maybeOf<T extends BlocBase>(BuildContext context) {
    final provider = context.getInheritedWidgetOfExactType<BlocProvider<T>>();
    return provider?.bloc;
  }

  static T of<T extends BlocBase>(BuildContext context) {
    final provider = context.getInheritedWidgetOfExactType<BlocProvider<T>>();
    if (provider == null) {
      throw """A BlocProvider ancestor with Type ${_typeOf<BlocProvider<T>>()} should be given in the widget tree.
If this is not true this probably means that BlocProvider.of<$T>(context)
was called while no BlocProvider with Type of $T was created in an
ancestor widget.""";
    }

    return provider.bloc;
  }

  static Type _typeOf<T>() => T;

  BlocProvider<T> copyWith(Widget child) {
    return BlocProvider<T>(key: key, bloc: bloc, child: child);
  }

  @override
  bool updateShouldNotify(BlocProvider<T> oldWidget) {
    return oldWidget.bloc != bloc;
  }
}
