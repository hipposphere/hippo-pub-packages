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
    final localeName = cl.localeName;
    if (localeName == 'de' && de != null) {
      return de;
    }
    if (localeName == 'fr' && fr != null) {
      return fr;
    }
    if (localeName == 'es' && es != null) {
      return es;
    }
    if (localeName == 'zh' && zh != null) {
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

Contextable<String> translateLazy({required String en, String? de, String? fr, String? es}) {
  return (context) => context.lazyTranslate(en: en, de: de, fr: fr, es: es);
}
