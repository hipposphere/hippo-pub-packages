import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hippo_utils/hippo_utils.dart';

part 'mobile.dart';

class AdaptiveDetailContainerState<T> {
  final T data;
  final String? routeName;

  AdaptiveDetailContainerState({required this.data, this.routeName});
}

class AdaptiveDetailController<T> {
  AdaptiveDetailController({AdaptiveDetailContainerState<T>? initialState}) {
    if (initialState != null) {
      stateSubject.add(initialState);
    }
  }

  final stateSubject = DataSubject<AdaptiveDetailContainerState<T>?>.seeded(null);

  void goBack() {
    stateSubject.add(null);
  }

  void selectState(AdaptiveDetailContainerState<T> state) {
    stateSubject.add(state);
  }
}

class AdaptiveDetailContainer<T> extends StatelessWidget {
  final AdaptiveDetailController<T> controller;
  final double breakpoint;
  final Widget Function(BuildContext context, AdaptiveDetailContainerState<T>? state)
  desktopBuilder;
  final Widget Function(BuildContext context, AdaptiveDetailContainerState<T>? state) mobileBuilder;
  const AdaptiveDetailContainer({
    super.key,
    this.breakpoint = 800,
    required this.controller,
    required this.desktopBuilder,
    required this.mobileBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= breakpoint;
        return DataSubjectBuilder<AdaptiveDetailContainerState<T>?>(
          subject: controller.stateSubject,
          builder: (context, state) {
            if (isDesktop) {
              return desktopBuilder(context, state);
            }
            return _Mobile<T>(controller: controller, mobileBuilder: mobileBuilder, state: state);
          },
        );
      },
    );
  }
}
