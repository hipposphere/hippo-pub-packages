/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter/widgets.dart';
import 'package:hippo_utils/package_info_plus.dart';

class AppVersionText extends StatelessWidget {
  const AppVersionText({super.key});

  @override
  Widget build(BuildContext context) {
    final future = PackageInfo.fromPlatform();
    return FutureBuilder<PackageInfo>(
      future: future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return SizedBox();
        }
        return Text('Version: ${data.version} (${data.buildNumber})\n', textAlign: TextAlign.start);
      },
    );
  }
}
