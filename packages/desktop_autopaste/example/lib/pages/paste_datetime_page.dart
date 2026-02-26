import 'dart:async';

import 'package:desktop_autopaste/desktop_autopaste.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:hotkey_api/hotkey_api.dart';

Future<void> openPasteDateTimePage(BuildContext context) async {
  final bloc = _Bloc();
  await Routing.openPage(
    context,
    BlocProvider<_Bloc>(bloc: bloc, child: const PasteDateTimePage()),
  );
  bloc.dispose();
}

class _Bloc extends BlocBase {
  final _autopaste = DesktopAutopaste();
  final hotkeyController = HotkeyStatusController(
    initialHotkey: Hotkey.single(switch (defaultTargetPlatform) {
      TargetPlatform.windows => PhysicalKeyboardKey.controlLeft,
      TargetPlatform.macOS => PhysicalKeyboardKey.metaLeft,
      _ => PhysicalKeyboardKey.f8,
    }),
  );

  final isPasting = DataSubject<bool>.seeded(false);
  final lastPastedText = DataSubject<String?>.seeded(null);
  final lastError = DataSubject<String?>.seeded(null);
  StreamSubscription<HotkeyStatusType>? _hotkeySubscription;
  bool _isDisposed = false;

  _Bloc() {
    _hotkeySubscription = hotkeyController.streamHotkeyStatusType().listen((
      status,
    ) {
      if (status == HotkeyStatusType.pressed) {
        debugPrint('Hotkey pressed, attempting to paste current DateTime...');
        pasteNow();
      }
    });
  }

  static _Bloc of(BuildContext context) {
    return BlocProvider.of<_Bloc>(context);
  }

  Future<void> pasteNow() async {
    if (isPasting.value || _isDisposed) return;
    isPasting.add(true);
    lastError.add(null);

    try {
      final text = DateTime.now().toIso8601String();
      final ok = await _autopaste.pasteIntoCursorViaClipboard(text);
      if (_isDisposed) return;
      if (ok) {
        lastPastedText.add(text);
      } else {
        lastError.add('Paste failed.');
      }
    } catch (error) {
      if (_isDisposed) return;
      lastError.add(error.toString());
    } finally {
      if (!_isDisposed) {
        isPasting.add(false);
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _hotkeySubscription?.cancel();
    hotkeyController.close();
    isPasting.close();
    lastPastedText.close();
    lastError.close();
  }
}

class PasteDateTimePage extends StatelessWidget {
  const PasteDateTimePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = _Bloc.of(context);
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
                DataSubjectBuilder<Hotkey?>(
                  subject: bloc.hotkeyController.hotkeySubject,
                  builder: (context, selectedHotkey) {
                    if (selectedHotkey == null) {
                      return const Text('No hotkey selected');
                    }
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
                                  bloc.hotkeyController.setHotkey(hotkey);
                                }
                              },
                              icon: const Icon(Icons.keyboard_outlined),
                              label: const Text('Select hotkey'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                bloc.hotkeyController.hotkeySubject.add(null);
                              },
                              icon: const Icon(Icons.clear_outlined),
                              label: const Text('Clear hotkey'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        HotkeyChip(hotkey: selectedHotkey),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                  emptyBuilder: (context) => const Text('No hotkey selected'),
                ),
                DataSubjectBuilder<bool>(
                  subject: bloc.isPasting,
                  builder: (context, isPasting) {
                    return FilledButton.icon(
                      onPressed: isPasting ? null : bloc.pasteNow,
                      icon: const Icon(Icons.paste_outlined),
                      label: const Text('Paste current DateTime'),
                    );
                  },
                ),
                Gap(8),
                DataSubjectBuilder<bool>(
                  subject: bloc.isPasting,
                  builder: (context, isPasting) {
                    return FilledButton.icon(
                      onPressed: isPasting
                          ? null
                          : () {
                              Future.delayed(const Duration(seconds: 1), () {
                                bloc.pasteNow();
                              });
                            },
                      icon: const Icon(Icons.paste_outlined),
                      label: const Text('Paste current DateTime (1s delay)'),
                    );
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
                DataSubjectBuilder<String?>(
                  subject: bloc.lastPastedText,
                  emptyBuilder: (_) => const SizedBox.shrink(),
                  builder: (context, text) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text('Last pasted: $text'),
                      ],
                    );
                  },
                ),
                DataSubjectBuilder<String?>(
                  subject: bloc.lastError,
                  builder: (context, error) {
                    if (error == null) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          error,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    );
                  },
                  emptyBuilder: (_) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
