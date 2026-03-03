import 'dart:io';

import 'package:flutter/material.dart';
import 'package:speech_utils/speech_utils.dart';
import 'package:speech_utils_example/widgets/example_dropdown_form_field.dart';

@immutable
final class AudioProcessingController {
  const AudioProcessingController({
    this.preset,
    this.iosSessionMode,
    this.preferredLatency,
    this.enableNoiseSuppression,
    this.enableEchoCancellation,
    this.enableAutomaticGainControl,
    this.enableHighPassFilter,
  });

  final AudioCapturePreset? preset;
  final IosAudioSessionMode? iosSessionMode;
  final Duration? preferredLatency;
  final bool? enableNoiseSuppression;
  final bool? enableEchoCancellation;
  final bool? enableAutomaticGainControl;
  final bool? enableHighPassFilter;

  AudioCapturePreset get effectivePreset => preset ?? AudioCapturePreset.raw;

  AudioProcessingPlatform get activePlatform {
    if (Platform.isIOS) {
      return AudioProcessingPlatform.ios;
    }
    if (Platform.isMacOS) {
      return AudioProcessingPlatform.macos;
    }
    if (Platform.isWindows) {
      return AudioProcessingPlatform.windows;
    }
    return AudioProcessingPlatform.generic;
  }

  bool get isApplePlatform =>
      activePlatform == AudioProcessingPlatform.ios ||
      activePlatform == AudioProcessingPlatform.macos;
  bool get supportsIosSessionMode => Platform.isIOS;

  IosAudioSessionMode get fallbackIosSessionMode {
    return switch (effectivePreset) {
      AudioCapturePreset.voice ||
      AudioCapturePreset.voiceIsolation => IosAudioSessionMode.voiceChat,
      AudioCapturePreset.raw ||
      AudioCapturePreset.music => IosAudioSessionMode.measurement,
    };
  }

  IosAudioSessionMode get resolvedIosSessionMode =>
      iosSessionMode ?? fallbackIosSessionMode;

  String get capturePresetLabel => labelForCapturePreset(preset);

  String get iosSessionModeLabel {
    final explicit = iosSessionMode;
    if (explicit == null) {
      return 'auto(${labelForIosSessionMode(fallbackIosSessionMode)})';
    }
    return labelForIosSessionMode(explicit);
  }

  AudioProcessingConfig buildProcessingConfig() {
    return AudioProcessingConfig(
      preset: effectivePreset,
      preferredLatency: preferredLatency,
      windows: WindowsAudioProcessingConfig(
        usePresetDefaults: true,
        enableNoiseSuppression: enableNoiseSuppression,
        enableEchoCancellation: enableEchoCancellation,
        enableAutomaticGainControl: enableAutomaticGainControl,
        enableHighPassFilter: enableHighPassFilter,
      ),
    );
  }

  IosAudioRecorderConfig buildIosRecorderConfig() {
    final presetValue = effectivePreset;
    return IosAudioRecorderConfig(
      sessionMode: supportsIosSessionMode ? iosSessionMode : null,
      allowBluetoothInput: true,
      allowBluetoothA2dp: false,
      defaultToSpeaker: false,
      mixWithOthers: presetValue == AudioCapturePreset.music,
      duckOthers: false,
      preferredIoBufferDuration: preferredLatency,
    );
  }

  MacosAudioRecorderConfig buildMacosRecorderConfig() {
    return MacosAudioRecorderConfig(processingQueueDuration: preferredLatency);
  }

  String processingSummary() {
    final platform = activePlatform;
    final config = buildProcessingConfig();
    final latency = config.preferredLatency?.inMilliseconds;
    final latencyText = latency == null ? 'auto' : '${latency}ms';

    if (platform == AudioProcessingPlatform.ios) {
      return 'platform=ios, mode=$iosSessionModeLabel, latency=$latencyText';
    }
    if (platform == AudioProcessingPlatform.macos) {
      return 'platform=macos, mode=n/a (AVAudioSession mode is iOS-only), queue=$latencyText';
    }

    final noise = config.resolveNoiseSuppressionForPlatform(platform)
        ? 'on'
        : 'off';
    final echo = config.resolveEchoCancellationForPlatform(platform)
        ? 'on'
        : 'off';
    final agc = config.resolveAutomaticGainControlForPlatform(platform)
        ? 'on'
        : 'off';
    final highPass = config.resolveHighPassFilterForPlatform(platform)
        ? 'on'
        : 'off';
    final platformText = switch (platform) {
      AudioProcessingPlatform.ios => 'ios',
      AudioProcessingPlatform.macos => 'macos',
      AudioProcessingPlatform.windows => 'windows',
      AudioProcessingPlatform.generic => 'generic',
    };
    return 'platform=$platformText, noise=$noise, echo=$echo, agc=$agc, high-pass=$highPass, latency=$latencyText';
  }

  AudioProcessingController copyWith({
    Object? preset = _unset,
    Object? iosSessionMode = _unset,
    Object? preferredLatency = _unset,
    Object? enableNoiseSuppression = _unset,
    Object? enableEchoCancellation = _unset,
    Object? enableAutomaticGainControl = _unset,
    Object? enableHighPassFilter = _unset,
  }) {
    return AudioProcessingController(
      preset: identical(preset, _unset)
          ? this.preset
          : preset as AudioCapturePreset?,
      iosSessionMode: identical(iosSessionMode, _unset)
          ? this.iosSessionMode
          : iosSessionMode as IosAudioSessionMode?,
      preferredLatency: identical(preferredLatency, _unset)
          ? this.preferredLatency
          : preferredLatency as Duration?,
      enableNoiseSuppression: identical(enableNoiseSuppression, _unset)
          ? this.enableNoiseSuppression
          : enableNoiseSuppression as bool?,
      enableEchoCancellation: identical(enableEchoCancellation, _unset)
          ? this.enableEchoCancellation
          : enableEchoCancellation as bool?,
      enableAutomaticGainControl: identical(enableAutomaticGainControl, _unset)
          ? this.enableAutomaticGainControl
          : enableAutomaticGainControl as bool?,
      enableHighPassFilter: identical(enableHighPassFilter, _unset)
          ? this.enableHighPassFilter
          : enableHighPassFilter as bool?,
    );
  }

  static String labelForCapturePreset(AudioCapturePreset? preset) {
    if (preset == null) {
      return 'No preset';
    }
    return switch (preset) {
      AudioCapturePreset.voice => 'Voice',
      AudioCapturePreset.voiceIsolation => 'Voice isolation',
      AudioCapturePreset.raw => 'Raw',
      AudioCapturePreset.music => 'Music',
    };
  }

  static String labelForIosSessionMode(IosAudioSessionMode mode) {
    return switch (mode) {
      IosAudioSessionMode.defaultMode => 'default',
      IosAudioSessionMode.voiceChat => 'voiceChat',
      IosAudioSessionMode.videoChat => 'videoChat',
      IosAudioSessionMode.measurement => 'measurement',
      IosAudioSessionMode.gameChat => 'gameChat',
      IosAudioSessionMode.spokenAudio => 'spokenAudio',
    };
  }

  static const Object _unset = Object();
}

class AudioProcessingCard extends StatelessWidget {
  const AudioProcessingCard({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });

  final AudioProcessingController controller;
  final bool enabled;
  final ValueChanged<AudioProcessingController> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isApple = controller.isApplePlatform;
    final supportsIosSessionMode = controller.supportsIosSessionMode;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Audio processing', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              isApple
                  ? (supportsIosSessionMode
                        ? 'Apple capture is mode-driven on iOS. Set mode directly or leave Auto to follow preset fallback.'
                        : 'macOS capture uses AVCaptureSession. AVAudioSession mode (voiceChat/measurement) is not applied on macOS.')
                  : 'Configure denoising/echo/AGC/high-pass overrides, or leave Auto to follow preset defaults.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ExampleDropdownFormField<AudioCapturePreset?>(
              initialValue: controller.preset,
              decoration: const InputDecoration(
                labelText: 'Processing preset',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              options: [
                const ExampleDropdownOption<AudioCapturePreset?>(
                  value: null,
                  label: 'No preset',
                ),
                ...AudioCapturePreset.values.map(
                  (preset) => ExampleDropdownOption<AudioCapturePreset?>(
                    value: preset,
                    label: AudioProcessingController.labelForCapturePreset(
                      preset,
                    ),
                  ),
                ),
              ],
              onChanged: !enabled
                  ? null
                  : (value) {
                      onChanged(controller.copyWith(preset: value));
                    },
            ),
            const SizedBox(height: 12),
            if (isApple && supportsIosSessionMode) ...[
              ExampleDropdownFormField<IosAudioSessionMode?>(
                initialValue: controller.iosSessionMode,
                decoration: const InputDecoration(
                  labelText: 'iOS session mode',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                options: [
                  ExampleDropdownOption<IosAudioSessionMode?>(
                    value: null,
                    label:
                        'Auto (preset fallback: ${AudioProcessingController.labelForIosSessionMode(controller.fallbackIosSessionMode)})',
                  ),
                  ...IosAudioSessionMode.values.map(
                    (mode) => ExampleDropdownOption<IosAudioSessionMode?>(
                      value: mode,
                      label: AudioProcessingController.labelForIosSessionMode(
                        mode,
                      ),
                    ),
                  ),
                ],
                onChanged: !enabled
                    ? null
                    : (value) {
                        onChanged(controller.copyWith(iosSessionMode: value));
                      },
              ),
            ] else if (isApple) ...[
              Text(
                'Apple session mode is iOS-only.',
                style: theme.textTheme.bodySmall,
              ),
            ] else ...[
              _buildToggleField(
                initialValue: controller.enableNoiseSuppression,
                label: 'Noise suppression',
                enabled: enabled,
                onChanged: (value) {
                  onChanged(controller.copyWith(enableNoiseSuppression: value));
                },
              ),
              const SizedBox(height: 12),
              _buildToggleField(
                initialValue: controller.enableEchoCancellation,
                label: 'Echo cancellation',
                enabled: enabled,
                onChanged: (value) {
                  onChanged(controller.copyWith(enableEchoCancellation: value));
                },
              ),
              const SizedBox(height: 12),
              _buildToggleField(
                initialValue: controller.enableAutomaticGainControl,
                label: 'Automatic gain control',
                enabled: enabled,
                onChanged: (value) {
                  onChanged(
                    controller.copyWith(enableAutomaticGainControl: value),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildToggleField(
                initialValue: controller.enableHighPassFilter,
                label: 'High-pass filter',
                enabled: enabled,
                onChanged: (value) {
                  onChanged(controller.copyWith(enableHighPassFilter: value));
                },
              ),
            ],
            const SizedBox(height: 12),
            ExampleDropdownFormField<Duration?>(
              initialValue: controller.preferredLatency,
              decoration: const InputDecoration(
                labelText: 'Preferred latency',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              options: const [
                ExampleDropdownOption<Duration?>(value: null, label: 'Auto'),
                ExampleDropdownOption<Duration?>(
                  value: Duration(milliseconds: 10),
                  label: '10 ms',
                ),
                ExampleDropdownOption<Duration?>(
                  value: Duration(milliseconds: 20),
                  label: '20 ms',
                ),
                ExampleDropdownOption<Duration?>(
                  value: Duration(milliseconds: 40),
                  label: '40 ms',
                ),
              ],
              onChanged: !enabled
                  ? null
                  : (value) {
                      onChanged(controller.copyWith(preferredLatency: value));
                    },
            ),
            const SizedBox(height: 8),
            Text(
              'Effective processing: ${controller.processingSummary()}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleField({
    required bool? initialValue,
    required String label,
    required bool enabled,
    required ValueChanged<bool?> onChanged,
  }) {
    return ExampleDropdownFormField<bool?>(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      options: const [
        ExampleDropdownOption<bool?>(value: null, label: 'Auto (preset)'),
        ExampleDropdownOption<bool?>(value: true, label: 'Enabled'),
        ExampleDropdownOption<bool?>(value: false, label: 'Disabled'),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}
