import 'dart:math' as math;
import 'dart:typed_data';

import 'package:speech_utils/speech_utils.dart';
import 'package:test/test.dart';

import 'fakes/native_audio_recorder_platform_implementation.dart';

void main() {
  const audio = AudioRecorderConfig(sampleRateHz: 16000, channelCount: 1);
  const command = WakeCommandCaptureConfig(
    postWakeDelay: Duration.zero,
    minCommandDuration: Duration(milliseconds: 200),
    endSilenceDuration: Duration(milliseconds: 500),
    maxCommandDuration: Duration(seconds: 5),
    preSpeechPadding: Duration.zero,
    trailingPadding: Duration.zero,
    vad: SpeechVadConfig.energyOnly(),
  );

  test('streams post-wake command audio and emits completed command', () async {
    final chunks = _chunks([
      _sineBytes(duration: const Duration(milliseconds: 300)),
      _sineBytes(duration: const Duration(milliseconds: 300)),
      _sineBytes(duration: const Duration(milliseconds: 300)),
      _silenceBytes(duration: const Duration(milliseconds: 700)),
    ]);
    final recorder = recorderFixture(
      platform: NativeAudioRecorderPlatform.macOS,
      readPcmStreamFn: ({required maxSamples}) {
        if (chunks.isEmpty) {
          return Uint8List(0);
        }
        return chunks.removeAt(0);
      },
    );
    final detector = _ChunkCountWakeWordDetector(fireOnChunk: 1);

    final session = await recorder.startVoiceActionCapture(
      VoiceActionCaptureRequest(
        detector: detector,
        wakeWords: const WakeWordDetectionConfig(keywords: <String>['hey dicto']),
        audio: audio,
        command: command,
        pollInterval: const Duration(milliseconds: 1),
      ),
    );

    final commandStreamFuture = session.commandStreams.first;
    final commandFuture = session.commands.first;
    final commandStream = await commandStreamFuture;
    final liveBytesFuture = commandStream.pcm16leStream.fold<int>(
      0,
      (sum, chunk) => sum + chunk.lengthInBytes,
    );
    final completed = await commandFuture;
    final liveByteCount = await liveBytesFuture;
    final stopResult = await session.stop();

    expect(completed.wakeWord, 'hey dicto');
    expect(completed.duration.inMilliseconds, inInclusiveRange(550, 700));
    expect(liveByteCount, greaterThanOrEqualTo(completed.pcm16leBytes.lengthInBytes));
    expect(stopResult.wakeWordCount, 1);
    expect(stopResult.commandCount, 1);
    expect(detector.disposed, isTrue);
  });

  test('discardWakeWordAudio excludes the detection chunk from completed audio', () async {
    final wakeChunk = _sineBytes(duration: const Duration(milliseconds: 300), amplitude: 0.25);
    final commandChunk = _sineBytes(duration: const Duration(milliseconds: 300), amplitude: 0.75);
    final chunks = _chunks([
      wakeChunk,
      commandChunk,
      commandChunk,
      _silenceBytes(duration: const Duration(milliseconds: 700)),
    ]);
    final recorder = recorderFixture(
      platform: NativeAudioRecorderPlatform.macOS,
      readPcmStreamFn: ({required maxSamples}) {
        if (chunks.isEmpty) {
          return Uint8List(0);
        }
        return chunks.removeAt(0);
      },
    );

    final session = await recorder.startVoiceActionCapture(
      VoiceActionCaptureRequest(
        detector: _ChunkCountWakeWordDetector(fireOnChunk: 1),
        wakeWords: const WakeWordDetectionConfig(keywords: <String>['hey dicto']),
        audio: audio,
        command: command,
        pollInterval: const Duration(milliseconds: 1),
      ),
    );

    final completed = await session.commands.first;
    await session.stop();

    expect(
      completed.pcm16leBytes.lengthInBytes,
      lessThan(wakeChunk.lengthInBytes + commandChunk.lengthInBytes * 2 - 64),
    );
    expect(completed.pcm16leBytes.lengthInBytes, greaterThan(commandChunk.lengthInBytes * 2 - 64));
  });
}

List<Uint8List> _chunks(List<Uint8List> chunks) => List<Uint8List>.of(chunks);

Uint8List _sineBytes({
  required Duration duration,
  double amplitude = 0.65,
  double frequencyHz = 220.0,
}) {
  final sampleCount = (16000 * duration.inMicroseconds / Duration.microsecondsPerSecond).round();
  final samples = Int16List(sampleCount);
  for (var i = 0; i < sampleCount; i++) {
    final sample = math.sin((2 * math.pi * frequencyHz * i) / 16000);
    samples[i] = (sample * amplitude * 32767.0).round();
  }
  return Uint8List.view(samples.buffer);
}

Uint8List _silenceBytes({required Duration duration}) {
  final sampleCount = (16000 * duration.inMicroseconds / Duration.microsecondsPerSecond).round();
  return Uint8List(sampleCount * 2);
}

final class _ChunkCountWakeWordDetector implements WakeWordDetector {
  _ChunkCountWakeWordDetector({required this.fireOnChunk});

  final int fireOnChunk;
  int _chunkCount = 0;
  bool _fired = false;
  bool disposed = false;

  @override
  List<WakeWordEvent> addChunk(
    Uint8List pcm16leBytes, {
    required int sampleRateHz,
    required int channelCount,
    required WakeWordDetectionConfig config,
  }) {
    _chunkCount++;
    if (_fired || _chunkCount != fireOnChunk) {
      return const <WakeWordEvent>[];
    }
    _fired = true;
    return <WakeWordEvent>[
      WakeWordEvent(keyword: config.keywords.first, confidence: 0.9, detectedAt: DateTime.now()),
    ];
  }

  @override
  void reset() {
    _chunkCount = 0;
    _fired = false;
  }

  @override
  void dispose() {
    disposed = true;
  }
}
