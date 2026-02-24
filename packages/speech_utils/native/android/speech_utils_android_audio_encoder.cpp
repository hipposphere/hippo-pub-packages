#include <media/NdkMediaCodec.h>
#include <media/NdkMediaExtractor.h>
#include <media/NdkMediaFormat.h>
#include <media/NdkMediaMuxer.h>

#include <algorithm>
#include <cctype>
#include <cstdint>
#include <cstring>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

namespace {
constexpr const char* kAacMimeType = "audio/mp4a-latm";
constexpr int64_t kCodecTimeoutUs = 10000;

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

std::string AsciiLower(std::string value) {
  std::transform(value.begin(), value.end(), value.begin(),
                 [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
  return value;
}

std::string ExtractContainerFormatFromPath(const char* input_path_utf8) {
  if (input_path_utf8 == nullptr) {
    return {};
  }

  const std::string path(input_path_utf8);
  const auto dot_index = path.find_last_of('.');
  if (dot_index == std::string::npos || dot_index + 1 >= path.size()) {
    return {};
  }
  return AsciiLower(path.substr(dot_index + 1));
}

std::string AacProfileName(int32_t profile) {
  switch (profile) {
    case 1:
      return "AAC-Main";
    case 2:
      return "AAC-LC";
    case 3:
      return "AAC-SSR";
    case 4:
      return "AAC-LTP";
    case 5:
      return "HE-AAC";
    case 6:
      return "Scalable-AAC";
    case 17:
      return "ER-AAC-LC";
    case 23:
      return "AAC-LD";
    case 29:
      return "HE-AACv2";
    case 39:
      return "AAC-ELD";
    default: {
      std::ostringstream ss;
      ss << "AAC-profile-" << profile;
      return ss.str();
    }
  }
}

uint16_t ReadLe16(const uint8_t* p) {
  return static_cast<uint16_t>(p[0] | (static_cast<uint16_t>(p[1]) << 8));
}

uint32_t ReadLe32(const uint8_t* p) {
  return static_cast<uint32_t>(p[0] | (static_cast<uint32_t>(p[1]) << 8) |
                               (static_cast<uint32_t>(p[2]) << 16) |
                               (static_cast<uint32_t>(p[3]) << 24));
}

struct WavPcmData {
  uint32_t sample_rate = 0;
  uint16_t channels = 0;
  uint16_t bits_per_sample = 0;
  std::vector<uint8_t> pcm;
};

bool ParsePcm16Wav(const char* input_path_utf8, WavPcmData* out, std::string* error) {
  if (input_path_utf8 == nullptr || out == nullptr) {
    if (error != nullptr) {
      *error = "Invalid arguments for ParsePcm16Wav.";
    }
    return false;
  }

  std::ifstream file(input_path_utf8, std::ios::binary);
  if (!file) {
    if (error != nullptr) {
      *error = std::string("Failed to open WAV input file: ") + input_path_utf8;
    }
    return false;
  }

  std::vector<uint8_t> bytes((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
  if (bytes.size() < 44) {
    if (error != nullptr) {
      *error = "WAV input is too small.";
    }
    return false;
  }

  if (std::memcmp(bytes.data(), "RIFF", 4) != 0 || std::memcmp(bytes.data() + 8, "WAVE", 4) != 0) {
    if (error != nullptr) {
      *error = "Input is not a RIFF/WAVE file.";
    }
    return false;
  }

  bool found_fmt = false;
  bool found_data = false;
  uint32_t data_offset = 0;
  uint32_t data_size = 0;
  uint16_t audio_format = 0;
  uint16_t channels = 0;
  uint32_t sample_rate = 0;
  uint16_t bits_per_sample = 0;

  std::size_t offset = 12;
  while (offset + 8 <= bytes.size()) {
    const uint8_t* chunk = bytes.data() + offset;
    const char* chunk_id = reinterpret_cast<const char*>(chunk);
    const uint32_t chunk_size = ReadLe32(chunk + 4);
    const std::size_t chunk_data_offset = offset + 8;
    const std::size_t chunk_data_end = chunk_data_offset + chunk_size;
    if (chunk_data_end > bytes.size()) {
      if (error != nullptr) {
        *error = "Corrupted WAV chunk (size exceeds file length).";
      }
      return false;
    }

    if (std::memcmp(chunk_id, "fmt ", 4) == 0) {
      if (chunk_size < 16) {
        if (error != nullptr) {
          *error = "WAV fmt chunk is too small.";
        }
        return false;
      }
      const uint8_t* fmt = bytes.data() + chunk_data_offset;
      audio_format = ReadLe16(fmt + 0);
      channels = ReadLe16(fmt + 2);
      sample_rate = ReadLe32(fmt + 4);
      bits_per_sample = ReadLe16(fmt + 14);
      found_fmt = true;
    } else if (std::memcmp(chunk_id, "data", 4) == 0) {
      data_offset = static_cast<uint32_t>(chunk_data_offset);
      data_size = chunk_size;
      found_data = true;
    }

    offset = chunk_data_end + (chunk_size & 1u);
  }

  if (!found_fmt || !found_data) {
    if (error != nullptr) {
      *error = "WAV file is missing fmt or data chunk.";
    }
    return false;
  }
  if (audio_format != 1) {
    if (error != nullptr) {
      *error = "Only PCM WAV (audioFormat=1) is supported on Android native encoder.";
    }
    return false;
  }
  if (channels == 0 || sample_rate == 0) {
    if (error != nullptr) {
      *error = "Invalid WAV channel count or sample rate.";
    }
    return false;
  }
  if (bits_per_sample != 16) {
    if (error != nullptr) {
      *error = "Only 16-bit PCM WAV is supported on Android native encoder.";
    }
    return false;
  }
  if (data_size == 0) {
    if (error != nullptr) {
      *error = "WAV data chunk is empty.";
    }
    return false;
  }
  if ((data_size % 2) != 0) {
    if (error != nullptr) {
      *error = "WAV PCM data length must be even for PCM16.";
    }
    return false;
  }

  out->sample_rate = sample_rate;
  out->channels = channels;
  out->bits_per_sample = bits_per_sample;
  out->pcm.assign(bytes.begin() + data_offset, bytes.begin() + data_offset + data_size);
  return true;
}

int32_t EncodePcm16WavToAacM4a(const WavPcmData& wav, const char* output_path_utf8,
                               uint32_t bitrate_bps, std::string* error) {
  if (output_path_utf8 == nullptr || bitrate_bps == 0 || wav.pcm.empty()) {
    if (error != nullptr) {
      *error = "Invalid arguments for EncodePcm16WavToAacM4a.";
    }
    return -1;
  }

  AMediaCodec* codec = nullptr;
  AMediaFormat* format = nullptr;
  AMediaMuxer* muxer = nullptr;
  bool codec_started = false;
  bool muxer_started = false;
  int32_t track_index = -1;
  int32_t result_code = 0;

  codec = AMediaCodec_createEncoderByType(kAacMimeType);
  if (codec == nullptr) {
    if (error != nullptr) {
      *error = "Failed to create AAC encoder codec.";
    }
    result_code = -2;
    goto cleanup;
  }

  format = AMediaFormat_new();
  if (format == nullptr) {
    if (error != nullptr) {
      *error = "Failed to create media format.";
    }
    result_code = -3;
    goto cleanup;
  }

  AMediaFormat_setString(format, AMEDIAFORMAT_KEY_MIME, kAacMimeType);
  AMediaFormat_setInt32(format, AMEDIAFORMAT_KEY_SAMPLE_RATE, static_cast<int32_t>(wav.sample_rate));
  AMediaFormat_setInt32(format, AMEDIAFORMAT_KEY_CHANNEL_COUNT, static_cast<int32_t>(wav.channels));
  AMediaFormat_setInt32(format, AMEDIAFORMAT_KEY_BIT_RATE, static_cast<int32_t>(bitrate_bps));
  AMediaFormat_setInt32(format, AMEDIAFORMAT_KEY_AAC_PROFILE, 2);  // AAC LC.
  AMediaFormat_setInt32(format, AMEDIAFORMAT_KEY_MAX_INPUT_SIZE, 16384);

  media_status_t status =
      AMediaCodec_configure(codec, format, nullptr, nullptr, AMEDIACODEC_CONFIGURE_FLAG_ENCODE);
  if (status != AMEDIA_OK) {
    if (error != nullptr) {
      std::ostringstream ss;
      ss << "AMediaCodec_configure failed: status=" << status;
      *error = ss.str();
    }
    result_code = static_cast<int32_t>(status);
    goto cleanup;
  }

  status = AMediaCodec_start(codec);
  if (status != AMEDIA_OK) {
    if (error != nullptr) {
      std::ostringstream ss;
      ss << "AMediaCodec_start failed: status=" << status;
      *error = ss.str();
    }
    result_code = static_cast<int32_t>(status);
    goto cleanup;
  }
  codec_started = true;

  muxer = AMediaMuxer_new(output_path_utf8, AMEDIAMUXER_OUTPUT_FORMAT_MPEG_4);
  if (muxer == nullptr) {
    if (error != nullptr) {
      *error = "Failed to create AMediaMuxer.";
    }
    result_code = -4;
    goto cleanup;
  }

  const int32_t bytes_per_frame = static_cast<int32_t>((wav.bits_per_sample / 8) * wav.channels);
  if (bytes_per_frame <= 0) {
    if (error != nullptr) {
      *error = "Invalid bytes-per-frame computed from WAV metadata.";
    }
    result_code = -5;
    goto cleanup;
  }

  std::size_t consumed = 0;
  int64_t frames_submitted = 0;
  bool input_eos = false;
  bool output_eos = false;

  while (!output_eos) {
    if (!input_eos) {
      const ssize_t input_index = AMediaCodec_dequeueInputBuffer(codec, kCodecTimeoutUs);
      if (input_index >= 0) {
        size_t input_capacity = 0;
        uint8_t* input_buffer = AMediaCodec_getInputBuffer(codec, input_index, &input_capacity);
        if (input_buffer == nullptr) {
          if (error != nullptr) {
            *error = "AMediaCodec_getInputBuffer returned null.";
          }
          result_code = -6;
          goto cleanup;
        }

        if (consumed < wav.pcm.size()) {
          const std::size_t remaining = wav.pcm.size() - consumed;
          const std::size_t to_copy = std::min<std::size_t>(remaining, input_capacity);
          std::memcpy(input_buffer, wav.pcm.data() + consumed, to_copy);
          const int64_t pts_us = (frames_submitted * 1000000LL) / wav.sample_rate;
          status = AMediaCodec_queueInputBuffer(codec, input_index, 0, to_copy, pts_us, 0);
          if (status != AMEDIA_OK) {
            if (error != nullptr) {
              std::ostringstream ss;
              ss << "AMediaCodec_queueInputBuffer failed: status=" << status;
              *error = ss.str();
            }
            result_code = static_cast<int32_t>(status);
            goto cleanup;
          }
          consumed += to_copy;
          frames_submitted += static_cast<int64_t>(to_copy / bytes_per_frame);
        } else {
          const int64_t pts_us = (frames_submitted * 1000000LL) / wav.sample_rate;
          status = AMediaCodec_queueInputBuffer(
              codec, input_index, 0, 0, pts_us, AMEDIACODEC_BUFFER_FLAG_END_OF_STREAM);
          if (status != AMEDIA_OK) {
            if (error != nullptr) {
              std::ostringstream ss;
              ss << "AMediaCodec_queueInputBuffer(EOS) failed: status=" << status;
              *error = ss.str();
            }
            result_code = static_cast<int32_t>(status);
            goto cleanup;
          }
          input_eos = true;
        }
      }
    }

    while (true) {
      AMediaCodecBufferInfo info;
      const ssize_t output_index = AMediaCodec_dequeueOutputBuffer(codec, &info, kCodecTimeoutUs);

      if (output_index == AMEDIACODEC_INFO_TRY_AGAIN_LATER) {
        break;
      }
      if (output_index == AMEDIACODEC_INFO_OUTPUT_FORMAT_CHANGED) {
        AMediaFormat* output_format = AMediaCodec_getOutputFormat(codec);
        if (output_format == nullptr) {
          if (error != nullptr) {
            *error = "AMediaCodec_getOutputFormat returned null.";
          }
          result_code = -7;
          goto cleanup;
        }

        track_index = AMediaMuxer_addTrack(muxer, output_format);
        AMediaFormat_delete(output_format);
        if (track_index < 0) {
          if (error != nullptr) {
            std::ostringstream ss;
            ss << "AMediaMuxer_addTrack failed: track_index=" << track_index;
            *error = ss.str();
          }
          result_code = track_index;
          goto cleanup;
        }

        status = AMediaMuxer_start(muxer);
        if (status != AMEDIA_OK) {
          if (error != nullptr) {
            std::ostringstream ss;
            ss << "AMediaMuxer_start failed: status=" << status;
            *error = ss.str();
          }
          result_code = static_cast<int32_t>(status);
          goto cleanup;
        }
        muxer_started = true;
        continue;
      }
      if (output_index < 0) {
        if (error != nullptr) {
          std::ostringstream ss;
          ss << "AMediaCodec_dequeueOutputBuffer failed: code=" << output_index;
          *error = ss.str();
        }
        result_code = static_cast<int32_t>(output_index);
        goto cleanup;
      }

      if ((info.flags & AMEDIACODEC_BUFFER_FLAG_CODEC_CONFIG) != 0) {
        info.size = 0;
      }

      if (info.size > 0) {
        if (!muxer_started || track_index < 0) {
          if (error != nullptr) {
            *error = "AAC output was produced before muxer started.";
          }
          result_code = -8;
          AMediaCodec_releaseOutputBuffer(codec, output_index, false);
          goto cleanup;
        }

        size_t output_capacity = 0;
        uint8_t* output_buffer = AMediaCodec_getOutputBuffer(codec, output_index, &output_capacity);
        if (output_buffer == nullptr) {
          if (error != nullptr) {
            *error = "AMediaCodec_getOutputBuffer returned null.";
          }
          result_code = -9;
          AMediaCodec_releaseOutputBuffer(codec, output_index, false);
          goto cleanup;
        }

        status = AMediaMuxer_writeSampleData(muxer, track_index, output_buffer, &info);
        if (status != AMEDIA_OK) {
          if (error != nullptr) {
            std::ostringstream ss;
            ss << "AMediaMuxer_writeSampleData failed: status=" << status;
            *error = ss.str();
          }
          result_code = static_cast<int32_t>(status);
          AMediaCodec_releaseOutputBuffer(codec, output_index, false);
          goto cleanup;
        }
      }

      const bool buffer_eos = (info.flags & AMEDIACODEC_BUFFER_FLAG_END_OF_STREAM) != 0;
      AMediaCodec_releaseOutputBuffer(codec, output_index, false);

      if (buffer_eos) {
        output_eos = true;
        break;
      }
    }
  }

cleanup:
  if (muxer != nullptr) {
    if (muxer_started) {
      AMediaMuxer_stop(muxer);
    }
    AMediaMuxer_delete(muxer);
  }
  if (codec != nullptr) {
    if (codec_started) {
      AMediaCodec_stop(codec);
    }
    AMediaCodec_delete(codec);
  }
  if (format != nullptr) {
    AMediaFormat_delete(format);
  }

  return result_code;
}

int32_t ReadAudioMetadata(const char* input_path_utf8, int64_t* out_duration_micros,
                          int32_t* out_sample_rate_hz, int32_t* out_channel_count,
                          int32_t* out_bitrate_bps, std::string* out_container_format,
                          std::string* out_codec, std::string* out_codec_profile,
                          std::string* error) {
  if (input_path_utf8 == nullptr || out_duration_micros == nullptr ||
      out_sample_rate_hz == nullptr || out_channel_count == nullptr ||
      out_bitrate_bps == nullptr || out_container_format == nullptr ||
      out_codec == nullptr || out_codec_profile == nullptr) {
    if (error != nullptr) {
      *error = "Invalid arguments for ReadAudioMetadata.";
    }
    return -1;
  }

  *out_duration_micros = -1;
  *out_sample_rate_hz = -1;
  *out_channel_count = -1;
  *out_bitrate_bps = -1;
  out_container_format->clear();
  out_codec->clear();
  out_codec_profile->clear();

  *out_container_format = ExtractContainerFormatFromPath(input_path_utf8);

  AMediaExtractor* extractor = AMediaExtractor_new();
  if (extractor == nullptr) {
    if (error != nullptr) {
      *error = "Failed to create AMediaExtractor.";
    }
    return -2;
  }

  const media_status_t set_data_status = AMediaExtractor_setDataSource(extractor, input_path_utf8);
  if (set_data_status != AMEDIA_OK) {
    if (error != nullptr) {
      std::ostringstream ss;
      ss << "AMediaExtractor_setDataSource failed: status=" << set_data_status;
      *error = ss.str();
    }
    AMediaExtractor_delete(extractor);
    return static_cast<int32_t>(set_data_status);
  }

  const size_t track_count = AMediaExtractor_getTrackCount(extractor);
  bool found_audio_track = false;

  for (size_t i = 0; i < track_count; ++i) {
    AMediaFormat* format = AMediaExtractor_getTrackFormat(extractor, i);
    if (format == nullptr) {
      continue;
    }

    const char* mime = nullptr;
    const bool has_mime = AMediaFormat_getString(format, AMEDIAFORMAT_KEY_MIME, &mime);
    const bool is_audio = has_mime && mime != nullptr && std::strncmp(mime, "audio/", 6) == 0;
    if (!is_audio) {
      AMediaFormat_delete(format);
      continue;
    }

    found_audio_track = true;
    *out_codec = mime;

    int64_t duration_micros = -1;
    if (!AMediaFormat_getInt64(format, AMEDIAFORMAT_KEY_DURATION, &duration_micros) ||
        duration_micros < 0) {
      if (error != nullptr) {
        *error = "Could not read valid audio duration from media metadata.";
      }
      AMediaFormat_delete(format);
      AMediaExtractor_delete(extractor);
      return -3;
    }
    *out_duration_micros = duration_micros;

    int32_t sample_rate_hz = -1;
    if (AMediaFormat_getInt32(format, AMEDIAFORMAT_KEY_SAMPLE_RATE, &sample_rate_hz)) {
      *out_sample_rate_hz = sample_rate_hz;
    }

    int32_t channel_count = -1;
    if (AMediaFormat_getInt32(format, AMEDIAFORMAT_KEY_CHANNEL_COUNT, &channel_count)) {
      *out_channel_count = channel_count;
    }

    int32_t bitrate_bps = -1;
    if (AMediaFormat_getInt32(format, AMEDIAFORMAT_KEY_BIT_RATE, &bitrate_bps)) {
      *out_bitrate_bps = bitrate_bps;
    }

    const std::string codec_lower = AsciiLower(*out_codec);
    const bool is_aac_codec = codec_lower.find("aac") != std::string::npos ||
                              codec_lower.find("mp4a") != std::string::npos;
    int32_t profile_value = -1;
    if (is_aac_codec &&
        (AMediaFormat_getInt32(format, AMEDIAFORMAT_KEY_AAC_PROFILE, &profile_value) ||
         AMediaFormat_getInt32(format, "profile", &profile_value))) {
      *out_codec_profile = AacProfileName(profile_value);
    }

    AMediaFormat_delete(format);
    break;
  }

  AMediaExtractor_delete(extractor);

  if (!found_audio_track) {
    if (error != nullptr) {
      *error = "No audio track found in media file.";
    }
    return -4;
  }

  return 0;
}
}  // namespace

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_android_aac_encoder_healthcheck(char* error_utf8, uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  AMediaCodec* codec = AMediaCodec_createEncoderByType(kAacMimeType);
  if (codec == nullptr) {
    WriteError("Failed to create Android AAC encoder codec (audio/mp4a-latm).", error_utf8,
               error_utf8_capacity);
    return -1;
  }
  AMediaCodec_delete(codec);
  return 0;
}

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_android_encode_wav_file_to_aac_m4a(const char* input_path_utf8,
                                                 const char* output_path_utf8,
                                                 uint32_t bitrate_bps,
                                                 char* error_utf8,
                                                 uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  if (input_path_utf8 == nullptr || output_path_utf8 == nullptr || bitrate_bps == 0) {
    WriteError("Invalid arguments for speech_utils_android_encode_wav_file_to_aac_m4a.",
               error_utf8, error_utf8_capacity);
    return -1;
  }

  WavPcmData wav;
  std::string parse_error;
  if (!ParsePcm16Wav(input_path_utf8, &wav, &parse_error)) {
    WriteError(parse_error, error_utf8, error_utf8_capacity);
    return -2;
  }

  std::string encode_error;
  const int32_t result = EncodePcm16WavToAacM4a(wav, output_path_utf8, bitrate_bps, &encode_error);
  if (result != 0 && !encode_error.empty()) {
    WriteError(encode_error, error_utf8, error_utf8_capacity);
  }
  return result;
}

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_android_audio_metadata_healthcheck(char* error_utf8, uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  AMediaExtractor* extractor = AMediaExtractor_new();
  if (extractor == nullptr) {
    WriteError("Failed to create Android media extractor.", error_utf8, error_utf8_capacity);
    return -1;
  }
  AMediaExtractor_delete(extractor);
  return 0;
}

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_android_read_audio_metadata(const char* input_path_utf8, int64_t* out_duration_micros,
                                         int32_t* out_sample_rate_hz, int32_t* out_channel_count,
                                         int32_t* out_bitrate_bps,
                                         char* out_container_format_utf8,
                                         uint32_t out_container_format_utf8_capacity,
                                         char* out_codec_utf8,
                                         uint32_t out_codec_utf8_capacity,
                                         char* out_codec_profile_utf8,
                                         uint32_t out_codec_profile_utf8_capacity,
                                         char* error_utf8,
                                         uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  WriteOutputText("", out_container_format_utf8, out_container_format_utf8_capacity);
  WriteOutputText("", out_codec_utf8, out_codec_utf8_capacity);
  WriteOutputText("", out_codec_profile_utf8, out_codec_profile_utf8_capacity);

  if (input_path_utf8 == nullptr || out_duration_micros == nullptr || out_sample_rate_hz == nullptr ||
      out_channel_count == nullptr || out_bitrate_bps == nullptr ||
      out_container_format_utf8 == nullptr || out_codec_utf8 == nullptr ||
      out_codec_profile_utf8 == nullptr) {
    WriteError("Invalid arguments for speech_utils_android_read_audio_metadata.", error_utf8,
               error_utf8_capacity);
    return -1;
  }

  std::string container_format;
  std::string codec;
  std::string codec_profile;
  std::string metadata_error;
  const int32_t code =
      ReadAudioMetadata(input_path_utf8, out_duration_micros, out_sample_rate_hz,
                        out_channel_count, out_bitrate_bps, &container_format, &codec,
                        &codec_profile, &metadata_error);
  WriteOutputText(container_format, out_container_format_utf8, out_container_format_utf8_capacity);
  WriteOutputText(codec, out_codec_utf8, out_codec_utf8_capacity);
  WriteOutputText(codec_profile, out_codec_profile_utf8, out_codec_profile_utf8_capacity);
  if (code != 0 && !metadata_error.empty()) {
    WriteError(metadata_error, error_utf8, error_utf8_capacity);
  }
  return code;
}
