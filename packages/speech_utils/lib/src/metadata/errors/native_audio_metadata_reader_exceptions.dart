part of '../native_audio_metadata_reader.dart';

/// Base exception type for native metadata-reader lifecycle/runtime failures.
class NativeAudioMetadataReaderException implements Exception {
  const NativeAudioMetadataReaderException(this.message, {this.details});

  final String message;
  final String? details;

  @override
  String toString() {
    final parts = <String>[
      message,
      if (details != null && details!.isNotEmpty) 'details=$details',
    ];
    return 'NativeAudioMetadataReaderException: ${parts.join(' | ')}';
  }
}

/// Thrown when native metadata reading is requested on an unsupported platform.
final class NativeAudioMetadataUnsupportedPlatformException
    extends NativeAudioMetadataReaderException {
  const NativeAudioMetadataUnsupportedPlatformException(super.message);
}

/// Native metadata decode/read failure reported by FFI bridge code.
final class AudioMetadataException extends NativeAudioMetadataReaderException {
  const AudioMetadataException(super.message, {this.errorCode, super.details});

  final int? errorCode;

  @override
  String toString() {
    final parts = <String>[
      message,
      if (errorCode != null) 'errorCode=$errorCode',
      if (details != null && details!.isNotEmpty) 'details=$details',
    ];
    return 'AudioMetadataException: ${parts.join(' | ')}';
  }
}
