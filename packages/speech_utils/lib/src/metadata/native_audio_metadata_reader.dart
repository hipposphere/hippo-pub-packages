import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart';

import '../encoding/generated/android_aac_bindings.dart' as android_bindings;
import '../encoding/generated/ios_aac_bindings.dart' as ios_bindings;
import '../encoding/generated/windows_aac_bindings.dart' as windows_bindings;
import 'generated/macos_audio_metadata_bindings.dart' as macos_bindings;

typedef NativeAudioMetadataReadFn = AudioMetadataNativeResult Function(String inputPath);
typedef NativeAudioMetadataAvailabilityFn = bool Function();

final class AudioMetadataNativeResult {
  const AudioMetadataNativeResult({
    required this.resultCode,
    required this.durationMicros,
    this.sampleRateHz,
    this.channelCount,
    this.bitrateBps,
    this.error,
  });

  final int resultCode;
  final int durationMicros;
  final int? sampleRateHz;
  final int? channelCount;
  final int? bitrateBps;
  final String? error;
}

enum NativeAudioMetadataPlatform { macOS, windows, android, iOS, unsupported }

final class NativeAudioMetadata {
  const NativeAudioMetadata({
    required this.duration,
    this.sampleRateHz,
    this.channelCount,
    this.bitrateBps,
  });

  final Duration duration;
  final int? sampleRateHz;
  final int? channelCount;
  final int? bitrateBps;
}

final class AudioMetadataException implements Exception {
  AudioMetadataException(this.message, {this.errorCode, this.details});

  final String message;
  final int? errorCode;
  final String? details;

  @override
  String toString() {
    final parts = <String>[
      message,
      if (errorCode != null) 'errorCode=$errorCode',
      if (details != null && details!.isNotEmpty) 'details=$details',
    ];
    return 'AudioMetadataException: ${parts.join(' | ')}';
  }
}

/// Reads media metadata using bundled native platform APIs via FFI.
final class NativeAudioMetadataReader {
  NativeAudioMetadataReader({
    NativeAudioMetadataPlatform? platform,
    NativeAudioMetadataReadFn? macosReadFn,
    NativeAudioMetadataAvailabilityFn? macosAvailabilityFn,
    NativeAudioMetadataReadFn? windowsReadFn,
    NativeAudioMetadataAvailabilityFn? windowsAvailabilityFn,
    NativeAudioMetadataReadFn? androidReadFn,
    NativeAudioMetadataAvailabilityFn? androidAvailabilityFn,
    NativeAudioMetadataReadFn? iosReadFn,
    NativeAudioMetadataAvailabilityFn? iosAvailabilityFn,
  }) : _platform = platform ?? _detectNativeAudioMetadataPlatform(),
       _macosReadFn = macosReadFn ?? _readAudioMetadataViaMacosFfi,
       _macosAvailabilityFn = macosAvailabilityFn ?? _isMacosAudioMetadataAvailableViaFfi,
       _windowsReadFn = windowsReadFn ?? _readAudioMetadataViaWindowsFfi,
       _windowsAvailabilityFn = windowsAvailabilityFn ?? _isWindowsAudioMetadataAvailableViaFfi,
       _androidReadFn = androidReadFn ?? _readAudioMetadataViaAndroidFfi,
       _androidAvailabilityFn = androidAvailabilityFn ?? _isAndroidAudioMetadataAvailableViaFfi,
       _iosReadFn = iosReadFn ?? _readAudioMetadataViaIosFfi,
       _iosAvailabilityFn = iosAvailabilityFn ?? _isIosAudioMetadataAvailableViaFfi;

  final NativeAudioMetadataPlatform _platform;
  final NativeAudioMetadataReadFn _macosReadFn;
  final NativeAudioMetadataAvailabilityFn _macosAvailabilityFn;
  final NativeAudioMetadataReadFn _windowsReadFn;
  final NativeAudioMetadataAvailabilityFn _windowsAvailabilityFn;
  final NativeAudioMetadataReadFn _androidReadFn;
  final NativeAudioMetadataAvailabilityFn _androidAvailabilityFn;
  final NativeAudioMetadataReadFn _iosReadFn;
  final NativeAudioMetadataAvailabilityFn _iosAvailabilityFn;

  Future<bool> isAvailable() async {
    return switch (_platform) {
      NativeAudioMetadataPlatform.macOS => _macosAvailabilityFn(),
      NativeAudioMetadataPlatform.windows => _windowsAvailabilityFn(),
      NativeAudioMetadataPlatform.android => _androidAvailabilityFn(),
      NativeAudioMetadataPlatform.iOS => _iosAvailabilityFn(),
      NativeAudioMetadataPlatform.unsupported => false,
    };
  }

  Future<NativeAudioMetadata> readAudioMetadata({required String inputPath}) async {
    _ensureSupportedPlatform();
    if (inputPath.trim().isEmpty) {
      throw ArgumentError.value(inputPath, 'inputPath', 'Must not be empty');
    }

    final result = switch (_platform) {
      NativeAudioMetadataPlatform.macOS => _macosReadFn(inputPath),
      NativeAudioMetadataPlatform.windows => _windowsReadFn(inputPath),
      NativeAudioMetadataPlatform.android => _androidReadFn(inputPath),
      NativeAudioMetadataPlatform.iOS => _iosReadFn(inputPath),
      NativeAudioMetadataPlatform.unsupported => throw UnsupportedError(
        'NativeAudioMetadataReader is currently supported on macOS, Windows, Android, and iOS.',
      ),
    };

    if (result.resultCode != 0) {
      throw AudioMetadataException(
        'Native audio metadata read failed',
        errorCode: result.resultCode,
        details: result.error,
      );
    }
    if (result.durationMicros < 0) {
      throw AudioMetadataException(
        'Native audio metadata returned an invalid duration',
        errorCode: result.resultCode,
        details: 'durationMicros=${result.durationMicros}',
      );
    }

    return NativeAudioMetadata(
      duration: Duration(microseconds: result.durationMicros),
      sampleRateHz: _toOptionalPositive(result.sampleRateHz),
      channelCount: _toOptionalPositive(result.channelCount),
      bitrateBps: _toOptionalPositive(result.bitrateBps),
    );
  }

  Future<Duration> readAudioDuration({required String inputPath}) async {
    final metadata = await readAudioMetadata(inputPath: inputPath);
    return metadata.duration;
  }

  void _ensureSupportedPlatform() {
    if (_platform == NativeAudioMetadataPlatform.unsupported) {
      throw UnsupportedError(
        'NativeAudioMetadataReader is currently supported on macOS, Windows, Android, and iOS.',
      );
    }
  }
}

int? _toOptionalPositive(int? value) {
  if (value == null || value <= 0) {
    return null;
  }
  return value;
}

NativeAudioMetadataPlatform _detectNativeAudioMetadataPlatform() {
  if (Platform.isMacOS) {
    return NativeAudioMetadataPlatform.macOS;
  }
  if (Platform.isWindows) {
    return NativeAudioMetadataPlatform.windows;
  }
  if (Platform.isAndroid) {
    return NativeAudioMetadataPlatform.android;
  }
  if (Platform.isIOS) {
    return NativeAudioMetadataPlatform.iOS;
  }
  return NativeAudioMetadataPlatform.unsupported;
}

const _metadataErrorBufferBytes = 4096;

bool _isMacosAudioMetadataAvailableViaFfi() {
  final errorPtr = calloc<ffi.Char>(_metadataErrorBufferBytes);
  try {
    try {
      final code = macos_bindings.speech_utils_macos_audio_metadata_healthcheck(
        errorPtr,
        _metadataErrorBufferBytes,
      );
      return code == 0;
    } on Object {
      return false;
    }
  } finally {
    calloc.free(errorPtr);
  }
}

AudioMetadataNativeResult _readAudioMetadataViaMacosFfi(String inputPath) {
  final inputPathPtr = inputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final outDurationPtr = calloc<ffi.Int64>();
  final outSampleRatePtr = calloc<ffi.Int32>();
  final outChannelCountPtr = calloc<ffi.Int32>();
  final outBitratePtr = calloc<ffi.Int32>();
  final errorPtr = calloc<ffi.Char>(_metadataErrorBufferBytes);

  try {
    final code = macos_bindings.speech_utils_macos_read_audio_metadata(
      inputPathPtr,
      outDurationPtr,
      outSampleRatePtr,
      outChannelCountPtr,
      outBitratePtr,
      errorPtr,
      _metadataErrorBufferBytes,
    );
    final error = errorPtr.cast<Utf8>().toDartString();
    return AudioMetadataNativeResult(
      resultCode: code,
      durationMicros: outDurationPtr.value,
      sampleRateHz: outSampleRatePtr.value,
      channelCount: outChannelCountPtr.value,
      bitrateBps: outBitratePtr.value,
      error: error.isEmpty ? null : error,
    );
  } finally {
    calloc.free(inputPathPtr);
    calloc.free(outDurationPtr);
    calloc.free(outSampleRatePtr);
    calloc.free(outChannelCountPtr);
    calloc.free(outBitratePtr);
    calloc.free(errorPtr);
  }
}

bool _isWindowsAudioMetadataAvailableViaFfi() {
  final errorPtr = calloc<ffi.Char>(_metadataErrorBufferBytes);
  try {
    try {
      final code = windows_bindings.speech_utils_windows_audio_metadata_healthcheck(
        errorPtr,
        _metadataErrorBufferBytes,
      );
      return code == 0;
    } on Object {
      return false;
    }
  } finally {
    calloc.free(errorPtr);
  }
}

AudioMetadataNativeResult _readAudioMetadataViaWindowsFfi(String inputPath) {
  final inputPathPtr = inputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final outDurationPtr = calloc<ffi.Int64>();
  final outSampleRatePtr = calloc<ffi.Int32>();
  final outChannelCountPtr = calloc<ffi.Int32>();
  final outBitratePtr = calloc<ffi.Int32>();
  final errorPtr = calloc<ffi.Char>(_metadataErrorBufferBytes);

  try {
    final code = windows_bindings.speech_utils_windows_read_audio_metadata(
      inputPathPtr,
      outDurationPtr,
      outSampleRatePtr,
      outChannelCountPtr,
      outBitratePtr,
      errorPtr,
      _metadataErrorBufferBytes,
    );
    final error = errorPtr.cast<Utf8>().toDartString();
    return AudioMetadataNativeResult(
      resultCode: code,
      durationMicros: outDurationPtr.value,
      sampleRateHz: outSampleRatePtr.value,
      channelCount: outChannelCountPtr.value,
      bitrateBps: outBitratePtr.value,
      error: error.isEmpty ? null : error,
    );
  } finally {
    calloc.free(inputPathPtr);
    calloc.free(outDurationPtr);
    calloc.free(outSampleRatePtr);
    calloc.free(outChannelCountPtr);
    calloc.free(outBitratePtr);
    calloc.free(errorPtr);
  }
}

bool _isAndroidAudioMetadataAvailableViaFfi() {
  final errorPtr = calloc<ffi.Char>(_metadataErrorBufferBytes);
  try {
    try {
      final code = android_bindings.speech_utils_android_audio_metadata_healthcheck(
        errorPtr,
        _metadataErrorBufferBytes,
      );
      return code == 0;
    } on Object {
      return false;
    }
  } finally {
    calloc.free(errorPtr);
  }
}

AudioMetadataNativeResult _readAudioMetadataViaAndroidFfi(String inputPath) {
  final inputPathPtr = inputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final outDurationPtr = calloc<ffi.Int64>();
  final outSampleRatePtr = calloc<ffi.Int32>();
  final outChannelCountPtr = calloc<ffi.Int32>();
  final outBitratePtr = calloc<ffi.Int32>();
  final errorPtr = calloc<ffi.Char>(_metadataErrorBufferBytes);

  try {
    final code = android_bindings.speech_utils_android_read_audio_metadata(
      inputPathPtr,
      outDurationPtr,
      outSampleRatePtr,
      outChannelCountPtr,
      outBitratePtr,
      errorPtr,
      _metadataErrorBufferBytes,
    );
    final error = errorPtr.cast<Utf8>().toDartString();
    return AudioMetadataNativeResult(
      resultCode: code,
      durationMicros: outDurationPtr.value,
      sampleRateHz: outSampleRatePtr.value,
      channelCount: outChannelCountPtr.value,
      bitrateBps: outBitratePtr.value,
      error: error.isEmpty ? null : error,
    );
  } finally {
    calloc.free(inputPathPtr);
    calloc.free(outDurationPtr);
    calloc.free(outSampleRatePtr);
    calloc.free(outChannelCountPtr);
    calloc.free(outBitratePtr);
    calloc.free(errorPtr);
  }
}

bool _isIosAudioMetadataAvailableViaFfi() {
  final errorPtr = calloc<ffi.Char>(_metadataErrorBufferBytes);
  try {
    try {
      final code = ios_bindings.speech_utils_ios_audio_metadata_healthcheck(
        errorPtr,
        _metadataErrorBufferBytes,
      );
      return code == 0;
    } on Object {
      return false;
    }
  } finally {
    calloc.free(errorPtr);
  }
}

AudioMetadataNativeResult _readAudioMetadataViaIosFfi(String inputPath) {
  final inputPathPtr = inputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final outDurationPtr = calloc<ffi.Int64>();
  final outSampleRatePtr = calloc<ffi.Int32>();
  final outChannelCountPtr = calloc<ffi.Int32>();
  final outBitratePtr = calloc<ffi.Int32>();
  final errorPtr = calloc<ffi.Char>(_metadataErrorBufferBytes);

  try {
    final code = ios_bindings.speech_utils_ios_read_audio_metadata(
      inputPathPtr,
      outDurationPtr,
      outSampleRatePtr,
      outChannelCountPtr,
      outBitratePtr,
      errorPtr,
      _metadataErrorBufferBytes,
    );
    final error = errorPtr.cast<Utf8>().toDartString();
    return AudioMetadataNativeResult(
      resultCode: code,
      durationMicros: outDurationPtr.value,
      sampleRateHz: outSampleRatePtr.value,
      channelCount: outChannelCountPtr.value,
      bitrateBps: outBitratePtr.value,
      error: error.isEmpty ? null : error,
    );
  } finally {
    calloc.free(inputPathPtr);
    calloc.free(outDurationPtr);
    calloc.free(outSampleRatePtr);
    calloc.free(outChannelCountPtr);
    calloc.free(outBitratePtr);
    calloc.free(errorPtr);
  }
}
