import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

class GetTextModal {
  final String? title;
  final String? inputLabel;
  final String initialText;
  final String? hintText;
  final String? actionText;
  final int? maxLines, minLines, maxLength;
  final String? Function(BuildContext context, String text)? validator;
  final Widget? top, bottom;
  final ModalType modalType;
  GetTextModal({
    this.title,
    this.inputLabel,
    this.initialText = '',
    this.hintText,
    this.actionText,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.validator,
    this.top,
    this.bottom,
    this.modalType = ModalType.dialog,
  });

  Modal buildModal() {
    final controller = TextEditingController(text: initialText);
    final statesController = WidgetStatesController();
    final errorSubject = DataSubject<String?>.seeded(null);
    final modal = Modal(
      body: ModalBody.simple(
        titleBuilder: (context) => ModalTitle(title ?? context.cl.actions_enter_text),
        child: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: _Body(
                controller: controller,
                inputLabel: inputLabel ?? context.cl.common_text,
                hintText: hintText,
                actionText: actionText ?? context.cl.actions_ok,
                maxLines: maxLines,
                minLines: minLines,
                maxLength: maxLength,
                statesController: statesController,
                errorSubject: errorSubject,
                top: top,
                bottom: bottom,
                onChange: (context, text) {
                  if (statesController.value.contains(WidgetState.error)) {
                    statesController.update(WidgetState.error, false);
                  }
                  errorSubject.add(null);
                },
                onSubmit: (context, text) {
                  if (validator != null) {
                    final error = validator!(context, text);
                    if (error != null) {
                      statesController.update(WidgetState.error, true);
                      errorSubject.add(error);
                      return;
                    }
                  }
                  Navigator.pop(context, text);
                },
                onConfirm: (context) {
                  final text = controller.text;
                  if (validator != null) {
                    final error = validator!(context, text);
                    if (error != null) {
                      statesController.update(WidgetState.error, true);
                      errorSubject.add(error);
                      return;
                    }
                  }
                  Navigator.pop(context, text);
                },
              ),
            );
          },
        ),
      ),
      type: (context) => modalType,
    );
    return modal;
  }

  Future<String?> open(BuildContext context) async {
    final modal = buildModal();
    return modal.show<String>(context);
  }
}

class _Body extends StatelessWidget {
  final String inputLabel;
  final String? hintText;
  final String actionText;
  final WidgetStatesController statesController;
  final DataSubject<String?> errorSubject;
  final int? minLines, maxLines, maxLength;
  final Function(BuildContext context, String text) onChange;
  final Function(BuildContext context) onConfirm;
  final Function(BuildContext context, String text) onSubmit;
  final Widget? top, bottom;

  final TextEditingController controller;
  const _Body({
    required this.controller,
    required this.inputLabel,
    required this.hintText,
    required this.actionText,
    required this.maxLines,
    required this.minLines,
    required this.maxLength,
    required this.errorSubject,
    required this.statesController,
    required this.onChange,
    required this.onConfirm,
    required this.onSubmit,
    required this.top,
    required this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return DataSubjectBuilder(
      subject: errorSubject,
      builder: (context, errorValue) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (top != null) Padding(padding: const EdgeInsets.only(bottom: 16.0), child: top!),
            FTextField(
              controller: controller,
              label: Text(inputLabel),
              autofocus: true,
              onChange: (value) => onChange(context, value),
              onSubmit: (text) => onSubmit(context, text),
              maxLines: maxLines,
              minLines: minLines,
              maxLength: maxLength,

              textInputAction: maxLines == 1 ? TextInputAction.done : TextInputAction.newline,
              statesController: statesController,
              description: errorValue != null
                  ? Text(errorValue, style: TextStyle(color: Colors.red))
                  : null,
              hint: hintText,
            ),
            if (bottom != null) Padding(padding: const EdgeInsets.only(top: 16.0), child: bottom!),
            const Gap(16),
            CancelConfirmModalActionsBar(
              confirmBuilder: (context) =>
                  Button(onTap: () => onConfirm(context), label: actionText),
            ),
          ],
        );
      },
    );
  }
}
