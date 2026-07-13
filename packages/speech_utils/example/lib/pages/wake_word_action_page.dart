import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:speech_utils/speech_utils.dart';
import 'package:speech_utils_example/widgets/theme_controls.dart';

class WakeWordActionPage extends StatefulWidget {
  const WakeWordActionPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<WakeWordActionPage> createState() => _WakeWordActionPageState();
}

class _WakeWordActionPageState extends State<WakeWordActionPage> {
  final NativeAudioRecorder _recorder = NativeAudioRecorder();
  final List<String> _logs = <String>[];
  final List<_CommandSummary> _commands = <_CommandSummary>[];

  late ThemeMode _themeMode;
  VoiceActionCaptureSession? _session;
  SherpaOnnxWakeWordDetector? _detector;
  StreamSubscription<WakeWordEvent>? _wakeWordSubscription;
  StreamSubscription<VoiceActionCommandStream>? _commandStreamSubscription;
  StreamSubscription<VoiceActionCommand>? _commandSubscription;
  StreamSubscription<VoiceActionCaptureStateSample>? _stateSubscription;
  final List<StreamSubscription<Uint8List>> _liveCommandSubscriptions =
      <StreamSubscription<Uint8List>>[];

  final TextEditingController _keywordLabelController = TextEditingController(
    text: const String.fromEnvironment(
      'SPEECH_UTILS_KWS_LABEL',
      defaultValue: 'hey dicto',
    ),
  );
  bool _isListening = false;
  bool _isStarting = false;
  String _stateLabel = 'Stopped';
  int _wakeWordCount = 0;
  int _liveCommandBytes = 0;
  int _completedCommandBytes = 0;
  double _sensitivity = 0.8;
  Duration _endSilenceDuration = const Duration(milliseconds: 1000);
  Duration _postWakeDelay = const Duration(milliseconds: 150);

  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeMode;
  }

  @override
  void dispose() {
    unawaited(_stopListening());
    _keywordLabelController.dispose();
    unawaited(_recorder.dispose());
    super.dispose();
  }

  Future<void> _startListening() async {
    if (_isListening || _isStarting) {
      return;
    }

    setState(() {
      _isStarting = true;
      _logs.clear();
      _commands.clear();
      _wakeWordCount = 0;
      _liveCommandBytes = 0;
      _completedCommandBytes = 0;
    });

    try {
      final detector = await SherpaOnnxWakeWordDetector.create(
        keywords: <String>[_keywordLabelController.text.trim()],
        sensitivity: _sensitivity,
      );

      final session = await _recorder.startVoiceActionCapture(
        VoiceActionCaptureRequest(
          detector: detector,
          wakeWords: WakeWordDetectionConfig(
            keywords: <String>[_keywordLabelController.text.trim()],
            sensitivity: _sensitivity,
          ),
          audio: const AudioRecorderConfig(
            sampleRateHz: 16000,
            channelCount: 1,
          ),
          command: WakeCommandCaptureConfig(
            discardWakeWordAudio: true,
            postWakeDelay: _postWakeDelay,
            endSilenceDuration: _endSilenceDuration,
            trailingPadding: const Duration(milliseconds: 250),
            vad: const SpeechVadConfig.preferTen(),
          ),
          pollInterval: const Duration(milliseconds: 20),
        ),
      );

      _detector = detector;
      _session = session;
      _attachSessionListeners(session);
      _appendLog('Listening for "${_keywordLabelController.text.trim()}".');

      if (!mounted) {
        return;
      }
      setState(() {
        _isListening = true;
        _stateLabel = 'Listening';
      });
    } on Object catch (error) {
      _appendLog('Failed to start wake-word capture: $error');
      _detector?.dispose();
      _detector = null;
    } finally {
      if (mounted) {
        setState(() {
          _isStarting = false;
        });
      }
    }
  }

  void _attachSessionListeners(VoiceActionCaptureSession session) {
    _wakeWordSubscription = session.wakeWords.listen((event) {
      _appendLog('Wake word detected: ${event.keyword}');
      if (!mounted) {
        return;
      }
      setState(() {
        _wakeWordCount++;
      });
    }, onError: (Object error) => _appendLog('Wake word stream error: $error'));

    _commandStreamSubscription = session.commandStreams.listen((commandStream) {
      _appendLog('Command #${commandStream.id} live stream started.');
      final subscription = commandStream.pcm16leStream.listen(
        (chunk) {
          if (!mounted) {
            return;
          }
          setState(() {
            _liveCommandBytes += chunk.lengthInBytes;
          });
        },
        onError: (Object error) =>
            _appendLog('Command live stream error: $error'),
      );
      _liveCommandSubscriptions.add(subscription);
    }, onError: (Object error) => _appendLog('Command stream error: $error'));

    _commandSubscription = session.commands.listen((command) {
      _appendLog(
        'Command #${command.id} completed: '
        '${command.duration.inMilliseconds} ms, ${command.pcm16leBytes.lengthInBytes} bytes.',
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _completedCommandBytes += command.pcm16leBytes.lengthInBytes;
        _commands.insert(
          0,
          _CommandSummary(
            id: command.id,
            wakeWord: command.wakeWord,
            duration: command.duration,
            byteCount: command.pcm16leBytes.lengthInBytes,
          ),
        );
      });
    }, onError: (Object error) => _appendLog('Command completion error: $error'));

    _stateSubscription = session.states.listen((state) {
      if (!mounted) {
        return;
      }
      setState(() {
        _stateLabel = switch (state.state) {
          VoiceActionCaptureState.listening => 'Listening',
          VoiceActionCaptureState.capturingCommand => 'Capturing command',
          VoiceActionCaptureState.paused => 'Paused',
          VoiceActionCaptureState.stopped => 'Stopped',
        };
      });
    }, onError: (Object error) => _appendLog('State stream error: $error'));
  }

  Future<void> _stopListening() async {
    final session = _session;
    _session = null;
    if (session != null) {
      try {
        final result = await session.stop();
        _appendLog(
          'Stopped. Wake words: ${result.wakeWordCount}, commands: ${result.commandCount}.',
        );
      } on Object catch (error) {
        _appendLog('Stop failed: $error');
      }
    }

    await _wakeWordSubscription?.cancel();
    await _commandStreamSubscription?.cancel();
    await _commandSubscription?.cancel();
    await _stateSubscription?.cancel();
    for (final subscription in _liveCommandSubscriptions) {
      await subscription.cancel();
    }
    _liveCommandSubscriptions.clear();
    _wakeWordSubscription = null;
    _commandStreamSubscription = null;
    _commandSubscription = null;
    _stateSubscription = null;
    _detector = null;

    if (!mounted) {
      return;
    }
    setState(() {
      _isListening = false;
      _stateLabel = 'Stopped';
    });
  }

  void _appendLog(String message) {
    if (!mounted) {
      return;
    }
    final timestamp = DateTime.now().toIso8601String();
    setState(() {
      _logs.insert(0, '[$timestamp] $message');
      if (_logs.length > 120) {
        _logs.removeRange(120, _logs.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wake Word Action Capture'),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusCard(context),
          const SizedBox(height: 12),
          _buildModelConfigCard(context),
          const SizedBox(height: 12),
          _buildCaptureConfigCard(context),
          const SizedBox(height: 12),
          _buildCommandCard(context),
          const SizedBox(height: 12),
          _buildLogCard(context),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_isListening ? Icons.hearing : Icons.hearing_disabled),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _stateLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Text('Wake words: $_wakeWordCount'),
                Text('Live bytes: $_liveCommandBytes'),
                Text('Completed bytes: $_completedCommandBytes'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _isListening || _isStarting
                      ? null
                      : _startListening,
                  icon: _isStarting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(_isStarting ? 'Starting' : 'Start'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _isListening ? _stopListening : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelConfigCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wake word', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _keywordLabelController,
              enabled: !_isListening && !_isStarting,
              decoration: const InputDecoration(
                labelText: 'Wake-word label',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Uses the bundled English sherpa-onnx wake-word model. Model files '
              'and keyword tokenization are managed automatically.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureConfigCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Capture tuning',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _SliderRow(
              label: 'Sensitivity',
              value: _sensitivity,
              min: 0,
              max: 1,
              divisions: 20,
              enabled: !_isListening && !_isStarting,
              onChanged: (value) => setState(() => _sensitivity = value),
            ),
            _SliderRow(
              label: 'Post-wake discard',
              value: _postWakeDelay.inMilliseconds.toDouble(),
              min: 0,
              max: 600,
              divisions: 12,
              enabled: !_isListening && !_isStarting,
              valueLabel: '${_postWakeDelay.inMilliseconds} ms',
              onChanged: (value) {
                setState(
                  () => _postWakeDelay = Duration(milliseconds: value.round()),
                );
              },
            ),
            _SliderRow(
              label: 'End silence',
              value: _endSilenceDuration.inMilliseconds.toDouble(),
              min: 400,
              max: 2000,
              divisions: 16,
              enabled: !_isListening && !_isStarting,
              valueLabel: '${_endSilenceDuration.inMilliseconds} ms',
              onChanged: (value) {
                setState(
                  () => _endSilenceDuration = Duration(
                    milliseconds: value.round(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completed commands',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_commands.isEmpty)
              const Text('No commands captured yet.')
            else
              ..._commands.map((command) {
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.record_voice_over),
                  title: Text('#${command.id} ${command.wakeWord}'),
                  subtitle: Text(
                    '${command.duration.inMilliseconds} ms · ${command.byteCount} bytes',
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_logs.isEmpty) const Text('No logs yet.'),
            for (final log in _logs.take(40))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(log, style: Theme.of(context).textTheme.bodySmall),
              ),
          ],
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.enabled,
    required this.onChanged,
    this.valueLabel,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final String? valueLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${valueLabel ?? value.toStringAsFixed(2)}'),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          label: valueLabel ?? value.toStringAsFixed(2),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}

final class _CommandSummary {
  const _CommandSummary({
    required this.id,
    required this.wakeWord,
    required this.duration,
    required this.byteCount,
  });

  final int id;
  final String wakeWord;
  final Duration duration;
  final int byteCount;
}
