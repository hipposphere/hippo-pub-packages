#include "windows_audio_metadata.h"

#include <climits>
#include <cstdint>
#include <string>

#include "windows_ffmpeg_common.h"

extern "C" {
#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"
}

namespace speech_utils::windows_encoding {

int32_t ReadAudioMetadata(const char* input_path_utf8, int64_t* out_duration_micros,
                          int32_t* out_sample_rate_hz, int32_t* out_channel_count,
                          int32_t* out_bitrate_bps, char* out_container_format_utf8,
                          uint32_t out_container_format_utf8_capacity, char* out_codec_utf8,
                          uint32_t out_codec_utf8_capacity, char* out_codec_profile_utf8,
                          uint32_t out_codec_profile_utf8_capacity, char* error_utf8,
                          uint32_t error_utf8_capacity) {
  if (input_path_utf8 == nullptr || input_path_utf8[0] == '\0') {
    WriteError("Input path is null or empty.", error_utf8, error_utf8_capacity);
    return -1;
  }
  if (out_duration_micros == nullptr || out_sample_rate_hz == nullptr ||
      out_channel_count == nullptr || out_bitrate_bps == nullptr) {
    WriteError("Metadata output pointers must not be null.", error_utf8, error_utf8_capacity);
    return -2;
  }

  *out_duration_micros = 0;
  *out_sample_rate_hz = 0;
  *out_channel_count = 0;
  *out_bitrate_bps = 0;
  WriteOutputText("", out_container_format_utf8, out_container_format_utf8_capacity);
  WriteOutputText("", out_codec_utf8, out_codec_utf8_capacity);
  WriteOutputText("", out_codec_profile_utf8, out_codec_profile_utf8_capacity);

  AVFormatContext* format_context = nullptr;
  int ffmpeg_code = avformat_open_input(&format_context, input_path_utf8, nullptr, nullptr);
  if (ffmpeg_code < 0) {
    WriteError("Failed to open input file: " + AvErrorToString(ffmpeg_code), error_utf8,
               error_utf8_capacity);
    return -10;
  }

  ffmpeg_code = avformat_find_stream_info(format_context, nullptr);
  if (ffmpeg_code < 0) {
    avformat_close_input(&format_context);
    WriteError("Failed to read input stream info: " + AvErrorToString(ffmpeg_code), error_utf8,
               error_utf8_capacity);
    return -11;
  }

  ffmpeg_code = av_find_best_stream(format_context, AVMEDIA_TYPE_AUDIO, -1, -1, nullptr, 0);
  if (ffmpeg_code < 0) {
    avformat_close_input(&format_context);
    WriteError("No audio stream found in input file.", error_utf8, error_utf8_capacity);
    return -12;
  }

  AVStream* audio_stream = format_context->streams[ffmpeg_code];
  const AVCodecParameters* codec_parameters = audio_stream->codecpar;

  int64_t duration_micros = ResolveDurationMicros(format_context, audio_stream);
  if (duration_micros < 0) {
    duration_micros = 0;
  }

  *out_duration_micros = duration_micros;
  *out_sample_rate_hz = static_cast<int32_t>(codec_parameters->sample_rate);
  *out_channel_count = static_cast<int32_t>(codec_parameters->ch_layout.nb_channels);

  const int64_t bitrate =
      codec_parameters->bit_rate > 0 ? codec_parameters->bit_rate : format_context->bit_rate;
  if (bitrate > 0 && bitrate <= INT32_MAX) {
    *out_bitrate_bps = static_cast<int32_t>(bitrate);
  }

  std::string container = format_context->iformat != nullptr
                              ? FirstCommaSeparatedToken(format_context->iformat->name)
                              : std::string();
  std::string codec = avcodec_get_name(codec_parameters->codec_id);
  std::string profile;
  if (codec_parameters->profile != AV_PROFILE_UNKNOWN) {
    const char* profile_name =
        avcodec_profile_name(codec_parameters->codec_id, codec_parameters->profile);
    if (profile_name != nullptr) {
      profile = profile_name;
    }
  }

  WriteOutputText(container, out_container_format_utf8, out_container_format_utf8_capacity);
  WriteOutputText(codec, out_codec_utf8, out_codec_utf8_capacity);
  WriteOutputText(profile, out_codec_profile_utf8, out_codec_profile_utf8_capacity);

  avformat_close_input(&format_context);
  return 0;
}

int32_t AudioMetadataHealthcheck(char* error_utf8, uint32_t error_utf8_capacity) {
  if (avformat_version() == 0 || avcodec_version() == 0) {
    WriteError("FFmpeg metadata APIs are unavailable.", error_utf8, error_utf8_capacity);
    return -1;
  }

  return 0;
}

}  // namespace speech_utils::windows_encoding
