/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:hippo_utils/hippo_utils.dart';

const defaultSelectedChannelStoreKey = 'app_release_client.selected_channel';

class ChannelSelectionStore {
  final KeyValueStore keyValueStore;
  final String selectedChannelStoreKey;

  ChannelSelectionStore({
    required this.keyValueStore,
    String? selectedChannelStoreKey,
  }) : selectedChannelStoreKey =
           selectedChannelStoreKey ?? defaultSelectedChannelStoreKey;

  Future<String?> readSelectedChannelSlug() {
    return keyValueStore.getString(selectedChannelStoreKey);
  }

  Future<void> saveSelectedChannelSlug(String channelSlug) {
    return keyValueStore.setString(selectedChannelStoreKey, channelSlug);
  }

  Future<void> clearSelectedChannelSlug() {
    return keyValueStore.removeValue(selectedChannelStoreKey);
  }
}
