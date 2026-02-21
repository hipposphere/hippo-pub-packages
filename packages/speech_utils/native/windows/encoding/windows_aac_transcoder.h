#ifndef SPEECH_UTILS_WINDOWS_AAC_TRANSCODER_H_
#define SPEECH_UTILS_WINDOWS_AAC_TRANSCODER_H_

#include <cstdint>

namespace speech_utils::windows_encoding {

int32_t EncodeAudioFileToAac(const char* input_path_utf8, const char* output_path_utf8,
                             uint32_t bitrate_bps, char* error_utf8,
                             uint32_t error_utf8_capacity);

int32_t AacEncoderHealthcheck(char* error_utf8, uint32_t error_utf8_capacity);

}  // namespace speech_utils::windows_encoding

#endif  // SPEECH_UTILS_WINDOWS_AAC_TRANSCODER_H_
