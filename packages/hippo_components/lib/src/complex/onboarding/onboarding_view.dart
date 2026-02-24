/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hippo_components/src/base/buttons/button.dart';
import 'package:hippo_components/src/base/buttons/text.dart';
import 'package:hippo_components/src/base/utils/components_context.dart';
import 'package:hippo_utils/hippo_utils.dart';

import 'onboarding_body.dart';
import 'onboarding_controller.dart';
import 'onboarding_step.dart';
import 'widgets/onboarding_page_indicator.dart';

class OnboardingView<S> extends StatefulWidget {
  final OnboardingController<S> controller;
  final FutureOr<void> Function() onFinished;
  final FutureOr<void> Function(int currentVisibleIndex, OnboardingStep<S>? currentStep)? onSkipped;
  final void Function(int visibleIndex, OnboardingStep<S> step, int visibleCount)? onStepChanged;

  final bool showBackButton;
  final bool showSkipButton;
  final bool allowUserSwipe;
  final String? backLabel;
  final String? nextLabel;
  final String? skipLabel;
  final String? finishLabel;
  final Color? backgroundColor;
  final OnboardingStepWidgetBuilder<S>? stepBuilder;

  const OnboardingView({
    super.key,
    required this.controller,
    required this.onFinished,
    this.onSkipped,
    this.onStepChanged,
    this.showBackButton = true,
    this.showSkipButton = true,
    this.allowUserSwipe = true,
    this.backLabel,
    this.nextLabel,
    this.skipLabel,
    this.finishLabel,
    this.backgroundColor,
    this.stepBuilder,
  });

  @override
  State<OnboardingView<S>> createState() => _OnboardingViewState<S>();
}

class _OnboardingViewState<S> extends State<OnboardingView<S>> {
  StreamSubscription<int>? _indexSubscription;

  bool _isActionInFlight = false;
  bool _hasTriggeredAutoFinishForEmptySteps = false;

  @override
  void initState() {
    super.initState();
    _subscribeToStepChanges();
  }

  @override
  void didUpdateWidget(covariant OnboardingView<S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _indexSubscription?.cancel();
      _subscribeToStepChanges();
      _hasTriggeredAutoFinishForEmptySteps = false;
    }
  }

  @override
  void dispose() {
    _indexSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: DataSubjectBuilder<List<OnboardingStep<S>>>(
          subject: widget.controller.enabledStepsSubject,
          builder: (context, steps) {
            if (steps.isEmpty) {
              _triggerAutoFinishForEmptySteps();
              return const SizedBox.expand();
            }

            _hasTriggeredAutoFinishForEmptySteps = false;

            return Column(
              children: [
                _TopBar<S>(
                  controller: widget.controller,
                  visibleStepCount: steps.length,
                  enabled: !_isActionInFlight,
                  visible: widget.showSkipButton,
                  skipLabel: widget.skipLabel ?? context.cl.actions_skip,
                  onSkipTap: _onSkipTap,
                ),
                Expanded(
                  child: OnboardingBody<S>(
                    controller: widget.controller,
                    allowUserSwipe: widget.allowUserSwipe && !_isActionInFlight,
                    stepBuilder: widget.stepBuilder,
                  ),
                ),
                _BottomBar<S>(
                  controller: widget.controller,
                  visibleStepCount: steps.length,
                  enabled: !_isActionInFlight,
                  showBackButton: widget.showBackButton,
                  backLabel: widget.backLabel ?? context.cl.actions_back,
                  nextLabel: widget.nextLabel ?? context.cl.actions_next,
                  finishLabel: widget.finishLabel ?? context.cl.actions_finish,
                  onBackTap: _onBackTap,
                  onPrimaryTap: _onPrimaryTap,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _subscribeToStepChanges() {
    _indexSubscription = widget.controller.currentIndexSubject.stream.listen((index) {
      final callback = widget.onStepChanged;
      if (callback == null) {
        return;
      }

      final steps = widget.controller.enabledSteps;
      if (steps.isEmpty) {
        return;
      }

      final safeIndex = index.clamp(0, steps.length - 1).toInt();
      callback(safeIndex, steps[safeIndex], steps.length);
    });
  }

  void _triggerAutoFinishForEmptySteps() {
    if (_hasTriggeredAutoFinishForEmptySteps) {
      return;
    }

    _hasTriggeredAutoFinishForEmptySteps = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _runAction(widget.onFinished);
    });
  }

  Future<void> _onBackTap() async {
    if (_isActionInFlight) {
      return;
    }
    await widget.controller.back();
  }

  Future<void> _onPrimaryTap() async {
    if (_isActionInFlight) {
      return;
    }

    if (widget.controller.isLastStep) {
      await _runAction(widget.onFinished);
      return;
    }

    await widget.controller.next();
  }

  Future<void> _onSkipTap() {
    final currentVisibleIndex = widget.controller.currentIndex;
    final currentStep = widget.controller.currentStep;
    return _runAction(() async {
      if (widget.onSkipped != null) {
        await Future.sync(() => widget.onSkipped!(currentVisibleIndex, currentStep));
      }
      await Future.sync(widget.onFinished);
    });
  }

  Future<void> _runAction(FutureOr<void> Function() action) async {
    if (_isActionInFlight) {
      return;
    }

    if (mounted) {
      setState(() {
        _isActionInFlight = true;
      });
    } else {
      _isActionInFlight = true;
    }

    try {
      await Future.sync(action);
    } finally {
      if (mounted) {
        setState(() {
          _isActionInFlight = false;
        });
      } else {
        _isActionInFlight = false;
      }
    }
  }
}

class _TopBar<S> extends StatelessWidget {
  final OnboardingController<S> controller;
  final int visibleStepCount;
  final bool enabled;
  final bool visible;
  final String skipLabel;
  final Future<void> Function() onSkipTap;

  const _TopBar({
    required this.controller,
    required this.visibleStepCount,
    required this.enabled,
    required this.visible,
    required this.skipLabel,
    required this.onSkipTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: DataSubjectBuilder<int>(
          subject: controller.currentIndexSubject,
          builder: (context, currentIndex) {
            if (!visible || visibleStepCount <= 1) {
              return const SizedBox.shrink();
            }

            final safeCurrentIndex = currentIndex.clamp(0, visibleStepCount - 1).toInt();
            final isLastVisibleStep = safeCurrentIndex >= visibleStepCount - 1;
            if (isLastVisibleStep) {
              return const SizedBox.shrink();
            }

            return TextTappable(label: skipLabel, onTap: enabled ? onSkipTap : null);
          },
        ),
      ),
    );
  }
}

class _BottomBar<S> extends StatelessWidget {
  final OnboardingController<S> controller;
  final int visibleStepCount;
  final bool enabled;
  final bool showBackButton;
  final String backLabel;
  final String nextLabel;
  final String finishLabel;
  final Future<void> Function() onBackTap;
  final Future<void> Function() onPrimaryTap;

  const _BottomBar({
    required this.controller,
    required this.visibleStepCount,
    required this.enabled,
    required this.showBackButton,
    required this.backLabel,
    required this.nextLabel,
    required this.finishLabel,
    required this.onBackTap,
    required this.onPrimaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: DataSubjectBuilder<int>(
        subject: controller.currentIndexSubject,
        builder: (context, currentIndex) {
          final safeCurrentIndex = currentIndex.clamp(0, visibleStepCount - 1).toInt();
          final isLastStep = safeCurrentIndex >= visibleStepCount - 1;
          final canGoBack = enabled && controller.canGoBack;
          final canGoForward = enabled;

          return Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: showBackButton
                      ? Button(
                          onTap: canGoBack ? onBackTap : null,
                          enabled: canGoBack,
                          type: ButtonType.outline,
                          label: backLabel,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              OnboardingPageIndicator(count: visibleStepCount, activeIndex: safeCurrentIndex),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Button(
                    onTap: canGoForward ? onPrimaryTap : null,
                    enabled: canGoForward,
                    label: isLastStep ? finishLabel : nextLabel,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
