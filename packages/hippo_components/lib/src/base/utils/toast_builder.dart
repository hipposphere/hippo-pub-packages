import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

enum ToastType { success, info, warning, error }

class ToastBuilder {
  const ToastBuilder._();

  static ToastReference showSimpleToast({
    String? title,
    Contextable<String>? titleBuilder,
    ToastType type = ToastType.info,
    String? subtitle,
    Contextable<String>? subtitleBuilder,
    BuildContext? context,
    bool showProgressBar = false,
    bool autoClose = false,
  }) {
    return _showGlassyToast(
      title: title,
      titleBuilder: titleBuilder,
      subtitle: subtitle,
      subtitleBuilder: subtitleBuilder,
      type: type,
      context: context,
      showProgressBar: showProgressBar,
      autoClose: autoClose,
    );
  }

  static ToastReference showAutoCloseToast({
    String? title,
    Contextable<String>? titleBuilder,
    ToastType type = ToastType.info,
    String? subtitle,
    Contextable<String>? subtitleBuilder,
    BuildContext? context,
    bool showProgressBar = false,
    Duration autoCloseDuration = const Duration(seconds: 3),
  }) {
    return _showGlassyToast(
      title: title,
      titleBuilder: titleBuilder,
      subtitle: subtitle,
      subtitleBuilder: subtitleBuilder,
      type: type,
      context: context,
      showProgressBar: showProgressBar,
      autoClose: true,
      autoCloseDuration: autoCloseDuration,
    );
  }

  static ToastReference _showGlassyToast({
    String? title,
    Contextable<String>? titleBuilder,
    String? subtitle,
    Contextable<String>? subtitleBuilder,
    required ToastType type,
    BuildContext? context,
    bool showProgressBar = false,
    bool autoClose = true,
    Duration autoCloseDuration = const Duration(seconds: 3),
    Alignment alignment = Alignment.bottomRight,
  }) {
    assert(title != null || titleBuilder != null, 'Either title or titleBuilder must be provided');
    final color = _colorForType(type);

    final item = toastification.show(
      context: context,
      alignment: alignment,
      type: _mapToastType(type),
      title: titleBuilder != null
          ? Builder(
              builder: (context) {
                return Text(
                  titleBuilder(context),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                );
              },
            )
          : Text(
              title!,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
      description: subtitleBuilder != null
          ? Builder(
              builder: (context) {
                return Text(
                  subtitleBuilder(context),
                  style: const TextStyle(color: Colors.white70),
                );
              },
            )
          : (subtitle != null
                ? Text(subtitle, style: const TextStyle(color: Colors.white70))
                : null),
      showProgressBar: showProgressBar,
      progressBarTheme: ProgressIndicatorThemeData(
        color: color.withValues(alpha: 0.9),
        linearTrackColor: color.withValues(alpha: 0.2),
        linearMinHeight: 4.0,
      ),
      autoCloseDuration: autoClose ? autoCloseDuration : null,
      applyBlurEffect: true,
      backgroundColor: color.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: color.withValues(alpha: 0.9), width: 1.2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 24, right: 16),
      closeOnClick: true,
      dragToClose: true,
      pauseOnHover: true,
      dismissDirection: DismissDirection.horizontal,
    );

    return ToastReference(item);
  }

  static ToastificationType _mapToastType(ToastType type) {
    return switch (type) {
      ToastType.success => ToastificationType.success,
      ToastType.info => ToastificationType.info,
      ToastType.warning => ToastificationType.warning,
      ToastType.error => ToastificationType.error,
    };
  }

  static Color _colorForType(ToastType type) {
    return switch (type) {
      ToastType.success => Colors.green,
      ToastType.info => HippoColors.primary,
      ToastType.warning => HippoColors.orange,
      ToastType.error => Colors.red,
    };
  }
}

class ToastReference {
  final ToastificationItem item;
  const ToastReference(this.item);

  void dismiss() {
    toastification.dismissById(item.id, showRemoveAnimation: false);
  }
}
