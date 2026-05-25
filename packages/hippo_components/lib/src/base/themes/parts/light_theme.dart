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

final lightCupertinoTheme = CupertinoThemeData(
  brightness: Brightness.light,
  primaryColor: HippoColors.black,
);

final lightMaterialTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(brightness: Brightness.light, seedColor: HippoColors.primary),
  cardTheme: CardThemeData(
    elevation: 0,
    margin: EdgeInsets.zero,
    color: HippoColors.sideBarLight,
    surfaceTintColor: HippoColors.sideBarLight,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
);

final lightForuiTheme = FThemeData(
  colors: FColors(
    brightness: Brightness.light,
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF09090B),
    primary: HippoColors.primary,
    primaryForeground: Color(0xFFFAFAFA),
    secondary: Color(0xFFF4F4F5),
    secondaryForeground: Color(0xFF18181B),
    card: Color(0xFFFFFFFF),
    muted: Color(0xFFF4F4F5),
    mutedForeground: Color(0xFF71717A),
    destructive: Color(0xFFEF4444),
    destructiveForeground: Color(0xFFFAFAFA),
    error: Color(0xFFEF4444),
    errorForeground: Color(0xFFFAFAFA),
    border: Color(0xFFE4E4E7),
    barrier: Color(0x33000000),
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  ),
  touch: true,
).copyWith();
