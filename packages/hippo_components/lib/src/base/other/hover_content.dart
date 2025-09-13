/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HoverPopup extends StatefulWidget {
  final Widget child;

  /// Builder for popup content, receiving a `closePopup` callback.
  final Widget Function(BuildContext context, VoidCallback closePopup) popupBuilder;

  /// Width of the popup. You can also make this dynamic.
  final double? popupWidth;

  /// Vertical gap between child and popup (in pixels).
  final double verticalOffset;

  const HoverPopup({
    super.key,
    required this.popupBuilder,
    required this.child,
    this.popupWidth,
    this.verticalOffset = 4,
  });

  @override
  State<HoverPopup> createState() => _HoverPopupState();
}

class _HoverPopupState extends State<HoverPopup> {
  OverlayEntry? _overlayEntry;
  bool _hoveringChild = false;
  bool _hoveringOverlay = false;

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final target = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        right: target.dx,
        top: target.dy + size.height,
        width: widget.popupWidth,
        child: MouseRegion(
          onEnter: (_) => _onOverlayEnter(),
          onExit: (_) => _onOverlayExit(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // transparent buffer to cover gap and keep hover active
              if (widget.verticalOffset > 0) SizedBox(height: widget.verticalOffset),
              // the actual popup
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: widget.popupBuilder(context, _hideOverlay),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _hoveringOverlay = false;
    _hoveringChild = false;
  }

  void _onChildEnter(PointerEnterEvent _) {
    _hoveringChild = true;
    _showOverlay();
  }

  void _onChildExit(PointerExitEvent _) {
    _hoveringChild = false;
    // slight delay to allow overlay onEnter to fire
    Future.delayed(const Duration(milliseconds: 10), _maybeHide);
  }

  void _onOverlayEnter() {
    _hoveringOverlay = true;
  }

  void _onOverlayExit() {
    _hoveringOverlay = false;
    Future.delayed(const Duration(milliseconds: 10), _maybeHide);
  }

  void _maybeHide() {
    if (!_hoveringChild && !_hoveringOverlay) {
      _hideOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(onEnter: _onChildEnter, onExit: _onChildExit, child: widget.child);
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }
}
