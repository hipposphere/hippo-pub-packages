#ifndef SPEECH_UTILS_NATIVE_AUDIO_RECORDER_WAV_H_
#define SPEECH_UTILS_NATIVE_AUDIO_RECORDER_WAV_H_

#include <cstdint>
#include <cstdio>

namespace speech_utils::native_recorder {

bool WriteWavHeaderPlaceholder(FILE* file, uint32_t sample_rate_hz, uint32_t channel_count);

bool FinalizeWavHeader(FILE* file, uint32_t data_bytes_written, uint32_t sample_rate_hz,
                       uint32_t channel_count);

}  // namespace speech_utils::native_recorder

#endif  // SPEECH_UTILS_NATIVE_AUDIO_RECORDER_WAV_H_

