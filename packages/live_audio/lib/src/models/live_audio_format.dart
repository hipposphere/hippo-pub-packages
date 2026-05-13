enum LiveAudioFormat { pcm16, pcmu, pcma }

extension LiveAudioFormatMimeType on LiveAudioFormat {
  String get mimeType => switch (this) {
    LiveAudioFormat.pcm16 => 'audio/pcm',
    LiveAudioFormat.pcmu => 'audio/pcmu',
    LiveAudioFormat.pcma => 'audio/pcma',
  };
}

final class LiveAudioInputFormat {
  const LiveAudioInputFormat({
    this.format = LiveAudioFormat.pcm16,
    this.sampleRate = 24000,
    this.channels = 1,
  });

  const LiveAudioInputFormat.pcm16k()
    : format = LiveAudioFormat.pcm16,
      sampleRate = 16000,
      channels = 1;

  const LiveAudioInputFormat.pcm24k()
    : format = LiveAudioFormat.pcm16,
      sampleRate = 24000,
      channels = 1;

  final LiveAudioFormat format;
  final int sampleRate;
  final int channels;

  String get mimeType => '${format.mimeType};rate=$sampleRate';
}
