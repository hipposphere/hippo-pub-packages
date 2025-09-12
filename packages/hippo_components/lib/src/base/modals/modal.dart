import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import 'types/floating_bottom_dialog_type.dart';

enum ModalType {
  dialog,
  bottomSheet,
  mobileBottomSheetAndDesktopDialog,
  mobileBottomSheetAndDesktopBottomRightSideDialog,
  sideSheet,
  fullScreen,
  bottomLeftDialog,
  bottomRightDialog;

  WoltModalType toWoltModalType(BuildContext context) {
    return switch (this) {
      ModalType.dialog => const WoltDialogType(),
      ModalType.bottomSheet => const WoltBottomSheetType(),
      ModalType.mobileBottomSheetAndDesktopDialog => switch (MediaQuery.sizeOf(context).width) {
        > 700 => const WoltDialogType(),
        _ => const WoltBottomSheetType(),
      },
      ModalType.mobileBottomSheetAndDesktopBottomRightSideDialog => switch (MediaQuery.sizeOf(
        context,
      ).width) {
        > 700 => const FloatingBottomSheetType(
          position: FloatingBottomSheetPosition.bottomRightDialog,
        ),
        _ => const WoltBottomSheetType(),
      },
      ModalType.sideSheet => const WoltSideSheetType(),
      ModalType.fullScreen => const WoltDialogType(),
      ModalType.bottomLeftDialog => const FloatingBottomSheetType(
        position: FloatingBottomSheetPosition.bottomLeftDialog,
      ),
      ModalType.bottomRightDialog => const FloatingBottomSheetType(
        position: FloatingBottomSheetPosition.bottomRightDialog,
      ),
    };
  }
}

class ModalBody {
  final String? title;
  final WidgetBuilder? titleBuilder;
  final List<Widget> slivers;
  final Widget? heroImage;
  final Widget? leadingNavBarWidget;
  final Widget? trailingNavBarWidget;
  final Widget? stickyActionBar;
  final bool forceMaxHeight;

  const ModalBody({
    this.title,
    this.titleBuilder,
    required this.slivers,
    this.heroImage,
    this.leadingNavBarWidget,
    this.trailingNavBarWidget,
    this.stickyActionBar,
    this.forceMaxHeight = false,
  }) : assert(
         title != null || titleBuilder != null,
         'Either title or titleBuilder must be provided',
       );

  factory ModalBody.simple({
    String? title,
    WidgetBuilder? titleBuilder,
    required Widget child,
    Widget? heroImage,
    Widget? leadingNavBarWidget,
    Widget? trailingNavBarWidget,
    Widget? stickyActionBar,
    List<BlocDefiner> blocDefiners = const [],
    bool forceMaxHeight = false,
  }) {
    return ModalBody(
      title: title,
      titleBuilder: titleBuilder,
      slivers: [
        SliverToBoxAdapter(
          child: MultiBlocProvider(blocDefiners: blocDefiners, child: child),
        ),
      ],
      heroImage: heroImage,
      leadingNavBarWidget: leadingNavBarWidget,
      trailingNavBarWidget: trailingNavBarWidget,
      stickyActionBar: stickyActionBar,
      forceMaxHeight: forceMaxHeight,
    );
  }

  SliverWoltModalSheetPage buildModalSheetPage(BuildContext context) {
    return SliverWoltModalSheetPage(
      leadingNavBarWidget:
          leadingNavBarWidget ??
          ModalTappable(
            tooltip: context.cl.actions_close,
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.close, size: 24),
          ),
      heroImage: heroImage,
      trailingNavBarWidget: trailingNavBarWidget,
      pageTitle: title != null ? ModalTitle(title!) : titleBuilder!(context),
      hasTopBarLayer: true,
      mainContentSliversBuilder: (context) => slivers,
      stickyActionBar: stickyActionBar,
      forceMaxHeight: forceMaxHeight,
    );
  }
}

class ModalTitle extends StatelessWidget {
  final String text;
  const ModalTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(text, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    );
  }
}

class Modal {
  final ModalBody body;
  final Contextable<ModalType> type;
  final bool? barrierDismissible;

  Modal({required this.body, required this.type, this.barrierDismissible});

  Future<T?> show<T>(BuildContext context) {
    return WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) {
        return [body.buildModalSheetPage(context)];
      },
      modalTypeBuilder: (context) {
        return type(context).toWoltModalType(context);
      },
      barrierDismissible: barrierDismissible,
      useRootNavigator: true,
    );
  }

  Future<void> showWithAutoPop(
    BuildContext context, {
    required Future<bool> future,
    Duration delay = const Duration(milliseconds: 250),
  }) async {
    final dialogPop = show(context);
    bool hasDialogPopped = false;
    dialogPop.then((_) => hasDialogPopped = true);
    await future.then((result) async {
      if (result == true) {
        await Future.delayed(delay);
        if (!hasDialogPopped) {
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        }
      }
    });
  }
}

class MultiPageModal {
  final List<ModalBody> pages;
  final ValueNotifier<int> selectedPageNotifier;
  final Contextable<ModalType> type;
  final bool? barrierDismissible;

  MultiPageModal({
    required this.pages,
    required this.selectedPageNotifier,
    required this.type,
    this.barrierDismissible,
  });

  Future<T?> show<T>(BuildContext context) {
    return WoltModalSheet.show(
      context: context,
      pageIndexNotifier: selectedPageNotifier,
      pageListBuilder: (context) {
        return [for (final body in pages) body.buildModalSheetPage(context)];
      },
      modalTypeBuilder: (context) {
        return type(context).toWoltModalType(context);
      },
      barrierDismissible: barrierDismissible,
      useRootNavigator: true,
    );
  }

  Future<void> showWithAutoPop(
    BuildContext context, {
    required Future<bool> future,
    Duration delay = const Duration(milliseconds: 250),
  }) async {
    final dialogPop = show(context);
    bool hasDialogPopped = false;
    dialogPop.then((_) => hasDialogPopped = true);
    await future.then((result) async {
      if (result == true) {
        await Future.delayed(delay);
        if (!hasDialogPopped) {
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        }
      }
    });
  }
}

class ModalUtils {
  static Widget buildModalWidget(BuildContext context, Modal modal) {
    return _ModalWidget(modal: modal);
  }
}

class _ModalWidget extends StatefulWidget {
  final Modal modal;
  const _ModalWidget({required this.modal});

  @override
  State<_ModalWidget> createState() => _ModalWidgetState();
}

class _ModalWidgetState extends State<_ModalWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final pageListBuilderNotifier = ValueNotifier<WoltModalSheetPageListBuilder>(
      (context) => [widget.modal.body.buildModalSheetPage(context)],
    );
    return WoltModalSheet(
      pageListBuilderNotifier: pageListBuilderNotifier,
      pageIndexNotifier: ValueNotifier(0),
      onModalDismissedWithBarrierTap: null,
      onModalDismissedWithDrag: null,
      pageContentDecorator: null,
      modalDecorator: null,
      modalTypeBuilder: (_) => widget.modal.type(context).toWoltModalType(context),
      transitionAnimationController: _animationController,
      route: WoltModalSheetRoute(
        pageListBuilderNotifier: pageListBuilderNotifier,
        transitionAnimationController: _animationController,
        barrierDismissible: false,
      ),
      enableDrag: true,
      showDragHandle: false,
      useSafeArea: false,
    );
  }
}
