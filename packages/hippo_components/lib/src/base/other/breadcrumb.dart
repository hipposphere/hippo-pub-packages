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
import 'package:hippo_components/hippo_components.dart';

class BreadcrumbItem<T> {
  final IconData? iconData;
  final String? title;
  final String? tooltip;
  final bool isHighlighted;
  final T? value;

  const BreadcrumbItem({
    this.iconData,
    this.title,
    this.tooltip,
    this.isHighlighted = false,
    this.value,
  }) : assert(iconData != null || title != null);
}

class Breadcrumb<T> extends StatelessWidget {
  final List<BreadcrumbItem<T>> items;
  final void Function(BuildContext context, T value)? onTap;
  final Color? highlightColor;
  const Breadcrumb({super.key, required this.items, this.onTap, this.highlightColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (final item in items) ...[
              _Tile(
                item: item,
                // ignore: null_check_on_nullable_type_parameter
                onTap: item.value != null ? () => _handleTap(context, item.value!) : null,
                color: _getColor(context, item.isHighlighted, highlightColor),
              ),
              if (items.last != item)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: _getColor(context, false, highlightColor),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, T value) {
    if (onTap != null) {
      onTap!(context, value);
    }
  }
}

class _Tile extends StatelessWidget {
  final BreadcrumbItem item;
  final VoidCallback? onTap;
  final Color color;
  const _Tile({required this.item, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SimpleTappable(
        // ignore: null_check_on_nullable_type_parameter
        onTap: onTap,
        tooltip: item.tooltip,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            children: [
              Gap(4),
              if (item.iconData != null) Icon(item.iconData, size: 24, color: color),
              if (item.title != null)
                Text(
                  item.title!,
                  style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              Gap(4),
            ],
          ),
        ),
      ),
    );
  }
}

Color _getColor(BuildContext context, bool isHighlited, Color? highlightColor) {
  return isHighlited
      ? (highlightColor ?? context.onBrightness(light: HippoColors.black, dark: HippoColors.white))
      : context.onBrightness(light: HippoColors.hoverDarkColor, dark: HippoColors.hoverDarkColor);
}
