import 'dart:async';
import 'dart:typed_data';

import '../recording/audio_recorder_config.dart';
import '../vad/speech_vad_config.dart';

final class WakeWordDetectionConfig {
  const WakeWordDetectionConfig({required this.keywords, this.sensitivity = 0.6});

  final List<String> keywords;

  /// Detection sensitivity in the range 0 (strict) to 1 (most permissive).
  final double sensitivity;

  void validate() {
    if (keywords.isEmpty) {
      throw ArgumentError.value(keywords, 'keywords', 'Must not be empty');
    }
    for (final keyword in keywords) {
      if (keyword.trim().isEmpty) {
        throw ArgumentError.value(keywords, 'keywords', 'Keywords must not be blank');
      }
    }
    if (sensitivity < 0 || sensitivity > 1) {
      throw ArgumentError.value(sensitivity, 'sensitivity', 'Must be in [0, 1]');
    }
  }
}

final class WakeWordEvent {
  const WakeWordEvent({required this.keyword, required this.confidence, required this.detectedAt});

  final String keyword;
  final double confidence;
  final DateTime detectedAt;
}

abstract interface class WakeWordDetector {
  List<WakeWordEvent> addChunk(
    Uint8List pcm16leBytes, {
    required int sampleRateHz,
    required int channelCount,
    required WakeWordDetectionConfig config,
  });

  void reset();

  void dispose();
}

final class WakeCommandCaptureConfig {
  const WakeCommandCaptureConfig({
    this.discardWakeWordAudio = true,
    this.postWakeDelay = const Duration(milliseconds: 150),
    this.minCommandDuration = const Duration(milliseconds: 700),
    this.endSilenceDuration = const Duration(milliseconds: 1000),
    this.maxCommandDuration = const Duration(seconds: 10),
    this.preSpeechPadding = const Duration(milliseconds: 200),
    this.trailingPadding = const Duration(milliseconds: 250),
    this.frameDuration = const Duration(milliseconds: 20),
    this.vad = const SpeechVadConfig(),
  });

  final bool discardWakeWordAudio;
  final Duration postWakeDelay;
  final Duration minCommandDuration;
  final Duration endSilenceDuration;
  final Duration maxCommandDuration;
  final Duration preSpeechPadding;
  final Duration trailingPadding;
  final Duration frameDuration;
  final SpeechVadConfig vad;

  void validate() {
    if (postWakeDelay < Duration.zero) {
      throw ArgumentError.value(postWakeDelay, 'postWakeDelay', 'Must be >= Duration.zero');
    }
    if (minCommandDuration < Duration.zero) {
      throw ArgumentError.value(
        minCommandDuration,
        'minCommandDuration',
        'Must be >= Duration.zero',
      );
    }
    if (endSilenceDuration < Duration.zero) {
      throw ArgumentError.value(
        endSilenceDuration,
        'endSilenceDuration',
        'Must be >= Duration.zero',
      );
    }
    if (maxCommandDuration <= Duration.zero) {
      throw ArgumentError.value(maxCommandDuration, 'maxCommandDuration', 'Must be > 0');
    }
    if (preSpeechPadding < Duration.zero) {
      throw ArgumentError.value(preSpeechPadding, 'preSpeechPadding', 'Must be >= Duration.zero');
    }
    if (trailingPadding < Duration.zero) {
      throw ArgumentError.value(trailingPadding, 'trailingPadding', 'Must be >= Duration.zero');
    }
    if (frameDuration <= Duration.zero) {
      throw ArgumentError.value(frameDuration, 'frameDuration', 'Must be > Duration.zero');
    }
  }
}

final class VoiceActionCaptureRequest {
  const VoiceActionCaptureRequest({
    required this.detector,
    required this.wakeWords,
    this.audio = const AudioRecorderConfig(),
    this.command = const WakeCommandCaptureConfig(),
    this.pollInterval = const Duration(milliseconds: 20),
    this.readSampleCapacity = 4096,
  });

  final WakeWordDetector detector;
  final WakeWordDetectionConfig wakeWords;
  final AudioRecorderConfig audio;
  final WakeCommandCaptureConfig command;
  final Duration pollInterval;
  final int readSampleCapacity;

  void validate() {
    wakeWords.validate();
    audio.validate();
    command.validate();
    if (pollInterval <= Duration.zero) {
      throw ArgumentError.value(pollInterval, 'pollInterval', 'Must be > Duration.zero');
    }
    if (readSampleCapacity <= 0) {
      throw ArgumentError.value(readSampleCapacity, 'readSampleCapacity', 'Must be > 0');
    }
  }
}

enum VoiceActionCaptureState { listening, capturingCommand, paused, stopped }

final class VoiceActionCaptureStateSample {
  const VoiceActionCaptureStateSample({required this.at, required this.state});

  final DateTime at;
  final VoiceActionCaptureState state;
}

final class VoiceActionCommand {
  const VoiceActionCommand({
    required this.id,
    required this.wakeWord,
    required this.startedAt,
    required this.completedAt,
    required this.pcm16leBytes,
    required this.sampleRateHz,
    required this.channelCount,
  });

  final int id;
  final String wakeWord;
  final DateTime startedAt;
  final DateTime completedAt;
  final Uint8List pcm16leBytes;
  final int sampleRateHz;
  final int channelCount;

  Duration get duration {
    final bytesPerSecond = sampleRateHz * channelCount * 2;
    if (bytesPerSecond <= 0) {
      return Duration.zero;
    }
    final micros = pcm16leBytes.lengthInBytes * Duration.microsecondsPerSecond ~/ bytesPerSecond;
    return Duration(microseconds: micros);
  }
}

final class VoiceActionCommandStream {
  const VoiceActionCommandStream({
    required this.id,
    required this.wakeWord,
    required this.startedAt,
    required this.pcm16leStream,
    required this.completed,
  });

  final int id;
  final String wakeWord;
  final DateTime startedAt;
  final Stream<Uint8List> pcm16leStream;
  final Future<VoiceActionCommand> completed;
}

final class VoiceActionCaptureStopResult {
  const VoiceActionCaptureStopResult({required this.commandCount, required this.wakeWordCount});

  final int commandCount;
  final int wakeWordCount;
}

abstract interface class VoiceActionCaptureSession {
  Stream<WakeWordEvent> get wakeWords;
  Stream<VoiceActionCommandStream> get commandStreams;
  Stream<VoiceActionCommand> get commands;
  Stream<VoiceActionCaptureStateSample> get states;
  bool get isPaused;
  Future<void> pause();
  Future<void> resume();
  Future<VoiceActionCaptureStopResult> stop();
  Future<void> cancel();
}
