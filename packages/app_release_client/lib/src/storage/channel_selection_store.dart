/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:convert';

import 'package:hippo_core/hippo_core.dart';

const defaultSelectedChannelStoreKey = 'app_release_client.selected_channel';
const defaultKnownHiddenChannelSlugsStoreKey =
    'app_release_client.known_hidden_channel_slugs';

class ChannelSelectionStore {
  final KeyValueStore keyValueStore;
  final String selectedChannelStoreKey;
  final String knownHiddenChannelSlugsStoreKey;

  ChannelSelectionStore({
    required this.keyValueStore,
    String? selectedChannelStoreKey,
    String? knownHiddenChannelSlugsStoreKey,
  }) : selectedChannelStoreKey =
           selectedChannelStoreKey ?? defaultSelectedChannelStoreKey,
       knownHiddenChannelSlugsStoreKey =
           knownHiddenChannelSlugsStoreKey ??
           defaultKnownHiddenChannelSlugsStoreKey;

  Future<String?> readSelectedChannelSlug() {
    return keyValueStore.getString(selectedChannelStoreKey);
  }

  Future<void> saveSelectedChannelSlug(String channelSlug) {
    return keyValueStore.setString(selectedChannelStoreKey, channelSlug);
  }

  Future<void> clearSelectedChannelSlug() {
    return keyValueStore.removeValue(selectedChannelStoreKey);
  }

  Future<List<String>> readKnownHiddenChannelSlugs() async {
    final encodedSlugs = await keyValueStore.getString(
      knownHiddenChannelSlugsStoreKey,
    );
    return _decodeChannelSlugs(encodedSlugs);
  }

  Future<void> saveKnownHiddenChannelSlugs(
    Iterable<String> channelSlugs,
  ) async {
    final normalizedSlugs = _normalizeChannelSlugs(channelSlugs);
    if (normalizedSlugs.isEmpty) {
      await keyValueStore.removeValue(knownHiddenChannelSlugsStoreKey);
      return;
    }

    await keyValueStore.setString(
      knownHiddenChannelSlugsStoreKey,
      jsonEncode(normalizedSlugs),
    );
  }

  Future<void> rememberHiddenChannelSlug(String channelSlug) {
    return rememberHiddenChannelSlugs([channelSlug]);
  }

  Future<void> rememberHiddenChannelSlugs(Iterable<String> channelSlugs) async {
    final existingChannelSlugs = await readKnownHiddenChannelSlugs();
    final mergedSlugs = _normalizeChannelSlugs([
      ...existingChannelSlugs,
      ...channelSlugs,
    ]);

    if (_listEquals(existingChannelSlugs, mergedSlugs)) {
      return;
    }

    await saveKnownHiddenChannelSlugs(mergedSlugs);
  }

  Future<void> clearKnownHiddenChannelSlugs() {
    return keyValueStore.removeValue(knownHiddenChannelSlugsStoreKey);
  }

  static List<String> _decodeChannelSlugs(String? encodedSlugs) {
    final value = encodedSlugs?.trim();
    if (value == null || value.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return _normalizeChannelSlugs(decoded);
      }
    } on FormatException {
      // Keep backward compatibility if older versions stored a plain CSV string.
      return _normalizeChannelSlugs(value.split(','));
    }

    return const [];
  }

  static List<String> _normalizeChannelSlugs(Iterable<Object?> channelSlugs) {
    final normalizedSlugs = <String>[];
    final seen = <String>{};

    for (final channelSlug in channelSlugs) {
      if (channelSlug is! String) {
        continue;
      }

      final normalizedSlug = channelSlug.trim();
      if (normalizedSlug.isEmpty || !seen.add(normalizedSlug)) {
        continue;
      }
      normalizedSlugs.add(normalizedSlug);
    }

    return normalizedSlugs;
  }

  static bool _listEquals(List<String> left, List<String> right) {
    if (left.length != right.length) {
      return false;
    }

    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) {
        return false;
      }
    }
    return true;
  }
}
