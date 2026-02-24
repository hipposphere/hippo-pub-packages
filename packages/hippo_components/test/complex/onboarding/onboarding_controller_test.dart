import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_components/hippo_components.dart';

class _OnboardingState {
  final bool showA;
  final bool showB;
  final bool showC;
  final bool showD;

  const _OnboardingState({
    this.showA = true,
    this.showB = true,
    this.showC = true,
    this.showD = true,
  });
}

void main() {
  group('OnboardingController', () {
    test('initialization resolves enabled steps from state', () {
      final controller = OnboardingController<_OnboardingState>(
        initialState: const _OnboardingState(showB: false),
        steps: _buildSteps(),
      );
      addTearDown(controller.dispose);

      expect(
        controller.enabledSteps.map((step) => step.id).toList(),
        orderedEquals(const ['a', 'c', 'd']),
      );
      expect(controller.currentIndex, 0);
      expect(controller.currentStep?.id, 'a');
    });

    test('constructor asserts when step ids are not unique', () {
      expect(
        () => OnboardingController<bool>(
          initialState: true,
          steps: const [
            OnboardingStep(id: 'duplicate', title: 'One'),
            OnboardingStep(id: 'duplicate', title: 'Two'),
          ],
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('next, back, goToIndex and goToStepId navigate in visible order', () async {
      final controller = OnboardingController<_OnboardingState>(
        initialState: const _OnboardingState(),
        steps: _buildSteps(),
      );
      addTearDown(controller.dispose);

      await controller.goToIndex(2);
      expect(controller.currentIndex, 2);
      expect(controller.currentStep?.id, 'c');

      await controller.next();
      expect(controller.currentStep?.id, 'd');

      await controller.back();
      expect(controller.currentStep?.id, 'c');

      await controller.goToStepId('a');
      expect(controller.currentIndex, 0);
      expect(controller.currentStep?.id, 'a');
    });

    test('updateState hides current step and jumps forward-first', () async {
      final controller = OnboardingController<_OnboardingState>(
        initialState: const _OnboardingState(),
        steps: _buildSteps(),
      );
      addTearDown(controller.dispose);

      await controller.goToStepId('b');
      expect(controller.currentStep?.id, 'b');

      controller.updateState(const _OnboardingState(showB: false));

      expect(
        controller.enabledSteps.map((step) => step.id).toList(),
        orderedEquals(const ['a', 'c', 'd']),
      );
      expect(controller.currentStep?.id, 'c');
      expect(controller.currentIndex, 1);
    });

    test('updateState keeps current step by id when still enabled', () async {
      final controller = OnboardingController<_OnboardingState>(
        initialState: const _OnboardingState(showA: false),
        steps: _buildSteps(),
      );
      addTearDown(controller.dispose);

      expect(
        controller.enabledSteps.map((step) => step.id).toList(),
        orderedEquals(const ['b', 'c', 'd']),
      );

      await controller.goToStepId('c');
      expect(controller.currentStep?.id, 'c');
      expect(controller.currentIndex, 1);

      controller.updateState(const _OnboardingState(showA: true));

      expect(
        controller.enabledSteps.map((step) => step.id).toList(),
        orderedEquals(const ['a', 'b', 'c', 'd']),
      );
      expect(controller.currentStep?.id, 'c');
      expect(controller.currentIndex, 2);
    });

    test('updateState with zero enabled steps keeps index stable at 0', () {
      final controller = OnboardingController<_OnboardingState>(
        initialState: const _OnboardingState(showA: true, showB: false, showC: false, showD: false),
        steps: _buildSteps(),
      );
      addTearDown(controller.dispose);

      expect(controller.enabledSteps.length, 1);
      expect(controller.currentStep?.id, 'a');

      controller.updateState(
        const _OnboardingState(showA: false, showB: false, showC: false, showD: false),
      );

      expect(controller.enabledSteps, isEmpty);
      expect(controller.currentStep, isNull);
      expect(controller.currentIndex, 0);
    });
  });
}

List<OnboardingStep<_OnboardingState>> _buildSteps() {
  return const [
    OnboardingStep(id: 'a', title: 'A', isEnabled: _showA),
    OnboardingStep(id: 'b', title: 'B', isEnabled: _showB),
    OnboardingStep(id: 'c', title: 'C', isEnabled: _showC),
    OnboardingStep(id: 'd', title: 'D', isEnabled: _showD),
  ];
}

bool _showA(_OnboardingState state) => state.showA;
bool _showB(_OnboardingState state) => state.showB;
bool _showC(_OnboardingState state) => state.showC;
bool _showD(_OnboardingState state) => state.showD;
