#include <windows.h>

#include <algorithm>
#include <cctype>
#include <cstdint>
#include <cstdio>
#include <cmath>
#include <cstring>
#include <deque>
#include <mutex>
#include <string>

#define MINIAUDIO_IMPLEMENTATION
#include "../../third_party/miniaudio/include/miniaudio.h"

namespace {
void WriteError(const std::string& message, char* out_error_utf8, uint32_t out_error_capacity) {
  if (out_error_utf8 == nullptr || out_error_capacity == 0) {
    return;
  }
  const auto copy_length = static_cast<uint32_t>(
      std::min<std::size_t>(message.size(), static_cast<std::size_t>(out_error_capacity - 1)));
  std::memcpy(out_error_utf8, message.data(), copy_length);
  out_error_utf8[copy_length] = '\0';
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

std::wstring Utf8ToWide(const char* utf8) {
  if (utf8 == nullptr) {
    return {};
  }

  const auto required =
      MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, utf8, -1, nullptr, 0);
  if (required <= 0) {
    return {};
  }

  std::wstring wide(static_cast<std::size_t>(required), L'\0');
  const auto converted =
      MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, utf8, -1, wide.data(), required);
  if (converted <= 0) {
    return {};
  }

  if (!wide.empty() && wide.back() == L'\0') {
    wide.pop_back();
  }
  return wide;
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

std::string JsonEscape(const std::string& input) {
  std::string escaped;
  escaped.reserve(input.size() + 8);
  static constexpr char kHexDigits[] = "0123456789abcdef";

  for (unsigned char ch : input) {
    switch (ch) {
      case '"':
        escaped += "\\\"";
        break;
      case '\\':
        escaped += "\\\\";
        break;
      case '\b':
        escaped += "\\b";
        break;
      case '\f':
        escaped += "\\f";
        break;
      case '\n':
        escaped += "\\n";
        break;
      case '\r':
        escaped += "\\r";
        break;
      case '\t':
        escaped += "\\t";
        break;
      default:
        if (ch < 0x20) {
          escaped += "\\u00";
          escaped += kHexDigits[(ch >> 4) & 0x0F];
          escaped += kHexDigits[ch & 0x0F];
        } else {
          escaped.push_back(static_cast<char>(ch));
        }
        break;
    }
  }

  return escaped;
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
    WriteError("Failed to initialize miniaudio context.", error_utf8, error_utf8_capacity);
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
    WriteError("Failed to enumerate miniaudio capture devices.", error_utf8,
               error_utf8_capacity);
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

std::string BuildInputDevicesJson(const ma_device_info* capture_infos, ma_uint32 capture_count) {
  std::string json = "[";
  for (ma_uint32 i = 0; i < capture_count; i++) {
    if (i > 0) {
      json += ',';
    }

    const auto& info = capture_infos[i];
    const std::string device_id = DeviceIdToHex(info.id);
    const std::string label = std::string(info.name);

    json += "{\"id\":\"";
    json += JsonEscape(device_id);
    json += "\",\"label\":\"";
    json += JsonEscape(label);
    json += "\",\"isDefault\":";
    json += info.isDefault ? "true" : "false";
    json += '}';
  }
  json += ']';
  return json;
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

enum class RecorderMode { kStopped, kFile, kStream };

class WindowsAudioRecorderState {
 public:
  WindowsAudioRecorderState() = default;

  ~WindowsAudioRecorderState() {
    char error[1] = {0};
    Stop(error, sizeof(error));
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

  int32_t StartFile(const char* output_path_utf8, uint32_t sample_rate_hz, uint32_t channel_count,
                    const char* input_device_id_utf8, char* error_utf8,
                    uint32_t error_utf8_capacity) {
    if (output_path_utf8 == nullptr) {
      WriteError("Output path is null.", error_utf8, error_utf8_capacity);
      return -1;
    }
    if (sample_rate_hz == 0 || channel_count == 0) {
      WriteError("Sample rate and channel count must be > 0.", error_utf8, error_utf8_capacity);
      return -2;
    }

    const auto output_path = Utf8ToWide(output_path_utf8);
    if (output_path.empty()) {
      WriteError("Output path UTF-8 decoding failed.", error_utf8, error_utf8_capacity);
      return -3;
    }

    std::lock_guard<std::mutex> lock(mutex_);
    if (mode_ != RecorderMode::kStopped) {
      WriteError("Recorder is already running.", error_utf8, error_utf8_capacity);
      return -4;
    }

    FILE* file = _wfopen(output_path.c_str(), L"wb");
    if (file == nullptr) {
      WriteError("Failed to open output file for writing.", error_utf8, error_utf8_capacity);
      return -5;
    }

    if (!WriteInitialWavHeader(file, sample_rate_hz, channel_count)) {
      std::fclose(file);
      WriteError("Failed to write WAV header.", error_utf8, error_utf8_capacity);
      return -6;
    }

    if (!StartDeviceLocked(sample_rate_hz, channel_count, input_device_id_utf8, error_utf8,
                           error_utf8_capacity)) {
      std::fclose(file);
      return -7;
    }

    file_ = file;
    sample_rate_hz_ = sample_rate_hz;
    channel_count_ = channel_count;
    data_bytes_written_ = 0;
    current_amplitude_dbfs_ = -90.0;
    max_amplitude_dbfs_ = -90.0;
    mode_ = RecorderMode::kFile;
    return 0;
  }

  int32_t StartStream(uint32_t sample_rate_hz, uint32_t channel_count, uint32_t frames_per_chunk,
                      const char* input_device_id_utf8, char* error_utf8,
                      uint32_t error_utf8_capacity) {
    if (sample_rate_hz == 0 || channel_count == 0 || frames_per_chunk == 0) {
      WriteError("Sample rate, channel count and frames_per_chunk must be > 0.", error_utf8,
                 error_utf8_capacity);
      return -1;
    }

    std::lock_guard<std::mutex> lock(mutex_);
    if (mode_ != RecorderMode::kStopped) {
      WriteError("Recorder is already running.", error_utf8, error_utf8_capacity);
      return -2;
    }

    if (!StartDeviceLocked(sample_rate_hz, channel_count, input_device_id_utf8, error_utf8,
                           error_utf8_capacity)) {
      return -3;
    }

    stream_samples_.clear();
    stream_sample_limit_ =
        std::max<std::size_t>(sample_rate_hz * channel_count * 5,
                              static_cast<std::size_t>(frames_per_chunk) * channel_count * 16);
    current_amplitude_dbfs_ = -90.0;
    max_amplitude_dbfs_ = -90.0;
    mode_ = RecorderMode::kStream;
    return 0;
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
    std::lock_guard<std::mutex> lock(mutex_);
    if (mode_ == RecorderMode::kStopped) {
      return 0;
    }

    if (device_initialized_) {
      ma_device_stop(&device_);
      ma_device_uninit(&device_);
      device_initialized_ = false;
    }

    if (file_ != nullptr) {
      if (!FinalizeWavHeader(file_, data_bytes_written_, sample_rate_hz_, channel_count_)) {
        WriteError("Failed to finalize WAV header.", error_utf8, error_utf8_capacity);
        std::fclose(file_);
        file_ = nullptr;
        mode_ = RecorderMode::kStopped;
        stream_samples_.clear();
        stream_sample_limit_ = 0;
        return -1;
      }
      std::fclose(file_);
      file_ = nullptr;
    }

    mode_ = RecorderMode::kStopped;
    stream_samples_.clear();
    stream_sample_limit_ = 0;
    data_bytes_written_ = 0;
    sample_rate_hz_ = 0;
    channel_count_ = 0;
    current_amplitude_dbfs_ = -90.0;
    max_amplitude_dbfs_ = -90.0;
    return 0;
  }

  int32_t IsRecording(int32_t* out_is_recording, char* error_utf8,
                      uint32_t error_utf8_capacity) {
    if (out_is_recording == nullptr) {
      WriteError("State output pointer is null.", error_utf8, error_utf8_capacity);
      return -1;
    }

    std::lock_guard<std::mutex> lock(mutex_);
    *out_is_recording = mode_ == RecorderMode::kStopped ? 0 : 1;
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
    UpdateAmplitudeLocked(samples, sample_count);

    if (mode_ == RecorderMode::kFile && file_ != nullptr) {
      const auto written = std::fwrite(samples, sizeof(int16_t), sample_count, file_);
      if (written == sample_count) {
        data_bytes_written_ += static_cast<uint32_t>(written * sizeof(int16_t));
      }
      return;
    }

    if (mode_ == RecorderMode::kStream) {
      stream_samples_.insert(stream_samples_.end(), samples, samples + sample_count);
      if (stream_samples_.size() > stream_sample_limit_) {
        const auto overflow = stream_samples_.size() - stream_sample_limit_;
        stream_samples_.erase(stream_samples_.begin(), stream_samples_.begin() + overflow);
      }
    }
  }

 private:
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

    auto* self = reinterpret_cast<WindowsAudioRecorderState*>(device->pUserData);
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

  bool StartDeviceLocked(uint32_t sample_rate_hz, uint32_t channel_count,
                         const char* input_device_id_utf8, char* error_utf8,
                         uint32_t error_utf8_capacity) {
    const std::string effective_device_id = TrimAscii(input_device_id_utf8);

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
    }

    ma_device_config config = ma_device_config_init(ma_device_type_capture);
    config.capture.format = ma_format_s16;
    config.capture.channels = channel_count;
    config.capture.pDeviceID = selected_device_id_ptr;
    config.sampleRate = sample_rate_hz;
    config.dataCallback = DataCallback;
    config.pUserData = this;

    const ma_result init_result = ma_device_init(nullptr, &config, &device_);
    if (init_result != MA_SUCCESS) {
      WriteError("Failed to initialize miniaudio capture device.", error_utf8,
                 error_utf8_capacity);
      return false;
    }

    const ma_result start_result = ma_device_start(&device_);
    if (start_result != MA_SUCCESS) {
      ma_device_uninit(&device_);
      WriteError("Failed to start miniaudio capture device.", error_utf8, error_utf8_capacity);
      return false;
    }

    device_initialized_ = true;
    sample_rate_hz_ = sample_rate_hz;
    channel_count_ = channel_count;
    data_bytes_written_ = 0;
    return true;
  }

  std::mutex mutex_;
  RecorderMode mode_ = RecorderMode::kStopped;

  ma_device device_{};
  bool device_initialized_ = false;

  FILE* file_ = nullptr;
  uint32_t sample_rate_hz_ = 0;
  uint32_t channel_count_ = 0;
  uint32_t data_bytes_written_ = 0;
  double current_amplitude_dbfs_ = -90.0;
  double max_amplitude_dbfs_ = -90.0;

  std::deque<int16_t> stream_samples_;
  std::size_t stream_sample_limit_ = 0;
};

WindowsAudioRecorderState g_recorder;
}  // namespace

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_healthcheck(char* error_utf8, uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return 0;
}

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_has_permission(int32_t* out_has_permission, char* error_utf8,
                                                   uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  if (out_has_permission == nullptr) {
    WriteError("Permission output pointer is null.", error_utf8, error_utf8_capacity);
    return -1;
  }
  *out_has_permission = 1;
  return 0;
}

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_request_permission(int32_t* out_has_permission,
                                                       char* error_utf8,
                                                       uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  if (out_has_permission == nullptr) {
    WriteError("Permission output pointer is null.", error_utf8, error_utf8_capacity);
    return -1;
  }
  *out_has_permission = 1;
  return 0;
}

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_list_input_devices_json(char* out_json_utf8,
                                                            uint32_t out_json_capacity,
                                                            char* error_utf8,
                                                            uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.ListInputDevicesJson(out_json_utf8, out_json_capacity, error_utf8,
                                         error_utf8_capacity);
}

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_start_file(const char* output_path_utf8, uint32_t sample_rate_hz,
                                               uint32_t channel_count,
                                               const char* input_device_id_utf8,
                                               char* error_utf8,
                                               uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.StartFile(output_path_utf8, sample_rate_hz, channel_count, input_device_id_utf8,
                              error_utf8, error_utf8_capacity);
}

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_start_stream(uint32_t sample_rate_hz, uint32_t channel_count,
                                                 uint32_t frames_per_chunk,
                                                 const char* input_device_id_utf8,
                                                 char* error_utf8,
                                                 uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.StartStream(sample_rate_hz, channel_count, frames_per_chunk,
                                input_device_id_utf8, error_utf8, error_utf8_capacity);
}

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_read_stream_pcm16(int16_t* out_samples,
                                                       uint32_t out_sample_capacity,
                                                       uint32_t* out_samples_written,
                                                       char* error_utf8,
                                                       uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.ReadStreamPcm16(out_samples, out_sample_capacity, out_samples_written,
                                    error_utf8, error_utf8_capacity);
}

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_stop(char* error_utf8, uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.Stop(error_utf8, error_utf8_capacity);
}

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_is_recording(int32_t* out_is_recording, char* error_utf8,
                                                 uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.IsRecording(out_is_recording, error_utf8, error_utf8_capacity);
}

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_get_amplitude(double* out_current_dbfs, double* out_max_dbfs,
                                                  char* error_utf8,
                                                  uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.GetAmplitude(out_current_dbfs, out_max_dbfs, error_utf8,
                                 error_utf8_capacity);
}
