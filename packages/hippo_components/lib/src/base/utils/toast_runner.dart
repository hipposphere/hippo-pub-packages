import 'package:flutter/widgets.dart';
import 'package:hippo_components/hippo_components.dart';

class ToastRunner {
  const ToastRunner._();

  static Future<T?> runFunctionWithToast<T>({
    required Future<T> Function() function,
    required String successMessage,
    required String errorMessage,
    BuildContext? context,
    String? loadingMessage,
    String? successSubtitle,
    Duration? toastLoadingDuration,
    Duration toastDuration = const Duration(seconds: 3),
    void Function(Object error, StackTrace stack)? onError,
  }) async {
    ToastReference? toast;

    if (loadingMessage != null) {
      (toastLoadingDuration != null)
          ? toast = ToastBuilder.showAutoCloseToast(
              context: context,
              title: loadingMessage,
              type: ToastType.info,
              showProgressBar: true,
              autoCloseDuration: toastLoadingDuration,
            )
          : toast = ToastBuilder.showSimpleToast(
              context: context,
              title: loadingMessage,
              type: ToastType.info,
              showProgressBar: true,
              autoClose: false,
            );
    }

    try {
      final result = await function();
      toast?.dismiss();
      ToastBuilder.showAutoCloseToast(
        title: successMessage,
        subtitle: successSubtitle,
        type: ToastType.success,
        showProgressBar: false,
        autoCloseDuration: toastDuration,
      );

      return result;
    } catch (e, st) {
      toast?.dismiss();

      ToastBuilder.showAutoCloseToast(
        // ignore: use_build_context_synchronously
        context: context,
        title: errorMessage,
        subtitle: e.toString(),
        type: ToastType.error,
        showProgressBar: false,
        autoCloseDuration: toastDuration,
      );

      onError?.call(e, st);
      return null;
    }
  }

  static Future<T?> runFutureWithToast<T>({
    required Future<T> future,
    required String successMessage,
    required String errorMessage,
    BuildContext? context,
    String? loadingMessage,
    Duration toastDuration = const Duration(seconds: 3),
    Duration? toastLoadingDuration,
    void Function(Object error, StackTrace stack)? onError,
  }) {
    return ToastRunner.runFunctionWithToast(
      function: () => future,
      successMessage: successMessage,
      errorMessage: errorMessage,
      loadingMessage: loadingMessage,
      toastLoadingDuration: toastLoadingDuration,
      toastDuration: toastDuration,
      context: context,
      onError: onError,
    );
  }

  static Future<void> runVoidCallbackWithToast({
    required VoidCallback? callback,
    required String successMessage,
    required String errorMessage,
    String? loadingMessage,
    String? successSubtitle,
    bool showProgressBar = true,
    BuildContext? context,
    Duration toastDuration = const Duration(seconds: 3),
    Duration? toastLoadingDuration,
    void Function(Object error, StackTrace stack)? onError,
  }) {
    return ToastRunner.runFunctionWithToast<void>(
      function: () async => callback?.call(),
      context: context,
      successMessage: successMessage,
      errorMessage: errorMessage,
      loadingMessage: loadingMessage,
      successSubtitle: successSubtitle,
      toastDuration: toastDuration,
      toastLoadingDuration: toastLoadingDuration,
      onError: onError,
    );
  }
}
