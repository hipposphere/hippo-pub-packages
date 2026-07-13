part of 'native_audio_encoder.dart';

final _nativeAudioEncoderWorker = NativeWorkerExecutor(
  entrypoint: _nativeAudioEncoderWorkerMain,
  debugName: 'speech_utils audio encoder',
);

bool _supportsEncoderWorker(NativeAudioEncoderPlatform platform) {
  return platform == NativeAudioEncoderPlatform.macOS ||
      platform == NativeAudioEncoderPlatform.windows ||
      platform == NativeAudioEncoderPlatform.linux;
}

final class _NativeAudioEncoderWorkerRequest {
  const _NativeAudioEncoderWorkerRequest({
    required this.platform,
    required this.inputPath,
    required this.outputPath,
    required this.bitrateBps,
  });

  final NativeAudioEncoderPlatform platform;
  final String inputPath;
  final String outputPath;
  final int bitrateBps;
}

@pragma('vm:entry-point')
void _nativeAudioEncoderWorkerMain(SendPort replyPort) {
  runNativeWorker(replyPort, (Object? request) async {
    if (request is! _NativeAudioEncoderWorkerRequest) {
      throw ArgumentError.value(request, 'request', 'Invalid audio encoder worker request');
    }
    final implementation = _resolveNativeAudioEncoderPlatformImplementation(
      platform: request.platform,
      platformImplementation: null,
    );
    implementation.ensureSupported();
    await implementation.encodeAudioFileToAac(
      inputPath: request.inputPath,
      outputPath: request.outputPath,
      bitrateBps: request.bitrateBps,
    );
    return null;
  });
}
