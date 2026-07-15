#include "speech_utils_native_audio_codec.h"

namespace {
constexpr const char* kPlatformName = "macOS";
}  // namespace

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_macos_encode_audio_file_to_aac(
    const char* input_path_utf8,
    const char* output_path_utf8,
    uint32_t bitrate_bps,
    char* error_utf8,
    uint32_t error_utf8_capacity) {
  return speech_utils::apple_audio_codec::EncodeAudioFileToAac(
      input_path_utf8,
      output_path_utf8,
      bitrate_bps,
      true,
      kPlatformName,
      error_utf8,
      error_utf8_capacity);
}

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_macos_read_audio_metadata(
    const char* input_path_utf8,
    int64_t* out_duration_micros,
    int32_t* out_sample_rate_hz,
    int32_t* out_channel_count,
    int32_t* out_bitrate_bps,
    char* out_container_format_utf8,
    uint32_t out_container_format_utf8_capacity,
    char* out_codec_utf8,
    uint32_t out_codec_utf8_capacity,
    char* out_codec_profile_utf8,
    uint32_t out_codec_profile_utf8_capacity,
    char* error_utf8,
    uint32_t error_utf8_capacity) {
  return speech_utils::apple_audio_codec::ReadAudioMetadata(
      input_path_utf8,
      out_duration_micros,
      out_sample_rate_hz,
      out_channel_count,
      out_bitrate_bps,
      out_container_format_utf8,
      out_container_format_utf8_capacity,
      out_codec_utf8,
      out_codec_utf8_capacity,
      out_codec_profile_utf8,
      out_codec_profile_utf8_capacity,
      error_utf8,
      error_utf8_capacity);
}
