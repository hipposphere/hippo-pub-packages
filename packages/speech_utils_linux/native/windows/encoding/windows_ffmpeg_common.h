#ifndef SPEECH_UTILS_WINDOWS_FFMPEG_COMMON_H_
#define SPEECH_UTILS_WINDOWS_FFMPEG_COMMON_H_

#include <cstdint>
#include <string>

extern "C" {
#include "libavformat/avformat.h"
}

namespace speech_utils::windows_encoding {

void WriteError(const std::string& message, char* out_error_utf8, uint32_t out_error_capacity);

void WriteOutputText(const std::string& value, char* out_utf8, uint32_t out_capacity);

std::string AvErrorToString(int code);

std::string FirstCommaSeparatedToken(const char* text);

int64_t ResolveDurationMicros(AVFormatContext* format_context, AVStream* audio_stream);

}  // namespace speech_utils::windows_encoding

#endif  // SPEECH_UTILS_WINDOWS_FFMPEG_COMMON_H_
