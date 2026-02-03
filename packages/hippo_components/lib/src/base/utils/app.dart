/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:forui/forui.dart';
import 'package:hippo_components/hippo_components.dart';

class App extends StatelessWidget {
  final String title;
  final Brightness brightness;
  final Widget? home;
  final Locale? locale;
  final Iterable<Locale>? supportedLocales;
  final GlobalKey<NavigatorState>? navigatorKey;
  final List<LocalizationsDelegate> localizationsDelegate;
  final List<NavigatorObserver> navigatorObservers;
  const App({
    super.key,
    required this.brightness,
    this.title = '',
    this.locale,
    this.navigatorKey,
    this.supportedLocales,
    this.localizationsDelegate = const [],
    this.navigatorObservers = const [],
    this.home,
  });

  @override
  Widget build(BuildContext context) {
    return FTheme(
      data: brightness == Brightness.light ? lightForuiTheme : darkForuiTheme,
      child: Theme(
        data: brightness == Brightness.light ? lightMaterialTheme : darkMaterialTheme,
        child: CupertinoApp(
          title: title,
          navigatorKey: navigatorKey,
          localizationsDelegates: [
            ComponentsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            ...localizationsDelegate,
          ],
          scrollBehavior: switch (defaultTargetPlatform) {
            TargetPlatform.iOS || TargetPlatform.macOS => CupertinoScrollBehavior().copyWith(
              dragDevices: PointerDeviceKind.values.toSet(),
            ),
            _ => MaterialScrollBehavior().copyWith(dragDevices: PointerDeviceKind.values.toSet()),
          },
          navigatorObservers: navigatorObservers,
          locale: locale,
          supportedLocales: supportedLocales ?? ComponentsLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          theme: brightness == Brightness.light ? lightCupertinoTheme : darkCupertinoTheme,
          home: home,
          onGenerateRoute: (settings) {
            return MaterialPageRoute(settings: settings, builder: (context) => home!);
          },
        ),
      ),
    );
  }
}
