import 'dart:async';

import 'package:desktop_autopaste/desktop_autopaste.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
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
  static const prePasteDelayPresetsMs = <int>[0, 50, 100, 250, 500, 1000];

  final _autopaste = DesktopAutopaste();
  final hotkeyController = HotkeyStatusController(
    initialHotkey: Hotkey.single(switch (defaultTargetPlatform) {
      TargetPlatform.windows => PhysicalKeyboardKey.f8,
      TargetPlatform.macOS => PhysicalKeyboardKey.metaLeft,
      _ => PhysicalKeyboardKey.f8,
    }),
  );

  final isPasting = DataSubject<bool>.seeded(false);
  final prePasteDelayMs = DataSubject<int>.seeded(0);
  final pasteShortcut = DataSubject<DesktopAutopastePasteShortcut>.seeded(
    DesktopAutopastePasteShortcut.ctrlV,
  );
  final lastPastedText = DataSubject<String?>.seeded(null);
  final lastError = DataSubject<String?>.seeded(null);
  StreamSubscription<HotkeyStatusType>? _hotkeySubscription;
  bool _isDisposed = false;

  _Bloc() {
    _hotkeySubscription = hotkeyController.streamHotkeyStatusType().listen((
      status,
    ) {
      if (status == HotkeyStatusType.released) {
        debugPrint('Hotkey released, attempting to paste current DateTime...');
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
      final ok = await _autopaste.pasteIntoCursorViaClipboard(
        text,
        prePasteDelay: Duration(milliseconds: prePasteDelayMs.value),
        pasteShortcut: pasteShortcut.value,
      );
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
    prePasteDelayMs.close();
    pasteShortcut.close();
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
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
                  DataSubjectBuilder<int>(
                    subject: bloc.prePasteDelayMs,
                    builder: (context, prePasteDelayMs) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pre-paste delay: ${prePasteDelayMs}ms',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Useful for Citrix or other remote-hosted apps that need time to sync clipboard contents before paste is sent.',
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _Bloc.prePasteDelayPresetsMs.map((ms) {
                              return ChoiceChip(
                                label: Text('${ms}ms'),
                                selected: prePasteDelayMs == ms,
                                onSelected: (_) {
                                  bloc.prePasteDelayMs.add(ms);
                                },
                              );
                            }).toList(),
                          ),
                          Slider.adaptive(
                            value: prePasteDelayMs.toDouble(),
                            min: 0,
                            max: 1000,
                            divisions: 20,
                            label: '${prePasteDelayMs}ms',
                            onChanged: (value) {
                              bloc.prePasteDelayMs.add(value.round());
                            },
                          ),
                        ],
                      );
                    },
                    emptyBuilder: (_) => const SizedBox.shrink(),
                  ),
                  if (defaultTargetPlatform == TargetPlatform.windows)
                    DataSubjectBuilder<DesktopAutopastePasteShortcut>(
                      subject: bloc.pasteShortcut,
                      builder: (context, pasteShortcut) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Paste shortcut',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ChoiceChip(
                                  label: const Text('Ctrl+V'),
                                  selected:
                                      pasteShortcut ==
                                      DesktopAutopastePasteShortcut.ctrlV,
                                  onSelected: (_) {
                                    bloc.pasteShortcut.add(
                                      DesktopAutopastePasteShortcut.ctrlV,
                                    );
                                  },
                                ),
                                ChoiceChip(
                                  label: const Text('Shift+Insert'),
                                  selected:
                                      pasteShortcut ==
                                      DesktopAutopastePasteShortcut.shiftInsert,
                                  onSelected: (_) {
                                    bloc.pasteShortcut.add(
                                      DesktopAutopastePasteShortcut.shiftInsert,
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                      emptyBuilder: (_) => const SizedBox.shrink(),
                    ),
                  const SizedBox(height: 8),
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
        ],
      ),
    );
  }
}
