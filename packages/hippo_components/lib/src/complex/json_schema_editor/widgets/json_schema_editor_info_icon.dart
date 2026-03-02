// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

class JsonSchemaEditorInfoIcon extends StatelessWidget {
  const JsonSchemaEditorInfoIcon({super.key, required this.message, this.size = 16});

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hint = message;
    if (hint == null || hint.isEmpty) {
      return const SizedBox.shrink();
    }
    return Tooltip(
      message: hint,
      child: Icon(Icons.info_outline, size: size, color: Theme.of(context).colorScheme.primary),
    );
  }
}
