import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HoverPopup2 extends StatefulWidget {
  /// Builder for popup content, receiving a `closePopup` callback.
  final Widget Function(BuildContext context, VoidCallback closePopup) topLeftBuilder;

  /// Builder for popup content, receiving a `closePopup` callback.
  final Widget Function(BuildContext context, VoidCallback closePopup) bottomRightBuilder;

  /// Width of the popup. You can also make this dynamic.
  final double? popupWidth;

  /// Vertical gap between child and popup (in pixels).
  final double verticalOffset;

  final Widget Function(BuildContext context, bool isHovered) builder;

  const HoverPopup2({
    super.key,
    required this.topLeftBuilder,
    required this.bottomRightBuilder,
    required this.builder,
    this.popupWidth,
    this.verticalOffset = 4,
  });

  @override
  State<HoverPopup2> createState() => _HoverPopupState();
}

class _HoverPopupState extends State<HoverPopup2> {
  OverlayEntry? _overlayEntry1;
  OverlayEntry? _overlayEntry2;
  bool _hoveringChild = false;
  bool _hoveringOverlay = false;

  bool _isHovering = false;

  void _showOverlay() {
    if (_overlayEntry1 != null) return;
    if (_overlayEntry2 != null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final target = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry1 = OverlayEntry(
      builder: (ctx) => Positioned(
        left: target.dx - 8,
        top: target.dy - 16,
        width: widget.popupWidth,
        child: MouseRegion(
          onEnter: (_) => _onOverlayEnter(),
          onExit: (_) => _onOverlayExit(),
          child: widget.topLeftBuilder(context, _hideOverlay),
        ),
      ),
    );
    _overlayEntry2 = OverlayEntry(
      builder: (ctx) => Positioned(
        right: target.dx,
        top: target.dy + size.height - 16,
        width: widget.popupWidth,
        child: MouseRegion(
          onEnter: (_) => _onOverlayEnter(),
          onExit: (_) => _onOverlayExit(),
          child: widget.bottomRightBuilder(context, _hideOverlay),
        ),
      ),
    );

    Overlay.of(context).insertAll([_overlayEntry1!, _overlayEntry2!]);
  }

  void _hideOverlay() {
    _overlayEntry1?.remove();
    _overlayEntry1 = null;
    _overlayEntry2?.remove();
    _overlayEntry2 = null;
    _hoveringOverlay = false;
    _hoveringChild = false;
    _updateIsHovering();
  }

  void _onChildEnter(PointerEnterEvent _) {
    _hoveringChild = true;
    _updateIsHovering();
    _showOverlay();
  }

  void _onChildExit(PointerExitEvent _) {
    _hoveringChild = false;
    _updateIsHovering();
    // slight delay to allow overlay onEnter to fire
    Future.delayed(const Duration(milliseconds: 10), _maybeHide);
  }

  void _onOverlayEnter() {
    _hoveringOverlay = true;
    _updateIsHovering();
  }

  void _onOverlayExit() {
    _hoveringOverlay = false;
    _updateIsHovering();
    Future.delayed(const Duration(milliseconds: 10), _maybeHide);
  }

  void _maybeHide() {
    if (!_hoveringChild && !_hoveringOverlay) {
      _hideOverlay();
    }
  }

  void _updateIsHovering() {
    final newIsHovering = _hoveringChild || _hoveringOverlay;
    if (newIsHovering != _isHovering) {
      if (mounted) {
        setState(() {
          _isHovering = newIsHovering;
        });
      } else {
        _isHovering = newIsHovering;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onChildEnter,
      onExit: _onChildExit,
      child: widget.builder(context, _isHovering),
    );
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }
}
