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
  Future<bool> requestPermission() => _backend.requestPermission();

  @override
  List<InputDevice> listInputDevices() => _backend.listInputDevices();

  @override
  Future<void> startFile({required String outputPath, required AudioRecorderConfig config}) async {
    await _backend.startFile(outputPath: outputPath, config: config);
  }

  @override
  Future<void> startStream({required AudioRecorderConfig config}) async {
    await _backend.startStream(config: config);
  }

  @override
  Uint8List readStream({required int maxSamples}) {
    return _backend.readStream(maxSamples: maxSamples);
  }

  @override
  Future<void> stop() => _backend.stop();

  @override
  Future<void> reset() => _backend.reset();

  @override
  bool isRecording() => _backend.isRecording();

  @override
  Amplitude getAmplitude() => _backend.getAmplitude();
}

enum _AndroidRecorderMode { stopped, file, stream }

final class _AndroidJniAudioRecordBackend {
  static const _errorCodeStreamReadFailed = -4;
  static const _errorCodeStartFailed = -7;
  static const _sourcePolicyVoice = 1;
  static const _sourcePolicyRaw = 2;
  static const _sourcePolicyMic = 3;
  static const _fileEncoderAacLc = 1;
  static const _fileEncoderAacHe = 2;
  static const _fileEncoderAacEld = 3;

  static const _permissionGranted = 0;
  static const _permissionRequestCode = 3407;
  static const _recordAudioPermission = 'android.permission.RECORD_AUDIO';
  static const _permissionRequestPollInterval = Duration(milliseconds: 100);
  static const _permissionDialogDetectionTimeout = Duration(seconds: 2);
  static const _permissionResolutionTimeout = Duration(seconds: 30);

  _AndroidRecorderMode _mode = _AndroidRecorderMode.stopped;
  _AndroidRecorderWorkerBridge? _worker;
  int _activeChannelCount = 1;
  double _currentDbfs = -90.0;
  double _maxDbfs = -90.0;

  bool isAvailable() {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      final worker = _AndroidAudioRecordWorkerBridge.create();
      worker.release();
      return true;
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

  Future<bool> requestPermission() async {
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
    final rawActivity = androidActivity(engineId);
    if (rawActivity == null) {
      return false;
    }
    final activity = rawActivity.as(android_jni.Activity.type, releaseOriginal: true);
    try {
      return await _requestRecordAudioPermission(activity);
    } on Object {
      return _hasRecordAudioPermission();
    } finally {
      activity.release();
    }
  }

  List<InputDevice> listInputDevices() {
    return const <InputDevice>[
      InputDevice(id: 'default', label: 'Default microphone', isDefault: true),
    ];
  }

  Future<void> startFile({required String outputPath, required AudioRecorderConfig config}) async {
    _ensureIdle();
    _ensurePermissionOrThrow(operation: 'Android file recording start');
    _resetAmplitude();

    final encoderCode = _resolveAndroidFileEncoderCode(config.encoding.encoder);
    final bitrateBps = _resolveEncodingBitrateBps(config.encoding);

    final worker = _AndroidMediaRecorderWorkerBridge.create();
    try {
      worker.startFile(
        outputPath: outputPath,
        sampleRateHz: config.sampleRateHz,
        channelCount: config.channelCount,
        bitrateBps: bitrateBps,
        audioEncoderCode: encoderCode,
        sourcePolicyCode: _resolveSourcePolicyCode(config),
      );
      _worker = worker;
      _activeChannelCount = worker.activeChannelCount;
      _mode = _AndroidRecorderMode.file;
      _refreshAmplitudeFromWorker();
    } on Object catch (error) {
      worker.release();
      throw _wrapAndroidWorkerError(
        operation: 'Android file recording start',
        errorCode: _errorCodeStartFailed,
        error: error,
      );
    }
  }

  Future<void> startStream({required AudioRecorderConfig config}) async {
    _ensureIdle();
    _ensurePermissionOrThrow(operation: 'Android stream recording start');
    _resetAmplitude();

    final worker = _AndroidAudioRecordWorkerBridge.create();
    try {
      worker.startStream(
        sampleRateHz: config.sampleRateHz,
        channelCount: config.channelCount,
        framesPerChunk: config.framesPerChunk,
        sourcePolicyCode: _resolveSourcePolicyCode(config),
      );
      _worker = worker;
      _activeChannelCount = worker.activeChannelCount;
      _mode = _AndroidRecorderMode.stream;
      _refreshAmplitudeFromWorker();
    } on Object catch (error) {
      worker.release();
      throw _wrapAndroidWorkerError(
        operation: 'Android stream recording start',
        errorCode: _errorCodeStartFailed,
        error: error,
      );
    }
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

    final worker = _worker;
    if (worker is! _AndroidAudioRecordWorkerBridge) {
      return Uint8List(0);
    }

    try {
      final bytes = worker.readStream(maxBytes: _alignedMaxBytes(maxSamples));
      _refreshAmplitudeFromWorker();
      return bytes;
    } on Object catch (error) {
      throw _wrapAndroidWorkerError(
        operation: 'Android stream read',
        errorCode: _errorCodeStreamReadFailed,
        error: error,
      );
    }
  }

  Future<void> stop() async {
    await _stopInternal(throwOnError: true);
  }

  Future<void> reset() async {
    await _stopInternal(throwOnError: false);
    _resetAmplitude();
  }

  bool isRecording() {
    if (_mode == _AndroidRecorderMode.stopped) {
      return false;
    }
    final worker = _worker;
    if (worker == null) {
      return false;
    }
    try {
      return worker.isRecording();
    } on Object {
      return false;
    }
  }

  Amplitude getAmplitude() {
    _refreshAmplitudeFromWorker();
    return Amplitude(
      current: _sanitizeAndroidDbfs(_currentDbfs),
      max: _sanitizeAndroidDbfs(_maxDbfs),
    );
  }

  bool _hasRecordAudioPermission() {
    JObject? rawContext;
    android_jni.Context? typedContext;
    JString? permission;
    try {
      rawContext = androidApplicationContext;
      typedContext = rawContext.as(android_jni.Context.type, releaseOriginal: true);
      rawContext = null;
      permission = _recordAudioPermission.toJString();
      final result = typedContext.checkSelfPermission(permission);
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
    throw AudioRecorderException(
      '$operation failed',
      errorCode: _errorCodeStartFailed,
      details:
          'Microphone permission not granted ($_recordAudioPermission). '
          'Call requestPermission() and wait for it to complete before starting recording.',
    );
  }

  Future<bool> _requestRecordAudioPermission(android_jni.Activity activity) async {
    JArray<JString?>? permissions;
    JString? permission;
    try {
      permission = _recordAudioPermission.toJString();
      permissions = JArray.withLength(JString.type, 1);
      permissions[0] = permission;

      final initialShouldShowRationale = _safeShouldShowRequestPermissionRationale(
        activity,
        permission,
        fallback: false,
      );
      final initialHasWindowFocus = _safeHasWindowFocus(activity, fallback: true);

      await _runOnUiThread(activity, () {
        activity.requestPermissions(permissions, _permissionRequestCode);
      });

      return await _waitForPermissionRequestResolution(
        activity: activity,
        permission: permission,
        initialShouldShowRationale: initialShouldShowRationale,
        initialHasWindowFocus: initialHasWindowFocus,
      );
    } finally {
      permissions?.release();
      permission?.release();
    }
  }

  Future<void> _runOnUiThread(android_jni.Activity activity, void Function() action) {
    final completer = Completer<void>();
    final runnable = android_jni.Runnable.implement(
      android_jni.$Runnable(
        run: () {
          if (completer.isCompleted) {
            return;
          }
          try {
            action();
            completer.complete();
          } catch (error, stackTrace) {
            completer.completeError(error, stackTrace);
          }
        },
      ),
    );

    try {
      activity.runOnUiThread(runnable);
    } catch (error, stackTrace) {
      runnable.release();
      if (!completer.isCompleted) {
        completer.completeError(error, stackTrace);
      }
    }

    return completer.future.whenComplete(() {
      runnable.release();
    });
  }

  Future<bool> _waitForPermissionRequestResolution({
    required android_jni.Activity activity,
    required JString permission,
    required bool initialShouldShowRationale,
    required bool initialHasWindowFocus,
  }) async {
    var sawDialogFocusLoss = false;
    final startedAt = DateTime.now();

    while (DateTime.now().difference(startedAt) < _permissionResolutionTimeout) {
      if (_hasRecordAudioPermission()) {
        return true;
      }

      final hasWindowFocus = _safeHasWindowFocus(activity, fallback: initialHasWindowFocus);
      final shouldShowRationale = _safeShouldShowRequestPermissionRationale(
        activity,
        permission,
        fallback: initialShouldShowRationale,
      );

      if (initialHasWindowFocus && !hasWindowFocus) {
        sawDialogFocusLoss = true;
      }

      if (sawDialogFocusLoss && hasWindowFocus) {
        return _hasRecordAudioPermission();
      }

      if (shouldShowRationale != initialShouldShowRationale) {
        return _hasRecordAudioPermission();
      }

      if (!sawDialogFocusLoss &&
          DateTime.now().difference(startedAt) >= _permissionDialogDetectionTimeout) {
        return _hasRecordAudioPermission();
      }

      await Future<void>.delayed(_permissionRequestPollInterval);
    }

    return _hasRecordAudioPermission();
  }

  bool _safeHasWindowFocus(android_jni.Activity activity, {required bool fallback}) {
    try {
      if (activity.isFinishing || activity.isDestroyed) {
        return fallback;
      }
      return activity.hasWindowFocus();
    } on Object {
      return fallback;
    }
  }

  bool _safeShouldShowRequestPermissionRationale(
    android_jni.Activity activity,
    JString permission, {
    required bool fallback,
  }) {
    try {
      if (activity.isFinishing || activity.isDestroyed) {
        return fallback;
      }
      return activity.shouldShowRequestPermissionRationale(permission);
    } on Object {
      return fallback;
    }
  }

  void _ensureIdle() {
    if (_mode != _AndroidRecorderMode.stopped) {
      throw const NativeAudioRecorderBusyException('A recording session is already running.');
    }
  }

  Future<void> _stopInternal({required bool throwOnError}) async {
    final worker = _worker;
    _worker = null;
    _mode = _AndroidRecorderMode.stopped;

    if (worker == null) {
      return;
    }

    Object? stopError;
    StackTrace? stopStackTrace;
    try {
      if (throwOnError) {
        worker.stop();
      } else {
        worker.reset();
      }
    } on Object catch (error, stackTrace) {
      stopError = error;
      stopStackTrace = stackTrace;
    } finally {
      worker.release();
    }

    if (stopError != null && throwOnError) {
      Error.throwWithStackTrace(
        _wrapAndroidWorkerError(
          operation: 'Android recording stop',
          errorCode: _errorCodeStreamReadFailed,
          error: stopError,
        ),
        stopStackTrace ?? StackTrace.current,
      );
    }
  }

  void _refreshAmplitudeFromWorker() {
    final worker = _worker;
    if (worker == null) {
      return;
    }
    try {
      final current = _sanitizeAndroidDbfs(worker.currentDbfs);
      final maxValue = _sanitizeAndroidDbfs(worker.maxDbfs);
      _currentDbfs = current;
      if (maxValue > _maxDbfs) {
        _maxDbfs = maxValue;
      }
    } on Object {
      // Fall back to the latest cached amplitude snapshot.
    }
  }

  int _alignedMaxBytes(int maxSamples) {
    final rawBytes = maxSamples * 2;
    final bytesPerFrame = math.max(2, _activeChannelCount * 2);
    final aligned = rawBytes - (rawBytes % bytesPerFrame);
    return aligned > 0 ? aligned : 0;
  }

  void _resetAmplitude() {
    _currentDbfs = -90.0;
    _maxDbfs = -90.0;
  }

  int _resolveSourcePolicyCode(AudioRecorderConfig config) {
    return switch (config.processing.preset) {
      AudioCapturePreset.raw => _sourcePolicyRaw,
      AudioCapturePreset.music => _sourcePolicyMic,
      AudioCapturePreset.voice || AudioCapturePreset.voiceIsolation => _sourcePolicyVoice,
    };
  }

  int _resolveAndroidFileEncoderCode(AudioEncoder encoder) {
    return switch (encoder) {
      AudioEncoder.aacLc => _fileEncoderAacLc,
      AudioEncoder.aacHe => _fileEncoderAacHe,
      AudioEncoder.aacEld => _fileEncoderAacEld,
      AudioEncoder.wav ||
      AudioEncoder.pcm16bits ||
      AudioEncoder.flac ||
      AudioEncoder.opus => throw ArgumentError.value(
        encoder,
        'config.encoding.encoder',
        'Android file recording supports AAC encoders only. Use AudioEncoder.aacLc, '
            'AudioEncoder.aacHe, or AudioEncoder.aacEld.',
      ),
    };
  }

  double _sanitizeAndroidDbfs(double value) {
    if (value.isNaN || value.isInfinite) {
      return -90.0;
    }
    return (value.clamp(-90.0, 0.0) as num).toDouble();
  }

  AudioRecorderException _wrapAndroidWorkerError({
    required String operation,
    required int errorCode,
    required Object error,
  }) {
    return AudioRecorderException('$operation failed', errorCode: errorCode, details: '$error');
  }
}

abstract class _AndroidRecorderWorkerBridge {
  void stop();
  void reset();
  bool isRecording();
  double get currentDbfs;
  double get maxDbfs;
  int get activeSampleRateHz;
  int get activeChannelCount;
  void release();
}

final class _AndroidMediaRecorderWorkerBridge implements _AndroidRecorderWorkerBridge {
  _AndroidMediaRecorderWorkerBridge._(this._instance);

  static const _className = 'org/hippolabs/speech_utils/SpeechUtilsMediaRecorderWorker';
  static final JClass _class = JClass.forName(_className);
  static final _constructor = _class.constructorId('()V');
  static final _startFileMethod = _class.instanceMethodId(
    'startFile',
    '(Ljava/lang/String;IIIII)V',
  );
  static final _stopMethod = _class.instanceMethodId('stop', '()V');
  static final _resetMethod = _class.instanceMethodId('reset', '()V');
  static final _isRecordingMethod = _class.instanceMethodId('isRecording', '()Z');
  static final _currentDbfsMethod = _class.instanceMethodId('getCurrentDbfs', '()D');
  static final _maxDbfsMethod = _class.instanceMethodId('getMaxDbfs', '()D');
  static final _activeSampleRateMethod = _class.instanceMethodId('getActiveSampleRateHz', '()I');
  static final _activeChannelCountMethod = _class.instanceMethodId('getActiveChannelCount', '()I');

  final JObject _instance;

  factory _AndroidMediaRecorderWorkerBridge.create() {
    return _AndroidMediaRecorderWorkerBridge._(_constructor.call(_class, []));
  }

  void startFile({
    required String outputPath,
    required int sampleRateHz,
    required int channelCount,
    required int bitrateBps,
    required int audioEncoderCode,
    required int sourcePolicyCode,
  }) {
    final path = outputPath.toJString();
    try {
      _startFileMethod.call(_instance, jvoid.type, [
        path,
        sampleRateHz,
        channelCount,
        bitrateBps,
        audioEncoderCode,
        sourcePolicyCode,
      ]);
    } finally {
      path.release();
    }
  }

  @override
  void stop() {
    _stopMethod.call(_instance, jvoid.type, []);
  }

  @override
  void reset() {
    _resetMethod.call(_instance, jvoid.type, []);
  }

  @override
  bool isRecording() {
    return _isRecordingMethod.call(_instance, jboolean.type, []);
  }

  @override
  double get currentDbfs {
    return _currentDbfsMethod.call(_instance, jdouble.type, []);
  }

  @override
  double get maxDbfs {
    return _maxDbfsMethod.call(_instance, jdouble.type, []);
  }

  @override
  int get activeSampleRateHz {
    return _activeSampleRateMethod.call(_instance, jint.type, []);
  }

  @override
  int get activeChannelCount {
    return _activeChannelCountMethod.call(_instance, jint.type, []);
  }

  @override
  void release() {
    _instance.release();
  }
}

final class _AndroidAudioRecordWorkerBridge implements _AndroidRecorderWorkerBridge {
  _AndroidAudioRecordWorkerBridge._(this._instance);

  static const _className = 'org/hippolabs/speech_utils/SpeechUtilsAudioRecordWorker';
  static final JClass _class = JClass.forName(_className);
  static final _constructor = _class.constructorId('()V');
  static final _startFileMethod = _class.instanceMethodId(
    'startFile',
    '(Ljava/lang/String;IIIZI)V',
  );
  static final _startStreamMethod = _class.instanceMethodId('startStream', '(IIII)V');
  static final _readStreamMethod = _class.instanceMethodId('readStream', '(I)[B');
  static final _stopMethod = _class.instanceMethodId('stop', '()V');
  static final _resetMethod = _class.instanceMethodId('reset', '()V');
  static final _isRecordingMethod = _class.instanceMethodId('isRecording', '()Z');
  static final _currentDbfsMethod = _class.instanceMethodId('getCurrentDbfs', '()D');
  static final _maxDbfsMethod = _class.instanceMethodId('getMaxDbfs', '()D');
  static final _activeSampleRateMethod = _class.instanceMethodId('getActiveSampleRateHz', '()I');
  static final _activeChannelCountMethod = _class.instanceMethodId('getActiveChannelCount', '()I');

  final JObject _instance;

  factory _AndroidAudioRecordWorkerBridge.create() {
    return _AndroidAudioRecordWorkerBridge._(_constructor.call(_class, []));
  }

  void startFile({
    required String outputPath,
    required int sampleRateHz,
    required int channelCount,
    required int framesPerChunk,
    required bool outputIsWav,
    required int sourcePolicyCode,
  }) {
    final path = outputPath.toJString();
    try {
      _startFileMethod.call(_instance, jvoid.type, [
        path,
        sampleRateHz,
        channelCount,
        framesPerChunk,
        outputIsWav,
        sourcePolicyCode,
      ]);
    } finally {
      path.release();
    }
  }

  void startStream({
    required int sampleRateHz,
    required int channelCount,
    required int framesPerChunk,
    required int sourcePolicyCode,
  }) {
    _startStreamMethod.call(_instance, jvoid.type, [
      sampleRateHz,
      channelCount,
      framesPerChunk,
      sourcePolicyCode,
    ]);
  }

  Uint8List readStream({required int maxBytes}) {
    final array = _readStreamMethod.call(_instance, JByteArray.type, [maxBytes]);
    try {
      final bytes = array.getRange(0, array.length);
      return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    } finally {
      array.release();
    }
  }

  @override
  void stop() {
    _stopMethod.call(_instance, jvoid.type, []);
  }

  @override
  void reset() {
    _resetMethod.call(_instance, jvoid.type, []);
  }

  @override
  bool isRecording() {
    return _isRecordingMethod.call(_instance, jboolean.type, []);
  }

  @override
  double get currentDbfs {
    return _currentDbfsMethod.call(_instance, jdouble.type, []);
  }

  @override
  double get maxDbfs {
    return _maxDbfsMethod.call(_instance, jdouble.type, []);
  }

  @override
  int get activeSampleRateHz {
    return _activeSampleRateMethod.call(_instance, jint.type, []);
  }

  @override
  int get activeChannelCount {
    return _activeChannelCountMethod.call(_instance, jint.type, []);
  }

  @override
  void release() {
    _instance.release();
  }
}
