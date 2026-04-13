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
import 'package:hippo_components/src/base/utils/components_context.dart';
import 'package:hippo_utils/hippo_utils.dart';

class JsonSchemaValidationPanel extends StatelessWidget {
  const JsonSchemaValidationPanel({super.key, required this.diagnostics});

  final List<JsonSchemaDiagnostic> diagnostics;

  @override
  Widget build(BuildContext context) {
    final warningCount = diagnostics.length;
    final colorScheme = Theme.of(context).colorScheme;
    final successColor = colorScheme.brightness == Brightness.dark
        ? const Color(0xFF62D084)
        : const Color(0xFF2E7D32);
    final successContainerColor = colorScheme.brightness == Brightness.dark
        ? const Color(0xFF163425)
        : const Color(0xFFEAF7EC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.lazyTranslate(en: 'Validation', de: 'Validierung', zh: '校验'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (warningCount > 0)
                Text(
                  context.lazyTranslate(
                    en: warningCount == 1 ? '1 warning' : '$warningCount warnings',
                    de: warningCount == 1 ? '1 Warnung' : '$warningCount Warnungen',
                    zh: warningCount == 1 ? '1 条警告' : '$warningCount 条警告',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
            ],
          ),
        ),
        if (warningCount == 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: successContainerColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: successColor.withValues(alpha: 0.18)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    key: const ValueKey('validation-success-avatar'),
                    radius: 18,
                    backgroundColor: successColor,
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.lazyTranslate(
                            en: 'No warnings detected',
                            de: 'Keine Warnungen gefunden',
                            zh: '未发现警告',
                          ),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: successColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.lazyTranslate(
                            en: 'Schema looks good.',
                            de: 'Das Schema sieht gut aus.',
                            zh: 'Schema 看起来没有问题。',
                          ),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 144),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              itemCount: diagnostics.length,
              itemBuilder: (context, index) {
                final item = diagnostics[index];
                return JsonSchemaWarningBadge(message: '${item.path}: ${item.message}');
              },
            ),
          ),
      ],
    );
  }
}

class JsonSchemaWarningBadge extends StatelessWidget {
  const JsonSchemaWarningBadge({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.18)),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onErrorContainer,
          height: 1.25,
        ),
      ),
    );
  }
}
