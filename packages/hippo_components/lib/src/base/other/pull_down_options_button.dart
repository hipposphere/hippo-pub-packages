import 'package:flutter/cupertino.dart';
import 'package:hippo_components/hippo_components.dart';
export 'package:pull_down_button/pull_down_button.dart';

class PullDownMenuOption<T> {
  final IconData? iconData;
  final Widget? iconWidget;
  final String title;
  final String? subtitle;

  PullDownMenuOption({this.iconData, required this.title, this.subtitle, this.iconWidget});
}

class PullDownOptionsButton<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final PullDownMenuOption Function(BuildContext context, T item) optionBuilder;
  final ValueChanged<T> onSelect;
  final double size;
  const PullDownOptionsButton({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.optionBuilder,
    required this.onSelect,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) {
        final options = items.map((e) => (e, optionBuilder(context, e))).toList();
        return [
          for (final (value, option) in options)
            PullDownMenuItem.selectable(
              onTap: () {
                onSelect(value);
              },
              icon: option.iconData,
              iconWidget: option.iconWidget,
              title: option.title,
              subtitle: option.subtitle,
              selected: value == selectedItem,
            ),
        ];
      },
      buttonBuilder: (context, showMenu) {
        final option = selectedItem != null ? optionBuilder(context, selectedItem as T) : null;
        return SimpleTappable(
          onTap: showMenu,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: option == null
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.cl.actions_select,
                        style: TextStyle(fontSize: size, fontWeight: FontWeight.bold),
                      ),
                      Gap(4),
                      Icon(CupertinoIcons.chevron_down, size: size),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (option.iconData != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(option.iconData, size: size),
                        ),
                      Text(
                        option.title,
                        style: TextStyle(fontSize: size, fontWeight: FontWeight.bold),
                      ),
                      Gap(4),
                      Icon(CupertinoIcons.chevron_down, size: size),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
