#import "speech_utils_apple_audio_recorder_wav.h"

#include <cstring>

namespace speech_utils::apple_recorder {

struct WavHeader {
  char riff[4];
  uint32_t chunk_size;
  char wave[4];
  char fmt[4];
  uint32_t subchunk1_size;
  uint16_t audio_format;
  uint16_t channel_count;
  uint32_t sample_rate;
  uint32_t byte_rate;
  uint16_t block_align;
  uint16_t bits_per_sample;
  char data[4];
  uint32_t data_size;
};

bool WriteInitialWavHeader(FILE* file, uint32_t sample_rate_hz, uint32_t channel_count) {
  if (file == nullptr) {
    return false;
  }

  WavHeader header{};
  std::memcpy(header.riff, "RIFF", 4);
  header.chunk_size = 36;
  std::memcpy(header.wave, "WAVE", 4);
  std::memcpy(header.fmt, "fmt ", 4);
  header.subchunk1_size = 16;
  header.audio_format = 1;
  header.channel_count = static_cast<uint16_t>(channel_count);
  header.sample_rate = sample_rate_hz;
  header.bits_per_sample = 16;
  header.block_align = static_cast<uint16_t>(header.channel_count * (header.bits_per_sample / 8));
  header.byte_rate = header.sample_rate * header.block_align;
  std::memcpy(header.data, "data", 4);
  header.data_size = 0;

  return std::fwrite(&header, sizeof(header), 1, file) == 1;
}

bool FinalizeWavHeader(FILE* file, uint32_t data_bytes_written, uint32_t sample_rate_hz,
                       uint32_t channel_count) {
  if (file == nullptr) {
    return false;
  }

  WavHeader header{};
  std::memcpy(header.riff, "RIFF", 4);
  std::memcpy(header.wave, "WAVE", 4);
  std::memcpy(header.fmt, "fmt ", 4);
  std::memcpy(header.data, "data", 4);
  header.subchunk1_size = 16;
  header.audio_format = 1;
  header.channel_count = static_cast<uint16_t>(channel_count);
  header.sample_rate = sample_rate_hz;
  header.bits_per_sample = 16;
  header.block_align = static_cast<uint16_t>(header.channel_count * (header.bits_per_sample / 8));
  header.byte_rate = header.sample_rate * header.block_align;
  header.data_size = data_bytes_written;
  header.chunk_size = 36 + data_bytes_written;

  if (std::fseek(file, 0, SEEK_SET) != 0) {
    return false;
  }
  if (std::fwrite(&header, sizeof(header), 1, file) != 1) {
    return false;
  }
  return true;
}

}  // namespace speech_utils::apple_recorder
