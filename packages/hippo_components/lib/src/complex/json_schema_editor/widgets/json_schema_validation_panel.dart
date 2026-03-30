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
import 'package:hippo_utils/hippo_utils.dart';

class JsonSchemaValidationPanel extends StatelessWidget {
  const JsonSchemaValidationPanel({super.key, required this.diagnostics});

  final List<JsonSchemaDiagnostic> diagnostics;

  @override
  Widget build(BuildContext context) {
    final warningCount = diagnostics.length;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Warnings (${warningCount.toString()})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (warningCount > 0)
                  Text(
                    'non-blocking',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
          if (warningCount == 0)
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text('No warnings detected.'),
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
      ),
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
