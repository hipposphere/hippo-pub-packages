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
import 'package:hippo_utils/hippo_utils.dart';

import 'onboarding_step.dart';

class OnboardingController<S> {
  final List<OnboardingStep<S>> allSteps;
  final DataSubject<S> stateSubject;
  final DataSubject<List<OnboardingStep<S>>> enabledStepsSubject;
  final DataSubject<int> currentIndexSubject;
  PageController pageController;

  final Duration animationDuration;
  final Curve animationCurve;

  bool _isAnimating = false;
  bool _isDisposed = false;

  factory OnboardingController({
    required List<OnboardingStep<S>> steps,
    required S initialState,
    int initialVisibleIndex = 0,
    Duration animationDuration = const Duration(milliseconds: 280),
    Curve animationCurve = Curves.easeOutCubic,
  }) {
    assert(steps.isNotEmpty, 'OnboardingController requires at least one step.');
    assert(_hasUniqueStepIds(steps), 'Onboarding step ids must be unique.');

    final resolvedSteps = List<OnboardingStep<S>>.unmodifiable(
      _resolveEnabledSteps<S>(steps, initialState),
    );
    final resolvedInitialIndex = _clampVisibleIndex(initialVisibleIndex, resolvedSteps.length);

    return OnboardingController._(
      allSteps: List<OnboardingStep<S>>.unmodifiable(steps),
      initialState: initialState,
      initialEnabledSteps: resolvedSteps,
      initialVisibleIndex: resolvedInitialIndex,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
    );
  }

  OnboardingController._({
    required this.allSteps,
    required S initialState,
    required List<OnboardingStep<S>> initialEnabledSteps,
    required int initialVisibleIndex,
    required this.animationDuration,
    required this.animationCurve,
  }) : stateSubject = DataSubject<S>.seeded(initialState),
       enabledStepsSubject = DataSubject<List<OnboardingStep<S>>>.seeded(initialEnabledSteps),
       currentIndexSubject = DataSubject<int>.seeded(initialVisibleIndex),
       pageController = PageController(initialPage: initialVisibleIndex);

  S get state => stateSubject.value;

  List<OnboardingStep<S>> get enabledSteps => enabledStepsSubject.value;

  int get currentIndex => currentIndexSubject.value;

  bool get hasEnabledSteps => enabledSteps.isNotEmpty;

  bool get isFirstStep => !hasEnabledSteps || currentIndex <= 0;

  bool get isLastStep => !hasEnabledSteps || currentIndex >= enabledSteps.length - 1;

  bool get canGoBack => hasEnabledSteps && currentIndex > 0;

  bool get canGoForward => hasEnabledSteps && currentIndex < enabledSteps.length - 1;

  OnboardingStep<S>? get currentStep {
    final steps = enabledSteps;
    if (steps.isEmpty) {
      return null;
    }
    final safeIndex = _clampVisibleIndex(currentIndex, steps.length);
    return steps[safeIndex];
  }

  void updateState(S newState) {
    if (_isDisposed) {
      return;
    }

    final previousCurrentStep = currentStep;
    final previousCanonicalIndex = previousCurrentStep != null
        ? _canonicalIndexByStepId(previousCurrentStep.id)
        : null;

    stateSubject.add(newState);

    final nextEnabledSteps = List<OnboardingStep<S>>.unmodifiable(
      _resolveEnabledSteps<S>(allSteps, newState),
    );
    enabledStepsSubject.add(nextEnabledSteps);

    final nextIndex = _resolveIndexAfterStateUpdate(
      nextEnabledSteps: nextEnabledSteps,
      previousCurrentStep: previousCurrentStep,
      previousCanonicalIndex: previousCanonicalIndex,
    );

    _setCurrentIndexWithoutAnimation(nextIndex);
  }

  Future<void> goToIndex(int visibleIndex, {bool animated = true}) async {
    if (_isDisposed) {
      return;
    }

    final steps = enabledSteps;
    if (steps.isEmpty) {
      _setCurrentIndexWithoutAnimation(0);
      return;
    }

    final targetIndex = _clampVisibleIndex(visibleIndex, steps.length);

    if (animated && _isAnimating) {
      return;
    }

    if (currentIndexSubject.value != targetIndex) {
      currentIndexSubject.add(targetIndex);
    }

    if (pageController.positions.isEmpty) {
      _replacePageController(targetIndex);
      return;
    }

    if (!animated) {
      pageController.jumpToPage(targetIndex);
      return;
    }

    _isAnimating = true;
    try {
      await pageController.animateToPage(
        targetIndex,
        duration: animationDuration,
        curve: animationCurve,
      );
    } finally {
      _isAnimating = false;
    }
  }

  Future<void> goToStepId(String stepId, {bool animated = true}) {
    final targetIndex = enabledSteps.indexWhere((step) => step.id == stepId);
    if (targetIndex == -1) {
      return Future.value();
    }
    return goToIndex(targetIndex, animated: animated);
  }

  Future<void> next() {
    if (!canGoForward) {
      return Future.value();
    }
    return goToIndex(currentIndex + 1);
  }

  Future<void> back() {
    if (!canGoBack) {
      return Future.value();
    }
    return goToIndex(currentIndex - 1);
  }

  void syncFromPageChanged(int visibleIndex) {
    if (_isDisposed) {
      return;
    }
    final steps = enabledSteps;
    final safeIndex = _clampVisibleIndex(visibleIndex, steps.length);
    if (currentIndexSubject.value != safeIndex) {
      currentIndexSubject.add(safeIndex);
    }
  }

  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    pageController.dispose();
    stateSubject.close();
    enabledStepsSubject.close();
    currentIndexSubject.close();
  }

  int _resolveIndexAfterStateUpdate({
    required List<OnboardingStep<S>> nextEnabledSteps,
    required OnboardingStep<S>? previousCurrentStep,
    required int? previousCanonicalIndex,
  }) {
    if (nextEnabledSteps.isEmpty) {
      return 0;
    }

    if (previousCurrentStep != null) {
      final currentStepIndex = nextEnabledSteps.indexWhere(
        (step) => step.id == previousCurrentStep.id,
      );
      if (currentStepIndex != -1) {
        return currentStepIndex;
      }
    }

    if (previousCanonicalIndex != null) {
      final fallbackIndex = _resolveForwardThenBackwardIndex(
        nextEnabledSteps: nextEnabledSteps,
        previousCanonicalIndex: previousCanonicalIndex,
      );
      if (fallbackIndex != null) {
        return fallbackIndex;
      }
    }

    return _clampVisibleIndex(currentIndexSubject.value, nextEnabledSteps.length);
  }

  int? _resolveForwardThenBackwardIndex({
    required List<OnboardingStep<S>> nextEnabledSteps,
    required int previousCanonicalIndex,
  }) {
    final visibleIndexById = <String, int>{
      for (int i = 0; i < nextEnabledSteps.length; i++) nextEnabledSteps[i].id: i,
    };

    for (int i = previousCanonicalIndex + 1; i < allSteps.length; i++) {
      final visibleIndex = visibleIndexById[allSteps[i].id];
      if (visibleIndex != null) {
        return visibleIndex;
      }
    }

    for (int i = previousCanonicalIndex - 1; i >= 0; i--) {
      final visibleIndex = visibleIndexById[allSteps[i].id];
      if (visibleIndex != null) {
        return visibleIndex;
      }
    }

    return null;
  }

  int _canonicalIndexByStepId(String stepId) {
    return allSteps.indexWhere((step) => step.id == stepId);
  }

  void _setCurrentIndexWithoutAnimation(int targetIndex) {
    if (_isDisposed) {
      return;
    }

    final safeIndex = _clampVisibleIndex(targetIndex, enabledSteps.length);
    if (currentIndexSubject.value != safeIndex) {
      currentIndexSubject.add(safeIndex);
    }

    if (pageController.positions.isNotEmpty) {
      pageController.jumpToPage(safeIndex);
      return;
    }

    _replacePageController(safeIndex);
  }

  void _replacePageController(int initialPage) {
    final previousPageController = pageController;
    pageController = PageController(initialPage: initialPage);
    previousPageController.dispose();
  }

  static bool _hasUniqueStepIds<T>(List<OnboardingStep<T>> steps) {
    final ids = <String>{};
    for (final step in steps) {
      if (!ids.add(step.id)) {
        return false;
      }
    }
    return true;
  }

  static List<OnboardingStep<T>> _resolveEnabledSteps<T>(List<OnboardingStep<T>> steps, T state) {
    return steps.where((step) => step.isEnabledFor(state)).toList(growable: false);
  }

  static int _clampVisibleIndex(int visibleIndex, int visibleCount) {
    if (visibleCount <= 0) {
      return 0;
    }
    return visibleIndex.clamp(0, visibleCount - 1).toInt();
  }
}
