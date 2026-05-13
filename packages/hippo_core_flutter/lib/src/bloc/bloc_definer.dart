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

import 'bloc_provider.dart';

/// A bloc definer doesn't have a child compared to a usual [BlocProvider].
/// It requires the child to be given when converting it to a [BlocProvider]
/// using [toBlocProvider] or with a [MultiBlocProvider].
class BlocDefiner<T extends BlocBase> {
  const BlocDefiner({required this.bloc});

  final T bloc;

  BlocProvider<T> toBlocProvider(Widget child) {
    return BlocProvider<T>(bloc: bloc, child: child);
  }
}
