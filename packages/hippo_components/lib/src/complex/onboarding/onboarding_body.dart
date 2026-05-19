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
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

import 'onboarding_controller.dart';
import 'onboarding_step.dart';

class OnboardingBody<S> extends StatelessWidget {
  final OnboardingController<S> controller;
  final bool allowUserSwipe;
  final double maxContentWidth;
  final EdgeInsetsGeometry contentPadding;
  final OnboardingStepWidgetBuilder<S>? stepBuilder;

  const OnboardingBody({
    super.key,
    required this.controller,
    this.allowUserSwipe = true,
    this.maxContentWidth = 540,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.stepBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return DataSubjectBuilder<List<OnboardingStep<S>>>(
      subject: controller.enabledStepsSubject,
      builder: (context, enabledSteps) {
        if (enabledSteps.isEmpty) {
          return const SizedBox.shrink();
        }

        return PageView.builder(
          controller: controller.pageController,
          physics: allowUserSwipe ? null : const NeverScrollableScrollPhysics(),
          itemCount: enabledSteps.length,
          onPageChanged: controller.syncFromPageChanged,
          itemBuilder: (context, index) {
            final step = enabledSteps[index];
            if (stepBuilder != null) {
              return stepBuilder!(context, step, index, enabledSteps.length);
            }

            return _DefaultOnboardingStep<S>(
              step: step,
              maxContentWidth: maxContentWidth,
              contentPadding: contentPadding,
            );
          },
        );
      },
    );
  }
}

class _DefaultOnboardingStep<S> extends StatelessWidget {
  final OnboardingStep<S> step;
  final double maxContentWidth;
  final EdgeInsetsGeometry contentPadding;

  const _DefaultOnboardingStep({
    required this.step,
    required this.maxContentWidth,
    required this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: contentPadding,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (step.mediaBuilder != null) ...[
                  Builder(builder: step.mediaBuilder!),
                  const SizedBox(height: 24),
                ],
                Text(
                  step.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (step.description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    step.description!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                if (step.customContentBuilder != null) ...[
                  const SizedBox(height: 24),
                  Builder(builder: step.customContentBuilder!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
