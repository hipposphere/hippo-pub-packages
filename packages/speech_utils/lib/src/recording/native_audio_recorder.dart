import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../models/input_device.dart';
import 'audio_recorder_config.dart';
import 'generated/ios_audio_recorder_bindings.dart' as ios_bindings;
import 'generated/macos_audio_recorder_bindings.dart' as macos_bindings;
import 'generated/windows_audio_recorder_bindings.dart' as windows_bindings;

enum NativeAudioRecorderPlatform { macOS, windows, iOS, unsupported }

typedef NativeAudioRecorderAvailabilityFn = bool Function();
typedef NativeAudioRecorderPermissionFn = bool Function();
typedef NativeAudioRecorderRequestPermissionFn = bool Function();
typedef NativeAudioRecorderListInputDevicesFn = List<InputDevice> Function();
typedef NativeAudioRecorderStartFileFn =
    void Function({
      required String outputPath,
      required int sampleRateHz,
      required int channelCount,
      required String? inputDeviceId,
    });
typedef NativeAudioRecorderStartStreamFn =
    void Function({
      required int sampleRateHz,
      required int channelCount,
      required int framesPerChunk,
      required String? inputDeviceId,
    });
typedef NativeAudioRecorderReadStreamFn = Uint8List Function({required int maxSamples});
typedef NativeAudioRecorderStopFn = void Function();
typedef NativeAudioRecorderIsRecordingFn = bool Function();

enum _RecorderMode { stopped, file, stream }

/// FFI-based microphone recorder backed by platform-native implementations.
///
/// Current native backends:
/// - macOS/iOS: AVFoundation
/// - Windows: miniaudio
final class NativeAudioRecorder {
  NativeAudioRecorder({
    NativeAudioRecorderPlatform? platform,
    NativeAudioRecorderAvailabilityFn? availabilityFn,
    NativeAudioRecorderPermissionFn? hasPermissionFn,
    NativeAudioRecorderRequestPermissionFn? requestPermissionFn,
    NativeAudioRecorderListInputDevicesFn? listInputDevicesFn,
    NativeAudioRecorderStartFileFn? startFileFn,
    NativeAudioRecorderStartStreamFn? startStreamFn,
    NativeAudioRecorderReadStreamFn? readStreamFn,
    NativeAudioRecorderStopFn? stopFn,
    NativeAudioRecorderIsRecordingFn? isRecordingFn,
  }) : this._(
         platform: platform ?? _detectNativeAudioRecorderPlatform(),
         availabilityFn: availabilityFn,
         hasPermissionFn: hasPermissionFn,
         requestPermissionFn: requestPermissionFn,
         listInputDevicesFn: listInputDevicesFn,
         startFileFn: startFileFn,
         startStreamFn: startStreamFn,
         readStreamFn: readStreamFn,
         stopFn: stopFn,
         isRecordingFn: isRecordingFn,
       );

  NativeAudioRecorder._({
    required NativeAudioRecorderPlatform platform,
    NativeAudioRecorderAvailabilityFn? availabilityFn,
    NativeAudioRecorderPermissionFn? hasPermissionFn,
    NativeAudioRecorderRequestPermissionFn? requestPermissionFn,
    NativeAudioRecorderListInputDevicesFn? listInputDevicesFn,
    NativeAudioRecorderStartFileFn? startFileFn,
    NativeAudioRecorderStartStreamFn? startStreamFn,
    NativeAudioRecorderReadStreamFn? readStreamFn,
    NativeAudioRecorderStopFn? stopFn,
    NativeAudioRecorderIsRecordingFn? isRecordingFn,
  }) : _platform = platform,
       _availabilityFn = availabilityFn ?? _resolveAvailabilityFn(platform),
       _hasPermissionFn = hasPermissionFn ?? _resolveHasPermissionFn(platform),
       _requestPermissionFn = requestPermissionFn ?? _resolveRequestPermissionFn(platform),
       _listInputDevicesFn = listInputDevicesFn ?? _resolveListInputDevicesFn(platform),
       _startFileFn = startFileFn ?? _resolveStartFileFn(platform),
       _startStreamFn = startStreamFn ?? _resolveStartStreamFn(platform),
       _readStreamFn = readStreamFn ?? _resolveReadStreamFn(platform),
       _stopFn = stopFn ?? _resolveStopFn(platform),
       _isRecordingFn = isRecordingFn ?? _resolveIsRecordingFn(platform);

  final NativeAudioRecorderPlatform _platform;
  final NativeAudioRecorderAvailabilityFn _availabilityFn;
  final NativeAudioRecorderPermissionFn _hasPermissionFn;
  final NativeAudioRecorderRequestPermissionFn _requestPermissionFn;
  final NativeAudioRecorderListInputDevicesFn _listInputDevicesFn;
  final NativeAudioRecorderStartFileFn _startFileFn;
  final NativeAudioRecorderStartStreamFn _startStreamFn;
  final NativeAudioRecorderReadStreamFn _readStreamFn;
  final NativeAudioRecorderStopFn _stopFn;
  final NativeAudioRecorderIsRecordingFn _isRecordingFn;

  _RecorderMode _mode = _RecorderMode.stopped;
  Timer? _streamTimer;
  StreamController<Uint8List>? _streamController;
  int _streamReadSampleCapacity = _defaultReadSampleCapacity;
  bool _stopping = false;

  static const _defaultReadSampleCapacity = 4096;

  NativeAudioRecorderPlatform get platform => _platform;

  bool get isRecording {
    if (_mode == _RecorderMode.stopped) {
      return false;
    }
    try {
      return _isRecordingFn();
    } on Object {
      return true;
    }
  }

  Future<bool> isAvailable() async {
    if (_platform == NativeAudioRecorderPlatform.unsupported) {
      return false;
    }
    return _availabilityFn();
  }

  Future<bool> hasPermission() async {
    _ensureSupportedPlatform();
    return _hasPermissionFn();
  }

  Future<bool> requestPermission() async {
    _ensureSupportedPlatform();
    return _requestPermissionFn();
  }

  /// Whether this platform can route capture to a specific input-device ID.
  ///
  /// Routing is driven only by `AudioRecorderConfig.inputDeviceId` passed to
  /// `start(...)`/`startStream(...)`; no input selection is stored internally.
  ///
  /// On Apple platforms this is implemented by the native AVFoundation capture
  /// backend using per-start configuration.
  bool get supportsInputSelection {
    return _platform == NativeAudioRecorderPlatform.macOS ||
        _platform == NativeAudioRecorderPlatform.windows ||
        _platform == NativeAudioRecorderPlatform.iOS;
  }

  Future<List<InputDevice>> listInputDevices() async {
    _ensureSupportedPlatform();
    return _listInputDevicesFn();
  }

  Future<void> start({
    required String outputPath,
    AudioRecorderConfig config = const AudioRecorderConfig(),
  }) async {
    _ensureSupportedPlatform();
    _ensureIdle();
    if (outputPath.trim().isEmpty) {
      throw ArgumentError.value(outputPath, 'outputPath', 'Must not be empty');
    }
    config.validate();

    _startFileFn(
      outputPath: outputPath,
      sampleRateHz: config.sampleRateHz,
      channelCount: config.channelCount,
      inputDeviceId: config.inputDeviceId,
    );
    _mode = _RecorderMode.file;
  }

  Future<Stream<Uint8List>> startStream({
    AudioRecorderConfig config = const AudioRecorderConfig(),
    Duration pollInterval = const Duration(milliseconds: 20),
    int readSampleCapacity = _defaultReadSampleCapacity,
  }) async {
    _ensureSupportedPlatform();
    _ensureIdle();
    config.validate();

    if (pollInterval <= Duration.zero) {
      throw ArgumentError.value(pollInterval, 'pollInterval', 'Must be > Duration.zero');
    }
    if (readSampleCapacity <= 0) {
      throw ArgumentError.value(readSampleCapacity, 'readSampleCapacity', 'Must be > 0');
    }

    _startStreamFn(
      sampleRateHz: config.sampleRateHz,
      channelCount: config.channelCount,
      framesPerChunk: config.framesPerChunk,
      inputDeviceId: config.inputDeviceId,
    );

    _mode = _RecorderMode.stream;
    _streamReadSampleCapacity = readSampleCapacity;

    final controller = StreamController<Uint8List>(
      onCancel: () async {
        await stop();
      },
    );
    _streamController = controller;

    _streamTimer = Timer.periodic(pollInterval, (_) {
      _drainNativeStream();
    });

    return controller.stream;
  }

  Future<void> stop() async {
    if (_mode == _RecorderMode.stopped) {
      return;
    }
    if (_stopping) {
      return;
    }
    _stopping = true;

    _streamTimer?.cancel();
    _streamTimer = null;

    Object? stopError;
    StackTrace? stopStackTrace;
    try {
      _stopFn();
    } on Object catch (error, stackTrace) {
      stopError = error;
      stopStackTrace = stackTrace;
    }

    _mode = _RecorderMode.stopped;
    _streamReadSampleCapacity = _defaultReadSampleCapacity;

    final controller = _streamController;
    _streamController = null;
    if (controller != null && !controller.isClosed) {
      final hasListener = controller.hasListener;
      if (stopError != null && hasListener) {
        controller.addError(stopError, stopStackTrace ?? StackTrace.current);
      }
      final closeFuture = controller.close();
      if (hasListener) {
        await closeFuture;
      } else {
        unawaited(closeFuture);
      }
    }

    _stopping = false;

    if (stopError != null) {
      Error.throwWithStackTrace(stopError, stopStackTrace ?? StackTrace.current);
    }
  }

  Future<void> dispose() => stop();

  void _drainNativeStream() {
    if (_mode != _RecorderMode.stream) {
      return;
    }
    final controller = _streamController;
    if (controller == null || controller.isClosed) {
      return;
    }

    try {
      for (var i = 0; i < 8; i++) {
        final chunk = _readStreamFn(maxSamples: _streamReadSampleCapacity);
        if (chunk.isEmpty) {
          break;
        }
        controller.add(chunk);
      }
    } on Object catch (error, stackTrace) {
      controller.addError(error, stackTrace);
      unawaited(stop());
    }
  }

  void _ensureSupportedPlatform() {
    if (_platform == NativeAudioRecorderPlatform.unsupported) {
      throw UnsupportedError(
        'NativeAudioRecorder is currently supported on macOS, Windows, and iOS.',
      );
    }
  }

  void _ensureIdle() {
    if (_mode != _RecorderMode.stopped) {
      throw StateError('Recorder is already running. Call stop() first.');
    }
  }
}

final class AudioRecorderException implements Exception {
  AudioRecorderException(this.message, {this.errorCode, this.details});

  final String message;
  final int? errorCode;
  final String? details;

  @override
  String toString() {
    final detailsText = <String>[
      message,
      if (errorCode != null) 'errorCode=$errorCode',
      if (details != null && details!.isNotEmpty) 'details=$details',
    ];
    return 'AudioRecorderException: ${detailsText.join(' | ')}';
  }
}

NativeAudioRecorderPlatform _detectNativeAudioRecorderPlatform() {
  if (Platform.isMacOS) {
    return NativeAudioRecorderPlatform.macOS;
  }
  if (Platform.isWindows) {
    return NativeAudioRecorderPlatform.windows;
  }
  if (Platform.isIOS) {
    return NativeAudioRecorderPlatform.iOS;
  }
  return NativeAudioRecorderPlatform.unsupported;
}

NativeAudioRecorderAvailabilityFn _resolveAvailabilityFn(NativeAudioRecorderPlatform platform) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _isMacosAudioRecorderAvailableViaFfi,
    NativeAudioRecorderPlatform.windows => _isWindowsAudioRecorderAvailableViaFfi,
    NativeAudioRecorderPlatform.iOS => _isIosAudioRecorderAvailableViaFfi,
    NativeAudioRecorderPlatform.unsupported => () => false,
  };
}

NativeAudioRecorderPermissionFn _resolveHasPermissionFn(NativeAudioRecorderPlatform platform) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _hasMacosMicrophonePermissionViaFfi,
    NativeAudioRecorderPlatform.windows => _hasWindowsMicrophonePermissionViaFfi,
    NativeAudioRecorderPlatform.iOS => _hasIosMicrophonePermissionViaFfi,
    NativeAudioRecorderPlatform.unsupported => () => false,
  };
}

NativeAudioRecorderRequestPermissionFn _resolveRequestPermissionFn(
  NativeAudioRecorderPlatform platform,
) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _requestMacosMicrophonePermissionViaFfi,
    NativeAudioRecorderPlatform.windows => _requestWindowsMicrophonePermissionViaFfi,
    NativeAudioRecorderPlatform.iOS => _requestIosMicrophonePermissionViaFfi,
    NativeAudioRecorderPlatform.unsupported => () => false,
  };
}

NativeAudioRecorderListInputDevicesFn _resolveListInputDevicesFn(
  NativeAudioRecorderPlatform platform,
) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _listMacosAudioRecorderInputDevicesViaFfi,
    NativeAudioRecorderPlatform.windows => _listWindowsAudioRecorderInputDevicesViaFfi,
    NativeAudioRecorderPlatform.iOS => _listIosAudioRecorderInputDevicesViaFfi,
    NativeAudioRecorderPlatform.unsupported => () => const <InputDevice>[],
  };
}

NativeAudioRecorderStartFileFn _resolveStartFileFn(NativeAudioRecorderPlatform platform) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _startMacosAudioRecorderFileViaFfi,
    NativeAudioRecorderPlatform.windows => _startWindowsAudioRecorderFileViaFfi,
    NativeAudioRecorderPlatform.iOS => _startIosAudioRecorderFileViaFfi,
    NativeAudioRecorderPlatform.unsupported =>
      ({
        required outputPath,
        required sampleRateHz,
        required channelCount,
        required inputDeviceId,
      }) => throw UnsupportedError(
        'NativeAudioRecorder is currently supported on macOS, Windows, and iOS.',
      ),
  };
}

NativeAudioRecorderStartStreamFn _resolveStartStreamFn(NativeAudioRecorderPlatform platform) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _startMacosAudioRecorderStreamViaFfi,
    NativeAudioRecorderPlatform.windows => _startWindowsAudioRecorderStreamViaFfi,
    NativeAudioRecorderPlatform.iOS => _startIosAudioRecorderStreamViaFfi,
    NativeAudioRecorderPlatform.unsupported =>
      ({
        required sampleRateHz,
        required channelCount,
        required framesPerChunk,
        required inputDeviceId,
      }) => throw UnsupportedError(
        'NativeAudioRecorder is currently supported on macOS, Windows, and iOS.',
      ),
  };
}

NativeAudioRecorderReadStreamFn _resolveReadStreamFn(NativeAudioRecorderPlatform platform) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _readMacosAudioRecorderStreamViaFfi,
    NativeAudioRecorderPlatform.windows => _readWindowsAudioRecorderStreamViaFfi,
    NativeAudioRecorderPlatform.iOS => _readIosAudioRecorderStreamViaFfi,
    NativeAudioRecorderPlatform.unsupported => ({required maxSamples}) => throw UnsupportedError(
      'NativeAudioRecorder is currently supported on macOS, Windows, and iOS.',
    ),
  };
}

NativeAudioRecorderStopFn _resolveStopFn(NativeAudioRecorderPlatform platform) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _stopMacosAudioRecorderViaFfi,
    NativeAudioRecorderPlatform.windows => _stopWindowsAudioRecorderViaFfi,
    NativeAudioRecorderPlatform.iOS => _stopIosAudioRecorderViaFfi,
    NativeAudioRecorderPlatform.unsupported => () => throw UnsupportedError(
      'NativeAudioRecorder is currently supported on macOS, Windows, and iOS.',
    ),
  };
}

NativeAudioRecorderIsRecordingFn _resolveIsRecordingFn(NativeAudioRecorderPlatform platform) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _isMacosAudioRecorderRunningViaFfi,
    NativeAudioRecorderPlatform.windows => _isWindowsAudioRecorderRunningViaFfi,
    NativeAudioRecorderPlatform.iOS => _isIosAudioRecorderRunningViaFfi,
    NativeAudioRecorderPlatform.unsupported => () => false,
  };
}

typedef _NativeHealthcheckFn = int Function(ffi.Pointer<ffi.Char>, int);
typedef _NativeBoolOutFn = int Function(ffi.Pointer<ffi.Int32>, ffi.Pointer<ffi.Char>, int);
typedef _NativeStartFileFn =
    int Function(
      ffi.Pointer<ffi.Char>,
      int,
      int,
      ffi.Pointer<ffi.Char>,
      ffi.Pointer<ffi.Char>,
      int,
    );
typedef _NativeStartStreamFn =
    int Function(int, int, int, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int);
typedef _NativeReadStreamFn =
    int Function(ffi.Pointer<ffi.Int16>, int, ffi.Pointer<ffi.Uint32>, ffi.Pointer<ffi.Char>, int);
typedef _NativeStopFn = int Function(ffi.Pointer<ffi.Char>, int);
typedef _NativeListInputDevicesFn =
    int Function(ffi.Pointer<ffi.Char>, int, ffi.Pointer<ffi.Char>, int);

const _recorderErrorBufferBytes = 4096;

bool _runRecorderHealthcheck(_NativeHealthcheckFn fn) {
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    try {
      final code = fn(errorPtr, _recorderErrorBufferBytes);
      return code == 0;
    } on Object {
      return false;
    }
  } finally {
    calloc.free(errorPtr);
  }
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
  required String operation,
}) {
  final outputPathPtr = outputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final inputDeviceIdPtr = (inputDeviceId == null || inputDeviceId.trim().isEmpty)
      ? ffi.nullptr
      : inputDeviceId.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final code = fn(
      outputPathPtr,
      sampleRateHz,
      channelCount,
      inputDeviceIdPtr,
      errorPtr,
      _recorderErrorBufferBytes,
    );
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);
  } finally {
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
  required String operation,
}) {
  final inputDeviceIdPtr = (inputDeviceId == null || inputDeviceId.trim().isEmpty)
      ? ffi.nullptr
      : inputDeviceId.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final code = fn(
      sampleRateHz,
      channelCount,
      framesPerChunk,
      inputDeviceIdPtr,
      errorPtr,
      _recorderErrorBufferBytes,
    );
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);
  } finally {
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
    final code = fn(
      outSamplesPtr,
      maxSamples,
      outSamplesWrittenPtr,
      errorPtr,
      _recorderErrorBufferBytes,
    );
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);

    final sampleCount = outSamplesWrittenPtr.value;
    if (sampleCount <= 0) {
      return Uint8List(0);
    }

    final bytes = Uint8List(sampleCount * 2);
    final dst = bytes.buffer.asInt16List();
    final src = outSamplesPtr.asTypedList(sampleCount);
    dst.setRange(0, sampleCount, src);
    return bytes;
  } finally {
    calloc.free(outSamplesPtr);
    calloc.free(outSamplesWrittenPtr);
    calloc.free(errorPtr);
  }
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

bool _isMacosAudioRecorderAvailableViaFfi() {
  return _runRecorderHealthcheck(macos_bindings.speech_utils_macos_audio_recorder_healthcheck);
}

bool _hasMacosMicrophonePermissionViaFfi() {
  return _runRecorderBoolCall(
    macos_bindings.speech_utils_macos_audio_recorder_has_permission,
    operation: 'macOS microphone permission check',
  );
}

bool _requestMacosMicrophonePermissionViaFfi() {
  return _runRecorderBoolCall(
    macos_bindings.speech_utils_macos_audio_recorder_request_permission,
    operation: 'macOS microphone permission request',
  );
}

void _startMacosAudioRecorderFileViaFfi({
  required String outputPath,
  required int sampleRateHz,
  required int channelCount,
  required String? inputDeviceId,
}) {
  _runRecorderStartFile(
    macos_bindings.speech_utils_macos_audio_recorder_start_file,
    outputPath: outputPath,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    inputDeviceId: inputDeviceId,
    operation: 'macOS file recording start',
  );
}

void _startMacosAudioRecorderStreamViaFfi({
  required int sampleRateHz,
  required int channelCount,
  required int framesPerChunk,
  required String? inputDeviceId,
}) {
  _runRecorderStartStream(
    macos_bindings.speech_utils_macos_audio_recorder_start_stream,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    framesPerChunk: framesPerChunk,
    inputDeviceId: inputDeviceId,
    operation: 'macOS stream recording start',
  );
}

List<InputDevice> _listMacosAudioRecorderInputDevicesViaFfi() {
  return _runRecorderListInputDevices(
    macos_bindings.speech_utils_macos_audio_recorder_list_input_devices_json,
    operation: 'macOS input device listing',
  );
}

Uint8List _readMacosAudioRecorderStreamViaFfi({required int maxSamples}) {
  return _runRecorderReadStream(
    macos_bindings.speech_utils_macos_audio_recorder_read_stream_pcm16,
    maxSamples: maxSamples,
    operation: 'macOS stream read',
  );
}

void _stopMacosAudioRecorderViaFfi() {
  _runRecorderStop(
    macos_bindings.speech_utils_macos_audio_recorder_stop,
    operation: 'macOS recording stop',
  );
}

bool _isMacosAudioRecorderRunningViaFfi() {
  return _runRecorderBoolCall(
    macos_bindings.speech_utils_macos_audio_recorder_is_recording,
    operation: 'macOS recorder state read',
  );
}

bool _isWindowsAudioRecorderAvailableViaFfi() {
  return _runRecorderHealthcheck(windows_bindings.speech_utils_windows_audio_recorder_healthcheck);
}

bool _hasWindowsMicrophonePermissionViaFfi() {
  return _runRecorderBoolCall(
    windows_bindings.speech_utils_windows_audio_recorder_has_permission,
    operation: 'Windows microphone permission check',
  );
}

bool _requestWindowsMicrophonePermissionViaFfi() {
  return _runRecorderBoolCall(
    windows_bindings.speech_utils_windows_audio_recorder_request_permission,
    operation: 'Windows microphone permission request',
  );
}

void _startWindowsAudioRecorderFileViaFfi({
  required String outputPath,
  required int sampleRateHz,
  required int channelCount,
  required String? inputDeviceId,
}) {
  _runRecorderStartFile(
    windows_bindings.speech_utils_windows_audio_recorder_start_file,
    outputPath: outputPath,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    inputDeviceId: inputDeviceId,
    operation: 'Windows file recording start',
  );
}

void _startWindowsAudioRecorderStreamViaFfi({
  required int sampleRateHz,
  required int channelCount,
  required int framesPerChunk,
  required String? inputDeviceId,
}) {
  _runRecorderStartStream(
    windows_bindings.speech_utils_windows_audio_recorder_start_stream,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    framesPerChunk: framesPerChunk,
    inputDeviceId: inputDeviceId,
    operation: 'Windows stream recording start',
  );
}

List<InputDevice> _listWindowsAudioRecorderInputDevicesViaFfi() {
  return _runRecorderListInputDevices(
    windows_bindings.speech_utils_windows_audio_recorder_list_input_devices_json,
    operation: 'Windows input device listing',
  );
}

Uint8List _readWindowsAudioRecorderStreamViaFfi({required int maxSamples}) {
  return _runRecorderReadStream(
    windows_bindings.speech_utils_windows_audio_recorder_read_stream_pcm16,
    maxSamples: maxSamples,
    operation: 'Windows stream read',
  );
}

void _stopWindowsAudioRecorderViaFfi() {
  _runRecorderStop(
    windows_bindings.speech_utils_windows_audio_recorder_stop,
    operation: 'Windows recording stop',
  );
}

bool _isWindowsAudioRecorderRunningViaFfi() {
  return _runRecorderBoolCall(
    windows_bindings.speech_utils_windows_audio_recorder_is_recording,
    operation: 'Windows recorder state read',
  );
}

bool _isIosAudioRecorderAvailableViaFfi() {
  return _runRecorderHealthcheck(ios_bindings.speech_utils_ios_audio_recorder_healthcheck);
}

bool _hasIosMicrophonePermissionViaFfi() {
  return _runRecorderBoolCall(
    ios_bindings.speech_utils_ios_audio_recorder_has_permission,
    operation: 'iOS microphone permission check',
  );
}

bool _requestIosMicrophonePermissionViaFfi() {
  return _runRecorderBoolCall(
    ios_bindings.speech_utils_ios_audio_recorder_request_permission,
    operation: 'iOS microphone permission request',
  );
}

void _startIosAudioRecorderFileViaFfi({
  required String outputPath,
  required int sampleRateHz,
  required int channelCount,
  required String? inputDeviceId,
}) {
  _runRecorderStartFile(
    ios_bindings.speech_utils_ios_audio_recorder_start_file,
    outputPath: outputPath,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    inputDeviceId: inputDeviceId,
    operation: 'iOS file recording start',
  );
}

void _startIosAudioRecorderStreamViaFfi({
  required int sampleRateHz,
  required int channelCount,
  required int framesPerChunk,
  required String? inputDeviceId,
}) {
  _runRecorderStartStream(
    ios_bindings.speech_utils_ios_audio_recorder_start_stream,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    framesPerChunk: framesPerChunk,
    inputDeviceId: inputDeviceId,
    operation: 'iOS stream recording start',
  );
}

List<InputDevice> _listIosAudioRecorderInputDevicesViaFfi() {
  return _runRecorderListInputDevices(
    ios_bindings.speech_utils_ios_audio_recorder_list_input_devices_json,
    operation: 'iOS input device listing',
  );
}

Uint8List _readIosAudioRecorderStreamViaFfi({required int maxSamples}) {
  return _runRecorderReadStream(
    ios_bindings.speech_utils_ios_audio_recorder_read_stream_pcm16,
    maxSamples: maxSamples,
    operation: 'iOS stream read',
  );
}

void _stopIosAudioRecorderViaFfi() {
  _runRecorderStop(
    ios_bindings.speech_utils_ios_audio_recorder_stop,
    operation: 'iOS recording stop',
  );
}

bool _isIosAudioRecorderRunningViaFfi() {
  return _runRecorderBoolCall(
    ios_bindings.speech_utils_ios_audio_recorder_is_recording,
    operation: 'iOS recorder state read',
  );
}
