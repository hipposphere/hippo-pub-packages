/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
double safeDouble(dynamic value) {
  switch (value) {
    case num n:
      return n.toDouble();
    case String s:
      final n = num.tryParse(s);
      if (n != null) return n.toDouble();
  }
  throw ArgumentError.value(value, 'value', 'Could not parse double');
}

int safeInt(dynamic value) {
  switch (value) {
    case num n:
      // Achtung: toInt() schneidet Richtung 0 ab (z.B. 3.9 -> 3, -3.9 -> -3).
      return n.toInt();
    case String s:
      final n = num.tryParse(s);
      if (n != null) return n.toInt();
  }
  throw ArgumentError.value(value, 'value', 'Could not parse int');
}
