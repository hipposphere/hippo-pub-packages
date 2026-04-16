import 'package:speech_utils_example/widgets/example_dropdown_form_field.dart';

enum ContinuousCaptureDurationPreset { fifteenSeconds, oneMinute, infinite }

extension ContinuousCaptureDurationPresetExtension
    on ContinuousCaptureDurationPreset {
  Duration? get duration => switch (this) {
    ContinuousCaptureDurationPreset.fifteenSeconds => const Duration(
      seconds: 15,
    ),
    ContinuousCaptureDurationPreset.oneMinute => const Duration(minutes: 1),
    ContinuousCaptureDurationPreset.infinite => null,
  };

  String get label => switch (this) {
    ContinuousCaptureDurationPreset.fifteenSeconds => '15 seconds',
    ContinuousCaptureDurationPreset.oneMinute => '1 minute',
    ContinuousCaptureDurationPreset.infinite => 'Infinite',
  };

  String get idleTimeoutLabel => switch (this) {
    ContinuousCaptureDurationPreset.fifteenSeconds => '15 seconds',
    ContinuousCaptureDurationPreset.oneMinute => '1 minute',
    ContinuousCaptureDurationPreset.infinite => 'Infinite',
  };

  String get warmBehaviorLabel => switch (this) {
    ContinuousCaptureDurationPreset.fifteenSeconds => 'for 15 seconds',
    ContinuousCaptureDurationPreset.oneMinute => 'for 1 minute',
    ContinuousCaptureDurationPreset.infinite => 'indefinitely',
  };
}

const continuousCaptureDurationPresetOptions =
    <ExampleDropdownOption<ContinuousCaptureDurationPreset>>[
      ExampleDropdownOption(
        value: ContinuousCaptureDurationPreset.fifteenSeconds,
        label: '15 seconds',
      ),
      ExampleDropdownOption(
        value: ContinuousCaptureDurationPreset.oneMinute,
        label: '1 minute',
      ),
      ExampleDropdownOption(
        value: ContinuousCaptureDurationPreset.infinite,
        label: 'Infinite',
      ),
    ];
