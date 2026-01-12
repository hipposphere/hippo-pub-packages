import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Maps [PhysicalKeyboardKey] to their symbolic representations.
/// Works in both debug and release modes.
class KeySymbols {
  static String getSymbol(PhysicalKeyboardKey key) {
    // Check platform independent (common) symbols first
    if (_commonSymbols.containsKey(key)) {
      return _commonSymbols[key]!;
    }

    // Check platform specific maps
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        if (_macSymbols.containsKey(key)) return _macSymbols[key]!;
        break;
      case TargetPlatform.windows:
        if (_windowsSymbols.containsKey(key)) return _windowsSymbols[key]!;
        break;
      default:
        break;
    }

    // Fallback to generic modifier names if not handled by platform-specific ones
    if (_fallbackSymbols.containsKey(key)) {
      return _fallbackSymbols[key]!;
    }

    // For other keys, we might need a way to show them in release mode.
    // If it's a letter or digit, we can use a manual map if requested.
    return _alphanumericSymbols[key] ?? 'Unknown';
  }

  static final Map<PhysicalKeyboardKey, String> _commonSymbols = {
    PhysicalKeyboardKey.enter: '⏎',
    PhysicalKeyboardKey.backspace: '⌫',
    PhysicalKeyboardKey.tab: '⇥',
    PhysicalKeyboardKey.capsLock: '⇪',
    PhysicalKeyboardKey.space: 'Space',
    PhysicalKeyboardKey.escape: 'Esc',
    PhysicalKeyboardKey.arrowUp: '↑',
    PhysicalKeyboardKey.arrowDown: '↓',
    PhysicalKeyboardKey.arrowLeft: '←',
    PhysicalKeyboardKey.arrowRight: '→',
    PhysicalKeyboardKey.delete: 'Del',
    PhysicalKeyboardKey.end: 'End',
    PhysicalKeyboardKey.home: 'Home',
    PhysicalKeyboardKey.pageDown: 'PgDn',
    PhysicalKeyboardKey.pageUp: 'PgUp',
    PhysicalKeyboardKey.insert: 'Ins',
    PhysicalKeyboardKey.printScreen: 'PrtScn',
    PhysicalKeyboardKey.shiftLeft: '⇧ (L)',
    PhysicalKeyboardKey.shiftRight: '⇧ (R)',
    PhysicalKeyboardKey.comma: ',',
    PhysicalKeyboardKey.period: '.',
    PhysicalKeyboardKey.slash: '/',
    PhysicalKeyboardKey.semicolon: ';',
    PhysicalKeyboardKey.quote: "'",
    PhysicalKeyboardKey.bracketLeft: '[',
    PhysicalKeyboardKey.bracketRight: ']',
    PhysicalKeyboardKey.backslash: '\\',
    PhysicalKeyboardKey.minus: '-',
    PhysicalKeyboardKey.equal: '=',
    PhysicalKeyboardKey.backquote: '`',
  };

  static final Map<PhysicalKeyboardKey, String> _macSymbols = {
    PhysicalKeyboardKey.metaLeft: '⌘ (L)',
    PhysicalKeyboardKey.metaRight: '⌘ (R)',
    PhysicalKeyboardKey.controlLeft: '⌃ (L)',
    PhysicalKeyboardKey.controlRight: '⌃ (R)',
    PhysicalKeyboardKey.altLeft: '⌥ (L)',
    PhysicalKeyboardKey.altRight: '⌥ (R)',
  };

  static final Map<PhysicalKeyboardKey, String> _windowsSymbols = {
    PhysicalKeyboardKey.metaLeft: '⊞ (L)',
    PhysicalKeyboardKey.metaRight: '⊞ (R)',
    PhysicalKeyboardKey.controlLeft: 'Ctrl (L)',
    PhysicalKeyboardKey.controlRight: 'Ctrl (R)',
    PhysicalKeyboardKey.altLeft: 'Alt (L)',
    PhysicalKeyboardKey.altRight: 'Alt (R)',
  };

  static final Map<PhysicalKeyboardKey, String> _fallbackSymbols = {
    PhysicalKeyboardKey.metaLeft: 'Meta (L)',
    PhysicalKeyboardKey.metaRight: 'Meta (R)',
    PhysicalKeyboardKey.controlLeft: 'Ctrl (L)',
    PhysicalKeyboardKey.controlRight: 'Ctrl (R)',
    PhysicalKeyboardKey.altLeft: 'Alt (L)',
    PhysicalKeyboardKey.altRight: 'Alt (R)',
  };

  // Common alphanumeric keys for release mode support
  static final Map<PhysicalKeyboardKey, String> _alphanumericSymbols = {
    PhysicalKeyboardKey.keyA: 'A',
    PhysicalKeyboardKey.keyB: 'B',
    PhysicalKeyboardKey.keyC: 'C',
    PhysicalKeyboardKey.keyD: 'D',
    PhysicalKeyboardKey.keyE: 'E',
    PhysicalKeyboardKey.keyF: 'F',
    PhysicalKeyboardKey.keyG: 'G',
    PhysicalKeyboardKey.keyH: 'H',
    PhysicalKeyboardKey.keyI: 'I',
    PhysicalKeyboardKey.keyJ: 'J',
    PhysicalKeyboardKey.keyK: 'K',
    PhysicalKeyboardKey.keyL: 'L',
    PhysicalKeyboardKey.keyM: 'M',
    PhysicalKeyboardKey.keyN: 'N',
    PhysicalKeyboardKey.keyO: 'O',
    PhysicalKeyboardKey.keyP: 'P',
    PhysicalKeyboardKey.keyQ: 'Q',
    PhysicalKeyboardKey.keyR: 'R',
    PhysicalKeyboardKey.keyS: 'S',
    PhysicalKeyboardKey.keyT: 'T',
    PhysicalKeyboardKey.keyU: 'U',
    PhysicalKeyboardKey.keyV: 'V',
    PhysicalKeyboardKey.keyW: 'W',
    PhysicalKeyboardKey.keyX: 'X',
    PhysicalKeyboardKey.keyY: 'Y',
    PhysicalKeyboardKey.keyZ: 'Z',
    PhysicalKeyboardKey.digit0: '0',
    PhysicalKeyboardKey.digit1: '1',
    PhysicalKeyboardKey.digit2: '2',
    PhysicalKeyboardKey.digit3: '3',
    PhysicalKeyboardKey.digit4: '4',
    PhysicalKeyboardKey.digit5: '5',
    PhysicalKeyboardKey.digit6: '6',
    PhysicalKeyboardKey.digit7: '7',
    PhysicalKeyboardKey.digit8: '8',
    PhysicalKeyboardKey.digit9: '9',
    PhysicalKeyboardKey.f1: 'F1',
    PhysicalKeyboardKey.f2: 'F2',
    PhysicalKeyboardKey.f3: 'F3',
    PhysicalKeyboardKey.f4: 'F4',
    PhysicalKeyboardKey.f5: 'F5',
    PhysicalKeyboardKey.f6: 'F6',
    PhysicalKeyboardKey.f7: 'F7',
    PhysicalKeyboardKey.f8: 'F8',
    PhysicalKeyboardKey.f9: 'F9',
    PhysicalKeyboardKey.f10: 'F10',
    PhysicalKeyboardKey.f11: 'F11',
    PhysicalKeyboardKey.f12: 'F12',
  };
}
