import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

class TappableChip extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;
  final Widget? label;
  final Color? color;
  final String? tooltip;
  final VoidCallback? onTap;
  final BoxBorder? border;
  final BorderRadius radius;
  final bool underlineTextOnHover;
  final MainAxisAlignment mainAxisAlignment;
  final EdgeInsets padding;
  const TappableChip({
    super.key,
    this.onTap,
    this.leading,
    this.trailing,
    this.label,
    this.color,
    this.tooltip,
    this.border,
    this.radius = const BorderRadius.all(Radius.circular(8.0)),
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.underlineTextOnHover = true,
    this.padding = const EdgeInsets.all(4),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Tappable(
        color:
            color ??
            context.onBrightness(
              light: HippoColors.hoverLightColor.withValues(alpha: 0.5),
              dark: HippoColors.hoverDarkColor.withValues(alpha: 0.5),
            ),
        tooltip: tooltip,
        onTap: onTap,
        border: border,
        radius: radius,
        builder: (context, isHovered, isFocused) {
          return IconTheme(
            data: IconTheme.of(context).copyWith(size: 16),
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.copyWith(
                fontSize: 14,
                decoration: isHovered ? TextDecoration.underline : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: mainAxisAlignment,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Gap(4),
                    if (leading != null) ...[leading!, Gap(4)],
                    if (label != null) Flexible(child: label!),
                    if (trailing != null) ...[Gap(4), trailing!],
                    Gap(4),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TonalTappableChip extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;
  final Widget? label;
  final BorderRadius radius;
  final VoidCallback? onTap;
  final bool underlineTextOnHover;
  const TonalTappableChip({
    super.key,
    this.onTap,
    this.leading,
    this.trailing,
    this.label,
    this.radius = const BorderRadius.all(Radius.circular(8.0)),
    this.underlineTextOnHover = true,
  });

  @override
  Widget build(BuildContext context) {
    return TappableChip(
      onTap: onTap,
      leading: leading,
      trailing: trailing,
      label: label,
      radius: radius,
      color: HippoColors.primaryLightened.withValues(alpha: 0.7),
      underlineTextOnHover: underlineTextOnHover,
    );
  }
}

class ChipSymbolTappable extends StatelessWidget {
  final IconData iconData;
  final VoidCallback onTap;
  final String? tooltip;
  const ChipSymbolTappable({super.key, required this.iconData, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return SimpleTappable(
      onTap: onTap,
      tooltip: tooltip,
      child: Padding(padding: const EdgeInsets.all(4.0), child: Icon(iconData)),
    );
  }
}
