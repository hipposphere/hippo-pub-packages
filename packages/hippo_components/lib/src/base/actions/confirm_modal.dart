import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

enum ConfirmActionType { primary, destructive }

class ConfirmAction {
  final ConfirmActionType type;
  final IconData? icon;
  final String text;

  const ConfirmAction({required this.type, required this.icon, required this.text});

  static ConfirmAction delete(BuildContext context) => ConfirmAction(
    type: ConfirmActionType.destructive,
    icon: Icons.delete_outline,
    text: context.cl.actions_delete,
  );

  static ConfirmAction reset(BuildContext context) => ConfirmAction(
    type: ConfirmActionType.destructive,
    icon: Icons.restore,
    text: context.cl.actions_reset,
  );
}

class ConfirmModal {
  final Widget? alert;
  final String? text;
  final ConfirmAction action;
  final ModalType modalType;
  ConfirmModal({this.alert, this.text, required this.action, this.modalType = ModalType.dialog});

  InfoModal buildInfoModal(BuildContext context) {
    return InfoModal(
      title: context.cl.actions_confirm_action,
      modalType: modalType,
      child: InfoModalBody(
        alert: alert,
        text: text,
        action: CancelConfirmModalActionsBar(
          onCancel: (context) => Navigator.of(context).pop(false),
          isConfirmLarge: action.type == ConfirmActionType.primary,
          confirmBuilder: (context) => Button(
            onTap: () {
              Navigator.of(context).pop(true);
            },
            prefix: action.icon != null ? Icon(action.icon) : null,
            label: action.text,
            type: switch (action.type) {
              ConfirmActionType.primary => ButtonType.primary,
              ConfirmActionType.destructive => ButtonType.destructive,
            },
          ),
        ),
      ),
    );
  }

  Future<bool> open(BuildContext context) async {
    final modal = buildInfoModal(context);
    final result = await modal.open<bool>(context);
    return result ?? false;
  }
}
