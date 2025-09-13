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

class NavigatorKeyBloc extends BlocBase {
  final GlobalKey<NavigatorState> navigatorKey;
  final NavigatorObserver Function()? navigatorObserverBuilder;

  const NavigatorKeyBloc({required this.navigatorKey, this.navigatorObserverBuilder});

  BuildContext get currentContext => navigatorKey.currentContext!;

  @override
  void dispose() {}

  static NavigatorKeyBloc of(BuildContext context) {
    return BlocProvider.of<NavigatorKeyBloc>(context);
  }
}
