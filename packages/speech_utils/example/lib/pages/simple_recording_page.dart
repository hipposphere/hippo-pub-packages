import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_utils/speech_utils.dart';
import 'package:speech_utils_example/widgets/example_dropdown_form_field.dart';
import 'package:speech_utils_example/widgets/live_waveform.dart';
import 'package:speech_utils_example/widgets/theme_controls.dart';

class SimpleRecordingPage extends StatefulWidget {
  const SimpleRecordingPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<SimpleRecordingPage> createState() => _SimpleRecordingPageState();
}

class _SimpleRecordingPageState extends State<SimpleRecordingPage> {
  final NativeAudioRecorder _recorder = NativeAudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  late ThemeMode _themeMode;
  late final bool _supportsInputSelection;

  final List<double> _waveformSamples = <double>[];
  final List<String> _logs = <String>[];
  List<InputDevice> _inputDevices = <InputDevice>[];
  InputDevice? _selectedInputDevice;

  int? _sampleRateHz;
  int _channelCount = 1;
  int? _bitrateKbps;

  final NativeAudioEncoder _nativeAacEncoder = NativeAudioEncoder();
  final FfmpegAacEncoder _ffmpegAacEncoder = FfmpegAacEncoder();

  bool _isNativeAacAvailable = false;
  bool _isFfmpegAacAvailable = false;
  AacEncoder? _selectedAacEncoder;

  StreamSubscription<Uint8List>? _streamSubscription;

  BytesBuilder? _sessionBytes;
  Directory? _outputRoot;

  bool _isRecording = false;
  bool _speechDetected = false;
  bool _isRefreshingInputDevices = false;

  int _chunkCount = 0;
  double _currentRms = 0;
  double _currentDbfs = -90;
  double _peakDbfs = -90;
  double _speechThresholdRms = 0.035;

  String? _latestWavPath;
  int? _latestWavBytes;
  AudioMetadata? _latestWavMetadata;
  String? _latestAacPath;
  int? _latestAacBytes;
  int? _latestAacLatencyMs;
  AudioMetadata? _latestAacMetadata;
  String? _playingPath;

  final Stopwatch _recordingStopwatch = Stopwatch();
  Timer? _recordingTicker;
  Duration _recordingDuration = Duration.zero;

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
    unawaited(_refreshAacEncoders());
  }

  Future<void> _refreshAacEncoders() async {
    bool nativeAvail = false;
    bool ffmpegAvail = false;
    AacEncoder? selected;

    try {
      nativeAvail = await _nativeAacEncoder.isAvailable();
      ffmpegAvail = await _ffmpegAacEncoder.isAvailable();

      if (nativeAvail) {
        selected = _nativeAacEncoder;
      } else if (ffmpegAvail) {
        selected = _ffmpegAacEncoder;
      }
    } on Object catch (error) {
      _appendLog('AAC encoder detection failed: $error');
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isNativeAacAvailable = nativeAvail;
      _isFfmpegAacAvailable = ffmpegAvail;
      _selectedAacEncoder = selected;
    });
  }

  @override
  void dispose() {
    _recordingTicker?.cancel();
    _recordingStopwatch.stop();
    unawaited(_streamSubscription?.cancel());
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
      '${temp.path}${Platform.pathSeparator}speech_utils_example_simple',
    );
    await root.create(recursive: true);
    _outputRoot = root;
    _appendLog('Output root: ${root.path}');
    return root;
  }

  void _appendLog(String message) {
    if (!mounted) {
      return;
    }
    final timestamp = DateTime.now().toIso8601String();
    setState(() {
      _logs.insert(0, '[$timestamp] $message');
      if (_logs.length > 200) {
        _logs.removeRange(200, _logs.length);
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
    if (_isRecording) {
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
      'Input device preview set to $label. Recording still uses system default on this platform.',
    );
  }

  Future<void> _startRecording() async {
    if (_isRecording) {
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

    late final Stream<Uint8List> micStream;
    final inputDeviceId = _supportsInputSelection
        ? ((_selectedInputDevice?.isDefault ?? true)
              ? null
              : _selectedInputDevice?.id)
        : null;
    try {
      micStream = await _recorder.startPcmStream(
        config: AudioRecorderConfig(
          sampleRateHz: _sampleRateHz ?? 16000,
          channelCount: _channelCount,
          framesPerChunk: 256,
          inputDeviceId: inputDeviceId,
        ),
        pollInterval: const Duration(milliseconds: 10),
        readSampleCapacity: 4096,
      );
    } on Object catch (error) {
      _appendLog('Failed to start recording: $error');
      return;
    }

    _sessionBytes = BytesBuilder(copy: false);

    _streamSubscription = micStream.listen(
      _onMicChunk,
      onError: (Object error, StackTrace stackTrace) {
        _appendLog('Recording stream error: $error');
      },
    );

    _recordingStopwatch
      ..reset()
      ..start();
    _recordingTicker?.cancel();
    _recordingTicker = Timer.periodic(const Duration(milliseconds: 160), (_) {
      if (!mounted || !_isRecording) {
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
      _isRecording = true;
      _speechDetected = false;
      _chunkCount = 0;
      _currentRms = 0;
      _currentDbfs = -90;
      _peakDbfs = -90;
      _recordingDuration = Duration.zero;
      _waveformSamples.clear();
      _latestWavPath = null;
      _latestWavBytes = null;
    });
    final activeInputLabel = _supportsInputSelection
        ? (_selectedInputDevice?.label ?? 'System default')
        : (_inputDevices
                  .where((device) => device.isDefault)
                  .firstOrNull
                  ?.label ??
              'System default');
    _appendLog('Recording started using "$activeInputLabel".');
  }

  void _onMicChunk(Uint8List chunk) {
    _sessionBytes?.add(chunk);

    final rms = _computePcm16Rms(chunk);
    final speech = rms >= _speechThresholdRms;

    if (!mounted) {
      return;
    }

    setState(() {
      _chunkCount++;
      _speechDetected = speech;
      _currentRms = rms;

      final dbfs = SpeechAmplitudeUtils.rmsToDbfs(rms);
      _currentDbfs = dbfs;
      _peakDbfs = math.max(_peakDbfs, dbfs);

      _waveformSamples.add(
        SpeechAmplitudeUtils.normalizeDbfsForWaveform(
          dbfs,
          sensitivity: SpeechAmplitudeUtils.defaultSensitivity,
        ),
      );
      if (_waveformSamples.length > 220) {
        _waveformSamples.removeRange(0, _waveformSamples.length - 220);
      }
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) {
      return;
    }

    _recordingTicker?.cancel();
    _recordingTicker = null;
    _recordingStopwatch.stop();

    try {
      await _recorder.stop();
    } on Object catch (error) {
      _appendLog('Stop recording failed: $error');
    }

    await _streamSubscription?.cancel();
    _streamSubscription = null;

    final bytes = _sessionBytes?.toBytes() ?? Uint8List(0);
    _sessionBytes = null;

    if (mounted) {
      setState(() {
        _isRecording = false;
        _recordingDuration = _recordingStopwatch.elapsed;
      });
    }

    if (bytes.isEmpty) {
      _appendLog('Recording stopped with no captured PCM data.');
      return;
    }

    final outputRoot = await _ensureOutputRoot();
    final outputPath =
        '${outputRoot.path}${Platform.pathSeparator}simple_recording_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _writePcm16BytesAsWav(
      pcm16leBytes: bytes,
      sampleRateHz: _sampleRateHz ?? 16000,
      channelCount: _channelCount,
      outputPath: outputPath,
    );

    final wavBytes = await File(outputPath).length();

    int? aacLatencyMs;
    String? aacPath;
    int? aacBytes;

    final encoder = _selectedAacEncoder;
    if (encoder != null) {
      aacPath =
          '${outputRoot.path}${Platform.pathSeparator}simple_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      try {
        final watch = Stopwatch()..start();
        await encoder.encodePcm16BytesToAac(
          pcm16leBytes: bytes,
          sampleRateHz: _sampleRateHz ?? 16000,
          channelCount: _channelCount,
          outputPath: aacPath,
          bitrateKbps: _bitrateKbps ?? 48,
        );
        aacLatencyMs = watch.elapsedMilliseconds;
        aacBytes = await File(aacPath).length();
      } on Object catch (error) {
        _appendLog('AAC conversion failed: $error');
        aacPath = null;
        aacBytes = null;
      }
    }

    final wavMetadata = await _readNativeMetadataAsync(outputPath);
    AudioMetadata? aacMetadata;
    if (aacPath != null) {
      aacMetadata = await _readNativeMetadataAsync(aacPath);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _latestWavPath = outputPath;
      _latestWavBytes = wavBytes;
      _latestWavMetadata = wavMetadata;
      _latestAacPath = aacPath;
      _latestAacBytes = aacBytes;
      _latestAacLatencyMs = aacLatencyMs;
      _latestAacMetadata = aacMetadata;
      _playingPath = null;
    });

    if (aacBytes != null) {
      _appendLog(
        'Recording saved: WAV $outputPath (${_formatBytes(wavBytes)}), AAC $aacPath (${_formatBytes(aacBytes)} in ${aacLatencyMs}ms).',
      );
    } else {
      _appendLog(
        'Recording saved: $outputPath (${_formatBytes(wavBytes)}), chunks=$_chunkCount.',
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
      _appendLog('Playback failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Recorder + Waveform'),
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
              _buildInputAndDetectionCard(theme),
              const SizedBox(height: 12),
              _buildConfigCard(theme),
              const SizedBox(height: 12),
            ],
            _buildControls(),
            const SizedBox(height: 12),
            _buildLatestRecordingCard(theme),
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
                    children: [
                      _buildInputAndDetectionCard(theme),
                      const SizedBox(height: 12),
                      _buildConfigCard(theme),
                    ],
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

  Widget _buildConfigCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              onChanged: _isRecording
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
              onChanged: _isRecording
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
              onChanged: _isRecording
                  ? null
                  : (val) {
                      setState(() {
                        _bitrateKbps = val;
                      });
                    },
            ),
            const SizedBox(height: 12),
            ExampleDropdownFormField<AacEncoder?>(
              initialValue: _selectedAacEncoder,
              decoration: const InputDecoration(
                labelText: 'AAC Encoder',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              options: [
                const ExampleDropdownOption<AacEncoder?>(
                  value: null,
                  label: 'None (WAV only)',
                ),
                if (_isNativeAacAvailable)
                  ExampleDropdownOption<AacEncoder?>(
                    value: _nativeAacEncoder,
                    label: 'Native AAC',
                  ),
                if (_isFfmpegAacAvailable)
                  ExampleDropdownOption<AacEncoder?>(
                    value: _ffmpegAacEncoder,
                    label: 'ffmpeg AAC',
                  ),
              ],
              onChanged: _isRecording
                  ? null
                  : (val) {
                      setState(() {
                        _selectedAacEncoder = val;
                      });
                    },
            ),
          ],
        ),
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
                  _isRecording ? Icons.mic : Icons.mic_none,
                  color: _isRecording
                      ? Colors.redAccent
                      : theme.colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Text(
                  _isRecording ? 'Recording' : 'Idle',
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
                Chip(
                  avatar: Icon(
                    Icons.graphic_eq,
                    color: indicatorColor,
                    size: 18,
                  ),
                  label: Text(_speechDetected ? 'Speech detected' : 'Silence'),
                ),
                Chip(label: Text('Chunks: $_chunkCount')),
                Chip(label: Text('RMS: ${_currentRms.toStringAsFixed(3)}')),
                Chip(label: Text('dBFS: ${_currentDbfs.toStringAsFixed(1)}')),
                Chip(label: Text('Peak: ${_peakDbfs.toStringAsFixed(1)} dBFS')),
              ],
            ),
            const SizedBox(height: 10),
            LiveWaveformPanel(
              samples: _waveformSamples,
              isActive: _isRecording,
              speechDetected: _speechDetected,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputAndDetectionCard(ThemeData theme) {
    final selectedDeviceId = _selectedInputDevice?.id;
    final defaultDevice = _inputDevices
        .where((device) => device.isDefault)
        .firstOrNull;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Input', style: theme.textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              _supportsInputSelection
                  ? 'Select a recording input device and keep it locked for this session.'
                  : 'Input listing is available. Selection is preview-only; recording follows the system default on this platform.',
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
                    onChanged: !_isRecording ? _selectInputDeviceById : null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Refresh inputs',
                  onPressed: _isRefreshingInputDevices || _isRecording
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
            const SizedBox(height: 12),
            Text('Speech threshold (RMS)', style: theme.textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              'Current threshold: ${_speechThresholdRms.toStringAsFixed(3)}',
              style: theme.textTheme.bodyMedium,
            ),
            Slider(
              value: _speechThresholdRms,
              min: 0.005,
              max: 0.20,
              divisions: 195,
              label: _speechThresholdRms.toStringAsFixed(3),
              onChanged: _isRecording
                  ? null
                  : (value) {
                      setState(() {
                        _speechThresholdRms = value;
                      });
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          onPressed: _isRecording ? _stopRecording : _startRecording,
          icon: Icon(_isRecording ? Icons.stop : Icons.mic),
          label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
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

  Widget _buildLatestRecordingCard(ThemeData theme) {
    final wavPath = _latestWavPath;
    if (wavPath == null) {
      return const SizedBox.shrink();
    }

    final wavBytes = _latestWavBytes ?? 0;

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
                    'Last recording',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _showMetadataDialog(
                    context: context,
                    title: 'Recording Metadata',
                    wavPath: wavPath,
                    wavBytes: wavBytes,
                    wavMetadata: _latestWavMetadata,
                    aacPath: _latestAacPath,
                    aacBytes: _latestAacBytes,
                    aacLatencyMs: _latestAacLatencyMs,
                    aacMetadata: _latestAacMetadata,
                  ),
                  tooltip: 'View Metadata',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('WAV: ${_formatBytes(wavBytes)}'),
            if (_latestAacBytes != null)
              Text(
                'AAC: ${_formatBytes(_latestAacBytes!)}'
                '${_latestAacLatencyMs != null ? ' in ${_latestAacLatencyMs}ms' : ''}',
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
                if (_latestAacPath != null)
                  OutlinedButton.icon(
                    onPressed: () => _togglePlayback(_latestAacPath!),
                    icon: Icon(
                      _playingPath == _latestAacPath
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

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final millis = (duration.inMilliseconds.remainder(1000) ~/ 10)
      .toString()
      .padLeft(2, '0');
  return '$minutes:$seconds.$millis';
}
