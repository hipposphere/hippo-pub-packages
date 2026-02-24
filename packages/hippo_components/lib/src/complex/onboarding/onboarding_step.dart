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

typedef OnboardingStepEnabled<S> = bool Function(S state);

typedef OnboardingStepWidgetBuilder<S> =
    Widget Function(
      BuildContext context,
      OnboardingStep<S> step,
      int visibleIndex,
      int visibleCount,
    );

class OnboardingStep<S> {
  final String id;
  final String title;
  final String? description;
  final WidgetBuilder? mediaBuilder;
  final WidgetBuilder? customContentBuilder;
  final OnboardingStepEnabled<S>? isEnabled;

  const OnboardingStep({
    required this.id,
    required this.title,
    this.description,
    this.mediaBuilder,
    this.customContentBuilder,
    this.isEnabled,
  });

  bool isEnabledFor(S state) {
    return isEnabled?.call(state) ?? true;
  }
}
