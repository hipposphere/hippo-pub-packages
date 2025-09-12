import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

class InfoModal {
  final String? title;
  final WidgetBuilder? titleBuilder;
  final Widget? leadingNavBarWidget;
  final Widget? trailingNavBarWidget;
  final Widget? stickyActionBar;
  final Widget child;
  final ModalType modalType;
  final bool? barrierDismissible;
  InfoModal({
    this.title,
    this.titleBuilder,
    required this.child,
    this.stickyActionBar,
    this.leadingNavBarWidget,
    this.trailingNavBarWidget,
    this.modalType = ModalType.mobileBottomSheetAndDesktopDialog,
    this.barrierDismissible,
  });

  Modal buildModal() {
    return Modal(
      body: ModalBody.simple(
        title: title,
        titleBuilder: titleBuilder,
        leadingNavBarWidget: leadingNavBarWidget,
        trailingNavBarWidget: trailingNavBarWidget,
        stickyActionBar: stickyActionBar,
        child: Padding(padding: const EdgeInsets.all(16.0), child: child),
      ),
      barrierDismissible: barrierDismissible,
      type: (context) => modalType,
    );
  }

  Future<T?> open<T>(BuildContext context) async {
    final modal = buildModal();
    return modal.show<T>(context);
  }
}

class InfoSliversModal {
  final String? title;
  final WidgetBuilder? titleBuilder;
  final List<Widget> slivers;
  final Widget? stickyActionBar;
  final Widget? trailingNavBarWidget;
  final ModalType modalType;
  InfoSliversModal({
    required this.title,
    this.titleBuilder,
    required this.slivers,
    this.stickyActionBar,
    this.trailingNavBarWidget,
    this.modalType = ModalType.mobileBottomSheetAndDesktopDialog,
  });

  Modal buildModal() {
    return Modal(
      body: ModalBody(
        title: title,
        titleBuilder: titleBuilder,
        stickyActionBar: stickyActionBar,
        trailingNavBarWidget: trailingNavBarWidget,
        slivers: slivers,
      ),
      type: (context) => modalType,
    );
  }

  Future<T?> open<T>(BuildContext context) async {
    final modal = buildModal();
    return modal.show<T>(context);
  }
}

class InfoModalBody extends StatelessWidget {
  final Widget? alert;
  final String? text;
  final Widget? action;
  const InfoModalBody({super.key, this.alert, this.text, this.action});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (alert != null) ...[alert!, const Gap(16)],
        if (text != null) ...[Text(text!, style: const TextStyle(fontSize: 16)), const Gap(16)],
        if (action != null) ...[action!],
      ],
    );
  }
}
