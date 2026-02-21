import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:speech_utils_example/pages/file_recorder_page.dart';
import 'package:speech_utils_example/pages/integrated_vad_compression_page.dart';
import 'package:speech_utils_example/pages/simple_recording_page.dart';
import 'package:speech_utils_example/widgets/theme_controls.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SpeechUtilsExampleApp());
}

class SpeechUtilsExampleApp extends StatefulWidget {
  const SpeechUtilsExampleApp({super.key});

  @override
  State<SpeechUtilsExampleApp> createState() => _SpeechUtilsExampleAppState();
}

class _SpeechUtilsExampleAppState extends State<SpeechUtilsExampleApp>
    with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.system;

  Brightness get _effectiveBrightness {
    return switch (_themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness,
    };
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    if (_themeMode != ThemeMode.system || !mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return App(
      brightness: _effectiveBrightness,
      title: 'speech_utils Example',
      home: _SpeechUtilsHomePage(
        themeMode: _themeMode,
        onThemeModeChanged: (mode) {
          setState(() {
            _themeMode = mode;
          });
        },
      ),
    );
  }
}

class _SpeechUtilsHomePage extends StatelessWidget {
  const _SpeechUtilsHomePage({
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('speech_utils Example'),
        actions: [
          ThemeActionButton(
            themeMode: themeMode,
            onThemeModeChanged: onThemeModeChanged,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Examples', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          _ExamplePageCard(
            title: 'File Recorder (start/stop)',
            description:
                'Direct capture with start/stop lifecycle and configurable codec, sample rate, channels, bitrate, and device selection.',
            icon: Icons.mic_external_on,
            onOpen: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => FileRecordingPage(
                    themeMode: themeMode,
                    onThemeModeChanged: onThemeModeChanged,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _ExamplePageCard(
            title: 'Integrated VAD + Compression',
            description:
                'Live stream segmentation, synthetic checks, snippet conversion, and full-recording AAC.',
            icon: Icons.hub,
            onOpen: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => IntegratedVadCompressionPage(
                    detectAacOnStartup: true,
                    themeMode: themeMode,
                    onThemeModeChanged: onThemeModeChanged,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _ExamplePageCard(
            title: 'Simple Recorder + Waveform',
            description:
                'Focused recording page with loudness, speech-threshold detection, device selection, and WAV playback.',
            icon: Icons.multitrack_audio,
            onOpen: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SimpleRecordingPage(
                    themeMode: themeMode,
                    onThemeModeChanged: onThemeModeChanged,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Current theme: ${themeModeLabel(themeMode)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ExamplePageCard extends StatelessWidget {
  const _ExamplePageCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onOpen,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Open'),
            ),
          ],
        ),
      ),
    );
  }
}
