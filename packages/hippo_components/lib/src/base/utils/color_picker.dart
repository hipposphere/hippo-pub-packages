import 'package:flutter/material.dart';

class ColorOptionPicker extends StatelessWidget {
  final List<String> hexColors;
  final String selectedColor;
  final void Function(String) onColorSelected;
  final bool enabled;

  const ColorOptionPicker({
    super.key,
    required this.hexColors,
    required this.selectedColor,
    required this.onColorSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5, // visually indicate disabled state
      child: IgnorePointer(
        ignoring: !enabled, // disable taps
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: hexColors.map((hex) {
              final color = HexColor.fromHex(hex);
              final isSelected = hex == selectedColor;

              return GestureDetector(
                onTap: () => onColorSelected(hex),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.lightBlueAccent : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // Add full opacity
    return int.parse(hex, radix: 16);
  }

  static Color fromHex(String hex) => HexColor(hex);
}
