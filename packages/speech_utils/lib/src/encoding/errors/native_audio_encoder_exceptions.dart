part of '../native_audio_encoder.dart';

/// Base exception type for native AAC encoder lifecycle/runtime failures.
class NativeAudioEncoderException implements Exception {
  const NativeAudioEncoderException(this.message, {this.details});

  final String message;
  final String? details;

  @override
  String toString() {
    final parts = <String>[
      message,
      if (details != null && details!.isNotEmpty) 'details=$details',
    ];
    return 'NativeAudioEncoderException: ${parts.join(' | ')}';
  }
}

/// Thrown when the native AAC encoder is used on an unsupported platform.
final class NativeAudioEncoderUnsupportedPlatformException
    extends NativeAudioEncoderException {
  const NativeAudioEncoderUnsupportedPlatformException(super.message);
}
