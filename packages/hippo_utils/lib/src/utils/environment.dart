import 'package:flutter/foundation.dart';

bool get isWebOrDesktopPlatform {
  if (kIsWeb) {
    return true;
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.macOS || TargetPlatform.windows || TargetPlatform.linux => true,
    _ => false,
  };
}

bool get isDesktopPlatform {
  if (kIsWeb) {
    return false;
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.macOS || TargetPlatform.windows || TargetPlatform.linux => true,
    _ => false,
  };
}

bool get isDesktopMacosPlatform {
  if (kIsWeb) {
    return false;
  }
  return defaultTargetPlatform == .macOS;
}

bool get isDesktopWindowsPlatform {
  if (kIsWeb) {
    return false;
  }
  return defaultTargetPlatform == .windows;
}

bool get isWebOrMobilePlatform {
  if (kIsWeb) {
    return true;
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS || TargetPlatform.android => true,
    _ => false,
  };
}

bool get isMobilePlatform {
  if (kIsWeb) {
    return false;
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS || TargetPlatform.android => true,
    _ => false,
  };
}
