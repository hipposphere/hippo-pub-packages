import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hippo_components/hippo_components.dart';

typedef TappableBuilder = Widget Function(BuildContext context, bool isHovered, bool isFocused);

class Tappable extends StatefulWidget {
  final double? height, width;
  final Color? color, foucusBorderColor, hoverColor;
  final bool coloredHover, showFocusBorder;
  final double focusBorderWidth;
  final String? tooltip;
  final Alignment tooltipTipAnchor;
  final Alignment tooltipChildAnchor;
  final MouseCursor cursor;
  final EdgeInsets margin;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final BorderRadius radius;
  final TappableBuilder builder;
  final BoxBorder? border;
  final FocusNode? focusNode; // Optional external FocusNode
  final bool scaleDown;

  const Tappable({
    super.key,
    this.height,
    this.width,
    this.tooltip,
    this.tooltipTipAnchor = Alignment.bottomCenter,
    this.tooltipChildAnchor = Alignment.topCenter,
    this.cursor = SystemMouseCursors.click,
    this.color,
    this.hoverColor,
    this.border,
    this.coloredHover = true,
    this.focusBorderWidth = 1.0,
    this.showFocusBorder = true,
    this.foucusBorderColor,
    this.margin = const EdgeInsets.only(),
    this.radius = const BorderRadius.all(Radius.circular(8.0)),
    this.focusNode, // Accept external FocusNode
    this.scaleDown = true,
    this.onLongPress,
    required this.onTap,
    required this.builder,
  });

  @override
  State<Tappable> createState() => _TappableState();
}

class _TappableState extends State<Tappable> {
  double _scale = 1.0;
  final Duration _duration = Duration(milliseconds: 200);
  bool _isHovered = false;
  bool _isFocused = false;
  bool _isPressing = false;
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    // Initialize the FocusNode here
    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    } else {
      _focusNode = widget.focusNode!;
    }
  }

  @override
  void dispose() {
    // Dispose only if we created the FocusNode
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  Timer? _onTapDownTimer;

  void _onTapDown(TapDownDetails details) async {
    // Reset the timer if it's already running
    _onTapDownTimer?.cancel();
    _onTapDownTimer = Timer(Duration(milliseconds: 1000), () {
      _updateScale(1.0);
      if (_isPressing == true) {
        setState(() {
          _isPressing = false;
        });
      }
    });
    _updateScale(0.8);
    setState(() {
      _isPressing = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    _updateScale(1.0);
    setState(() {
      _isPressing = false;
    });
  }

  void _updateScale(double newScale) {
    if (widget.scaleDown == false) return;
    if (mounted) {
      setState(() {
        _scale = newScale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightnessHoverColor = context.onBrightness(
      light: HippoColors.hoverLightColor,
      dark: HippoColors.hoverDarkColor,
    );

    return GestureDetector(
      onTap: widget.onTap != null
          ? () {
              widget.onTap?.call();
            }
          : null,
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onLongPress: widget.onLongPress,
      child: FocusableActionDetector(
        focusNode: _focusNode,
        autofocus: false,
        mouseCursor: widget.onTap != null ? widget.cursor : MouseCursor.defer,
        descendantsAreFocusable: false,
        enabled: widget.onTap != null,
        onShowFocusHighlight: (value) {
          setState(() {
            _isFocused = value;
          });
        },
        onShowHoverHighlight: (value) {
          setState(() {
            _isHovered = value;
          });
        },
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
          LogicalKeySet(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          if (widget.onTap != null)
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (intent) async {
                widget.onTap?.call();
                _updateScale(0.8);

                // Wait for a short duration to simulate tap down effect
                await Future.delayed(Duration(milliseconds: 100));

                _updateScale(1.0);
                return null;
              },
            ),
        },
        child: OptionalTooltip(
          message: widget.tooltip,
          tipAnchor: widget.tooltipTipAnchor,
          childAnchor: widget.tooltipChildAnchor,
          child: SizedBox(
            height: widget.height,
            width: widget.width,
            child: AnimatedScale(
              scale: _scale,
              duration: _duration,
              child: AnimatedContainer(
                duration: _duration,
                decoration: BoxDecoration(
                  border: widget.border,
                  borderRadius: widget.radius,
                  color: widget.color,
                ),
                child: AnimatedContainer(
                  duration: _duration,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isFocused
                          ? brightnessHoverColor.withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                    borderRadius: widget.radius,
                    color: widget.coloredHover && (_isHovered || _isFocused || _isPressing)
                        ? (widget.hoverColor ?? brightnessHoverColor.withValues(alpha: 0.3))
                        : Colors.transparent,
                  ),
                  child: Padding(
                    padding: widget.margin,
                    child: widget.builder(context, _isHovered, _isFocused),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleTappable extends StatelessWidget {
  final double? height, width;
  final Color? color, foucusBorderColor, hoverColor;
  final bool coloredHover, showFocusBorder;
  final double focusBorderWidth;
  final String? tooltip;
  final Alignment tooltipTipAnchor;
  final Alignment tooltipChildAnchor;
  final MouseCursor cursor;
  final EdgeInsets margin;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final BorderRadius radius;
  final Widget child;
  final FocusNode? focusNode; // Optional external FocusNode
  final bool scaleDown;

  const SimpleTappable({
    super.key,
    this.height,
    this.width,
    this.tooltip,
    this.tooltipTipAnchor = Alignment.bottomCenter,
    this.tooltipChildAnchor = Alignment.topCenter,
    this.cursor = SystemMouseCursors.click,
    this.color,
    this.coloredHover = true,
    this.hoverColor,
    this.focusBorderWidth = 1.0,
    this.showFocusBorder = true,
    this.foucusBorderColor,
    this.margin = const EdgeInsets.only(),
    this.radius = const BorderRadius.all(Radius.circular(8.0)),
    this.focusNode, // Accept external FocusNode
    this.scaleDown = true,
    this.onLongPress,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      height: height,
      width: width,
      color: color,
      hoverColor: hoverColor,
      coloredHover: coloredHover,
      focusBorderWidth: focusBorderWidth,
      showFocusBorder: showFocusBorder,
      tooltip: tooltip,
      tooltipTipAnchor: tooltipTipAnchor,
      tooltipChildAnchor: tooltipChildAnchor,
      cursor: cursor,
      margin: margin,
      radius: radius,
      focusNode: focusNode,
      scaleDown: scaleDown,
      onLongPress: onLongPress,
      onTap: onTap,
      builder: (context, isHovered, isFocused) => child,
    );
  }
}

class TextIconTappable extends StatelessWidget {
  final IconData iconData;
  final String label;
  final double? height;
  final VoidCallback? onTap;
  final MainAxisAlignment mainAxisAlignment;
  final bool enabled;
  const TextIconTappable({
    super.key,
    required this.iconData,
    required this.label,
    required this.onTap,
    this.height,
    this.enabled = true,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      height: height,
      onTap: onTap,
      builder: (context, isHovered, isFocused) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: IconTheme(
            data: IconTheme.of(
              context,
            ).copyWith(color: (enabled && onTap != null) ? null : HippoColors.inactiveGray),
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.copyWith(
                color: (enabled && onTap != null) ? null : HippoColors.inactiveGray,
                decoration: isHovered ? TextDecoration.underline : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: mainAxisAlignment,
                children: [
                  Gap(4),
                  Icon(iconData),
                  Gap(4),
                  Flexible(child: Text(label)),
                  Gap(4),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class TextIconTappableWithShortCut extends StatelessWidget {
  final IconData iconData;
  final String label;
  final double? height;
  final VoidCallback? onTap;
  final MainAxisAlignment mainAxisAlignment;
  final bool enabled;
  final Widget? shortCut;
  const TextIconTappableWithShortCut({
    super.key,
    required this.iconData,
    required this.label,
    required this.onTap,
    this.height,
    this.enabled = true,
    this.shortCut,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      height: height,
      onTap: onTap,
      builder: (context, isHovered, isFocused) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: IconTheme(
            data: IconTheme.of(
              context,
            ).copyWith(color: (enabled && onTap != null) ? null : HippoColors.inactiveGray),
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.copyWith(
                color: (enabled && onTap != null) ? null : HippoColors.inactiveGray,
                decoration: isHovered ? TextDecoration.underline : null,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: mainAxisAlignment,
                    children: [Gap(4), Icon(iconData), Gap(4), Text(label), Gap(4)],
                  ),
                  if (shortCut != null) Positioned(right: 0, bottom: 0, child: shortCut!),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
