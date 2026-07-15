#include "linux_audio_recorder_api.h"

#include <algorithm>
#include <cctype>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <deque>
#include <mutex>
#include <string>
#include <vector>

#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>

#include "../../../third_party/miniaudio/include/miniaudio.h"

namespace speech_utils::linux_recorder {

void WriteError(const std::string& message, char* out_error_utf8, uint32_t out_error_capacity) {
  if (out_error_utf8 == nullptr || out_error_capacity == 0) {
    return;
  }
  const auto copy_length = static_cast<uint32_t>(
      std::min<std::size_t>(message.size(), static_cast<std::size_t>(out_error_capacity - 1)));
  std::memcpy(out_error_utf8, message.data(), copy_length);
  out_error_utf8[copy_length] = '\0';
}

namespace {
constexpr uint32_t kProcessingFlagNoiseSuppression = 1U << 0;
constexpr uint32_t kProcessingFlagAutomaticGainControl = 1U << 2;
constexpr uint32_t kProcessingFlagHighPassFilter = 1U << 3;
constexpr uint32_t kProcessingFlagPresetVoiceIsolation = 1U << 5;

std::string DescribeMiniaudioError(const char* prefix, ma_result result) {
  const char* description = ma_result_description(result);
  if (description == nullptr || description[0] == '\0') {
    return std::string(prefix) + " (miniaudio code " + std::to_string(static_cast<int>(result)) +
           ").";
  }
  return std::string(prefix) + ": " + description;
}

bool WriteOutput(const std::string& output, char* out_utf8, uint32_t out_capacity,
                 char* error_utf8, uint32_t error_capacity) {
  if (out_utf8 == nullptr || out_capacity == 0) {
    WriteError("Output buffer is null.", error_utf8, error_capacity);
    return false;
  }
  if (output.size() + 1 > out_capacity) {
    WriteError("Output buffer is too small.", error_utf8, error_capacity);
    return false;
  }
  std::memcpy(out_utf8, output.data(), output.size());
  out_utf8[output.size()] = '\0';
  return true;
}

std::string TrimAscii(const char* utf8) {
  if (utf8 == nullptr) {
    return {};
  }

  std::string value(utf8);
  const auto is_whitespace = [](unsigned char ch) { return std::isspace(ch) != 0; };

  const auto begin = std::find_if_not(value.begin(), value.end(), [&](char ch) {
    return is_whitespace(static_cast<unsigned char>(ch));
  });
  if (begin == value.end()) {
    return {};
  }

  const auto end = std::find_if_not(value.rbegin(), value.rend(), [&](char ch) {
                     return is_whitespace(static_cast<unsigned char>(ch));
                   }).base();
  return std::string(begin, end);
}

std::string DeviceIdToHex(const ma_device_id& device_id) {
  static constexpr char kHexDigits[] = "0123456789abcdef";
  const auto* bytes = reinterpret_cast<const uint8_t*>(&device_id);

  std::string hex(sizeof(ma_device_id) * 2, '\0');
  for (std::size_t i = 0; i < sizeof(ma_device_id); i++) {
    const uint8_t value = bytes[i];
    hex[i * 2] = kHexDigits[(value >> 4) & 0x0F];
    hex[i * 2 + 1] = kHexDigits[value & 0x0F];
  }

  return hex;
}

bool EnumerateCaptureDevices(ma_context* out_context, ma_device_info** out_capture_infos,
                             ma_uint32* out_capture_count, char* error_utf8,
                             uint32_t error_utf8_capacity) {
  if (out_context == nullptr || out_capture_infos == nullptr || out_capture_count == nullptr) {
    WriteError("Capture device enumeration output pointer is null.", error_utf8,
               error_utf8_capacity);
    return false;
  }

  ma_context_config context_config = ma_context_config_init();
  const ma_result context_result = ma_context_init(nullptr, 0, &context_config, out_context);
  if (context_result != MA_SUCCESS) {
    WriteError(DescribeMiniaudioError("Failed to initialize miniaudio context", context_result),
               error_utf8, error_utf8_capacity);
    return false;
  }

  ma_device_info* playback_infos = nullptr;
  ma_uint32 playback_count = 0;
  ma_device_info* capture_infos = nullptr;
  ma_uint32 capture_count = 0;

  const ma_result devices_result = ma_context_get_devices(
      out_context, &playback_infos, &playback_count, &capture_infos, &capture_count);
  if (devices_result != MA_SUCCESS) {
    ma_context_uninit(out_context);
    WriteError(
        DescribeMiniaudioError("Failed to enumerate miniaudio capture devices", devices_result),
        error_utf8, error_utf8_capacity);
    return false;
  }

  *out_capture_infos = capture_infos;
  *out_capture_count = capture_count;
  return true;
}

bool FindCaptureDeviceByHexId(const ma_device_info* capture_infos, ma_uint32 capture_count,
                              const std::string& target_id_hex,
                              ma_device_id* out_device_id_or_null) {
  if (target_id_hex.empty()) {
    return false;
  }

  for (ma_uint32 i = 0; i < capture_count; i++) {
    const auto& info = capture_infos[i];
    if (DeviceIdToHex(info.id) != target_id_hex) {
      continue;
    }
    if (out_device_id_or_null != nullptr) {
      *out_device_id_or_null = info.id;
    }
    return true;
  }

  return false;
}

const ma_device_info* FindDefaultCaptureDeviceInfo(const ma_device_info* capture_infos,
                                                   ma_uint32 capture_count) {
  for (ma_uint32 i = 0; i < capture_count; i++) {
    if (capture_infos[i].isDefault == MA_TRUE) {
      return &capture_infos[i];
    }
  }
  return nullptr;
}

std::string BuildInputDevicesJson(const ma_device_info* capture_infos, ma_uint32 capture_count) {
  rapidjson::StringBuffer buffer;
  rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
  writer.StartArray();

  for (ma_uint32 i = 0; i < capture_count; i++) {
    const auto& info = capture_infos[i];
    const std::string device_id = DeviceIdToHex(info.id);
    const std::string label = std::string(info.name);

    writer.StartObject();
    writer.Key("id");
    writer.String(device_id.c_str(), static_cast<rapidjson::SizeType>(device_id.size()));
    writer.Key("label");
    writer.String(label.c_str(), static_cast<rapidjson::SizeType>(label.size()));
    writer.Key("isDefault");
    writer.Bool(info.isDefault == MA_TRUE);
    writer.EndObject();
  }

  writer.EndArray();
  return std::string(buffer.GetString(), buffer.GetSize());
}

#pragma pack(push, 1)
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
#pragma pack(pop)

struct CaptureDeviceConfig {
  uint32_t sample_rate_hz = 0;
  uint32_t channel_count = 0;
  uint32_t preferred_period_frames = 0;
  uint32_t processing_flags = 0;
  std::string input_device_id;

  bool IsCompatibleWith(const CaptureDeviceConfig& other) const {
    return sample_rate_hz == other.sample_rate_hz && channel_count == other.channel_count &&
           processing_flags == other.processing_flags && input_device_id == other.input_device_id;
  }
};

bool IsCaptureDeviceConfigValid(const CaptureDeviceConfig& config) {
  return config.sample_rate_hz > 0 && config.channel_count > 0;
}

CaptureDeviceConfig BuildCaptureDeviceConfig(uint32_t sample_rate_hz, uint32_t channel_count,
                                             uint32_t preferred_period_frames,
                                             uint32_t processing_flags,
                                             const char* input_device_id_utf8) {
  CaptureDeviceConfig config{};
  config.sample_rate_hz = sample_rate_hz;
  config.channel_count = channel_count;
  config.preferred_period_frames = preferred_period_frames;
  config.processing_flags = processing_flags;
  config.input_device_id = TrimAscii(input_device_id_utf8);
  return config;
}

enum class RecorderMode { kStopped, kContinuous, kFile, kStream };

struct SoftwareVoiceProcessingConfig {
  bool noise_suppression = false;
  bool automatic_gain_control = false;
  bool high_pass_filter = false;
  bool strong_isolation = false;
};

SoftwareVoiceProcessingConfig BuildSoftwareVoiceProcessingConfig(uint32_t processing_flags) {
  SoftwareVoiceProcessingConfig config{};
  config.noise_suppression = (processing_flags & kProcessingFlagNoiseSuppression) != 0;
  config.automatic_gain_control = (processing_flags & kProcessingFlagAutomaticGainControl) != 0;
  config.high_pass_filter = (processing_flags & kProcessingFlagHighPassFilter) != 0;
  config.strong_isolation = (processing_flags & kProcessingFlagPresetVoiceIsolation) != 0;
  return config;
}

class LinuxAudioRecorderState {
 public:
  LinuxAudioRecorderState() = default;

  ~LinuxAudioRecorderState() {
    char error[1] = {0};
    Reset(error, sizeof(error));
  }

  int32_t ListInputDevicesJson(char* out_json_utf8, uint32_t out_json_capacity,
                               char* error_utf8, uint32_t error_utf8_capacity) {
    ma_context context{};
    ma_device_info* capture_infos = nullptr;
    ma_uint32 capture_count = 0;
    if (!EnumerateCaptureDevices(&context, &capture_infos, &capture_count, error_utf8,
                                 error_utf8_capacity)) {
      return -1;
    }

    const std::string json = BuildInputDevicesJson(capture_infos, capture_count);
    ma_context_uninit(&context);

    if (!WriteOutput(json, out_json_utf8, out_json_capacity, error_utf8,
                     error_utf8_capacity)) {
      return -2;
    }

    return 0;
  }

  int32_t StartFile(const speech_utils::recorder::RecorderStartConfig& start_config,
                    char* error_utf8,
                    uint32_t error_utf8_capacity) {
    const uint32_t sample_rate_hz = start_config.sample_rate_hz;
    const uint32_t channel_count = start_config.channel_count;
    const char* output_path_utf8 = start_config.output_path_utf8;
    const char* input_device_id_utf8 = start_config.input_device_id_utf8;
    const uint32_t processing_flags =
        static_cast<uint32_t>(start_config.runtime.processing_flags);
    const uint32_t preferred_period_frames =
        start_config.runtime.windows_preferred_period_frames;
    if (output_path_utf8 == nullptr) {
      WriteError("Output path is null.", error_utf8, error_utf8_capacity);
      return -1;
    }
    if (sample_rate_hz == 0 || channel_count == 0) {
      WriteError("Sample rate and channel count must be > 0.", error_utf8, error_utf8_capacity);
      return -2;
    }

    const CaptureDeviceConfig requested_config = BuildCaptureDeviceConfig(
        sample_rate_hz, channel_count, preferred_period_frames, processing_flags,
        input_device_id_utf8);

    FILE* file = std::fopen(output_path_utf8, "wb");
    if (file == nullptr) {
      WriteError("Failed to open output file for writing.", error_utf8, error_utf8_capacity);
      return -3;
    }

    if (!WriteInitialWavHeader(file, sample_rate_hz, channel_count)) {
      std::fclose(file);
      WriteError("Failed to write WAV header.", error_utf8, error_utf8_capacity);
      return -4;
    }

    while (true) {
      bool should_stop_device = false;
      {
        std::lock_guard<std::mutex> lock(mutex_);
        if (mode_ == RecorderMode::kFile || mode_ == RecorderMode::kStream) {
          std::fclose(file);
          WriteError("Recorder is already running.", error_utf8, error_utf8_capacity);
          return -5;
        }

        warm_capture_config_ = requested_config;

        if (device_initialized_ && !current_device_config_.IsCompatibleWith(requested_config)) {
          PrepareDeviceRestartLocked();
          should_stop_device = true;
        } else {
          if (!device_initialized_ &&
              !StartDeviceLocked(requested_config, error_utf8, error_utf8_capacity)) {
            std::fclose(file);
            return -6;
          }

          file_ = file;
          sample_rate_hz_ = sample_rate_hz;
          channel_count_ = channel_count;
          data_bytes_written_ = 0;
          ResetAmplitudeStateLocked();
          mode_ = RecorderMode::kFile;
          return 0;
        }
      }

      if (should_stop_device) {
        ma_device_stop(&device_);
        ma_device_uninit(&device_);
      }
    }
  }

  int32_t StartStream(const speech_utils::recorder::RecorderStartConfig& start_config,
                      char* error_utf8,
                      uint32_t error_utf8_capacity) {
    const uint32_t sample_rate_hz = start_config.sample_rate_hz;
    const uint32_t channel_count = start_config.channel_count;
    const uint32_t frames_per_chunk = start_config.frames_per_chunk;
    const char* input_device_id_utf8 = start_config.input_device_id_utf8;
    const uint32_t processing_flags =
        static_cast<uint32_t>(start_config.runtime.processing_flags);
    const uint32_t preferred_period_frames =
        start_config.runtime.windows_preferred_period_frames;
    if (sample_rate_hz == 0 || channel_count == 0 || frames_per_chunk == 0) {
      WriteError("Sample rate, channel count and frames_per_chunk must be > 0.", error_utf8,
                 error_utf8_capacity);
      return -1;
    }

    const uint32_t effective_period_frames =
        preferred_period_frames > 0 ? preferred_period_frames : frames_per_chunk;
    const CaptureDeviceConfig requested_config = BuildCaptureDeviceConfig(
        sample_rate_hz, channel_count, effective_period_frames, processing_flags,
        input_device_id_utf8);

    while (true) {
      bool should_stop_device = false;
      {
        std::lock_guard<std::mutex> lock(mutex_);
        if (mode_ == RecorderMode::kFile || mode_ == RecorderMode::kStream) {
          WriteError("Recorder is already running.", error_utf8, error_utf8_capacity);
          return -2;
        }

        warm_capture_config_ = requested_config;

        if (device_initialized_ && !current_device_config_.IsCompatibleWith(requested_config)) {
          PrepareDeviceRestartLocked();
          should_stop_device = true;
        } else {
          if (!device_initialized_ &&
              !StartDeviceLocked(requested_config, error_utf8, error_utf8_capacity)) {
            return -3;
          }

          ClearBufferedAudioLocked();
          stream_sample_limit_ =
              std::max<std::size_t>(sample_rate_hz * channel_count * 5,
                                    static_cast<std::size_t>(frames_per_chunk) * channel_count *
                                        16);
          ResetAmplitudeStateLocked();
          mode_ = RecorderMode::kStream;
          return 0;
        }
      }

      if (should_stop_device) {
        ma_device_stop(&device_);
        ma_device_uninit(&device_);
      }
    }
  }

  int32_t SetContinousCapture(int32_t enabled,
                              const speech_utils::recorder::RecorderStartConfig* start_config,
                              char* error_utf8,
                              uint32_t error_utf8_capacity) {
    const bool should_enable = enabled != 0;
    CaptureDeviceConfig requested_config{};

    if (should_enable) {
      if (start_config == nullptr) {
        WriteError("Start config pointer is null.", error_utf8, error_utf8_capacity);
        return -1;
      }
      if (start_config->sample_rate_hz == 0 || start_config->channel_count == 0) {
        WriteError("Sample rate and channel count must be > 0.", error_utf8, error_utf8_capacity);
        return -2;
      }

      const uint32_t effective_period_frames =
          start_config->runtime.windows_preferred_period_frames > 0
              ? start_config->runtime.windows_preferred_period_frames
              : start_config->frames_per_chunk;
      requested_config = BuildCaptureDeviceConfig(
          start_config->sample_rate_hz, start_config->channel_count, effective_period_frames,
          static_cast<uint32_t>(start_config->runtime.processing_flags),
          start_config->input_device_id_utf8);
    }

    while (true) {
      bool should_stop_device = false;
      bool should_start_device = false;
      CaptureDeviceConfig config_to_start{};

      {
        std::lock_guard<std::mutex> lock(mutex_);
        continuous_capture_enabled_ = should_enable;

        if (should_enable) {
          warm_capture_config_ = requested_config;
          if (mode_ == RecorderMode::kFile || mode_ == RecorderMode::kStream) {
            return 0;
          }
          if (device_initialized_ &&
              current_device_config_.IsCompatibleWith(warm_capture_config_)) {
            mode_ = RecorderMode::kContinuous;
            return 0;
          }
          if (device_initialized_) {
            PrepareDeviceRestartLocked();
            should_stop_device = true;
          } else {
            config_to_start = warm_capture_config_;
            should_start_device = IsCaptureDeviceConfigValid(config_to_start);
          }
        } else {
          if (mode_ == RecorderMode::kContinuous && device_initialized_) {
            PrepareDeviceRestartLocked();
            should_stop_device = true;
          } else {
            return 0;
          }
        }
      }

      if (should_stop_device) {
        ma_device_stop(&device_);
        ma_device_uninit(&device_);
        if (!should_enable) {
          return 0;
        }
        continue;
      }

      if (should_start_device) {
        std::lock_guard<std::mutex> lock(mutex_);
        if (!StartDeviceLocked(config_to_start, error_utf8, error_utf8_capacity)) {
          continuous_capture_enabled_ = false;
          return -3;
        }
        ResetAmplitudeStateLocked();
        mode_ = RecorderMode::kContinuous;
        return 0;
      }

      return 0;
    }
  }

  int32_t ReadStreamPcm16(int16_t* out_samples, uint32_t out_sample_capacity,
                          uint32_t* out_samples_written, char* error_utf8,
                          uint32_t error_utf8_capacity) {
    if (out_samples == nullptr || out_samples_written == nullptr) {
      WriteError("Output sample pointers must not be null.", error_utf8, error_utf8_capacity);
      return -1;
    }

    *out_samples_written = 0;

    std::lock_guard<std::mutex> lock(mutex_);
    if (mode_ != RecorderMode::kStream) {
      return 0;
    }

    const auto readable =
        static_cast<uint32_t>(std::min<std::size_t>(stream_samples_.size(), out_sample_capacity));
    for (uint32_t i = 0; i < readable; i++) {
      out_samples[i] = stream_samples_.front();
      stream_samples_.pop_front();
    }
    *out_samples_written = readable;
    return 0;
  }

  int32_t Stop(char* error_utf8, uint32_t error_utf8_capacity) {
    FILE* file_to_finalize = nullptr;
    uint32_t data_bytes_written = 0;
    uint32_t sample_rate_hz = 0;
    uint32_t channel_count = 0;
    bool should_stop_device = false;
    bool should_start_device = false;
    CaptureDeviceConfig warm_config_to_start{};

    {
      std::lock_guard<std::mutex> lock(mutex_);
      if (mode_ == RecorderMode::kStopped || mode_ == RecorderMode::kContinuous) {
        return 0;
      }

      const bool keep_device_running =
          continuous_capture_enabled_ && device_initialized_ &&
          IsCaptureDeviceConfigValid(warm_capture_config_) &&
          current_device_config_.IsCompatibleWith(warm_capture_config_);
      const bool restart_continuous_capture =
          continuous_capture_enabled_ && device_initialized_ &&
          IsCaptureDeviceConfigValid(warm_capture_config_) && !keep_device_running;
      mode_ = keep_device_running ? RecorderMode::kContinuous : RecorderMode::kStopped;
      ClearBufferedAudioLocked();
      ResetAmplitudeStateLocked();

      file_to_finalize = file_;
      file_ = nullptr;
      data_bytes_written = data_bytes_written_;
      sample_rate_hz = sample_rate_hz_;
      channel_count = channel_count_;
      data_bytes_written_ = 0;

      if (!keep_device_running) {
        should_stop_device = device_initialized_;
        should_start_device = restart_continuous_capture;
        warm_config_to_start = warm_capture_config_;
        PrepareDeviceRestartLocked();
      }
    }

    if (should_stop_device) {
      ma_device_stop(&device_);
      ma_device_uninit(&device_);
    }

    if (file_to_finalize != nullptr) {
      if (!FinalizeWavHeader(file_to_finalize, data_bytes_written, sample_rate_hz, channel_count)) {
        WriteError("Failed to finalize WAV header.", error_utf8, error_utf8_capacity);
        std::fclose(file_to_finalize);
        return -1;
      }
      std::fclose(file_to_finalize);
    }

    if (should_start_device) {
      std::lock_guard<std::mutex> lock(mutex_);
      if (!StartDeviceLocked(warm_config_to_start, error_utf8, error_utf8_capacity)) {
        continuous_capture_enabled_ = false;
        return -2;
      }
      ResetAmplitudeStateLocked();
      mode_ = RecorderMode::kContinuous;
    }

    return 0;
  }

  int32_t Reset(char* error_utf8, uint32_t error_utf8_capacity) {
    FILE* file_to_close = nullptr;
    bool should_stop_device = false;

    {
      std::lock_guard<std::mutex> lock(mutex_);
      if (mode_ == RecorderMode::kStopped && !device_initialized_) {
        return 0;
      }

      file_to_close = file_;
      file_ = nullptr;
      mode_ = RecorderMode::kStopped;
      ClearBufferedAudioLocked();
      ResetAmplitudeStateLocked();
      should_stop_device = device_initialized_;
      PrepareDeviceRestartLocked();
    }

    if (should_stop_device) {
      ma_device_stop(&device_);
      ma_device_uninit(&device_);
    }

    if (file_to_close != nullptr) {
      std::fclose(file_to_close);
    }

    WriteError("", error_utf8, error_utf8_capacity);
    return 0;
  }

  int32_t IsRecording(int32_t* out_is_recording, char* error_utf8,
                      uint32_t error_utf8_capacity) {
    if (out_is_recording == nullptr) {
      WriteError("State output pointer is null.", error_utf8, error_utf8_capacity);
      return -1;
    }

    std::lock_guard<std::mutex> lock(mutex_);
    *out_is_recording = (mode_ == RecorderMode::kFile || mode_ == RecorderMode::kStream) ? 1 : 0;
    return 0;
  }

  int32_t GetAmplitude(double* out_current_dbfs, double* out_max_dbfs, char* error_utf8,
                       uint32_t error_utf8_capacity) {
    if (out_current_dbfs == nullptr || out_max_dbfs == nullptr) {
      WriteError("Amplitude output pointers must not be null.", error_utf8, error_utf8_capacity);
      return -1;
    }

    std::lock_guard<std::mutex> lock(mutex_);
    *out_current_dbfs = current_amplitude_dbfs_;
    *out_max_dbfs = max_amplitude_dbfs_;
    return 0;
  }

  void OnCapturedSamples(const int16_t* samples, uint32_t frame_count) {
    if (samples == nullptr || frame_count == 0) {
      return;
    }

    std::lock_guard<std::mutex> lock(mutex_);
    if (mode_ == RecorderMode::kStopped) {
      return;
    }

    const auto sample_count = static_cast<std::size_t>(frame_count) * channel_count_;
    const int16_t* processed_samples = MaybeProcessSamplesLocked(samples, sample_count);
    UpdateAmplitudeLocked(processed_samples, sample_count);

    if (mode_ == RecorderMode::kFile && file_ != nullptr) {
      const auto written =
          std::fwrite(processed_samples, sizeof(int16_t), sample_count, file_);
      if (written == sample_count) {
        data_bytes_written_ += static_cast<uint32_t>(written * sizeof(int16_t));
      }
      return;
    }

    if (mode_ == RecorderMode::kStream) {
      stream_samples_.insert(stream_samples_.end(), processed_samples,
                             processed_samples + sample_count);
      if (stream_samples_.size() > stream_sample_limit_) {
        const auto overflow = stream_samples_.size() - stream_sample_limit_;
        stream_samples_.erase(stream_samples_.begin(), stream_samples_.begin() + overflow);
      }
    }
  }

 private:
  void ResetAmplitudeStateLocked() {
    current_amplitude_dbfs_ = -90.0;
    max_amplitude_dbfs_ = -90.0;
  }

  void ClearBufferedAudioLocked() {
    stream_samples_.clear();
    stream_sample_limit_ = 0;
  }

  void PrepareDeviceRestartLocked() {
    mode_ = RecorderMode::kStopped;
    file_ = nullptr;
    ClearBufferedAudioLocked();
    ResetAmplitudeStateLocked();
    device_initialized_ = false;
    current_device_config_ = {};
    software_processing_config_ = {};
    data_bytes_written_ = 0;
    sample_rate_hz_ = 0;
    channel_count_ = 0;
    ResetSoftwareProcessingStateLocked();
  }

  static double ComputeDbfs(const int16_t* samples, std::size_t sample_count) {
    if (samples == nullptr || sample_count == 0) {
      return -90.0;
    }

    double sum_squares = 0.0;
    for (std::size_t i = 0; i < sample_count; i++) {
      const double normalized = static_cast<double>(samples[i]) / 32768.0;
      sum_squares += normalized * normalized;
    }
    if (sum_squares <= 0.0) {
      return -90.0;
    }

    const double rms = std::sqrt(sum_squares / static_cast<double>(sample_count));
    if (!(rms > 0.0)) {
      return -90.0;
    }

    const double dbfs = 20.0 * std::log10(rms);
    if (!std::isfinite(dbfs)) {
      return -90.0;
    }

    return std::clamp(dbfs, -90.0, 0.0);
  }

  void UpdateAmplitudeLocked(const int16_t* samples, std::size_t sample_count) {
    const double dbfs = ComputeDbfs(samples, sample_count);
    current_amplitude_dbfs_ = dbfs;
    if (dbfs > max_amplitude_dbfs_) {
      max_amplitude_dbfs_ = dbfs;
    }
  }

  static void DataCallback(ma_device* device, void* output, const void* input,
                           ma_uint32 frame_count) {
    (void)output;
    if (device == nullptr || input == nullptr) {
      return;
    }

    auto* self = reinterpret_cast<LinuxAudioRecorderState*>(device->pUserData);
    if (self == nullptr) {
      return;
    }

    self->OnCapturedSamples(reinterpret_cast<const int16_t*>(input),
                            static_cast<uint32_t>(frame_count));
  }

  static bool WriteInitialWavHeader(FILE* file, uint32_t sample_rate_hz, uint32_t channel_count) {
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

  static bool FinalizeWavHeader(FILE* file, uint32_t data_bytes_written, uint32_t sample_rate_hz,
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

  void ResetSoftwareProcessingStateLocked() {
    software_noise_floor_rms_ = 0.015;
    software_agc_gain_ = 1.0;

    const auto channel_count = std::max<uint32_t>(channel_count_, 1);
    hpf_prev_input_by_channel_.assign(channel_count, 0.0);
    hpf_prev_output_by_channel_.assign(channel_count, 0.0);
    software_frame_buffer_.clear();
    software_output_buffer_.clear();
  }

  const int16_t* MaybeProcessSamplesLocked(const int16_t* samples, std::size_t sample_count) {
    if (samples == nullptr || sample_count == 0 ||
        (!software_processing_config_.noise_suppression &&
         !software_processing_config_.automatic_gain_control &&
         !software_processing_config_.high_pass_filter)) {
      return samples;
    }

    software_frame_buffer_.resize(sample_count);
    software_output_buffer_.resize(sample_count);

    double sum_squares = 0.0;
    const auto channel_count = std::max<uint32_t>(channel_count_, 1);
    constexpr double high_pass_alpha = 0.985;

    for (std::size_t i = 0; i < sample_count; i++) {
      double value = static_cast<double>(samples[i]) / 32768.0;

      if (software_processing_config_.high_pass_filter) {
        const std::size_t channel_index = i % channel_count;
        const double previous_input = hpf_prev_input_by_channel_[channel_index];
        const double previous_output = hpf_prev_output_by_channel_[channel_index];
        const double filtered = high_pass_alpha * (previous_output + value - previous_input);
        hpf_prev_input_by_channel_[channel_index] = value;
        hpf_prev_output_by_channel_[channel_index] = filtered;
        value = filtered;
      }

      software_frame_buffer_[i] = static_cast<float>(value);
      sum_squares += value * value;
    }

    double rms =
        std::sqrt(sum_squares / static_cast<double>(std::max<std::size_t>(sample_count, 1)));

    if (software_processing_config_.noise_suppression) {
      const double floored_rms = std::max(rms, 0.0025);
      if (floored_rms <= software_noise_floor_rms_ * 1.1) {
        software_noise_floor_rms_ = software_noise_floor_rms_ * 0.98 + floored_rms * 0.02;
      } else {
        software_noise_floor_rms_ = software_noise_floor_rms_ * 0.999 + floored_rms * 0.001;
      }

      const double threshold_multiplier =
          software_processing_config_.strong_isolation ? 3.0 : 2.2;
      const double threshold = std::max(software_noise_floor_rms_ * threshold_multiplier, 0.01);
      double suppression_gain = 1.0;
      if (rms < threshold) {
        const double ratio = threshold <= 0.0 ? 1.0 : rms / threshold;
        const double minimum_gain = software_processing_config_.strong_isolation ? 0.08 : 0.2;
        suppression_gain = std::clamp(ratio, minimum_gain, 1.0);
      }

      if (suppression_gain < 1.0) {
        for (std::size_t i = 0; i < sample_count; i++) {
          software_frame_buffer_[i] *= static_cast<float>(suppression_gain);
        }
        rms *= suppression_gain;
      }
    }

    if (software_processing_config_.automatic_gain_control) {
      const double target_rms = software_processing_config_.strong_isolation ? 0.12 : 0.1;
      const double desired_gain = std::clamp(target_rms / std::max(rms, 0.001), 0.5, 8.0);
      const double smoothing = desired_gain < software_agc_gain_ ? 0.15 : 0.05;
      software_agc_gain_ += (desired_gain - software_agc_gain_) * smoothing;

      for (std::size_t i = 0; i < sample_count; i++) {
        software_frame_buffer_[i] *= static_cast<float>(software_agc_gain_);
      }
    }

    for (std::size_t i = 0; i < sample_count; i++) {
      const double clipped = std::clamp(static_cast<double>(software_frame_buffer_[i]), -1.0, 1.0);
      const int32_t scaled = static_cast<int32_t>(std::lrint(clipped * 32767.0));
      software_output_buffer_[i] = static_cast<int16_t>(std::clamp(scaled, -32768, 32767));
    }

    return software_output_buffer_.data();
  }

  bool StartDeviceLocked(const CaptureDeviceConfig& requested_config, char* error_utf8,
                         uint32_t error_utf8_capacity) {
    const uint32_t sample_rate_hz = requested_config.sample_rate_hz;
    const uint32_t channel_count = requested_config.channel_count;
    const uint32_t preferred_period_frames = requested_config.preferred_period_frames;
    const std::string& effective_device_id = requested_config.input_device_id;

    ma_device_id selected_device_id{};
    ma_device_id* selected_device_id_ptr = nullptr;

    if (!effective_device_id.empty()) {
      ma_context context{};
      ma_device_info* capture_infos = nullptr;
      ma_uint32 capture_count = 0;
      if (!EnumerateCaptureDevices(&context, &capture_infos, &capture_count, error_utf8,
                                   error_utf8_capacity)) {
        return false;
      }

      const bool found = FindCaptureDeviceByHexId(capture_infos, capture_count, effective_device_id,
                                                  &selected_device_id);
      ma_context_uninit(&context);

      if (!found) {
        WriteError("Selected input device is no longer available.", error_utf8,
                   error_utf8_capacity);
        return false;
      }

      selected_device_id_ptr = &selected_device_id;
    } else {
      ma_context context{};
      ma_device_info* capture_infos = nullptr;
      ma_uint32 capture_count = 0;
      if (EnumerateCaptureDevices(&context, &capture_infos, &capture_count, error_utf8,
                                  error_utf8_capacity)) {
        const ma_device_info* default_device =
            FindDefaultCaptureDeviceInfo(capture_infos, capture_count);
        if (default_device != nullptr) {
          selected_device_id = default_device->id;
          selected_device_id_ptr = &selected_device_id;
        }
        ma_context_uninit(&context);
      }

      // Default-device discovery is a best-effort fallback only.
      WriteError("", error_utf8, error_utf8_capacity);
    }

    software_processing_config_ =
        BuildSoftwareVoiceProcessingConfig(requested_config.processing_flags);

    ma_device_config config = ma_device_config_init(ma_device_type_capture);
    config.capture.format = ma_format_s16;
    config.capture.channels = channel_count;
    config.capture.pDeviceID = selected_device_id_ptr;
    config.sampleRate = sample_rate_hz;
    if (preferred_period_frames > 0) {
      config.periodSizeInFrames = preferred_period_frames;
      config.periods = 2;
      config.performanceProfile = ma_performance_profile_low_latency;
    }
    config.dataCallback = DataCallback;
    config.pUserData = this;

    const ma_result init_result = ma_device_init(nullptr, &config, &device_);
    if (init_result != MA_SUCCESS) {
      WriteError(DescribeMiniaudioError("Failed to initialize miniaudio capture device",
                                        init_result),
                 error_utf8, error_utf8_capacity);
      return false;
    }

    const ma_result start_result = ma_device_start(&device_);
    if (start_result != MA_SUCCESS) {
      ma_device_uninit(&device_);
      WriteError(DescribeMiniaudioError("Failed to start miniaudio capture device", start_result),
                 error_utf8, error_utf8_capacity);
      return false;
    }

    device_initialized_ = true;
    sample_rate_hz_ = sample_rate_hz;
    channel_count_ = channel_count;
    data_bytes_written_ = 0;
    current_device_config_ = requested_config;
    ResetSoftwareProcessingStateLocked();
    return true;
  }

  std::mutex mutex_;
  RecorderMode mode_ = RecorderMode::kStopped;
  bool continuous_capture_enabled_ = false;

  ma_device device_{};
  bool device_initialized_ = false;
  CaptureDeviceConfig current_device_config_{};
  CaptureDeviceConfig warm_capture_config_{};

  FILE* file_ = nullptr;
  uint32_t sample_rate_hz_ = 0;
  uint32_t channel_count_ = 0;
  uint32_t data_bytes_written_ = 0;
  double current_amplitude_dbfs_ = -90.0;
  double max_amplitude_dbfs_ = -90.0;
  SoftwareVoiceProcessingConfig software_processing_config_{};
  double software_noise_floor_rms_ = 0.015;
  double software_agc_gain_ = 1.0;
  std::vector<double> hpf_prev_input_by_channel_;
  std::vector<double> hpf_prev_output_by_channel_;
  std::vector<float> software_frame_buffer_;
  std::vector<int16_t> software_output_buffer_;

  std::deque<int16_t> stream_samples_;
  std::size_t stream_sample_limit_ = 0;
};

LinuxAudioRecorderState g_recorder;
}  // namespace

int32_t HasPermission(int32_t* out_has_permission, char* error_utf8, uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  if (out_has_permission == nullptr) {
    WriteError("Permission output pointer is null.", error_utf8, error_utf8_capacity);
    return -1;
  }
  *out_has_permission = 1;
  return 0;
}

int32_t RequestPermission(int32_t* out_has_permission, char* error_utf8,
                          uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  if (out_has_permission == nullptr) {
    WriteError("Permission output pointer is null.", error_utf8, error_utf8_capacity);
    return -1;
  }
  *out_has_permission = 1;
  return 0;
}

int32_t ListInputDevicesJson(char* out_json_utf8, uint32_t out_json_capacity, char* error_utf8,
                             uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.ListInputDevicesJson(out_json_utf8, out_json_capacity, error_utf8,
                                         error_utf8_capacity);
}

int32_t StartFile(const speech_utils::recorder::RecorderStartConfig* start_config,
                  char* error_utf8,
                  uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  if (start_config == nullptr) {
    WriteError("Start config pointer is null.", error_utf8, error_utf8_capacity);
    return -1;
  }
  return g_recorder.StartFile(*start_config, error_utf8, error_utf8_capacity);
}

int32_t StartStream(const speech_utils::recorder::RecorderStartConfig* start_config,
                    char* error_utf8,
                    uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  if (start_config == nullptr) {
    WriteError("Start config pointer is null.", error_utf8, error_utf8_capacity);
    return -1;
  }
  return g_recorder.StartStream(*start_config, error_utf8, error_utf8_capacity);
}

int32_t SetContinousCapture(int32_t enabled,
                            const speech_utils::recorder::RecorderStartConfig* start_config,
                            char* error_utf8,
                            uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.SetContinousCapture(enabled, start_config, error_utf8, error_utf8_capacity);
}

int32_t ReadStreamPcm16(int16_t* out_samples, uint32_t out_sample_capacity,
                        uint32_t* out_samples_written, char* error_utf8,
                        uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.ReadStreamPcm16(out_samples, out_sample_capacity, out_samples_written,
                                    error_utf8, error_utf8_capacity);
}

int32_t Stop(char* error_utf8, uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.Stop(error_utf8, error_utf8_capacity);
}

int32_t Reset(char* error_utf8, uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.Reset(error_utf8, error_utf8_capacity);
}

int32_t IsRecording(int32_t* out_is_recording, char* error_utf8, uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.IsRecording(out_is_recording, error_utf8, error_utf8_capacity);
}

int32_t GetAmplitude(double* out_current_dbfs, double* out_max_dbfs, char* error_utf8,
                     uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.GetAmplitude(out_current_dbfs, out_max_dbfs, error_utf8, error_utf8_capacity);
}

}  // namespace speech_utils::linux_recorder
