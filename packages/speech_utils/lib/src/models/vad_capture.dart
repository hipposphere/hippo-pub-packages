import 'dart:async';
import 'dart:io';

import 'package:cross_file/cross_file.dart';

import '../recording/audio_recorder_config.dart';
import '../recording/voice_segment.dart';
import '../vad/speech_vad_config.dart';
import 'audio_metadata.dart';
import 'audio_segment_metrics.dart';
import 'pause_split_options.dart';

final class VadCaptureTelemetryConfig {
  const VadCaptureTelemetryConfig({
    this.speechHoldDuration = Duration.zero,
    this.emitSpeechState = true,
    this.emitLevels = true,
    this.emitFrameDecisions = false,
  });

  final Duration speechHoldDuration;
  final bool emitSpeechState;
  final bool emitLevels;
  final bool emitFrameDecisions;

  void validate() {
    if (speechHoldDuration < Duration.zero) {
      throw ArgumentError.value(speechHoldDuration, 'speechHoldDuration', 'Must be >= 0');
    }
  }
}

final class VadCaptureOutputConfig {
  const VadCaptureOutputConfig({
    required this.outputDirectory,
    this.segmentEncoding = const AudioEncodingConfig(encoder: AudioEncoder.wav),
    this.fullRecordingEncoding,
    this.emitFullRecordingOnStop = false,
    this.fullRecordingFileStem = 'recording_full',
    this.segmentPathBuilder,
  });

  final Directory outputDirectory;
  final AudioEncodingConfig segmentEncoding;
  final AudioEncodingConfig? fullRecordingEncoding;
  final bool emitFullRecordingOnStop;
  final String fullRecordingFileStem;
  final NativeVoiceSegmentPathBuilder? segmentPathBuilder;

  void validate() {
    segmentEncoding.validate();
    fullRecordingEncoding?.validate();
    if (fullRecordingFileStem.trim().isEmpty) {
      throw ArgumentError.value(fullRecordingFileStem, 'fullRecordingFileStem', 'Must not be empty');
    }
  }
}

final class VadCaptureRequest {
  const VadCaptureRequest({
    required this.split,
    required this.output,
    this.audio = const AudioRecorderConfig(),
    this.vad = const SpeechVadConfig(),
    this.telemetry = const VadCaptureTelemetryConfig(),
    this.flushOnStop = true,
    this.pollInterval = const Duration(milliseconds: 20),
    this.readSampleCapacity = 4096,
  });

  final PauseSplitOptions split;
  final VadCaptureOutputConfig output;
  final AudioRecorderConfig audio;
  final SpeechVadConfig vad;
  final VadCaptureTelemetryConfig telemetry;
  final bool flushOnStop;
  final Duration pollInterval;
  final int readSampleCapacity;

  void validate() {
    audio.validate();
    split.validate();
    output.validate();
    telemetry.validate();
    if (pollInterval <= Duration.zero) {
      throw ArgumentError.value(pollInterval, 'pollInterval', 'Must be > Duration.zero');
    }
    if (readSampleCapacity <= 0) {
      throw ArgumentError.value(readSampleCapacity, 'readSampleCapacity', 'Must be > 0');
    }
  }
}

final class VadFrameDecision {
  const VadFrameDecision({
    required this.at,
    required this.isSpeechFrame,
    required this.analyzedFrameCount,
    required this.speechFrameCount,
  });

  final DateTime at;
  final bool isSpeechFrame;
  final int analyzedFrameCount;
  final int speechFrameCount;
}

final class VadSpeechStateSample {
  const VadSpeechStateSample({required this.at, required this.speechDetected});

  final DateTime at;
  final bool speechDetected;
}

final class VadLevelSample {
  const VadLevelSample({
    required this.at,
    required this.rms,
    required this.dbfs,
    required this.hasSpeechFrame,
  });

  final DateTime at;
  final double rms;
  final double dbfs;
  final bool hasSpeechFrame;
}

final class VadRecordingArtifact {
  const VadRecordingArtifact({
    required this.file,
    required this.fileExtension,
    required this.mimeType,
    required this.metadata,
    required this.metrics,
  });

  final XFile file;
  final String fileExtension;
  final String mimeType;
  final AudioMetadata metadata;
  final AudioSegmentMetrics metrics;
}

final class VadCaptureStopResult {
  const VadCaptureStopResult({
    required this.segmentCount,
    required this.analyzedFrameCount,
    required this.speechFrameCount,
    this.fullRecording,
  });

  final int segmentCount;
  final int analyzedFrameCount;
  final int speechFrameCount;
  final VadRecordingArtifact? fullRecording;
}

abstract interface class VadCaptureSession {
  ResolvedVadKind get backendKind;
  String get backendLabel;
  Stream<VoiceSegment> get segments;
  Stream<VadSpeechStateSample> get speechStates;
  Stream<VadLevelSample> get levels;
  Stream<VadFrameDecision> get frameDecisions;
  Future<VadCaptureStopResult> stop();
  Future<void> cancel();
}
