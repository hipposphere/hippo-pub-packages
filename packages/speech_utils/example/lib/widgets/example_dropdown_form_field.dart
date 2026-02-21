import 'package:flutter/material.dart';

final class ExampleDropdownOption<T> {
  const ExampleDropdownOption({required this.value, required this.label});

  final T value;
  final String label;
}

class ExampleDropdownFormField<T> extends StatelessWidget {
  const ExampleDropdownFormField({
    super.key,
    required this.initialValue,
    required this.decoration,
    required this.options,
    this.onChanged,
    this.menuMaxHeight,
  });

  final T? initialValue;
  final InputDecoration decoration;
  final List<ExampleDropdownOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final double? menuMaxHeight;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      isExpanded: true,
      decoration: decoration,
      menuMaxHeight: menuMaxHeight,
      items: options
          .map(
            (option) => DropdownMenuItem<T>(
              value: option.value,
              child: Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(growable: false),
      selectedItemBuilder: (context) {
        return options
            .map(
              (option) => Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(growable: false);
      },
      onChanged: onChanged,
    );
  }
}
