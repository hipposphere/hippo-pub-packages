import 'dart:io';

import 'package:speech_utils_android/speech_utils_android.dart';
import 'package:speech_utils_ios/speech_utils_ios.dart';
import 'package:speech_utils_linux/speech_utils_linux.dart';
import 'package:speech_utils_macos/speech_utils_macos.dart';
import 'package:speech_utils_platform_interface/speech_utils_platform_interface.dart';
import 'package:speech_utils_windows/speech_utils_windows.dart';

import '../utils/pcm16_audio_utils.dart';

typedef NativeAudioMetadataReadFn = AudioMetadata Function(String inputPath);
typedef NativeAudioMetadataAvailabilityFn = bool Function();

enum NativeAudioMetadataPlatform { macOS, windows, linux, android, iOS, unsupported }

const _unsupportedMessage =
    'NativeAudioMetadataReader is currently supported on macOS, Windows, Linux, Android, and iOS.';

/// Portable metadata facade backed by the active federated platform package.
final class NativeAudioMetadataReader {
  NativeAudioMetadataReader({
    NativeAudioMetadataPlatform? platform,
    NativeAudioMetadataReadFn? macosReadFn,
    NativeAudioMetadataAvailabilityFn? macosAvailabilityFn,
    NativeAudioMetadataReadFn? windowsReadFn,
    NativeAudioMetadataAvailabilityFn? windowsAvailabilityFn,
    NativeAudioMetadataReadFn? linuxReadFn,
    NativeAudioMetadataAvailabilityFn? linuxAvailabilityFn,
    NativeAudioMetadataReadFn? androidReadFn,
    NativeAudioMetadataAvailabilityFn? androidAvailabilityFn,
    NativeAudioMetadataReadFn? iosReadFn,
    NativeAudioMetadataAvailabilityFn? iosAvailabilityFn,
  }) : _platform = platform ?? _detectPlatform(),
       _readOverrides = _buildReadOverrides(
         macosReadFn,
         windowsReadFn,
         linuxReadFn,
         androidReadFn,
         iosReadFn,
       ),
       _availabilityOverrides = _buildAvailabilityOverrides(
         macosAvailabilityFn,
         windowsAvailabilityFn,
         linuxAvailabilityFn,
         androidAvailabilityFn,
         iosAvailabilityFn,
       );

  final NativeAudioMetadataPlatform _platform;
  final Map<NativeAudioMetadataPlatform, NativeAudioMetadataReadFn> _readOverrides;
  final Map<NativeAudioMetadataPlatform, NativeAudioMetadataAvailabilityFn> _availabilityOverrides;

  Future<bool> isAvailable() async {
    final override = _availabilityOverrides[_platform];
    if (override != null) return override();
    return await _resolveBackend(_platform)?.isAvailable() ?? false;
  }

  Future<AudioMetadata> readAudioMetadata({required String inputPath}) async {
    _ensureSupported();
    if (inputPath.trim().isEmpty) {
      throw ArgumentError.value(inputPath, 'inputPath', 'Must not be empty');
    }

    final override = _readOverrides[_platform];
    final metadata = override != null
        ? override(inputPath)
        : await _resolveBackend(_platform)!.readAudioMetadata(inputPath: inputPath);
    if (metadata.duration < Duration.zero) {
      throw AudioMetadataException(
        'Native audio metadata returned an invalid duration',
        details: 'durationMicros=${metadata.duration.inMicroseconds}',
      );
    }
    return AudioMetadata(
      duration: metadata.duration,
      sampleRateHz: Pcm16AudioUtils.toOptionalPositive(metadata.sampleRateHz),
      channelCount: Pcm16AudioUtils.toOptionalPositive(metadata.channelCount),
      bitrateBps: Pcm16AudioUtils.toOptionalPositive(metadata.bitrateBps),
      containerFormat: Pcm16AudioUtils.toOptionalText(metadata.containerFormat),
      codec: Pcm16AudioUtils.toOptionalText(metadata.codec),
      codecProfile: Pcm16AudioUtils.toOptionalText(metadata.codecProfile),
    );
  }

  Future<Duration> readAudioDuration({required String inputPath}) async =>
      (await readAudioMetadata(inputPath: inputPath)).duration;

  void _ensureSupported() {
    if (_platform == NativeAudioMetadataPlatform.unsupported ||
        (_readOverrides[_platform] == null && _resolveBackend(_platform) == null)) {
      throw const NativeAudioMetadataUnsupportedPlatformException(_unsupportedMessage);
    }
  }
}

NativeAudioMetadataPlatform _detectPlatform() {
  if (Platform.isMacOS) return NativeAudioMetadataPlatform.macOS;
  if (Platform.isWindows) return NativeAudioMetadataPlatform.windows;
  if (Platform.isLinux) return NativeAudioMetadataPlatform.linux;
  if (Platform.isAndroid) return NativeAudioMetadataPlatform.android;
  if (Platform.isIOS) return NativeAudioMetadataPlatform.iOS;
  return NativeAudioMetadataPlatform.unsupported;
}

NativeAudioMetadataBackend? _resolveBackend(NativeAudioMetadataPlatform platform) =>
    switch (platform) {
      NativeAudioMetadataPlatform.macOS => SpeechUtilsMacos().metadataReader,
      NativeAudioMetadataPlatform.windows => SpeechUtilsWindows().metadataReader,
      NativeAudioMetadataPlatform.linux => SpeechUtilsLinux().metadataReader,
      NativeAudioMetadataPlatform.android => const SpeechUtilsAndroid().metadataReader,
      NativeAudioMetadataPlatform.iOS => const SpeechUtilsIos().metadataReader,
      NativeAudioMetadataPlatform.unsupported => null,
    };

Map<NativeAudioMetadataPlatform, NativeAudioMetadataReadFn> _buildReadOverrides(
  NativeAudioMetadataReadFn? macos,
  NativeAudioMetadataReadFn? windows,
  NativeAudioMetadataReadFn? linux,
  NativeAudioMetadataReadFn? android,
  NativeAudioMetadataReadFn? ios,
) {
  final values = <NativeAudioMetadataPlatform, NativeAudioMetadataReadFn>{};
  if (macos != null) values[NativeAudioMetadataPlatform.macOS] = macos;
  if (windows != null) values[NativeAudioMetadataPlatform.windows] = windows;
  if (linux != null) values[NativeAudioMetadataPlatform.linux] = linux;
  if (android != null) values[NativeAudioMetadataPlatform.android] = android;
  if (ios != null) values[NativeAudioMetadataPlatform.iOS] = ios;
  return values;
}

Map<NativeAudioMetadataPlatform, NativeAudioMetadataAvailabilityFn> _buildAvailabilityOverrides(
  NativeAudioMetadataAvailabilityFn? macos,
  NativeAudioMetadataAvailabilityFn? windows,
  NativeAudioMetadataAvailabilityFn? linux,
  NativeAudioMetadataAvailabilityFn? android,
  NativeAudioMetadataAvailabilityFn? ios,
) {
  final values = <NativeAudioMetadataPlatform, NativeAudioMetadataAvailabilityFn>{};
  if (macos != null) values[NativeAudioMetadataPlatform.macOS] = macos;
  if (windows != null) values[NativeAudioMetadataPlatform.windows] = windows;
  if (linux != null) values[NativeAudioMetadataPlatform.linux] = linux;
  if (android != null) values[NativeAudioMetadataPlatform.android] = android;
  if (ios != null) values[NativeAudioMetadataPlatform.iOS] = ios;
  return values;
}
