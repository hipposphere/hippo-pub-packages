import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_utils/speech_utils.dart';
import 'package:speech_utils_example/widgets/audio_processing_card.dart';
import 'package:speech_utils_example/widgets/example_dropdown_form_field.dart';
import 'package:speech_utils_example/widgets/live_waveform.dart';
import 'package:speech_utils_example/widgets/theme_controls.dart';

const _speechHoldDuration = Duration(milliseconds: 320);
const _waveformLimit = 220;

enum _TenVadPreset { sensitive, balanced, strict }

class IntegratedVadCompressionPage extends StatefulWidget {
  const IntegratedVadCompressionPage({
    super.key,
    this.detectAacOnStartup = true,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final bool detectAacOnStartup;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<IntegratedVadCompressionPage> createState() =>
      _IntegratedVadCompressionPageState();
}

class _IntegratedVadCompressionPageState
    extends State<IntegratedVadCompressionPage> {
  final NativeAudioRecorder _recorder = NativeAudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  late ThemeMode _themeMode;
  late final bool _supportsInputSelection;

  final NativeAudioEncoder _nativeAacEncoder = NativeAudioEncoder();
  final FfmpegAacEncoder _ffmpegAacEncoder = FfmpegAacEncoder();

  final List<String> _logs = <String>[];
  final List<_SnippetArtifact> _snippets = <_SnippetArtifact>[];
  final List<double> _waveformSamples = <double>[];
  List<InputDevice> _inputDevices = <InputDevice>[];
  InputDevice? _selectedInputDevice;

  Directory? _outputRoot;
  Directory? _liveOutputDir;

  VadCaptureSession? _liveCaptureSession;
  StreamSubscription<VoiceSegment>? _liveSegmentSubscription;
  StreamSubscription<VadSpeechStateSample>? _liveSpeechStateSubscription;
  StreamSubscription<VadLevelSample>? _liveLevelSubscription;

  Timer? _recordingTicker;
  Timer? _streamHealthTimer;
  final Stopwatch _recordingStopwatch = Stopwatch();

  bool _isRunningSyntheticChecks = false;
  bool _isLiveStreaming = false;
  bool _isRefreshingInputDevices = false;
  bool _speechDetected = false;
  int _liveSnippetCount = 0;
  int _liveChunkCount = 0;
  double _currentRms = 0;
  double _currentDbfs = -90;

  bool _autoConvertSnippets = true;
  bool _convertWholeRecordingWhenStopped = true;
  bool _preferTenVadForLive = true;
  _TenVadPreset _tenVadPreset = _TenVadPreset.balanced;

  double _tenVadThreshold = 0.45;
  double _energyPrimaryRmsThreshold = 0.0045;
  double _energySecondaryRmsThreshold = 0.0025;
  double _energyMinZeroCrossingRate = 0.02;

  AacEncoder? _selectedAacEncoder;
  String _selectedAacEncoderLabel = 'Not available';

  Duration _recordingDuration = Duration.zero;
  String _activeVadLabel = 'None';

  String? _playingPath;

  String? _fullRecordingWavPath;
  int? _fullRecordingWavBytes;
  AudioMetadata? _fullRecordingWavMetadata;
  String? _fullRecordingAacPath;
  int? _fullRecordingAacBytes;
  int? _fullRecordingAacLatencyMs;
  AudioMetadata? _fullRecordingAacMetadata;

  int? _sampleRateHz;
  int _channelCount = 1;
  int? _bitrateKbps;
  AudioProcessingController _processingController =
      const AudioProcessingController();

  PauseSplitOptions get _splitOptions => PauseSplitOptions(
    sampleRateHz: _sampleRateHz ?? 16000,
    channelCount: _channelCount,
    frameDuration: const Duration(milliseconds: 16),
    minSpeechDuration: const Duration(milliseconds: 140),
    minSilenceDuration: const Duration(milliseconds: 750),
    preSpeechPadding: const Duration(milliseconds: 80),
    postSpeechPadding: const Duration(milliseconds: 120),
  );

  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeMode;
    _supportsInputSelection = _recorder.supportsInputSelection;
    _player.onPlayerComplete.listen((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _playingPath = null;
      });
    });

    unawaited(_ensureOutputRoot());
    unawaited(_refreshInputDevices(logResult: false));
    if (widget.detectAacOnStartup) {
      unawaited(_detectAvailableAacEncoder());
    }
  }

  @override
  void dispose() {
    _recordingTicker?.cancel();
    _streamHealthTimer?.cancel();
    _recordingStopwatch.stop();

    unawaited(_liveCaptureSession?.cancel());
    unawaited(_liveSegmentSubscription?.cancel());
    unawaited(_liveSpeechStateSubscription?.cancel());
    unawaited(_liveLevelSubscription?.cancel());

    unawaited(_player.stop());
    unawaited(_player.dispose());
    unawaited(_recorder.dispose());
    super.dispose();
  }

  Future<Directory> _ensureOutputRoot() async {
    final existing = _outputRoot;
    if (existing != null) {
      return existing;
    }

    final temp = await getTemporaryDirectory();
    final root = Directory(
      '${temp.path}${Platform.pathSeparator}speech_utils_example',
    );
    await root.create(recursive: true);

    _outputRoot = root;
    _appendLog('Output root: ${root.path}');
    return root;
  }

  Future<void> _detectAvailableAacEncoder() async {
    AacEncoder? selected;
    var label = 'Not available';

    try {
      if (await _nativeAacEncoder.isAvailable()) {
        selected = _nativeAacEncoder;
        label = 'Native AAC (AVFoundation)';
      } else if (await _ffmpegAacEncoder.isAvailable()) {
        selected = _ffmpegAacEncoder;
        label = 'ffmpeg AAC';
      }
    } on Object catch (error) {
      _appendLog('AAC encoder detection failed: $error');
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedAacEncoder = selected;
      _selectedAacEncoderLabel = label;
      if (selected == null) {
        _autoConvertSnippets = false;
        _convertWholeRecordingWhenStopped = false;
      }
    });
  }

  void _appendLog(String message) {
    final timestamp = DateTime.now().toIso8601String();
    if (!mounted) {
      return;
    }

    setState(() {
      _logs.insert(0, '[$timestamp] $message');
      if (_logs.length > 300) {
        _logs.removeRange(300, _logs.length);
      }
    });
  }

  InputDevice? _findInputDeviceById(String? id) {
    if (id == null || id.isEmpty) {
      return null;
    }
    for (final device in _inputDevices) {
      if (device.id == id) {
        return device;
      }
    }
    return null;
  }

  Future<void> _refreshInputDevices({bool logResult = true}) async {
    if (_isRefreshingInputDevices) {
      return;
    }

    if (mounted) {
      setState(() {
        _isRefreshingInputDevices = true;
      });
    }

    try {
      final devices = await _recorder.listInputDevices();
      InputDevice? selected = _selectedInputDevice;
      final previousSelectedId = selected?.id;
      if (previousSelectedId != null) {
        selected = devices
            .where((device) => device.id == previousSelectedId)
            .firstOrNull;
      }
      selected ??= devices.where((device) => device.isDefault).firstOrNull;
      selected ??= devices.isNotEmpty ? devices.first : null;

      if (!mounted) {
        return;
      }

      setState(() {
        _inputDevices = devices;
        _selectedInputDevice = selected;
        _isRefreshingInputDevices = false;
      });

      if (logResult) {
        final selectedLabel = selected?.label ?? 'System default';
        _appendLog(
          'Detected ${devices.length} input device(s). Active: $selectedLabel.',
        );
      }
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isRefreshingInputDevices = false;
      });
      _appendLog('Failed to list input devices: $error');
    }
  }

  void _selectInputDeviceById(String? id) {
    if (_isLiveStreaming) {
      return;
    }

    final next = _findInputDeviceById(id);

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedInputDevice = next;
    });

    final label = next?.label ?? 'System default';
    if (_supportsInputSelection) {
      _appendLog('Input device changed to $label.');
      return;
    }
    _appendLog(
      'Input device preview set to $label. Live capture still uses system default on this platform.',
    );
  }

  void _setTenVadPreset(_TenVadPreset preset) {
    _tenVadPreset = preset;
    switch (preset) {
      case _TenVadPreset.sensitive:
        _tenVadThreshold = 0.35;
      case _TenVadPreset.balanced:
        _tenVadThreshold = 0.45;
      case _TenVadPreset.strict:
        _tenVadThreshold = 0.60;
    }
  }

  String _tenVadPresetLabel(_TenVadPreset preset) {
    return switch (preset) {
      _TenVadPreset.sensitive => 'Sensitive',
      _TenVadPreset.balanced => 'Balanced',
      _TenVadPreset.strict => 'Strict',
    };
  }

  SpeechVadConfig _buildSpeechVadConfig({required bool preferTenVad}) {
    final energy = EnergyVadConfig(
      primaryRmsThreshold: _energyPrimaryRmsThreshold,
      secondaryRmsThreshold: _energySecondaryRmsThreshold,
      minZeroCrossingRate: _energyMinZeroCrossingRate,
    );
    if (preferTenVad) {
      return SpeechVadConfig.preferTen(
        ten: TenVadConfig(threshold: _tenVadThreshold),
        energy: energy,
      );
    }
    return SpeechVadConfig.energyOnly(energy: energy);
  }

  (_VadPair, String) _createVadPair({required bool preferTenVad}) {
    final vadConfig = _buildSpeechVadConfig(preferTenVad: preferTenVad);
    final splitResolved = SpeechUtils.resolveVadBackend(
      options: _splitOptions,
      config: vadConfig,
    );
    final detectResolved = SpeechUtils.resolveVadBackend(
      options: _splitOptions,
      config: vadConfig,
    );

    return (
      _VadPair(
        splitter: splitResolved.backend,
        detector: detectResolved.backend,
      ),
      splitResolved.label,
    );
  }

  Future<void> _runSyntheticChecks() async {
    if (_isRunningSyntheticChecks || _isLiveStreaming) {
      return;
    }

    setState(() {
      _isRunningSyntheticChecks = true;
    });

    final outputRoot = await _ensureOutputRoot();
    final runDir = Directory(
      '${outputRoot.path}${Platform.pathSeparator}synthetic_${DateTime.now().millisecondsSinceEpoch}',
    );
    await runDir.create(recursive: true);
    _appendLog('Running synthetic checks in ${runDir.path}');

    final samples = _buildExamplePcm(_splitOptions.sampleRateHz);
    final sourceBytes = Uint8List.view(samples.buffer);
    final sourcePcmPath =
        '${runDir.path}${Platform.pathSeparator}source_input.pcm';
    await File(sourcePcmPath).writeAsBytes(sourceBytes, flush: true);

    final vadPairAndLabel = _createVadPair(preferTenVad: true);
    final vadPair = vadPairAndLabel.$1;
    final vadLabel = vadPairAndLabel.$2;

    _appendLog('Synthetic backend: $vadLabel');

    try {
      final batchSnippets = SpeechUtils.splitPcm16OnSilence(
        pcm16leBytes: sourceBytes,
        options: _splitOptions,
        vadBackend: vadPair.splitter,
      );
      _appendLog('splitPcm16OnSilence -> ${batchSnippets.length} snippets');

      final streamSnippets = await SpeechUtils.splitPcm16StreamOnSilence(
        pcm16leStream: _chunkedPcmStream(sourceBytes, chunkByteSize: 333),
        options: _splitOptions,
        vadBackend: vadPair.splitter,
      ).toList();
      _appendLog(
        'splitPcm16StreamOnSilence -> ${streamSnippets.length} snippets',
      );

      final wavDir = Directory(
        '${runDir.path}${Platform.pathSeparator}wav_snippets',
      );
      final wavFiles = await SpeechUtils.splitPcm16AndWriteWavSnippets(
        pcm16leBytes: sourceBytes,
        options: _splitOptions,
        outputDirectory: wavDir,
        vadBackend: vadPair.splitter,
        filePrefix: 'speech',
      );
      _appendLog('splitPcm16AndWriteWavSnippets -> ${wavFiles.length} files');

      final encoder = _selectedAacEncoder;
      if (encoder != null) {
        final aacDir = Directory(
          '${runDir.path}${Platform.pathSeparator}aac_snippets',
        );
        final aacFiles = await SpeechUtils.splitPcm16AndEncodeAacSnippets(
          pcm16leBytes: sourceBytes,
          options: _splitOptions,
          outputDirectory: aacDir,
          vadBackend: vadPair.splitter,
          encoder: encoder,
          filePrefix: 'speech',
          fileExtension: 'm4a',
        );
        _appendLog(
          'splitPcm16AndEncodeAacSnippets -> ${aacFiles.length} files',
        );

        final fromBytesPath =
            '${runDir.path}${Platform.pathSeparator}single_from_bytes.m4a';
        final encodeStopwatch = Stopwatch()..start();
        await encoder.encodePcm16BytesToAac(
          pcm16leBytes: sourceBytes,
          sampleRateHz: _splitOptions.sampleRateHz,
          channelCount: _splitOptions.channelCount,
          outputPath: fromBytesPath,
          bitrateKbps: _bitrateKbps ?? 48,
        );
        _appendLog(
          'encodePcm16BytesToAac -> $fromBytesPath (${encodeStopwatch.elapsedMilliseconds} ms)',
        );

        final fromPcmPath =
            '${runDir.path}${Platform.pathSeparator}single_from_pcm_file.m4a';
        encodeStopwatch.reset();
        await encoder.encodePcm16FileToAac(
          inputPath: sourcePcmPath,
          sampleRateHz: _splitOptions.sampleRateHz,
          channelCount: _splitOptions.channelCount,
          outputPath: fromPcmPath,
          bitrateKbps: _bitrateKbps ?? 48,
        );
        _appendLog(
          'encodePcm16FileToAac -> $fromPcmPath (${encodeStopwatch.elapsedMilliseconds} ms)',
        );

        if (wavFiles.isNotEmpty) {
          final fromWavPath =
              '${runDir.path}${Platform.pathSeparator}single_from_wav_file.m4a';
          encodeStopwatch.reset();
          await encoder.encodeAudioFileToAac(
            inputPath: wavFiles.first.path,
            outputPath: fromWavPath,
            bitrateKbps: _bitrateKbps ?? 48,
          );
          _appendLog(
            'encodeAudioFileToAac -> $fromWavPath (${encodeStopwatch.elapsedMilliseconds} ms)',
          );
        }
      } else {
        _appendLog('No AAC encoder available. Skipped AAC checks.');
      }
    } on Object catch (error) {
      _appendLog('Synthetic check failed: $error');
    } finally {
      vadPair.splitter.dispose();
      vadPair.detector.dispose();
      if (mounted) {
        setState(() {
          _isRunningSyntheticChecks = false;
        });
      }
    }
  }

  Future<void> _startLiveStream() async {
    if (_isLiveStreaming || _isRunningSyntheticChecks) {
      return;
    }

    var hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      hasPermission = await _recorder.requestPermission();
    }
    if (!hasPermission) {
      _appendLog('Microphone permission denied.');
      return;
    }

    final outputRoot = await _ensureOutputRoot();
    final liveDir = Directory(
      '${outputRoot.path}${Platform.pathSeparator}live_${DateTime.now().millisecondsSinceEpoch}',
    );
    await liveDir.create(recursive: true);

    final vadConfig = _buildSpeechVadConfig(preferTenVad: _preferTenVadForLive);
    final inputDeviceId = _supportsInputSelection
        ? ((_selectedInputDevice?.isDefault ?? true)
              ? null
              : _selectedInputDevice?.id)
        : null;
    final processingController = _processingController;
    final processingConfig = processingController.buildProcessingConfig();
    final iosConfig = processingController.buildIosRecorderConfig();
    final macosConfig = processingController.buildMacosRecorderConfig();
    late final VadCaptureSession capture;
    try {
      capture = await _recorder.startVadCapture(
        VadCaptureRequest(
          split: _splitOptions,
          audio: AudioRecorderConfig(
            sampleRateHz: _sampleRateHz ?? 16000,
            channelCount: _channelCount,
            framesPerChunk: 256,
            inputDeviceId: inputDeviceId,
            processing: processingConfig,
            iosConfig: iosConfig,
            macosConfig: macosConfig,
            encoding: const AudioEncodingConfig(encoder: AudioEncoder.wav),
          ),
          vad: vadConfig,
          telemetry: const VadCaptureTelemetryConfig(
            speechHoldDuration: _speechHoldDuration,
          ),
          output: VadCaptureOutputConfig(
            outputDirectory: liveDir,
            segmentEncoding: const AudioEncodingConfig(
              encoder: AudioEncoder.wav,
            ),
            emitFullRecordingOnStop: true,
            fullRecordingFileStem: 'recording_full',
            fullRecordingEncoding: const AudioEncodingConfig(
              encoder: AudioEncoder.wav,
            ),
          ),
          pollInterval: const Duration(milliseconds: 10),
          readSampleCapacity: 4096,
        ),
      );
    } on Object catch (error) {
      _appendLog('Failed to start live recording: $error');
      return;
    }

    _liveCaptureSession = capture;
    _liveOutputDir = liveDir;
    final activeInputLabel = _supportsInputSelection
        ? (_selectedInputDevice?.label ?? 'System default')
        : (_inputDevices
                  .where((device) => device.isDefault)
                  .firstOrNull
                  ?.label ??
              'System default');
    _appendLog(
      'Live stream started (${capture.backendLabel}) using "$activeInputLabel".',
    );
    if (_preferTenVadForLive) {
      _appendLog(
        'TEN config: preset=${_tenVadPresetLabel(_tenVadPreset)}, '
        'threshold=${_tenVadThreshold.toStringAsFixed(2)}',
      );
    }
    if (!capture.backendLabel.startsWith('TEN VAD')) {
      _appendLog(
        'Energy thresholds: primary=${_energyPrimaryRmsThreshold.toStringAsFixed(4)}, '
        'secondary=${_energySecondaryRmsThreshold.toStringAsFixed(4)}, '
        'zcr=${_energyMinZeroCrossingRate.toStringAsFixed(3)}',
      );
    }
    _appendLog(
      'Processing: preset=${processingController.capturePresetLabel}, ${processingController.processingSummary()}.',
    );

    _liveSegmentSubscription = capture.segments.listen(
      (segment) {
        unawaited(_onLiveSegment(segment));
      },
      onError: (Object error, StackTrace stackTrace) {
        _appendLog('Live segment stream error: $error');
      },
      cancelOnError: false,
    );

    _liveSpeechStateSubscription = capture.speechStates.listen(
      (state) {
        if (!mounted) {
          return;
        }
        setState(() {
          _speechDetected = state.speechDetected;
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        _appendLog('Live speech-state stream error: $error');
      },
      cancelOnError: false,
    );

    _liveLevelSubscription = capture.levels.listen(
      (level) {
        if (!mounted) {
          return;
        }
        setState(() {
          _liveChunkCount++;
          final waveformLevel = SpeechAmplitudeUtils.normalizeDbfsForWaveform(
            level.dbfs,
            sensitivity: SpeechAmplitudeUtils.defaultSensitivity,
          );
          _waveformSamples.add(waveformLevel);
          if (_waveformSamples.length > _waveformLimit) {
            _waveformSamples.removeRange(
              0,
              _waveformSamples.length - _waveformLimit,
            );
          }
          _currentRms = level.rms;
          _currentDbfs = level.dbfs;
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        _appendLog('Live level stream error: $error');
      },
      cancelOnError: false,
    );

    _recordingStopwatch
      ..reset()
      ..start();
    _recordingTicker?.cancel();
    _recordingTicker = Timer.periodic(const Duration(milliseconds: 160), (_) {
      if (!mounted || !_isLiveStreaming) {
        return;
      }
      setState(() {
        _recordingDuration = _recordingStopwatch.elapsed;
      });
    });

    if (!mounted) {
      return;
    }

    setState(() {
      _isLiveStreaming = true;
      _speechDetected = false;
      _activeVadLabel = capture.backendLabel;
      _liveSnippetCount = 0;
      _liveChunkCount = 0;
      _recordingDuration = Duration.zero;
      _currentRms = 0;
      _currentDbfs = -160;
      _waveformSamples.clear();
      _snippets.clear();
      _fullRecordingWavPath = null;
      _fullRecordingWavBytes = null;
      _fullRecordingAacPath = null;
      _fullRecordingAacBytes = null;
      _fullRecordingAacLatencyMs = null;
      _fullRecordingWavMetadata = null;
      _fullRecordingAacMetadata = null;
    });

    _streamHealthTimer?.cancel();
    _streamHealthTimer = Timer(const Duration(seconds: 2), () {
      if (!_isLiveStreaming || _liveChunkCount > 0) {
        return;
      }
      _appendLog(
        'No PCM chunks received after 2s. Check microphone routing/permissions on this device.',
      );
    });
  }

  Future<void> _onLiveSegment(VoiceSegment segment) async {
    final wavPath = segment.file.path;
    if (wavPath.isEmpty) {
      return;
    }

    final nextIndex = _liveSnippetCount + 1;
    final wavBytes = await File(wavPath).length();

    if (!mounted) {
      return;
    }

    final artifact = _SnippetArtifact(
      id: nextIndex,
      duration: segment.metadata.duration,
      wavPath: wavPath,
      wavBytes: wavBytes,
      aacPath: null,
      aacBytes: null,
      aacLatencyMs: null,
      conversionInProgress: _autoConvertSnippets && _selectedAacEncoder != null,
      wavMetadata: segment.metadata,
    );

    setState(() {
      _liveSnippetCount = nextIndex;
      _snippets.insert(0, artifact);
    });

    _appendLog(
      'Snippet #$nextIndex finished (${segment.metadata.duration.inMilliseconds} ms, WAV ${_formatBytes(wavBytes)}).',
    );

    final encoder = _selectedAacEncoder;
    final outputDir = _liveOutputDir;
    if (_autoConvertSnippets && encoder != null) {
      if (outputDir == null) {
        return;
      }
      final aacPath =
          '${outputDir.path}${Platform.pathSeparator}snippet_${nextIndex.toString().padLeft(3, '0')}.m4a';

      try {
        final watch = Stopwatch()..start();
        await encoder.encodeAudioFileToAac(
          inputPath: wavPath,
          outputPath: aacPath,
          bitrateKbps: _bitrateKbps ?? 48,
        );
        watch.stop();

        final aacBytes = await File(aacPath).length();
        final aacLatencyMs = watch.elapsedMilliseconds;
        final aacMetadata = await _readNativeMetadataAsync(aacPath);
        final wavMetadata = await _readNativeMetadataAsync(wavPath);

        _updateSnippet(
          nextIndex,
          (item) => item.copyWith(
            aacPath: aacPath,
            aacBytes: aacBytes,
            aacLatencyMs: aacLatencyMs,
            conversionInProgress: false,
            aacMetadata: aacMetadata,
            wavMetadata: wavMetadata,
          ),
        );

        _appendLog(
          'Snippet #$nextIndex AAC ready (${_formatBytes(aacBytes)}, ${_sizeChangeLabel(original: wavBytes, compressed: aacBytes)}, ${watch.elapsedMilliseconds} ms latency).',
        );
      } on Object catch (error) {
        final wavMetadata = await _readNativeMetadataAsync(wavPath);
        _updateSnippet(
          nextIndex,
          (item) => item.copyWith(
            conversionInProgress: false,
            wavMetadata: wavMetadata,
          ),
        );
        _appendLog('Snippet #$nextIndex AAC conversion failed: $error');
      }
    } else {
      final wavMetadata = await _readNativeMetadataAsync(wavPath);
      _updateSnippet(
        nextIndex,
        (item) => item.copyWith(
          conversionInProgress: false,
          wavMetadata: wavMetadata,
        ),
      );
    }
  }

  void _updateSnippet(
    int id,
    _SnippetArtifact Function(_SnippetArtifact) update,
  ) {
    if (!mounted) {
      return;
    }

    setState(() {
      final index = _snippets.indexWhere((item) => item.id == id);
      if (index == -1) {
        return;
      }
      _snippets[index] = update(_snippets[index]);
    });
  }

  Future<void> _stopLiveStream({bool internalDispose = false}) async {
    if (!_isLiveStreaming && !internalDispose) {
      return;
    }

    final capture = _liveCaptureSession;
    _liveCaptureSession = null;
    VadCaptureStopResult? stopResult;
    try {
      if (capture != null) {
        stopResult = await capture.stop();
      } else {
        await _recorder.stop();
      }
    } on Object catch (error) {
      _appendLog('Stop recording failed: $error');
    }

    await _liveSegmentSubscription?.cancel();
    await _liveSpeechStateSubscription?.cancel();
    await _liveLevelSubscription?.cancel();
    _cleanupLiveState();

    await _finalizeWholeRecordingArtifacts(
      fullRecording: stopResult?.fullRecording,
    );

    if (!internalDispose) {
      _appendLog('Live stream stopped.');
    }
  }

  void _cleanupLiveState() {
    _recordingTicker?.cancel();
    _streamHealthTimer?.cancel();
    _recordingStopwatch.stop();

    _liveSegmentSubscription = null;
    _liveSpeechStateSubscription = null;
    _liveLevelSubscription = null;

    if (!mounted) {
      return;
    }

    setState(() {
      _isLiveStreaming = false;
      _speechDetected = false;
      _recordingDuration = _recordingStopwatch.elapsed;
      _liveChunkCount = 0;
      _currentRms = 0;
      _currentDbfs = -160;
    });
  }

  Future<void> _finalizeWholeRecordingArtifacts({
    required VadRecordingArtifact? fullRecording,
  }) async {
    final sessionDir = _liveOutputDir;

    _liveOutputDir = null;

    if (fullRecording == null || sessionDir == null) {
      return;
    }

    final wavPath = fullRecording.file.path;
    final wavBytes = await File(wavPath).length();

    String? aacPath;
    int? aacBytes;
    int? aacLatencyMs;
    AudioMetadata? wavMetadata = fullRecording.metadata;
    AudioMetadata? aacMetadata;

    final encoder = _selectedAacEncoder;
    if (_convertWholeRecordingWhenStopped && encoder != null) {
      aacPath = '${sessionDir.path}${Platform.pathSeparator}recording_full.m4a';
      try {
        final watch = Stopwatch()..start();
        await encoder.encodeAudioFileToAac(
          inputPath: wavPath,
          outputPath: aacPath,
          bitrateKbps: _bitrateKbps ?? 48,
        );
        aacLatencyMs = watch.elapsedMilliseconds;
        aacBytes = await File(aacPath).length();
      } on Object catch (error) {
        _appendLog('Whole-recording AAC conversion failed: $error');
        aacPath = null;
        aacBytes = null;
        aacLatencyMs = null;
      }
    }

    wavMetadata = await _readNativeMetadataAsync(wavPath) ?? wavMetadata;
    if (aacPath != null) {
      aacMetadata = await _readNativeMetadataAsync(aacPath);
    }

    if (mounted) {
      setState(() {
        _fullRecordingWavPath = wavPath;
        _fullRecordingWavBytes = wavBytes;
        _fullRecordingWavMetadata = wavMetadata;
        _fullRecordingAacPath = aacPath;
        _fullRecordingAacBytes = aacBytes;
        _fullRecordingAacLatencyMs = aacLatencyMs;
        _fullRecordingAacMetadata = aacMetadata;
      });
      _appendLog(
        'Recording saved. WAV: ${_formatBytes(wavBytes)}. '
        '${aacBytes != null ? 'AAC: ${_formatBytes(aacBytes)} in ${aacLatencyMs}ms' : 'AAC not generated.'}',
      );
    }
  }

  Future<void> _togglePlayback(String path) async {
    if (_playingPath == path) {
      await _player.stop();
      if (!mounted) {
        return;
      }
      setState(() {
        _playingPath = null;
      });
      return;
    }

    try {
      await _player.stop();
      await _player.play(DeviceFileSource(path));
      if (!mounted) {
        return;
      }
      setState(() {
        _playingPath = path;
      });
    } on Object catch (error) {
      _appendLog('Playback failed ($path): $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Integrated VAD + Compression'),
        actions: [
          ThemeActionButton(
            themeMode: _themeMode,
            onThemeModeChanged: (mode) {
              setState(() {
                _themeMode = mode;
              });
              widget.onThemeModeChanged(mode);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;

          final mainContent = [
            _buildStatusCard(theme),
            const SizedBox(height: 12),
            if (!isWide) ...[
              _buildOptionsCard(theme),
              const SizedBox(height: 12),
            ],
            _buildControlButtons(),
            const SizedBox(height: 12),
            _buildFullRecordingCard(theme),
            const SizedBox(height: 12),
            _buildSnippetListCard(theme),
            const SizedBox(height: 12),
            _buildLogCard(theme),
          ];

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: mainContent,
                  ),
                ),
                Container(
                  width: 320,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [_buildOptionsCard(theme)],
                  ),
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: mainContent,
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    final indicatorColor = _speechDetected
        ? Colors.green
        : theme.colorScheme.outline;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isLiveStreaming ? Icons.mic : Icons.mic_none,
                  color: _isLiveStreaming
                      ? Colors.redAccent
                      : theme.colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Text(
                  _isLiveStreaming ? 'Recording' : 'Idle',
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  _formatDuration(_recordingDuration),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('VAD: $_activeVadLabel')),
                Chip(
                  avatar: Icon(
                    Icons.graphic_eq,
                    color: indicatorColor,
                    size: 18,
                  ),
                  label: Text(_speechDetected ? 'Speech detected' : 'Silence'),
                ),
                Chip(label: Text('Snippets: $_liveSnippetCount')),
                Chip(label: Text('Chunks: $_liveChunkCount')),
                Chip(label: Text('RMS: ${_currentRms.toStringAsFixed(3)}')),
                Chip(label: Text('dBFS: ${_currentDbfs.toStringAsFixed(1)}')),
              ],
            ),
            const SizedBox(height: 10),
            LiveWaveformPanel(
              samples: _waveformSamples,
              isActive: _isLiveStreaming,
              speechDetected: _speechDetected,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsCard(ThemeData theme) {
    final encoderAvailable = _selectedAacEncoder != null;
    final tenAvailable = TenVadFfiBackend.supportsCurrentPlatform;
    final canEditVad = !_isLiveStreaming;
    final selectedDeviceId = _selectedInputDevice?.id;
    final defaultDevice = _inputDevices
        .where((device) => device.isDefault)
        .firstOrNull;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Input', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              _supportsInputSelection
                  ? 'Choose which microphone route should be used for live capture.'
                  : 'Input listing is available. Selection is preview-only; live capture follows the system default on this platform.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ExampleDropdownFormField<String?>(
                    initialValue: selectedDeviceId,
                    decoration: const InputDecoration(
                      labelText: 'Input device',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    options: <ExampleDropdownOption<String?>>[
                      const ExampleDropdownOption<String?>(
                        value: null,
                        label: 'System default',
                      ),
                      ..._inputDevices.map(
                        (device) => ExampleDropdownOption<String?>(
                          value: device.id,
                          label: device.isDefault
                              ? '${device.label} (Default)'
                              : device.label,
                        ),
                      ),
                    ],
                    onChanged: canEditVad ? _selectInputDeviceById : null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Refresh inputs',
                  onPressed: _isRefreshingInputDevices || _isLiveStreaming
                      ? null
                      : () => unawaited(_refreshInputDevices()),
                  icon: _isRefreshingInputDevices
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _supportsInputSelection
                  ? 'Detected: ${_inputDevices.length} devices.'
                  : 'System default: ${defaultDevice?.label ?? 'System input'} (selection preview only).',
              style: theme.textTheme.bodySmall,
            ),
            const Divider(height: 24),
            Text('AAC options', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Encoder: $_selectedAacEncoderLabel',
              style: theme.textTheme.bodyMedium,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _autoConvertSnippets,
              onChanged: encoderAvailable
                  ? (value) {
                      setState(() {
                        _autoConvertSnippets = value;
                      });
                    }
                  : null,
              title: const Text('Auto-convert snippets to AAC'),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _convertWholeRecordingWhenStopped,
              onChanged: encoderAvailable
                  ? (value) {
                      setState(() {
                        _convertWholeRecordingWhenStopped = value;
                      });
                    }
                  : null,
              title: const Text('Convert whole recording on stop'),
            ),
            const Divider(height: 24),
            Text('Audio Config', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ExampleDropdownFormField<int?>(
              initialValue: _sampleRateHz,
              decoration: const InputDecoration(
                labelText: 'Sample Rate',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              options: const [
                ExampleDropdownOption(value: null, label: '-- Auto --'),
                ExampleDropdownOption(value: 8000, label: '8000 Hz'),
                ExampleDropdownOption(value: 16000, label: '16000 Hz'),
                ExampleDropdownOption(value: 32000, label: '32000 Hz'),
                ExampleDropdownOption(value: 44100, label: '44100 Hz'),
                ExampleDropdownOption(value: 48000, label: '48000 Hz'),
              ],
              onChanged: _isLiveStreaming
                  ? null
                  : (val) {
                      setState(() {
                        _sampleRateHz = val;
                      });
                    },
            ),
            const SizedBox(height: 12),
            ExampleDropdownFormField<int>(
              initialValue: _channelCount,
              decoration: const InputDecoration(
                labelText: 'Channels',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              options: const [
                ExampleDropdownOption(value: 1, label: '1 (Mono)'),
                ExampleDropdownOption(value: 2, label: '2 (Stereo)'),
              ],
              onChanged: _isLiveStreaming
                  ? null
                  : (val) {
                      if (val != null) {
                        setState(() {
                          _channelCount = val;
                        });
                      }
                    },
            ),
            const SizedBox(height: 12),
            ExampleDropdownFormField<int?>(
              initialValue: _bitrateKbps,
              decoration: const InputDecoration(
                labelText: 'Bitrate (kbps)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              options: const [
                ExampleDropdownOption(value: null, label: '-- Auto --'),
                ExampleDropdownOption(value: 32, label: '32 kbps'),
                ExampleDropdownOption(value: 48, label: '48 kbps'),
                ExampleDropdownOption(value: 64, label: '64 kbps'),
                ExampleDropdownOption(value: 128, label: '128 kbps'),
              ],
              onChanged: _isLiveStreaming
                  ? null
                  : (val) {
                      setState(() {
                        _bitrateKbps = val;
                      });
                    },
            ),
            const Divider(height: 24),
            AudioProcessingCard(
              controller: _processingController,
              enabled: !_isLiveStreaming,
              onChanged: (controller) {
                setState(() {
                  _processingController = controller;
                });
              },
            ),
            const Divider(height: 24),
            Text('VAD tuning', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              canEditVad
                  ? 'Threshold changes apply to the next live recording.'
                  : 'Stop recording to adjust VAD thresholds.',
              style: theme.textTheme.bodySmall,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _preferTenVadForLive,
              onChanged: tenAvailable && canEditVad
                  ? (value) {
                      setState(() {
                        _preferTenVadForLive = value;
                      });
                    }
                  : null,
              title: const Text('Use TEN VAD for live recording'),
              subtitle: Text(
                tenAvailable
                    ? 'If disabled, uses a more tolerant Energy VAD.'
                    : 'TEN VAD not bundled for this runtime target.',
              ),
            ),
            if (_preferTenVadForLive)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: ExampleDropdownFormField<_TenVadPreset>(
                  initialValue: _tenVadPreset,
                  decoration: const InputDecoration(
                    labelText: 'TEN preset',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  options: _TenVadPreset.values
                      .map(
                        (preset) => ExampleDropdownOption<_TenVadPreset>(
                          value: preset,
                          label: _tenVadPresetLabel(preset),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: tenAvailable && canEditVad
                      ? (preset) {
                          if (preset == null) {
                            return;
                          }
                          setState(() {
                            _setTenVadPreset(preset);
                          });
                        }
                      : null,
                ),
              ),
            if (_preferTenVadForLive)
              _buildTuningSlider(
                label: 'TEN threshold',
                value: _tenVadThreshold,
                min: 0.05,
                max: 0.95,
                divisions: 90,
                enabled: tenAvailable && canEditVad,
                onChanged: (value) {
                  setState(() {
                    _tenVadThreshold = value;
                  });
                },
              )
            else ...[
              _buildTuningSlider(
                label: 'Energy primary RMS',
                value: _energyPrimaryRmsThreshold,
                min: 0.0010,
                max: 0.0200,
                divisions: 190,
                enabled: canEditVad,
                onChanged: (value) {
                  setState(() {
                    _energyPrimaryRmsThreshold = value;
                  });
                },
              ),
              _buildTuningSlider(
                label: 'Energy secondary RMS',
                value: _energySecondaryRmsThreshold,
                min: 0.0005,
                max: 0.0150,
                divisions: 145,
                enabled: canEditVad,
                onChanged: (value) {
                  setState(() {
                    _energySecondaryRmsThreshold = value;
                  });
                },
              ),
              _buildTuningSlider(
                label: 'Energy min zero-crossing rate',
                value: _energyMinZeroCrossingRate,
                min: 0.0,
                max: 0.20,
                divisions: 200,
                enabled: canEditVad,
                onChanged: (value) {
                  setState(() {
                    _energyMinZeroCrossingRate = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTuningSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required bool enabled,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${value.toStringAsFixed(4)}'),
          Slider(
            value: value.clamp(min, max).toDouble(),
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(4),
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          onPressed: _isRunningSyntheticChecks || _isLiveStreaming
              ? null
              : _runSyntheticChecks,
          icon: const Icon(Icons.science),
          label: Text(
            _isRunningSyntheticChecks
                ? 'Running synthetic checks...'
                : 'Run Synthetic API Checks',
          ),
        ),
        FilledButton.icon(
          onPressed: _isRunningSyntheticChecks
              ? null
              : (_isLiveStreaming ? _stopLiveStream : _startLiveStream),
          icon: Icon(_isLiveStreaming ? Icons.stop : Icons.mic),
          label: Text(
            _isLiveStreaming ? 'Stop Live Stream' : 'Start Live Stream',
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {
            if (!mounted) {
              return;
            }
            setState(() {
              _logs.clear();
            });
          },
          icon: const Icon(Icons.clear_all),
          label: const Text('Clear Log'),
        ),
      ],
    );
  }

  Future<AudioMetadata?> _readNativeMetadataAsync(String path) async {
    try {
      final reader = NativeAudioMetadataReader();
      if (await reader.isAvailable()) {
        return await reader.readAudioMetadata(inputPath: path);
      }
    } catch (_) {}
    return null;
  }

  void _showMetadataDialog({
    required BuildContext context,
    required String title,
    required String wavPath,
    required int wavBytes,
    required AudioMetadata? wavMetadata,
    String? aacPath,
    int? aacBytes,
    int? aacLatencyMs,
    AudioMetadata? aacMetadata,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                const SizedBox(height: 8),
                Text(
                  'WAV Format',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'File: ${wavPath.split(Platform.pathSeparator).last}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Size: ${_formatBytes(wavBytes)}',
                  style: const TextStyle(fontSize: 12),
                ),
                _buildMetadataRows(wavMetadata),
                if (aacPath != null) ...[
                  const Divider(),
                  Text(
                    'AAC Format',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'File: ${aacPath.split(Platform.pathSeparator).last}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (aacBytes != null)
                    Text(
                      'Size: ${_formatBytes(aacBytes)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  if (aacLatencyMs != null)
                    Text(
                      'Encode Time: ${aacLatencyMs}ms',
                      style: const TextStyle(fontSize: 12),
                    ),
                  _buildMetadataRows(aacMetadata),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetadataRows(AudioMetadata? metadata) {
    if (metadata == null) {
      return const Text(
        'Native Metadata: Unavailable\n',
        style: TextStyle(fontSize: 12),
      );
    }
    final bitrateDesc = metadata.bitrateBps != null
        ? '${metadata.bitrateBps! ~/ 1000} kbps'
        : 'Unknown';
    final sampleRateDesc = metadata.sampleRateHz != null
        ? '${metadata.sampleRateHz} Hz'
        : 'Unknown';
    final channelsDesc = metadata.channelCount != null
        ? '${metadata.channelCount} ch'
        : 'Unknown';
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Duration: ${metadata.duration.inMilliseconds} ms',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            'Config: $sampleRateDesc, $channelsDesc, $bitrateDesc',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            'Engine: ${metadata.codec ?? 'Unknown'} ${metadata.codecProfile ?? ''} (${metadata.containerFormat ?? 'Unknown'})',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFullRecordingCard(ThemeData theme) {
    final wavPath = _fullRecordingWavPath;
    if (wavPath == null) {
      return const SizedBox.shrink();
    }

    final wavBytes = _fullRecordingWavBytes ?? 0;
    final aacPath = _fullRecordingAacPath;
    final aacBytes = _fullRecordingAacBytes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Whole recording',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _showMetadataDialog(
                    context: context,
                    title: 'Whole Recording Metadata',
                    wavPath: wavPath,
                    wavBytes: wavBytes,
                    wavMetadata: _fullRecordingWavMetadata,
                    aacPath: aacPath,
                    aacBytes: aacBytes,
                    aacLatencyMs: _fullRecordingAacLatencyMs,
                    aacMetadata: _fullRecordingAacMetadata,
                  ),
                  tooltip: 'View Metadata',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('WAV: ${_formatBytes(wavBytes)}'),
            if (aacBytes != null)
              Text(
                'AAC: ${_formatBytes(aacBytes)} (${_sizeChangeLabel(original: wavBytes, compressed: aacBytes)})'
                '${_fullRecordingAacLatencyMs != null ? ' in ${_fullRecordingAacLatencyMs}ms' : ''}',
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _togglePlayback(wavPath),
                  icon: Icon(
                    _playingPath == wavPath ? Icons.stop : Icons.play_arrow,
                  ),
                  label: const Text('Play WAV'),
                ),
                if (aacPath != null)
                  OutlinedButton.icon(
                    onPressed: () => _togglePlayback(aacPath),
                    icon: Icon(
                      _playingPath == aacPath ? Icons.stop : Icons.play_arrow,
                    ),
                    label: const Text('Play AAC'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnippetListCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Finished snippets', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_snippets.isEmpty)
              Text(
                'No snippets yet. Start recording and speak.',
                style: theme.textTheme.bodyMedium,
              ),
            if (_snippets.isNotEmpty)
              ..._snippets.map((snippet) {
                final aacLabel = snippet.aacBytes == null
                    ? (snippet.conversionInProgress
                          ? 'AAC: converting...'
                          : 'AAC: not converted')
                    : 'AAC: ${_formatBytes(snippet.aacBytes!)} '
                          '(${_sizeChangeLabel(original: snippet.wavBytes, compressed: snippet.aacBytes!)})'
                          '${snippet.aacLatencyMs != null ? ' in ${snippet.aacLatencyMs}ms' : ''}';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Snippet #${snippet.id} • ${snippet.duration.inMilliseconds} ms',
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () => _showMetadataDialog(
                                  context: context,
                                  title: 'Snippet #${snippet.id} Metadata',
                                  wavPath: snippet.wavPath,
                                  wavBytes: snippet.wavBytes,
                                  wavMetadata: snippet.wavMetadata,
                                  aacPath: snippet.aacPath,
                                  aacBytes: snippet.aacBytes,
                                  aacLatencyMs: snippet.aacLatencyMs,
                                  aacMetadata: snippet.aacMetadata,
                                ),
                                tooltip: 'View Metadata',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('WAV: ${_formatBytes(snippet.wavBytes)}'),
                          Text(aacLabel),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _togglePlayback(snippet.wavPath),
                                icon: Icon(
                                  _playingPath == snippet.wavPath
                                      ? Icons.stop
                                      : Icons.play_arrow,
                                ),
                                label: const Text('Play WAV'),
                              ),
                              if (snippet.aacPath != null)
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _togglePlayback(snippet.aacPath!),
                                  icon: Icon(
                                    _playingPath == snippet.aacPath
                                        ? Icons.stop
                                        : Icons.play_arrow,
                                  ),
                                  label: const Text('Play AAC'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableRegion(
                  selectionControls: MaterialTextSelectionControls(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          _logs[index],
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _SnippetArtifact {
  const _SnippetArtifact({
    required this.id,
    required this.duration,
    required this.wavPath,
    required this.wavBytes,
    required this.aacPath,
    required this.aacBytes,
    required this.aacLatencyMs,
    required this.conversionInProgress,
    this.wavMetadata,
    this.aacMetadata,
  });

  final int id;
  final Duration duration;
  final String wavPath;
  final int wavBytes;
  final String? aacPath;
  final int? aacBytes;
  final int? aacLatencyMs;
  final bool conversionInProgress;
  final AudioMetadata? wavMetadata;
  final AudioMetadata? aacMetadata;

  _SnippetArtifact copyWith({
    String? aacPath,
    int? aacBytes,
    int? aacLatencyMs,
    bool? conversionInProgress,
    AudioMetadata? wavMetadata,
    AudioMetadata? aacMetadata,
  }) {
    return _SnippetArtifact(
      id: id,
      duration: duration,
      wavPath: wavPath,
      wavBytes: wavBytes,
      aacPath: aacPath ?? this.aacPath,
      aacBytes: aacBytes ?? this.aacBytes,
      aacLatencyMs: aacLatencyMs ?? this.aacLatencyMs,
      conversionInProgress: conversionInProgress ?? this.conversionInProgress,
      wavMetadata: wavMetadata ?? this.wavMetadata,
      aacMetadata: aacMetadata ?? this.aacMetadata,
    );
  }
}

final class _VadPair {
  const _VadPair({required this.splitter, required this.detector});

  final VadBackend splitter;
  final VadBackend detector;
}

Stream<Uint8List> _chunkedPcmStream(
  Uint8List input, {
  required int chunkByteSize,
}) async* {
  var offset = 0;
  while (offset < input.lengthInBytes) {
    final end = math.min(offset + chunkByteSize, input.lengthInBytes);
    yield Uint8List.sublistView(input, offset, end);
    offset = end;
  }
}

Int16List _buildExamplePcm(int sampleRateHz) {
  return _concatSamples([
    _tone(
      sampleRateHz: sampleRateHz,
      duration: const Duration(milliseconds: 720),
      frequencyHz: 220,
    ),
    _silence(
      sampleRateHz: sampleRateHz,
      duration: const Duration(milliseconds: 900),
    ),
    _tone(
      sampleRateHz: sampleRateHz,
      duration: const Duration(milliseconds: 840),
      frequencyHz: 260,
    ),
    _silence(
      sampleRateHz: sampleRateHz,
      duration: const Duration(milliseconds: 760),
    ),
    _tone(
      sampleRateHz: sampleRateHz,
      duration: const Duration(milliseconds: 610),
      frequencyHz: 180,
    ),
  ]);
}

Int16List _tone({
  required int sampleRateHz,
  required Duration duration,
  required double frequencyHz,
  double amplitude = 0.62,
}) {
  final sampleCount =
      (sampleRateHz * duration.inMicroseconds / Duration.microsecondsPerSecond)
          .round();
  final result = Int16List(sampleCount);

  for (var i = 0; i < sampleCount; i++) {
    final value = math.sin((2 * math.pi * frequencyHz * i) / sampleRateHz);
    result[i] = (value * amplitude * 32767).round();
  }
  return result;
}

Int16List _silence({required int sampleRateHz, required Duration duration}) {
  final sampleCount =
      (sampleRateHz * duration.inMicroseconds / Duration.microsecondsPerSecond)
          .round();
  return Int16List(sampleCount);
}

Int16List _concatSamples(List<Int16List> segments) {
  final totalLength = segments.fold<int>(
    0,
    (sum, segment) => sum + segment.length,
  );
  final result = Int16List(totalLength);
  var offset = 0;

  for (final segment in segments) {
    result.setRange(offset, offset + segment.length, segment);
    offset += segment.length;
  }

  return result;
}

String _formatBytes(int bytes) {
  const units = <String>['B', 'KB', 'MB', 'GB'];
  var value = bytes.toDouble();
  var unitIndex = 0;

  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex++;
  }

  return '${value.toStringAsFixed(unitIndex == 0 ? 0 : 2)} ${units[unitIndex]}';
}

String _sizeChangeLabel({required int original, required int compressed}) {
  if (original <= 0) {
    return 'n/a';
  }

  final delta = 1 - (compressed / original);
  final percentage = (delta * 100).toStringAsFixed(1);

  if (delta >= 0) {
    return '$percentage% smaller';
  }
  return '${percentage.replaceFirst('-', '')}% larger';
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final millis = (duration.inMilliseconds.remainder(1000) ~/ 10)
      .toString()
      .padLeft(2, '0');
  return '$minutes:$seconds.$millis';
}
