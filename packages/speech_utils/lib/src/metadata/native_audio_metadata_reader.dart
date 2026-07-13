import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

import '../generated/audio_encoder/android_audio_encoder_bindings.dart' as android_bindings;
import '../generated/audio_encoder/linux_audio_encoder_bindings.dart' as linux_bindings;
import '../generated/metadata/apple_audio_metadata_bindings.dart' as apple_metadata_bindings;
import '../generated/audio_encoder/windows_audio_encoder_bindings.dart' as windows_bindings;
import '../models/audio_metadata.dart';
import '../utils/pcm16_audio_utils.dart';
import '../utils/native_worker_executor.dart';

part 'errors/native_audio_metadata_reader_exceptions.dart';
part 'native_audio_metadata_worker.dart';

typedef NativeAudioMetadataReadFn = AudioMetadata Function(String inputPath);
typedef NativeAudioMetadataAvailabilityFn = bool Function();

enum NativeAudioMetadataPlatform { macOS, windows, linux, android, iOS, unsupported }

const _unsupportedNativeAudioMetadataReaderMessage =
    'NativeAudioMetadataReader is currently supported on macOS, Windows, Linux, Android, and iOS.';

/// Reads media metadata using bundled native platform APIs via FFI.
final class NativeAudioMetadataReader {
  NativeAudioMetadataReader({
    NativeAudioMetadataPlatform? platform,
    NativeAudioMetadataReadFn? macosReadFn,
    NativeAudioMetadataAvailabilityFn? macosAvailabilityFn,
    NativeAudioMetadataReadFn? windowsReadFn,
    NativeAudioMetadataAvailabilityFn? windowsAvailabilityFn,
    NativeAudioMetadataReadFn? linuxReadFn,
    NativeAudioMetadataAvailabilityFn? linuxAvailabilityFn,
    NativeAudioMetadataReadFn? androidReadFn,
    NativeAudioMetadataAvailabilityFn? androidAvailabilityFn,
    NativeAudioMetadataReadFn? iosReadFn,
    NativeAudioMetadataAvailabilityFn? iosAvailabilityFn,
  }) : _platform = platform ?? _detectNativeAudioMetadataPlatform(),
       _useWorker =
           macosReadFn == null &&
           windowsReadFn == null &&
           linuxReadFn == null &&
           androidReadFn == null &&
           iosReadFn == null &&
           _supportsMetadataWorker(platform ?? _detectNativeAudioMetadataPlatform()),
       _macosReadFn = macosReadFn ?? _readAudioMetadataViaMacosFfi,
       _macosAvailabilityFn = macosAvailabilityFn ?? _isAppleAudioMetadataAvailableViaFfi,
       _windowsReadFn = windowsReadFn ?? _readAudioMetadataViaWindowsFfi,
       _windowsAvailabilityFn = windowsAvailabilityFn ?? _isWindowsAudioMetadataAvailableViaFfi,
       _linuxReadFn = linuxReadFn ?? _readAudioMetadataViaLinuxFfi,
       _linuxAvailabilityFn = linuxAvailabilityFn ?? _isLinuxAudioMetadataAvailableViaFfi,
       _androidReadFn = androidReadFn ?? _readAudioMetadataViaAndroidFfi,
       _androidAvailabilityFn = androidAvailabilityFn ?? _isAndroidAudioMetadataAvailableViaFfi,
       _iosReadFn = iosReadFn ?? _readAudioMetadataViaIosFfi,
       _iosAvailabilityFn = iosAvailabilityFn ?? _isAppleAudioMetadataAvailableViaFfi;

  final NativeAudioMetadataPlatform _platform;
  final bool _useWorker;
  final NativeAudioMetadataReadFn _macosReadFn;
  final NativeAudioMetadataAvailabilityFn _macosAvailabilityFn;
  final NativeAudioMetadataReadFn _windowsReadFn;
  final NativeAudioMetadataAvailabilityFn _windowsAvailabilityFn;
  final NativeAudioMetadataReadFn _linuxReadFn;
  final NativeAudioMetadataAvailabilityFn _linuxAvailabilityFn;
  final NativeAudioMetadataReadFn _androidReadFn;
  final NativeAudioMetadataAvailabilityFn _androidAvailabilityFn;
  final NativeAudioMetadataReadFn _iosReadFn;
  final NativeAudioMetadataAvailabilityFn _iosAvailabilityFn;

  Future<bool> isAvailable() async {
    return switch (_platform) {
      NativeAudioMetadataPlatform.macOS => _macosAvailabilityFn(),
      NativeAudioMetadataPlatform.windows => _windowsAvailabilityFn(),
      NativeAudioMetadataPlatform.linux => _linuxAvailabilityFn(),
      NativeAudioMetadataPlatform.android => _androidAvailabilityFn(),
      NativeAudioMetadataPlatform.iOS => _iosAvailabilityFn(),
      NativeAudioMetadataPlatform.unsupported => false,
    };
  }

  Future<AudioMetadata> readAudioMetadata({required String inputPath}) async {
    _ensureSupportedPlatform();
    if (inputPath.trim().isEmpty) {
      throw ArgumentError.value(inputPath, 'inputPath', 'Must not be empty');
    }

    final metadata = _useWorker
        ? await _nativeAudioMetadataWorker.execute<AudioMetadata>(
            _NativeAudioMetadataWorkerRequest(platform: _platform, inputPath: inputPath),
          )
        : _readAudioMetadataDirect(inputPath);

    if (metadata.duration < Duration.zero) {
      throw AudioMetadataException(
        'Native audio metadata returned an invalid duration',
        details: 'durationMicros=${metadata.duration.inMicroseconds}',
      );
    }

    return _buildAudioMetadata(
      duration: metadata.duration,
      sampleRateHz: metadata.sampleRateHz,
      channelCount: metadata.channelCount,
      bitrateBps: metadata.bitrateBps,
      containerFormat: metadata.containerFormat,
      codec: metadata.codec,
      codecProfile: metadata.codecProfile,
    );
  }

  AudioMetadata _readAudioMetadataDirect(String inputPath) {
    return switch (_platform) {
      NativeAudioMetadataPlatform.macOS => _macosReadFn(inputPath),
      NativeAudioMetadataPlatform.windows => _windowsReadFn(inputPath),
      NativeAudioMetadataPlatform.linux => _linuxReadFn(inputPath),
      NativeAudioMetadataPlatform.android => _androidReadFn(inputPath),
      NativeAudioMetadataPlatform.iOS => _iosReadFn(inputPath),
      NativeAudioMetadataPlatform.unsupported =>
        throw const NativeAudioMetadataUnsupportedPlatformException(
          _unsupportedNativeAudioMetadataReaderMessage,
        ),
    };
  }

  Future<Duration> readAudioDuration({required String inputPath}) async {
    final metadata = await readAudioMetadata(inputPath: inputPath);
    return metadata.duration;
  }

  void _ensureSupportedPlatform() {
    if (_platform == NativeAudioMetadataPlatform.unsupported) {
      throw const NativeAudioMetadataUnsupportedPlatformException(
        _unsupportedNativeAudioMetadataReaderMessage,
      );
    }
  }
}

NativeAudioMetadataPlatform _detectNativeAudioMetadataPlatform() {
  if (Platform.isMacOS) {
    return NativeAudioMetadataPlatform.macOS;
  }
  if (Platform.isWindows) {
    return NativeAudioMetadataPlatform.windows;
  }
  if (Platform.isLinux) {
    return NativeAudioMetadataPlatform.linux;
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
const _metadataTextBufferBytes = 256;

AudioMetadata _buildAudioMetadata({
  required Duration duration,
  required int? sampleRateHz,
  required int? channelCount,
  required int? bitrateBps,
  required String? containerFormat,
  required String? codec,
  required String? codecProfile,
}) {
  return AudioMetadata(
    duration: duration,
    sampleRateHz: Pcm16AudioUtils.toOptionalPositive(sampleRateHz),
    channelCount: Pcm16AudioUtils.toOptionalPositive(channelCount),
    bitrateBps: Pcm16AudioUtils.toOptionalPositive(bitrateBps),
    containerFormat: Pcm16AudioUtils.toOptionalText(containerFormat),
    codec: Pcm16AudioUtils.toOptionalText(codec),
    codecProfile: Pcm16AudioUtils.toOptionalText(codecProfile),
  );
}

bool _isAppleAudioMetadataAvailableViaFfi() {
  return true;
}

AudioMetadata _readAudioMetadataViaMacosFfi(String inputPath) {
  return _readAudioMetadataViaAppleFfi(
    inputPath: inputPath,
    function: apple_metadata_bindings.speech_utils_macos_read_audio_metadata,
  );
}

AudioMetadata _readAudioMetadataViaIosFfi(String inputPath) {
  return _readAudioMetadataViaAppleFfi(
    inputPath: inputPath,
    function: apple_metadata_bindings.speech_utils_ios_read_audio_metadata,
  );
}

typedef _AppleAudioMetadataFfi =
    int Function(
      ffi.Pointer<ffi.Char> inputPathUtf8,
      ffi.Pointer<ffi.Int64> outDurationMicros,
      ffi.Pointer<ffi.Int32> outSampleRateHz,
      ffi.Pointer<ffi.Int32> outChannelCount,
      ffi.Pointer<ffi.Int32> outBitrateBps,
      ffi.Pointer<ffi.Char> outContainerFormatUtf8,
      int outContainerFormatUtf8Capacity,
      ffi.Pointer<ffi.Char> outCodecUtf8,
      int outCodecUtf8Capacity,
      ffi.Pointer<ffi.Char> outCodecProfileUtf8,
      int outCodecProfileUtf8Capacity,
      ffi.Pointer<ffi.Char> errorUtf8,
      int errorUtf8Capacity,
    );

AudioMetadata _readAudioMetadataViaAppleFfi({
  required String inputPath,
  required _AppleAudioMetadataFfi function,
}) {
  final inputPathPtr = inputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final outDurationPtr = calloc<ffi.Int64>();
  final outSampleRatePtr = calloc<ffi.Int32>();
  final outChannelCountPtr = calloc<ffi.Int32>();
  final outBitratePtr = calloc<ffi.Int32>();
  final outContainerFormatPtr = calloc<ffi.Char>(_metadataTextBufferBytes);
  final outCodecPtr = calloc<ffi.Char>(_metadataTextBufferBytes);
  final outCodecProfilePtr = calloc<ffi.Char>(_metadataTextBufferBytes);
  final errorPtr = calloc<ffi.Char>(_metadataErrorBufferBytes);

  try {
    final code = function(
      inputPathPtr,
      outDurationPtr,
      outSampleRatePtr,
      outChannelCountPtr,
      outBitratePtr,
      outContainerFormatPtr,
      _metadataTextBufferBytes,
      outCodecPtr,
      _metadataTextBufferBytes,
      outCodecProfilePtr,
      _metadataTextBufferBytes,
      errorPtr,
      _metadataErrorBufferBytes,
    );
    final containerFormat = outContainerFormatPtr.cast<Utf8>().toDartString();
    final codec = outCodecPtr.cast<Utf8>().toDartString();
    final codecProfile = outCodecProfilePtr.cast<Utf8>().toDartString();
    final error = errorPtr.cast<Utf8>().toDartString();
    if (code != 0) {
      throw AudioMetadataException(
        'Native audio metadata read failed',
        errorCode: code,
        details: error.isEmpty ? null : error,
      );
    }

    final durationMicros = outDurationPtr.value;
    if (durationMicros < 0) {
      throw AudioMetadataException(
        'Native audio metadata returned an invalid duration',
        details: 'durationMicros=$durationMicros',
      );
    }

    return _buildAudioMetadata(
      duration: Duration(microseconds: durationMicros),
      sampleRateHz: outSampleRatePtr.value,
      channelCount: outChannelCountPtr.value,
      bitrateBps: outBitratePtr.value,
      containerFormat: containerFormat,
      codec: codec,
      codecProfile: codecProfile,
    );
  } finally {
    calloc.free(inputPathPtr);
    calloc.free(outDurationPtr);
    calloc.free(outSampleRatePtr);
    calloc.free(outChannelCountPtr);
    calloc.free(outBitratePtr);
    calloc.free(outContainerFormatPtr);
    calloc.free(outCodecPtr);
    calloc.free(outCodecProfilePtr);
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

AudioMetadata _readAudioMetadataViaWindowsFfi(String inputPath) {
  final inputPathPtr = inputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final outDurationPtr = calloc<ffi.Int64>();
  final outSampleRatePtr = calloc<ffi.Int32>();
  final outChannelCountPtr = calloc<ffi.Int32>();
  final outBitratePtr = calloc<ffi.Int32>();
  final outContainerFormatPtr = calloc<ffi.Char>(_metadataTextBufferBytes);
  final outCodecPtr = calloc<ffi.Char>(_metadataTextBufferBytes);
  final outCodecProfilePtr = calloc<ffi.Char>(_metadataTextBufferBytes);
  final errorPtr = calloc<ffi.Char>(_metadataErrorBufferBytes);

  try {
    final code = windows_bindings.speech_utils_windows_read_audio_metadata(
      inputPathPtr,
      outDurationPtr,
      outSampleRatePtr,
      outChannelCountPtr,
      outBitratePtr,
      outContainerFormatPtr,
      _metadataTextBufferBytes,
      outCodecPtr,
      _metadataTextBufferBytes,
      outCodecProfilePtr,
      _metadataTextBufferBytes,
      errorPtr,
      _metadataErrorBufferBytes,
    );
    final containerFormat = outContainerFormatPtr.cast<Utf8>().toDartString();
    final codec = outCodecPtr.cast<Utf8>().toDartString();
    final codecProfile = outCodecProfilePtr.cast<Utf8>().toDartString();
    final error = errorPtr.cast<Utf8>().toDartString();
    if (code != 0) {
      throw AudioMetadataException(
        'Native audio metadata read failed',
        errorCode: code,
        details: error.isEmpty ? null : error,
      );
    }

    final durationMicros = outDurationPtr.value;
    if (durationMicros < 0) {
      throw AudioMetadataException(
        'Native audio metadata returned an invalid duration',
        details: 'durationMicros=$durationMicros',
      );
    }

    return _buildAudioMetadata(
      duration: Duration(microseconds: durationMicros),
      sampleRateHz: outSampleRatePtr.value,
      channelCount: outChannelCountPtr.value,
      bitrateBps: outBitratePtr.value,
      containerFormat: containerFormat,
      codec: codec,
      codecProfile: codecProfile,
    );
  } finally {
    calloc.free(inputPathPtr);
    calloc.free(outDurationPtr);
    calloc.free(outSampleRatePtr);
    calloc.free(outChannelCountPtr);
    calloc.free(outBitratePtr);
    calloc.free(outContainerFormatPtr);
    calloc.free(outCodecPtr);
    calloc.free(outCodecProfilePtr);
    calloc.free(errorPtr);
  }
}

bool _isLinuxAudioMetadataAvailableViaFfi() {
  final errorPtr = calloc<ffi.Char>(_metadataErrorBufferBytes);
  try {
    try {
      final code = linux_bindings.speech_utils_linux_audio_metadata_healthcheck(
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

AudioMetadata _readAudioMetadataViaLinuxFfi(String inputPath) {
  final inputPathPtr = inputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final outDurationPtr = calloc<ffi.Int64>();
  final outSampleRatePtr = calloc<ffi.Int32>();
  final outChannelCountPtr = calloc<ffi.Int32>();
  final outBitratePtr = calloc<ffi.Int32>();
  final outContainerFormatPtr = calloc<ffi.Char>(_metadataTextBufferBytes);
  final outCodecPtr = calloc<ffi.Char>(_metadataTextBufferBytes);
  final outCodecProfilePtr = calloc<ffi.Char>(_metadataTextBufferBytes);
  final errorPtr = calloc<ffi.Char>(_metadataErrorBufferBytes);

  try {
    final code = linux_bindings.speech_utils_linux_read_audio_metadata(
      inputPathPtr,
      outDurationPtr,
      outSampleRatePtr,
      outChannelCountPtr,
      outBitratePtr,
      outContainerFormatPtr,
      _metadataTextBufferBytes,
      outCodecPtr,
      _metadataTextBufferBytes,
      outCodecProfilePtr,
      _metadataTextBufferBytes,
      errorPtr,
      _metadataErrorBufferBytes,
    );
    final containerFormat = outContainerFormatPtr.cast<Utf8>().toDartString();
    final codec = outCodecPtr.cast<Utf8>().toDartString();
    final codecProfile = outCodecProfilePtr.cast<Utf8>().toDartString();
    final error = errorPtr.cast<Utf8>().toDartString();
    if (code != 0) {
      throw AudioMetadataException(
        'Native audio metadata read failed',
        errorCode: code,
        details: error.isEmpty ? null : error,
      );
    }

    final durationMicros = outDurationPtr.value;
    if (durationMicros < 0) {
      throw AudioMetadataException(
        'Native audio metadata returned an invalid duration',
        details: 'durationMicros=$durationMicros',
      );
    }

    return _buildAudioMetadata(
      duration: Duration(microseconds: durationMicros),
      sampleRateHz: outSampleRatePtr.value,
      channelCount: outChannelCountPtr.value,
      bitrateBps: outBitratePtr.value,
      containerFormat: containerFormat,
      codec: codec,
      codecProfile: codecProfile,
    );
  } finally {
    calloc.free(inputPathPtr);
    calloc.free(outDurationPtr);
    calloc.free(outSampleRatePtr);
    calloc.free(outChannelCountPtr);
    calloc.free(outBitratePtr);
    calloc.free(outContainerFormatPtr);
    calloc.free(outCodecPtr);
    calloc.free(outCodecProfilePtr);
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

AudioMetadata _readAudioMetadataViaAndroidFfi(String inputPath) {
  final inputPathPtr = inputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final outDurationPtr = calloc<ffi.Int64>();
  final outSampleRatePtr = calloc<ffi.Int32>();
  final outChannelCountPtr = calloc<ffi.Int32>();
  final outBitratePtr = calloc<ffi.Int32>();
  final outContainerFormatPtr = calloc<ffi.Char>(_metadataTextBufferBytes);
  final outCodecPtr = calloc<ffi.Char>(_metadataTextBufferBytes);
  final outCodecProfilePtr = calloc<ffi.Char>(_metadataTextBufferBytes);
  final errorPtr = calloc<ffi.Char>(_metadataErrorBufferBytes);

  try {
    final code = android_bindings.speech_utils_android_read_audio_metadata(
      inputPathPtr,
      outDurationPtr,
      outSampleRatePtr,
      outChannelCountPtr,
      outBitratePtr,
      outContainerFormatPtr,
      _metadataTextBufferBytes,
      outCodecPtr,
      _metadataTextBufferBytes,
      outCodecProfilePtr,
      _metadataTextBufferBytes,
      errorPtr,
      _metadataErrorBufferBytes,
    );
    final containerFormat = outContainerFormatPtr.cast<Utf8>().toDartString();
    final codec = outCodecPtr.cast<Utf8>().toDartString();
    final codecProfile = outCodecProfilePtr.cast<Utf8>().toDartString();
    final error = errorPtr.cast<Utf8>().toDartString();
    if (code != 0) {
      throw AudioMetadataException(
        'Native audio metadata read failed',
        errorCode: code,
        details: error.isEmpty ? null : error,
      );
    }

    final durationMicros = outDurationPtr.value;
    if (durationMicros < 0) {
      throw AudioMetadataException(
        'Native audio metadata returned an invalid duration',
        details: 'durationMicros=$durationMicros',
      );
    }

    return _buildAudioMetadata(
      duration: Duration(microseconds: durationMicros),
      sampleRateHz: outSampleRatePtr.value,
      channelCount: outChannelCountPtr.value,
      bitrateBps: outBitratePtr.value,
      containerFormat: containerFormat,
      codec: codec,
      codecProfile: codecProfile,
    );
  } finally {
    calloc.free(inputPathPtr);
    calloc.free(outDurationPtr);
    calloc.free(outSampleRatePtr);
    calloc.free(outChannelCountPtr);
    calloc.free(outBitratePtr);
    calloc.free(outContainerFormatPtr);
    calloc.free(outCodecPtr);
    calloc.free(outCodecProfilePtr);
    calloc.free(errorPtr);
  }
}
