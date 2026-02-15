/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
enum AppReleasePlatform { macos, windows, linux }

enum AppReleaseArch { x64, arm64 }

extension AppReleasePlatformValue on AppReleasePlatform {
  String get value {
    switch (this) {
      case AppReleasePlatform.macos:
        return 'macos';
      case AppReleasePlatform.windows:
        return 'windows';
      case AppReleasePlatform.linux:
        return 'linux';
    }
  }
}

extension AppReleaseArchValue on AppReleaseArch {
  String get value {
    switch (this) {
      case AppReleaseArch.x64:
        return 'x64';
      case AppReleaseArch.arm64:
        return 'arm64';
    }
  }
}
