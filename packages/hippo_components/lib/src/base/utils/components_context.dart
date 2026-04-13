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
import 'package:hippo_components/hippo_components.dart';

extension ComponentsContextExtension on BuildContext {
  ComponentsLocalizations get cl => ComponentsLocalizations.of(this)!;

  String lazyTranslate({required String en, String? de, String? fr, String? es, String? zh}) {
    final localeName =
        ComponentsLocalizations.of(this)?.localeName ??
        Localizations.maybeLocaleOf(this)?.toLanguageTag() ??
        'en';
    final languageCode = localeName.split(RegExp(r'[-_]')).first.toLowerCase();
    if (languageCode == 'de' && de != null) {
      return de;
    }
    if (languageCode == 'fr' && fr != null) {
      return fr;
    }
    if (languageCode == 'es' && es != null) {
      return es;
    }
    if (languageCode == 'zh' && zh != null) {
      return zh;
    }
    return en;
  }

  T onBrightness<T>({required T light, required T dark}) {
    final brightness = CupertinoTheme.of(this).brightness;
    if (brightness == Brightness.light) {
      return light;
    }
    return dark;
  }
}

Contextable<String> translateCL(String Function(ComponentsLocalizations cl) translate) {
  return (context) => translate(ComponentsLocalizations.of(context)!);
}

Contextable<String> translateLazy({
  required String en,
  String? de,
  String? fr,
  String? es,
  String? zh,
}) {
  return (context) => context.lazyTranslate(en: en, de: de, fr: fr, es: es, zh: zh);
}
