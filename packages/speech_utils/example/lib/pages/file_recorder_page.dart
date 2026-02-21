import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_utils/speech_utils.dart';
import 'package:speech_utils_example/widgets/example_dropdown_form_field.dart';
import 'package:speech_utils_example/widgets/live_waveform.dart';
import 'package:speech_utils_example/widgets/theme_controls.dart';

class FileRecordingPage extends StatefulWidget {
  const FileRecordingPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<FileRecordingPage> createState() => _FileRecordingPageState();
}

class _FileRecordingPageState extends State<FileRecordingPage> {
  static const int _waveformSampleLimit = 220;

  final NativeAudioRecorder _recorder = NativeAudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final NativeAudioMetadataReader _metadataReader = NativeAudioMetadataReader();
  StreamSubscription<Amplitude>? _amplitudeSubscription;

  final List<String> _logs = <String>[];
  final Stopwatch _recordingStopwatch = Stopwatch();
  final List<double> _waveformSamples = <double>[];

  late ThemeMode _themeMode;
  late final bool _supportsInputSelection;

  List<InputDevice> _inputDevices = <InputDevice>[];
  InputDevice? _selectedInputDevice;

  bool _isRefreshingInputDevices = false;
  bool _isRecording = false;
  bool _isMetadataReading = false;

  int? _sampleRateHz;
  int _channelCount = 1;
  int? _bitrateKbps;
  AudioEncoder _selectedEncoder = AudioEncoder.wav;

  String? _activeOutputPath;
  String? _latestRecordingPath;
  String? _playingPath;
  AudioMetadata? _latestMetadata;
  int? _latestByteCount;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTicker;
  Directory? _outputRoot;
  double _currentDbfs = -90;
  double _peakDbfs = -90;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeMode;
    _supportsInputSelection = _recorder.supportsInputSelection;
    unawaited(_ensureOutputRoot());
    unawaited(_refreshInputDevices(logResult: false));
    _player.onPlayerComplete.listen((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _playingPath = null;
      });
    });
  }

  @override
  void dispose() {
    _recordingTicker?.cancel();
    _recordingStopwatch.stop();
    unawaited(_amplitudeSubscription?.cancel());
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
      '${temp.path}${Platform.pathSeparator}speech_utils_example_file',
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
      final selectedId = _selectedInputDevice?.id;
      InputDevice? selected = selectedId == null
          ? null
          : devices.where((device) => device.id == selectedId).firstOrNull;
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
    } else {
      _appendLog(
        'Input device preview set to $label. Recording still follows system default on this platform.',
      );
    }
  }

  String _encoderFileExtension(AudioEncoder encoder) {
    switch (encoder) {
      case AudioEncoder.aacLc:
      case AudioEncoder.aacHe:
      case AudioEncoder.aacEld:
        return 'm4a';
      case AudioEncoder.wav:
        return 'wav';
      case AudioEncoder.pcm16bits:
        return 'pcm';
      case AudioEncoder.flac:
      case AudioEncoder.opus:
        return 'dat';
    }
  }

  AudioEncodingConfig _buildEncodingConfig() {
    return AudioEncodingConfig(
      encoder: _selectedEncoder,
      bitrateBps: _selectedEncoder.isAac && _bitrateKbps != null
          ? _bitrateKbps! * 1000
          : null,
      aacEncoder: _selectedEncoder.isAac ? NativeAacEncoder() : null,
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

    final outputRoot = await _ensureOutputRoot();
    final outputPath =
        '${outputRoot.path}${Platform.pathSeparator}file_recording_${DateTime.now().millisecondsSinceEpoch}.${_encoderFileExtension(_selectedEncoder)}';

    final config = AudioRecorderConfig(
      sampleRateHz: _sampleRateHz ?? 16000,
      channelCount: _channelCount,
      inputDeviceId: _supportsInputSelection ? _selectedInputDevice?.id : null,
      encoding: _buildEncodingConfig(),
    );

    try {
      await _recorder.start(outputPath: outputPath, config: config);
    } on Object catch (error) {
      _appendLog('Failed to start recording: $error');
      return;
    }

    _activeOutputPath = outputPath;
    _latestMetadata = null;
    _latestByteCount = null;
    _latestRecordingPath = null;
    _recordingStopwatch
      ..reset()
      ..start();
    _recordingTicker?.cancel();
    _recordingTicker = Timer.periodic(const Duration(milliseconds: 200), (_) {
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
      _recordingDuration = Duration.zero;
      _playingPath = null;
      _currentDbfs = -90;
      _peakDbfs = -90;
      _waveformSamples.clear();
    });
    _startAmplitudeMonitoring();
    final activeInputLabel = _supportsInputSelection
        ? (_selectedInputDevice?.label ?? 'System default')
        : (_inputDevices
                  .where((device) => device.isDefault)
                  .firstOrNull
                  ?.label ??
              'System default');
    _appendLog('Recording started using "$activeInputLabel".');
    _appendLog(
      'Output: $_selectedEncoder (${_sampleRateHz ?? 'auto'} Hz, $_channelCount ch).',
    );
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) {
      return;
    }

    _recordingTicker?.cancel();
    _recordingTicker = null;
    _recordingStopwatch.stop();
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;

    try {
      await _recorder.stop();
    } on Object catch (error) {
      _appendLog('Stop recording failed: $error');
    }

    final outputPath = _activeOutputPath;
    if (outputPath == null) {
      if (mounted) {
        setState(() {
          _isRecording = false;
          _recordingDuration = _recordingStopwatch.elapsed;
        });
      }
      _appendLog('Recording stopped without an active output path.');
      return;
    }
    _activeOutputPath = null;

    final outputFile = File(outputPath);
    if (!await outputFile.exists()) {
      if (mounted) {
        setState(() {
          _isRecording = false;
          _recordingDuration = _recordingStopwatch.elapsed;
        });
      }
      _appendLog('Recording stopped, but file was not created: $outputPath');
      return;
    }

    final bytes = await outputFile.length();
    setState(() {
      _isRecording = false;
      _recordingDuration = _recordingStopwatch.elapsed;
      _latestByteCount = bytes;
      _latestRecordingPath = outputPath;
      _latestMetadata = null;
    });

    setState(() {
      _isMetadataReading = true;
    });
    final metadata = await _readMetadataAsync(outputPath);
    if (!mounted) {
      return;
    }
    setState(() {
      _latestMetadata = metadata;
      _isMetadataReading = false;
    });
    if (metadata != null) {
      _appendLog(
        'Recording saved: ${_formatBytes(bytes)} (${metadata.containerFormat ?? 'unknown'}).',
      );
    } else {
      _appendLog('Recording saved: $outputPath (${_formatBytes(bytes)}).');
    }
  }

  void _startAmplitudeMonitoring() {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 80))
        .listen(
          (Amplitude amplitude) {
            if (!mounted || !_isRecording) {
              return;
            }
            final normalizedAmplitude =
                SpeechAmplitudeUtils.normalizeDbfsForWaveform(
                  amplitude.current,
                  sensitivity: SpeechAmplitudeUtils.defaultSensitivity,
                );
            setState(() {
              _currentDbfs = amplitude.current;
              if (amplitude.max > _peakDbfs) {
                _peakDbfs = amplitude.max;
              }
              _waveformSamples.add(normalizedAmplitude);
              if (_waveformSamples.length > _waveformSampleLimit) {
                _waveformSamples.removeRange(
                  0,
                  _waveformSamples.length - _waveformSampleLimit,
                );
              }
            });
          },
          onError: (Object error, StackTrace stackTrace) {
            _appendLog('Amplitude stream error: $error');
          },
        );
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

  Future<AudioMetadata?> _readMetadataAsync(String path) async {
    try {
      if (!await _metadataReader.isAvailable()) {
        return null;
      }
      return await _metadataReader.readAudioMetadata(inputPath: path);
    } on Object catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width > 900;

    final cards = <Widget>[
      _buildStatusCard(theme),
      const SizedBox(height: 12),
      _buildControls(),
      const SizedBox(height: 12),
      if (!wide) ...[
        _buildInputCard(theme),
        const SizedBox(height: 12),
        _buildConfigCard(theme),
      ],
      if (_latestByteCount != null) ...[
        const SizedBox(height: 12),
        _buildRecordingResultCard(theme),
      ],
      const SizedBox(height: 12),
      _buildLogCard(theme),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start/Stop Recorder (No Streaming)'),
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
      body: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: cards,
                  ),
                ),
                Container(
                  width: 340,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildInputCard(theme),
                      const SizedBox(height: 12),
                      _buildConfigCard(theme),
                    ],
                  ),
                ),
              ],
            )
          : ListView(padding: const EdgeInsets.all(16), children: cards),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
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
                Chip(label: Text('Encoder: ${_selectedEncoder.name}')),
                Chip(
                  label: Text(
                    'Sample rate: ${_sampleRateHz?.toString() ?? "auto"} Hz',
                  ),
                ),
                Chip(label: Text('Channels: $_channelCount')),
                if (_selectedEncoder.isAac)
                  Chip(
                    label: Text(
                      'Bitrate: ${_bitrateKbps?.toString() ?? "auto"} kbps',
                    ),
                  ),
                Chip(label: Text('dBFS: ${_currentDbfs.toStringAsFixed(1)}')),
                Chip(label: Text('Peak: ${_peakDbfs.toStringAsFixed(1)} dBFS')),
                if (_isMetadataReading)
                  Chip(
                    label: Text(
                      'Reading metadata...',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
            if (_activeOutputPath != null) ...[
              const SizedBox(height: 8),
              Text(
                'Current output: ${_activeOutputPath!.split(Platform.pathSeparator).last}',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            LiveWaveformPanel(
              samples: _waveformSamples,
              isActive: _isRecording,
              speechDetected: _currentDbfs > -35,
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
          label: Text(_isRecording ? 'Stop recording' : 'Start recording'),
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
          label: const Text('Clear log'),
        ),
      ],
    );
  }

  Widget _buildInputCard(ThemeData theme) {
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
            const SizedBox(height: 4),
            Text(
              _supportsInputSelection
                  ? 'Choose the capture input for this file recording session.'
                  : 'Input list is visible; selection is preview-only on this platform.',
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
                    onChanged: _isRecording ? null : _selectInputDeviceById,
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
                  ? 'Detected ${_inputDevices.length} devices.'
                  : 'System default: ${defaultDevice?.label ?? 'System input'}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
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
            ExampleDropdownFormField<AudioEncoder>(
              initialValue: _selectedEncoder,
              decoration: const InputDecoration(
                labelText: 'Output codec',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              options: const [
                ExampleDropdownOption(
                  value: AudioEncoder.wav,
                  label: 'WAV (PCM16 in container)',
                ),
                ExampleDropdownOption(
                  value: AudioEncoder.pcm16bits,
                  label: 'PCM16 (raw)',
                ),
                ExampleDropdownOption(
                  value: AudioEncoder.aacLc,
                  label: 'AAC-LC',
                ),
                ExampleDropdownOption(
                  value: AudioEncoder.aacHe,
                  label: 'AAC-HE',
                ),
                ExampleDropdownOption(
                  value: AudioEncoder.aacEld,
                  label: 'AAC-ELD',
                ),
              ],
              onChanged: _isRecording
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedEncoder = value;
                      });
                    },
            ),
            const SizedBox(height: 12),
            ExampleDropdownFormField<int?>(
              initialValue: _sampleRateHz,
              decoration: const InputDecoration(
                labelText: 'Sample rate',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              options: const [
                ExampleDropdownOption(value: null, label: 'Auto'),
                ExampleDropdownOption(value: 8000, label: '8000 Hz'),
                ExampleDropdownOption(value: 16000, label: '16000 Hz'),
                ExampleDropdownOption(value: 32000, label: '32000 Hz'),
                ExampleDropdownOption(value: 44100, label: '44100 Hz'),
                ExampleDropdownOption(value: 48000, label: '48000 Hz'),
              ],
              onChanged: _isRecording
                  ? null
                  : (value) {
                      setState(() {
                        _sampleRateHz = value;
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
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _channelCount = value;
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
                ExampleDropdownOption(value: null, label: 'Auto'),
                ExampleDropdownOption(value: 32, label: '32 kbps'),
                ExampleDropdownOption(value: 48, label: '48 kbps'),
                ExampleDropdownOption(value: 64, label: '64 kbps'),
                ExampleDropdownOption(value: 128, label: '128 kbps'),
              ],
              onChanged: _selectedEncoder.isAac && !_isRecording
                  ? (value) {
                      setState(() {
                        _bitrateKbps = value;
                      });
                    }
                  : null,
            ),
            if (!_selectedEncoder.isAac) ...[
              const SizedBox(height: 8),
              Text(
                'Bitrate is used only for AAC encoders.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingResultCard(ThemeData theme) {
    final outputPath = _latestRecordingPath;
    if (outputPath == null || _latestByteCount == null) {
      return const SizedBox.shrink();
    }
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
                    'Latest recording',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (_latestMetadata != null)
                  IconButton(
                    tooltip: 'Show metadata',
                    icon: const Icon(Icons.info_outline),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      _showMetadataSheet(context, outputPath, _latestMetadata!);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Path: ${outputPath.split(Platform.pathSeparator).last}'),
            Text('Size: ${_formatBytes(_latestByteCount!)}'),
            if (_latestMetadata != null) ...[
              const SizedBox(height: 8),
              Text(
                'Metadata: ${_latestMetadata!.sampleRateHz ?? 'unknown'} Hz, '
                '${_latestMetadata!.channelCount ?? 'unknown'} ch'
                '${_latestMetadata!.bitrateBps != null ? ', ${_latestMetadata!.bitrateBps! ~/ 1000} kbps' : ''}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                'Codec: ${_latestMetadata!.codec ?? 'unknown'}'
                '${_latestMetadata!.codecProfile != null ? ' (${_latestMetadata!.codecProfile})' : ''}',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _togglePlayback(outputPath),
              icon: Icon(
                _playingPath == outputPath ? Icons.stop : Icons.play_arrow,
              ),
              label: Text(
                _playingPath == outputPath ? 'Stop playback' : 'Play recording',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMetadataSheet(
    BuildContext context,
    String path,
    AudioMetadata metadata,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recording metadata',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('Path: ${path.split(Platform.pathSeparator).last}'),
                const SizedBox(height: 8),
                _buildMetadataRows(metadata),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetadataRows(AudioMetadata metadata) {
    final sampleRateDesc = metadata.sampleRateHz != null
        ? '${metadata.sampleRateHz} Hz'
        : 'Unknown';
    final channelsDesc = metadata.channelCount != null
        ? '${metadata.channelCount} ch'
        : 'Unknown';
    final bitrateDesc = metadata.bitrateBps != null
        ? '${metadata.bitrateBps! ~/ 1000} kbps'
        : 'Unknown';
    return Column(
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
          'Container: ${metadata.containerFormat ?? 'Unknown'}',
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          'Codec: ${metadata.codec ?? 'Unknown'} ${metadata.codecProfile ?? ''}',
          style: const TextStyle(fontSize: 12),
        ),
      ],
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
              height: 200,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableRegion(
                  selectionControls: MaterialTextSelectionControls(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        _logs[index],
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
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
  final millis = (duration.inMilliseconds.remainder(1000) / 10)
      .round()
      .toString()
      .padLeft(2, '0');
  return '$minutes:$seconds.$millis';
}
