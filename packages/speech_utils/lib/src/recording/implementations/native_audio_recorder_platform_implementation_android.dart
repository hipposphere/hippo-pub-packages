part of 'package:speech_utils/src/recording/native_audio_recorder.dart';

final class _AndroidNativeAudioRecorderPlatformImplementation
    extends NativeAudioRecorderPlatformImplementation {
  const _AndroidNativeAudioRecorderPlatformImplementation()
      : super(
          platform: NativeAudioRecorderPlatform.android,
          supportsInputSelection: false,
          capabilities: const NativeAudioRecorderCapabilities(
            supportsNoiseCancellation: false,
            supportsEchoCancellation: false,
            supportsVoiceIsolation: false,
          ),
        );

  static final _backend = _AndroidJniAudioRecordBackend();

  @override
  bool isAvailable() => _backend.isAvailable();

  @override
  bool hasPermission() => _backend.hasPermission();

  @override
  bool requestPermission() => _backend.requestPermission();

  @override
  List<InputDevice> listInputDevices() => _backend.listInputDevices();

  @override
  void startFile({required String outputPath, required AudioRecorderConfig config}) {
    _backend.startFile(outputPath: outputPath, config: config);
  }

  @override
  void startStream({required AudioRecorderConfig config}) {
    _backend.startStream(config: config);
  }

  @override
  Uint8List readStream({required int maxSamples}) {
    return _backend.readStream(maxSamples: maxSamples);
  }

  @override
  void stop() => _backend.stop();

  @override
  void reset() => _backend.reset();

  @override
  bool isRecording() => _backend.isRecording();

  @override
  Amplitude getAmplitude() => _backend.getAmplitude();
}

enum _AndroidRecorderMode { stopped, file, stream }

final class _AndroidAudioRecordOpenResult {
  const _AndroidAudioRecordOpenResult({
    required this.audioRecord,
    required this.readBuffer,
    required this.readBufferSamples,
    required this.sampleRateHz,
    required this.channelCount,
  });

  final android_jni.AudioRecord audioRecord;
  final JShortArray readBuffer;
  final int readBufferSamples;
  final int sampleRateHz;
  final int channelCount;
}

final class _AndroidJniAudioRecordBackend {
  static const _errorCodeStreamReadFailed = -4;
  static const _errorCodeStartFailed = -7;

  static const _permissionGranted = 0;
  static const _permissionRequestCode = 3407;
  static const _recordAudioPermission = 'android.permission.RECORD_AUDIO';

  static const _audioSourceMic = 1;
  static const _audioSourceVoiceRecognition = 6;
  static const _audioFormatPcm16Bit = 2;
  static const _channelInMono = 16;
  static const _channelInStereo = 12;

  _AndroidRecorderMode _mode = _AndroidRecorderMode.stopped;
  android_jni.AudioRecord? _audioRecord;
  JShortArray? _readBuffer;
  int _readBufferSamples = 0;
  Timer? _fileDrainTimer;
  RandomAccessFile? _fileOutput;
  bool _fileOutputIsWav = true;
  int _activeSampleRateHz = 16000;
  int _activeChannelCount = 1;
  int _pcmDataBytesWritten = 0;
  double _currentDbfs = -90.0;
  double _maxDbfs = -90.0;

  bool isAvailable() {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      return _queryMinBufferSize(
            sampleRateHz: 16000,
            channelConfig: _channelInMono,
            audioFormat: _audioFormatPcm16Bit,
          ) >
          0;
    } on Object {
      return false;
    }
  }

  bool hasPermission() {
    if (!Platform.isAndroid) {
      return false;
    }
    return _hasRecordAudioPermission();
  }

  bool requestPermission() {
    if (!Platform.isAndroid) {
      return false;
    }
    if (_hasRecordAudioPermission()) {
      return true;
    }
    final engineId = PlatformDispatcher.instance.engineId;
    if (engineId == null) {
      return false;
    }
    final rawActivity = Jni.androidActivity(engineId);
    if (rawActivity == null) {
      return false;
    }
    final activity = rawActivity.as(android_jni.Activity.type, releaseOriginal: true);

    JArray<JString?>? permissions;
    JString? permission;
    try {
      permissions = JArray<JString?>(JString.nullableType, 1);
      permission = _recordAudioPermission.toJString();
      permissions[0] = permission;
      activity.requestPermissions(permissions, _permissionRequestCode);
    } on Object {
      return _hasRecordAudioPermission();
    } finally {
      permission?.release();
      permissions?.release();
      activity.release();
    }
    return _hasRecordAudioPermission();
  }

  List<InputDevice> listInputDevices() {
    return const <InputDevice>[
      InputDevice(
        id: 'default',
        label: 'Default microphone',
        isDefault: true,
      ),
    ];
  }

  void startFile({required String outputPath, required AudioRecorderConfig config}) {
    _ensureIdle();
    _ensurePermissionOrThrow(operation: 'Android file recording start');
    _resetAmplitude();

    final openResult = _openAudioRecord(config: config, operation: 'Android file recording start');
    _audioRecord = openResult.audioRecord;
    _readBuffer = openResult.readBuffer;
    _readBufferSamples = openResult.readBufferSamples;
    _activeSampleRateHz = openResult.sampleRateHz;
    _activeChannelCount = openResult.channelCount;
    _mode = _AndroidRecorderMode.file;

    try {
      _startFileOutput(outputPath: outputPath, config: config);
      final intervalMs = _computeFileDrainIntervalMs(
        framesPerChunk: config.framesPerChunk,
        sampleRateHz: _activeSampleRateHz,
      );
      _fileDrainTimer = Timer.periodic(
        Duration(milliseconds: intervalMs),
        _drainFileChunk,
      );
    } on Object {
      _stopInternal(throwOnError: false);
      rethrow;
    }
  }

  void startStream({required AudioRecorderConfig config}) {
    _ensureIdle();
    _ensurePermissionOrThrow(operation: 'Android stream recording start');
    _resetAmplitude();
    final openResult = _openAudioRecord(
      config: config,
      operation: 'Android stream recording start',
    );
    _audioRecord = openResult.audioRecord;
    _readBuffer = openResult.readBuffer;
    _readBufferSamples = openResult.readBufferSamples;
    _activeSampleRateHz = openResult.sampleRateHz;
    _activeChannelCount = openResult.channelCount;
    _mode = _AndroidRecorderMode.stream;
  }

  Uint8List readStream({required int maxSamples}) {
    if (_mode != _AndroidRecorderMode.stream) {
      throw const AudioRecorderException(
        'Android stream read failed',
        errorCode: _errorCodeStreamReadFailed,
        details: 'Recorder is not in stream mode.',
      );
    }
    if (maxSamples <= 0) {
      return Uint8List(0);
    }
    return _readChunk(
      operation: 'Android stream read',
      maxSamples: maxSamples,
    );
  }

  void stop() {
    _stopInternal(throwOnError: true);
  }

  void reset() {
    _stopInternal(throwOnError: false);
    _resetAmplitude();
  }

  bool isRecording() {
    if (_mode == _AndroidRecorderMode.stopped) {
      return false;
    }
    final audioRecord = _audioRecord;
    if (audioRecord == null) {
      return false;
    }
    try {
      final recordingState = audioRecord.getRecordingState();
      return recordingState == android_jni.AudioRecord.RECORDSTATE_RECORDING;
    } on Object {
      return false;
    }
  }

  Amplitude getAmplitude() {
    return Amplitude(
      current: _sanitizeAndroidDbfs(_currentDbfs),
      max: _sanitizeAndroidDbfs(_maxDbfs),
    );
  }

  void _drainFileChunk(Timer _) {
    if (_mode != _AndroidRecorderMode.file) {
      return;
    }
    try {
      final bytes = _readChunk(
        operation: 'Android file recording read',
        maxSamples: _readBufferSamples,
      );
      if (bytes.isEmpty) {
        return;
      }
      final output = _fileOutput;
      if (output == null) {
        throw const AudioRecorderException(
          'Android file recording start failed',
          errorCode: _errorCodeStartFailed,
          details: 'Output file is not available.',
        );
      }
      output.writeFromSync(bytes);
      _pcmDataBytesWritten += bytes.length;
    } on Object {
      _stopInternal(throwOnError: false);
    }
  }

  void _startFileOutput({required String outputPath, required AudioRecorderConfig config}) {
    final outputFile = File(outputPath);
    outputFile.parent.createSync(recursive: true);
    final randomAccessFile = outputFile.openSync(mode: FileMode.write);
    _fileOutputIsWav = config.encoding.encoder != AudioEncoder.pcm16bits;
    if (_fileOutputIsWav) {
      randomAccessFile.writeFromSync(Uint8List(_wavHeaderBytes));
    }
    _fileOutput = randomAccessFile;
    _pcmDataBytesWritten = 0;
  }

  int _computeFileDrainIntervalMs({
    required int framesPerChunk,
    required int sampleRateHz,
  }) {
    final effectiveFrames = framesPerChunk > 0 ? framesPerChunk : (sampleRateHz ~/ 50);
    final millis = ((effectiveFrames * 1000) / sampleRateHz).round();
    return (millis.clamp(10, 60) as num).toInt();
  }

  Uint8List _readChunk({
    required String operation,
    required int maxSamples,
  }) {
    final audioRecord = _audioRecord;
    final readBuffer = _readBuffer;
    if (audioRecord == null || readBuffer == null) {
      throw AudioRecorderException(
        '$operation failed',
        errorCode: _errorCodeStreamReadFailed,
        details: 'AudioRecord is not initialized.',
      );
    }

    final samplesToRead = math.min(maxSamples, _readBufferSamples);
    if (samplesToRead <= 0) {
      return Uint8List(0);
    }

    final samplesRead = audioRecord.read$5(readBuffer, 0, samplesToRead);

    if (samplesRead < 0) {
      throw AudioRecorderException(
        '$operation failed',
        errorCode: _errorCodeStreamReadFailed,
        details: 'AudioRecord.read returned $samplesRead.',
      );
    }
    if (samplesRead == 0) {
      return Uint8List(0);
    }

    final pcmSamples = readBuffer.getRange(0, samplesRead);
    _updateAmplitude(pcmSamples);

    final bytes = Uint8List(samplesRead * 2);
    bytes.buffer.asInt16List().setRange(0, samplesRead, pcmSamples);
    return bytes;
  }

  _AndroidAudioRecordOpenResult _openAudioRecord({
    required AudioRecorderConfig config,
    required String operation,
  }) {
    final requestedChannelCount = config.channelCount <= 1 ? 1 : 2;
    final channelConfig = requestedChannelCount == 1 ? _channelInMono : _channelInStereo;

    final sampleRates = <int>[config.sampleRateHz];
    if (!sampleRates.contains(16000)) {
      sampleRates.add(16000);
    }
    if (!sampleRates.contains(48000)) {
      sampleRates.add(48000);
    }
    if (!sampleRates.contains(44100)) {
      sampleRates.add(44100);
    }

    final sources = <int>[_audioSourceMic, _audioSourceVoiceRecognition];
    final attemptErrors = <String>[];

    for (final sampleRateHz in sampleRates) {
      for (final source in sources) {
        android_jni.AudioRecord? audioRecord;
        try {
          final minBufferSize = _queryMinBufferSize(
            sampleRateHz: sampleRateHz,
            channelConfig: channelConfig,
            audioFormat: _audioFormatPcm16Bit,
          );
          if (minBufferSize <= 0) {
            attemptErrors.add(
              'source=$source rate=$sampleRateHz getMinBufferSize=$minBufferSize',
            );
            continue;
          }

          final targetFrames = math.max(config.framesPerChunk, sampleRateHz ~/ 50);
          final requestedBufferBytes = math.max(
            minBufferSize,
            targetFrames * requestedChannelCount * 2,
          );

          audioRecord = android_jni.AudioRecord(
            source,
            sampleRateHz,
            channelConfig,
            _audioFormatPcm16Bit,
            requestedBufferBytes,
          );

          final state = audioRecord.getState();
          if (state != android_jni.AudioRecord.STATE_INITIALIZED) {
            attemptErrors.add(
              'source=$source rate=$sampleRateHz initializedState=$state',
            );
            _releaseAudioRecordObject(audioRecord);
            audioRecord = null;
            continue;
          }

          audioRecord.startRecording();

          final recordingState = audioRecord.getRecordingState();
          if (recordingState != android_jni.AudioRecord.RECORDSTATE_RECORDING) {
            attemptErrors.add(
              'source=$source rate=$sampleRateHz recordingState=$recordingState',
            );
            _stopAndReleaseAudioRecordObject(audioRecord);
            audioRecord = null;
            continue;
          }

          final actualSampleRate = audioRecord.getSampleRate();
          final readBufferSamples = math.max(
            requestedBufferBytes ~/ 2,
            math.max(256, targetFrames * requestedChannelCount),
          );
          final readBuffer = JShortArray(readBufferSamples);
          return _AndroidAudioRecordOpenResult(
            audioRecord: audioRecord,
            readBuffer: readBuffer,
            readBufferSamples: readBufferSamples,
            sampleRateHz: actualSampleRate > 0 ? actualSampleRate : sampleRateHz,
            channelCount: requestedChannelCount,
          );
        } on Object catch (error) {
          attemptErrors.add('source=$source rate=$sampleRateHz error=$error');
          if (audioRecord != null) {
            _stopAndReleaseAudioRecordObject(audioRecord);
          }
        }
      }
    }

    final details = attemptErrors.isEmpty ? null : attemptErrors.join(' | ');
    throw AudioRecorderException(
      '$operation failed',
      errorCode: _errorCodeStartFailed,
      details: details ?? 'Failed to open AudioRecord session.',
    );
  }

  int _queryMinBufferSize({
    required int sampleRateHz,
    required int channelConfig,
    required int audioFormat,
  }) {
    return android_jni.AudioRecord.getMinBufferSize(
      sampleRateHz,
      channelConfig,
      audioFormat,
    );
  }

  bool _hasRecordAudioPermission() {
    JObject? rawContext;
    android_jni.Context? typedContext;
    JString? permission;
    try {
      rawContext = Jni.androidApplicationContext;
      typedContext = rawContext.as(android_jni.Context.type, releaseOriginal: true);
      rawContext = null;
      permission = _recordAudioPermission.toJString();
      final result = typedContext!.checkSelfPermission(permission);
      return result == _permissionGranted;
    } on Object {
      return false;
    } finally {
      permission?.release();
      typedContext?.release();
      rawContext?.release();
    }
  }

  void _ensurePermissionOrThrow({required String operation}) {
    if (_hasRecordAudioPermission()) {
      return;
    }
    requestPermission();
    if (_hasRecordAudioPermission()) {
      return;
    }
    throw AudioRecorderException(
      '$operation failed',
      errorCode: _errorCodeStartFailed,
      details: 'Microphone permission not granted ($_recordAudioPermission).',
    );
  }

  void _ensureIdle() {
    if (_mode != _AndroidRecorderMode.stopped) {
      throw const NativeAudioRecorderBusyException('A recording session is already running.');
    }
  }

  void _stopInternal({required bool throwOnError}) {
    final wasFileMode = _mode == _AndroidRecorderMode.file;
    final errors = <String>[];

    _fileDrainTimer?.cancel();
    _fileDrainTimer = null;

    final audioRecord = _audioRecord;
    _audioRecord = null;
    if (audioRecord != null) {
      try {
        audioRecord.stop();
      } on Object catch (error) {
        errors.add('AudioRecord.stop error: $error');
      }
      try {
        audioRecord.release$1();
      } on Object catch (error) {
        errors.add('AudioRecord.release error: $error');
      }
      audioRecord.release();
    }

    final readBuffer = _readBuffer;
    _readBuffer = null;
    _readBufferSamples = 0;
    readBuffer?.release();

    final output = _fileOutput;
    _fileOutput = null;
    if (output != null) {
      try {
        if (wasFileMode && _fileOutputIsWav) {
          _writeWavHeader(
            output,
            sampleRateHz: _activeSampleRateHz,
            channelCount: _activeChannelCount,
            pcmDataBytes: _pcmDataBytesWritten,
          );
        }
      } on Object catch (error) {
        errors.add('WAV finalize error: $error');
      }
      try {
        output.flushSync();
      } on Object catch (error) {
        errors.add('Output flush error: $error');
      }
      try {
        output.closeSync();
      } on Object catch (error) {
        errors.add('Output close error: $error');
      }
    }

    _mode = _AndroidRecorderMode.stopped;
    _pcmDataBytesWritten = 0;

    if (throwOnError && errors.isNotEmpty) {
      throw AudioRecorderException(
        'Android recording stop failed',
        details: errors.join(' | '),
      );
    }
  }

  void _releaseAudioRecordObject(android_jni.AudioRecord audioRecord) {
    try {
      audioRecord.release$1();
    } on Object {
      // Best effort cleanup only.
    } finally {
      audioRecord.release();
    }
  }

  void _stopAndReleaseAudioRecordObject(android_jni.AudioRecord audioRecord) {
    try {
      audioRecord.stop();
    } on Object {
      // Best effort cleanup only.
    } finally {
      _releaseAudioRecordObject(audioRecord);
    }
  }

  void _resetAmplitude() {
    _currentDbfs = -90.0;
    _maxDbfs = -90.0;
  }

  void _updateAmplitude(Int16List samples) {
    if (samples.isEmpty) {
      _currentDbfs = -90.0;
      return;
    }

    var peak = 0;
    for (final sample in samples) {
      final absolute = sample < 0 ? -sample : sample;
      if (absolute > peak) {
        peak = absolute;
      }
    }

    if (peak <= 0) {
      _currentDbfs = -90.0;
      return;
    }

    final normalized = peak / 32767.0;
    final dbfs = _sanitizeAndroidDbfs(20.0 * (math.log(normalized) / math.ln10));
    _currentDbfs = dbfs;
    if (dbfs > _maxDbfs) {
      _maxDbfs = dbfs;
    }
  }

  double _sanitizeAndroidDbfs(double value) {
    if (value.isNaN || value.isInfinite) {
      return -90.0;
    }
    return (value.clamp(-90.0, 0.0) as num).toDouble();
  }

  static const _wavHeaderBytes = 44;

  void _writeWavHeader(
    RandomAccessFile file, {
    required int sampleRateHz,
    required int channelCount,
    required int pcmDataBytes,
  }) {
    final byteRate = sampleRateHz * channelCount * 2;
    final blockAlign = channelCount * 2;
    final riffChunkSize = 36 + pcmDataBytes;

    final header = ByteData(_wavHeaderBytes);
    header.setUint32(0, 0x46464952, Endian.little); // RIFF
    header.setUint32(4, riffChunkSize, Endian.little);
    header.setUint32(8, 0x45564157, Endian.little); // WAVE
    header.setUint32(12, 0x20746d66, Endian.little); // fmt
    header.setUint32(16, 16, Endian.little); // PCM chunk size
    header.setUint16(20, 1, Endian.little); // PCM format
    header.setUint16(22, channelCount, Endian.little);
    header.setUint32(24, sampleRateHz, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, 16, Endian.little); // bits per sample
    header.setUint32(36, 0x61746164, Endian.little); // data
    header.setUint32(40, pcmDataBytes, Endian.little);

    final endPosition = file.lengthSync();
    file.setPositionSync(0);
    file.writeFromSync(header.buffer.asUint8List());
    file.setPositionSync(endPosition);
  }
}
