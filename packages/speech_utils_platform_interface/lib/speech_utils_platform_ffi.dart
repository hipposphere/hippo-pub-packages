import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:speech_utils_core/speech_utils_core.dart';

final class NativeRecorderRuntimeConfig {
  const NativeRecorderRuntimeConfig({
    this.processingFlags = 0,
    this.iosSessionModeCode = 0,
    this.iosCategoryOptionsFlags = 0,
    this.preferredLatencySeconds = 0,
    this.iosPreferredIoBufferDurationSeconds = 0,
    this.iosPreferredInputGain = -1,
    this.fileBitrateBps = 0,
    this.fileEncoderCode = 0,
    this.macosProcessingQueueDurationSeconds = 0,
    this.windowsPreferredPeriodFrames = 0,
    this.windowsFlags = 0,
    this.windowsCaptureCategoryCode = 0,
    this.windowsUseCommunicationsDevice = 0,
    this.windowsVoiceProcessingModeCode = 0,
  });

  final int processingFlags;
  final int iosSessionModeCode;
  final int iosCategoryOptionsFlags;
  final double preferredLatencySeconds;
  final double iosPreferredIoBufferDurationSeconds;
  final double iosPreferredInputGain;
  final int fileBitrateBps;
  final int fileEncoderCode;
  final double macosProcessingQueueDurationSeconds;
  final int windowsPreferredPeriodFrames;
  final int windowsFlags;
  final int windowsCaptureCategoryCode;
  final int windowsUseCommunicationsDevice;
  final int windowsVoiceProcessingModeCode;
}

typedef NativeBoolOutFn =
    int Function(ffi.Pointer<ffi.Int32>, ffi.Pointer<ffi.Char>, int);
typedef NativeStartFileFn =
    int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Char>, int);
typedef NativeStartStreamFn =
    int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Char>, int);
typedef NativeSetContinousCaptureFn =
    int Function(int, ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Char>, int);
typedef NativeReadStreamFn =
    int Function(
      ffi.Pointer<ffi.Int16>,
      int,
      ffi.Pointer<ffi.Uint32>,
      ffi.Pointer<ffi.Char>,
      int,
    );
typedef NativeStopFn = int Function(ffi.Pointer<ffi.Char>, int);
typedef NativeListInputDevicesFn =
    int Function(ffi.Pointer<ffi.Char>, int, ffi.Pointer<ffi.Char>, int);
typedef NativeGetAmplitudeFn =
    int Function(
      ffi.Pointer<ffi.Double>,
      ffi.Pointer<ffi.Double>,
      ffi.Pointer<ffi.Char>,
      int,
    );

const _recorderErrorBufferBytes = 4096;

final class NativeRecorderRuntimeConfigFfi extends ffi.Struct {
  @ffi.Int32()
  external int processingFlags;

  @ffi.Int32()
  external int iosSessionModeCode;

  @ffi.Uint32()
  external int iosCategoryOptionsFlags;

  @ffi.Double()
  external double preferredLatencySeconds;

  @ffi.Double()
  external double iosPreferredIoBufferDurationSeconds;

  @ffi.Double()
  external double iosPreferredInputGain;

  @ffi.Uint32()
  external int fileBitrateBps;

  @ffi.Int32()
  external int fileEncoderCode;

  @ffi.Double()
  external double macosProcessingQueueDurationSeconds;

  @ffi.Uint32()
  external int windowsPreferredPeriodFrames;

  @ffi.Uint32()
  external int windowsFlags;

  @ffi.Int32()
  external int windowsCaptureCategoryCode;

  @ffi.Int32()
  external int windowsUseCommunicationsDevice;

  @ffi.Int32()
  external int windowsVoiceProcessingModeCode;
}

final class _NativeRecorderStartConfigFfi extends ffi.Struct {
  @ffi.Uint32()
  external int sampleRateHz;

  @ffi.Uint32()
  external int channelCount;

  @ffi.Uint32()
  external int framesPerChunk;

  external ffi.Pointer<ffi.Char> outputPathUtf8;

  external ffi.Pointer<ffi.Char> inputDeviceIdUtf8;

  external NativeRecorderRuntimeConfigFfi runtime;
}

bool runRecorderBoolCall(NativeBoolOutFn fn, {required String operation}) {
  final outBoolPtr = calloc<ffi.Int32>();
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final code = fn(outBoolPtr, errorPtr, _recorderErrorBufferBytes);
    _throwRecorderExceptionIfNeeded(
      code: code,
      errorPtr: errorPtr,
      operation: operation,
    );
    return outBoolPtr.value != 0;
  } finally {
    calloc.free(outBoolPtr);
    calloc.free(errorPtr);
  }
}

void runRecorderStartFile(
  NativeStartFileFn fn, {
  required String outputPath,
  required int sampleRateHz,
  required int channelCount,
  required String? inputDeviceId,
  required NativeRecorderRuntimeConfig runtimeConfig,
  required String operation,
}) {
  final outputPathPtr = outputPath
      .toNativeUtf8(allocator: calloc)
      .cast<ffi.Char>();
  final inputDeviceIdPtr =
      (inputDeviceId == null || inputDeviceId.trim().isEmpty)
      ? ffi.nullptr
      : inputDeviceId.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final startConfigPtr = calloc<_NativeRecorderStartConfigFfi>();
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final startConfig = startConfigPtr.ref;
    startConfig.sampleRateHz = sampleRateHz;
    startConfig.channelCount = channelCount;
    startConfig.framesPerChunk = 0;
    startConfig.outputPathUtf8 = outputPathPtr;
    startConfig.inputDeviceIdUtf8 = inputDeviceIdPtr;
    startConfig.runtime.processingFlags = runtimeConfig.processingFlags;
    startConfig.runtime.iosSessionModeCode = runtimeConfig.iosSessionModeCode;
    startConfig.runtime.iosCategoryOptionsFlags =
        runtimeConfig.iosCategoryOptionsFlags;
    startConfig.runtime.preferredLatencySeconds =
        runtimeConfig.preferredLatencySeconds;
    startConfig.runtime.iosPreferredIoBufferDurationSeconds =
        runtimeConfig.iosPreferredIoBufferDurationSeconds;
    startConfig.runtime.iosPreferredInputGain =
        runtimeConfig.iosPreferredInputGain;
    startConfig.runtime.fileBitrateBps = runtimeConfig.fileBitrateBps;
    startConfig.runtime.fileEncoderCode = runtimeConfig.fileEncoderCode;
    startConfig.runtime.macosProcessingQueueDurationSeconds =
        runtimeConfig.macosProcessingQueueDurationSeconds;
    startConfig.runtime.windowsPreferredPeriodFrames =
        runtimeConfig.windowsPreferredPeriodFrames;
    startConfig.runtime.windowsFlags = runtimeConfig.windowsFlags;
    startConfig.runtime.windowsCaptureCategoryCode =
        runtimeConfig.windowsCaptureCategoryCode;
    startConfig.runtime.windowsUseCommunicationsDevice =
        runtimeConfig.windowsUseCommunicationsDevice;
    startConfig.runtime.windowsVoiceProcessingModeCode =
        runtimeConfig.windowsVoiceProcessingModeCode;

    final code = fn(
      startConfigPtr.cast<ffi.Void>(),
      errorPtr,
      _recorderErrorBufferBytes,
    );
    _throwRecorderExceptionIfNeeded(
      code: code,
      errorPtr: errorPtr,
      operation: operation,
    );
  } finally {
    calloc.free(startConfigPtr);
    calloc.free(outputPathPtr);
    if (inputDeviceIdPtr != ffi.nullptr) {
      calloc.free(inputDeviceIdPtr);
    }
    calloc.free(errorPtr);
  }
}

void runRecorderStartStream(
  NativeStartStreamFn fn, {
  required int sampleRateHz,
  required int channelCount,
  required int framesPerChunk,
  required String? inputDeviceId,
  required NativeRecorderRuntimeConfig runtimeConfig,
  required String operation,
}) {
  final inputDeviceIdPtr =
      (inputDeviceId == null || inputDeviceId.trim().isEmpty)
      ? ffi.nullptr
      : inputDeviceId.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final startConfigPtr = calloc<_NativeRecorderStartConfigFfi>();
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final startConfig = startConfigPtr.ref;
    startConfig.sampleRateHz = sampleRateHz;
    startConfig.channelCount = channelCount;
    startConfig.framesPerChunk = framesPerChunk;
    startConfig.outputPathUtf8 = ffi.nullptr;
    startConfig.inputDeviceIdUtf8 = inputDeviceIdPtr;
    startConfig.runtime.processingFlags = runtimeConfig.processingFlags;
    startConfig.runtime.iosSessionModeCode = runtimeConfig.iosSessionModeCode;
    startConfig.runtime.iosCategoryOptionsFlags =
        runtimeConfig.iosCategoryOptionsFlags;
    startConfig.runtime.preferredLatencySeconds =
        runtimeConfig.preferredLatencySeconds;
    startConfig.runtime.iosPreferredIoBufferDurationSeconds =
        runtimeConfig.iosPreferredIoBufferDurationSeconds;
    startConfig.runtime.iosPreferredInputGain =
        runtimeConfig.iosPreferredInputGain;
    startConfig.runtime.fileBitrateBps = runtimeConfig.fileBitrateBps;
    startConfig.runtime.fileEncoderCode = runtimeConfig.fileEncoderCode;
    startConfig.runtime.macosProcessingQueueDurationSeconds =
        runtimeConfig.macosProcessingQueueDurationSeconds;
    startConfig.runtime.windowsPreferredPeriodFrames =
        runtimeConfig.windowsPreferredPeriodFrames;
    startConfig.runtime.windowsFlags = runtimeConfig.windowsFlags;
    startConfig.runtime.windowsCaptureCategoryCode =
        runtimeConfig.windowsCaptureCategoryCode;
    startConfig.runtime.windowsUseCommunicationsDevice =
        runtimeConfig.windowsUseCommunicationsDevice;
    startConfig.runtime.windowsVoiceProcessingModeCode =
        runtimeConfig.windowsVoiceProcessingModeCode;

    final code = fn(
      startConfigPtr.cast<ffi.Void>(),
      errorPtr,
      _recorderErrorBufferBytes,
    );
    _throwRecorderExceptionIfNeeded(
      code: code,
      errorPtr: errorPtr,
      operation: operation,
    );
  } finally {
    calloc.free(startConfigPtr);
    if (inputDeviceIdPtr != ffi.nullptr) {
      calloc.free(inputDeviceIdPtr);
    }
    calloc.free(errorPtr);
  }
}

void runRecorderSetContinousCapture(
  NativeSetContinousCaptureFn fn, {
  required bool enabled,
  required int sampleRateHz,
  required int channelCount,
  required int framesPerChunk,
  required String? inputDeviceId,
  required NativeRecorderRuntimeConfig runtimeConfig,
  required String operation,
}) {
  final inputDeviceIdPtr =
      (inputDeviceId == null || inputDeviceId.trim().isEmpty)
      ? ffi.nullptr
      : inputDeviceId.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final startConfigPtr = calloc<_NativeRecorderStartConfigFfi>();
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final startConfig = startConfigPtr.ref;
    startConfig.sampleRateHz = sampleRateHz;
    startConfig.channelCount = channelCount;
    startConfig.framesPerChunk = framesPerChunk;
    startConfig.outputPathUtf8 = ffi.nullptr;
    startConfig.inputDeviceIdUtf8 = inputDeviceIdPtr;
    startConfig.runtime.processingFlags = runtimeConfig.processingFlags;
    startConfig.runtime.iosSessionModeCode = runtimeConfig.iosSessionModeCode;
    startConfig.runtime.iosCategoryOptionsFlags =
        runtimeConfig.iosCategoryOptionsFlags;
    startConfig.runtime.preferredLatencySeconds =
        runtimeConfig.preferredLatencySeconds;
    startConfig.runtime.iosPreferredIoBufferDurationSeconds =
        runtimeConfig.iosPreferredIoBufferDurationSeconds;
    startConfig.runtime.iosPreferredInputGain =
        runtimeConfig.iosPreferredInputGain;
    startConfig.runtime.fileBitrateBps = runtimeConfig.fileBitrateBps;
    startConfig.runtime.fileEncoderCode = runtimeConfig.fileEncoderCode;
    startConfig.runtime.macosProcessingQueueDurationSeconds =
        runtimeConfig.macosProcessingQueueDurationSeconds;
    startConfig.runtime.windowsPreferredPeriodFrames =
        runtimeConfig.windowsPreferredPeriodFrames;
    startConfig.runtime.windowsFlags = runtimeConfig.windowsFlags;
    startConfig.runtime.windowsCaptureCategoryCode =
        runtimeConfig.windowsCaptureCategoryCode;
    startConfig.runtime.windowsUseCommunicationsDevice =
        runtimeConfig.windowsUseCommunicationsDevice;
    startConfig.runtime.windowsVoiceProcessingModeCode =
        runtimeConfig.windowsVoiceProcessingModeCode;

    final code = fn(
      enabled ? 1 : 0,
      startConfigPtr.cast<ffi.Void>(),
      errorPtr,
      _recorderErrorBufferBytes,
    );
    _throwRecorderExceptionIfNeeded(
      code: code,
      errorPtr: errorPtr,
      operation: operation,
    );
  } finally {
    calloc.free(startConfigPtr);
    if (inputDeviceIdPtr != ffi.nullptr) {
      calloc.free(inputDeviceIdPtr);
    }
    calloc.free(errorPtr);
  }
}

List<InputDevice> runRecorderListInputDevices(
  NativeListInputDevicesFn fn, {
  required String operation,
}) {
  const outputCapacity = 64 * 1024;
  final outputPtr = calloc<ffi.Char>(outputCapacity);
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final code = fn(
      outputPtr,
      outputCapacity,
      errorPtr,
      _recorderErrorBufferBytes,
    );
    _throwRecorderExceptionIfNeeded(
      code: code,
      errorPtr: errorPtr,
      operation: operation,
    );

    final jsonText = outputPtr.cast<Utf8>().toDartString();
    if (jsonText.trim().isEmpty) {
      return const <InputDevice>[];
    }

    final decoded = jsonDecode(jsonText);
    if (decoded is! List) {
      throw const FormatException(
        'Native input-device payload is not a JSON list.',
      );
    }

    final devices = <InputDevice>[];
    for (final item in decoded) {
      if (item is! Map<String, Object?>) {
        continue;
      }
      final device = InputDevice.fromJson(item);
      if (device.id.trim().isEmpty) {
        continue;
      }
      devices.add(device);
    }
    return devices;
  } finally {
    calloc.free(outputPtr);
    calloc.free(errorPtr);
  }
}

Uint8List runRecorderReadStream(
  NativeReadStreamFn fn, {
  required int maxSamples,
  required String operation,
}) {
  final outSamplesPtr = calloc<ffi.Int16>(maxSamples);
  final outSamplesWrittenPtr = calloc<ffi.Uint32>();
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);

  try {
    return runRecorderReadStreamWithBuffers(
      fn,
      maxSamples: maxSamples,
      outSamplesPtr: outSamplesPtr,
      outSamplesWrittenPtr: outSamplesWrittenPtr,
      errorPtr: errorPtr,
      operation: operation,
    );
  } finally {
    calloc.free(outSamplesPtr);
    calloc.free(outSamplesWrittenPtr);
    calloc.free(errorPtr);
  }
}

Uint8List runRecorderReadStreamWithBuffers(
  NativeReadStreamFn fn, {
  required int maxSamples,
  required ffi.Pointer<ffi.Int16> outSamplesPtr,
  required ffi.Pointer<ffi.Uint32> outSamplesWrittenPtr,
  required ffi.Pointer<ffi.Char> errorPtr,
  required String operation,
}) {
  final code = fn(
    outSamplesPtr,
    maxSamples,
    outSamplesWrittenPtr,
    errorPtr,
    _recorderErrorBufferBytes,
  );
  _throwRecorderExceptionIfNeeded(
    code: code,
    errorPtr: errorPtr,
    operation: operation,
  );

  final sampleCount = math.min(outSamplesWrittenPtr.value, maxSamples);
  if (sampleCount <= 0) {
    return Uint8List(0);
  }

  final bytes = Uint8List(sampleCount * 2);
  final dst = bytes.buffer.asInt16List();
  final src = outSamplesPtr.asTypedList(sampleCount);
  dst.setRange(0, sampleCount, src);
  return bytes;
}

void runRecorderStop(NativeStopFn fn, {required String operation}) {
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final code = fn(errorPtr, _recorderErrorBufferBytes);
    _throwRecorderExceptionIfNeeded(
      code: code,
      errorPtr: errorPtr,
      operation: operation,
    );
  } finally {
    calloc.free(errorPtr);
  }
}

void runRecorderReset(NativeStopFn fn, {required String operation}) {
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final code = fn(errorPtr, _recorderErrorBufferBytes);
    _throwRecorderExceptionIfNeeded(
      code: code,
      errorPtr: errorPtr,
      operation: operation,
    );
  } finally {
    calloc.free(errorPtr);
  }
}

Amplitude runRecorderGetAmplitude(
  NativeGetAmplitudeFn fn, {
  required String operation,
}) {
  final outCurrentPtr = calloc<ffi.Double>();
  final outMaxPtr = calloc<ffi.Double>();
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final code = fn(
      outCurrentPtr,
      outMaxPtr,
      errorPtr,
      _recorderErrorBufferBytes,
    );
    _throwRecorderExceptionIfNeeded(
      code: code,
      errorPtr: errorPtr,
      operation: operation,
    );
    return Amplitude(
      current: _sanitizeDbfs(outCurrentPtr.value),
      max: _sanitizeDbfs(outMaxPtr.value),
    );
  } finally {
    calloc.free(outCurrentPtr);
    calloc.free(outMaxPtr);
    calloc.free(errorPtr);
  }
}

double _sanitizeDbfs(double value) {
  if (value.isNaN || value.isInfinite) {
    return -90.0;
  }
  return (value.clamp(-90.0, 0.0) as num).toDouble();
}

void _throwRecorderExceptionIfNeeded({
  required int code,
  required ffi.Pointer<ffi.Char> errorPtr,
  required String operation,
}) {
  if (code == 0) return;
  final details = errorPtr.cast<Utf8>().toDartString();
  throw AudioRecorderException(
    '$operation failed',
    errorCode: code,
    details: details.isEmpty ? null : details,
  );
}
