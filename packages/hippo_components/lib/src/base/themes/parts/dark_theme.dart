/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
part of '../themes.dart';

final darkCupertinoTheme = CupertinoThemeData(
  brightness: Brightness.dark,
  primaryColor: HippoColors.white,
);

final darkMaterialTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: HippoColors.primary),
  cardTheme: CardThemeData(
    elevation: 0,
    margin: EdgeInsets.zero,
    color: HippoColors.sideBarDark,
    surfaceTintColor: HippoColors.sideBarDark,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
);

final darkForuiTheme = FThemeData(
  colors: FColors(
    brightness: Brightness.dark,
    background: Color(0xFF09090B),
    foreground: Color(0xFFFAFAFA),
    primary: HippoColors.primary,
    primaryForeground: Color(0xFFFAFAFA),
    secondary: Color(0xFF27272A),
    secondaryForeground: Color(0xFFFAFAFA),
    card: Color(0xFF1C1C1E),
    muted: Color(0xFF27272A),
    mutedForeground: Color(0xFFA1A1AA),
    destructive: Color(0xFF7F1D1D),
    destructiveForeground: Color(0xFFFAFAFA),
    error: Color(0xFF7F1D1D),
    errorForeground: Color(0xFFFAFAFA),
    border: Color(0xFF27272A),
    barrier: Color(0x7A000000),
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
);
