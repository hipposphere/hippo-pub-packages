import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'aac_encoder.dart';
import 'generated/android_aac_bindings.dart' as android_bindings;
import 'generated/ios_aac_bindings.dart' as ios_bindings;
import 'generated/windows_aac_bindings.dart' as windows_bindings;

typedef NativeAacCommandRunner =
    Future<NativeAacCommandResult> Function(String executable, List<String> arguments);

typedef WindowsNativeAacEncodeFn =
    void Function({required String inputPath, required String outputPath, required int bitrateBps});

typedef WindowsNativeAacAvailabilityFn = bool Function();

typedef AndroidNativeAacEncodeFn =
    void Function({required String inputPath, required String outputPath, required int bitrateBps});

typedef AndroidNativeAacAvailabilityFn = bool Function();

typedef IosNativeAacEncodeFn =
    void Function({required String inputPath, required String outputPath, required int bitrateBps});

typedef IosNativeAacAvailabilityFn = bool Function();

final class NativeAacCommandResult {
  const NativeAacCommandResult({required this.exitCode, required this.stderr});

  final int exitCode;
  final String stderr;
}

enum NativeAacPlatform { macOS, windows, android, iOS, unsupported }

/// AAC encoder that uses native platform tooling:
/// - macOS: `afconvert`
/// - Windows: bundled native Media Foundation bridge via Dart FFI
/// - Android: bundled native NDK bridge via Dart FFI (PCM16 WAV input path)
/// - iOS: bundled native AVFoundation bridge via Dart FFI
///
/// This encoder intentionally does not fall back to ffmpeg.
final class NativeAacEncoder implements AacEncoder {
  NativeAacEncoder({
    this.executable = 'afconvert',
    NativeAacCommandRunner? commandRunner,
    NativeAacPlatform? platform,
    WindowsNativeAacEncodeFn? windowsEncodeFn,
    WindowsNativeAacAvailabilityFn? windowsAvailabilityFn,
    AndroidNativeAacEncodeFn? androidEncodeFn,
    AndroidNativeAacAvailabilityFn? androidAvailabilityFn,
    IosNativeAacEncodeFn? iosEncodeFn,
    IosNativeAacAvailabilityFn? iosAvailabilityFn,
  }) : _commandRunner = commandRunner ?? _defaultNativeAacCommandRunner,
       _platform = platform ?? _detectNativeAacPlatform(),
       _windowsEncodeFn = windowsEncodeFn ?? _encodeAudioFileToAacViaWindowsFfi,
       _windowsAvailabilityFn = windowsAvailabilityFn ?? _isWindowsNativeAacAvailableViaFfi,
       _androidEncodeFn = androidEncodeFn ?? _encodeAudioFileToAacViaAndroidFfi,
       _androidAvailabilityFn = androidAvailabilityFn ?? _isAndroidNativeAacAvailableViaFfi,
       _iosEncodeFn = iosEncodeFn ?? _encodeAudioFileToAacViaIosFfi,
       _iosAvailabilityFn = iosAvailabilityFn ?? _isIosNativeAacAvailableViaFfi;

  /// macOS encoder executable (`afconvert` by default).
  final String executable;

  final NativeAacCommandRunner _commandRunner;
  final NativeAacPlatform _platform;
  final WindowsNativeAacEncodeFn _windowsEncodeFn;
  final WindowsNativeAacAvailabilityFn _windowsAvailabilityFn;
  final AndroidNativeAacEncodeFn _androidEncodeFn;
  final AndroidNativeAacAvailabilityFn _androidAvailabilityFn;
  final IosNativeAacEncodeFn _iosEncodeFn;
  final IosNativeAacAvailabilityFn _iosAvailabilityFn;

  Future<bool> isAvailable() async {
    switch (_platform) {
      case NativeAacPlatform.macOS:
        try {
          await _commandRunner(executable, const ['-h']);
          return true;
        } on Object {
          return false;
        }
      case NativeAacPlatform.windows:
        return _windowsAvailabilityFn();
      case NativeAacPlatform.android:
        return _androidAvailabilityFn();
      case NativeAacPlatform.iOS:
        return _iosAvailabilityFn();
      case NativeAacPlatform.unsupported:
        return false;
    }
  }

  @override
  Future<void> encodePcm16BytesToAac({
    required Uint8List pcm16leBytes,
    required int sampleRateHz,
    required int channelCount,
    required String outputPath,
    int bitrateKbps = 48,
  }) async {
    _ensureSupportedPlatform();
    _validatePcmParams(sampleRateHz: sampleRateHz, channelCount: channelCount);
    if (pcm16leBytes.isEmpty) {
      throw ArgumentError.value(pcm16leBytes, 'pcm16leBytes', 'Cannot be empty');
    }
    if (pcm16leBytes.length.isOdd) {
      throw ArgumentError.value(
        pcm16leBytes.length,
        'pcm16leBytes',
        'PCM16 byte length must be even',
      );
    }

    await _withTempDirectory((tempDir) async {
      final normalized = _normalizePcm16ForWindowsAac(
        pcm16leBytes: pcm16leBytes,
        sampleRateHz: sampleRateHz,
        channelCount: channelCount,
        isWindowsPlatform: _platform == NativeAacPlatform.windows,
      );
      final wavPath = '${tempDir.path}${Platform.pathSeparator}input.wav';
      await _writePcm16BytesAsWav(
        pcm16leBytes: normalized.bytes,
        sampleRateHz: normalized.sampleRateHz,
        channelCount: channelCount,
        wavOutputPath: wavPath,
      );
      await encodeAudioFileToAac(
        inputPath: wavPath,
        outputPath: outputPath,
        bitrateKbps: bitrateKbps,
      );
    });
  }

  @override
  Future<void> encodePcm16FileToAac({
    required String inputPath,
    required int sampleRateHz,
    required int channelCount,
    required String outputPath,
    int bitrateKbps = 48,
  }) async {
    _ensureSupportedPlatform();
    _validatePcmParams(sampleRateHz: sampleRateHz, channelCount: channelCount);

    final inputFile = File(inputPath);
    final inputLength = await inputFile.length();
    if (inputLength <= 0) {
      throw ArgumentError.value(inputPath, 'inputPath', 'PCM file cannot be empty');
    }
    if (inputLength.isOdd) {
      throw ArgumentError.value(inputPath, 'inputPath', 'PCM16 file length must be even');
    }

    await _withTempDirectory((tempDir) async {
      final wavPath = '${tempDir.path}${Platform.pathSeparator}input.wav';
      if (_shouldResampleForWindowsAac(
        sampleRateHz,
        isWindowsPlatform: _platform == NativeAacPlatform.windows,
      )) {
        final pcm16leBytes = await inputFile.readAsBytes();
        final normalized = _normalizePcm16ForWindowsAac(
          pcm16leBytes: pcm16leBytes,
          sampleRateHz: sampleRateHz,
          channelCount: channelCount,
          isWindowsPlatform: _platform == NativeAacPlatform.windows,
        );
        await _writePcm16BytesAsWav(
          pcm16leBytes: normalized.bytes,
          sampleRateHz: normalized.sampleRateHz,
          channelCount: channelCount,
          wavOutputPath: wavPath,
        );
      } else {
        await _writePcm16FileAsWav(
          inputFile: inputFile,
          inputPcmByteLength: inputLength,
          sampleRateHz: sampleRateHz,
          channelCount: channelCount,
          wavOutputPath: wavPath,
        );
      }
      await encodeAudioFileToAac(
        inputPath: wavPath,
        outputPath: outputPath,
        bitrateKbps: bitrateKbps,
      );
    });
  }

  @override
  Future<void> encodeAudioFileToAac({
    required String inputPath,
    required String outputPath,
    int bitrateKbps = 48,
  }) async {
    _ensureSupportedPlatform();
    if (bitrateKbps <= 0) {
      throw ArgumentError.value(bitrateKbps, 'bitrateKbps', 'Must be > 0');
    }

    final outputFile = File(outputPath);
    if (await outputFile.exists()) {
      await outputFile.delete();
    }

    switch (_platform) {
      case NativeAacPlatform.macOS:
        final args = <String>[
          '-f',
          'm4af',
          '-d',
          'aac',
          '-b',
          '${bitrateKbps * 1000}',
          inputPath,
          outputPath,
        ];
        await _runCommand(executable, args, commandLabel: 'native AAC command');
      case NativeAacPlatform.windows:
        try {
          _windowsEncodeFn(
            inputPath: inputPath,
            outputPath: outputPath,
            bitrateBps: bitrateKbps * 1000,
          );
        } on AacEncodingException {
          rethrow;
        } on Object catch (error) {
          throw AacEncodingException('Failed to execute windows native AAC encoder: $error');
        }
      case NativeAacPlatform.android:
        try {
          _androidEncodeFn(
            inputPath: inputPath,
            outputPath: outputPath,
            bitrateBps: bitrateKbps * 1000,
          );
        } on AacEncodingException {
          rethrow;
        } on Object catch (error) {
          throw AacEncodingException('Failed to execute android native AAC encoder: $error');
        }
      case NativeAacPlatform.iOS:
        try {
          _iosEncodeFn(
            inputPath: inputPath,
            outputPath: outputPath,
            bitrateBps: bitrateKbps * 1000,
          );
        } on AacEncodingException {
          rethrow;
        } on Object catch (error) {
          throw AacEncodingException('Failed to execute iOS native AAC encoder: $error');
        }
      case NativeAacPlatform.unsupported:
        _ensureSupportedPlatform();
    }
  }

  void _ensureSupportedPlatform() {
    if (_platform == NativeAacPlatform.unsupported) {
      throw UnsupportedError(
        'NativeAacEncoder is currently supported on macOS (afconvert), '
        'Windows (Media Foundation), Android (NDK MediaCodec), and '
        'iOS (AVFoundation).',
      );
    }
  }

  void _validatePcmParams({required int sampleRateHz, required int channelCount}) {
    if (sampleRateHz <= 0) {
      throw ArgumentError.value(sampleRateHz, 'sampleRateHz', 'Must be > 0');
    }
    if (channelCount <= 0) {
      throw ArgumentError.value(channelCount, 'channelCount', 'Must be > 0');
    }
  }

  Future<void> _runCommand(
    String executable,
    List<String> args, {
    required String commandLabel,
  }) async {
    NativeAacCommandResult result;
    try {
      result = await _commandRunner(executable, args);
    } on AacEncodingException {
      rethrow;
    } on Object catch (error) {
      throw AacEncodingException('Failed to execute $commandLabel: $error');
    }

    if (result.exitCode != 0) {
      throw AacEncodingException(
        '$commandLabel exited with a non-zero code',
        exitCode: result.exitCode,
        stderr: result.stderr,
      );
    }
  }

  Future<void> _withTempDirectory(Future<void> Function(Directory tempDir) action) async {
    final tempDir = await Directory.systemTemp.createTemp('speech_utils_aac_');
    try {
      await action(tempDir);
    } finally {
      try {
        await tempDir.delete(recursive: true);
      } on Object {
        // Best-effort cleanup.
      }
    }
  }
}

const _windowsPreferredAacSampleRateHz = 48000;

bool _shouldResampleForWindowsAac(
  int sampleRateHz, {
  required bool isWindowsPlatform,
}) {
  return isWindowsPlatform && sampleRateHz != _windowsPreferredAacSampleRateHz;
}

({Uint8List bytes, int sampleRateHz}) _normalizePcm16ForWindowsAac({
  required Uint8List pcm16leBytes,
  required int sampleRateHz,
  required int channelCount,
  required bool isWindowsPlatform,
}) {
  if (
      !_shouldResampleForWindowsAac(
        sampleRateHz,
        isWindowsPlatform: isWindowsPlatform,
      )) {
    return (bytes: pcm16leBytes, sampleRateHz: sampleRateHz);
  }
  return (
    bytes: _resamplePcm16leLinear(
      pcm16leBytes: pcm16leBytes,
      inSampleRateHz: sampleRateHz,
      outSampleRateHz: _windowsPreferredAacSampleRateHz,
      channelCount: channelCount,
    ),
    sampleRateHz: _windowsPreferredAacSampleRateHz,
  );
}

Uint8List _resamplePcm16leLinear({
  required Uint8List pcm16leBytes,
  required int inSampleRateHz,
  required int outSampleRateHz,
  required int channelCount,
}) {
  if (inSampleRateHz == outSampleRateHz) {
    return pcm16leBytes;
  }
  final input = Int16List.view(
    pcm16leBytes.buffer,
    pcm16leBytes.offsetInBytes,
    pcm16leBytes.lengthInBytes ~/ 2,
  );
  final inputFrameCount = input.length ~/ channelCount;
  if (inputFrameCount <= 1) {
    return pcm16leBytes;
  }

  final outputFrameCount = ((inputFrameCount * outSampleRateHz) / inSampleRateHz)
      .round()
      .clamp(1, 1 << 30);
  final output = Int16List(outputFrameCount * channelCount);

  for (var frame = 0; frame < outputFrameCount; frame++) {
    final sourcePosition = frame * inSampleRateHz / outSampleRateHz;
    final i0 = sourcePosition.floor().clamp(0, inputFrameCount - 1);
    final i1 = (i0 + 1).clamp(0, inputFrameCount - 1);
    final mix = sourcePosition - i0;
    for (var channel = 0; channel < channelCount; channel++) {
      final s0 = input[i0 * channelCount + channel];
      final s1 = input[i1 * channelCount + channel];
      final sample = (s0 + (s1 - s0) * mix).round().clamp(-32768, 32767);
      output[frame * channelCount + channel] = sample;
    }
  }

  return Uint8List.view(output.buffer);
}

NativeAacPlatform _detectNativeAacPlatform() {
  if (Platform.isMacOS) {
    return NativeAacPlatform.macOS;
  }
  if (Platform.isWindows) {
    return NativeAacPlatform.windows;
  }
  if (Platform.isAndroid) {
    return NativeAacPlatform.android;
  }
  if (Platform.isIOS) {
    return NativeAacPlatform.iOS;
  }
  return NativeAacPlatform.unsupported;
}

Future<void> _writePcm16BytesAsWav({
  required Uint8List pcm16leBytes,
  required int sampleRateHz,
  required int channelCount,
  required String wavOutputPath,
}) async {
  final output = File(wavOutputPath);
  final sink = output.openWrite();
  sink.add(
    _buildPcm16WavHeader(
      sampleRateHz: sampleRateHz,
      channelCount: channelCount,
      pcmDataByteLength: pcm16leBytes.length,
    ),
  );
  sink.add(pcm16leBytes);
  await sink.close();
}

Future<void> _writePcm16FileAsWav({
  required File inputFile,
  required int inputPcmByteLength,
  required int sampleRateHz,
  required int channelCount,
  required String wavOutputPath,
}) async {
  final output = File(wavOutputPath);
  final sink = output.openWrite();
  sink.add(
    _buildPcm16WavHeader(
      sampleRateHz: sampleRateHz,
      channelCount: channelCount,
      pcmDataByteLength: inputPcmByteLength,
    ),
  );
  await sink.addStream(inputFile.openRead());
  await sink.close();
}

Uint8List _buildPcm16WavHeader({
  required int sampleRateHz,
  required int channelCount,
  required int pcmDataByteLength,
}) {
  final header = Uint8List(44);
  final data = ByteData.sublistView(header);

  void writeAscii(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      header[offset + i] = value.codeUnitAt(i);
    }
  }

  final byteRate = sampleRateHz * channelCount * 2;
  final blockAlign = channelCount * 2;
  final riffChunkSize = 36 + pcmDataByteLength;

  writeAscii(0, 'RIFF');
  data.setUint32(4, riffChunkSize, Endian.little);
  writeAscii(8, 'WAVE');
  writeAscii(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, channelCount, Endian.little);
  data.setUint32(24, sampleRateHz, Endian.little);
  data.setUint32(28, byteRate, Endian.little);
  data.setUint16(32, blockAlign, Endian.little);
  data.setUint16(34, 16, Endian.little);
  writeAscii(36, 'data');
  data.setUint32(40, pcmDataByteLength, Endian.little);

  return header;
}

Future<NativeAacCommandResult> _defaultNativeAacCommandRunner(
  String executable,
  List<String> arguments,
) async {
  Process process;
  try {
    process = await Process.start(executable, arguments, runInShell: false);
  } on ProcessException catch (error) {
    throw AacEncodingException('Failed to start native AAC encoder: ${error.message}');
  }

  final stderrFuture = process.stderr.transform(utf8.decoder).join();
  final stdoutDrainFuture = process.stdout.drain<void>();

  final exitCode = await process.exitCode;
  await stdoutDrainFuture;
  final stderr = await stderrFuture;
  return NativeAacCommandResult(exitCode: exitCode, stderr: stderr);
}

const _nativeErrorBufferBytes = 4096;

bool _isWindowsNativeAacAvailableViaFfi() {
  final errorPtr = calloc<ffi.Char>(_nativeErrorBufferBytes);
  try {
    final hr = windows_bindings.speech_utils_windows_aac_encoder_healthcheck(
      errorPtr,
      _nativeErrorBufferBytes,
    );
    return hr == 0;
  } finally {
    calloc.free(errorPtr);
  }
}

void _encodeAudioFileToAacViaWindowsFfi({
  required String inputPath,
  required String outputPath,
  required int bitrateBps,
}) {
  final inputPathPtr = inputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final outputPathPtr = outputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final errorPtr = calloc<ffi.Char>(_nativeErrorBufferBytes);

  try {
    final hr = windows_bindings.speech_utils_windows_encode_audio_file_to_aac(
      inputPathPtr,
      outputPathPtr,
      bitrateBps,
      errorPtr,
      _nativeErrorBufferBytes,
    );
    if (hr == 0) {
      return;
    }

    final stderr = errorPtr.cast<Utf8>().toDartString();
    throw AacEncodingException(
      'windows native AAC encoder failed',
      exitCode: hr,
      stderr: stderr.isEmpty ? null : stderr,
    );
  } finally {
    calloc.free(inputPathPtr);
    calloc.free(outputPathPtr);
    calloc.free(errorPtr);
  }
}

bool _isAndroidNativeAacAvailableViaFfi() {
  final errorPtr = calloc<ffi.Char>(_nativeErrorBufferBytes);
  try {
    final code = android_bindings.speech_utils_android_aac_encoder_healthcheck(
      errorPtr,
      _nativeErrorBufferBytes,
    );
    return code == 0;
  } finally {
    calloc.free(errorPtr);
  }
}

void _encodeAudioFileToAacViaAndroidFfi({
  required String inputPath,
  required String outputPath,
  required int bitrateBps,
}) {
  final inputPathPtr = inputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final outputPathPtr = outputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final errorPtr = calloc<ffi.Char>(_nativeErrorBufferBytes);

  try {
    final code = android_bindings.speech_utils_android_encode_wav_file_to_aac_m4a(
      inputPathPtr,
      outputPathPtr,
      bitrateBps,
      errorPtr,
      _nativeErrorBufferBytes,
    );
    if (code == 0) {
      return;
    }

    final stderr = errorPtr.cast<Utf8>().toDartString();
    throw AacEncodingException(
      'android native AAC encoder failed',
      exitCode: code,
      stderr: stderr.isEmpty ? null : stderr,
    );
  } finally {
    calloc.free(inputPathPtr);
    calloc.free(outputPathPtr);
    calloc.free(errorPtr);
  }
}

bool _isIosNativeAacAvailableViaFfi() {
  final errorPtr = calloc<ffi.Char>(_nativeErrorBufferBytes);
  try {
    final code = ios_bindings.speech_utils_ios_aac_encoder_healthcheck(
      errorPtr,
      _nativeErrorBufferBytes,
    );
    return code == 0;
  } finally {
    calloc.free(errorPtr);
  }
}

void _encodeAudioFileToAacViaIosFfi({
  required String inputPath,
  required String outputPath,
  required int bitrateBps,
}) {
  final inputPathPtr = inputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final outputPathPtr = outputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final errorPtr = calloc<ffi.Char>(_nativeErrorBufferBytes);

  try {
    final code = ios_bindings.speech_utils_ios_encode_audio_file_to_aac(
      inputPathPtr,
      outputPathPtr,
      bitrateBps,
      errorPtr,
      _nativeErrorBufferBytes,
    );
    if (code == 0) {
      return;
    }

    final stderr = errorPtr.cast<Utf8>().toDartString();
    throw AacEncodingException(
      'iOS native AAC encoder failed',
      exitCode: code,
      stderr: stderr.isEmpty ? null : stderr,
    );
  } finally {
    calloc.free(inputPathPtr);
    calloc.free(outputPathPtr);
    calloc.free(errorPtr);
  }
}
