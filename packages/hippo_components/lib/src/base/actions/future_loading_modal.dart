import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

class FutureLoadingModal {
  final Future<bool> future;

  FutureLoadingModal({required this.future});

  BuildContext? _modalContext;

  InfoModal _buildModal() {
    return InfoModal(
      title: 'Laden',
      barrierDismissible: false,
      child: Builder(
        builder: (context) {
          _modalContext = context;
          return FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              final data = snapshot.data;

              return switch (data) {
                true => Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(Icons.check_circle_outline, color: Colors.green),
                  ),
                ),
                false => Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(Icons.error_outline, color: Colors.green),
                  ),
                ),
                _ => Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
              };
            },
          );
        },
      ),
    );
  }

  Future<void> open(BuildContext context) async {
    final modal = _buildModal();
    final modalOpenFuture = modal.open(context);
    unawaited(
      future.whenComplete(() {
        final context = _modalContext;
        if (context == null || !context.mounted) return;
        Navigator.of(context).pop();
      }),
    );
    await modalOpenFuture;
  }
}
