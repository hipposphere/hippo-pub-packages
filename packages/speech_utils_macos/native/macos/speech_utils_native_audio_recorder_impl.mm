#import <TargetConditionals.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMedia/CoreMedia.h>
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


@class SpeechUtilsAudioSampleBufferDelegate;

namespace speech_utils::native_recorder {

class NativeCaptureSessionRecorder;

namespace {

enum class RecorderMode { kStopped, kContinuous, kFile, kStream };

enum class RecorderLifecycle { kStopped, kStarting, kRunning, kStopping };

enum class FileSink { kNone, kWav, kPcm16, kAacM4A };

enum class CaptureSessionOutputKind { kData, kFile };

struct CaptureSessionConfig {
  uint32_t sample_rate_hz = 0;
  uint32_t channel_count = 0;
  uint32_t frames_per_chunk = 1024;
  double macos_processing_queue_duration_seconds = 0.0;
  std::string input_device_id;
  CaptureSessionOutputKind output_kind = CaptureSessionOutputKind::kData;

  bool IsValid() const { return sample_rate_hz > 0 && channel_count > 0; }

  bool IsCompatibleWith(const CaptureSessionConfig& other) const {
    return sample_rate_hz == other.sample_rate_hz && channel_count == other.channel_count &&
           input_device_id == other.input_device_id && output_kind == other.output_kind;
  }
};

enum class CaptureFileLifecycle { kInactive, kStarting, kRunning, kStopRequested, kFinished };

constexpr const char* kRecorderCaptureQueueLabel = "speech_utils.native_recorder.capture";
constexpr const char* kRecorderProcessingQueueLabel = "speech_utils.native_recorder.processing";
constexpr int64_t kCaptureFileStopTimeoutNanos = 10LL * NSEC_PER_SEC;

bool WaitForSemaphoreWithMainRunLoop(dispatch_semaphore_t semaphore, int64_t timeout_nanos) {
  if (semaphore == nullptr) {
    return true;
  }
  if (![NSThread isMainThread]) {
    return dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, timeout_nanos)) ==
           0;
  }

  NSDate* deadline = [NSDate dateWithTimeIntervalSinceNow:static_cast<NSTimeInterval>(timeout_nanos) /
                                                         static_cast<NSTimeInterval>(NSEC_PER_SEC)];
  while (true) {
    if (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW) == 0) {
      return true;
    }

    const NSTimeInterval remaining = deadline.timeIntervalSinceNow;
    if (remaining <= 0.0) {
      return false;
    }

    @autoreleasepool {
      NSDate* slice_deadline =
          [NSDate dateWithTimeIntervalSinceNow:std::min<NSTimeInterval>(0.05, remaining)];
      [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:slice_deadline];
    }
  }
}

bool CaptureFileLifecycleNeedsStopWait(CaptureFileLifecycle lifecycle) {
  return lifecycle == CaptureFileLifecycle::kStarting ||
         lifecycle == CaptureFileLifecycle::kRunning ||
         lifecycle == CaptureFileLifecycle::kStopRequested;
}

bool IsRecordingMode(RecorderMode mode) {
  return mode == RecorderMode::kFile || mode == RecorderMode::kStream;
}

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

AVAudioPCMBuffer* BuildPcmBufferFromAudioBufferList(const AudioBufferList* source_audio_buffers,
                                                    AVAudioFormat* source_format,
                                                    AVAudioFrameCount frame_count) {
  if (source_audio_buffers == nullptr || source_format == nil || frame_count == 0) {
    return nil;
  }

  AVAudioPCMBuffer* source_buffer =
      [[AVAudioPCMBuffer alloc] initWithPCMFormat:source_format frameCapacity:frame_count];
  if (source_buffer == nil) {
    return nil;
  }
  source_buffer.frameLength = frame_count;

  AudioBufferList* target_audio_buffers = source_buffer.mutableAudioBufferList;
  if (target_audio_buffers == nullptr || target_audio_buffers->mNumberBuffers == 0 ||
      source_audio_buffers->mNumberBuffers < target_audio_buffers->mNumberBuffers) {
    return nil;
  }

  for (UInt32 i = 0; i < target_audio_buffers->mNumberBuffers; i++) {
    const AudioBuffer& src = source_audio_buffers->mBuffers[i];
    AudioBuffer& dst = target_audio_buffers->mBuffers[i];
    if (src.mData == nullptr || dst.mData == nullptr || src.mDataByteSize < dst.mDataByteSize) {
      return nil;
    }
    std::memcpy(dst.mData, src.mData, dst.mDataByteSize);
  }

  return source_buffer;
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

std::string OsStatusToString(const char* context, OSStatus status) {
  return std::string(context) + " (OSStatus=" + std::to_string(static_cast<int32_t>(status)) +
         ")";
}

CaptureSessionConfig BuildCaptureSessionConfig(
    const speech_utils::recorder::RecorderStartConfig& config,
    CaptureSessionOutputKind output_kind) {
  CaptureSessionConfig session_config{};
  session_config.sample_rate_hz = config.sample_rate_hz;
  session_config.channel_count = config.channel_count;
  session_config.frames_per_chunk = config.frames_per_chunk > 0 ? config.frames_per_chunk : 1024;
  session_config.macos_processing_queue_duration_seconds =
      config.runtime.macos_processing_queue_duration_seconds;
  session_config.input_device_id = TrimWhitespace(TrimAscii(config.input_device_id_utf8));
  session_config.output_kind = output_kind;
  return session_config;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
NSArray<AVCaptureDeviceType>* ResolveAudioCaptureDeviceTypes() {
#if TARGET_OS_IPHONE
  if (@available(iOS 17.0, *)) {
    return @[ AVCaptureDeviceTypeMicrophone ];
  }
  return @[ AVCaptureDeviceTypeBuiltInMicrophone ];
#else
  if (@available(macOS 14.0, *)) {
    return @[ AVCaptureDeviceTypeMicrophone, AVCaptureDeviceTypeExternal ];
  }
  return @[ AVCaptureDeviceTypeBuiltInMicrophone, AVCaptureDeviceTypeExternalUnknown ];
#endif
}
#pragma clang diagnostic pop

NSDictionary<NSString*, id>* BuildCaptureAudioOutputSettings(uint32_t sample_rate_hz,
                                                              uint32_t channel_count) {
  return @{
    AVFormatIDKey : @(kAudioFormatLinearPCM),
    AVSampleRateKey : @(sample_rate_hz),
    AVNumberOfChannelsKey : @(channel_count),
    AVLinearPCMBitDepthKey : @16,
    AVLinearPCMIsFloatKey : @NO,
    AVLinearPCMIsBigEndianKey : @NO,
    AVLinearPCMIsNonInterleaved : @NO,
  };
}

NSDictionary<NSString*, id>* BuildCaptureAacFileOutputSettings(uint32_t sample_rate_hz,
                                                                uint32_t channel_count,
                                                                uint32_t bitrate_bps) {
  const uint32_t channels = std::max<uint32_t>(1, std::min<uint32_t>(channel_count, 2));
  const double sample_rate = sample_rate_hz > 0 ? static_cast<double>(sample_rate_hz) : 44100.0;
  const uint32_t bitrate = ResolveNativeAacBitrate(bitrate_bps);

  return @{
    AVFormatIDKey : @(static_cast<UInt32>(kAudioFormatMPEG4AAC)),
    AVSampleRateKey : @(sample_rate),
    AVNumberOfChannelsKey : @(static_cast<NSInteger>(channels)),
    AVEncoderBitRateKey : @(static_cast<NSInteger>(bitrate)),
    AVEncoderAudioQualityKey : @(AVAudioQualityHigh),
  };
}

bool CreateAacOutputFile(NSString* output_path, uint32_t sample_rate_hz, uint32_t channel_count,
                         uint32_t bitrate_bps, int32_t encoder_code, ExtAudioFileRef* out_file,
                         char* error_utf8, uint32_t error_utf8_capacity) {
  if (out_file == nullptr) {
    WriteError("AAC output file pointer is null.", error_utf8, error_utf8_capacity);
    return false;
  }
  *out_file = nullptr;

  if (output_path == nil || output_path.length == 0) {
    WriteError("Output path is missing.", error_utf8, error_utf8_capacity);
    return false;
  }
  if (sample_rate_hz == 0 || channel_count == 0) {
    WriteError("AAC output sample rate and channel count must be > 0.", error_utf8,
               error_utf8_capacity);
    return false;
  }

  NSURL* output_url = [NSURL fileURLWithPath:output_path];
  if (output_url == nil) {
    WriteError("Failed to create AAC output URL.", error_utf8, error_utf8_capacity);
    return false;
  }

  AudioStreamBasicDescription destination_format{};
  destination_format.mSampleRate = static_cast<Float64>(sample_rate_hz);
  destination_format.mFormatID = ResolveNativeAacFormatId(encoder_code);
  destination_format.mChannelsPerFrame = channel_count;
  destination_format.mFramesPerPacket = 1024;

  ExtAudioFileRef output_file = nullptr;
  OSStatus status = ExtAudioFileCreateWithURL((__bridge CFURLRef)output_url, kAudioFileM4AType,
                                              &destination_format, nullptr,
                                              kAudioFileFlags_EraseFile, &output_file);
  if (status != noErr || output_file == nullptr) {
    WriteError(OsStatusToString("Failed to create AAC output file", status), error_utf8,
               error_utf8_capacity);
    return false;
  }

  AudioStreamBasicDescription client_format{};
  client_format.mSampleRate = static_cast<Float64>(sample_rate_hz);
  client_format.mFormatID = kAudioFormatLinearPCM;
  client_format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
  client_format.mBitsPerChannel = 16;
  client_format.mChannelsPerFrame = channel_count;
  client_format.mFramesPerPacket = 1;
  client_format.mBytesPerFrame = channel_count * sizeof(int16_t);
  client_format.mBytesPerPacket = client_format.mBytesPerFrame;

  status = ExtAudioFileSetProperty(output_file, kExtAudioFileProperty_ClientDataFormat,
                                   static_cast<UInt32>(sizeof(client_format)), &client_format);
  if (status != noErr) {
    (void)ExtAudioFileDispose(output_file);
    WriteError(OsStatusToString("Failed to configure AAC client PCM format", status), error_utf8,
               error_utf8_capacity);
    return false;
  }

  const UInt32 resolved_bitrate = ResolveNativeAacBitrate(bitrate_bps);
  if (resolved_bitrate > 0) {
    AudioConverterRef converter = nullptr;
    UInt32 converter_size = static_cast<UInt32>(sizeof(converter));
    status = ExtAudioFileGetProperty(output_file, kExtAudioFileProperty_AudioConverter,
                                     &converter_size, &converter);
    if (status == noErr && converter != nullptr) {
      (void)AudioConverterSetProperty(converter, kAudioConverterEncodeBitRate,
                                      static_cast<UInt32>(sizeof(resolved_bitrate)),
                                      &resolved_bitrate);
    }
  }

  *out_file = output_file;
  return true;
}

bool PreparePcmFileOutput(NSString* output_path, FileSink sink, uint32_t sample_rate_hz,
                          uint32_t channel_count, FILE** out_file, char* error_utf8,
                          uint32_t error_utf8_capacity) {
  if (out_file == nullptr) {
    WriteError("PCM output file pointer is null.", error_utf8, error_utf8_capacity);
    return false;
  }
  *out_file = nullptr;

  if (output_path == nil || output_path.length == 0) {
    WriteError("Output path is missing.", error_utf8, error_utf8_capacity);
    return false;
  }

  NSFileManager* fs = NSFileManager.defaultManager;
  if ([fs fileExistsAtPath:output_path]) {
    NSError* remove_error = nil;
    if (![fs removeItemAtPath:output_path error:&remove_error]) {
      WriteNSError(remove_error, "Failed to remove existing output file", error_utf8,
                   error_utf8_capacity);
      return false;
    }
  }

  const char* path_fs = output_path.fileSystemRepresentation;
  if (path_fs == nullptr || path_fs[0] == '\0') {
    WriteError("Output path cannot be represented as a file-system path.", error_utf8,
               error_utf8_capacity);
    return false;
  }

  FILE* pcm_file = std::fopen(path_fs, "wb");
  if (pcm_file == nullptr) {
    WriteError("Failed to open output file.", error_utf8, error_utf8_capacity);
    return false;
  }

  if (sink == FileSink::kWav &&
      !WriteWavHeaderPlaceholder(pcm_file, sample_rate_hz, channel_count)) {
    std::fclose(pcm_file);
    WriteError("Failed to write WAV header.", error_utf8, error_utf8_capacity);
    return false;
  }

  *out_file = pcm_file;
  return true;
}

#if !TARGET_OS_IPHONE
AVCaptureDevice* ResolveMacosCaptureDevice(NSString* input_uid, char* error_utf8,
                                           uint32_t error_utf8_capacity) {
  AVCaptureDevice* default_device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];

  AVCaptureDeviceDiscoverySession* discovery =
      [AVCaptureDeviceDiscoverySession
          discoverySessionWithDeviceTypes:ResolveAudioCaptureDeviceTypes()
                                mediaType:AVMediaTypeAudio
                                 position:AVCaptureDevicePositionUnspecified];

  if (input_uid == nil || input_uid.length == 0) {
    if (default_device != nil) {
      return default_device;
    }
    if (discovery.devices.count > 0) {
      return discovery.devices.firstObject;
    }
    WriteError("No macOS audio capture device is available.", error_utf8, error_utf8_capacity);
    return nil;
  }

  if (default_device != nil && [default_device.uniqueID isEqualToString:input_uid]) {
    return default_device;
  }

  for (AVCaptureDevice* device in discovery.devices) {
    if ([device.uniqueID isEqualToString:input_uid]) {
      return device;
    }
  }

  WriteError("Selected macOS input device is not available.", error_utf8,
             error_utf8_capacity);
  return nil;
}
#endif

}  // namespace

}  // namespace speech_utils::native_recorder

@interface SpeechUtilsAudioSampleBufferDelegate
    : NSObject <AVCaptureAudioDataOutputSampleBufferDelegate>

- (instancetype)initWithRecorder:(speech_utils::native_recorder::NativeCaptureSessionRecorder*)recorder;

@end

@interface SpeechUtilsAudioFileRecordingDelegate : NSObject <AVCaptureFileOutputRecordingDelegate>

- (instancetype)initWithRecorder:(speech_utils::native_recorder::NativeCaptureSessionRecorder*)recorder;

@end

namespace speech_utils::native_recorder {

class NativeCaptureSessionRecorder {
 public:
  NativeCaptureSessionRecorder() {
    capture_queue_ = dispatch_queue_create(kRecorderCaptureQueueLabel, DISPATCH_QUEUE_SERIAL);
    processing_queue_ = dispatch_queue_create(kRecorderProcessingQueueLabel, DISPATCH_QUEUE_SERIAL);
  }

  ~NativeCaptureSessionRecorder() {
    char sink[1] = {0};
    (void)Reset(sink, sizeof(sink));
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
            discoverySessionWithDeviceTypes:ResolveAudioCaptureDeviceTypes()
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
    const CaptureSessionConfig requested_session_config = BuildCaptureSessionConfig(
        config, sink == FileSink::kAacM4A ? CaptureSessionOutputKind::kFile
                                          : CaptureSessionOutputKind::kData);

    while (true) {
      bool should_reset = false;
      bool can_reuse_continuous_session = false;

      {
        std::lock_guard<std::mutex> lock(mutex_);
        if (lifecycle_ == RecorderLifecycle::kRunning && mode_ == RecorderMode::kContinuous) {
          if (current_session_config_.IsCompatibleWith(requested_session_config)) {
            can_reuse_continuous_session = true;
          } else {
            should_reset = true;
          }
        } else if (lifecycle_ != RecorderLifecycle::kStopped) {
          WriteError("Recorder is already running.", error_utf8, error_utf8_capacity);
          return -6;
        }
      }

      if (should_reset) {
        const int32_t reset_code = Reset(error_utf8, error_utf8_capacity);
        if (reset_code != 0) {
          return reset_code;
        }
        continue;
      }

      if (can_reuse_continuous_session) {
        FILE* pcm_file = nullptr;
        if (!PreparePcmFileOutput(output_path, sink, config.sample_rate_hz, config.channel_count,
                                  &pcm_file, error_utf8, error_utf8_capacity)) {
          return -7;
        }

        {
          std::lock_guard<std::mutex> lock(mutex_);
          if (lifecycle_ != RecorderLifecycle::kRunning || mode_ != RecorderMode::kContinuous ||
              !current_session_config_.IsCompatibleWith(requested_session_config)) {
            std::fclose(pcm_file);
            WriteError("Continuous capture session is no longer available.", error_utf8,
                       error_utf8_capacity);
            return -8;
          }

          ApplyActiveModeLocked(RecorderMode::kFile, sink, requested_session_config,
                                /*frames_per_chunk=*/1024, pcm_file, nullptr,
                                /*wav_data_bytes=*/0);
          if (continuous_capture_enabled_) {
            warm_capture_config_ =
                BuildCaptureSessionConfig(config, CaptureSessionOutputKind::kData);
          }
        }
        accepting_samples_.store(true, std::memory_order_release);
        return 0;
      }

      return StartInternal(config, /*frames_per_chunk=*/1024, RecorderMode::kFile, sink,
                           output_path, error_utf8, error_utf8_capacity);
    }
  }

  int32_t StartStream(const speech_utils::recorder::RecorderStartConfig& config,
                      char* error_utf8, uint32_t error_utf8_capacity) {
    if (config.sample_rate_hz == 0 || config.channel_count == 0 || config.frames_per_chunk == 0) {
      WriteError("Sample rate, channel count, and frames_per_chunk must be > 0.", error_utf8,
                 error_utf8_capacity);
      return -1;
    }

    const CaptureSessionConfig requested_session_config =
        BuildCaptureSessionConfig(config, CaptureSessionOutputKind::kData);

    while (true) {
      bool should_reset = false;
      bool can_reuse_continuous_session = false;

      {
        std::lock_guard<std::mutex> lock(mutex_);
        if (lifecycle_ == RecorderLifecycle::kRunning && mode_ == RecorderMode::kContinuous) {
          if (current_session_config_.IsCompatibleWith(requested_session_config)) {
            can_reuse_continuous_session = true;
          } else {
            should_reset = true;
          }
        } else if (lifecycle_ != RecorderLifecycle::kStopped) {
          WriteError("Recorder is already running.", error_utf8, error_utf8_capacity);
          return -2;
        }
      }

      if (should_reset) {
        const int32_t reset_code = Reset(error_utf8, error_utf8_capacity);
        if (reset_code != 0) {
          return reset_code;
        }
        continue;
      }

      if (can_reuse_continuous_session) {
        {
          std::lock_guard<std::mutex> lock(mutex_);
          if (lifecycle_ != RecorderLifecycle::kRunning || mode_ != RecorderMode::kContinuous ||
              !current_session_config_.IsCompatibleWith(requested_session_config)) {
            WriteError("Continuous capture session is no longer available.", error_utf8,
                       error_utf8_capacity);
            return -3;
          }

          ApplyActiveModeLocked(RecorderMode::kStream, FileSink::kNone,
                                requested_session_config,
                                config.frames_per_chunk, nullptr, nullptr,
                                /*wav_data_bytes=*/0);
          if (continuous_capture_enabled_) {
            warm_capture_config_ =
                BuildCaptureSessionConfig(config, CaptureSessionOutputKind::kData);
          }
        }
        accepting_samples_.store(true, std::memory_order_release);
        return 0;
      }

      return StartInternal(config, config.frames_per_chunk, RecorderMode::kStream,
                           FileSink::kNone, nil, error_utf8, error_utf8_capacity);
    }
  }

  int32_t SetContinousCapture(int32_t enabled,
                              const speech_utils::recorder::RecorderStartConfig* start_config,
                              char* error_utf8,
                              uint32_t error_utf8_capacity) {
    const bool should_enable = enabled != 0;
    CaptureSessionConfig requested_warm_config{};

    if (should_enable) {
      if (start_config == nullptr) {
        WriteError("Start config pointer is null.", error_utf8, error_utf8_capacity);
        return -1;
      }
      if (start_config->sample_rate_hz == 0 || start_config->channel_count == 0) {
        WriteError("Sample rate and channel count must be > 0.", error_utf8, error_utf8_capacity);
        return -2;
      }
      requested_warm_config =
          BuildCaptureSessionConfig(*start_config, CaptureSessionOutputKind::kData);
    }

    bool should_reset = false;
    bool should_start_continuous = false;

    {
      std::lock_guard<std::mutex> lock(mutex_);
      continuous_capture_enabled_ = should_enable;
      if (should_enable) {
        warm_capture_config_ = requested_warm_config;
      }

      if (IsRecordingMode(mode_)) {
        return 0;
      }

      if (should_enable) {
        if (mode_ == RecorderMode::kContinuous &&
            current_session_config_.IsCompatibleWith(warm_capture_config_)) {
          ApplyActiveModeLocked(RecorderMode::kContinuous, FileSink::kNone,
                                warm_capture_config_, warm_capture_config_.frames_per_chunk,
                                nullptr, nullptr, /*wav_data_bytes=*/0);
          lifecycle_ = RecorderLifecycle::kRunning;
          return 0;
        }
        should_reset = lifecycle_ != RecorderLifecycle::kStopped;
        should_start_continuous = true;
      } else if (mode_ == RecorderMode::kContinuous) {
        should_reset = true;
      }
    }

    if (should_reset) {
      const int32_t reset_code = Reset(error_utf8, error_utf8_capacity);
      if (reset_code != 0) {
        return reset_code;
      }
    }

    if (!should_enable || !should_start_continuous) {
      return 0;
    }

    return StartContinuousSession(warm_capture_config_, error_utf8, error_utf8_capacity);
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
    return StopInternal(/*allow_keepalive=*/true, error_utf8, error_utf8_capacity);
  }

  int32_t Reset(char* error_utf8, uint32_t error_utf8_capacity) {
    return StopInternal(/*allow_keepalive=*/false, error_utf8, error_utf8_capacity);
  }

  int32_t IsRecording(int32_t* out_is_recording, char* error_utf8,
                      uint32_t error_utf8_capacity) {
    if (out_is_recording == nullptr) {
      WriteError("State output pointer is null.", error_utf8, error_utf8_capacity);
      return -1;
    }

    std::lock_guard<std::mutex> lock(mutex_);
    *out_is_recording = IsRecordingMode(mode_) ? 1 : 0;
    return 0;
  }

  int32_t GetAmplitude(double* out_current_dbfs, double* out_max_dbfs, char* error_utf8,
                       uint32_t error_utf8_capacity) {
    if (out_current_dbfs == nullptr || out_max_dbfs == nullptr) {
      WriteError("Amplitude output pointers must not be null.", error_utf8, error_utf8_capacity);
      return -1;
    }

    std::lock_guard<std::mutex> lock(mutex_);
    if (capture_file_output_ != nil) {
      AVCaptureConnection* connection = capture_file_output_.connections.firstObject;
      AVCaptureAudioChannel* channel = connection.audioChannels.firstObject;
      if (channel != nil) {
        const double dbfs = std::clamp(static_cast<double>(channel.averagePowerLevel), -90.0, 0.0);
        current_dbfs_ = dbfs;
        if (dbfs > max_dbfs_) {
          max_dbfs_ = dbfs;
        }
      }
    }
    *out_current_dbfs = current_dbfs_;
    *out_max_dbfs = max_dbfs_;
    return 0;
  }

  void HandleSampleBuffer(CMSampleBufferRef sample_buffer) {
    if (sample_buffer == nullptr) {
      return;
    }
    if (!accepting_samples_.load(std::memory_order_acquire)) {
      return;
    }
    if (!CMSampleBufferDataIsReady(sample_buffer)) {
      return;
    }

    const CMItemCount frame_count_raw = CMSampleBufferGetNumSamples(sample_buffer);
    if (frame_count_raw <= 0) {
      return;
    }
    const AVAudioFrameCount frame_count = static_cast<AVAudioFrameCount>(frame_count_raw);

    CMFormatDescriptionRef format_description = CMSampleBufferGetFormatDescription(sample_buffer);
    if (format_description == nullptr) {
      MarkDeferredError(-28, "Capture sample has no format description.");
      return;
    }

    const AudioStreamBasicDescription* asbd =
        CMAudioFormatDescriptionGetStreamBasicDescription(format_description);
    if (asbd == nullptr) {
      MarkDeferredError(-28, "Capture sample has no ASBD.");
      return;
    }
    if (asbd->mFormatID != kAudioFormatLinearPCM) {
      MarkDeferredError(-28, "Capture output format mismatch: expected linear PCM audio.");
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
    if (target_format == nil) {
      MarkDeferredError(-28, "Recorder target format is unavailable.");
      return;
    }

    const uint32_t source_channel_count = std::max<uint32_t>(asbd->mChannelsPerFrame, 1u);
    const UInt32 audio_buffer_count =
        static_cast<UInt32>(std::max<uint32_t>(source_channel_count, 1u));
    const UInt32 audio_buffer_list_size =
        static_cast<UInt32>(offsetof(AudioBufferList, mBuffers) +
                            sizeof(AudioBuffer) * audio_buffer_count);

    std::vector<uint8_t> audio_buffer_list_storage(audio_buffer_list_size, 0);
    AudioBufferList* audio_buffer_list =
        reinterpret_cast<AudioBufferList*>(audio_buffer_list_storage.data());

    CMBlockBufferRef block_buffer = nullptr;
    const OSStatus buffer_status = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
        sample_buffer, nullptr, audio_buffer_list, audio_buffer_list_size, kCFAllocatorDefault,
        kCFAllocatorDefault, 0, &block_buffer);

    auto release_block_buffer = [&]() {
      if (block_buffer != nullptr) {
        CFRelease(block_buffer);
        block_buffer = nullptr;
      }
    };

    if (buffer_status != noErr || audio_buffer_list->mNumberBuffers == 0) {
      release_block_buffer();
      MarkDeferredError(-28,
                       OsStatusToString("Failed to read capture sample audio buffers",
                                        buffer_status));
      return;
    }

    AVAudioFormat* source_format = [[AVAudioFormat alloc] initWithStreamDescription:asbd];
    if (source_format == nil) {
      release_block_buffer();
      MarkDeferredError(-28, "Failed to create source format from capture sample.");
      return;
    }

    AVAudioPCMBuffer* source_pcm_buffer =
        BuildPcmBufferFromAudioBufferList(audio_buffer_list, source_format, frame_count);
    release_block_buffer();
    if (source_pcm_buffer == nil) {
      MarkDeferredError(-28, "Failed to map capture sample into PCM buffer.");
      return;
    }

    AVAudioPCMBuffer* converted =
        ConvertToTargetPcm16(source_pcm_buffer, target_format, pcm_converter);
    if (converted == nil && !FormatsMatchPcm16(source_pcm_buffer.format, target_format)) {
      AVAudioConverter* adaptive_converter =
          [[AVAudioConverter alloc] initFromFormat:source_pcm_buffer.format toFormat:target_format];
      if (adaptive_converter != nil) {
        adaptive_converter.sampleRateConverterQuality = AVAudioQualityHigh;
#if TARGET_OS_IPHONE
        if (@available(iOS 13.0, *)) {
          adaptive_converter.primeMethod = AVAudioConverterPrimeMethod_None;
        }
#else
        if (@available(macOS 10.15, *)) {
          adaptive_converter.primeMethod = AVAudioConverterPrimeMethod_None;
        }
#endif
        converted = ConvertToTargetPcm16(source_pcm_buffer, target_format, adaptive_converter);
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
          "Failed to convert capture sample into recorder PCM format (sample-rate/channel mismatch).");
      return;
    }

    if (converted.frameLength == 0 || converted.format.channelCount == 0) {
      return;
    }

    const AVAudioFrameCount converted_frame_count = converted.frameLength;
    const uint32_t converted_channel_count = static_cast<uint32_t>(converted.format.channelCount);
    const AudioBufferList* converted_audio_buffers = converted.audioBufferList;
    if (converted_audio_buffers == nullptr || converted_audio_buffers->mNumberBuffers == 0) {
      return;
    }

    std::vector<int16_t> captured_samples;
    std::vector<int16_t> interleaved_scratch;

    if (converted.format.isInterleaved) {
      const AudioBuffer& buffer = converted_audio_buffers->mBuffers[0];
      const std::size_t expected_sample_count =
          static_cast<std::size_t>(converted_frame_count) * converted_channel_count;
      if (buffer.mData == nullptr || expected_sample_count == 0 ||
          buffer.mDataByteSize < expected_sample_count * sizeof(int16_t)) {
        MarkDeferredError(-28, "Converted PCM buffer is missing interleaved PCM16 payload.");
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
          MarkDeferredError(-28, "Converted PCM buffer has fewer channel buffers than expected.");
          return;
        }
        for (uint32_t channel = 0; channel < converted_channel_count; channel++) {
          const AudioBuffer& channel_buffer = converted_audio_buffers->mBuffers[channel];
          if (channel_buffer.mData == nullptr ||
              channel_buffer.mDataByteSize < converted_frame_count * sizeof(int16_t)) {
            MarkDeferredError(-28, "Converted PCM channel buffer is missing payload.");
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

    NativeCaptureSessionRecorder* callback_self = this;
    dispatch_async(processing_queue_, ^{
      if (callback_self != nullptr) {
        callback_self->ProcessCapturedSamples(samples);
        callback_self->pending_samples_.fetch_sub(samples->size(), std::memory_order_acq_rel);
      }
    });
  }

  void HandleFileOutputStarted(AVCaptureFileOutput* output) {
    bool should_stop_recording = false;
    {
      std::lock_guard<std::mutex> lock(mutex_);
      if (output == nil || output != capture_file_output_) {
        return;
      }
      switch (capture_file_lifecycle_) {
        case CaptureFileLifecycle::kStarting:
          capture_file_lifecycle_ = CaptureFileLifecycle::kRunning;
          break;
        case CaptureFileLifecycle::kStopRequested:
          should_stop_recording = true;
          break;
        case CaptureFileLifecycle::kInactive:
        case CaptureFileLifecycle::kRunning:
        case CaptureFileLifecycle::kFinished:
          break;
      }
    }
    if (should_stop_recording && output != nil) {
      [output stopRecording];
    }
  }

  void HandleFileOutputFinished(AVCaptureFileOutput* output, NSError* error) {
    dispatch_semaphore_t stop_semaphore = nullptr;
    if (error != nil) {
      bool should_mark_error = false;
      {
        std::lock_guard<std::mutex> lock(mutex_);
        should_mark_error = output != nil && output == capture_file_output_;
      }

      if (should_mark_error) {
        NSNumber* success_value = error.userInfo[AVErrorRecordingSuccessfullyFinishedKey];
        const bool success = success_value != nil && success_value.boolValue;
        if (!success) {
          std::string message("AVCaptureAudioFileOutput failed");
          if (error.localizedDescription != nil) {
            message.append(": ");
            message.append([[error.localizedDescription description] UTF8String]);
          }
          MarkDeferredError(-31, message);
        }
      }
    }

    {
      std::lock_guard<std::mutex> lock(mutex_);
      if (output == nil || output != capture_file_output_) {
        return;
      }
      capture_file_lifecycle_ = CaptureFileLifecycle::kFinished;
      stop_semaphore = capture_file_stop_semaphore_;
      capture_file_stop_semaphore_ = nullptr;
    }
    if (stop_semaphore != nullptr) {
      dispatch_semaphore_signal(stop_semaphore);
    }
  }

 private:
  int32_t StopInternal(bool allow_keepalive, char* error_utf8,
                       uint32_t error_utf8_capacity) {
    AVCaptureSession* capture_session = nil;
    AVCaptureAudioDataOutput* capture_output = nil;
    AVCaptureAudioFileOutput* capture_file_output = nil;
    FileSink file_sink = FileSink::kNone;
    dispatch_semaphore_t capture_file_stop_semaphore = nullptr;
    CaptureFileLifecycle capture_file_lifecycle = CaptureFileLifecycle::kInactive;

    FILE* pcm_file = nullptr;
    ExtAudioFileRef aac_file = nullptr;
    uint32_t wav_data_bytes = 0;
    uint32_t sample_rate_hz = 0;
    uint32_t channel_count = 0;

    int32_t deferred_code = 0;
    std::string deferred_error;
    uint64_t processed_sample_count = 0;
    bool keep_session_running = false;
    bool should_restart_continuous = false;
    CaptureSessionConfig restart_continuous_config{};
    bool had_active_recording = false;

    {
      std::lock_guard<std::mutex> lock(mutex_);
      if (lifecycle_ == RecorderLifecycle::kStopped) {
        return 0;
      }

      had_active_recording = IsRecordingMode(mode_);
      if (allow_keepalive && mode_ == RecorderMode::kContinuous) {
        return 0;
      }

      lifecycle_ = RecorderLifecycle::kStopping;
      file_sink = file_sink_;
      restart_continuous_config = warm_capture_config_;
      keep_session_running =
          allow_keepalive && had_active_recording && continuous_capture_enabled_ &&
          warm_capture_config_.IsValid() && current_session_config_.IsCompatibleWith(warm_capture_config_) &&
          current_session_config_.output_kind == CaptureSessionOutputKind::kData &&
          capture_session_ != nil;
      should_restart_continuous =
          allow_keepalive && had_active_recording && continuous_capture_enabled_ &&
          warm_capture_config_.IsValid() && !keep_session_running;

      if (!keep_session_running) {
        capture_session = capture_session_;
        capture_output = capture_output_;
        capture_file_output = capture_file_output_;
        if (capture_file_output_ != nil && file_sink_ == FileSink::kAacM4A) {
          capture_file_lifecycle = capture_file_lifecycle_;
          if (CaptureFileLifecycleNeedsStopWait(capture_file_lifecycle_)) {
            capture_file_stop_semaphore = capture_file_stop_semaphore_;
            if (capture_file_stop_semaphore == nullptr) {
              capture_file_stop_semaphore = dispatch_semaphore_create(0);
              capture_file_stop_semaphore_ = capture_file_stop_semaphore;
            }
            capture_file_lifecycle_ = CaptureFileLifecycle::kStopRequested;
          }
        }
      }
      accepting_samples_.store(false, std::memory_order_release);
    }

    if (keep_session_running) {
      if (capture_queue_ != nullptr) {
        dispatch_sync(capture_queue_, ^{});
      }
      if (processing_queue_ != nullptr) {
        dispatch_sync(processing_queue_, ^{});
      }

      {
        std::lock_guard<std::mutex> lock(mutex_);
        processed_sample_count = processed_sample_count_.load(std::memory_order_acquire);
        pcm_file = pcm_file_;
        aac_file = aac_file_;
        wav_data_bytes = wav_data_bytes_;
        sample_rate_hz = sample_rate_hz_;
        channel_count = channel_count_;

        if (deferred_code == 0) {
          deferred_code = deferred_error_code_;
          deferred_error = deferred_error_;
        }

        ApplyActiveModeLocked(RecorderMode::kContinuous, FileSink::kNone, warm_capture_config_,
                              warm_capture_config_.frames_per_chunk, nullptr, nullptr,
                              /*wav_data_bytes=*/0);
        lifecycle_ = RecorderLifecycle::kRunning;
      }

      accepting_samples_.store(true, std::memory_order_release);
    } else {
      if (capture_output != nil) {
        [capture_output setSampleBufferDelegate:nil queue:nil];
      }
      const bool uses_capture_file_output =
          capture_file_output != nil && file_sink == FileSink::kAacM4A;
      const bool should_wait_for_capture_file_output =
          uses_capture_file_output && CaptureFileLifecycleNeedsStopWait(capture_file_lifecycle);
      const bool capture_file_output_has_started =
          uses_capture_file_output &&
          (capture_file_lifecycle == CaptureFileLifecycle::kRunning || capture_file_output.recording);
      if (should_wait_for_capture_file_output && capture_file_output_has_started) {
        [capture_file_output stopRecording];
      }
      if (capture_session != nil && capture_session.running &&
          (!uses_capture_file_output || capture_file_output_has_started)) {
        [capture_session stopRunning];
      }
      if (should_wait_for_capture_file_output) {
        if (!WaitForSemaphoreWithMainRunLoop(capture_file_stop_semaphore,
                                             kCaptureFileStopTimeoutNanos) &&
            deferred_code == 0) {
          deferred_code = -43;
          deferred_error =
              "Timed out while waiting for AVCaptureAudioFileOutput to finish recording.";
        }
      }
      if (capture_session != nil && capture_session.running) {
        [capture_session stopRunning];
      }

      if (capture_queue_ != nullptr) {
        dispatch_sync(capture_queue_, ^{});
      }
      if (processing_queue_ != nullptr) {
        dispatch_sync(processing_queue_, ^{});
      }

      {
        std::lock_guard<std::mutex> lock(mutex_);
        processed_sample_count = processed_sample_count_.load(std::memory_order_acquire);
        pcm_file = pcm_file_;
        aac_file = aac_file_;
        wav_data_bytes = wav_data_bytes_;
        sample_rate_hz = sample_rate_hz_;
        channel_count = channel_count_;

        if (deferred_code == 0) {
          deferred_code = deferred_error_code_;
          deferred_error = deferred_error_;
        }

        mode_ = RecorderMode::kStopped;
        lifecycle_ = RecorderLifecycle::kStopped;
        ClearBufferedAudioLocked();
        pending_samples_.store(0, std::memory_order_release);
        pending_sample_limit_.store(0, std::memory_order_release);
        capture_session_ = nil;
        capture_input_ = nil;
        capture_output_ = nil;
        capture_file_output_ = nil;
        capture_delegate_ = nil;
        capture_file_delegate_ = nil;
        capture_file_stop_semaphore_ = nullptr;
        capture_file_lifecycle_ = CaptureFileLifecycle::kInactive;
        target_format_ = nil;
        pcm_converter_ = nil;
        current_session_config_ = {};
        file_sink_ = FileSink::kNone;
        pcm_file_ = nullptr;
        aac_file_ = nullptr;
        wav_data_bytes_ = 0;
        sample_rate_hz_ = 0;
        channel_count_ = 0;
        ResetAmplitudeStateLocked();
        deferred_error_code_ = 0;
        deferred_error_.clear();
      }

#if TARGET_OS_IPHONE
      [AVAudioSession.sharedInstance setActive:NO error:nil];
#endif
    }

    if (had_active_recording && file_sink != FileSink::kAacM4A && processed_sample_count == 0 &&
        deferred_code == 0) {
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

    if (file_sink == FileSink::kAacM4A && capture_file_output != nil) {
      // AAC file capture is finalized by AVCaptureAudioFileOutput delegate callback.
    } else if (file_sink == FileSink::kAacM4A && aac_file != nullptr) {
      const OSStatus dispose_status = ExtAudioFileDispose(aac_file);
      if (dispose_status != noErr && deferred_code == 0) {
        deferred_code = -33;
        deferred_error = OsStatusToString("Failed to finalize AAC output file", dispose_status);
      }
    } else if (file_sink == FileSink::kAacM4A && had_active_recording && deferred_code == 0) {
      deferred_code = -33;
      deferred_error = "AAC output handle is unavailable.";
    }

    if (should_restart_continuous) {
      const int32_t restart_code =
          StartContinuousSession(restart_continuous_config, error_utf8, error_utf8_capacity);
      if (restart_code != 0 && deferred_code == 0) {
        return restart_code;
      }
    }

    if (deferred_code != 0) {
      WriteError(deferred_error, error_utf8, error_utf8_capacity);
      return deferred_code;
    }

    return 0;
  }

  int32_t StartContinuousSession(const CaptureSessionConfig& session_config, char* error_utf8,
                                 uint32_t error_utf8_capacity) {
    if (!session_config.IsValid()) {
      return 0;
    }

    std::string input_device_id_storage = session_config.input_device_id;
    speech_utils::recorder::RecorderStartConfig start_config{};
    start_config.sample_rate_hz = session_config.sample_rate_hz;
    start_config.channel_count = session_config.channel_count;
    start_config.frames_per_chunk =
        session_config.frames_per_chunk > 0 ? session_config.frames_per_chunk : 1024;
    start_config.output_path_utf8 = nullptr;
    start_config.input_device_id_utf8 =
        input_device_id_storage.empty() ? nullptr : input_device_id_storage.c_str();
    start_config.runtime = {};
    start_config.runtime.macos_processing_queue_duration_seconds =
        session_config.macos_processing_queue_duration_seconds;

    return StartInternal(start_config, start_config.frames_per_chunk, RecorderMode::kContinuous,
                         FileSink::kNone, nil, error_utf8, error_utf8_capacity);
  }

  void ResetAmplitudeStateLocked() {
    current_dbfs_ = -90.0;
    max_dbfs_ = -90.0;
  }

  void ClearBufferedAudioLocked() {
    stream_samples_.clear();
    stream_sample_limit_ = 0;
  }

  void ApplyActiveModeLocked(RecorderMode mode, FileSink sink,
                             const CaptureSessionConfig& session_config,
                             uint32_t frames_per_chunk, FILE* pcm_file,
                             ExtAudioFileRef aac_file, uint32_t wav_data_bytes) {
    mode_ = mode;
    file_sink_ = sink;
    current_session_config_ = session_config;
    sample_rate_hz_ = session_config.sample_rate_hz;
    channel_count_ = session_config.channel_count;
    ClearBufferedAudioLocked();

    if (mode == RecorderMode::kStream) {
      stream_sample_limit_ =
          std::max<std::size_t>(
              static_cast<std::size_t>(session_config.sample_rate_hz) *
                  session_config.channel_count * 5,
              static_cast<std::size_t>(frames_per_chunk) * session_config.channel_count * 16);
    }

    const std::size_t default_pending_limit =
        std::max<std::size_t>(
            static_cast<std::size_t>(session_config.sample_rate_hz) *
                session_config.channel_count * 2,
            static_cast<std::size_t>(frames_per_chunk) * session_config.channel_count * 32);
    const double requested_queue_duration_seconds =
        session_config.macos_processing_queue_duration_seconds;
    const std::size_t requested_pending_limit =
        requested_queue_duration_seconds <= 0.0
            ? 0
            : static_cast<std::size_t>(std::max<double>(
                  1.0, requested_queue_duration_seconds * session_config.sample_rate_hz *
                           session_config.channel_count));
    pending_sample_limit_.store(
        requested_pending_limit > 0 ? requested_pending_limit : default_pending_limit,
        std::memory_order_release);
    pending_samples_.store(0, std::memory_order_release);
    processed_sample_count_.store(0, std::memory_order_release);

    pcm_file_ = pcm_file;
    aac_file_ = aac_file;
    wav_data_bytes_ = wav_data_bytes;

    deferred_error_code_ = 0;
    deferred_error_.clear();
    ResetAmplitudeStateLocked();
  }

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

    bool reset_start_state_on_failure = false;
    auto cleanup_start_state = [&](int*) {
      if (!reset_start_state_on_failure) {
        return;
      }

      std::lock_guard<std::mutex> lock(mutex_);
      mode_ = RecorderMode::kStopped;
      lifecycle_ = RecorderLifecycle::kStopped;
      file_sink_ = FileSink::kNone;
      capture_session_ = nil;
      capture_input_ = nil;
      capture_output_ = nil;
      capture_file_output_ = nil;
      capture_delegate_ = nil;
      capture_file_delegate_ = nil;
      capture_file_stop_semaphore_ = nullptr;
      capture_file_lifecycle_ = CaptureFileLifecycle::kInactive;
      target_format_ = nil;
      pcm_converter_ = nil;
      current_session_config_ = {};
      sample_rate_hz_ = 0;
      channel_count_ = 0;
      ClearBufferedAudioLocked();
      pending_samples_.store(0, std::memory_order_release);
      pending_sample_limit_.store(0, std::memory_order_release);
      processed_sample_count_.store(0, std::memory_order_release);
      pcm_file_ = nullptr;
      aac_file_ = nullptr;
      wav_data_bytes_ = 0;
      ResetAmplitudeStateLocked();
      deferred_error_code_ = 0;
      deferred_error_.clear();
    };
    std::unique_ptr<int, decltype(cleanup_start_state)> start_state_guard(
        reinterpret_cast<int*>(1), cleanup_start_state);

    {
      std::lock_guard<std::mutex> lock(mutex_);
      if (lifecycle_ != RecorderLifecycle::kStopped) {
        WriteError("Recorder is already running.", error_utf8, error_utf8_capacity);
        return -6;
      }
      lifecycle_ = RecorderLifecycle::kStarting;
      file_sink_ = FileSink::kNone;
      capture_file_stop_semaphore_ = nullptr;
      capture_file_lifecycle_ = CaptureFileLifecycle::kInactive;
    }
    reset_start_state_on_failure = true;
    accepting_samples_.store(false, std::memory_order_release);
    pending_samples_.store(0, std::memory_order_release);
    pending_sample_limit_.store(0, std::memory_order_release);

    const std::string trimmed_device_id = TrimWhitespace(TrimAscii(config.input_device_id_utf8));

#if TARGET_OS_IPHONE
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
#endif

    bool use_capture_file_output = false;
#if !TARGET_OS_IPHONE
    use_capture_file_output =
        mode == RecorderMode::kFile && sink == FileSink::kAacM4A;
#endif
    const CaptureSessionConfig requested_session_config = BuildCaptureSessionConfig(
        config, use_capture_file_output ? CaptureSessionOutputKind::kFile
                                        : CaptureSessionOutputKind::kData);

    AVAudioFormat* target_format = nil;
    if (!use_capture_file_output) {
      target_format = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt16
                                                        sampleRate:static_cast<double>(config.sample_rate_hz)
                                                          channels:config.channel_count
                                                       interleaved:NO];
      if (target_format == nil) {
        WriteError("Failed to create target PCM16 format.", error_utf8, error_utf8_capacity);
        return -10;
      }
    }

    FILE* pcm_file = nullptr;
    ExtAudioFileRef aac_file = nullptr;
    uint32_t wav_data_bytes = 0;

    auto ClosePendingOutputs = [&]() {
      if (pcm_file != nullptr) {
        std::fclose(pcm_file);
        pcm_file = nullptr;
      }
      if (aac_file != nullptr) {
        (void)ExtAudioFileDispose(aac_file);
        aac_file = nullptr;
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
          pcm_file = nullptr;
          WriteError("Failed to write WAV header.", error_utf8, error_utf8_capacity);
          return -15;
        }
      } else if (sink == FileSink::kAacM4A && !use_capture_file_output) {
        if (!CreateAacOutputFile(output_path, config.sample_rate_hz, config.channel_count,
                                 config.runtime.file_bitrate_bps,
                                 config.runtime.file_encoder_code, &aac_file, error_utf8,
                                 error_utf8_capacity)) {
          return -16;
        }
      }
    }

    AVCaptureDevice* capture_device = nil;
#if TARGET_OS_IPHONE
    capture_device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    if (capture_device == nil) {
      AVCaptureDeviceDiscoverySession* discovery =
          [AVCaptureDeviceDiscoverySession
              discoverySessionWithDeviceTypes:ResolveAudioCaptureDeviceTypes()
                                    mediaType:AVMediaTypeAudio
                                     position:AVCaptureDevicePositionUnspecified];
      capture_device = discovery.devices.firstObject;
    }
#else
    NSString* requested_uid = nil;
    if (!trimmed_device_id.empty()) {
      requested_uid = [NSString stringWithUTF8String:trimmed_device_id.c_str()];
      if (requested_uid == nil || requested_uid.length == 0) {
        ClosePendingOutputs();
        WriteError("Input device id UTF-8 decoding failed.", error_utf8, error_utf8_capacity);
        return -23;
      }
    }
    capture_device = ResolveMacosCaptureDevice(requested_uid, error_utf8, error_utf8_capacity);
#endif

    if (capture_device == nil) {
      ClosePendingOutputs();
      WriteError("No audio capture device is available.", error_utf8, error_utf8_capacity);
      return -21;
    }

    AVCaptureSession* capture_session = [[AVCaptureSession alloc] init];
    if (capture_session == nil) {
      ClosePendingOutputs();
      WriteError("Failed to initialize AVCaptureSession.", error_utf8, error_utf8_capacity);
      return -21;
    }

#if TARGET_OS_IPHONE
    if ([capture_session respondsToSelector:@selector(setAutomaticallyConfiguresApplicationAudioSession:)]) {
      capture_session.automaticallyConfiguresApplicationAudioSession = NO;
    }
#endif

    NSError* input_error = nil;
    AVCaptureDeviceInput* capture_input =
        [AVCaptureDeviceInput deviceInputWithDevice:capture_device error:&input_error];
    if (capture_input == nil) {
      ClosePendingOutputs();
      WriteNSError(input_error, "Failed to create AVCaptureDeviceInput", error_utf8,
                   error_utf8_capacity);
      return -22;
    }

    AVCaptureAudioDataOutput* capture_output = nil;
    SpeechUtilsAudioSampleBufferDelegate* capture_delegate = nil;
    AVCaptureAudioFileOutput* capture_file_output = nil;
    SpeechUtilsAudioFileRecordingDelegate* capture_file_delegate = nil;
    NSURL* output_url = nil;

    if (use_capture_file_output) {
      capture_file_output = [[AVCaptureAudioFileOutput alloc] init];
      if (capture_file_output == nil) {
        ClosePendingOutputs();
        WriteError("Failed to initialize AVCaptureAudioFileOutput.", error_utf8,
                   error_utf8_capacity);
        return -25;
      }
      capture_file_delegate =
          [[SpeechUtilsAudioFileRecordingDelegate alloc] initWithRecorder:this];
      output_url = [NSURL fileURLWithPath:output_path];
      if (output_url == nil) {
        ClosePendingOutputs();
        WriteError("Failed to create output URL for capture file output.", error_utf8,
                   error_utf8_capacity);
        return -16;
      }
    } else {
      capture_output = [[AVCaptureAudioDataOutput alloc] init];
      if (capture_output == nil) {
        ClosePendingOutputs();
        WriteError("Failed to initialize AVCaptureAudioDataOutput.", error_utf8,
                   error_utf8_capacity);
        return -25;
      }

      capture_output.audioSettings =
          BuildCaptureAudioOutputSettings(config.sample_rate_hz, config.channel_count);

      capture_delegate =
          [[SpeechUtilsAudioSampleBufferDelegate alloc] initWithRecorder:this];
    }

    [capture_session beginConfiguration];
    if (![capture_session canAddInput:capture_input]) {
      [capture_session commitConfiguration];
      ClosePendingOutputs();
      WriteError("AVCaptureSession cannot add selected microphone input.", error_utf8,
                 error_utf8_capacity);
      return -23;
    }
    [capture_session addInput:capture_input];

    if (use_capture_file_output) {
      if (![capture_session canAddOutput:capture_file_output]) {
        [capture_session commitConfiguration];
        ClosePendingOutputs();
        WriteError("AVCaptureSession cannot add audio file output.", error_utf8,
                   error_utf8_capacity);
        return -26;
      }

      [capture_session addOutput:capture_file_output];
      capture_file_output.audioSettings = BuildCaptureAacFileOutputSettings(
          config.sample_rate_hz, config.channel_count, config.runtime.file_bitrate_bps);
    } else {
      if (![capture_session canAddOutput:capture_output]) {
        [capture_session commitConfiguration];
        ClosePendingOutputs();
        WriteError("AVCaptureSession cannot add audio output.", error_utf8, error_utf8_capacity);
        return -26;
      }

      [capture_output setSampleBufferDelegate:capture_delegate queue:capture_queue_];
      [capture_session addOutput:capture_output];
    }
    [capture_session commitConfiguration];

    [capture_session startRunning];
    if (!capture_session.running) {
      if (capture_output != nil) {
        [capture_output setSampleBufferDelegate:nil queue:nil];
      }
      ClosePendingOutputs();
#if TARGET_OS_IPHONE
      [AVAudioSession.sharedInstance setActive:NO error:nil];
#endif
      WriteError("Failed to start AVCaptureSession.", error_utf8, error_utf8_capacity);
      return -27;
    }

    bool start_was_cancelled = false;
    {
      std::lock_guard<std::mutex> lock(mutex_);
      start_was_cancelled = lifecycle_ != RecorderLifecycle::kStarting;
    }
    if (start_was_cancelled) {
      if (capture_output != nil) {
        [capture_output setSampleBufferDelegate:nil queue:nil];
      }
      [capture_session stopRunning];
      ClosePendingOutputs();
#if TARGET_OS_IPHONE
      [AVAudioSession.sharedInstance setActive:NO error:nil];
#endif
      WriteError("Recorder was stopped while starting.", error_utf8, error_utf8_capacity);
      return -44;
    }

    {
      std::lock_guard<std::mutex> lock(mutex_);
      capture_session_ = capture_session;
      capture_input_ = capture_input;
      capture_output_ = capture_output;
      capture_file_output_ = capture_file_output;
      capture_delegate_ = capture_delegate;
      capture_file_delegate_ = capture_file_delegate;
      capture_file_stop_semaphore_ = nullptr;
      capture_file_lifecycle_ =
          use_capture_file_output ? CaptureFileLifecycle::kStarting
                                  : CaptureFileLifecycle::kInactive;
      target_format_ = target_format;
      pcm_converter_ = nil;
      ApplyActiveModeLocked(mode, sink, requested_session_config, frames_per_chunk, pcm_file,
                            aac_file, wav_data_bytes);
      if (continuous_capture_enabled_) {
        warm_capture_config_ = BuildCaptureSessionConfig(config, CaptureSessionOutputKind::kData);
      }
    }

    if (use_capture_file_output) {
      [capture_file_output startRecordingToOutputFileURL:output_url
                                           outputFileType:AVFileTypeAppleM4A
                                         recordingDelegate:capture_file_delegate];
      // Recording state flips asynchronously; avoid synchronous `recording` checks here.
    }

    accepting_samples_.store(true, std::memory_order_release);
    {
      std::lock_guard<std::mutex> lock(mutex_);
      if (lifecycle_ == RecorderLifecycle::kStarting) {
        lifecycle_ = RecorderLifecycle::kRunning;
      }
    }
    reset_start_state_on_failure = false;
    (void)start_state_guard.release();
    return 0;
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
    ExtAudioFileRef aac_file = nullptr;
    uint32_t channel_count = 0;

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
      aac_file = aac_file_;
      channel_count = channel_count_;
    }

    if (mode != RecorderMode::kFile) {
      return;
    }

    if (sink == FileSink::kAacM4A) {
      if (aac_file == nullptr || channel_count == 0) {
        MarkDeferredError(-30, "AAC output handle is unavailable for recorder file capture.");
        return;
      }

      const std::size_t frame_count = sample_count / channel_count;
      if (frame_count == 0 ||
          frame_count * static_cast<std::size_t>(channel_count) != sample_count) {
        MarkDeferredError(-31, "Captured PCM block is not aligned to AAC channel layout.");
        return;
      }

      AudioBufferList buffer_list{};
      buffer_list.mNumberBuffers = 1;
      buffer_list.mBuffers[0].mNumberChannels = channel_count;
      buffer_list.mBuffers[0].mData = const_cast<int16_t*>(sample_data);
      buffer_list.mBuffers[0].mDataByteSize =
          static_cast<UInt32>(sample_count * sizeof(int16_t));
      const OSStatus status =
          ExtAudioFileWrite(aac_file, static_cast<UInt32>(frame_count), &buffer_list);
      if (status != noErr) {
        MarkDeferredError(-31, OsStatusToString("Failed to write AAC frames", status));
      }
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

  dispatch_queue_t capture_queue_ = nullptr;
  dispatch_queue_t processing_queue_ = nullptr;

  std::atomic<bool> accepting_samples_{false};
  std::atomic<std::size_t> pending_samples_{0};
  std::atomic<std::size_t> pending_sample_limit_{0};
  std::atomic<uint64_t> processed_sample_count_{0};

  std::mutex mutex_;

  RecorderMode mode_ = RecorderMode::kStopped;
  RecorderLifecycle lifecycle_ = RecorderLifecycle::kStopped;
  bool continuous_capture_enabled_ = false;
  FileSink file_sink_ = FileSink::kNone;
  CaptureSessionConfig current_session_config_{};
  CaptureSessionConfig warm_capture_config_{};

  AVCaptureSession* capture_session_ = nil;
  AVCaptureDeviceInput* capture_input_ = nil;
  AVCaptureAudioDataOutput* capture_output_ = nil;
  AVCaptureAudioFileOutput* capture_file_output_ = nil;
  SpeechUtilsAudioSampleBufferDelegate* capture_delegate_ = nil;
  SpeechUtilsAudioFileRecordingDelegate* capture_file_delegate_ = nil;
  dispatch_semaphore_t capture_file_stop_semaphore_ = nullptr;
  CaptureFileLifecycle capture_file_lifecycle_ = CaptureFileLifecycle::kInactive;
  AVAudioFormat* target_format_ = nil;
  AVAudioConverter* pcm_converter_ = nil;

  uint32_t sample_rate_hz_ = 0;
  uint32_t channel_count_ = 0;

  std::deque<int16_t> stream_samples_;
  std::size_t stream_sample_limit_ = 0;

  FILE* pcm_file_ = nullptr;
  ExtAudioFileRef aac_file_ = nullptr;
  uint32_t wav_data_bytes_ = 0;

  double current_dbfs_ = -90.0;
  double max_dbfs_ = -90.0;

  int32_t deferred_error_code_ = 0;
  std::string deferred_error_;
};

namespace {
NativeCaptureSessionRecorder g_recorder;
}

}  // namespace speech_utils::native_recorder

@implementation SpeechUtilsAudioSampleBufferDelegate {
  speech_utils::native_recorder::NativeCaptureSessionRecorder* _recorder;
}

- (instancetype)initWithRecorder:(speech_utils::native_recorder::NativeCaptureSessionRecorder*)recorder {
  self = [super init];
  if (self != nil) {
    _recorder = recorder;
  }
  return self;
}

- (void)captureOutput:(AVCaptureOutput*)output
    didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
           fromConnection:(AVCaptureConnection*)connection {
  (void)output;
  (void)connection;
  if (_recorder != nullptr) {
    _recorder->HandleSampleBuffer(sampleBuffer);
  }
}

@end

@implementation SpeechUtilsAudioFileRecordingDelegate {
  speech_utils::native_recorder::NativeCaptureSessionRecorder* _recorder;
}

- (instancetype)initWithRecorder:(speech_utils::native_recorder::NativeCaptureSessionRecorder*)recorder {
  self = [super init];
  if (self != nil) {
    _recorder = recorder;
  }
  return self;
}

- (void)captureOutput:(AVCaptureFileOutput*)output
    didStartRecordingToOutputFileAtURL:(NSURL*)outputFileURL
                         fromConnections:(NSArray<AVCaptureConnection*>*)connections {
  (void)outputFileURL;
  (void)connections;
  if (_recorder != nullptr) {
    _recorder->HandleFileOutputStarted(output);
  }
}

- (void)captureOutput:(AVCaptureFileOutput*)output
    didFinishRecordingToOutputFileAtURL:(NSURL*)outputFileURL
                         fromConnections:(NSArray<AVCaptureConnection*>*)connections
                                   error:(NSError*)error {
  (void)outputFileURL;
  (void)connections;
  if (_recorder != nullptr) {
    _recorder->HandleFileOutputFinished(output, error);
  }
}

@end

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
#if TARGET_OS_IPHONE
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

  return RequiresVoiceProcessing(processing_flags) ? AVAudioSessionModeVoiceChat
                                                   : AVAudioSessionModeDefault;
#else
  (void)ios_session_mode_code;
  (void)processing_flags;
  return nil;
#endif
}

AVAudioSessionCategoryOptions ResolveIosCategoryOptions(uint32_t ios_category_options_flags) {
#if TARGET_OS_IPHONE
  AVAudioSessionCategoryOptions options = 0;
  if ((ios_category_options_flags & (1u << 0)) != 0u) {
    options |= AVAudioSessionCategoryOptionAllowBluetoothHFP;
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
#else
  (void)ios_category_options_flags;
  return 0;
#endif
}

bool RequiresVoiceProcessing(int32_t processing_flags) {
  const int32_t mask = kProcessingFlagPresetVoice | kProcessingFlagPresetVoiceIsolation;
  return (processing_flags & mask) != 0;
}

AudioFormatID ResolveNativeAacFormatId(int32_t file_encoder_code) {
  // AVCaptureSession live capture + ExtAudioFile is most reliable with AAC-LC.
  // Ignore profile hints for direct recorder writes and keep a stable format.
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

int32_t SetContinousCapture(int32_t enabled,
                            const speech_utils::recorder::RecorderStartConfig* start_config,
                            char* error_utf8,
                            uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  @autoreleasepool {
    return g_recorder.SetContinousCapture(enabled, start_config, error_utf8,
                                          error_utf8_capacity);
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

