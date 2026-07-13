part of 'native_audio_metadata_reader.dart';

final _nativeAudioMetadataWorker = NativeWorkerExecutor(
  entrypoint: _nativeAudioMetadataWorkerMain,
  debugName: 'speech_utils audio metadata',
);

bool _supportsMetadataWorker(NativeAudioMetadataPlatform platform) {
  return platform == NativeAudioMetadataPlatform.macOS ||
      platform == NativeAudioMetadataPlatform.windows ||
      platform == NativeAudioMetadataPlatform.linux;
}

final class _NativeAudioMetadataWorkerRequest {
  const _NativeAudioMetadataWorkerRequest({required this.platform, required this.inputPath});

  final NativeAudioMetadataPlatform platform;
  final String inputPath;
}

@pragma('vm:entry-point')
void _nativeAudioMetadataWorkerMain(SendPort replyPort) {
  runNativeWorker(replyPort, (Object? request) {
    if (request is! _NativeAudioMetadataWorkerRequest) {
      throw ArgumentError.value(request, 'request', 'Invalid audio metadata worker request');
    }
    return switch (request.platform) {
      NativeAudioMetadataPlatform.macOS => _readAudioMetadataViaMacosFfi(request.inputPath),
      NativeAudioMetadataPlatform.windows => _readAudioMetadataViaWindowsFfi(request.inputPath),
      NativeAudioMetadataPlatform.linux => _readAudioMetadataViaLinuxFfi(request.inputPath),
      NativeAudioMetadataPlatform.android ||
      NativeAudioMetadataPlatform.iOS ||
      NativeAudioMetadataPlatform.unsupported =>
        throw const NativeAudioMetadataUnsupportedPlatformException(
          _unsupportedNativeAudioMetadataReaderMessage,
        ),
    };
  });
}
