#include "speech_utils_apple_aac_codec.h"

#if defined(SPEECH_UTILS_APPLE_AAC_TARGET_IOS)
#define SPEECH_UTILS_APPLE_AAC_SYMBOL(name) speech_utils_ios_##name
#define SPEECH_UTILS_APPLE_AAC_PLATFORM_NAME "iOS"
#elif defined(SPEECH_UTILS_APPLE_AAC_TARGET_MACOS)
#define SPEECH_UTILS_APPLE_AAC_SYMBOL(name) speech_utils_macos_##name
#define SPEECH_UTILS_APPLE_AAC_PLATFORM_NAME "macOS"
#else
#error "Define SPEECH_UTILS_APPLE_AAC_TARGET_IOS or SPEECH_UTILS_APPLE_AAC_TARGET_MACOS"
#endif

using namespace speech_utils::apple_aac;

extern "C" __attribute__((visibility("default"))) int32_t
SPEECH_UTILS_APPLE_AAC_SYMBOL(encode_audio_file_to_aac)(
    const char* input_path_utf8, const char* output_path_utf8, uint32_t bitrate_bps,
    char* error_utf8, uint32_t error_utf8_capacity) {
  return EncodeAudioFileToAac(input_path_utf8, output_path_utf8, bitrate_bps, true,
                              SPEECH_UTILS_APPLE_AAC_PLATFORM_NAME, error_utf8,
                              error_utf8_capacity);
}

extern "C" __attribute__((visibility("default"))) int32_t
SPEECH_UTILS_APPLE_AAC_SYMBOL(read_audio_metadata)(
    const char* input_path_utf8, int64_t* out_duration_micros, int32_t* out_sample_rate_hz,
    int32_t* out_channel_count, int32_t* out_bitrate_bps, char* out_container_format_utf8,
    uint32_t out_container_format_utf8_capacity, char* out_codec_utf8,
    uint32_t out_codec_utf8_capacity, char* out_codec_profile_utf8,
    uint32_t out_codec_profile_utf8_capacity, char* error_utf8, uint32_t error_utf8_capacity) {
  return ReadAudioMetadata(input_path_utf8, out_duration_micros, out_sample_rate_hz, out_channel_count,
                          out_bitrate_bps, out_container_format_utf8,
                          out_container_format_utf8_capacity, out_codec_utf8, out_codec_utf8_capacity,
                          out_codec_profile_utf8, out_codec_profile_utf8_capacity, error_utf8,
                          error_utf8_capacity);
}
