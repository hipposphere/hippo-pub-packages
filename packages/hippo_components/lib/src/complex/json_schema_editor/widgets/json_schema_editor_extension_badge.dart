// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

class JsonSchemaEditorChipLabel extends StatelessWidget {
  const JsonSchemaEditorChipLabel({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: textColor),
            const Gap(3),
            Text(
              label,
              style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class JsonSchemaExtensionStateBadge extends StatelessWidget {
  const JsonSchemaExtensionStateBadge({
    super.key,
    required this.isConfigured,
    required this.isImplemented,
  });

  final bool isConfigured;
  final bool isImplemented;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!isConfigured) {
      return JsonSchemaEditorChipLabel(
        label: context.lazyTranslate(en: 'custom', de: 'eigen', zh: '自定义'),
        icon: Icons.extension,
        color: colorScheme.errorContainer,
        textColor: colorScheme.onErrorContainer,
      );
    }
    if (isImplemented) {
      return JsonSchemaEditorChipLabel(
        label: context.lazyTranslate(en: 'active', de: 'aktiv', zh: '已启用'),
        icon: Icons.check_circle,
        color: colorScheme.secondaryContainer,
        textColor: colorScheme.onSecondaryContainer,
      );
    }
    return JsonSchemaEditorChipLabel(
      label: context.lazyTranslate(en: 'available', de: 'verfügbar', zh: '可用'),
      icon: Icons.tune,
      color: colorScheme.surfaceContainerHighest,
      textColor: colorScheme.onSurfaceVariant,
    );
  }
}
