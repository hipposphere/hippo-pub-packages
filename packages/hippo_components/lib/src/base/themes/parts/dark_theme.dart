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
  colors: const FColors(
    brightness: Brightness.dark,
    background: Color(0xFF09090B),
    foreground: Color(0xFFFAFAFA),
    primary: HippoColors.primary,
    primaryForeground: Color(0xFFFAFAFA),
    secondary: Color(0xFF27272A),
    secondaryForeground: Color(0xFFFAFAFA),
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
