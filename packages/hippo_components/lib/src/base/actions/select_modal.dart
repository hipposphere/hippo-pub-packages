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
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

class SelectModal<T> {
  final String? title;
  final SelectModalItems<T> items;
  final SelectItemBuilder<T>? itemBuilder;
  final SelectItemTitleBuilder<T>? itemTitleBuilder;
  final SelectType selectType;
  final ModalType modalType;
  final T? previousSelected;
  final Widget? emptyButton;

  final Widget? trailingNavBarWidget;
  final List<Widget>? additionalSlivers;

  final DataSubject<T?> selectedItemSubject;

  const SelectModal._({
    required this.title,
    required this.items,
    required this.selectedItemSubject,
    this.itemBuilder,
    this.itemTitleBuilder,
    this.selectType = SelectType.direct,
    this.modalType = ModalType.dialog,
    this.previousSelected,
    this.trailingNavBarWidget,
    this.additionalSlivers,
    this.emptyButton,
  });

  factory SelectModal.items({
    String? title,
    required List<T> items,
    SelectItemBuilder<T>? itemBuilder,
    SelectItemTitleBuilder<T>? itemTitleBuilder,
    SelectType selectType = SelectType.direct,
    ModalType modalType = ModalType.dialog,
    T? previousSelected,
    Widget? trailingNavBarWidget,
    List<Widget>? additionalSlivers,
    Widget? emptyButton,
  }) {
    final selectedItemSubject = DataSubject<T?>.seeded(null);
    if (selectType == SelectType.confirm && previousSelected != null) {
      selectedItemSubject.add(previousSelected);
    }
    return SelectModal<T>._(
      title: title,
      items: SelectItemsList(items: items),
      itemBuilder: itemBuilder,
      itemTitleBuilder: itemTitleBuilder,
      selectType: selectType,
      modalType: modalType,
      selectedItemSubject: selectedItemSubject,
      previousSelected: previousSelected,
      trailingNavBarWidget: trailingNavBarWidget,
      additionalSlivers: additionalSlivers,
      emptyButton: emptyButton,
    );
  }

  factory SelectModal.stream({
    String? title,
    required Stream<List<T>> itemStream,
    SelectItemBuilder<T>? itemBuilder,
    SelectItemTitleBuilder<T>? itemTitleBuilder,
    SelectType selectType = SelectType.direct,
    ModalType modalType = ModalType.dialog,
    T? previousSelected,
    Widget? trailingNavBarWidget,
    List<Widget>? additionalSlivers,
    Widget? emptyButton,
  }) {
    final selectedItemSubject = DataSubject<T?>.seeded(null);
    if (selectType == SelectType.confirm && previousSelected != null) {
      selectedItemSubject.add(previousSelected);
    }
    return SelectModal._(
      title: title,
      items: SelectItemsStream(itemStream: itemStream),
      itemBuilder: itemBuilder,
      itemTitleBuilder: itemTitleBuilder,
      selectType: selectType,
      modalType: modalType,
      selectedItemSubject: selectedItemSubject,
      previousSelected: previousSelected,
      trailingNavBarWidget: trailingNavBarWidget,
      additionalSlivers: additionalSlivers,
      emptyButton: emptyButton,
    );
  }

  Modal buildModal() {
    return Modal(
      body: ModalBody(
        titleBuilder: (context) => ModalTitle(title ?? context.cl.actions_select),
        trailingNavBarWidget: trailingNavBarWidget,
        slivers: [
          _Body(
            items: items,
            itemBuilder: itemBuilder,
            itemTitleBuilder: itemTitleBuilder,
            previousSelected: previousSelected,
            selectType: selectType,
            selectedItemSubject: selectedItemSubject,
            emptyButton: emptyButton,
          ),
          ...?additionalSlivers,
        ],
      ),
      type: (context) => modalType,
    );
  }

  Future<T?> open(BuildContext context) async {
    final modal = buildModal();
    return modal.show<T>(context);
  }
}

class _Body<T> extends StatelessWidget {
  final SelectModalItems<T> items;
  final SelectItemBuilder<T>? itemBuilder;
  final SelectItemTitleBuilder<T>? itemTitleBuilder;
  final SelectType selectType;
  final T? previousSelected;
  final Widget? emptyButton;

  final DataSubject<T?> selectedItemSubject;
  const _Body({
    required this.items,
    required this.itemBuilder,
    required this.itemTitleBuilder,
    required this.selectType,
    required this.selectedItemSubject,
    required this.previousSelected,
    this.emptyButton,
  });

  @override
  Widget build(BuildContext context) {
    final confirmSelect = selectType == SelectType.confirm;
    return DataSubjectBuilder(
      subject: selectedItemSubject,
      builder: (context, selectedItem) {
        return SliverMainAxisGroup(
          slivers: [
            switch (items) {
              SelectItemsList(items: final itemsList) => _Items(
                items: itemsList,
                itemBuilder: itemBuilder,
                itemTitleBuilder: itemTitleBuilder,
                confirmSelect: confirmSelect,
                selectedItem: selectedItem,
                previousSelected: previousSelected,
                emptyButton: emptyButton,
                onSelect: (item) {
                  if (confirmSelect) {
                    selectedItemSubject.add(item);
                  } else {
                    Navigator.pop(context, item);
                  }
                },
              ),
              SelectItemsStream(itemStream: final itemStream) => StreamBuilder(
                stream: itemStream,
                builder: (context, snapshot) {
                  final itemsList = snapshot.data;
                  if (itemsList == null) {
                    return SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                  }
                  return _Items(
                    items: itemsList,
                    itemBuilder: itemBuilder,
                    itemTitleBuilder: itemTitleBuilder,
                    confirmSelect: confirmSelect,
                    selectedItem: selectedItem,
                    previousSelected: previousSelected,
                    emptyButton: emptyButton,
                    onSelect: (item) {
                      if (confirmSelect) {
                        selectedItemSubject.add(item);
                      } else {
                        Navigator.pop(context, item);
                      }
                    },
                  );
                },
              ),
            },
            if (confirmSelect)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: OkModalActionsBar(
                    enabled: selectedItem != null,
                    label: context.cl.actions_select,
                    onTap: () {
                      Navigator.pop(context, selectedItem);
                    },
                  ),
                ),
              )
            else
              SliverToBoxAdapter(child: Gap(16)),
          ],
        );
      },
    );
  }
}

class _Items<T> extends StatelessWidget {
  final List<T> items;
  final SelectItemBuilder<T>? itemBuilder;
  final SelectItemTitleBuilder<T>? itemTitleBuilder;
  final bool confirmSelect;
  final T? selectedItem;
  final Function(T item) onSelect;
  final T? previousSelected;
  final Widget? emptyButton;

  const _Items({
    required this.items,
    required this.itemBuilder,
    required this.itemTitleBuilder,
    required this.confirmSelect,
    required this.selectedItem,
    required this.onSelect,
    required this.previousSelected,
    this.emptyButton,
  });

  @override
  Widget build(BuildContext context) {
    // If there are no items and we have a create button config, show an empty state with create button
    if (items.isEmpty && emptyButton != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(context.cl.generic_no_entries_available),
              Gap(16),
              emptyButton ?? const SizedBox.shrink(),
            ],
          ),
        ),
      );
    }

    // Original implementation for when items exist
    return SliverBodyListItems(
      items: items,
      itemBuilder: (context, item) {
        if (itemBuilder != null) {
          return itemBuilder!(
            context,
            item,
            confirmSelect ? item == selectedItem : null,
            // ignore: null_check_on_nullable_type_parameter
            previousSelected != null ? {previousSelected!} : null,
            () => onSelect(item),
          );
        }

        if (confirmSelect) {
          return Tile(
            leading: IgnorePointer(
              // ignore: deprecated_member_use
              child: Radio(value: item, groupValue: selectedItem, onChanged: (_) {}),
            ),
            title: Text(
              itemTitleBuilder != null ? itemTitleBuilder!(context, item) : item.toString(),
            ),
            onTap: () {
              onSelect(item);
            },
            showArrowIndicator: true,
          );
        } else {
          final isSelected = previousSelected == item;
          return Tile(
            title: Text(
              itemTitleBuilder != null ? itemTitleBuilder!(context, item) : item.toString(),
            ),
            onTap: () => onSelect(item),
            enabled: !isSelected,
            trailing: isSelected ? Icon(Icons.done, color: Colors.green) : null,
            showArrowIndicator: !isSelected,
          );
        }
      },
    );
  }
}

typedef SelectItemBuilder<T> =
    Widget Function(
      BuildContext context,
      T item,
      bool? selected,
      Set<T>? previousSelected,
      VoidCallback onTap,
    );

typedef SelectItemTitleBuilder<T> = String Function(BuildContext context, T item);

enum SelectType { direct, confirm }

sealed class SelectModalItems<T> {}

class SelectItemsList<T> implements SelectModalItems<T> {
  final List<T> items;

  const SelectItemsList({required this.items});
}

class SelectItemsStream<T> implements SelectModalItems<T> {
  final Stream<List<T>> itemStream;

  SelectItemsStream({required this.itemStream});
}
