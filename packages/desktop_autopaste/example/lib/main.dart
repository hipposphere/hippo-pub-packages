// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:desktop_autopaste/desktop_autopaste.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_api/hotkey_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _ExampleApp());
}

class _ExampleApp extends StatelessWidget {
  const _ExampleApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focused Text Context Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const _HomePage(),
    );
  }
}

class _ContextLogEntry {
  const _ContextLogEntry({
    required this.timestamp,
    required this.trigger,
    required this.context,
  });

  final DateTime timestamp;
  final String trigger;
  final FocusedTextFieldContext context;
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  static const _defaultBeforeChars = 120;
  static const _defaultAfterChars = 120;

  final _autopaste = DesktopAutopaste();
  final _beforeCharsController = TextEditingController(
    text: '$_defaultBeforeChars',
  );
  final _afterCharsController = TextEditingController(
    text: '$_defaultAfterChars',
  );
  final _logEntries = <_ContextLogEntry>[];
  final _jsonEncoder = const JsonEncoder.withIndent('  ');
  final _hotkeyController = HotkeyStatusController(
    initialHotkey: Hotkey.single(PhysicalKeyboardKey.metaRight),
  );

  StreamSubscription<HotkeyStatusType>? _hotkeySubscription;
  bool _isCapturing = false;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _hotkeySubscription = _hotkeyController.streamHotkeyStatusType().listen((
      status,
    ) {
      if (status == HotkeyStatusType.pressed) {
        print('Hotkey pressed, capturing context...');
        _captureContext(trigger: 'hotkey');
      }
    });
  }

  @override
  void dispose() {
    _hotkeySubscription?.cancel();
    _hotkeyController.close();
    _beforeCharsController.dispose();
    _afterCharsController.dispose();
    super.dispose();
  }

  int _readLimit(TextEditingController controller, int fallback) {
    final parsed = int.tryParse(controller.text);
    if (parsed == null) return fallback;
    return parsed < 0 ? 0 : parsed;
  }

  Future<void> _captureContext({required String trigger}) async {
    if (_isCapturing) return;
    setState(() {
      _isCapturing = true;
      _lastError = null;
    });

    try {
      final context = await _autopaste.getFocusedTextFieldContext(
        maxCharsBefore: _readLimit(_beforeCharsController, _defaultBeforeChars),
        maxCharsAfter: _readLimit(_afterCharsController, _defaultAfterChars),
      );

      print('Captured context: ${context.toMap()}');

      if (!mounted) return;
      setState(() {
        _logEntries.insert(
          0,
          _ContextLogEntry(
            timestamp: DateTime.now(),
            trigger: trigger,
            context: context,
          ),
        );
        if (_logEntries.length > 200) {
          _logEntries.removeRange(200, _logEntries.length);
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _lastError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focused Text Context'),
        actions: [
          IconButton(
            tooltip: 'Clear logs',
            onPressed: _logEntries.isEmpty
                ? null
                : () {
                    setState(_logEntries.clear);
                  },
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Press F8 in any app/text field to capture focused text context.',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 140,
                          child: TextField(
                            controller: _beforeCharsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Chars before',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 140,
                          child: TextField(
                            controller: _afterCharsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Chars after',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: _isCapturing
                              ? null
                              : () => _captureContext(trigger: 'button'),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Capture now'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Local test field',
                      ),
                    ),
                    if (_lastError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _lastError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _logEntries.isEmpty
                ? const Center(
                    child: Text(
                      'No captures yet. Focus a text field and press F8.',
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _logEntries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = _logEntries[index];
                      final headline =
                          '${entry.timestamp.toIso8601String()} • ${entry.trigger}';
                      final body = _jsonEncoder.convert(entry.context.toMap());
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                headline,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                body,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
