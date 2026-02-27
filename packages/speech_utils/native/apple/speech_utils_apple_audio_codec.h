#ifndef SPEECH_UTILS_APPLE_AUDIO_CODEC_H_
#define SPEECH_UTILS_APPLE_AUDIO_CODEC_H_

#include <cstdint>

namespace speech_utils::apple_audio_codec {

int32_t EncodeAudioFileToAac(const char* input_path_utf8, const char* output_path_utf8,
                             uint32_t bitrate_bps, bool use_source_format_hint,
                             const char* platform_name, char* error_utf8,
                             uint32_t error_utf8_capacity);

int32_t ReadAudioMetadata(const char* input_path_utf8, int64_t* out_duration_micros,
                          int32_t* out_sample_rate_hz, int32_t* out_channel_count,
                          int32_t* out_bitrate_bps, char* out_container_format_utf8,
                          uint32_t out_container_format_utf8_capacity, char* out_codec_utf8,
                          uint32_t out_codec_utf8_capacity, char* out_codec_profile_utf8,
                          uint32_t out_codec_profile_utf8_capacity, char* error_utf8,
                          uint32_t error_utf8_capacity);

}  // namespace speech_utils::apple_audio_codec

#endif  // SPEECH_UTILS_APPLE_AUDIO_CODEC_H_
