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

class MultiSelectModal<T> {
  final String? title;
  final SelectModalItems<T> items;
  final SelectItemBuilder<T>? itemBuilder;
  final SelectItemTitleBuilder<T>? itemTitleBuilder;
  final ModalType modalType;
  final Set<T>? previousSelected;

  final DataSubject<Set<T>> selectedItemsSubject;

  const MultiSelectModal._({
    required this.title,
    required this.items,
    required this.selectedItemsSubject,
    this.itemBuilder,
    this.itemTitleBuilder,
    this.modalType = ModalType.dialog,
    this.previousSelected,
  });

  factory MultiSelectModal.items({
    String? title,
    required List<T> items,
    SelectItemBuilder<T>? itemBuilder,
    SelectItemTitleBuilder<T>? itemTitleBuilder,
    ModalType modalType = ModalType.dialog,
    Set<T>? previousSelected,
  }) {
    final selectedItemsSubject = DataSubject<Set<T>>.seeded({});
    if (previousSelected != null) {
      selectedItemsSubject.add(previousSelected);
    }
    return MultiSelectModal<T>._(
      title: title,
      items: SelectItemsList(items: items),
      itemBuilder: itemBuilder,
      itemTitleBuilder: itemTitleBuilder,
      modalType: modalType,
      selectedItemsSubject: selectedItemsSubject,
      previousSelected: previousSelected,
    );
  }

  factory MultiSelectModal.stream({
    String? title,
    required Stream<List<T>> itemStream,
    SelectItemBuilder<T>? itemBuilder,
    SelectItemTitleBuilder<T>? itemTitleBuilder,
    ModalType modalType = ModalType.dialog,
    Set<T>? previousSelected,
  }) {
    final selectedItemsSubject = DataSubject<Set<T>>.seeded({});
    if (previousSelected != null) {
      selectedItemsSubject.add(previousSelected);
    }
    return MultiSelectModal._(
      title: title,
      items: SelectItemsStream(itemStream: itemStream),
      itemBuilder: itemBuilder,
      itemTitleBuilder: itemTitleBuilder,
      modalType: modalType,
      selectedItemsSubject: selectedItemsSubject,
      previousSelected: previousSelected,
    );
  }

  Modal buildModal() {
    return Modal(
      body: ModalBody(
        titleBuilder: (context) => ModalTitle(title ?? context.cl.actions_select),
        slivers: [
          _Body(
            items: items,
            itemBuilder: itemBuilder,
            itemTitleBuilder: itemTitleBuilder,
            previousSelected: previousSelected,
            selectedItemsSubject: selectedItemsSubject,
          ),
        ],
      ),
      type: (context) => modalType,
    );
  }

  Future<Set<T>?> open(BuildContext context) async {
    final modal = buildModal();
    return modal.show<Set<T>>(context);
  }
}

class _Body<T> extends StatelessWidget {
  final SelectModalItems<T> items;
  final SelectItemBuilder<T>? itemBuilder;
  final SelectItemTitleBuilder<T>? itemTitleBuilder;
  final Set<T>? previousSelected;

  final DataSubject<Set<T>> selectedItemsSubject;
  const _Body({
    required this.items,
    required this.itemBuilder,
    required this.itemTitleBuilder,
    required this.selectedItemsSubject,
    required this.previousSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DataSubjectBuilder(
      subject: selectedItemsSubject,
      builder: (context, selectedItems) {
        return SliverMainAxisGroup(
          slivers: [
            switch (items) {
              SelectItemsList(items: final itemsList) => _Items(
                items: itemsList,
                itemBuilder: itemBuilder,
                itemTitleBuilder: itemTitleBuilder,
                selectedItems: selectedItems,
                previousSelected: previousSelected,
                onSelect: (item, selected) {
                  if (selected) {
                    selectedItems.add(item);
                  } else {
                    selectedItems.remove(item);
                  }
                  selectedItemsSubject.add(selectedItems);
                },
              ),
              SelectItemsStream(itemStream: final itemStream) => StreamBuilder(
                stream: itemStream,
                builder: (context, snapshot) {
                  final itemsList = snapshot.data;
                  if (itemsList == null) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return _Items(
                    items: itemsList,
                    itemBuilder: itemBuilder,
                    itemTitleBuilder: itemTitleBuilder,
                    selectedItems: selectedItems,
                    previousSelected: previousSelected,
                    onSelect: (item, selected) {
                      if (selected) {
                        selectedItems.add(item);
                      } else {
                        selectedItems.remove(item);
                      }
                      selectedItemsSubject.add(selectedItems);
                    },
                  );
                },
              ),
            },
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: OkModalActionsBar(
                  enabled: selectedItems.isNotEmpty,
                  label: context.cl.actions_select,
                  onTap: () {
                    Navigator.pop(context, selectedItems);
                  },
                ),
              ),
            ),
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
  final Set<T> selectedItems;
  final Function(T item, bool selected) onSelect;
  final Set<T>? previousSelected;
  const _Items({
    required this.items,
    required this.itemBuilder,
    required this.itemTitleBuilder,
    required this.selectedItems,
    required this.onSelect,
    required this.previousSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SliverBodyListItems(
      items: items,
      itemBuilder: (context, item) {
        final isSelected = selectedItems.contains(item);
        if (itemBuilder != null) {
          return itemBuilder!(
            context,
            item,
            isSelected,
            previousSelected,
            () => onSelect(item, !isSelected),
          );
        }

        return Tile(
          onTap: () {
            onSelect(item, !isSelected);
          },
          leading: IgnorePointer(
            child: Checkbox(
              value: isSelected,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (value) {},
            ),
          ),
          title: Text(
            itemTitleBuilder != null ? itemTitleBuilder!(context, item) : item.toString(),
          ),
        );
      },
    );
  }
}
