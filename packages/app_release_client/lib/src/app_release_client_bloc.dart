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
import 'package:hippo_utils/hippo_utils.dart';

class AppReleaseClientBloc extends BlocBase {
  final AppReleaseApiController apiController;
  final ChannelSelectionStore channelSelectionStore;

  final String appSlug;
  final AppReleasePlatform platform;
  final AppReleaseArch arch;
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
    required String? appId,
    required this.defaultChannelSlug,
    required this.currentVersion,
    required this.publicChannelsOnly,
    required this.channelsSubject,
    required this.selectedChannelSubject,
    required this.appCastUrlSubject,
    required this.errorSubject,
  }) : _appId = appId {
    unawaited(initialize());
  }

  factory AppReleaseClientBloc.create({
    required Uri baseUrl,
    required KeyValueStore keyValueStore,
    required String appSlug,
    required AppReleasePlatform platform,
    required AppReleaseArch arch,
    String? appId,
    String defaultChannelSlug = 'stable',
    String? currentVersion,
    String? selectedChannelStoreKey,
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
      ),
      appSlug: appSlug,
      platform: platform,
      arch: arch,
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
      final channels = await _loadChannels();
      channelsSubject.add(SelectedValue(channels));

      final storedChannelSlug = await channelSelectionStore
          .readSelectedChannelSlug();
      final preferredChannelSlug = storedChannelSlug ?? defaultChannelSlug;

      final selectedChannel = _resolveSelectedChannel(
        channels: channels,
        preferredChannelSlug: preferredChannelSlug,
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
      channelSlug: channelSlug,
      currentVersion: currentVersion,
    );
  }

  Future<List<AppReleaseChannel>> _loadChannels() async {
    final appId = await _resolveAppId();
    if (appId == null || appId.isEmpty) {
      return [
        AppReleaseChannel.fallback(slug: defaultChannelSlug, appId: _appId),
      ];
    }

    final channels = await apiController.listChannels(
      appId: appId,
      publicOnly: publicChannelsOnly,
    );

    if (channels.isEmpty) {
      return [
        AppReleaseChannel.fallback(slug: defaultChannelSlug, appId: appId),
      ];
    }

    return channels;
  }

  Future<String?> _resolveAppId() async {
    if (_appId != null && _appId!.isNotEmpty) {
      return _appId;
    }

    final appId = await apiController.findAppIdBySlug(appSlug);
    _appId = appId;
    return appId;
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
