import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'generated/ten_vad_bindings.dart' as ten_vad;
import 'vad_backend.dart';

/// TEN VAD backend using bundled native assets.
///
/// Requires mono 16kHz PCM16 frames with a fixed hop size.
final class TenVadFfiBackend extends VadBackend {
  TenVadFfiBackend({this.hopSize = 256, double threshold = 0.5}) {
    _ensureSupportedPlatform();
    if (hopSize <= 0) {
      throw ArgumentError.value(hopSize, 'hopSize', 'Must be > 0');
    }
    if (threshold < 0 || threshold > 1) {
      throw ArgumentError.value(threshold, 'threshold', 'Must be in [0, 1]');
    }

    final handleOut = calloc<ten_vad.ten_vad_handle_t>();
    try {
      final result = ten_vad.ten_vad_create(handleOut, hopSize, threshold);
      if (result != 0 || handleOut.value == ffi.nullptr) {
        throw TenVadException(
          'TEN VAD initialization failed (result=$result). '
          'Ensure native assets were bundled for this target.',
        );
      }
      _vadHandle = handleOut.value;
    } finally {
      calloc.free(handleOut);
    }

    _scratch = calloc<ffi.Int16>(hopSize);
    _scratchView = _scratch.asTypedList(hopSize);
    _outProbability = calloc<ffi.Float>();
    _outFlag = calloc<ffi.Int>();
  }

  /// Returns null if TEN VAD cannot be initialized on this runtime.
  static TenVadFfiBackend? tryCreate({int hopSize = 256, double threshold = 0.5}) {
    try {
      return TenVadFfiBackend(hopSize: hopSize, threshold: threshold);
    } on Object {
      return null;
    }
  }

  /// Whether bundled TEN VAD assets are expected for this runtime target.
  static bool get supportsCurrentPlatform {
    return switch (ffi.Abi.current()) {
      ffi.Abi.macosArm64 ||
      ffi.Abi.macosX64 ||
      ffi.Abi.windowsX64 ||
      ffi.Abi.androidArm ||
      ffi.Abi.androidArm64 ||
      ffi.Abi.iosArm64 => true,
      _ => false,
    };
  }

  /// Returns bundled TEN VAD library version when available.
  static String? versionOrNull() {
    if (!supportsCurrentPlatform) {
      return null;
    }
    try {
      final version = ten_vad.ten_vad_get_version();
      if (version == ffi.nullptr) {
        return null;
      }
      return version.cast<Utf8>().toDartString();
    } on Object {
      return null;
    }
  }

  final int hopSize;

  ffi.Pointer<ffi.Void> _vadHandle = ffi.nullptr;
  late final ffi.Pointer<ffi.Int16> _scratch;
  late final Int16List _scratchView;
  late final ffi.Pointer<ffi.Float> _outProbability;
  late final ffi.Pointer<ffi.Int> _outFlag;

  bool _disposed = false;

  @override
  bool isSpeechFrame(
    Int16List interleavedPcm16Samples, {
    required int startSampleOffset,
    required int sampleCount,
    required int sampleRateHz,
    required int channelCount,
  }) {
    if (_disposed) {
      throw StateError('TEN VAD backend has been disposed');
    }
    if (sampleRateHz != 16000) {
      throw ArgumentError.value(sampleRateHz, 'sampleRateHz', 'TEN VAD expects 16000 Hz');
    }
    if (channelCount != 1) {
      throw ArgumentError.value(channelCount, 'channelCount', 'TEN VAD expects mono PCM');
    }
    if (sampleCount != hopSize) {
      throw ArgumentError.value(
        sampleCount,
        'sampleCount',
        'TEN VAD expects exactly $hopSize samples per frame',
      );
    }

    _scratchView.setRange(0, hopSize, interleavedPcm16Samples, startSampleOffset);
    final result = ten_vad.ten_vad_process(
      _vadHandle,
      _scratch.cast(),
      hopSize,
      _outProbability,
      _outFlag,
    );
    if (result != 0) {
      throw TenVadException('TEN VAD processing failed with code $result');
    }
    return _outFlag.value != 0;
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;

    if (_vadHandle != ffi.nullptr) {
      final handleOut = calloc<ten_vad.ten_vad_handle_t>();
      try {
        handleOut.value = _vadHandle;
        ten_vad.ten_vad_destroy(handleOut);
        _vadHandle = ffi.nullptr;
      } finally {
        calloc.free(handleOut);
      }
    }

    calloc.free(_scratch);
    calloc.free(_outProbability);
    calloc.free(_outFlag);
  }

  static void _ensureSupportedPlatform() {
    if (!supportsCurrentPlatform) {
      throw UnsupportedError(
        'Bundled TEN VAD is currently configured for macOS, Windows x64, '
        'Android (arm/arm64), and iOS arm64 targets.',
      );
    }
  }
}

final class TenVadException implements Exception {
  TenVadException(this.message);

  final String message;

  @override
  String toString() => 'TenVadException: $message';
}
