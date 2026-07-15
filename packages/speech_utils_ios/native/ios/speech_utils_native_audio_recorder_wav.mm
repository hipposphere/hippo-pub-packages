#import "speech_utils_native_audio_recorder_wav.h"

#include <cstdint>
#include <cstring>

namespace speech_utils::native_recorder {

namespace {

struct WavHeader {
  char riff[4];
  uint32_t chunk_size;
  char wave[4];
  char fmt[4];
  uint32_t fmt_chunk_size;
  uint16_t audio_format;
  uint16_t channels;
  uint32_t sample_rate;
  uint32_t byte_rate;
  uint16_t block_align;
  uint16_t bits_per_sample;
  char data[4];
  uint32_t data_size;
};

WavHeader BuildWavHeader(uint32_t data_bytes, uint32_t sample_rate_hz, uint32_t channel_count) {
  WavHeader header{};
  std::memcpy(header.riff, "RIFF", 4);
  std::memcpy(header.wave, "WAVE", 4);
  std::memcpy(header.fmt, "fmt ", 4);
  std::memcpy(header.data, "data", 4);
  header.chunk_size = 36u + data_bytes;
  header.fmt_chunk_size = 16u;
  header.audio_format = 1u;
  header.channels = static_cast<uint16_t>(channel_count);
  header.sample_rate = sample_rate_hz;
  header.bits_per_sample = 16u;
  header.block_align = static_cast<uint16_t>(header.channels * (header.bits_per_sample / 8u));
  header.byte_rate = header.sample_rate * static_cast<uint32_t>(header.block_align);
  header.data_size = data_bytes;
  return header;
}

}  // namespace

bool WriteWavHeaderPlaceholder(FILE* file, uint32_t sample_rate_hz, uint32_t channel_count) {
  if (file == nullptr || sample_rate_hz == 0 || channel_count == 0) {
    return false;
  }

  const WavHeader placeholder = BuildWavHeader(0u, sample_rate_hz, channel_count);
  return std::fwrite(&placeholder, sizeof(placeholder), 1, file) == 1;
}

bool FinalizeWavHeader(FILE* file, uint32_t data_bytes_written, uint32_t sample_rate_hz,
                       uint32_t channel_count) {
  if (file == nullptr || sample_rate_hz == 0 || channel_count == 0) {
    return false;
  }

  if (std::fseek(file, 0, SEEK_SET) != 0) {
    return false;
  }

  const WavHeader header = BuildWavHeader(data_bytes_written, sample_rate_hz, channel_count);
  return std::fwrite(&header, sizeof(header), 1, file) == 1;
}

}  // namespace speech_utils::native_recorder

