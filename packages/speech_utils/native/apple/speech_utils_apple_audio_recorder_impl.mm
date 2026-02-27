#import <TargetConditionals.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <dispatch/dispatch.h>

#include <algorithm>
#include <atomic>
#include <cctype>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <deque>
#include <limits>
#include <memory>
#include <mutex>
#include <string>
#include <vector>

#include "speech_utils_apple_audio_codec.h"
#include "speech_utils_apple_audio_recorder_api.h"
#include "speech_utils_apple_audio_recorder_common.h"
#include "speech_utils_apple_audio_recorder_wav.h"

#include "../ios/speech_utils_ios_audio_recorder_session.h"
#include "../macos/speech_utils_macos_audio_recorder_devices.h"

namespace speech_utils::apple_recorder {

namespace {

enum class RecorderMode { kStopped, kFile, kStream };

enum class FileSink { kNone, kWav, kPcm16, kAacM4A };

constexpr const char* kRecorderProcessingQueueLabel = "speech_utils.apple_recorder.processing";

bool WriteJsonArray(NSArray<NSDictionary<NSString*, id>*>* payload, char* out_json_utf8,
                    uint32_t out_json_capacity, char* error_utf8,
                    uint32_t error_utf8_capacity) {
  if (out_json_utf8 == nullptr || out_json_capacity == 0) {
    WriteError("Output buffer is null.", error_utf8, error_utf8_capacity);
    return false;
  }

  NSError* json_error = nil;
  NSData* json_data = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&json_error];
  if (json_data == nil) {
    WriteNSError(json_error, "Failed to encode input device list", error_utf8,
                 error_utf8_capacity);
    return false;
  }

  if (json_data.length + 1 > out_json_capacity) {
    WriteError("Output buffer is too small.", error_utf8, error_utf8_capacity);
    return false;
  }

  std::memcpy(out_json_utf8, json_data.bytes, json_data.length);
  out_json_utf8[json_data.length] = '\0';
  return true;
}

FileSink ResolveFileSinkFromPath(NSString* output_path) {
  NSString* extension = output_path.pathExtension.lowercaseString;
  if ([extension isEqualToString:@"m4a"]) {
    return FileSink::kAacM4A;
  }
  if ([extension isEqualToString:@"pcm"]) {
    return FileSink::kPcm16;
  }
  return FileSink::kWav;
}

bool FormatsMatchPcm16(AVAudioFormat* input, AVAudioFormat* target) {
  if (input == nil || target == nil) {
    return false;
  }
  if (input.commonFormat != AVAudioPCMFormatInt16 ||
      target.commonFormat != AVAudioPCMFormatInt16) {
    return false;
  }
  if (input.channelCount != target.channelCount) {
    return false;
  }
  return std::abs(input.sampleRate - target.sampleRate) < 0.5;
}

AVAudioPCMBuffer* ConvertToTargetPcm16(AVAudioPCMBuffer* input_buffer, AVAudioFormat* target_format,
                                       AVAudioConverter* converter) {
  if (input_buffer == nil || target_format == nil) {
    return nil;
  }
  if (FormatsMatchPcm16(input_buffer.format, target_format)) {
    return input_buffer;
  }

  if (converter == nil) {
    return nil;
  }

  const double source_rate = input_buffer.format.sampleRate;
  const double target_rate = target_format.sampleRate;
  const double ratio = source_rate > 0.0 ? target_rate / source_rate : 1.0;

  const auto estimated_capacity = static_cast<AVAudioFrameCount>(
      std::max<double>(64.0, std::ceil(static_cast<double>(input_buffer.frameLength) * ratio) + 8.0));

  AVAudioPCMBuffer* converted =
      [[AVAudioPCMBuffer alloc] initWithPCMFormat:target_format frameCapacity:estimated_capacity];
  if (converted == nil) {
    return nil;
  }

  NSError* convert_error = nil;
  AVAudioConverterOutputStatus status =
      [converter convertToBuffer:converted
                           error:&convert_error
                withInputFromBlock:^AVAudioBuffer*(AVAudioPacketCount in_packets,
                                                   AVAudioConverterInputStatus* out_status) {
                  (void)in_packets;
                  *out_status = AVAudioConverterInputStatus_HaveData;
                  return input_buffer;
                }];

  if (status == AVAudioConverterOutputStatus_Error || convert_error != nil) {
    return nil;
  }

  return converted;
}

std::string TrimWhitespace(const std::string& input) {
  const auto is_space = [](unsigned char c) { return std::isspace(c) != 0; };

  const auto begin = std::find_if_not(input.begin(), input.end(), [&](char c) {
    return is_space(static_cast<unsigned char>(c));
  });
  if (begin == input.end()) {
    return {};
  }

  const auto end = std::find_if_not(input.rbegin(), input.rend(), [&](char c) {
                     return is_space(static_cast<unsigned char>(c));
                   }).base();
  return std::string(begin, end);
}

class AppleAudioEngineRecorder {
 public:
  AppleAudioEngineRecorder() {
    processing_queue_ = dispatch_queue_create(kRecorderProcessingQueueLabel, DISPATCH_QUEUE_SERIAL);
  }

  ~AppleAudioEngineRecorder() {
    char sink[1] = {0};
    (void)Stop(sink, sizeof(sink));
  }

  int32_t ListInputDevices(char* out_json_utf8, uint32_t out_json_capacity, char* error_utf8,
                           uint32_t error_utf8_capacity) {
    NSMutableArray<NSDictionary<NSString*, id>*>* devices = [NSMutableArray array];

#if TARGET_OS_IPHONE
    AVAudioSession* session = AVAudioSession.sharedInstance;
    AVAudioSessionPortDescription* default_input = session.currentRoute.inputs.firstObject;

    NSString* default_uid = default_input.UID;
    NSString* default_label = default_input.portName;

    for (AVAudioSessionPortDescription* input in session.availableInputs) {
      if (input.UID.length == 0) {
        continue;
      }
      const BOOL is_default = default_uid != nil && [default_uid isEqualToString:input.UID];
      [devices addObject:@{
        @"id" : input.UID,
        @"label" : (input.portName.length > 0 ? input.portName : input.UID),
        @"isDefault" : @(is_default),
      }];
    }

    if (devices.count == 0 && default_uid.length > 0) {
      [devices addObject:@{
        @"id" : default_uid,
        @"label" : (default_label.length > 0 ? default_label : default_uid),
        @"isDefault" : @YES,
      }];
    }
#else
    AVCaptureDevice* default_device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSString* default_uid = default_device.uniqueID;

    AVCaptureDeviceDiscoverySession* discovery =
        [AVCaptureDeviceDiscoverySession
            discoverySessionWithDeviceTypes:@[ AVCaptureDeviceTypeBuiltInMicrophone,
                                               AVCaptureDeviceTypeExternalUnknown ]
                                  mediaType:AVMediaTypeAudio
                                   position:AVCaptureDevicePositionUnspecified];

    for (AVCaptureDevice* device in discovery.devices) {
      if (device.uniqueID.length == 0) {
        continue;
      }
      const BOOL is_default = default_uid != nil && [default_uid isEqualToString:device.uniqueID];
      [devices addObject:@{
        @"id" : device.uniqueID,
        @"label" : (device.localizedName.length > 0 ? device.localizedName : device.uniqueID),
        @"isDefault" : @(is_default),
      }];
    }

    if (devices.count == 0 && default_uid.length > 0) {
      [devices addObject:@{
        @"id" : default_uid,
        @"label" : (default_device.localizedName.length > 0 ? default_device.localizedName : default_uid),
        @"isDefault" : @YES,
      }];
    }
#endif

    if (!WriteJsonArray(devices, out_json_utf8, out_json_capacity, error_utf8,
                        error_utf8_capacity)) {
      return -1;
    }

    return 0;
  }

  int32_t StartFile(const speech_utils::recorder::RecorderStartConfig& config, char* error_utf8,
                    uint32_t error_utf8_capacity) {
    if (config.output_path_utf8 == nullptr || config.output_path_utf8[0] == '\0') {
      WriteError("Output path is null or empty.", error_utf8, error_utf8_capacity);
      return -1;
    }
    if (config.sample_rate_hz == 0 || config.channel_count == 0) {
      WriteError("Sample rate and channel count must be > 0.", error_utf8, error_utf8_capacity);
      return -2;
    }

    NSString* output_path = [NSString stringWithUTF8String:config.output_path_utf8];
    if (output_path.length == 0) {
      WriteError("Output path UTF-8 decoding failed.", error_utf8, error_utf8_capacity);
      return -3;
    }

    const FileSink sink = ResolveFileSinkFromPath(output_path);

    return StartInternal(config, /*frames_per_chunk=*/1024, RecorderMode::kFile, sink,
                         output_path, error_utf8, error_utf8_capacity);
  }

  int32_t StartStream(const speech_utils::recorder::RecorderStartConfig& config,
                      char* error_utf8, uint32_t error_utf8_capacity) {
    if (config.sample_rate_hz == 0 || config.channel_count == 0 || config.frames_per_chunk == 0) {
      WriteError("Sample rate, channel count, and frames_per_chunk must be > 0.", error_utf8,
                 error_utf8_capacity);
      return -1;
    }

    return StartInternal(config, config.frames_per_chunk, RecorderMode::kStream, FileSink::kNone,
                         nil, error_utf8, error_utf8_capacity);
  }

  int32_t ReadStream(int16_t* out_samples, uint32_t out_sample_capacity,
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

    const uint32_t readable = static_cast<uint32_t>(
        std::min<std::size_t>(stream_samples_.size(), static_cast<std::size_t>(out_sample_capacity)));

    for (uint32_t i = 0; i < readable; i++) {
      out_samples[i] = stream_samples_.front();
      stream_samples_.pop_front();
    }
    *out_samples_written = readable;

    return 0;
  }

  int32_t Stop(char* error_utf8, uint32_t error_utf8_capacity) {
    AVAudioEngine* audio_engine = nil;
    AVAudioInputNode* input_node = nil;
    FileSink file_sink = FileSink::kNone;

    FILE* pcm_file = nullptr;
    uint32_t wav_data_bytes = 0;
    uint32_t sample_rate_hz = 0;
    uint32_t channel_count = 0;
    uint32_t aac_bitrate_bps = 0;
    std::string aac_capture_wav_path;
    std::string output_path_utf8;

    int32_t deferred_code = 0;
    std::string deferred_error;
    uint64_t processed_sample_count = 0;

    {
      std::lock_guard<std::mutex> lock(mutex_);
      if (mode_ == RecorderMode::kStopped) {
        return 0;
      }

      audio_engine = audio_engine_;
      input_node = input_node_;
      accepting_samples_.store(false, std::memory_order_release);
    }

    if (input_node != nil) {
      [input_node removeTapOnBus:0];
      if (@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)) {
        (void)[input_node setVoiceProcessingEnabled:NO error:nil];
      }
    }
    if (audio_engine != nil) {
      [audio_engine stop];
    }

    if (processing_queue_ != nullptr) {
      dispatch_sync(processing_queue_, ^{});
    }

    {
      std::lock_guard<std::mutex> lock(mutex_);
      mode_ = RecorderMode::kStopped;
      stream_samples_.clear();
      stream_sample_limit_ = 0;
      pending_samples_.store(0, std::memory_order_release);
      pending_sample_limit_.store(0, std::memory_order_release);
      processed_sample_count = processed_sample_count_.load(std::memory_order_acquire);

      file_sink = file_sink_;

      pcm_file = pcm_file_;
      wav_data_bytes = wav_data_bytes_;
      sample_rate_hz = sample_rate_hz_;
      channel_count = channel_count_;
      aac_bitrate_bps = aac_bitrate_bps_;
      aac_capture_wav_path = aac_capture_wav_path_utf8_;
      output_path_utf8 = output_path_utf8_;

      deferred_code = deferred_error_code_;
      deferred_error = deferred_error_;

      audio_engine_ = nil;
      input_node_ = nil;
      pcm_converter_ = nil;
      target_format_ = nil;
      file_sink_ = FileSink::kNone;
      pcm_file_ = nullptr;
      wav_data_bytes_ = 0;
      sample_rate_hz_ = 0;
      channel_count_ = 0;
      aac_capture_wav_path_utf8_.clear();
      output_path_utf8_.clear();
      aac_bitrate_bps_ = 0;
      current_dbfs_ = -90.0;
      max_dbfs_ = -90.0;
      deferred_error_code_ = 0;
      deferred_error_.clear();
    }

    if (processed_sample_count == 0 && deferred_code == 0) {
      deferred_code = -41;
      deferred_error = "Recorder stopped without capturing any microphone samples.";
    }

    if ((file_sink == FileSink::kWav || file_sink == FileSink::kPcm16 ||
         file_sink == FileSink::kAacM4A) &&
        pcm_file != nullptr) {
      if (file_sink == FileSink::kWav || file_sink == FileSink::kAacM4A) {
        uint32_t data_bytes_for_header = wav_data_bytes;
        std::fflush(pcm_file);
        if (std::fseek(pcm_file, 0, SEEK_END) == 0) {
          const long total_size = std::ftell(pcm_file);
          if (total_size >= 44) {
            const uint64_t computed = static_cast<uint64_t>(total_size - 44);
            data_bytes_for_header = static_cast<uint32_t>(
                std::min<uint64_t>(computed, std::numeric_limits<uint32_t>::max()));
          }
        }
        (void)FinalizeWavHeader(pcm_file, data_bytes_for_header, sample_rate_hz, channel_count);
      }
      std::fclose(pcm_file);
    }

    if (file_sink == FileSink::kAacM4A && deferred_code == 0) {
      if (aac_capture_wav_path.empty() || output_path_utf8.empty()) {
        deferred_code = -33;
        deferred_error = "AAC capture paths are unavailable.";
      } else {
        char encode_error[1024] = {0};
        const int32_t encode_status = speech_utils::apple_audio_codec::EncodeAudioFileToAac(
            aac_capture_wav_path.c_str(), output_path_utf8.c_str(),
            ResolveAppleAacBitrate(aac_bitrate_bps), /*use_source_format_hint=*/true,
            "Apple recorder stop", encode_error, sizeof(encode_error));
        if (encode_status != 0) {
          deferred_code = -33;
          deferred_error = std::string("Failed to write AAC frames");
          if (encode_error[0] != '\0') {
            deferred_error.append(": ");
            deferred_error.append(encode_error);
          }
        }
      }
    }

    if (!aac_capture_wav_path.empty()) {
      NSString* capture_path = [NSString stringWithUTF8String:aac_capture_wav_path.c_str()];
      if (capture_path.length > 0 &&
          [NSFileManager.defaultManager fileExistsAtPath:capture_path]) {
        (void)[NSFileManager.defaultManager removeItemAtPath:capture_path error:nil];
      }
    }

#if TARGET_OS_IPHONE
    [AVAudioSession.sharedInstance setActive:NO error:nil];
#endif

    if (deferred_code != 0) {
      WriteError(deferred_error, error_utf8, error_utf8_capacity);
      return deferred_code;
    }

    return 0;
  }

  int32_t Reset(char* error_utf8, uint32_t error_utf8_capacity) {
    char sink[1] = {0};
    (void)error_utf8;
    (void)error_utf8_capacity;
    (void)Stop(sink, sizeof(sink));
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
    *out_current_dbfs = current_dbfs_;
    *out_max_dbfs = max_dbfs_;
    return 0;
  }

  private:
  int32_t StartInternal(const speech_utils::recorder::RecorderStartConfig& config,
                        uint32_t frames_per_chunk, RecorderMode mode, FileSink sink,
                        NSString* output_path, char* error_utf8,
                        uint32_t error_utf8_capacity) {
    int32_t has_permission = 0;
    if (!EnsureMicrophonePermission(&has_permission, false, error_utf8, error_utf8_capacity)) {
      return -4;
    }
    if (has_permission == 0) {
      WriteError("Microphone permission not granted.", error_utf8, error_utf8_capacity);
      return -5;
    }

    {
      std::lock_guard<std::mutex> lock(mutex_);
      if (mode_ != RecorderMode::kStopped) {
        WriteError("Recorder is already running.", error_utf8, error_utf8_capacity);
        return -6;
      }
    }
    accepting_samples_.store(false, std::memory_order_release);
    pending_samples_.store(0, std::memory_order_release);
    pending_sample_limit_.store(0, std::memory_order_release);

    const std::string trimmed_device_id = TrimWhitespace(TrimAscii(config.input_device_id_utf8));

#if TARGET_OS_IPHONE
    if (!ConfigureIosRecorderSession(
            config.sample_rate_hz, config.runtime.processing_flags,
            config.runtime.apple_session_mode_code, config.runtime.apple_category_options_flags,
            config.runtime.preferred_latency_seconds,
            config.runtime.apple_preferred_io_buffer_duration_seconds,
            config.runtime.apple_preferred_input_gain, error_utf8, error_utf8_capacity)) {
      return -7;
    }

    NSString* input_uid = nil;
    if (!trimmed_device_id.empty()) {
      input_uid = [NSString stringWithUTF8String:trimmed_device_id.c_str()];
      if (input_uid == nil || input_uid.length == 0) {
        WriteError("Input device id UTF-8 decoding failed.", error_utf8, error_utf8_capacity);
        return -8;
      }
    }

    if (!SelectIosInputDeviceByUid(input_uid, error_utf8, error_utf8_capacity)) {
      return -9;
    }
#endif

    AVAudioFormat* target_format =
        [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt16
                                          sampleRate:static_cast<double>(config.sample_rate_hz)
                                            channels:config.channel_count
                                         interleaved:NO];
    if (target_format == nil) {
      WriteError("Failed to create target PCM16 format.", error_utf8, error_utf8_capacity);
      return -10;
    }

    FILE* pcm_file = nullptr;
    uint32_t wav_data_bytes = 0;
    std::string output_path_utf8;
    std::string aac_capture_wav_path_utf8;
    uint32_t aac_bitrate_bps = 0;

    auto CleanupAacCaptureWav = [&aac_capture_wav_path_utf8]() {
      if (aac_capture_wav_path_utf8.empty()) {
        return;
      }
      NSString* capture_path = [NSString stringWithUTF8String:aac_capture_wav_path_utf8.c_str()];
      if (capture_path.length > 0 &&
          [NSFileManager.defaultManager fileExistsAtPath:capture_path]) {
        (void)[NSFileManager.defaultManager removeItemAtPath:capture_path error:nil];
      }
    };

    if (mode == RecorderMode::kFile) {
      if (output_path == nil || output_path.length == 0) {
        WriteError("Output path is missing.", error_utf8, error_utf8_capacity);
        return -11;
      }

      NSFileManager* fs = NSFileManager.defaultManager;
      if ([fs fileExistsAtPath:output_path]) {
        NSError* remove_error = nil;
        if (![fs removeItemAtPath:output_path error:&remove_error]) {
          WriteNSError(remove_error, "Failed to remove existing output file", error_utf8,
                       error_utf8_capacity);
          return -12;
        }
      }

      if (sink == FileSink::kWav || sink == FileSink::kPcm16) {
        const char* path_fs = output_path.fileSystemRepresentation;
        if (path_fs == nullptr || path_fs[0] == '\0') {
          WriteError("Output path cannot be represented as a file-system path.", error_utf8,
                     error_utf8_capacity);
          return -13;
        }

        pcm_file = std::fopen(path_fs, "wb");
        if (pcm_file == nullptr) {
          WriteError("Failed to open output file.", error_utf8, error_utf8_capacity);
          return -14;
        }

        if (sink == FileSink::kWav &&
            !WriteWavHeaderPlaceholder(pcm_file, config.sample_rate_hz, config.channel_count)) {
          std::fclose(pcm_file);
          WriteError("Failed to write WAV header.", error_utf8, error_utf8_capacity);
          return -15;
        }
      } else if (sink == FileSink::kAacM4A) {
        const char* output_utf8 = [output_path UTF8String];
        if (output_utf8 == nullptr || output_utf8[0] == '\0') {
          WriteError("Output path UTF-8 decoding failed.", error_utf8, error_utf8_capacity);
          return -16;
        }
        output_path_utf8 = output_utf8;

        NSString* capture_filename =
            [NSString stringWithFormat:@"speech_utils_capture_%@.wav", NSUUID.UUID.UUIDString];
        NSString* capture_path = [NSTemporaryDirectory() stringByAppendingPathComponent:capture_filename];
        const char* capture_utf8 = [capture_path UTF8String];
        if (capture_utf8 == nullptr || capture_utf8[0] == '\0') {
          WriteError("Failed to create temporary AAC capture path.", error_utf8,
                     error_utf8_capacity);
          return -17;
        }
        aac_capture_wav_path_utf8 = capture_utf8;

        const char* capture_path_fs = capture_path.fileSystemRepresentation;
        if (capture_path_fs == nullptr || capture_path_fs[0] == '\0') {
          CleanupAacCaptureWav();
          WriteError("Temporary capture path is not file-system representable.", error_utf8,
                     error_utf8_capacity);
          return -18;
        }

        pcm_file = std::fopen(capture_path_fs, "wb");
        if (pcm_file == nullptr) {
          CleanupAacCaptureWav();
          WriteError("Failed to open temporary AAC capture file.", error_utf8,
                     error_utf8_capacity);
          return -19;
        }

        if (!WriteWavHeaderPlaceholder(pcm_file, config.sample_rate_hz, config.channel_count)) {
          std::fclose(pcm_file);
          pcm_file = nullptr;
          CleanupAacCaptureWav();
          WriteError("Failed to write temporary WAV header for AAC capture.", error_utf8,
                     error_utf8_capacity);
          return -20;
        }

        aac_bitrate_bps = ResolveAppleAacBitrate(config.runtime.apple_file_bitrate_bps);
      }
    }

    AVAudioEngine* audio_engine = [[AVAudioEngine alloc] init];
    if (audio_engine == nil) {
      if (pcm_file != nullptr) {
        std::fclose(pcm_file);
      }
      CleanupAacCaptureWav();
      WriteError("Failed to initialize AVAudioEngine.", error_utf8, error_utf8_capacity);
      return -21;
    }

    AVAudioInputNode* input_node = audio_engine.inputNode;
    if (input_node == nil) {
      if (pcm_file != nullptr) {
        std::fclose(pcm_file);
      }
      CleanupAacCaptureWav();
      WriteError("AVAudioEngine input node is unavailable.", error_utf8, error_utf8_capacity);
      return -22;
    }

#if !TARGET_OS_IPHONE
    NSString* requested_uid = nil;
    if (!trimmed_device_id.empty()) {
      requested_uid = [NSString stringWithUTF8String:trimmed_device_id.c_str()];
      if (requested_uid == nil || requested_uid.length == 0) {
        if (pcm_file != nullptr) {
          std::fclose(pcm_file);
        }
        CleanupAacCaptureWav();
        WriteError("Input device id UTF-8 decoding failed.", error_utf8, error_utf8_capacity);
        return -23;
      }
    }

    if (!SetMacosInputDevice(input_node, requested_uid, error_utf8, error_utf8_capacity)) {
      if (pcm_file != nullptr) {
        std::fclose(pcm_file);
      }
      CleanupAacCaptureWav();
      return -24;
    }
#endif

    const bool voice_processing_requested =
        mode == RecorderMode::kStream &&
        RequiresVoiceProcessing(config.runtime.processing_flags);
    if (voice_processing_requested) {
      if (@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)) {
        NSError* voice_error = nil;
        if (![input_node setVoiceProcessingEnabled:YES error:&voice_error]) {
          if (pcm_file != nullptr) {
            std::fclose(pcm_file);
          }
          CleanupAacCaptureWav();
          WriteNSError(voice_error, "Failed to enable AVAudioEngine voice processing",
                       error_utf8, error_utf8_capacity);
          return -25;
        }
        input_node.voiceProcessingAGCEnabled =
            (config.runtime.processing_flags & kProcessingFlagAutomaticGainControl) != 0;
      } else {
        if (pcm_file != nullptr) {
          std::fclose(pcm_file);
        }
        CleanupAacCaptureWav();
        WriteError("Voice processing requires iOS 13.0/macOS 10.15 or newer.", error_utf8,
                   error_utf8_capacity);
        return -26;
      }
    }

    AVAudioFormat* input_format = [input_node inputFormatForBus:0];
    if (input_format == nil || input_format.sampleRate <= 0.0 || input_format.channelCount == 0) {
      input_format = [input_node outputFormatForBus:0];
    }
    if (input_format == nil) {
      if (pcm_file != nullptr) {
        std::fclose(pcm_file);
      }
      CleanupAacCaptureWav();
      WriteError("Failed to resolve AVAudioEngine input format.", error_utf8, error_utf8_capacity);
      return -27;
    }

    AVAudioConverter* pcm_converter = nil;
    if (!FormatsMatchPcm16(input_format, target_format)) {
      pcm_converter = [[AVAudioConverter alloc] initFromFormat:input_format toFormat:target_format];
      if (pcm_converter == nil) {
        if (pcm_file != nullptr) {
          std::fclose(pcm_file);
        }
        CleanupAacCaptureWav();
        WriteError("Failed to initialize AVAudioConverter for recorder PCM pipeline.", error_utf8,
                   error_utf8_capacity);
        return -28;
      }
      pcm_converter.sampleRateConverterQuality = AVAudioQualityHigh;
#if TARGET_OS_IPHONE
      if (@available(iOS 13.0, *)) {
        pcm_converter.primeMethod = AVAudioConverterPrimeMethod_None;
      }
#else
      if (@available(macOS 10.15, *)) {
        pcm_converter.primeMethod = AVAudioConverterPrimeMethod_None;
      }
#endif
    }

    const AVAudioFrameCount tap_frames =
        static_cast<AVAudioFrameCount>(std::max<uint32_t>(frames_per_chunk, 64));

    AppleAudioEngineRecorder* callback_self = this;
    [input_node removeTapOnBus:0];
    [input_node installTapOnBus:0
                     bufferSize:tap_frames
                         format:input_format
                          block:^(AVAudioPCMBuffer* buffer, AVAudioTime* when) {
                            (void)when;
                            if (callback_self == nullptr || buffer == nil) {
                              return;
                            }
                            callback_self->HandleInputBuffer(buffer);
                          }];

    [audio_engine prepare];
    NSError* start_error = nil;
    if (![audio_engine startAndReturnError:&start_error]) {
      [input_node removeTapOnBus:0];
      if (@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)) {
        (void)[input_node setVoiceProcessingEnabled:NO error:nil];
      }
      if (pcm_file != nullptr) {
        std::fclose(pcm_file);
      }
      CleanupAacCaptureWav();
#if TARGET_OS_IPHONE
      [AVAudioSession.sharedInstance setActive:NO error:nil];
#endif
      WriteNSError(start_error, "Failed to start AVAudioEngine", error_utf8,
                   error_utf8_capacity);
      return -29;
    }

    {
      std::lock_guard<std::mutex> lock(mutex_);
      mode_ = mode;
      file_sink_ = sink;
      audio_engine_ = audio_engine;
      input_node_ = input_node;
      pcm_converter_ = pcm_converter;
      target_format_ = target_format;
      sample_rate_hz_ = config.sample_rate_hz;
      channel_count_ = config.channel_count;
      stream_samples_.clear();
      stream_sample_limit_ =
          std::max<std::size_t>(
              static_cast<std::size_t>(config.sample_rate_hz) * config.channel_count * 5,
              static_cast<std::size_t>(frames_per_chunk) * config.channel_count * 16);
      pending_sample_limit_.store(
          std::max<std::size_t>(
              static_cast<std::size_t>(config.sample_rate_hz) * config.channel_count * 2,
              static_cast<std::size_t>(frames_per_chunk) * config.channel_count * 32),
          std::memory_order_release);
      pending_samples_.store(0, std::memory_order_release);
      processed_sample_count_.store(0, std::memory_order_release);

      pcm_file_ = pcm_file;
      wav_data_bytes_ = wav_data_bytes;
      output_path_utf8_ = output_path_utf8;
      aac_capture_wav_path_utf8_ = aac_capture_wav_path_utf8;
      aac_bitrate_bps_ = aac_bitrate_bps;

      deferred_error_code_ = 0;
      deferred_error_.clear();
      current_dbfs_ = -90.0;
      max_dbfs_ = -90.0;
    }
    accepting_samples_.store(true, std::memory_order_release);

    return 0;
  }

  void HandleInputBuffer(AVAudioPCMBuffer* input_buffer) {
    if (input_buffer == nil) {
      return;
    }
    if (!accepting_samples_.load(std::memory_order_acquire)) {
      return;
    }

    AVAudioFormat* target_format = nil;
    AVAudioConverter* pcm_converter = nil;

    {
      std::lock_guard<std::mutex> lock(mutex_);
      if (mode_ == RecorderMode::kStopped || target_format_ == nil || channel_count_ == 0) {
        return;
      }
      target_format = target_format_;
      pcm_converter = pcm_converter_;
    }

    AVAudioPCMBuffer* converted = ConvertToTargetPcm16(input_buffer, target_format, pcm_converter);
    if (converted == nil) {
      std::lock_guard<std::mutex> lock(mutex_);
      if (deferred_error_code_ == 0) {
        deferred_error_code_ = -28;
        deferred_error_ = "Failed to convert input audio buffer into target PCM format.";
      }
      return;
    }

    if (converted.frameLength == 0 || converted.format.channelCount == 0) {
      return;
    }

    const AVAudioFrameCount frame_count = converted.frameLength;
    const uint32_t channel_count = static_cast<uint32_t>(converted.format.channelCount);
    const AudioBufferList* audio_buffer_list = converted.audioBufferList;
    if (audio_buffer_list == nullptr || audio_buffer_list->mNumberBuffers == 0) {
      return;
    }

    std::vector<int16_t> captured_samples;
    std::vector<int16_t> interleaved_scratch;

    if (converted.format.isInterleaved) {
      const AudioBuffer& buffer = audio_buffer_list->mBuffers[0];
      const std::size_t expected_sample_count =
          static_cast<std::size_t>(frame_count) * channel_count;
      if (buffer.mData == nullptr || expected_sample_count == 0 ||
          buffer.mDataByteSize < expected_sample_count * sizeof(int16_t)) {
        return;
      }
      const int16_t* samples = reinterpret_cast<const int16_t*>(buffer.mData);
      captured_samples.assign(samples, samples + expected_sample_count);
    } else {
      const std::size_t sample_count = static_cast<std::size_t>(frame_count) * channel_count;
      if (sample_count == 0) {
        return;
      }

      interleaved_scratch.resize(sample_count);
      const int16_t* const* channel_data = converted.int16ChannelData;
      if (channel_data != nullptr) {
        for (AVAudioFrameCount frame = 0; frame < frame_count; frame++) {
          for (uint32_t channel = 0; channel < channel_count; channel++) {
            interleaved_scratch[static_cast<std::size_t>(frame) * channel_count + channel] =
                channel_data[channel][frame];
          }
        }
      } else {
        if (audio_buffer_list->mNumberBuffers < channel_count) {
          return;
        }
        for (uint32_t channel = 0; channel < channel_count; channel++) {
          const AudioBuffer& channel_buffer = audio_buffer_list->mBuffers[channel];
          if (channel_buffer.mData == nullptr ||
              channel_buffer.mDataByteSize < frame_count * sizeof(int16_t)) {
            return;
          }
          const int16_t* source = reinterpret_cast<const int16_t*>(channel_buffer.mData);
          for (AVAudioFrameCount frame = 0; frame < frame_count; frame++) {
            interleaved_scratch[static_cast<std::size_t>(frame) * channel_count + channel] =
                source[frame];
          }
        }
      }
      captured_samples = std::move(interleaved_scratch);
    }

    if (captured_samples.empty() ||
        !accepting_samples_.load(std::memory_order_acquire)) {
      return;
    }

    const std::size_t pending_limit = pending_sample_limit_.load(std::memory_order_acquire);
    const std::size_t pending_now = pending_samples_.load(std::memory_order_relaxed);
    if (pending_limit > 0 && pending_now >= pending_limit) {
      std::lock_guard<std::mutex> lock(mutex_);
      if (deferred_error_code_ == 0) {
        deferred_error_code_ = -34;
        deferred_error_ =
            "Recorder processing queue is overloaded. Increase buffer size or reduce workload.";
      }
      return;
    }

    auto samples = std::make_shared<std::vector<int16_t>>(std::move(captured_samples));
    pending_samples_.fetch_add(samples->size(), std::memory_order_acq_rel);

    AppleAudioEngineRecorder* callback_self = this;
    dispatch_async(processing_queue_, ^{
      if (callback_self != nullptr) {
        callback_self->ProcessCapturedSamples(samples);
        callback_self->pending_samples_.fetch_sub(samples->size(), std::memory_order_acq_rel);
      }
    });
  }

  void ProcessCapturedSamples(const std::shared_ptr<std::vector<int16_t>>& samples) {
    if (samples == nullptr || samples->empty()) {
      return;
    }

    const int16_t* sample_data = samples->data();
    const std::size_t sample_count = samples->size();
    processed_sample_count_.fetch_add(static_cast<uint64_t>(sample_count),
                                      std::memory_order_acq_rel);
    RecorderMode mode = RecorderMode::kStopped;
    FileSink sink = FileSink::kNone;
    FILE* pcm_file = nullptr;

    {
      std::lock_guard<std::mutex> lock(mutex_);
      if (mode_ == RecorderMode::kStopped) {
        return;
      }

      UpdateAmplitudeLocked(sample_data, sample_count);
      mode = mode_;
      if (mode_ == RecorderMode::kStream) {
        stream_samples_.insert(stream_samples_.end(), sample_data, sample_data + sample_count);
        if (stream_samples_.size() > stream_sample_limit_) {
          const auto overflow = stream_samples_.size() - stream_sample_limit_;
          stream_samples_.erase(stream_samples_.begin(), stream_samples_.begin() + overflow);
        }
        return;
      }

      if (mode_ != RecorderMode::kFile) {
        return;
      }

      sink = file_sink_;
      pcm_file = pcm_file_;
    }

    if (mode != RecorderMode::kFile) {
      return;
    }

    if (sink == FileSink::kWav || sink == FileSink::kPcm16 || sink == FileSink::kAacM4A) {
      if (pcm_file == nullptr) {
        std::lock_guard<std::mutex> lock(mutex_);
        if (deferred_error_code_ == 0) {
          deferred_error_code_ = -30;
          deferred_error_ = "Output file handle is unavailable for recorder file capture.";
        }
        return;
      }

      const std::size_t bytes_to_write = sample_count * sizeof(int16_t);
      const std::size_t bytes_written = std::fwrite(sample_data, 1, bytes_to_write, pcm_file);
      if (bytes_written != bytes_to_write) {
        std::lock_guard<std::mutex> lock(mutex_);
        if (deferred_error_code_ == 0) {
          deferred_error_code_ = -31;
          deferred_error_ = "Failed to write captured PCM bytes to file.";
        }
        return;
      }

      if (sink == FileSink::kWav || sink == FileSink::kAacM4A) {
        std::lock_guard<std::mutex> lock(mutex_);
        const auto remaining = std::numeric_limits<uint32_t>::max() - wav_data_bytes_;
        const auto bounded = static_cast<uint32_t>(
            std::min<std::size_t>(bytes_written, static_cast<std::size_t>(remaining)));
        wav_data_bytes_ += bounded;
      }
      return;
    }
  }

  void UpdateAmplitudeLocked(const int16_t* samples, std::size_t sample_count) {
    if (samples == nullptr || sample_count == 0) {
      current_dbfs_ = -90.0;
      return;
    }

    int32_t peak = 0;
    for (std::size_t i = 0; i < sample_count; i++) {
      const int32_t value = std::abs(static_cast<int32_t>(samples[i]));
      if (value > peak) {
        peak = value;
      }
    }

    if (peak <= 0) {
      current_dbfs_ = -90.0;
      return;
    }

    const double normalized = static_cast<double>(peak) / 32767.0;
    double dbfs = 20.0 * std::log10(normalized);
    if (!std::isfinite(dbfs)) {
      dbfs = -90.0;
    }
    dbfs = std::clamp(dbfs, -90.0, 0.0);

    current_dbfs_ = dbfs;
    if (dbfs > max_dbfs_) {
      max_dbfs_ = dbfs;
    }
  }

  dispatch_queue_t processing_queue_ = nullptr;

  std::atomic<bool> accepting_samples_{false};
  std::atomic<std::size_t> pending_samples_{0};
  std::atomic<std::size_t> pending_sample_limit_{0};
  std::atomic<uint64_t> processed_sample_count_{0};

  std::mutex mutex_;

  RecorderMode mode_ = RecorderMode::kStopped;
  FileSink file_sink_ = FileSink::kNone;

  AVAudioEngine* audio_engine_ = nil;
  AVAudioInputNode* input_node_ = nil;
  AVAudioConverter* pcm_converter_ = nil;
  AVAudioFormat* target_format_ = nil;

  uint32_t sample_rate_hz_ = 0;
  uint32_t channel_count_ = 0;

  std::deque<int16_t> stream_samples_;
  std::size_t stream_sample_limit_ = 0;

  FILE* pcm_file_ = nullptr;
  uint32_t wav_data_bytes_ = 0;

  std::string output_path_utf8_;
  std::string aac_capture_wav_path_utf8_;
  uint32_t aac_bitrate_bps_ = 0;

  double current_dbfs_ = -90.0;
  double max_dbfs_ = -90.0;

  int32_t deferred_error_code_ = 0;
  std::string deferred_error_;
};

AppleAudioEngineRecorder g_recorder;

}  // namespace

void WriteError(const std::string& message, char* out_error_utf8, uint32_t out_error_capacity) {
  if (out_error_utf8 == nullptr || out_error_capacity == 0) {
    return;
  }

  const auto copy_len = static_cast<uint32_t>(
      std::min<std::size_t>(message.size(), static_cast<std::size_t>(out_error_capacity - 1)));
  std::memcpy(out_error_utf8, message.data(), copy_len);
  out_error_utf8[copy_len] = '\0';
}

void WriteNSError(NSError* error, const char* prefix, char* out_error_utf8,
                  uint32_t out_error_capacity) {
  if (error == nil) {
    WriteError(std::string(prefix) + ": unknown error", out_error_utf8, out_error_capacity);
    return;
  }

  std::string message(prefix);
  message.append(": ");
  message.append([[error localizedDescription] UTF8String]);
  WriteError(message, out_error_utf8, out_error_capacity);
}

std::string TrimAscii(const char* utf8) {
  if (utf8 == nullptr) {
    return {};
  }

  return std::string(utf8);
}

bool EnsureMicrophonePermission(int32_t* out_has_permission, bool request_if_needed,
                                char* out_error_utf8, uint32_t out_error_capacity) {
  if (out_has_permission == nullptr) {
    WriteError("Permission output pointer is null.", out_error_utf8, out_error_capacity);
    return false;
  }

  const AVAuthorizationStatus status =
      [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];

  if (status == AVAuthorizationStatusAuthorized) {
    *out_has_permission = 1;
    return true;
  }
  if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
    *out_has_permission = 0;
    return true;
  }
  if (!request_if_needed) {
    *out_has_permission = 0;
    return true;
  }

  __block bool granted = false;
  dispatch_semaphore_t done = dispatch_semaphore_create(0);
  [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio
                           completionHandler:^(BOOL did_grant) {
                             granted = did_grant;
                             dispatch_semaphore_signal(done);
                           }];

  const dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, 30LL * NSEC_PER_SEC);
  if (dispatch_semaphore_wait(done, timeout) != 0) {
    WriteError("Timed out while requesting microphone permission.", out_error_utf8,
               out_error_capacity);
    return false;
  }

  *out_has_permission = granted ? 1 : 0;
  return true;
}

NSString* ResolveIosSessionMode(int32_t apple_session_mode_code, int32_t processing_flags) {
#if TARGET_OS_IPHONE
  switch (apple_session_mode_code) {
    case 1:
      return AVAudioSessionModeVoiceChat;
    case 2:
      return AVAudioSessionModeVideoChat;
    case 3:
      return AVAudioSessionModeMeasurement;
    case 4:
      return AVAudioSessionModeGameChat;
    case 5:
      return AVAudioSessionModeSpokenAudio;
    default:
      break;
  }

  return RequiresVoiceProcessing(processing_flags) ? AVAudioSessionModeVoiceChat
                                                   : AVAudioSessionModeDefault;
#else
  (void)apple_session_mode_code;
  (void)processing_flags;
  return nil;
#endif
}

AVAudioSessionCategoryOptions ResolveIosCategoryOptions(uint32_t apple_category_options_flags) {
#if TARGET_OS_IPHONE
  AVAudioSessionCategoryOptions options = 0;
  if ((apple_category_options_flags & (1u << 0)) != 0u) {
    options |= AVAudioSessionCategoryOptionAllowBluetooth;
  }
  if ((apple_category_options_flags & (1u << 1)) != 0u) {
    options |= AVAudioSessionCategoryOptionAllowBluetoothA2DP;
  }
  if ((apple_category_options_flags & (1u << 2)) != 0u) {
    options |= AVAudioSessionCategoryOptionDefaultToSpeaker;
  }
  if ((apple_category_options_flags & (1u << 3)) != 0u) {
    options |= AVAudioSessionCategoryOptionMixWithOthers;
  }
  if ((apple_category_options_flags & (1u << 4)) != 0u) {
    options |= AVAudioSessionCategoryOptionDuckOthers;
  }
  return options;
#else
  (void)apple_category_options_flags;
  return 0;
#endif
}

bool RequiresVoiceProcessing(int32_t processing_flags) {
  const int32_t mask = kProcessingFlagEchoCancellation;
  return (processing_flags & mask) != 0;
}

AudioFormatID ResolveAppleAacFormatId(int32_t apple_file_encoder_code) {
  switch (apple_file_encoder_code) {
    case kAppleFileEncoderAacHe:
      return kAudioFormatMPEG4AAC_HE;
    case kAppleFileEncoderAacEld:
      return kAudioFormatMPEG4AAC_ELD;
    case kAppleFileEncoderAacLc:
    default:
      return kAudioFormatMPEG4AAC;
  }
}

uint32_t ResolveAppleAacBitrate(uint32_t requested_bitrate_bps) {
  if (requested_bitrate_bps == 0) {
    return 64000;
  }
  return requested_bitrate_bps;
}

int32_t HasPermission(int32_t* out_has_permission, char* error_utf8,
                      uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  @autoreleasepool {
    if (!EnsureMicrophonePermission(out_has_permission, false, error_utf8, error_utf8_capacity)) {
      return -1;
    }
  }
  return 0;
}

int32_t RequestPermission(int32_t* out_has_permission, char* error_utf8,
                          uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  @autoreleasepool {
    if (!EnsureMicrophonePermission(out_has_permission, true, error_utf8, error_utf8_capacity)) {
      return -1;
    }
  }
  return 0;
}

int32_t ListInputDevicesJson(char* out_json_utf8, uint32_t out_json_capacity, char* error_utf8,
                             uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  @autoreleasepool {
    return g_recorder.ListInputDevices(out_json_utf8, out_json_capacity, error_utf8,
                                       error_utf8_capacity);
  }
}

int32_t StartFile(const speech_utils::recorder::RecorderStartConfig* start_config,
                  char* error_utf8,
                  uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  if (start_config == nullptr) {
    WriteError("Start config pointer is null.", error_utf8, error_utf8_capacity);
    return -1;
  }
  @autoreleasepool {
    return g_recorder.StartFile(*start_config, error_utf8, error_utf8_capacity);
  }
}

int32_t StartStream(const speech_utils::recorder::RecorderStartConfig* start_config,
                    char* error_utf8,
                    uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  if (start_config == nullptr) {
    WriteError("Start config pointer is null.", error_utf8, error_utf8_capacity);
    return -1;
  }
  @autoreleasepool {
    return g_recorder.StartStream(*start_config, error_utf8, error_utf8_capacity);
  }
}

int32_t ReadStreamPcm16(int16_t* out_samples, uint32_t out_sample_capacity,
                        uint32_t* out_samples_written, char* error_utf8,
                        uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.ReadStream(out_samples, out_sample_capacity, out_samples_written, error_utf8,
                               error_utf8_capacity);
}

int32_t Stop(char* error_utf8, uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.Stop(error_utf8, error_utf8_capacity);
}

int32_t Reset(char* error_utf8, uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.Reset(error_utf8, error_utf8_capacity);
}

int32_t IsRecording(int32_t* out_is_recording, char* error_utf8,
                    uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.IsRecording(out_is_recording, error_utf8, error_utf8_capacity);
}

int32_t GetAmplitude(double* out_current_dbfs, double* out_max_dbfs, char* error_utf8,
                     uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.GetAmplitude(out_current_dbfs, out_max_dbfs, error_utf8,
                                 error_utf8_capacity);
}

}  // namespace speech_utils::apple_recorder
