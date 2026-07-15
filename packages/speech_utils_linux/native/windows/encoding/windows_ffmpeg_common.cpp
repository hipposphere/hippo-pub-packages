#include "windows_ffmpeg_common.h"

#include <algorithm>
#include <cstring>

extern "C" {
#include "libavutil/error.h"
#include "libavutil/mathematics.h"
}

namespace speech_utils::windows_encoding {

void WriteError(const std::string& message, char* out_error_utf8, uint32_t out_error_capacity) {
  if (out_error_utf8 == nullptr || out_error_capacity == 0) {
    return;
  }

  const auto copy_length = static_cast<uint32_t>(
      std::min<std::size_t>(message.size(), static_cast<std::size_t>(out_error_capacity - 1)));
  std::memcpy(out_error_utf8, message.data(), copy_length);
  out_error_utf8[copy_length] = '\0';
}

void WriteOutputText(const std::string& value, char* out_utf8, uint32_t out_capacity) {
  if (out_utf8 == nullptr || out_capacity == 0) {
    return;
  }

  const auto copy_length = static_cast<uint32_t>(
      std::min<std::size_t>(value.size(), static_cast<std::size_t>(out_capacity - 1)));
  std::memcpy(out_utf8, value.data(), copy_length);
  out_utf8[copy_length] = '\0';
}

std::string AvErrorToString(int code) {
  char buffer[AV_ERROR_MAX_STRING_SIZE] = {0};
  if (av_strerror(code, buffer, sizeof(buffer)) < 0) {
    return "unknown ffmpeg error";
  }
  return std::string(buffer);
}

std::string FirstCommaSeparatedToken(const char* text) {
  if (text == nullptr || text[0] == '\0') {
    return {};
  }

  const char* end = text;
  while (*end != '\0' && *end != ',') {
    end++;
  }
  return std::string(text, static_cast<std::size_t>(end - text));
}

int64_t ResolveDurationMicros(AVFormatContext* format_context, AVStream* audio_stream) {
  if (audio_stream != nullptr && audio_stream->duration != AV_NOPTS_VALUE) {
    return av_rescale_q(audio_stream->duration, audio_stream->time_base, AV_TIME_BASE_Q);
  }
  if (format_context != nullptr && format_context->duration != AV_NOPTS_VALUE) {
    return format_context->duration;
  }
  return 0;
}

}  // namespace speech_utils::windows_encoding
