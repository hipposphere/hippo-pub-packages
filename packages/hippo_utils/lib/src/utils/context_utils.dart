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
import 'package:hippo_utils/hippo_utils.dart';

extension UtilsContextExtension on BuildContext {
  GlobalKey<NavigatorState> get navigatorKey {
    return NavigatorKeyBloc.of(this).navigatorKey;
  }

  Size get mediaSize => MediaQuery.sizeOf(this);

  bool get isDesktop => mediaSize.width >= 850.0;
}
