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
import 'package:flutter/widget_previews.dart';
import 'package:hippo_components/hippo_components.dart';

Widget onboardingPreviewWrapper(Widget child) {
  return Builder(
    builder: (context) {
      final brightness = MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.light;
      return HippoThemeBuilder(
        brightness: brightness,
        child: Material(child: child),
      );
    },
  );
}

PreviewLocalizationsData onboardingPreviewLocalizations() {
  return const PreviewLocalizationsData(
    locale: Locale('en'),
    supportedLocales: ComponentsLocalizations.supportedLocales,
    localizationsDelegates: ComponentsLocalizations.localizationsDelegates,
  );
}

@Preview(
  group: 'Onboarding',
  name: 'Light - Full Flow',
  size: Size(390, 844),
  wrapper: onboardingPreviewWrapper,
  localizations: onboardingPreviewLocalizations,
  brightness: Brightness.light,
)
Widget onboardingLightPreview() {
  return const _OnboardingPreviewHost(
    initialState: _OnboardingPreviewState(hasGrantedPermissions: false, isPowerUser: true),
  );
}

@Preview(
  group: 'Onboarding',
  name: 'Dark - Full Flow',
  size: Size(390, 844),
  wrapper: onboardingPreviewWrapper,
  localizations: onboardingPreviewLocalizations,
  brightness: Brightness.dark,
)
Widget onboardingDarkPreview() {
  return const _OnboardingPreviewHost(
    initialState: _OnboardingPreviewState(hasGrantedPermissions: false, isPowerUser: true),
  );
}

@Preview(
  group: 'Onboarding',
  name: 'Conditional - Hidden Steps',
  size: Size(390, 844),
  wrapper: onboardingPreviewWrapper,
  localizations: onboardingPreviewLocalizations,
  brightness: Brightness.light,
)
Widget onboardingConditionalPreview() {
  return const _OnboardingPreviewHost(
    initialState: _OnboardingPreviewState(hasGrantedPermissions: true, isPowerUser: false),
  );
}

class _OnboardingPreviewHost extends StatefulWidget {
  final _OnboardingPreviewState initialState;
  const _OnboardingPreviewHost({required this.initialState});

  @override
  State<_OnboardingPreviewHost> createState() => _OnboardingPreviewHostState();
}

class _OnboardingPreviewHostState extends State<_OnboardingPreviewHost> {
  late final OnboardingController<_OnboardingPreviewState> _controller;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingController<_OnboardingPreviewState>(
      initialState: widget.initialState,
      steps: const [
        OnboardingStep<_OnboardingPreviewState>(
          id: 'welcome',
          title: 'Welcome to Hippo',
          description: 'Get to know the main features in under a minute.',
        ),
        OnboardingStep<_OnboardingPreviewState>(
          id: 'permissions',
          title: 'Enable Permissions',
          description: 'Allow notifications so reminders arrive on time.',
          isEnabled: _showPermissionsStep,
        ),
        OnboardingStep<_OnboardingPreviewState>(
          id: 'power-user',
          title: 'Power User Shortcuts',
          description: 'Learn keyboard and workflow shortcuts for faster usage.',
          isEnabled: _showPowerUserStep,
        ),
        OnboardingStep<_OnboardingPreviewState>(
          id: 'finish',
          title: 'You Are Ready',
          description: 'Everything is set up. Start exploring the app.',
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingView<_OnboardingPreviewState>(
      controller: _controller,
      onFinished: () {},
      onSkipped: (currentVisibleIndex, currentStep) {},
    );
  }
}

class _OnboardingPreviewState {
  final bool hasGrantedPermissions;
  final bool isPowerUser;

  const _OnboardingPreviewState({required this.hasGrantedPermissions, required this.isPowerUser});
}

bool _showPermissionsStep(_OnboardingPreviewState state) => !state.hasGrantedPermissions;

bool _showPowerUserStep(_OnboardingPreviewState state) => state.isPowerUser;
