import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;

import 'encoding/aac_encoder.dart';
import 'encoding/native_aac_encoder.dart';
import 'model/pause_split_options.dart';
import 'model/pcm16_snippet.dart';
import 'splitting/pcm16_pause_splitter.dart';
import 'splitting/pcm16_stream_pause_splitter.dart';
import 'vad/speech_vad_config.dart';
import 'vad/vad_backend.dart';

/// High-level helpers for speech segmentation and AAC encoding.
final class SpeechUtils {
  SpeechUtils._();

  /// Splits PCM16 audio into speech snippets, using silence as boundaries.
  static List<Pcm16Snippet> splitPcm16OnSilence({
    required Uint8List pcm16leBytes,
    required PauseSplitOptions options,
    VadBackend? vadBackend,
    SpeechVadConfig vadConfig = const SpeechVadConfig(),
  }) {
    final managedBackend = _ManagedVadBackend.resolve(
      options: options,
      explicitBackend: vadBackend,
      config: vadConfig,
    );
    try {
      final splitter = Pcm16PauseSplitter(options: options, vadBackend: managedBackend.backend);
      return splitter.split(pcm16leBytes);
    } finally {
      managedBackend.disposeIfOwned();
    }
  }

  /// Splits a live PCM16 stream into snippets and emits each snippet once
  /// silence boundaries are detected.
  static Stream<Pcm16Snippet> splitPcm16StreamOnSilence({
    required Stream<Uint8List> pcm16leStream,
    required PauseSplitOptions options,
    VadBackend? vadBackend,
    SpeechVadConfig vadConfig = const SpeechVadConfig(),
  }) async* {
    final managedBackend = _ManagedVadBackend.resolve(
      options: options,
      explicitBackend: vadBackend,
      config: vadConfig,
    );
    final splitter = Pcm16StreamPauseSplitter(options: options, vadBackend: managedBackend.backend);

    try {
      await for (final chunk in pcm16leStream) {
        final emitted = splitter.addChunk(chunk);
        for (final snippet in emitted) {
          yield snippet;
        }
      }

      final trailing = splitter.flush();
      for (final snippet in trailing) {
        yield snippet;
      }
    } finally {
      managedBackend.disposeIfOwned();
    }
  }

  @Deprecated('Use splitPcm16OnSilence instead.')
  static List<Pcm16Snippet> splitPcm16OnLongPauses({
    required Uint8List pcm16leBytes,
    required PauseSplitOptions options,
    VadBackend? vadBackend,
    SpeechVadConfig vadConfig = const SpeechVadConfig(),
  }) {
    return splitPcm16OnSilence(
      pcm16leBytes: pcm16leBytes,
      options: options,
      vadBackend: vadBackend,
      vadConfig: vadConfig,
    );
  }

  @Deprecated('Use splitPcm16StreamOnSilence instead.')
  static Stream<Pcm16Snippet> splitPcm16StreamOnLongPauses({
    required Stream<Uint8List> pcm16leStream,
    required PauseSplitOptions options,
    VadBackend? vadBackend,
    SpeechVadConfig vadConfig = const SpeechVadConfig(),
  }) {
    return splitPcm16StreamOnSilence(
      pcm16leStream: pcm16leStream,
      options: options,
      vadBackend: vadBackend,
      vadConfig: vadConfig,
    );
  }

  /// Writes speech snippets as WAV files.
  static Future<List<File>> splitPcm16AndWriteWavSnippets({
    required Uint8List pcm16leBytes,
    required PauseSplitOptions options,
    required Directory outputDirectory,
    VadBackend? vadBackend,
    SpeechVadConfig vadConfig = const SpeechVadConfig(),
    String filePrefix = 'snippet',
  }) async {
    final snippets = splitPcm16OnSilence(
      pcm16leBytes: pcm16leBytes,
      options: options,
      vadBackend: vadBackend,
      vadConfig: vadConfig,
    );
    await outputDirectory.create(recursive: true);

    final files = <File>[];
    for (var i = 0; i < snippets.length; i++) {
      final outputPath = path.join(
        outputDirectory.path,
        '${filePrefix}_${i.toString().padLeft(3, '0')}.wav',
      );
      files.add(await snippets[i].writeWav(outputPath));
    }
    return files;
  }

  /// Splits PCM16 audio and encodes each snippet to AAC.
  ///
  /// This avoids creating intermediate snippet files in the output directory.
  static Future<List<File>> splitPcm16AndEncodeAacSnippets({
    required Uint8List pcm16leBytes,
    required PauseSplitOptions options,
    required Directory outputDirectory,
    VadBackend? vadBackend,
    SpeechVadConfig vadConfig = const SpeechVadConfig(),
    AacEncoder? encoder,
    int bitrateKbps = 48,
    String filePrefix = 'snippet',
    String fileExtension = 'm4a',
  }) async {
    final snippets = splitPcm16OnSilence(
      pcm16leBytes: pcm16leBytes,
      options: options,
      vadBackend: vadBackend,
      vadConfig: vadConfig,
    );
    await outputDirectory.create(recursive: true);

    final effectiveEncoder = encoder ?? NativeAacEncoder();
    final files = <File>[];
    for (var i = 0; i < snippets.length; i++) {
      final outputPath = path.join(
        outputDirectory.path,
        '${filePrefix}_${i.toString().padLeft(3, '0')}.$fileExtension',
      );
      await effectiveEncoder.encodePcm16BytesToAac(
        pcm16leBytes: snippets[i].asBytesView(),
        sampleRateHz: options.sampleRateHz,
        channelCount: options.channelCount,
        outputPath: outputPath,
        bitrateKbps: bitrateKbps,
      );
      files.add(File(outputPath));
    }
    return files;
  }

  /// Resolves and creates a VAD backend from [options] and [config].
  ///
  /// The caller owns the returned backend and must call `dispose()` when done.
  static ResolvedVadBackend resolveVadBackend({
    required PauseSplitOptions options,
    SpeechVadConfig config = const SpeechVadConfig(),
  }) {
    return resolveSpeechVadBackend(options: options, config: config);
  }
}

final class _ManagedVadBackend {
  const _ManagedVadBackend._({required this.backend, required this.owned});

  final VadBackend backend;
  final bool owned;

  factory _ManagedVadBackend.resolve({
    required PauseSplitOptions options,
    required VadBackend? explicitBackend,
    required SpeechVadConfig config,
  }) {
    if (explicitBackend != null) {
      return _ManagedVadBackend._(backend: explicitBackend, owned: false);
    }
    final resolved = resolveSpeechVadBackend(options: options, config: config);
    return _ManagedVadBackend._(backend: resolved.backend, owned: true);
  }

  void disposeIfOwned() {
    if (!owned) {
      return;
    }
    backend.dispose();
  }
}
