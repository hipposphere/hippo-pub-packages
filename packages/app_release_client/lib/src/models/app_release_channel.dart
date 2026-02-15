/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:app_release_client/api/openapi.enums.swagger.dart' as api_enums;
import 'package:app_release_client/api/openapi.models.swagger.dart';

class AppReleaseChannel {
  final String id;
  final String appId;
  final String slug;
  final String? displayName;
  final bool isSystem;
  final bool isPublic;
  final int rolloutPercent;

  const AppReleaseChannel({
    required this.id,
    required this.appId,
    required this.slug,
    this.displayName,
    required this.isSystem,
    required this.isPublic,
    required this.rolloutPercent,
  });

  factory AppReleaseChannel.fromApi(ApiV1ChannelsGet$Response$Item item) {
    return AppReleaseChannel(
      id: item.id,
      appId: item.appId,
      slug: item.slug,
      displayName: item.displayName,
      isSystem: item.isSystem,
      isPublic:
          item.visibility ==
          api_enums.ApiV1ChannelsGet$Response$ItemVisibility.public,
      rolloutPercent: item.rolloutPercent,
    );
  }

  factory AppReleaseChannel.fallback({required String slug, String? appId}) {
    return AppReleaseChannel(
      id: 'fallback:$slug',
      appId: appId ?? '',
      slug: slug,
      displayName: null,
      isSystem: true,
      isPublic: true,
      rolloutPercent: 100,
    );
  }

  String get label {
    final value = displayName?.trim();
    if (value == null || value.isEmpty) {
      return slug;
    }
    return value;
  }

  @override
  String toString() {
    return 'AppReleaseChannel(slug: $slug, label: $label, isPublic: $isPublic)';
  }
}
