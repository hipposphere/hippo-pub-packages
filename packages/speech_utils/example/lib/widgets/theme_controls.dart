import 'package:flutter/material.dart';

String themeModeLabel(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };
}

void showExampleThemeModeSheet({
  required BuildContext context,
  required ThemeMode currentThemeMode,
  required ValueChanged<ThemeMode> onThemeModeChanged,
}) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                selected: <ThemeMode>{currentThemeMode},
                segments: const <ButtonSegment<ThemeMode>>[
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.brightness_auto),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode),
                  ),
                ],
                onSelectionChanged: (selection) {
                  final next = selection.firstOrNull;
                  if (next == null) {
                    return;
                  }
                  onThemeModeChanged(next);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class ThemeActionButton extends StatelessWidget {
  const ThemeActionButton({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Theme settings',
      icon: const Icon(Icons.palette_outlined),
      onPressed: () {
        showExampleThemeModeSheet(
          context: context,
          currentThemeMode: themeMode,
          onThemeModeChanged: onThemeModeChanged,
        );
      },
    );
  }
}
