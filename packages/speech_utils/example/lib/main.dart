import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_utils/speech_utils.dart';

const _splitOptions = PauseSplitOptions(
  sampleRateHz: 16000,
  channelCount: 1,
  frameDuration: Duration(milliseconds: 16),
  minSpeechDuration: Duration(milliseconds: 140),
  minSilenceDuration: Duration(milliseconds: 700),
  preSpeechPadding: Duration(milliseconds: 80),
  postSpeechPadding: Duration(milliseconds: 120),
);

const _speechHoldDuration = Duration(milliseconds: 320);
const _waveformLimit = 220;

enum _TenVadPreset { sensitive, balanced, strict }

void main() {
  runApp(const SpeechUtilsExampleApp());
}

class SpeechUtilsExampleApp extends StatelessWidget {
  const SpeechUtilsExampleApp({super.key, this.detectAacOnStartup = true});

  final bool detectAacOnStartup;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'speech_utils Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A7A5C)),
      ),
      home: SpeechUtilsExamplePage(detectAacOnStartup: detectAacOnStartup),
    );
  }
}

class SpeechUtilsExamplePage extends StatefulWidget {
  const SpeechUtilsExamplePage({super.key, this.detectAacOnStartup = true});

  final bool detectAacOnStartup;

  @override
  State<SpeechUtilsExamplePage> createState() => _SpeechUtilsExamplePageState();
}

class _SpeechUtilsExamplePageState extends State<SpeechUtilsExamplePage> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  final NativeAacEncoder _nativeAacEncoder = NativeAacEncoder();
  final FfmpegAacEncoder _ffmpegAacEncoder = FfmpegAacEncoder();

  final List<String> _logs = <String>[];
  final List<_SnippetArtifact> _snippets = <_SnippetArtifact>[];
  final List<double> _waveformSamples = <double>[];

  Directory? _outputRoot;
  Directory? _liveOutputDir;

  StreamSubscription<Pcm16Snippet>? _liveSnippetSubscription;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  Completer<void>? _liveDone;

  VadBackend? _liveSplitVadBackend;
  VadBackend? _liveDetectionVadBackend;
  _LiveSpeechDetector? _liveSpeechDetector;

  Timer? _recordingTicker;
  Timer? _streamHealthTimer;
  final Stopwatch _recordingStopwatch = Stopwatch();

  BytesBuilder? _sessionBytes;
  DateTime? _lastSpeechAt;

  bool _isRunningSyntheticChecks = false;
  bool _isLiveStreaming = false;
  bool _speechDetected = false;
  int _liveSnippetCount = 0;
  int _liveChunkCount = 0;
  double _currentRms = 0;

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
  String? _fullRecordingAacPath;
  int? _fullRecordingAacBytes;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _playingPath = null;
      });
    });

    unawaited(_ensureOutputRoot());
    if (widget.detectAacOnStartup) {
      unawaited(_detectAvailableAacEncoder());
    }
  }

  @override
  void dispose() {
    _recordingTicker?.cancel();
    _streamHealthTimer?.cancel();
    _recordingStopwatch.stop();

    unawaited(_liveSnippetSubscription?.cancel());
    unawaited(_amplitudeSubscription?.cancel());
    _liveSplitVadBackend?.dispose();
    _liveDetectionVadBackend?.dispose();

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
        label = 'Native AAC (afconvert)';
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
        await encoder.encodePcm16BytesToAac(
          pcm16leBytes: sourceBytes,
          sampleRateHz: _splitOptions.sampleRateHz,
          channelCount: _splitOptions.channelCount,
          outputPath: fromBytesPath,
        );
        _appendLog('encodePcm16BytesToAac -> $fromBytesPath');

        final fromPcmPath =
            '${runDir.path}${Platform.pathSeparator}single_from_pcm_file.m4a';
        await encoder.encodePcm16FileToAac(
          inputPath: sourcePcmPath,
          sampleRateHz: _splitOptions.sampleRateHz,
          channelCount: _splitOptions.channelCount,
          outputPath: fromPcmPath,
        );
        _appendLog('encodePcm16FileToAac -> $fromPcmPath');

        if (wavFiles.isNotEmpty) {
          final fromWavPath =
              '${runDir.path}${Platform.pathSeparator}single_from_wav_file.m4a';
          await encoder.encodeAudioFileToAac(
            inputPath: wavFiles.first.path,
            outputPath: fromWavPath,
          );
          _appendLog('encodeAudioFileToAac -> $fromWavPath');
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

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      _appendLog('Microphone permission denied.');
      return;
    }

    final supportsPcm16 = await _recorder.isEncoderSupported(
      AudioEncoder.pcm16bits,
    );
    if (!supportsPcm16) {
      _appendLog('PCM16 stream recording is not supported on this platform.');
      return;
    }

    final outputRoot = await _ensureOutputRoot();
    final liveDir = Directory(
      '${outputRoot.path}${Platform.pathSeparator}live_${DateTime.now().millisecondsSinceEpoch}',
    );
    await liveDir.create(recursive: true);

    final vadPairAndLabel = _createVadPair(preferTenVad: _preferTenVadForLive);
    final vadPair = vadPairAndLabel.$1;
    final vadLabel = vadPairAndLabel.$2;

    late final Stream<Uint8List> micStream;
    try {
      micStream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
          streamBufferSize: 4096,
        ),
      );
    } on Object catch (error) {
      vadPair.splitter.dispose();
      vadPair.detector.dispose();
      _appendLog('Failed to start live recording: $error');
      return;
    }

    _liveOutputDir = liveDir;
    _liveSplitVadBackend = vadPair.splitter;
    _liveDetectionVadBackend = vadPair.detector;
    _liveSpeechDetector = _LiveSpeechDetector(
      options: _splitOptions,
      vadBackend: vadPair.detector,
    );

    _sessionBytes = BytesBuilder(copy: false);
    _lastSpeechAt = null;

    final tappedStream = micStream.map((chunk) {
      _onRawMicChunk(chunk);
      return chunk;
    });

    final snippets = SpeechUtils.splitPcm16StreamOnSilence(
      pcm16leStream: tappedStream,
      options: _splitOptions,
      vadBackend: vadPair.splitter,
    );

    final liveDone = Completer<void>();
    _liveDone = liveDone;

    _liveSnippetSubscription = snippets.listen(
      (snippet) => unawaited(_onLiveSnippet(snippet)),
      onError: (Object error, StackTrace stackTrace) {
        _appendLog('Live stream error: $error');
        _cleanupLiveState();
        if (!liveDone.isCompleted) {
          liveDone.complete();
        }
      },
      onDone: () {
        _appendLog('Live stream closed.');
        _cleanupLiveState();
        if (!liveDone.isCompleted) {
          liveDone.complete();
        }
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
      _activeVadLabel = vadLabel;
      _liveSnippetCount = 0;
      _liveChunkCount = 0;
      _recordingDuration = Duration.zero;
      _currentRms = 0;
      _waveformSamples.clear();
      _snippets.clear();
      _fullRecordingWavPath = null;
      _fullRecordingWavBytes = null;
      _fullRecordingAacPath = null;
      _fullRecordingAacBytes = null;
    });

    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 120))
        .listen((amplitude) {
          if (!mounted || !_isLiveStreaming) {
            return;
          }

          final normalized = _dbfsToLinear(amplitude.current);
          setState(() {
            if (_liveChunkCount == 0) {
              _waveformSamples.add(normalized);
              if (_waveformSamples.length > _waveformLimit) {
                _waveformSamples.removeRange(
                  0,
                  _waveformSamples.length - _waveformLimit,
                );
              }
              _currentRms = normalized;
            } else {
              _currentRms = math.max(_currentRms, normalized);
            }
          });
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

    _appendLog('Live stream started ($vadLabel).');
    if (_preferTenVadForLive) {
      _appendLog(
        'TEN config: preset=${_tenVadPresetLabel(_tenVadPreset)}, '
        'threshold=${_tenVadThreshold.toStringAsFixed(2)}',
      );
    }
    if (!vadLabel.startsWith('TEN VAD')) {
      _appendLog(
        'Energy thresholds: primary=${_energyPrimaryRmsThreshold.toStringAsFixed(4)}, '
        'secondary=${_energySecondaryRmsThreshold.toStringAsFixed(4)}, '
        'zcr=${_energyMinZeroCrossingRate.toStringAsFixed(3)}',
      );
    }
  }

  void _onRawMicChunk(Uint8List chunk) {
    _sessionBytes?.add(chunk);
    _liveChunkCount++;

    final now = DateTime.now();
    final amplitude = _computePcm16Rms(chunk);
    final detector = _liveSpeechDetector;
    final hasSpeechInChunk = detector?.addChunk(chunk) ?? false;

    if (hasSpeechInChunk) {
      _lastSpeechAt = now;
    }

    final speechActive =
        _lastSpeechAt != null &&
        now.difference(_lastSpeechAt!) <= _speechHoldDuration;

    if (!mounted) {
      return;
    }

    setState(() {
      _waveformSamples.add(amplitude);
      if (_waveformSamples.length > _waveformLimit) {
        _waveformSamples.removeRange(
          0,
          _waveformSamples.length - _waveformLimit,
        );
      }
      _speechDetected = speechActive;
      _currentRms = amplitude;
    });
  }

  Future<void> _onLiveSnippet(Pcm16Snippet snippet) async {
    final outputDir = _liveOutputDir;
    if (outputDir == null) {
      return;
    }

    final nextIndex = _liveSnippetCount + 1;
    final wavPath =
        '${outputDir.path}${Platform.pathSeparator}snippet_${nextIndex.toString().padLeft(3, '0')}.wav';
    await snippet.writeWav(wavPath);
    final wavBytes = await File(wavPath).length();

    if (!mounted) {
      return;
    }

    final artifact = _SnippetArtifact(
      id: nextIndex,
      duration: snippet.duration,
      wavPath: wavPath,
      wavBytes: wavBytes,
      aacPath: null,
      aacBytes: null,
      conversionInProgress: _autoConvertSnippets && _selectedAacEncoder != null,
    );

    setState(() {
      _liveSnippetCount = nextIndex;
      _snippets.insert(0, artifact);
    });

    _appendLog(
      'Snippet #$nextIndex finished (${snippet.duration.inMilliseconds} ms, WAV ${_formatBytes(wavBytes)}).',
    );

    final encoder = _selectedAacEncoder;
    if (!_autoConvertSnippets || encoder == null) {
      return;
    }

    final aacPath =
        '${outputDir.path}${Platform.pathSeparator}snippet_${nextIndex.toString().padLeft(3, '0')}.m4a';

    try {
      await encoder.encodePcm16BytesToAac(
        pcm16leBytes: snippet.asBytesView(),
        sampleRateHz: _splitOptions.sampleRateHz,
        channelCount: _splitOptions.channelCount,
        outputPath: aacPath,
        bitrateKbps: 48,
      );

      final aacBytes = await File(aacPath).length();
      _updateSnippet(
        nextIndex,
        (item) => item.copyWith(
          aacPath: aacPath,
          aacBytes: aacBytes,
          conversionInProgress: false,
        ),
      );

      _appendLog(
        'Snippet #$nextIndex AAC ready (${_formatBytes(aacBytes)}, ${_sizeChangeLabel(original: wavBytes, compressed: aacBytes)}).',
      );
    } on Object catch (error) {
      _updateSnippet(
        nextIndex,
        (item) => item.copyWith(conversionInProgress: false),
      );
      _appendLog('Snippet #$nextIndex AAC conversion failed: $error');
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

    try {
      await _recorder.stop();
    } on Object catch (error) {
      _appendLog('Stop recording failed: $error');
    }

    final done = _liveDone;
    if (done != null) {
      try {
        await done.future.timeout(const Duration(seconds: 3));
      } on TimeoutException {
        await _liveSnippetSubscription?.cancel();
        _cleanupLiveState();
      }
    } else {
      await _liveSnippetSubscription?.cancel();
      _cleanupLiveState();
    }

    await _finalizeWholeRecordingArtifacts();

    if (!internalDispose) {
      _appendLog('Live stream stopped.');
    }
  }

  void _cleanupLiveState() {
    _recordingTicker?.cancel();
    _streamHealthTimer?.cancel();
    _recordingStopwatch.stop();

    _liveSnippetSubscription = null;
    unawaited(_amplitudeSubscription?.cancel());
    _amplitudeSubscription = null;
    _liveDone = null;

    _liveSplitVadBackend?.dispose();
    _liveSplitVadBackend = null;

    _liveDetectionVadBackend?.dispose();
    _liveDetectionVadBackend = null;

    _liveSpeechDetector = null;

    if (!mounted) {
      return;
    }

    setState(() {
      _isLiveStreaming = false;
      _speechDetected = false;
      _recordingDuration = _recordingStopwatch.elapsed;
      _liveChunkCount = 0;
      _currentRms = 0;
    });
  }

  Future<void> _finalizeWholeRecordingArtifacts() async {
    final bytesBuilder = _sessionBytes;
    final sessionDir = _liveOutputDir;

    _sessionBytes = null;
    _liveOutputDir = null;

    if (bytesBuilder == null || sessionDir == null) {
      return;
    }

    final pcmBytes = bytesBuilder.toBytes();
    if (pcmBytes.isEmpty) {
      return;
    }

    final wavPath =
        '${sessionDir.path}${Platform.pathSeparator}recording_full.wav';
    await _writePcm16BytesAsWav(
      pcm16leBytes: pcmBytes,
      sampleRateHz: _splitOptions.sampleRateHz,
      channelCount: _splitOptions.channelCount,
      outputPath: wavPath,
    );
    final wavBytes = await File(wavPath).length();

    String? aacPath;
    int? aacBytes;

    final encoder = _selectedAacEncoder;
    if (_convertWholeRecordingWhenStopped && encoder != null) {
      aacPath = '${sessionDir.path}${Platform.pathSeparator}recording_full.m4a';
      try {
        await encoder.encodePcm16BytesToAac(
          pcm16leBytes: pcmBytes,
          sampleRateHz: _splitOptions.sampleRateHz,
          channelCount: _splitOptions.channelCount,
          outputPath: aacPath,
          bitrateKbps: 48,
        );
        aacBytes = await File(aacPath).length();
      } on Object catch (error) {
        _appendLog('Whole-recording AAC conversion failed: $error');
        aacPath = null;
        aacBytes = null;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _fullRecordingWavPath = wavPath;
      _fullRecordingWavBytes = wavBytes;
      _fullRecordingAacPath = aacPath;
      _fullRecordingAacBytes = aacBytes;
    });

    if (aacBytes != null) {
      _appendLog(
        'Whole recording AAC: ${_formatBytes(wavBytes)} -> ${_formatBytes(aacBytes)} (${_sizeChangeLabel(original: wavBytes, compressed: aacBytes)}).',
      );
    } else {
      _appendLog(
        'Whole recording WAV saved: $wavPath (${_formatBytes(wavBytes)}).',
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
      appBar: AppBar(title: const Text('speech_utils Example')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusCard(theme),
          const SizedBox(height: 12),
          _buildOptionsCard(theme),
          const SizedBox(height: 12),
          _buildControlButtons(),
          const SizedBox(height: 12),
          _buildFullRecordingCard(theme),
          const SizedBox(height: 12),
          _buildSnippetListCard(theme),
          const SizedBox(height: 12),
          _buildLogCard(theme),
        ],
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
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                child: CustomPaint(
                  painter: _WaveformPainter(
                    samples: _waveformSamples,
                    color: theme.colorScheme.primary,
                    centerLineColor: theme.colorScheme.outlineVariant,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                child: DropdownButtonFormField<_TenVadPreset>(
                  initialValue: _tenVadPreset,
                  decoration: const InputDecoration(
                    labelText: 'TEN preset',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _TenVadPreset.values
                      .map(
                        (preset) => DropdownMenuItem<_TenVadPreset>(
                          value: preset,
                          child: Text(_tenVadPresetLabel(preset)),
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
            Text('Whole recording', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('WAV: ${_formatBytes(wavBytes)}'),
            if (aacBytes != null)
              Text(
                'AAC: ${_formatBytes(aacBytes)} (${_sizeChangeLabel(original: wavBytes, compressed: aacBytes)})',
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
                          '(${_sizeChangeLabel(original: snippet.wavBytes, compressed: snippet.aacBytes!)})';

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
                          Text(
                            'Snippet #${snippet.id} • ${snippet.duration.inMilliseconds} ms',
                            style: theme.textTheme.titleSmall,
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

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({
    required this.samples,
    required this.color,
    required this.centerLineColor,
  });

  final List<double> samples;
  final Color color;
  final Color centerLineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;

    final centerPaint = Paint()
      ..color = centerLineColor
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      centerPaint,
    );

    if (samples.isEmpty) {
      return;
    }

    final barPaint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final visibleSamples = samples.length;
    final stepX = visibleSamples <= 1
        ? size.width
        : size.width / (visibleSamples - 1);

    for (var i = 0; i < visibleSamples; i++) {
      final amplitude = samples[i].clamp(0.0, 1.0);
      final barHalfHeight = math.max(1.0, amplitude * (size.height * 0.46));
      final x = i * stepX;
      canvas.drawLine(
        Offset(x, centerY - barHalfHeight),
        Offset(x, centerY + barHalfHeight),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.color != color ||
        oldDelegate.centerLineColor != centerLineColor;
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
    required this.conversionInProgress,
  });

  final int id;
  final Duration duration;
  final String wavPath;
  final int wavBytes;
  final String? aacPath;
  final int? aacBytes;
  final bool conversionInProgress;

  _SnippetArtifact copyWith({
    String? aacPath,
    int? aacBytes,
    bool? conversionInProgress,
  }) {
    return _SnippetArtifact(
      id: id,
      duration: duration,
      wavPath: wavPath,
      wavBytes: wavBytes,
      aacPath: aacPath ?? this.aacPath,
      aacBytes: aacBytes ?? this.aacBytes,
      conversionInProgress: conversionInProgress ?? this.conversionInProgress,
    );
  }
}

final class _VadPair {
  const _VadPair({required this.splitter, required this.detector});

  final VadBackend splitter;
  final VadBackend detector;
}

final class _LiveSpeechDetector {
  _LiveSpeechDetector({required this.options, required this.vadBackend})
    : _frameByteCount = options.frameSampleCount * 2;

  final PauseSplitOptions options;
  final VadBackend vadBackend;

  final int _frameByteCount;
  Uint8List _leftoverBytes = Uint8List(0);

  bool addChunk(Uint8List chunk) {
    if (chunk.isEmpty) {
      return false;
    }

    final workingBytes = _ensureEvenByteOffset(_mergeWithLeftover(chunk));
    final fullFrameCount = workingBytes.length ~/ _frameByteCount;
    var hasSpeech = false;

    for (var frameIndex = 0; frameIndex < fullFrameCount; frameIndex++) {
      final frameStart = frameIndex * _frameByteCount;
      final frameEnd = frameStart + _frameByteCount;
      final frameBytes = Uint8List.sublistView(
        workingBytes,
        frameStart,
        frameEnd,
      );
      final alignedFrameBytes = _ensureEvenByteOffset(frameBytes);
      final frameSamples = Int16List.view(
        alignedFrameBytes.buffer,
        alignedFrameBytes.offsetInBytes,
        options.frameSampleCount,
      );

      if (vadBackend.isSpeechFrame(
        frameSamples,
        startSampleOffset: 0,
        sampleCount: options.frameSampleCount,
        sampleRateHz: options.sampleRateHz,
        channelCount: options.channelCount,
      )) {
        hasSpeech = true;
      }
    }

    final processedBytes = fullFrameCount * _frameByteCount;
    final remainingBytes = workingBytes.length - processedBytes;
    if (remainingBytes == 0) {
      _leftoverBytes = Uint8List(0);
    } else {
      _leftoverBytes = Uint8List(remainingBytes);
      _leftoverBytes.setRange(0, remainingBytes, workingBytes, processedBytes);
    }

    return hasSpeech;
  }

  Uint8List _mergeWithLeftover(Uint8List chunk) {
    if (_leftoverBytes.isEmpty) {
      return chunk;
    }

    final merged = Uint8List(_leftoverBytes.length + chunk.length);
    merged.setRange(0, _leftoverBytes.length, _leftoverBytes);
    merged.setRange(_leftoverBytes.length, merged.length, chunk);
    return merged;
  }
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

Future<void> _writePcm16BytesAsWav({
  required Uint8List pcm16leBytes,
  required int sampleRateHz,
  required int channelCount,
  required String outputPath,
}) async {
  final output = File(outputPath);
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

double _computePcm16Rms(Uint8List bytes) {
  if (bytes.lengthInBytes < 2) {
    return 0;
  }

  final byteData = ByteData.sublistView(bytes);
  var sumSquares = 0.0;
  var sampleCount = 0;

  for (var i = 0; i + 1 < bytes.lengthInBytes; i += 2) {
    final sample = byteData.getInt16(i, Endian.little) / 32768.0;
    sumSquares += sample * sample;
    sampleCount++;
  }

  if (sampleCount == 0) {
    return 0;
  }

  final rms = math.sqrt(sumSquares / sampleCount);
  return rms.clamp(0.0, 1.0);
}

double _dbfsToLinear(double dbfs) {
  if (dbfs.isNaN || dbfs.isInfinite) {
    return 0;
  }
  if (dbfs <= -160) {
    return 0;
  }
  final linear = math.pow(10.0, dbfs / 20.0).toDouble();
  return linear.clamp(0.0, 1.0);
}

Uint8List _ensureEvenByteOffset(Uint8List bytes) {
  if (bytes.offsetInBytes.isEven) {
    return bytes;
  }

  final aligned = Uint8List(bytes.lengthInBytes);
  aligned.setRange(0, aligned.lengthInBytes, bytes);
  return aligned;
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
