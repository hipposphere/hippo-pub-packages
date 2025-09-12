import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

const double _cardRadius = 8.0;

enum TileControlAffinity { leading, trailing }

class Tile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showArrowIndicator;
  final bool isFirst, isLast;
  final bool ignorePointer;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final bool enabled;
  const Tile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showArrowIndicator = false,
    this.isFirst = false,
    this.isLast = false,
    this.ignorePointer = false,
    this.enabled = true,
    this.contentPadding,
    this.borderRadius = _cardRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleTappable(
      scaleDown: false,
      onTap: enabled ? onTap : null,
      radius: _borderRadius,
      child: IgnorePointer(
        ignoring: ignorePointer,
        child: ListTile(
          leading: leading,
          contentPadding: contentPadding,
          title: title,
          subtitle: subtitle,
          enabled: enabled,
          mouseCursor: MouseCursor.defer,
          trailing: DefaultTextStyle(
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: context.onBrightness(light: Colors.black, dark: Colors.white),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailing != null) trailing!,
                Gap(2),
                if (showArrowIndicator) TileArrowIndicator(enabled: enabled),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BorderRadius get _borderRadius => BorderRadius.only(
    topLeft: isFirst ? Radius.circular(borderRadius) : Radius.zero,
    topRight: isFirst ? Radius.circular(borderRadius) : Radius.zero,
    bottomLeft: isLast ? Radius.circular(borderRadius) : Radius.zero,
    bottomRight: isLast ? Radius.circular(borderRadius) : Radius.zero,
  );
}

class TileArrowIndicator extends StatelessWidget {
  final bool enabled;
  const TileArrowIndicator({super.key, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2.0),
      child: Icon(
        Icons.chevron_right,
        color: enabled
            ? Theme.of(context).dividerColor
            : Theme.of(context).dividerColor.withValues(alpha: 0.5),
      ),
    );
  }
}

class TileCircleAvatar extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double radius;
  const TileCircleAvatar({super.key, required this.child, this.backgroundColor, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(radius: radius, backgroundColor: backgroundColor, child: child);
  }
}

class TileCard extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showArrowIndicator;
  final bool ignorePointer;
  final double borderRadius;
  final bool enabled;
  const TileCard({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showArrowIndicator = false,
    this.ignorePointer = false,
    this.enabled = true,
    this.borderRadius = _cardRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Tile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        showArrowIndicator: showArrowIndicator,
        ignorePointer: ignorePointer,
        borderRadius: borderRadius,
        isFirst: true,
        isLast: true,
        enabled: enabled,
      ),
    );
  }
}

class TileGradientCard extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showArrowIndicator;
  final bool ignorePointer;
  final double borderRadius;
  final bool enabled;
  const TileGradientCard({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showArrowIndicator = false,
    this.ignorePointer = false,
    this.enabled = true,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return HippoGradientCard(
      padding: EdgeInsets.zero,
      child: Tile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        showArrowIndicator: showArrowIndicator,
        ignorePointer: ignorePointer,
        borderRadius: borderRadius,
        isFirst: true,
        isLast: true,
        enabled: enabled,
      ),
    );
  }
}

class LinkTile extends StatelessWidget {
  final Uri uri;
  final LinkTarget target;
  final bool isFirst, isLast;
  final Widget? leading, title, subtitle, trailing;

  const LinkTile({
    super.key,
    required this.uri,
    this.target = LinkTarget.blank,
    this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tile(
      title: title,
      leading: leading,
      subtitle: subtitle,
      trailing: trailing,
      onTap: () {
        launchUrl(uri);
      },
      isFirst: isFirst,
      isLast: isLast,
      showArrowIndicator: true,
    );
    // return Link(
    //   uri: uri,
    //   target: target,
    //   builder: (context, followLink) {
    //     return Tile(
    //       title: title,
    //       leading: leading,
    //       subtitle: subtitle,
    //       trailing: trailing,
    //       onTap: () {
    //         followLink!();
    //       },
    //       isFirst: isFirst,
    //       isLast: isLast,
    //       showArrowIndicator: true,
    //     );
    //   },
    // );
  }
}

class CheckboxTile extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;
  final Widget? title;
  final Widget? subtitle;
  final bool value;
  final bool enabled;
  final Function(bool newValue)? onChanged;
  final bool isFirst, isLast;
  final TileControlAffinity controlAffinity;
  const CheckboxTile({
    super.key,
    this.title,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.isFirst = false,
    this.isLast = false,
    this.leading,
    this.trailing,
    this.subtitle,
    this.controlAffinity = TileControlAffinity.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Tile(
      onTap: enabled && onChanged != null
          ? () {
              onChanged!(!value);
            }
          : null,
      leading: controlAffinity == TileControlAffinity.leading
          ? IgnorePointer(
              child: Checkbox.adaptive(
                value: value,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: enabled && onChanged != null ? (value) {} : null,
              ),
            )
          : leading,
      trailing: controlAffinity == TileControlAffinity.trailing
          ? IgnorePointer(
              child: Checkbox.adaptive(
                value: value,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: enabled && onChanged != null ? (value) {} : null,
              ),
            )
          : trailing,
      title: title,
      isFirst: isFirst,
      isLast: isLast,
    );
  }
}

class RadioTile extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final bool value;
  final bool enabled;
  final VoidCallback? onTap;
  final bool isFirst, isLast;
  final TileControlAffinity controlAffinity;
  final Icon? icon;

  const RadioTile({
    super.key,
    this.title,
    this.subtitle,
    required this.value,
    required this.onTap,
    this.enabled = true,
    this.isFirst = false,
    this.isLast = false,
    this.icon,
    this.controlAffinity = TileControlAffinity.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Tile(
      onTap: enabled ? onTap : null,
      leading: controlAffinity == TileControlAffinity.leading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IgnorePointer(
                  child: Radio.adaptive(
                    value: true,
                    // ignore: deprecated_member_use
                    groupValue: value,
                    // ignore: deprecated_member_use
                    onChanged: enabled && onTap != null ? (value) {} : null,
                  ),
                ),
              ],
            )
          : (icon != null ? TileCircleAvatar(child: icon!) : null),
      trailing: controlAffinity == TileControlAffinity.trailing
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IgnorePointer(
                  child: Radio.adaptive(
                    value: true,
                    // ignore: deprecated_member_use
                    groupValue: value,
                    // ignore: deprecated_member_use
                    onChanged: enabled && onTap != null ? (value) {} : null,
                  ),
                ),
              ],
            )
          : (icon != null ? TileCircleAvatar(child: icon!) : null),
      title: title,
      subtitle: subtitle,
      isFirst: isFirst,
      isLast: isLast,
    );
  }
}

class SwitchTile extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final bool value;
  final bool enabled;
  final Function(bool newValue)? onChanged;
  final bool isFirst, isLast;
  final TileControlAffinity controlAffinity;
  const SwitchTile({
    super.key,
    this.title,
    this.subtitle,
    this.enabled = true,
    required this.value,
    required this.onChanged,
    this.isFirst = false,
    this.isLast = false,
    this.controlAffinity = TileControlAffinity.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Tile(
      onTap: enabled && onChanged != null
          ? () {
              onChanged!(!value);
            }
          : null,
      leading: controlAffinity == TileControlAffinity.leading
          ? IgnorePointer(
              child: Switch.adaptive(
                value: value,
                onChanged: enabled && onChanged != null ? (value) {} : null,
              ),
            )
          : null,
      trailing: controlAffinity == TileControlAffinity.trailing
          ? IgnorePointer(
              child: Switch.adaptive(
                value: value,
                onChanged: enabled && onChanged != null ? (value) {} : null,
              ),
            )
          : null,
      title: title,
      subtitle: subtitle,
      isFirst: isFirst,
      isLast: isLast,
    );
  }
}

class SelectTile<T> extends StatelessWidget {
  final T? value;
  final List<T> options;
  final Widget? title;
  final Widget? subtitle;
  final bool enabled;
  final Function(T newValue)? onChanged;
  final String Function(BuildContext context, T value) displayNameBuilder;
  final bool isFirst, isLast;
  const SelectTile({
    super.key,
    required this.value,
    required this.options,
    this.title,
    this.subtitle,
    this.enabled = true,
    required this.onChanged,
    required this.displayNameBuilder,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tile(
      onTap: enabled ? () {} : null,
      title: title,
      subtitle: subtitle,
      trailing: DropdownButton<T>(
        value: value,
        items: options.map((option) {
          return DropdownMenuItem<T>(
            value: option,
            child: Text(displayNameBuilder(context, option)),
          );
        }).toList(),
        onChanged: enabled
            ? (newValue) {
                if (newValue != null) {
                  onChanged!(newValue);
                }
              }
            : null,
      ),
      isFirst: isFirst,
      isLast: isLast,
    );
  }
}

class TileTappableChild extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final String? tooltip;
  final bool enabled;
  const TileTappableChild({
    super.key,
    required this.onTap,
    required this.child,
    this.tooltip,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleTappable(
      onTap: enabled ? onTap : null,
      margin: EdgeInsets.all(8),
      tooltip: tooltip,
      child: IconTheme(
        data: IconTheme.of(context).copyWith(
          color: enabled
              ? Theme.of(context).dividerColor
              : Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
        child: child,
      ),
    );
  }
}
