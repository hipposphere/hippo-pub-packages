// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:desktop_autopaste/desktop_autopaste.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_api/hotkey_api.dart';

class ContextPage extends StatefulWidget {
  const ContextPage({super.key});

  @override
  State<ContextPage> createState() => _ContextPageState();
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

class _ContextPageState extends State<ContextPage> {
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
    initialHotkey: Hotkey.single(switch (defaultTargetPlatform) {
      .macOS => PhysicalKeyboardKey.metaRight,
      .windows => PhysicalKeyboardKey.controlRight,
      _ => PhysicalKeyboardKey.f8,
    }),
  );

  StreamSubscription<HotkeyStatusType>? _hotkeySubscription;
  bool _isCapturing = false;
  bool _enableScreenReader = true;
  bool _swapOnHotkey = false;
  SemanticsHandle? _semanticsHandle;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _hotkeySubscription = _hotkeyController.streamHotkeyStatusType().listen((
      status,
    ) {
      if (status == HotkeyStatusType.pressed) {
        if (_swapOnHotkey) {
          print('Hotkey pressed, swapping aha/uhu...');
          _swapAhaUhuInFocusedField();
        } else {
          print('Hotkey pressed, capturing context...');
          _captureContext(trigger: 'hotkey');
        }
      }
    });
  }

  @override
  void dispose() {
    _semanticsHandle?.dispose();
    _hotkeySubscription?.cancel();
    _hotkeyController.close();
    _beforeCharsController.dispose();
    _afterCharsController.dispose();
    super.dispose();
  }

  int? _readLimit(TextEditingController controller, int fallback) {
    final raw = controller.text.trim();
    if (raw.isEmpty) return null;
    final parsed = int.tryParse(raw);
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
        enableScreenReader: _enableScreenReader,
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

  Future<void> _swapAhaUhuInFocusedField() async {
    if (_isCapturing) return;
    setState(() {
      _isCapturing = true;
      _lastError = null;
    });

    try {
      final context = await _autopaste.getFocusedTextFieldContext(
        maxCharsBefore: null,
        maxCharsAfter: null,
        enableScreenReader: _enableScreenReader,
      );
      if (!context.available) {
        if (!mounted) return;
        setState(() {
          _lastError =
              'Focused field context unavailable (${context.reason ?? 'unknown'}).';
        });
        return;
      }

      final fullText =
          (context.textBeforeSelection ?? '') +
          (context.selectedText ?? '') +
          (context.textAfterSelection ?? '');

      final operations = <FocusedTextEditOperation>[];
      int index = 0;
      while (index < fullText.length) {
        if (index + 3 <= fullText.length &&
            fullText.substring(index, index + 3) == 'aha') {
          operations.add(
            FocusedTextEditOperation.replaceRange(
              start: index,
              end: index + 3,
              replacement: 'uhu',
            ),
          );
          index += 3;
          continue;
        }
        if (index + 3 <= fullText.length &&
            fullText.substring(index, index + 3) == 'uhu') {
          operations.add(
            FocusedTextEditOperation.replaceRange(
              start: index,
              end: index + 3,
              replacement: 'aha',
            ),
          );
          index += 3;
          continue;
        }
        index += 1;
      }

      operations.sort((a, b) => b.start.compareTo(a.start));
      final ok = operations.isEmpty
          ? true
          : await _autopaste.editFocusedTextField(operations);
      if (!mounted) return;
      if (!ok) {
        setState(() {
          _lastError =
              'Focused field could not be edited (unsupported control or read-only).';
        });
      }
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
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _isCapturing
                              ? null
                              : _swapAhaUhuInFocusedField,
                          icon: const Icon(Icons.edit_note_outlined),
                          label: const Text('Swap aha/uhu'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _swapOnHotkey,
                      title: const Text('Hotkey triggers aha/uhu swap'),
                      subtitle: const Text(
                        'If off, hotkey captures context instead.',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _swapOnHotkey = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _enableScreenReader,
                      title: const Text('Enable screen reader context capture'),
                      subtitle: const Text(
                        'Disabled by default. Enable to use accessibility APIs.',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _enableScreenReader = value;
                          if (_enableScreenReader) {
                            _semanticsHandle ??= WidgetsBinding.instance
                                .ensureSemantics();
                          } else {
                            _semanticsHandle?.dispose();
                            _semanticsHandle = null;
                          }
                        });
                      },
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
