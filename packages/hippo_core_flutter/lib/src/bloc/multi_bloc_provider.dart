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

import 'bloc_definer.dart';

class MultiBlocProvider extends StatelessWidget {
  const MultiBlocProvider({super.key, required this.blocDefiners, required this.child});

  final List<BlocDefiner> blocDefiners;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget tree = child;
    for (final blocProvider in blocDefiners.reversed) {
      tree = blocProvider.toBlocProvider(tree);
    }
    return tree;
  }
}
