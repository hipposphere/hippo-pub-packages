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
import 'package:hippo_utils/hippo_utils.dart';

class JsonSchemaValidationPanel extends StatelessWidget {
  const JsonSchemaValidationPanel({super.key, required this.diagnostics});

  final List<JsonSchemaDiagnostic> diagnostics;

  @override
  Widget build(BuildContext context) {
    final warningCount = diagnostics.length;

    return HippoGradientCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Warnings (${warningCount.toString()})',
                      style: Theme.of(context).textTheme.titleMedium,
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
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('No warnings detected.'),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  itemCount: diagnostics.length,
                  itemBuilder: (context, index) {
                    final item = diagnostics[index];
                    return JsonSchemaWarningBadge(message: '${item.path}: ${item.message}');
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class JsonSchemaWarningBadge extends StatelessWidget {
  const JsonSchemaWarningBadge({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
