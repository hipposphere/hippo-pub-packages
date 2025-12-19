import 'package:audioplayers/audioplayers.dart' as audioplayers;
import 'package:hippo_utils/cross_file.dart';

class MediaDataReader {
  static Future<Duration> getMediaDurationFromXFile(XFile file) async {
    final player = audioplayers.AudioPlayer();
    await player.setSource(
      audioplayers.BytesSource(
        await file.readAsBytes(),
        mimeType: file.mimeType,
      ),
    );
    final duration = await player.getDuration();
    await player.dispose();
    return duration!;
  }
}
