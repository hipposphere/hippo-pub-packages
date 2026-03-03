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

#include "speech_utils_native_audio_recorder_api.h"
#include "speech_utils_native_audio_recorder_common.h"
#include "speech_utils_native_audio_recorder_wav.h"

#include "speech_utils_ios_audio_recorder_session.h"

namespace speech_utils::native_recorder {

class NativeAudioRecorder;

namespace {

enum class RecorderMode { kStopped, kFile, kStream };

enum class FileSink { kNone, kWav, kPcm16, kAacM4A };

constexpr const char* kRecorderProcessingQueueLabel = "speech_utils.native_recorder.processing";

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

std::string Utf8OrFallback(NSString* value, const char* fallback) {
  if (value == nil || value.length == 0) {
    return std::string(fallback);
  }
  const char* utf8 = value.UTF8String;
  if (utf8 == nullptr || utf8[0] == '\0') {
    return std::string(fallback);
  }
  return std::string(utf8);
}

std::string BuildAacPrepareFailureMessage(NSDictionary<NSString*, id>* settings, NSURL* output_url) {
  AVAudioSession* audio_session = AVAudioSession.sharedInstance;

  std::string message("AVAudioRecorder failed to prepare AAC output.");
  message.append(" category=");
  message.append(Utf8OrFallback(audio_session.category, "<none>"));
  message.append(" mode=");
  message.append(Utf8OrFallback(audio_session.mode, "<none>"));
  message.append(" sessionSampleRate=");
  message.append(std::to_string(static_cast<uint32_t>(std::llround(audio_session.sampleRate))));

  if (output_url != nil) {
    message.append(" path=");
    message.append(Utf8OrFallback(output_url.path, "<none>"));
  }

  if (settings != nil) {
    NSError* json_error = nil;
    NSData* json_data =
        [NSJSONSerialization dataWithJSONObject:settings options:0 error:&json_error];
    if (json_data != nil) {
      NSString* json = [[NSString alloc] initWithData:json_data encoding:NSUTF8StringEncoding];
      message.append(" settings=");
      message.append(Utf8OrFallback(json, "<json-unavailable>"));
    } else if (json_error != nil && json_error.localizedDescription != nil) {
      message.append(" settingsError=");
      message.append(Utf8OrFallback(json_error.localizedDescription, "unknown"));
    }
  }

  return message;
}

bool HasUsableConverterValues(NSArray<NSNumber*>* values) {
  if (values == nil || values.count == 0) {
    return false;
  }
  if (values.count == 1) {
    return std::abs(values.firstObject.doubleValue) > 0.5;
  }
  return true;
}

double FindNearestConverterValue(NSArray<NSNumber*>* values, double requested) {
  if (values == nil || values.count == 0) {
    return requested;
  }

  double best_value = values.firstObject.doubleValue;
  double best_distance = std::abs(best_value - requested);
  for (NSNumber* number in values) {
    const double current = number.doubleValue;
    const double distance = std::abs(current - requested);
    if (distance < best_distance) {
      best_value = current;
      best_distance = distance;
    }
  }
  return best_value;
}

NSDictionary<NSString*, id>* BuildAacRecorderSettings(uint32_t sample_rate_hz,
                                                       uint32_t channel_count,
                                                       uint32_t bitrate_bps) {
  uint32_t channels = std::max<uint32_t>(1, std::min<uint32_t>(channel_count, 2));
  AVAudioSession* audio_session = AVAudioSession.sharedInstance;
  if (audio_session != nil && audio_session.maximumInputNumberOfChannels > 0) {
    channels = std::min<uint32_t>(
        channels, static_cast<uint32_t>(audio_session.maximumInputNumberOfChannels));
  }

  const double sample_rate =
      std::min<double>(sample_rate_hz > 0 ? static_cast<double>(sample_rate_hz) : 44100.0,
                       48000.0);
  const uint32_t bitrate = ResolveNativeAacBitrate(bitrate_bps);

  NSMutableDictionary<NSString*, id>* settings = [@{
    AVFormatIDKey : @(static_cast<UInt32>(kAudioFormatMPEG4AAC)),
    AVSampleRateKey : @(sample_rate),
    AVNumberOfChannelsKey : @(static_cast<NSInteger>(channels)),
    AVEncoderBitRateKey : @(static_cast<NSInteger>(bitrate)),
    AVEncoderAudioQualityKey : @(AVAudioQualityHigh),
  } mutableCopy];

  AVAudioFormat* input_format =
      [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt16
                                        sampleRate:sample_rate
                                          channels:channels
                                       interleaved:NO];
  AVAudioFormat* output_format = [[AVAudioFormat alloc] initWithSettings:settings];
  AVAudioConverter* converter =
      (input_format != nil && output_format != nil)
          ? [[AVAudioConverter alloc] initFromFormat:input_format toFormat:output_format]
          : nil;
  if (converter != nil) {
    NSArray<NSNumber*>* supported_sample_rates = converter.availableEncodeSampleRates;
    if (HasUsableConverterValues(supported_sample_rates)) {
      const double nearest_sample_rate =
          FindNearestConverterValue(supported_sample_rates, sample_rate);
      settings[AVSampleRateKey] = @(nearest_sample_rate);
    } else {
      [settings removeObjectForKey:AVSampleRateKey];
    }

    NSArray<NSNumber*>* supported_bit_rates = converter.availableEncodeBitRates;
    if (HasUsableConverterValues(supported_bit_rates)) {
      const double nearest_bit_rate =
          FindNearestConverterValue(supported_bit_rates, static_cast<double>(bitrate));
      settings[AVEncoderBitRateKey] = @(static_cast<NSInteger>(std::llround(nearest_bit_rate)));
    } else {
      [settings removeObjectForKey:AVEncoderBitRateKey];
    }
  }

  return settings;
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
      std::max<double>(64.0, std::ceil(static_cast<double>(input_buffer.frameLength) * ratio) +
                                 8.0));

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

}  // namespace

}  // namespace speech_utils::native_recorder

namespace speech_utils::native_recorder {

class NativeAudioRecorder {
 public:
  NativeAudioRecorder() {
    processing_queue_ = dispatch_queue_create(kRecorderProcessingQueueLabel, DISPATCH_QUEUE_SERIAL);
  }

  ~NativeAudioRecorder() {
    char sink[1] = {0};
    (void)Stop(sink, sizeof(sink));
  }

  int32_t ListInputDevices(char* out_json_utf8, uint32_t out_json_capacity, char* error_utf8,
                           uint32_t error_utf8_capacity) {
    NSMutableArray<NSDictionary<NSString*, id>*>* devices = [NSMutableArray array];

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
    AVAudioEngine* stream_engine = nil;
    AVAudioRecorder* file_recorder = nil;
    FileSink file_sink = FileSink::kNone;

    FILE* pcm_file = nullptr;
    uint32_t wav_data_bytes = 0;
    uint32_t sample_rate_hz = 0;
    uint32_t channel_count = 0;

    int32_t deferred_code = 0;
    std::string deferred_error;
    uint64_t processed_sample_count = 0;

    {
      std::lock_guard<std::mutex> lock(mutex_);
      if (mode_ == RecorderMode::kStopped) {
        return 0;
      }

      stream_engine = stream_engine_;
      file_recorder = file_recorder_;
      accepting_samples_.store(false, std::memory_order_release);
    }

    if (stream_engine != nil) {
      [stream_engine.inputNode removeTapOnBus:0];
      [stream_engine stop];
    }
    if (file_recorder != nil && [file_recorder isRecording]) {
      [file_recorder stop];
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

      deferred_code = deferred_error_code_;
      deferred_error = deferred_error_;

      stream_engine_ = nil;
      file_recorder_ = nil;
      target_format_ = nil;
      pcm_converter_ = nil;
      file_sink_ = FileSink::kNone;
      pcm_file_ = nullptr;
      wav_data_bytes_ = 0;
      sample_rate_hz_ = 0;
      channel_count_ = 0;
      current_dbfs_ = -90.0;
      max_dbfs_ = -90.0;
      deferred_error_code_ = 0;
      deferred_error_.clear();
    }

    const bool uses_native_file_recorder = file_recorder != nil && file_sink == FileSink::kAacM4A;
    if (!uses_native_file_recorder && processed_sample_count == 0 && deferred_code == 0) {
      deferred_code = -41;
      deferred_error = "Recorder stopped without capturing any microphone samples.";
    }

    if ((file_sink == FileSink::kWav || file_sink == FileSink::kPcm16) && pcm_file != nullptr) {
      if (file_sink == FileSink::kWav) {
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

    [AVAudioSession.sharedInstance setActive:NO error:nil];

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
    if (file_recorder_ != nil && [file_recorder_ isRecording]) {
      [file_recorder_ updateMeters];
      const double dbfs =
          std::clamp(static_cast<double>([file_recorder_ averagePowerForChannel:0]), -90.0, 0.0);
      current_dbfs_ = dbfs;
      if (dbfs > max_dbfs_) {
        max_dbfs_ = dbfs;
      }
    }
    *out_current_dbfs = current_dbfs_;
    *out_max_dbfs = max_dbfs_;
    return 0;
  }

  void HandleEngineBuffer(AVAudioPCMBuffer* source_buffer) {
    if (source_buffer == nil || !accepting_samples_.load(std::memory_order_acquire)) {
      return;
    }
    if (source_buffer.frameLength == 0 || source_buffer.format.channelCount == 0) {
      return;
    }

    RecorderMode mode = RecorderMode::kStopped;
    AVAudioFormat* target_format = nil;
    AVAudioConverter* pcm_converter = nil;
    {
      std::lock_guard<std::mutex> lock(mutex_);
      if (mode_ == RecorderMode::kStopped || target_format_ == nil || channel_count_ == 0) {
        return;
      }
      mode = mode_;
      target_format = target_format_;
      pcm_converter = pcm_converter_;
    }

    AVAudioPCMBuffer* converted = ConvertToTargetPcm16(source_buffer, target_format, pcm_converter);
    if (converted == nil && !FormatsMatchPcm16(source_buffer.format, target_format)) {
      AVAudioConverter* adaptive_converter =
          [[AVAudioConverter alloc] initFromFormat:source_buffer.format toFormat:target_format];
      if (adaptive_converter != nil) {
        adaptive_converter.sampleRateConverterQuality = AVAudioQualityHigh;
        if (@available(iOS 13.0, *)) {
          adaptive_converter.primeMethod = AVAudioConverterPrimeMethod_None;
        }
        converted = ConvertToTargetPcm16(source_buffer, target_format, adaptive_converter);
        if (converted != nil) {
          std::lock_guard<std::mutex> lock(mutex_);
          if (mode_ != RecorderMode::kStopped) {
            pcm_converter_ = adaptive_converter;
          }
        }
      }
    }
    if (converted == nil) {
      MarkDeferredError(
          -28,
          "Failed to convert engine sample into recorder PCM format (sample-rate/channel mismatch).");
      return;
    }

    const AVAudioFrameCount converted_frame_count = converted.frameLength;
    const uint32_t converted_channel_count = static_cast<uint32_t>(converted.format.channelCount);
    if (converted_frame_count == 0 || converted_channel_count == 0) {
      return;
    }

    std::vector<int16_t> captured_samples;
    std::vector<int16_t> interleaved_scratch;
    const AudioBufferList* converted_audio_buffers = converted.audioBufferList;
    if (converted_audio_buffers == nullptr || converted_audio_buffers->mNumberBuffers == 0) {
      return;
    }

    if (converted.format.isInterleaved) {
      const AudioBuffer& buffer = converted_audio_buffers->mBuffers[0];
      const std::size_t expected_sample_count =
          static_cast<std::size_t>(converted_frame_count) * converted_channel_count;
      if (buffer.mData == nullptr || expected_sample_count == 0 ||
          buffer.mDataByteSize < expected_sample_count * sizeof(int16_t)) {
        MarkDeferredError(-28, "Converted engine PCM buffer is missing interleaved PCM16 payload.");
        return;
      }
      const int16_t* samples = reinterpret_cast<const int16_t*>(buffer.mData);
      captured_samples.assign(samples, samples + expected_sample_count);
    } else {
      const std::size_t sample_count =
          static_cast<std::size_t>(converted_frame_count) * converted_channel_count;
      if (sample_count == 0) {
        return;
      }

      interleaved_scratch.resize(sample_count);
      const int16_t* const* channel_data = converted.int16ChannelData;
      if (channel_data != nullptr) {
        for (AVAudioFrameCount frame = 0; frame < converted_frame_count; frame++) {
          for (uint32_t channel = 0; channel < converted_channel_count; channel++) {
            interleaved_scratch[static_cast<std::size_t>(frame) * converted_channel_count +
                               channel] = channel_data[channel][frame];
          }
        }
      } else {
        if (converted_audio_buffers->mNumberBuffers < converted_channel_count) {
          MarkDeferredError(-28, "Converted engine PCM buffer has fewer channel buffers than expected.");
          return;
        }
        for (uint32_t channel = 0; channel < converted_channel_count; channel++) {
          const AudioBuffer& channel_buffer = converted_audio_buffers->mBuffers[channel];
          if (channel_buffer.mData == nullptr ||
              channel_buffer.mDataByteSize < converted_frame_count * sizeof(int16_t)) {
            MarkDeferredError(-28, "Converted engine PCM channel buffer is missing payload.");
            return;
          }
          const int16_t* source = reinterpret_cast<const int16_t*>(channel_buffer.mData);
          for (AVAudioFrameCount frame = 0; frame < converted_frame_count; frame++) {
            interleaved_scratch[static_cast<std::size_t>(frame) * converted_channel_count +
                               channel] = source[frame];
          }
        }
      }
      captured_samples = std::move(interleaved_scratch);
    }

    if (captured_samples.empty() || !accepting_samples_.load(std::memory_order_acquire)) {
      return;
    }

    if (mode == RecorderMode::kStream) {
      ProcessCapturedSamples(std::make_shared<std::vector<int16_t>>(std::move(captured_samples)));
      return;
    }

    const std::size_t pending_limit = pending_sample_limit_.load(std::memory_order_acquire);
    const std::size_t pending_now = pending_samples_.load(std::memory_order_relaxed);
    if (pending_limit > 0 && pending_now >= pending_limit) {
      MarkDeferredError(
          -34,
          "Recorder processing queue is overloaded. Increase buffer size or reduce workload.");
      return;
    }

    auto samples = std::make_shared<std::vector<int16_t>>(std::move(captured_samples));
    pending_samples_.fetch_add(samples->size(), std::memory_order_acq_rel);

    NativeAudioRecorder* callback_self = this;
    dispatch_async(processing_queue_, ^{
      if (callback_self != nullptr) {
        callback_self->ProcessCapturedSamples(samples);
        callback_self->pending_samples_.fetch_sub(samples->size(), std::memory_order_acq_rel);
      }
    });
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

    if (!ConfigureIosRecorderSession(
            config.sample_rate_hz, config.runtime.processing_flags,
            config.runtime.ios_session_mode_code, config.runtime.ios_category_options_flags,
            config.runtime.preferred_latency_seconds,
            config.runtime.ios_preferred_io_buffer_duration_seconds,
            config.runtime.ios_preferred_input_gain, error_utf8, error_utf8_capacity)) {
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

    auto ClosePendingOutputs = [&]() {
      if (pcm_file != nullptr) {
        std::fclose(pcm_file);
        pcm_file = nullptr;
      }
    };

    if (mode == RecorderMode::kFile) {
      if (output_path == nil || output_path.length == 0) {
        WriteError("Output path is missing.", error_utf8, error_utf8_capacity);
        return -11;
      }

      NSFileManager* fs = NSFileManager.defaultManager;
      NSString* output_parent = output_path.stringByDeletingLastPathComponent;
      if (output_parent.length > 0 && ![fs fileExistsAtPath:output_parent]) {
        NSError* create_error = nil;
        if (![fs createDirectoryAtPath:output_parent
            withIntermediateDirectories:YES
                             attributes:nil
                                  error:&create_error]) {
          WriteNSError(create_error, "Failed to create output directory", error_utf8,
                       error_utf8_capacity);
          return -12;
        }
      }
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
          pcm_file = nullptr;
          WriteError("Failed to write WAV header.", error_utf8, error_utf8_capacity);
          return -15;
        }
      }
    }

    if (mode == RecorderMode::kFile && sink == FileSink::kAacM4A) {
      AVAudioSession* audio_session = AVAudioSession.sharedInstance;
      NSError* session_mode_error = nil;
      if (![audio_session setMode:AVAudioSessionModeDefault error:&session_mode_error]) {
        WriteNSError(session_mode_error, "Failed to set AVAudioSession mode for AAC file recording",
                     error_utf8, error_utf8_capacity);
        return -16;
      }
      [audio_session setActive:YES error:nil];

      const NSInteger max_input_channels = audio_session.maximumInputNumberOfChannels;
      if (max_input_channels > 0) {
        const NSUInteger preferred_channels =
            static_cast<NSUInteger>(std::min<uint32_t>(config.channel_count,
                                                       static_cast<uint32_t>(max_input_channels)));
        if (preferred_channels > 0) {
          [audio_session setPreferredInputNumberOfChannels:preferred_channels error:nil];
        }
      }

      NSURL* output_url = [NSURL fileURLWithPath:output_path];
      if (output_url == nil) {
        WriteError("Failed to create output URL for AAC file recording.", error_utf8,
                   error_utf8_capacity);
        return -16;
      }

      NSDictionary<NSString*, id>* recorder_settings = BuildAacRecorderSettings(
          config.sample_rate_hz, config.channel_count, config.runtime.file_bitrate_bps);

      NSError* recorder_error = nil;
      AVAudioRecorder* file_recorder =
          [[AVAudioRecorder alloc] initWithURL:output_url
                                      settings:recorder_settings
                                         error:&recorder_error];
      if (file_recorder == nil) {
        WriteNSError(recorder_error, "Failed to initialize AVAudioRecorder", error_utf8,
                     error_utf8_capacity);
        return -16;
      }

      file_recorder.meteringEnabled = YES;
      const bool prepared = [file_recorder prepareToRecord];
      const bool started = [file_recorder record];
      if (!started) {
        if (!prepared) {
          std::string message = BuildAacPrepareFailureMessage(recorder_settings, output_url);
          message.append(" record()=false");
          WriteError(message, error_utf8, error_utf8_capacity);
        } else {
          WriteError("AVAudioRecorder failed to start AAC output.", error_utf8,
                     error_utf8_capacity);
        }
        return -16;
      }

      {
        std::lock_guard<std::mutex> lock(mutex_);
        mode_ = mode;
        file_sink_ = sink;
        stream_engine_ = nil;
        file_recorder_ = file_recorder;
        target_format_ = target_format;
        pcm_converter_ = nil;
        sample_rate_hz_ = config.sample_rate_hz;
        channel_count_ = config.channel_count;
        stream_samples_.clear();
        stream_sample_limit_ = 0;
        pending_sample_limit_.store(0, std::memory_order_release);
        pending_samples_.store(0, std::memory_order_release);
        processed_sample_count_.store(0, std::memory_order_release);

        pcm_file_ = nullptr;
        wav_data_bytes_ = 0;

        deferred_error_code_ = 0;
        deferred_error_.clear();
        current_dbfs_ = -90.0;
        max_dbfs_ = -90.0;
      }

      accepting_samples_.store(false, std::memory_order_release);
      return 0;
    }

    if (mode == RecorderMode::kStream ||
        (mode == RecorderMode::kFile &&
         (sink == FileSink::kWav || sink == FileSink::kPcm16))) {
      AVAudioEngine* stream_engine = [[AVAudioEngine alloc] init];
      if (stream_engine == nil) {
        ClosePendingOutputs();
        WriteError("Failed to initialize AVAudioEngine.", error_utf8, error_utf8_capacity);
        return -21;
      }

      AVAudioInputNode* input_node = stream_engine.inputNode;
      AVAudioFormat* source_format = [input_node inputFormatForBus:0];
      if (source_format == nil) {
        ClosePendingOutputs();
        WriteError("AVAudioEngine input format is unavailable.", error_utf8, error_utf8_capacity);
        return -22;
      }

      AVAudioConverter* pcm_converter =
          [[AVAudioConverter alloc] initFromFormat:source_format toFormat:target_format];
      if (pcm_converter != nil) {
        pcm_converter.sampleRateConverterQuality = AVAudioQualityHigh;
        if (@available(iOS 13.0, *)) {
          pcm_converter.primeMethod = AVAudioConverterPrimeMethod_None;
        }
      }

      const AVAudioFrameCount tap_frames =
          static_cast<AVAudioFrameCount>(std::max<uint32_t>(64, frames_per_chunk));
      NativeAudioRecorder* callback_self = this;
      [input_node installTapOnBus:0
                       bufferSize:tap_frames
                           format:source_format
                            block:^(AVAudioPCMBuffer* buffer, AVAudioTime* when) {
                              (void)when;
                              if (callback_self != nullptr) {
                                callback_self->HandleEngineBuffer(buffer);
                              }
                            }];

      [stream_engine prepare];
      NSError* engine_error = nil;
      if (![stream_engine startAndReturnError:&engine_error]) {
        [input_node removeTapOnBus:0];
        ClosePendingOutputs();
        WriteNSError(engine_error, "Failed to start AVAudioEngine", error_utf8,
                     error_utf8_capacity);
        [AVAudioSession.sharedInstance setActive:NO error:nil];
        return -27;
      }

      {
        std::lock_guard<std::mutex> lock(mutex_);
        mode_ = mode;
        file_sink_ = sink;
        stream_engine_ = stream_engine;
        file_recorder_ = nil;
        target_format_ = target_format;
        pcm_converter_ = pcm_converter;
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

        pcm_file_ = (mode == RecorderMode::kFile ? pcm_file : nullptr);
        wav_data_bytes_ = (mode == RecorderMode::kFile ? wav_data_bytes : 0);

        deferred_error_code_ = 0;
        deferred_error_.clear();
        current_dbfs_ = -90.0;
        max_dbfs_ = -90.0;
      }

      accepting_samples_.store(true, std::memory_order_release);
      return 0;
    }
    ClosePendingOutputs();
    WriteError("Unsupported iOS recorder mode.", error_utf8, error_utf8_capacity);
    return -21;
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

    if (sink == FileSink::kAacM4A) {
      // AAC file recording is handled by AVAudioRecorder directly.
      return;
    }

    if (sink == FileSink::kWav || sink == FileSink::kPcm16) {
      if (pcm_file == nullptr) {
        MarkDeferredError(-30, "Output file handle is unavailable for recorder file capture.");
        return;
      }

      const std::size_t bytes_to_write = sample_count * sizeof(int16_t);
      const std::size_t bytes_written = std::fwrite(sample_data, 1, bytes_to_write, pcm_file);
      if (bytes_written != bytes_to_write) {
        MarkDeferredError(-31, "Failed to write captured PCM bytes to file.");
        return;
      }

      if (sink == FileSink::kWav) {
        std::lock_guard<std::mutex> lock(mutex_);
        const auto remaining = std::numeric_limits<uint32_t>::max() - wav_data_bytes_;
        const auto bounded = static_cast<uint32_t>(
            std::min<std::size_t>(bytes_written, static_cast<std::size_t>(remaining)));
        wav_data_bytes_ += bounded;
      }
    }
  }

  void MarkDeferredError(int32_t code, const std::string& message) {
    std::lock_guard<std::mutex> lock(mutex_);
    if (deferred_error_code_ != 0) {
      return;
    }
    deferred_error_code_ = code;
    deferred_error_ = message;
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

  AVAudioEngine* stream_engine_ = nil;
  AVAudioRecorder* file_recorder_ = nil;
  AVAudioFormat* target_format_ = nil;
  AVAudioConverter* pcm_converter_ = nil;

  uint32_t sample_rate_hz_ = 0;
  uint32_t channel_count_ = 0;

  std::deque<int16_t> stream_samples_;
  std::size_t stream_sample_limit_ = 0;

  FILE* pcm_file_ = nullptr;
  uint32_t wav_data_bytes_ = 0;

  double current_dbfs_ = -90.0;
  double max_dbfs_ = -90.0;

  int32_t deferred_error_code_ = 0;
  std::string deferred_error_;
};

namespace {
NativeAudioRecorder g_recorder;
}

}  // namespace speech_utils::native_recorder

namespace speech_utils::native_recorder {

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

NSString* ResolveIosSessionMode(int32_t ios_session_mode_code, int32_t processing_flags) {
  switch (ios_session_mode_code) {
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

  (void)processing_flags;
  return AVAudioSessionModeDefault;
}

AVAudioSessionCategoryOptions ResolveIosCategoryOptions(uint32_t ios_category_options_flags) {
  AVAudioSessionCategoryOptions options = 0;
  if ((ios_category_options_flags & (1u << 0)) != 0u) {
    options |= AVAudioSessionCategoryOptionAllowBluetooth;
  }
  if ((ios_category_options_flags & (1u << 1)) != 0u) {
    options |= AVAudioSessionCategoryOptionAllowBluetoothA2DP;
  }
  if ((ios_category_options_flags & (1u << 2)) != 0u) {
    options |= AVAudioSessionCategoryOptionDefaultToSpeaker;
  }
  if ((ios_category_options_flags & (1u << 3)) != 0u) {
    options |= AVAudioSessionCategoryOptionMixWithOthers;
  }
  if ((ios_category_options_flags & (1u << 4)) != 0u) {
    options |= AVAudioSessionCategoryOptionDuckOthers;
  }
  return options;
}

bool RequiresVoiceProcessing(int32_t processing_flags) {
  const int32_t mask = kProcessingFlagPresetVoice | kProcessingFlagPresetVoiceIsolation;
  return (processing_flags & mask) != 0;
}

AudioFormatID ResolveNativeAacFormatId(int32_t file_encoder_code) {
  // AAC file recording always targets AAC-LC for broad device compatibility.
  (void)file_encoder_code;
  return kAudioFormatMPEG4AAC;
}

uint32_t ResolveNativeAacBitrate(uint32_t requested_bitrate_bps) {
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

}  // namespace speech_utils::native_recorder
