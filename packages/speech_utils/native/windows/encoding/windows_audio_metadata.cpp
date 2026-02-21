#include "windows_audio_metadata.h"

#include <climits>
#include <cctype>
#include <cstdint>
#include <string>

#include "windows_ffmpeg_common.h"

extern "C" {
#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"
}

namespace speech_utils::windows_encoding {

namespace {

std::string ToLowerAscii(const std::string& value) {
  std::string lower = value;
  for (char& ch : lower) {
    ch = static_cast<char>(std::tolower(static_cast<unsigned char>(ch)));
  }
  return lower;
}

std::string NormalizeAacProfileLabel(const std::string& raw_label) {
  if (raw_label.empty()) {
    return {};
  }

  const std::string lower = ToLowerAscii(raw_label);
  if (lower.find("hev2") != std::string::npos || lower.find("hev-2") != std::string::npos ||
      lower.find("he-aacv2") != std::string::npos || lower.find("he-aac v2") != std::string::npos) {
    return "hev2";
  }
  if (lower.find("eld") != std::string::npos) {
    return "eld";
  }
  if (lower.find("he") != std::string::npos || lower.find("sbr") != std::string::npos) {
    return "he";
  }
  if (lower.find("lc") != std::string::npos || lower.find("low") != std::string::npos) {
    return "lc";
  }
  if (lower.find("main") != std::string::npos) {
    return "main";
  }
  if (lower.find("ld") != std::string::npos) {
    return "ld";
  }
  if (lower.find("ltp") != std::string::npos) {
    return "ltp";
  }
  if (lower.find("ssr") != std::string::npos) {
    return "ssr";
  }
  return lower;
}

std::string ResolveProfileFromFfmpegProfileEnum(const AVCodecParameters* codec_parameters) {
  if (codec_parameters == nullptr || codec_parameters->profile == AV_PROFILE_UNKNOWN) {
    return {};
  }

  if (codec_parameters->codec_id == AV_CODEC_ID_AAC) {
    switch (codec_parameters->profile) {
      case AV_PROFILE_AAC_MAIN:
        return "main";
      case AV_PROFILE_AAC_LOW:
        return "lc";
      case AV_PROFILE_AAC_SSR:
        return "ssr";
      case AV_PROFILE_AAC_LTP:
        return "ltp";
      case AV_PROFILE_AAC_HE:
        return "he";
      case AV_PROFILE_AAC_HE_V2:
        return "hev2";
      case AV_PROFILE_AAC_LD:
        return "ld";
      case AV_PROFILE_AAC_ELD:
        return "eld";
      default:
        break;
    }
  }

  const char* profile_name =
      avcodec_profile_name(codec_parameters->codec_id, codec_parameters->profile);
  if (profile_name == nullptr) {
    return {};
  }
  return codec_parameters->codec_id == AV_CODEC_ID_AAC ? NormalizeAacProfileLabel(profile_name)
                                                        : std::string(profile_name);
}

bool ReadBits(const uint8_t* bytes, std::size_t byte_count, std::size_t* bit_offset, int bit_count,
              uint32_t* out_value) {
  if (bytes == nullptr || bit_offset == nullptr || out_value == nullptr || bit_count <= 0) {
    return false;
  }

  const std::size_t total_bits = byte_count * 8;
  if (*bit_offset + static_cast<std::size_t>(bit_count) > total_bits) {
    return false;
  }

  uint32_t value = 0;
  for (int i = 0; i < bit_count; i++) {
    const std::size_t absolute_bit_index = *bit_offset + static_cast<std::size_t>(i);
    const std::size_t byte_index = absolute_bit_index / 8;
    const std::size_t bit_index_in_byte = 7 - (absolute_bit_index % 8);
    const uint32_t bit = (bytes[byte_index] >> bit_index_in_byte) & 0x01;
    value = (value << 1) | bit;
  }

  *bit_offset += static_cast<std::size_t>(bit_count);
  *out_value = value;
  return true;
}

int ParseAacAudioObjectTypeFromAsc(const AVCodecParameters* codec_parameters) {
  if (codec_parameters == nullptr || codec_parameters->extradata == nullptr ||
      codec_parameters->extradata_size <= 0) {
    return -1;
  }

  const auto* bytes = reinterpret_cast<const uint8_t*>(codec_parameters->extradata);
  const auto byte_count = static_cast<std::size_t>(codec_parameters->extradata_size);

  std::size_t bit_offset = 0;
  uint32_t audio_object_type = 0;
  if (!ReadBits(bytes, byte_count, &bit_offset, 5, &audio_object_type)) {
    return -1;
  }

  if (audio_object_type == 31) {
    uint32_t extension = 0;
    if (!ReadBits(bytes, byte_count, &bit_offset, 6, &extension)) {
      return -1;
    }
    audio_object_type = 32 + extension;
  }

  return static_cast<int>(audio_object_type);
}

std::string ResolveAacProfileFromAsc(const AVCodecParameters* codec_parameters) {
  if (codec_parameters == nullptr || codec_parameters->codec_id != AV_CODEC_ID_AAC) {
    return {};
  }

  switch (ParseAacAudioObjectTypeFromAsc(codec_parameters)) {
    case 1:
      return "main";
    case 2:
      return "lc";
    case 3:
      return "ssr";
    case 4:
      return "ltp";
    case 5:
      return "he";
    case 23:
      return "ld";
    case 29:
      return "hev2";
    case 39:
      return "eld";
    default:
      return {};
  }
}

std::string ResolveCodecProfile(const AVStream* audio_stream,
                                const AVCodecParameters* codec_parameters) {
  if (codec_parameters == nullptr) {
    return {};
  }

  std::string profile = ResolveProfileFromFfmpegProfileEnum(codec_parameters);
  if (!profile.empty()) {
    return profile;
  }

  if (audio_stream != nullptr && audio_stream->metadata != nullptr) {
    const AVDictionaryEntry* profile_entry =
        av_dict_get(audio_stream->metadata, "profile", nullptr, AV_DICT_MATCH_CASE);
    if (profile_entry != nullptr && profile_entry->value != nullptr && profile_entry->value[0] != '\0') {
      profile = codec_parameters->codec_id == AV_CODEC_ID_AAC
                    ? NormalizeAacProfileLabel(profile_entry->value)
                    : std::string(profile_entry->value);
    }
  }
  if (!profile.empty()) {
    return profile;
  }

  if (codec_parameters->codec_id == AV_CODEC_ID_AAC) {
    profile = ResolveAacProfileFromAsc(codec_parameters);
  }
  return profile;
}

}  // namespace

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
  std::string profile = ResolveCodecProfile(audio_stream, codec_parameters);

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
