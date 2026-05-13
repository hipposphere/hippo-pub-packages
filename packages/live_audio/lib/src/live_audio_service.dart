import 'live_audio_session.dart';

abstract interface class LiveAudioService {
  Future<LiveAudioSession> connect();
}
