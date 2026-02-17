/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:app_release_client/api/openapi.swagger.dart';
import 'package:app_release_client/src/models/app_release_channel.dart';
import 'package:app_release_client/src/models/app_release_target.dart';
import 'package:chopper/chopper.dart';

class AppReleaseApiController {
  final Uri baseUrl;
  final Openapi api;

  AppReleaseApiController({
    required this.baseUrl,
    List<Interceptor>? interceptors,
  }) : api = Openapi.create(
         baseUrl: baseUrl,
         interceptors: interceptors ?? const [],
       );

  Future<String?> findAppIdBySlug(String appSlug) async {
    final response = await api.apiV1AppsGet();
    if (!response.isSuccessful) {
      throw AppReleaseClientApiException(
        'Unable to list apps. HTTP ${response.statusCode}.',
      );
    }

    final apps = response.body;
    if (apps == null) {
      return null;
    }

    for (final app in apps) {
      if (app.slug == appSlug) {
        return app.id;
      }
    }

    return null;
  }

  Future<List<AppReleaseChannel>> listChannels({
    required String appId,
    bool publicOnly = true,
  }) async {
    final response = await api.apiV1ChannelsGet(appId: appId);
    if (!response.isSuccessful) {
      throw AppReleaseClientApiException(
        'Unable to list channels. HTTP ${response.statusCode}.',
      );
    }

    final channels = response.body ?? const [];
    final mapped = channels
        .map(AppReleaseChannel.fromApi)
        .toList(growable: false);
    if (!publicOnly) {
      return mapped;
    }

    return mapped.where((channel) => channel.isPublic).toList(growable: false);
  }

  Uri buildAppCastUri({
    required String appSlug,
    required AppReleasePlatform platform,
    AppReleaseArch? arch,
    List<String>? packageTypes,
    required String channelSlug,
    String? currentVersion,
  }) {
    final encodedAppSlug = Uri.encodeComponent(appSlug);
    final encodedChannelSlug = Uri.encodeComponent(channelSlug);
    final appcastPath =
        '/api/public/v1/appcast/$encodedAppSlug/${platform.value}/$encodedChannelSlug/appcast.xml';

    final normalizedPackageTypes = packageTypes
        ?.map((packageType) => packageType.trim())
        .where((packageType) => packageType.isNotEmpty)
        .toList(growable: false);
    final queryParts = <String>[
      if (arch != null) 'arch=${Uri.encodeQueryComponent(arch.value)}',
      if (currentVersion != null && currentVersion.isNotEmpty)
        'currentVersion=${Uri.encodeQueryComponent(currentVersion)}',
      if (normalizedPackageTypes != null)
        for (final packageType in normalizedPackageTypes)
          'packageType=${Uri.encodeQueryComponent(packageType)}',
    ];

    final basePath = baseUrl.path.endsWith('/')
        ? baseUrl.path.substring(0, baseUrl.path.length - 1)
        : baseUrl.path;

    return baseUrl.replace(
      path: '$basePath$appcastPath',
      query: queryParts.isEmpty ? null : queryParts.join('&'),
    );
  }

  void dispose() {
    api.client.dispose();
  }
}

class AppReleaseClientApiException implements Exception {
  final String message;

  AppReleaseClientApiException(this.message);

  @override
  String toString() => 'AppReleaseClientApiException(message: $message)';
}
