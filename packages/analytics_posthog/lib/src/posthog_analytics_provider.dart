/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:hippo_utils/hippo_utils.dart' show AnalyticsProvider;
import 'package:posthog_flutter/posthog_flutter.dart';

class PosthogAnalyticsProvider implements AnalyticsProvider {
  final Posthog _client;

  PosthogAnalyticsProvider({Posthog? client}) : _client = client ?? Posthog();

  @override
  void logEvent({required String eventName, Map<String, Object>? parameters}) {
    _client.capture(eventName: eventName, properties: parameters);
  }

  @override
  void identify({required String userId, Map<String, Object>? parameters}) {
    _client.identify(userId: userId, userProperties: parameters);
  }

  @override
  void resetAnalyticsData() {
    _client.reset();
  }

  @override
  void setCurrentScreen({required String screenName, Map<String, Object>? parameters}) {
    _client.screen(screenName: screenName, properties: parameters);
  }
}
