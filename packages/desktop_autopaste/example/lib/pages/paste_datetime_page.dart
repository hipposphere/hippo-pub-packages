import 'dart:async';

import 'package:desktop_autopaste/desktop_autopaste.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:hotkey_api/hotkey_api.dart';

class PasteDateTimePage extends StatefulWidget {
  const PasteDateTimePage({super.key});

  @override
  State<PasteDateTimePage> createState() => _PasteDateTimePageState();
}

class _PasteDateTimePageState extends State<PasteDateTimePage> {
  final _autopaste = DesktopAutopaste();
  final _hotkeyController = HotkeyStatusController(
    initialHotkey: Hotkey.single(switch (defaultTargetPlatform) {
      .macOS => PhysicalKeyboardKey.metaRight,
      .windows => PhysicalKeyboardKey.controlRight,
      _ => PhysicalKeyboardKey.f8,
    }),
  );

  StreamSubscription<HotkeyStatusType>? _hotkeySubscription;
  bool _isPasting = false;
  String? _lastPastedText;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _hotkeySubscription = _hotkeyController.streamHotkeyStatusType().listen((
      status,
    ) {
      if (status == HotkeyStatusType.pressed) {
        _pasteNow();
      }
    });
  }

  @override
  void dispose() {
    _hotkeySubscription?.cancel();
    _hotkeyController.close();
    super.dispose();
  }

  Future<void> _pasteNow() async {
    if (_isPasting) return;
    setState(() {
      _isPasting = true;
      _lastError = null;
    });

    try {
      final text = DateTime.now().toIso8601String();
      final ok = await _autopaste.pasteIntoCursorViaClipboard(text);
      if (!mounted) return;
      setState(() {
        if (ok) {
          _lastPastedText = text;
        } else {
          _lastError = 'Paste failed.';
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
          _isPasting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paste Current DateTime')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Focus any text field in any app, then press your selected hotkey to paste the current date/time via clipboard.',
                ),
                const SizedBox(height: 12),
                DataSubjectBuilder(
                  subject: _hotkeyController.hotkeySubject,
                  builder: (context, selectedHotkey) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: () async {
                                final hotkey = await SelectHotkeyModal(
                                  initialHotkey: selectedHotkey,
                                ).open(context);
                                if (hotkey != null) {
                                  _hotkeyController.setHotkey(hotkey);
                                }
                              },
                              icon: const Icon(Icons.keyboard_outlined),
                              label: const Text('Select hotkey'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: selectedHotkey == null
                                  ? null
                                  : () {
                                      _hotkeyController.hotkeySubject.add(null);
                                    },
                              icon: const Icon(Icons.clear_outlined),
                              label: const Text('Clear hotkey'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (selectedHotkey != null)
                          HotkeyChip(hotkey: selectedHotkey)
                        else
                          const Text('No hotkey selected'),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
                FilledButton.icon(
                  onPressed: _isPasting ? null : _pasteNow,
                  icon: const Icon(Icons.paste_outlined),
                  label: const Text('Paste current DateTime'),
                ),
                const SizedBox(height: 12),
                const TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Local test field',
                  ),
                ),
                if (_lastPastedText != null) ...[
                  const SizedBox(height: 12),
                  Text('Last pasted: $_lastPastedText'),
                ],
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
    );
  }
}
