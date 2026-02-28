part of 'package:speech_utils/src/recording/native_audio_recorder.dart';

typedef _NativeBoolOutFn = int Function(ffi.Pointer<ffi.Int32>, ffi.Pointer<ffi.Char>, int);
typedef _NativeStartFileFn = int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Char>, int);
typedef _NativeStartStreamFn = int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Char>, int);
typedef _NativeReadStreamFn =
    int Function(ffi.Pointer<ffi.Int16>, int, ffi.Pointer<ffi.Uint32>, ffi.Pointer<ffi.Char>, int);
typedef _NativeStopFn = int Function(ffi.Pointer<ffi.Char>, int);
typedef _NativeListInputDevicesFn =
    int Function(ffi.Pointer<ffi.Char>, int, ffi.Pointer<ffi.Char>, int);
typedef _NativeGetAmplitudeFn =
    int Function(ffi.Pointer<ffi.Double>, ffi.Pointer<ffi.Double>, ffi.Pointer<ffi.Char>, int);

const _recorderErrorBufferBytes = 4096;

final class _NativeRecorderRuntimeConfigFfi extends ffi.Struct {
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

  external _NativeRecorderRuntimeConfigFfi runtime;
}

bool _runRecorderBoolCall(_NativeBoolOutFn fn, {required String operation}) {
  final outBoolPtr = calloc<ffi.Int32>();
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final code = fn(outBoolPtr, errorPtr, _recorderErrorBufferBytes);
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);
    return outBoolPtr.value != 0;
  } finally {
    calloc.free(outBoolPtr);
    calloc.free(errorPtr);
  }
}

void _runRecorderStartFile(
  _NativeStartFileFn fn, {
  required String outputPath,
  required int sampleRateHz,
  required int channelCount,
  required String? inputDeviceId,
  required _NativeRecorderRuntimeConfig runtimeConfig,
  required String operation,
}) {
  final outputPathPtr = outputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final inputDeviceIdPtr = (inputDeviceId == null || inputDeviceId.trim().isEmpty)
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
    startConfig.runtime.iosCategoryOptionsFlags = runtimeConfig.iosCategoryOptionsFlags;
    startConfig.runtime.preferredLatencySeconds = runtimeConfig.preferredLatencySeconds;
    startConfig.runtime.iosPreferredIoBufferDurationSeconds =
        runtimeConfig.iosPreferredIoBufferDurationSeconds;
    startConfig.runtime.iosPreferredInputGain = runtimeConfig.iosPreferredInputGain;
    startConfig.runtime.fileBitrateBps = runtimeConfig.fileBitrateBps;
    startConfig.runtime.fileEncoderCode = runtimeConfig.fileEncoderCode;
    startConfig.runtime.macosProcessingQueueDurationSeconds =
        runtimeConfig.macosProcessingQueueDurationSeconds;
    startConfig.runtime.windowsPreferredPeriodFrames = runtimeConfig.windowsPreferredPeriodFrames;
    startConfig.runtime.windowsFlags = runtimeConfig.windowsFlags;
    startConfig.runtime.windowsCaptureCategoryCode = runtimeConfig.windowsCaptureCategoryCode;
    startConfig.runtime.windowsUseCommunicationsDevice =
        runtimeConfig.windowsUseCommunicationsDevice;
    startConfig.runtime.windowsVoiceProcessingModeCode =
        runtimeConfig.windowsVoiceProcessingModeCode;

    final code = fn(startConfigPtr.cast<ffi.Void>(), errorPtr, _recorderErrorBufferBytes);
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);
  } finally {
    calloc.free(startConfigPtr);
    calloc.free(outputPathPtr);
    if (inputDeviceIdPtr != ffi.nullptr) {
      calloc.free(inputDeviceIdPtr);
    }
    calloc.free(errorPtr);
  }
}

void _runRecorderStartStream(
  _NativeStartStreamFn fn, {
  required int sampleRateHz,
  required int channelCount,
  required int framesPerChunk,
  required String? inputDeviceId,
  required _NativeRecorderRuntimeConfig runtimeConfig,
  required String operation,
}) {
  final inputDeviceIdPtr = (inputDeviceId == null || inputDeviceId.trim().isEmpty)
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
    startConfig.runtime.iosCategoryOptionsFlags = runtimeConfig.iosCategoryOptionsFlags;
    startConfig.runtime.preferredLatencySeconds = runtimeConfig.preferredLatencySeconds;
    startConfig.runtime.iosPreferredIoBufferDurationSeconds =
        runtimeConfig.iosPreferredIoBufferDurationSeconds;
    startConfig.runtime.iosPreferredInputGain = runtimeConfig.iosPreferredInputGain;
    startConfig.runtime.fileBitrateBps = runtimeConfig.fileBitrateBps;
    startConfig.runtime.fileEncoderCode = runtimeConfig.fileEncoderCode;
    startConfig.runtime.macosProcessingQueueDurationSeconds =
        runtimeConfig.macosProcessingQueueDurationSeconds;
    startConfig.runtime.windowsPreferredPeriodFrames = runtimeConfig.windowsPreferredPeriodFrames;
    startConfig.runtime.windowsFlags = runtimeConfig.windowsFlags;
    startConfig.runtime.windowsCaptureCategoryCode = runtimeConfig.windowsCaptureCategoryCode;
    startConfig.runtime.windowsUseCommunicationsDevice =
        runtimeConfig.windowsUseCommunicationsDevice;
    startConfig.runtime.windowsVoiceProcessingModeCode =
        runtimeConfig.windowsVoiceProcessingModeCode;

    final code = fn(startConfigPtr.cast<ffi.Void>(), errorPtr, _recorderErrorBufferBytes);
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);
  } finally {
    calloc.free(startConfigPtr);
    if (inputDeviceIdPtr != ffi.nullptr) {
      calloc.free(inputDeviceIdPtr);
    }
    calloc.free(errorPtr);
  }
}

List<InputDevice> _runRecorderListInputDevices(
  _NativeListInputDevicesFn fn, {
  required String operation,
}) {
  const outputCapacity = 64 * 1024;
  final outputPtr = calloc<ffi.Char>(outputCapacity);
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final code = fn(outputPtr, outputCapacity, errorPtr, _recorderErrorBufferBytes);
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);

    final jsonText = outputPtr.cast<Utf8>().toDartString();
    if (jsonText.trim().isEmpty) {
      return const <InputDevice>[];
    }

    final decoded = jsonDecode(jsonText);
    if (decoded is! List) {
      throw const FormatException('Native input-device payload is not a JSON list.');
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

Uint8List _runRecorderReadStream(
  _NativeReadStreamFn fn, {
  required int maxSamples,
  required String operation,
}) {
  final outSamplesPtr = calloc<ffi.Int16>(maxSamples);
  final outSamplesWrittenPtr = calloc<ffi.Uint32>();
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);

  try {
    return _runRecorderReadStreamWithBuffers(
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

Uint8List _runRecorderReadStreamWithBuffers(
  _NativeReadStreamFn fn, {
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
  _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);

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

void _runRecorderStop(_NativeStopFn fn, {required String operation}) {
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final code = fn(errorPtr, _recorderErrorBufferBytes);
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);
  } finally {
    calloc.free(errorPtr);
  }
}

void _runRecorderReset(_NativeStopFn fn, {required String operation}) {
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final code = fn(errorPtr, _recorderErrorBufferBytes);
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);
  } finally {
    calloc.free(errorPtr);
  }
}

Amplitude _runRecorderGetAmplitude(_NativeGetAmplitudeFn fn, {required String operation}) {
  final outCurrentPtr = calloc<ffi.Double>();
  final outMaxPtr = calloc<ffi.Double>();
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final code = fn(outCurrentPtr, outMaxPtr, errorPtr, _recorderErrorBufferBytes);
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);
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

const int _processingFlagNoiseSuppression = 1 << 0;
const int _processingFlagEchoCancellation = 1 << 1;
const int _processingFlagAutomaticGainControl = 1 << 2;
const int _processingFlagHighPassFilter = 1 << 3;
const int _processingFlagPresetVoice = 1 << 4;
const int _processingFlagPresetVoiceIsolation = 1 << 5;
const int _processingFlagPresetRaw = 1 << 6;
const int _processingFlagPresetMusic = 1 << 7;

const int _iosCategoryOptionAllowBluetooth = 1 << 0;
const int _iosCategoryOptionAllowBluetoothA2dp = 1 << 1;
const int _iosCategoryOptionDefaultToSpeaker = 1 << 2;
const int _iosCategoryOptionMixWithOthers = 1 << 3;
const int _iosCategoryOptionDuckOthers = 1 << 4;

const int _fileEncoderAacLc = 0;

const int _windowsFlagExclusiveMode = 1 << 0;
const int _windowsFlagRawCapture = 1 << 1;
const int _windowsVoiceProcessingModeAuto = 0;
const int _windowsVoiceProcessingModeSystem = 1;
const int _windowsVoiceProcessingModeSoftware = 2;
const int _windowsVoiceProcessingModeOff = 3;

IosAudioSessionMode _defaultIosSessionModeForPreset(AudioCapturePreset preset) {
  return switch (preset) {
    AudioCapturePreset.voice || AudioCapturePreset.voiceIsolation => IosAudioSessionMode.voiceChat,
    AudioCapturePreset.raw || AudioCapturePreset.music => IosAudioSessionMode.measurement,
  };
}

int _encodeFileEncoder(AudioEncoder encoder) {
  return switch (encoder) {
    // Direct native AAC recording on Apple backends uses AAC-LC for stability.
    AudioEncoder.aacHe => _fileEncoderAacLc,
    AudioEncoder.aacEld => _fileEncoderAacLc,
    AudioEncoder.aacLc ||
    AudioEncoder.wav ||
    AudioEncoder.flac ||
    AudioEncoder.opus ||
    AudioEncoder.pcm16bits => _fileEncoderAacLc,
  };
}

int _processingPresetFlags(AudioCapturePreset preset) {
  return switch (preset) {
    AudioCapturePreset.voice => _processingFlagPresetVoice,
    AudioCapturePreset.voiceIsolation => _processingFlagPresetVoiceIsolation,
    AudioCapturePreset.raw => _processingFlagPresetRaw,
    AudioCapturePreset.music => _processingFlagPresetMusic,
  };
}

int _encodeIosSessionMode(IosAudioSessionMode? mode) {
  return switch (mode) {
    null => 0,
    IosAudioSessionMode.defaultMode => 0,
    IosAudioSessionMode.voiceChat => 1,
    IosAudioSessionMode.videoChat => 2,
    IosAudioSessionMode.measurement => 3,
    IosAudioSessionMode.gameChat => 4,
    IosAudioSessionMode.spokenAudio => 5,
  };
}

int _encodeWindowsCaptureCategory(WindowsCaptureCategory? category) {
  return switch (category) {
    null => 2,
    WindowsCaptureCategory.media => 0,
    WindowsCaptureCategory.communications => 1,
    WindowsCaptureCategory.speech => 2,
  };
}

int _encodeWindowsVoiceProcessingMode(WindowsVoiceProcessingMode? mode) {
  return switch (mode) {
    null => _windowsVoiceProcessingModeAuto,
    WindowsVoiceProcessingMode.auto => _windowsVoiceProcessingModeAuto,
    WindowsVoiceProcessingMode.system => _windowsVoiceProcessingModeSystem,
    WindowsVoiceProcessingMode.software => _windowsVoiceProcessingModeSoftware,
    WindowsVoiceProcessingMode.off => _windowsVoiceProcessingModeOff,
  };
}

void _throwRecorderExceptionIfNeeded({
  required int code,
  required ffi.Pointer<ffi.Char> errorPtr,
  required String operation,
}) {
  if (code == 0) {
    return;
  }
  final details = errorPtr.cast<Utf8>().toDartString();
  throw AudioRecorderException(
    '$operation failed',
    errorCode: code,
    details: details.isEmpty ? null : details,
  );
}
