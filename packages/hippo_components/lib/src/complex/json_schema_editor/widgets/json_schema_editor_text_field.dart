// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------

import 'dart:async';

import 'package:flutter/material.dart';
import 'json_schema_editor_info_icon.dart';

class JsonSchemaEditorTextField extends StatefulWidget {
  const JsonSchemaEditorTextField({
    super.key,
    required this.value,
    required this.hint,
    required this.onChanged,
    this.helpText,
    this.debounceDelay,
    this.onSubmitted,
    this.onCleared,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
  }) : assert(minLines > 0, 'minLines must be greater than 0'),
       assert(maxLines >= minLines, 'maxLines must be greater than or equal to minLines');

  final String? value;
  final String hint;
  final String? helpText;
  final ValueChanged<String> onChanged;
  final Duration? debounceDelay;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onCleared;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;

  @override
  State<JsonSchemaEditorTextField> createState() => _JsonSchemaEditorTextFieldState();
}

class _JsonSchemaEditorTextFieldState extends State<JsonSchemaEditorTextField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  Timer? _onChangeDebounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
    _focusNode.addListener(_handleFocusLoss);
  }

  @override
  void didUpdateWidget(covariant JsonSchemaEditorTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _onChangeDebounce?.cancel();
      _controller.text = widget.value ?? '';
    }
  }

  void _handleSubmit(String value) {
    _onChangeDebounce?.cancel();
    if (value.trim().isEmpty) {
      widget.onCleared?.call();
    }
    widget.onSubmitted?.call(value);
  }

  void _handleFocusLoss() {
    if (_focusNode.hasFocus) {
      return;
    }
    _handleSubmit(_controller.text);
  }

  void _handleChange(String value) {
    final debounceDelay = widget.debounceDelay;
    if (debounceDelay == null) {
      widget.onChanged(value);
      return;
    }

    _onChangeDebounce?.cancel();
    _onChangeDebounce = Timer(debounceDelay, () {
      if (!mounted) {
        return;
      }
      widget.onChanged(value);
    });
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusLoss)
      ..dispose();
    _onChangeDebounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        isDense: true,
        labelText: widget.hint,
        alignLabelWithHint: widget.maxLines > 1 || widget.minLines > 1,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerLowest,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: widget.maxLines > 1 || widget.minLines > 1 ? 16 : 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.2),
        ),
        suffixIcon: widget.helpText == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 8),
                child: JsonSchemaEditorInfoIcon(message: widget.helpText!, size: 15),
              ),
        suffixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      ),
      onChanged: _handleChange,
      onSubmitted: _handleSubmit,
    );
  }
}
