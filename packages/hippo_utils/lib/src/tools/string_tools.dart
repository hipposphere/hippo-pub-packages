/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
//
String truncateStringToMaxLength(String input, {int maxLength = 64}) {
  if (input.length <= maxLength) {
    return input;
  }
  return input.substring(0, maxLength);
}
