import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as path;

import 'encoding/aac_encoder.dart';
import 'encoding/native_audio_encoder.dart';
import 'models/pause_split_options.dart';
import 'models/pcm16_snippet.dart';
import 'splitting/pcm16_pause_splitter.dart';
import 'splitting/pcm16_stream_pause_splitter.dart';
import 'vad/speech_vad_config.dart';
import 'vad/vad_backend.dart';

/// High-level helpers for speech segmentation and AAC encoding.
final class SpeechUtils {
  SpeechUtils._();

  /// Splits PCM16 audio into speech snippets, using silence as boundaries.
  ///
  /// Callers own [vadBackend] lifecycle and should dispose it when needed.
  static List<Pcm16Snippet> splitPcm16OnSilence({
    required Uint8List pcm16leBytes,
    required PauseSplitOptions options,
    required VadBackend vadBackend,
  }) {
    final splitter = Pcm16PauseSplitter(options: options, vadBackend: vadBackend);
    return splitter.split(pcm16leBytes);
  }

  /// Splits a live PCM16 stream into snippets and emits each snippet once
  /// silence boundaries are detected.
  ///
  /// Callers own [vadBackend] lifecycle and should dispose it when needed.
  static Stream<Pcm16Snippet> splitPcm16StreamOnSilence({
    required Stream<Uint8List> pcm16leStream,
    required PauseSplitOptions options,
    required VadBackend vadBackend,
  }) async* {
    final splitter = Pcm16StreamPauseSplitter(options: options, vadBackend: vadBackend);

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
  }

  /// Writes speech snippets as WAV files.
  static Future<List<XFile>> splitPcm16AndWriteWavSnippets({
    required Uint8List pcm16leBytes,
    required PauseSplitOptions options,
    required Directory outputDirectory,
    required VadBackend vadBackend,
    String filePrefix = 'snippet',
  }) async {
    final snippets = splitPcm16OnSilence(
      pcm16leBytes: pcm16leBytes,
      options: options,
      vadBackend: vadBackend,
    );
    await outputDirectory.create(recursive: true);

    final files = <XFile>[];
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
  static Future<List<XFile>> splitPcm16AndEncodeAacSnippets({
    required Uint8List pcm16leBytes,
    required PauseSplitOptions options,
    required Directory outputDirectory,
    required VadBackend vadBackend,
    AacEncoder? encoder,
    int bitrateKbps = 48,
    String filePrefix = 'snippet',
    String fileExtension = 'm4a',
  }) async {
    final snippets = splitPcm16OnSilence(
      pcm16leBytes: pcm16leBytes,
      options: options,
      vadBackend: vadBackend,
    );
    await outputDirectory.create(recursive: true);

    final effectiveEncoder = encoder ?? NativeAudioEncoder();
    final files = <XFile>[];
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
      files.add(XFile(outputPath, mimeType: 'audio/aac'));
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
