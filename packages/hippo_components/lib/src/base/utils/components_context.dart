import 'package:flutter/cupertino.dart';
import 'package:hippo_components/hippo_components.dart';

extension ComponentsContextExtension on BuildContext {
  ComponentsLocalizations get cl => ComponentsLocalizations.of(this)!;

  String lazyTranslate({required String en, String? de}) {
    final localeName = cl.localeName;
    if (localeName == 'de' && de != null) {
      return de;
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

Contextable<String> translateLazy({required String en, String? de}) {
  return (context) => context.lazyTranslate(en: en, de: de);
}
