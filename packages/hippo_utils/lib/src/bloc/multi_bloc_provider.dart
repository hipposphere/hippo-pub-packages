/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter/material.dart';

import 'bloc_definer.dart';

class MultiBlocProvider extends StatelessWidget {
  /// The [BlocDefiner] list which is converted into
  /// a tree of [BlocProvider] widgets.
  ///
  /// The tree of [BlocProvider] widgets is created in order meaning
  /// the first [BlocProvider] will be the top-most [BlocProvider] and
  /// the last [BlocProvider] will be a direct ancestor of the [child] [Widget].
  ///
  /// Each provider's `child` will be discarded, so giving `child` to each
  /// provider makes no sense.
  final List<BlocDefiner> blocDefiners;

  /// The [Widget] and its descendants which will have access to
  /// every `BloC` provided by [blocDefiners].
  ///
  /// This [Widget] will be a direct descendent of
  /// the last [BlocProvider] in [blocDefiners].
  final Widget child;

  const MultiBlocProvider({super.key, required this.blocDefiners, required this.child});

  @override
  Widget build(BuildContext context) {
    Widget tree = child;
    for (final blocProvider in blocDefiners.reversed) {
      tree = blocProvider.toBlocProvider(tree);
    }
    return tree;
  }
}
