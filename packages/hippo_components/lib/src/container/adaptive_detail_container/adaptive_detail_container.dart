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
  AdaptiveDetailController();

  final stateSubject = DataSubject<AdaptiveDetailContainerState<T>?>.seeded(null);

  void goBack() {
    stateSubject.add(null);
  }

  void selectState(AdaptiveDetailContainerState<T> state) {
    stateSubject.add(state);
  }
}

class AdaptiveDetailScaffold<T> extends StatelessWidget {
  final AdaptiveDetailController<T> controller;
  final Widget Function(BuildContext context, AdaptiveDetailContainerState<T>? state)
      desktopBuilder;
  final Widget Function(BuildContext context, AdaptiveDetailContainerState<T>? state)
      mobileBuilder;
  const AdaptiveDetailScaffold({
    super.key,
    required this.controller,
    required this.desktopBuilder,
    required this.mobileBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 800;
        return DataSubjectBuilder<AdaptiveDetailContainerState<T>?>(
          subject: controller.stateSubject,
          builder: (context, state) {
            if (isDesktop) {
              return desktopBuilder(context, state);
            }
            return _Mobile<T>(
              controller: controller,
              mobileBuilder: mobileBuilder,
              state: state,
            );
          },
        );
      },
    );
  }
}
