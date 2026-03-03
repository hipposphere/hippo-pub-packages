#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMedia/CoreMedia.h>
#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

#include <algorithm>
#include <cctype>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <limits>
#include <string>
#include <vector>

#include "speech_utils_native_audio_codec.h"

namespace {

std::string EffectivePlatformName(const char* platform_name) {
  if (platform_name == nullptr || platform_name[0] == '\0') {
    return "Apple";
  }
  return platform_name;
}

void WriteError(const std::string& message, char* out_error_utf8, uint32_t out_error_capacity) {
  if (out_error_utf8 == nullptr || out_error_capacity == 0) {
    return;
  }

  const auto copy_len = static_cast<uint32_t>(
      std::min<std::size_t>(message.size(), static_cast<std::size_t>(out_error_capacity - 1)));
  std::memcpy(out_error_utf8, message.data(), copy_len);
  out_error_utf8[copy_len] = '\0';
}

void WriteOutputText(const std::string& text, char* out_utf8, uint32_t out_utf8_capacity) {
  if (out_utf8 == nullptr || out_utf8_capacity == 0) {
    return;
  }
  const auto copy_len = static_cast<uint32_t>(
      std::min<std::size_t>(text.size(), static_cast<std::size_t>(out_utf8_capacity - 1)));
  std::memcpy(out_utf8, text.data(), copy_len);
  out_utf8[copy_len] = '\0';
}

std::string NormalizeProfile(std::string profile) {
  for (char& ch : profile) {
    ch = static_cast<char>(std::tolower(static_cast<unsigned char>(ch)));
  }

  if (profile.find("hev2") != std::string::npos || profile.find("hev-2") != std::string::npos ||
      profile.find("he-aacv2") != std::string::npos) {
    return "hev2";
  }
  if (profile.find("eld") != std::string::npos) {
    return "eld";
  }
  if (profile.find("he") != std::string::npos || profile.find("sbr") != std::string::npos) {
    return "he";
  }
  if (profile.find("lc") != std::string::npos || profile.find("low") != std::string::npos) {
    return "lc";
  }
  if (profile.find("main") != std::string::npos) {
    return "main";
  }
  if (profile.find("ld") != std::string::npos) {
    return "ld";
  }
  return profile;
}

std::string NSErrorToString(NSError* error) {
  if (error == nil) {
    return "unknown error";
  }

  std::string text;
  if (error.domain != nil) {
    text.append([[error.domain description] UTF8String]);
    text.append("(");
    text.append(std::to_string(static_cast<long long>(error.code)));
    text.append(")");
  } else {
    text.append("code ");
    text.append(std::to_string(static_cast<long long>(error.code)));
  }

  if (error.localizedDescription != nil) {
    text.append(": ");
    text.append([[error.localizedDescription description] UTF8String]);
  }

  NSError* underlying = error.userInfo[NSUnderlyingErrorKey];
  if (underlying != nil && underlying != error) {
    text.append(" | underlying: ");
    text.append(NSErrorToString(underlying));
  }

  return text;
}

void WriteNSError(const char* prefix, NSError* error, char* out_error_utf8,
                  uint32_t out_error_utf8_capacity) {
  WriteError(std::string(prefix) + ": " + NSErrorToString(error), out_error_utf8,
             out_error_utf8_capacity);
}

std::string OsStatusToString(OSStatus status) {
  std::string text = "OSStatus=" + std::to_string(static_cast<int32_t>(status));
  if (status == noErr) {
    return text;
  }

  const uint32_t be = CFSwapInt32HostToBig(static_cast<uint32_t>(status));
  char fourcc[5] = {0};
  std::memcpy(fourcc, &be, sizeof(be));
  const bool printable = std::isprint(static_cast<unsigned char>(fourcc[0])) != 0 &&
                         std::isprint(static_cast<unsigned char>(fourcc[1])) != 0 &&
                         std::isprint(static_cast<unsigned char>(fourcc[2])) != 0 &&
                         std::isprint(static_cast<unsigned char>(fourcc[3])) != 0;
  if (printable) {
    text.append(" ('");
    text.append(fourcc, 4);
    text.append("')");
  }
  return text;
}

void WriteOsStatusError(const char* prefix, OSStatus status, char* out_error_utf8,
                        uint32_t out_error_utf8_capacity) {
  WriteError(std::string(prefix) + ": " + OsStatusToString(status), out_error_utf8,
             out_error_utf8_capacity);
}

bool HasUsableNumericList(NSArray<NSNumber*>* values) {
  if (values == nil || values.count == 0) {
    return false;
  }
  if (values.count == 1 && std::abs(values.firstObject.doubleValue) < 0.5) {
    return false;
  }
  return true;
}

NSNumber* NearestValue(NSArray<NSNumber*>* values, double target) {
  if (!HasUsableNumericList(values)) {
    return @(target);
  }

  NSNumber* best = values.firstObject;
  double best_distance = std::abs(best.doubleValue - target);
  for (NSNumber* candidate in values) {
    const double distance = std::abs(candidate.doubleValue - target);
    if (distance < best_distance) {
      best = candidate;
      best_distance = distance;
    }
  }
  return best;
}

NSDictionary<NSString*, id>* BuildAacOutputSettings(double source_sample_rate,
                                                     uint32_t source_channel_count,
                                                     uint32_t requested_bitrate_bps) {
  const uint32_t channels = std::max<uint32_t>(1, std::min<uint32_t>(source_channel_count, 2));
  const double requested_rate = source_sample_rate > 0.0 ? source_sample_rate : 44100.0;

  NSMutableDictionary<NSString*, id>* settings = [@{
    AVFormatIDKey : @(static_cast<UInt32>(kAudioFormatMPEG4AAC)),
    AVSampleRateKey : @(requested_rate),
    AVNumberOfChannelsKey : @(static_cast<NSInteger>(channels)),
    AVEncoderBitRateKey : @(static_cast<NSInteger>(requested_bitrate_bps)),
    AVEncoderAudioQualityKey : @(AVAudioQualityHigh),
  } mutableCopy];

  AVAudioFormat* in_format =
      [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt16
                                        sampleRate:std::min<double>(requested_rate, 48000.0)
                                          channels:channels
                                       interleaved:NO];
  AVAudioFormat* out_format = [[AVAudioFormat alloc] initWithSettings:settings];
  if (in_format == nil || out_format == nil) {
    return settings;
  }

  AVAudioConverter* converter = [[AVAudioConverter alloc] initFromFormat:in_format
                                                                 toFormat:out_format];
  if (converter == nil) {
    return settings;
  }

  NSArray<NSNumber*>* sample_rates = converter.availableEncodeSampleRates;
  if (HasUsableNumericList(sample_rates)) {
    settings[AVSampleRateKey] = NearestValue(sample_rates, requested_rate);
  } else {
    [settings removeObjectForKey:AVSampleRateKey];
  }

  NSArray<NSNumber*>* bitrates = converter.availableEncodeBitRates;
  if (HasUsableNumericList(bitrates)) {
    settings[AVEncoderBitRateKey] =
        NearestValue(bitrates, static_cast<double>(requested_bitrate_bps));
  } else {
    [settings removeObjectForKey:AVEncoderBitRateKey];
  }

  return settings;
}

bool ResolveTrackFormat(AVAssetTrack* track, double* out_sample_rate, int* out_channels,
                        AudioFormatID* out_format_id) {
  if (track == nil || out_sample_rate == nullptr || out_channels == nullptr ||
      out_format_id == nullptr) {
    return false;
  }

  *out_sample_rate = 44100.0;
  *out_channels = 1;
  *out_format_id = 0;

  for (id format_desc in track.formatDescriptions) {
    CMAudioFormatDescriptionRef audio_desc = (__bridge CMAudioFormatDescriptionRef)format_desc;
    const AudioStreamBasicDescription* asbd =
        CMAudioFormatDescriptionGetStreamBasicDescription(audio_desc);
    if (asbd != nullptr) {
      if (asbd->mSampleRate > 0.0) {
        *out_sample_rate = asbd->mSampleRate;
      }
      if (asbd->mChannelsPerFrame > 0) {
        *out_channels = static_cast<int>(asbd->mChannelsPerFrame);
      }
      if (asbd->mFormatID != 0) {
        *out_format_id = asbd->mFormatID;
      }
      return true;
    }

    const FourCharCode subtype = CMFormatDescriptionGetMediaSubType(audio_desc);
    if (subtype != 0) {
      *out_format_id = subtype;
    }
  }

  return true;
}

std::string CodecFromFormatId(AudioFormatID format_id) {
  switch (format_id) {
    case kAudioFormatLinearPCM:
      return "pcm_s16le";
    case kAudioFormatMPEGLayer3:
      return "mp3";
    case kAudioFormatAppleLossless:
      return "alac";
    case kAudioFormatMPEG4AAC:
    case kAudioFormatMPEG4AAC_HE:
    case kAudioFormatMPEG4AAC_HE_V2:
    case kAudioFormatMPEG4AAC_LD:
    case kAudioFormatMPEG4AAC_ELD:
      return "aac";
    default:
      return {};
  }
}

std::string ProfileFromFormatId(AudioFormatID format_id) {
  switch (format_id) {
    case kAudioFormatMPEG4AAC:
      return "lc";
    case kAudioFormatMPEG4AAC_HE:
      return "he";
    case kAudioFormatMPEG4AAC_HE_V2:
      return "hev2";
    case kAudioFormatMPEG4AAC_LD:
      return "ld";
    case kAudioFormatMPEG4AAC_ELD:
      return "eld";
    default:
      return {};
  }
}

int32_t SafeDurationMicros(CMTime duration, int64_t* out_duration_micros) {
  if (out_duration_micros == nullptr) {
    return -1;
  }

  if (!CMTIME_IS_VALID(duration) || duration.timescale <= 0 || duration.value < 0) {
    return -2;
  }

  *out_duration_micros =
      static_cast<int64_t>((duration.value * static_cast<int64_t>(1000000)) / duration.timescale);
  return 0;
}

}  // namespace

namespace speech_utils::apple_audio_codec {

int32_t EncodeAudioFileToAac(const char* input_path_utf8, const char* output_path_utf8,
                             uint32_t bitrate_bps, bool use_source_format_hint,
                             const char* platform_name, char* error_utf8,
                             uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);

  if (input_path_utf8 == nullptr || input_path_utf8[0] == '\0') {
    WriteError("Input path is null or empty.", error_utf8, error_utf8_capacity);
    return -1;
  }
  if (output_path_utf8 == nullptr || output_path_utf8[0] == '\0') {
    WriteError("Output path is null or empty.", error_utf8, error_utf8_capacity);
    return -2;
  }
  if (bitrate_bps == 0) {
    WriteError("AAC bitrate must be > 0.", error_utf8, error_utf8_capacity);
    return -3;
  }

  (void)use_source_format_hint;
  (void)platform_name;

  @autoreleasepool {
    NSString* input_path = [NSString stringWithUTF8String:input_path_utf8];
    NSString* output_path = [NSString stringWithUTF8String:output_path_utf8];
    if (input_path.length == 0 || output_path.length == 0) {
      WriteError("Input/output path UTF-8 decoding failed.", error_utf8, error_utf8_capacity);
      return -4;
    }

    NSFileManager* fs = NSFileManager.defaultManager;
    if ([fs fileExistsAtPath:output_path]) {
      NSError* remove_error = nil;
      if (![fs removeItemAtPath:output_path error:&remove_error]) {
        WriteNSError("Failed to remove existing output", remove_error, error_utf8,
                     error_utf8_capacity);
        return -5;
      }
    }

    NSURL* input_url = [NSURL fileURLWithPath:input_path];
    NSURL* output_url = [NSURL fileURLWithPath:output_path];

    ExtAudioFileRef input_file = nullptr;
    ExtAudioFileRef output_file = nullptr;

    auto DisposeInput = [&]() {
      if (input_file != nullptr) {
        (void)ExtAudioFileDispose(input_file);
        input_file = nullptr;
      }
    };
    auto DisposeOutput = [&]() -> OSStatus {
      if (output_file == nullptr) {
        return noErr;
      }
      const OSStatus status = ExtAudioFileDispose(output_file);
      output_file = nullptr;
      return status;
    };

    OSStatus status = ExtAudioFileOpenURL((__bridge CFURLRef)input_url, &input_file);
    if (status != noErr || input_file == nullptr) {
      WriteOsStatusError("Failed to open input audio file", status, error_utf8,
                         error_utf8_capacity);
      return -6;
    }

    AudioStreamBasicDescription input_file_format{};
    UInt32 input_file_format_size = static_cast<UInt32>(sizeof(input_file_format));
    status = ExtAudioFileGetProperty(input_file, kExtAudioFileProperty_FileDataFormat,
                                     &input_file_format_size, &input_file_format);
    if (status != noErr) {
      DisposeInput();
      WriteOsStatusError("Failed to inspect input audio file format", status, error_utf8,
                         error_utf8_capacity);
      return -7;
    }

    const double input_sample_rate =
        input_file_format.mSampleRate > 0.0 ? input_file_format.mSampleRate : 44100.0;
    const uint32_t input_channels =
        input_file_format.mChannelsPerFrame > 0 ? input_file_format.mChannelsPerFrame : 1;

    NSDictionary<NSString*, id>* output_settings =
        BuildAacOutputSettings(input_sample_rate, input_channels, bitrate_bps);

    const double output_sample_rate =
        [output_settings[AVSampleRateKey] doubleValue] > 0.0
            ? [output_settings[AVSampleRateKey] doubleValue]
            : input_sample_rate;
    const uint32_t output_channels = std::max<uint32_t>(
        1, static_cast<uint32_t>(
               [output_settings[AVNumberOfChannelsKey] integerValue] > 0
                   ? [output_settings[AVNumberOfChannelsKey] integerValue]
                   : static_cast<NSInteger>(std::min<uint32_t>(input_channels, 2))));

    AudioStreamBasicDescription client_format{};
    client_format.mSampleRate = input_sample_rate;
    client_format.mFormatID = kAudioFormatLinearPCM;
    client_format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    client_format.mBitsPerChannel = 16;
    client_format.mChannelsPerFrame = output_channels;
    client_format.mFramesPerPacket = 1;
    client_format.mBytesPerFrame = client_format.mChannelsPerFrame * sizeof(int16_t);
    client_format.mBytesPerPacket = client_format.mBytesPerFrame;

    status = ExtAudioFileSetProperty(input_file, kExtAudioFileProperty_ClientDataFormat,
                                     static_cast<UInt32>(sizeof(client_format)), &client_format);
    if (status != noErr) {
      DisposeInput();
      WriteOsStatusError("Failed to configure input client PCM format", status, error_utf8,
                         error_utf8_capacity);
      return -8;
    }

    AudioStreamBasicDescription destination_format{};
    destination_format.mSampleRate = output_sample_rate;
    destination_format.mFormatID = kAudioFormatMPEG4AAC;
    destination_format.mChannelsPerFrame = output_channels;
    destination_format.mFramesPerPacket = 1024;

    status = ExtAudioFileCreateWithURL((__bridge CFURLRef)output_url, kAudioFileM4AType,
                                       &destination_format, nullptr, kAudioFileFlags_EraseFile,
                                       &output_file);
    if (status != noErr || output_file == nullptr) {
      DisposeInput();
      WriteOsStatusError("Failed to create AAC output file", status, error_utf8,
                         error_utf8_capacity);
      return -9;
    }

    status = ExtAudioFileSetProperty(output_file, kExtAudioFileProperty_ClientDataFormat,
                                     static_cast<UInt32>(sizeof(client_format)), &client_format);
    if (status != noErr) {
      (void)DisposeOutput();
      DisposeInput();
      WriteOsStatusError("Failed to configure output client PCM format", status, error_utf8,
                         error_utf8_capacity);
      return -10;
    }

    constexpr UInt32 kFramesPerChunk = 2048;
    std::vector<int16_t> pcm_buffer(static_cast<std::size_t>(kFramesPerChunk) * output_channels);
    while (true) {
      UInt32 frames = kFramesPerChunk;

      AudioBufferList buffer_list{};
      buffer_list.mNumberBuffers = 1;
      buffer_list.mBuffers[0].mNumberChannels = output_channels;
      buffer_list.mBuffers[0].mDataByteSize =
          static_cast<UInt32>(pcm_buffer.size() * sizeof(int16_t));
      buffer_list.mBuffers[0].mData = pcm_buffer.data();

      status = ExtAudioFileRead(input_file, &frames, &buffer_list);
      if (status != noErr) {
        (void)DisposeOutput();
        DisposeInput();
        WriteOsStatusError("Failed to read source PCM frames", status, error_utf8,
                           error_utf8_capacity);
        return -11;
      }
      if (frames == 0) {
        break;
      }

      buffer_list.mBuffers[0].mDataByteSize =
          frames * output_channels * static_cast<UInt32>(sizeof(int16_t));
      status = ExtAudioFileWrite(output_file, frames, &buffer_list);
      if (status != noErr) {
        (void)DisposeOutput();
        DisposeInput();
        WriteOsStatusError("Failed to write AAC frames", status, error_utf8,
                           error_utf8_capacity);
        return -12;
      }
    }

    const OSStatus dispose_output_status = DisposeOutput();
    DisposeInput();
    if (dispose_output_status != noErr) {
      WriteOsStatusError("Failed to finalize AAC output file", dispose_output_status, error_utf8,
                         error_utf8_capacity);
      return -13;
    }
  }

  return 0;
}

int32_t ReadAudioMetadata(const char* input_path_utf8, int64_t* out_duration_micros,
                          int32_t* out_sample_rate_hz, int32_t* out_channel_count,
                          int32_t* out_bitrate_bps, char* out_container_format_utf8,
                          uint32_t out_container_format_utf8_capacity, char* out_codec_utf8,
                          uint32_t out_codec_utf8_capacity, char* out_codec_profile_utf8,
                          uint32_t out_codec_profile_utf8_capacity, char* error_utf8,
                          uint32_t error_utf8_capacity) {
  if (input_path_utf8 == nullptr || input_path_utf8[0] == '\0') {
    WriteError("Input path is null or empty.", error_utf8, error_utf8_capacity);
    return -1;
  }
  if (out_duration_micros == nullptr || out_sample_rate_hz == nullptr ||
      out_channel_count == nullptr || out_bitrate_bps == nullptr) {
    WriteError("Metadata output pointers must not be null.", error_utf8, error_utf8_capacity);
    return -2;
  }

  *out_duration_micros = 0;
  *out_sample_rate_hz = -1;
  *out_channel_count = -1;
  *out_bitrate_bps = -1;
  WriteOutputText("", out_container_format_utf8, out_container_format_utf8_capacity);
  WriteOutputText("", out_codec_utf8, out_codec_utf8_capacity);
  WriteOutputText("", out_codec_profile_utf8, out_codec_profile_utf8_capacity);

  @autoreleasepool {
    NSString* input_path = [NSString stringWithUTF8String:input_path_utf8];
    if (input_path.length == 0) {
      WriteError("Input path UTF-8 decoding failed.", error_utf8, error_utf8_capacity);
      return -3;
    }

    NSURL* input_url = [NSURL fileURLWithPath:input_path];
    AVURLAsset* asset = [AVURLAsset URLAssetWithURL:input_url options:nil];
    NSArray<AVAssetTrack*>* tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    if (tracks.count == 0) {
      WriteError("Input file does not contain an audio track.", error_utf8,
                 error_utf8_capacity);
      return -4;
    }

    const int32_t duration_status = SafeDurationMicros(asset.duration, out_duration_micros);
    if (duration_status != 0) {
      WriteError("Audio duration is invalid or unavailable.", error_utf8, error_utf8_capacity);
      return -5;
    }

    AVAssetTrack* track = tracks.firstObject;
    double sample_rate = 0.0;
    int channels = 0;
    AudioFormatID format_id = 0;
    if (!ResolveTrackFormat(track, &sample_rate, &channels, &format_id)) {
      WriteError("Failed to inspect audio stream format.", error_utf8, error_utf8_capacity);
      return -6;
    }

    if (sample_rate > 0.0 && sample_rate <= static_cast<double>(std::numeric_limits<int32_t>::max())) {
      *out_sample_rate_hz = static_cast<int32_t>(llround(sample_rate));
    }
    if (channels > 0) {
      *out_channel_count = channels;
    }

    const float estimated_data_rate = track.estimatedDataRate;
    if (estimated_data_rate > 0.0f &&
        estimated_data_rate <= static_cast<float>(std::numeric_limits<int32_t>::max())) {
      *out_bitrate_bps = static_cast<int32_t>(llround(estimated_data_rate));
    }

    NSString* extension = input_url.pathExtension.lowercaseString;
    if (extension.length > 0) {
      const char* extension_utf8 = extension.UTF8String;
      if (extension_utf8 != nullptr) {
        WriteOutputText(extension_utf8, out_container_format_utf8,
                        out_container_format_utf8_capacity);
      }
    }

    std::string codec = CodecFromFormatId(format_id);
    if (!codec.empty()) {
      WriteOutputText(codec, out_codec_utf8, out_codec_utf8_capacity);
    }

    std::string profile = ProfileFromFormatId(format_id);
    if (profile.empty()) {
      for (id format_desc in track.formatDescriptions) {
        CMAudioFormatDescriptionRef audio_desc = (__bridge CMAudioFormatDescriptionRef)format_desc;
        NSDictionary* extensions = (__bridge NSDictionary*)
            CMFormatDescriptionGetExtensions(audio_desc);
        NSString* profile_name = extensions[@"AudioFormatName"];
        if (profile_name.length > 0) {
          profile = NormalizeProfile([profile_name UTF8String]);
          break;
        }
      }
    }
    if (!profile.empty()) {
      WriteOutputText(profile, out_codec_profile_utf8, out_codec_profile_utf8_capacity);
    }
  }

  return 0;
}

}  // namespace speech_utils::apple_audio_codec
