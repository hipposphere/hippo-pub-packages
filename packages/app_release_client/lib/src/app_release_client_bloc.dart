/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:async';

import 'package:app_release_client/src/app_release_api_controller.dart';
import 'package:app_release_client/src/models/app_release_channel.dart';
import 'package:app_release_client/src/models/app_release_target.dart';
import 'package:app_release_client/src/storage/channel_selection_store.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/widgets.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
import 'package:hippo_utils/hippo_utils.dart';

class AppReleaseClientBloc extends BlocBase {
  final AppReleaseApiController apiController;
  final ChannelSelectionStore channelSelectionStore;

  final String appSlug;
  final AppReleasePlatform platform;
  final AppReleaseArch? arch;
  final List<String>? packageTypes;
  final String defaultChannelSlug;
  final String? currentVersion;
  final bool publicChannelsOnly;

  String? _appId;

  final DataSubject<SelectedValue<List<AppReleaseChannel>>> channelsSubject;
  final DataSubject<SelectedValue<AppReleaseChannel?>> selectedChannelSubject;
  final DataSubject<SelectedValue<Uri?>?> appCastUrlSubject;
  final DataSubject<SelectedValue<Object?>?> errorSubject;

  AppReleaseClientBloc._({
    required this.apiController,
    required this.channelSelectionStore,
    required this.appSlug,
    required this.platform,
    required this.arch,
    required this.packageTypes,
    required this._appId,
    required this.defaultChannelSlug,
    required this.currentVersion,
    required this.publicChannelsOnly,
    required this.channelsSubject,
    required this.selectedChannelSubject,
    required this.appCastUrlSubject,
    required this.errorSubject,
  }) {
    unawaited(initialize());
  }

  factory AppReleaseClientBloc.create({
    required Uri baseUrl,
    required KeyValueStore keyValueStore,
    required String appSlug,
    required AppReleasePlatform platform,
    AppReleaseArch? arch,
    List<String>? packageTypes,
    String? appId,
    String defaultChannelSlug = 'stable',
    String? currentVersion,
    String? selectedChannelStoreKey,
    String? knownHiddenChannelSlugsStoreKey,
    bool publicChannelsOnly = true,
    List<Interceptor>? interceptors,
  }) {
    return AppReleaseClientBloc._(
      apiController: AppReleaseApiController(
        baseUrl: baseUrl,
        interceptors: interceptors,
      ),
      channelSelectionStore: ChannelSelectionStore(
        keyValueStore: keyValueStore,
        selectedChannelStoreKey: selectedChannelStoreKey,
        knownHiddenChannelSlugsStoreKey: knownHiddenChannelSlugsStoreKey,
      ),
      appSlug: appSlug,
      platform: platform,
      arch: arch,
      packageTypes: packageTypes?.toList(growable: false),
      appId: appId,
      defaultChannelSlug: defaultChannelSlug,
      currentVersion: currentVersion,
      publicChannelsOnly: publicChannelsOnly,
      channelsSubject: DataSubject.seeded(
        const SelectedValue(<AppReleaseChannel>[]),
      ),
      selectedChannelSubject: DataSubject.seeded(
        const SelectedValue<AppReleaseChannel?>(null),
      ),
      appCastUrlSubject: DataSubject.seeded(null),
      errorSubject: DataSubject.seeded(null),
    );
  }

  static AppReleaseClientBloc of(BuildContext context) {
    return BlocProvider.of<AppReleaseClientBloc>(context);
  }

  Future<void> initialize() async {
    try {
      final storedChannelSlug = await channelSelectionStore
          .readSelectedChannelSlug();
      final knownHiddenChannelSlugs = await channelSelectionStore
          .readKnownHiddenChannelSlugs();
      final preferredChannelSlug = storedChannelSlug ?? defaultChannelSlug;
      final hiddenChannelSlugs = publicChannelsOnly
          ? const <String>[]
          : <String>[
              ...knownHiddenChannelSlugs,
              if (storedChannelSlug != null) preferredChannelSlug,
            ];
      final channels = await _loadChannels(
        hiddenChannelSlugs: hiddenChannelSlugs,
      );
      channelsSubject.add(SelectedValue(channels));

      final selectedChannel = _resolveSelectedChannel(
        channels: channels,
        preferredChannelSlug: preferredChannelSlug,
      );
      await _rememberKnownHiddenChannels(
        channels: channels,
        selectedChannel: selectedChannel,
      );

      selectedChannelSubject.add(SelectedValue(selectedChannel));
      appCastUrlSubject.add(
        SelectedValue(_buildAppCastUrl(selectedChannel?.slug)),
      );
      errorSubject.add(null);
    } catch (error) {
      errorSubject.add(SelectedValue(error));

      final fallbackChannel = AppReleaseChannel.fallback(
        slug: defaultChannelSlug,
        appId: _appId,
      );

      channelsSubject.add(SelectedValue([fallbackChannel]));
      selectedChannelSubject.add(SelectedValue(fallbackChannel));
      appCastUrlSubject.add(
        SelectedValue(_buildAppCastUrl(fallbackChannel.slug)),
      );
    }
  }

  Future<void> refreshChannels() async {
    await initialize();
  }

  Future<void> selectChannelBySlug(String channelSlug) async {
    final channels = channelsSubject.value.value;
    final selectedChannel = _resolveSelectedChannel(
      channels: channels,
      preferredChannelSlug: channelSlug,
    );

    if (selectedChannel == null) {
      return;
    }

    await channelSelectionStore.saveSelectedChannelSlug(selectedChannel.slug);
    if (!selectedChannel.isPublic) {
      await channelSelectionStore.rememberHiddenChannelSlug(
        selectedChannel.slug,
      );
    }
    selectedChannelSubject.add(SelectedValue(selectedChannel));
    appCastUrlSubject.add(
      SelectedValue(_buildAppCastUrl(selectedChannel.slug)),
    );
    errorSubject.add(null);
  }

  Future<void> clearSelectedChannel() async {
    await channelSelectionStore.clearSelectedChannelSlug();
    await initialize();
  }

  Uri? _buildAppCastUrl(String? channelSlug) {
    if (channelSlug == null || channelSlug.isEmpty) {
      return null;
    }

    return apiController.buildAppCastUri(
      appSlug: appSlug,
      platform: platform,
      arch: arch,
      packageTypes: packageTypes,
      channelSlug: channelSlug,
      currentVersion: currentVersion,
    );
  }

  Future<List<AppReleaseChannel>> _loadChannels({
    required Iterable<String> hiddenChannelSlugs,
  }) async {
    final channels = await apiController.listChannels(
      appId: _appId,
      appSlug: appSlug,
      publicOnly: publicChannelsOnly,
      includeHiddenChannelSlugs: publicChannelsOnly ? null : hiddenChannelSlugs,
    );

    if (channels.isNotEmpty) {
      final resolvedAppId = channels.first.appId;
      if ((_appId == null || _appId!.isEmpty) && resolvedAppId.isNotEmpty) {
        _appId = resolvedAppId;
      }
      return channels;
    }

    return [
      AppReleaseChannel.fallback(slug: defaultChannelSlug, appId: _appId),
    ];
  }

  Future<void> _rememberKnownHiddenChannels({
    required List<AppReleaseChannel> channels,
    required AppReleaseChannel? selectedChannel,
  }) async {
    if (publicChannelsOnly) {
      return;
    }

    final knownHiddenChannelSlugs = <String>[
      for (final channel in channels)
        if (!channel.isPublic) channel.slug,
      if (selectedChannel != null && !selectedChannel.isPublic)
        selectedChannel.slug,
    ];
    if (knownHiddenChannelSlugs.isEmpty) {
      return;
    }

    await channelSelectionStore.rememberHiddenChannelSlugs(
      knownHiddenChannelSlugs,
    );
  }

  AppReleaseChannel? _resolveSelectedChannel({
    required List<AppReleaseChannel> channels,
    required String preferredChannelSlug,
  }) {
    if (channels.isEmpty) {
      return null;
    }

    for (final channel in channels) {
      if (channel.slug == preferredChannelSlug) {
        return channel;
      }
    }

    for (final channel in channels) {
      if (channel.slug == defaultChannelSlug) {
        return channel;
      }
    }

    return channels.first;
  }

  @override
  void dispose() {
    apiController.dispose();
    channelsSubject.close();
    selectedChannelSubject.close();
    appCastUrlSubject.close();
    errorSubject.close();
  }
}
