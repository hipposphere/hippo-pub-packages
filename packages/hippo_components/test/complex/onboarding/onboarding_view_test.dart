import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_components/hippo_components.dart';

class _ViewState {
  final bool showWelcome;
  final bool showPermissions;
  final bool showDone;

  const _ViewState({this.showWelcome = true, this.showPermissions = true, this.showDone = true});
}

void main() {
  group('OnboardingView', () {
    testWidgets('renders only enabled steps and matching indicator count', (tester) async {
      final controller = OnboardingController<_ViewState>(
        initialState: const _ViewState(showPermissions: false),
        steps: _buildViewSteps(),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _buildTestApp(OnboardingView<_ViewState>(controller: controller, onFinished: () async {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Permissions'), findsNothing);
      expect(find.byKey(const ValueKey('onboarding_indicator_dot_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('onboarding_indicator_dot_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('onboarding_indicator_dot_2')), findsNothing);
    });

    testWidgets('next advances and last page switches label to finish', (tester) async {
      final controller = OnboardingController<_ViewState>(
        initialState: const _ViewState(showPermissions: false),
        steps: _buildViewSteps(),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _buildTestApp(OnboardingView<_ViewState>(controller: controller, onFinished: () async {})),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(Button, 'Next'));
      await tester.pumpAndSettle();

      expect(find.text('Done'), findsOneWidget);
      expect(find.widgetWithText(Button, 'Finish'), findsOneWidget);
    });

    testWidgets('skip triggers onSkipped before onFinished', (tester) async {
      final calls = <String>[];
      final controller = OnboardingController<_ViewState>(
        initialState: const _ViewState(),
        steps: _buildViewSteps(),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          OnboardingView<_ViewState>(
            controller: controller,
            onFinished: () async {
              calls.add('finish');
            },
            onSkipped: (index, step) async {
              calls.add('skip:${step?.id}:$index');
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip', findRichText: true));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(calls, orderedEquals(const ['skip:welcome:0', 'finish']));
    });

    testWidgets('swipe moves to next page when enabled', (tester) async {
      final controller = OnboardingController<_ViewState>(
        initialState: const _ViewState(),
        steps: _buildViewSteps(),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          OnboardingView<_ViewState>(
            controller: controller,
            allowUserSwipe: true,
            onFinished: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(controller.currentIndex, 1);
      expect(find.text('Permissions'), findsOneWidget);
    });

    testWidgets('swipe does not move to next page when disabled', (tester) async {
      final controller = OnboardingController<_ViewState>(
        initialState: const _ViewState(),
        steps: _buildViewSteps(),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          OnboardingView<_ViewState>(
            controller: controller,
            allowUserSwipe: false,
            onFinished: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(controller.currentIndex, 0);
      expect(find.text('Welcome'), findsOneWidget);
    });

    testWidgets('back button is disabled on first page and enabled later', (tester) async {
      final controller = OnboardingController<_ViewState>(
        initialState: const _ViewState(),
        steps: _buildViewSteps(),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _buildTestApp(OnboardingView<_ViewState>(controller: controller, onFinished: () async {})),
      );
      await tester.pumpAndSettle();

      var backButton = tester.widget<Button>(find.widgetWithText(Button, 'Back'));
      expect(backButton.enabled, isFalse);

      await tester.tap(find.widgetWithText(Button, 'Next'));
      await tester.pumpAndSettle();

      backButton = tester.widget<Button>(find.widgetWithText(Button, 'Back'));
      expect(backButton.enabled, isTrue);
    });

    testWidgets('zero enabled steps auto-finishes exactly once', (tester) async {
      int finishCalls = 0;
      final controller = OnboardingController<_ViewState>(
        initialState: const _ViewState(showWelcome: false, showPermissions: false, showDone: false),
        steps: _buildViewSteps(),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          OnboardingView<_ViewState>(
            controller: controller,
            onFinished: () async {
              finishCalls++;
            },
          ),
        ),
      );

      await tester.pump();
      expect(finishCalls, 1);

      await tester.pump();
      expect(finishCalls, 1);
    });

    testWidgets('in-flight finish action prevents duplicate triggers', (tester) async {
      final completer = Completer<void>();
      int finishCalls = 0;

      final controller = OnboardingController<_ViewState>(
        initialState: const _ViewState(showPermissions: false, showDone: true),
        steps: const [OnboardingStep(id: 'done', title: 'Done')],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          OnboardingView<_ViewState>(
            controller: controller,
            onFinished: () async {
              finishCalls++;
              await completer.future;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final finishButtonFinder = find.widgetWithText(Button, 'Finish');
      await tester.tap(finishButtonFinder);
      await tester.pump();
      await tester.tap(finishButtonFinder);
      await tester.pump();

      expect(finishCalls, 1);

      completer.complete();
      await tester.pumpAndSettle();
    });
  });
}

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: ComponentsLocalizations.localizationsDelegates,
    supportedLocales: ComponentsLocalizations.supportedLocales,
    home: HippoThemeBuilder(brightness: Brightness.light, child: child),
  );
}

List<OnboardingStep<_ViewState>> _buildViewSteps() {
  return const [
    OnboardingStep(id: 'welcome', title: 'Welcome', isEnabled: _showWelcome),
    OnboardingStep(id: 'permissions', title: 'Permissions', isEnabled: _showPermissions),
    OnboardingStep(id: 'done', title: 'Done', isEnabled: _showDone),
  ];
}

bool _showWelcome(_ViewState state) => state.showWelcome;
bool _showPermissions(_ViewState state) => state.showPermissions;
bool _showDone(_ViewState state) => state.showDone;
