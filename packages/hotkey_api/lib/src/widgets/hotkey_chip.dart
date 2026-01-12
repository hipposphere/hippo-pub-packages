import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hotkey_api/hotkey_api.dart';

class HotkeyChip extends StatelessWidget {
  final Hotkey hotkey;
  const HotkeyChip({super.key, required this.hotkey});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2,
      runSpacing: 2,
      children: [
        for (final key in hotkey.physicalKeys)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              PhysicalKeyChip(physicalKey: key),
              if (key != hotkey.physicalKeys.last) Icon(Icons.add, size: 16),
            ],
          ),
      ],
    );
  }
}

class PhysicalKeyChip extends StatelessWidget {
  final PhysicalKeyboardKey physicalKey;
  const PhysicalKeyChip({super.key, required this.physicalKey});

  @override
  Widget build(BuildContext context) {
    return TappableChip(label: Text(KeySymbols.getSymbol(physicalKey)));
  }
}
