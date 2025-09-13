/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:uuid/v4.dart' as uuid_v4;

class IdGenerator {
  const IdGenerator._();

  static String uuidV4() {
    return uuid_v4.UuidV4().generate();
  }
}
