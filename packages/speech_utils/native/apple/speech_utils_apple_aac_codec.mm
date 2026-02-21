#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMedia/CoreMedia.h>
#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

#include <algorithm>
#include <climits>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <limits>
#include <string>

#include "speech_utils_apple_aac_codec.h"

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
  const auto copy_length = static_cast<uint32_t>(std::min<std::size_t>(
      message.size(), static_cast<std::size_t>(out_error_capacity - 1)));
  std::memcpy(out_error_utf8, message.data(), copy_length);
  out_error_utf8[copy_length] = '\0';
}

std::string NSErrorToString(NSError* error) {
  if (error == nil) {
    return "unknown error";
  }

  std::string message;
  if (error.domain != nil) {
    message += [[error.domain description] UTF8String];
    message += " (";
    message += std::to_string(static_cast<long long>(error.code));
    message += ")";
  } else {
    message += "code ";
    message += std::to_string(static_cast<long long>(error.code));
  }

  if (error.localizedDescription != nil) {
    message += ": ";
    message += [[error localizedDescription] UTF8String];
  }

  NSError* underlying = error.userInfo[NSUnderlyingErrorKey];
  if (underlying != nil && underlying != error) {
    message += " | underlying: ";
    message += NSErrorToString(underlying);
  }
  return message;
}

void WriteNSError(NSError* error, const char* prefix, char* out_error_utf8,
                 uint32_t out_error_capacity) {
  const std::string error_message = std::string(prefix) + ": " + NSErrorToString(error);
  WriteError(error_message, out_error_utf8, out_error_capacity);
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

AudioFormatID ResolveAudioFormatId(AVAssetTrack* track) {
  if (track == nil) {
    return 0;
  }
  for (id format_description in track.formatDescriptions) {
    CMAudioFormatDescriptionRef audio_desc =
        (__bridge CMAudioFormatDescriptionRef)format_description;
    const AudioStreamBasicDescription* asbd =
        CMAudioFormatDescriptionGetStreamBasicDescription(audio_desc);
    if (asbd != nullptr && asbd->mFormatID != 0) {
      return asbd->mFormatID;
    }
    const FourCharCode media_subtype = CMFormatDescriptionGetMediaSubType(audio_desc);
    if (media_subtype != 0) {
      return media_subtype;
    }
  }
  return 0;
}

std::string AudioFormatIdToCodec(AudioFormatID format_id) {
  switch (format_id) {
    case kAudioFormatLinearPCM:
      return "pcm";
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
      return "";
  }
}

std::string AudioFormatIdToCodecProfile(AudioFormatID format_id) {
  switch (format_id) {
    case kAudioFormatMPEG4AAC:
      return "AAC-LC";
    case kAudioFormatMPEG4AAC_HE:
      return "HE-AAC";
    case kAudioFormatMPEG4AAC_HE_V2:
      return "HE-AACv2";
    case kAudioFormatMPEG4AAC_LD:
      return "AAC-LD";
    case kAudioFormatMPEG4AAC_ELD:
      return "AAC-ELD";
    default:
      return "";
  }
}

void ResolveAudioParams(AVAssetTrack* track, double* out_sample_rate, int* out_channels) {
  if (out_sample_rate == nullptr || out_channels == nullptr) {
    return;
  }
  *out_sample_rate = 44100.0;
  *out_channels = 1;
  if (track == nil) {
    return;
  }

  for (id format_description in track.formatDescriptions) {
    CMAudioFormatDescriptionRef audio_desc =
        (__bridge CMAudioFormatDescriptionRef)format_description;
    const AudioStreamBasicDescription* asbd =
        CMAudioFormatDescriptionGetStreamBasicDescription(audio_desc);
    if (asbd != nullptr) {
      if (asbd->mSampleRate > 0) {
        *out_sample_rate = asbd->mSampleRate;
      }
      if (asbd->mChannelsPerFrame > 0) {
        *out_channels = static_cast<int>(asbd->mChannelsPerFrame);
      }
      return;
    }
  }
}

bool ResolveAudioTrackMetadata(AVAssetTrack* track, int32_t* out_sample_rate_hz,
                               int32_t* out_channel_count, int32_t* out_bitrate_bps) {
  if (track == nil || out_sample_rate_hz == nullptr || out_channel_count == nullptr ||
      out_bitrate_bps == nullptr) {
    return false;
  }

  *out_sample_rate_hz = -1;
  *out_channel_count = -1;
  *out_bitrate_bps = -1;

  double sample_rate = 0.0;
  int channels = 0;
  ResolveAudioParams(track, &sample_rate, &channels);

  if (sample_rate > 0 && sample_rate <= static_cast<double>(INT32_MAX)) {
    *out_sample_rate_hz = static_cast<int32_t>(llround(sample_rate));
  }
  if (channels > 0) {
    *out_channel_count = channels;
  }

  const float estimated_data_rate = track.estimatedDataRate;
  if (estimated_data_rate > 0 && estimated_data_rate <= static_cast<float>(INT32_MAX)) {
    *out_bitrate_bps = static_cast<int32_t>(llround(estimated_data_rate));
  }

  return true;
}
}  // namespace

namespace speech_utils::apple_aac {
int32_t EncodeAudioFileToAac(const char* input_path_utf8, const char* output_path_utf8,
                             uint32_t bitrate_bps, bool use_source_format_hint,
                             const char* platform_name, char* error_utf8,
                             uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  if (input_path_utf8 == nullptr || output_path_utf8 == nullptr || bitrate_bps == 0) {
    WriteError(std::string(EffectivePlatformName(platform_name)) +
                  ": Invalid arguments for speech_utils_platform_encode_audio_file_to_aac.",
              error_utf8, error_utf8_capacity);
    return -1;
  }

  @autoreleasepool {
    NSString* input_path = [NSString stringWithUTF8String:input_path_utf8];
    NSString* output_path = [NSString stringWithUTF8String:output_path_utf8];
    if (input_path.length == 0 || output_path.length == 0) {
      WriteError("Input/output path UTF-8 decoding failed.", error_utf8, error_utf8_capacity);
      return -2;
    }

    NSFileManager* file_manager = [NSFileManager defaultManager];
    if ([file_manager fileExistsAtPath:output_path]) {
      NSError* remove_error = nil;
      if (![file_manager removeItemAtPath:output_path error:&remove_error]) {
        WriteNSError(remove_error,
                     (std::string(EffectivePlatformName(platform_name)) +
                      ": Failed to remove existing output file")
                         .c_str(),
                     error_utf8, error_utf8_capacity);
        return -3;
      }
    }

    NSURL* input_url = [NSURL fileURLWithPath:input_path];
    NSURL* output_url = [NSURL fileURLWithPath:output_path];

    AVURLAsset* asset = [AVURLAsset URLAssetWithURL:input_url options:nil];
    NSArray<AVAssetTrack*>* audio_tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    if (audio_tracks.count == 0) {
      WriteError("Input file does not contain an audio track.", error_utf8, error_utf8_capacity);
      return -4;
    }
    AVAssetTrack* audio_track = audio_tracks.firstObject;

    NSError* read_error = nil;
    AVAssetReader* reader = [[AVAssetReader alloc] initWithAsset:asset error:&read_error];
    if (reader == nil) {
      WriteNSError(read_error, (std::string(EffectivePlatformName(platform_name)) +
                                   ": Failed to create AVAssetReader")
                                   .c_str(),
                   error_utf8, error_utf8_capacity);
      return -5;
    }

    NSDictionary* reader_settings = @{
      AVFormatIDKey : @(kAudioFormatLinearPCM),
      AVLinearPCMBitDepthKey : @16,
      AVLinearPCMIsFloatKey : @NO,
      AVLinearPCMIsBigEndianKey : @NO,
      AVLinearPCMIsNonInterleaved : @NO
    };
    AVAssetReaderTrackOutput* reader_output =
        [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audio_track
                                                    outputSettings:reader_settings];
    reader_output.alwaysCopiesSampleData = NO;
    if (![reader canAddOutput:reader_output]) {
      WriteError("Cannot add reader output for input audio track.", error_utf8, error_utf8_capacity);
      return -6;
    }
    [reader addOutput:reader_output];

    double sample_rate = 44100.0;
    int channels = 1;
    ResolveAudioParams(audio_track, &sample_rate, &channels);

    NSError* write_error = nil;
    AVAssetWriter* writer =
        [[AVAssetWriter alloc] initWithURL:output_url fileType:AVFileTypeAppleM4A
                                     error:&write_error];
    if (writer == nil) {
      WriteNSError(write_error, (std::string(EffectivePlatformName(platform_name)) +
                                   ": Failed to create AVAssetWriter")
                                   .c_str(),
                   error_utf8, error_utf8_capacity);
      return -7;
    }

    if (![reader startReading]) {
      WriteNSError(reader.error, (std::string(EffectivePlatformName(platform_name)) +
                                     ": AVAssetReader startReading failed")
                     .c_str(),
                   error_utf8, error_utf8_capacity);
      return -9;
    }

    CMSampleBufferRef first_sample = [reader_output copyNextSampleBuffer];
    if (first_sample == nullptr) {
      if (reader.status == AVAssetReaderStatusFailed) {
        WriteNSError(reader.error, (std::string(EffectivePlatformName(platform_name)) +
                                       ": AVAssetReader failed before first sample")
                       .c_str(),
                     error_utf8, error_utf8_capacity);
        return -11;
      }
      WriteError("Input file yielded no decodable audio samples.", error_utf8, error_utf8_capacity);
      return -11;
    }

    NSDictionary* writer_settings = @{
      AVFormatIDKey : @(kAudioFormatMPEG4AAC),
      AVSampleRateKey : @(sample_rate),
      AVNumberOfChannelsKey : @(channels),
      AVEncoderBitRateKey : @(bitrate_bps)
    };

    CMFormatDescriptionRef source_format = CMSampleBufferGetFormatDescription(first_sample);
    AVAssetWriterInput* writer_input = nil;
    if (use_source_format_hint && source_format != nullptr) {
      writer_input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                          outputSettings:writer_settings
                                                        sourceFormatHint:source_format];
    } else {
      writer_input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                          outputSettings:writer_settings];
    }

    if (![writer canAddInput:writer_input]) {
      CFRelease(first_sample);
      WriteError("Cannot add writer input for AAC output.", error_utf8, error_utf8_capacity);
      return -8;
    }
    writer_input.expectsMediaDataInRealTime = NO;
    [writer addInput:writer_input];

    if (![writer startWriting]) {
      CFRelease(first_sample);
      WriteNSError(writer.error, (std::string(EffectivePlatformName(platform_name)) +
                                       ": AVAssetWriter startWriting failed")
                      .c_str(),
                   error_utf8, error_utf8_capacity);
      [reader cancelReading];
      return -10;
    }

    CMTime start_time = CMSampleBufferGetPresentationTimeStamp(first_sample);
    if (!CMTIME_IS_VALID(start_time)) {
      start_time = kCMTimeZero;
    }
    [writer startSessionAtSourceTime:start_time];

    CMSampleBufferRef sample = first_sample;
    while (sample != nullptr) {
      while (![writer_input isReadyForMoreMediaData]) {
        if (reader.status == AVAssetReaderStatusFailed) {
          CFRelease(sample);
          [reader cancelReading];
          [writer cancelWriting];
          WriteNSError(reader.error,
                       (std::string(EffectivePlatformName(platform_name)) +
                        ": AVAssetReader failed during transcode")
                           .c_str(),
                       error_utf8, error_utf8_capacity);
          return -12;
        }
        if (writer.status == AVAssetWriterStatusFailed ||
            writer.status == AVAssetWriterStatusCancelled) {
          CFRelease(sample);
          [reader cancelReading];
          [writer cancelWriting];
          WriteNSError(writer.error, (std::string(EffectivePlatformName(platform_name)) +
                                         ": macOS AAC transcode failed")
                         .c_str(),
                       error_utf8, error_utf8_capacity);
          return -11;
        }
        [NSThread sleepForTimeInterval:0.001];
      }

      const BOOL append_ok = [writer_input appendSampleBuffer:sample];
      CFRelease(sample);
      if (!append_ok) {
        [writer_input markAsFinished];
        [reader cancelReading];
        [writer cancelWriting];
        WriteNSError(writer.error, (std::string(EffectivePlatformName(platform_name)) +
                                       ": AAC transcode failed")
                       .c_str(),
                     error_utf8, error_utf8_capacity);
        return -11;
      }
      sample = [reader_output copyNextSampleBuffer];
    }

    [writer_input markAsFinished];
    __block NSError* block_error = nil;
    dispatch_semaphore_t done = dispatch_semaphore_create(0);
    [writer finishWritingWithCompletionHandler:^{
      if (writer.status != AVAssetWriterStatusCompleted) {
        block_error = writer.error;
      }
      dispatch_semaphore_signal(done);
    }];
    dispatch_semaphore_wait(done, DISPATCH_TIME_FOREVER);

    if (block_error != nil) {
      WriteNSError(block_error, (std::string(EffectivePlatformName(platform_name)) +
                                     ": AAC transcode failed")
                     .c_str(),
                   error_utf8, error_utf8_capacity);
      return -11;
    }

    if (reader.status == AVAssetReaderStatusFailed) {
      WriteNSError(reader.error, (std::string(EffectivePlatformName(platform_name)) +
                                     ": AVAssetReader failed during transcode")
                     .c_str(),
                   error_utf8, error_utf8_capacity);
      return -12;
    }
    if (writer.status != AVAssetWriterStatusCompleted) {
      WriteNSError(writer.error, (std::string(EffectivePlatformName(platform_name)) +
                                     ": AVAssetWriter did not complete transcode")
                     .c_str(),
                   error_utf8, error_utf8_capacity);
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
  if (input_path_utf8 == nullptr || out_duration_micros == nullptr ||
      out_sample_rate_hz == nullptr || out_channel_count == nullptr ||
      out_bitrate_bps == nullptr || out_container_format_utf8 == nullptr ||
      out_codec_utf8 == nullptr || out_codec_profile_utf8 == nullptr) {
    WriteError("Invalid arguments for ReadAudioMetadata.", error_utf8, error_utf8_capacity);
    return -1;
  }

  *out_duration_micros = -1;
  *out_sample_rate_hz = -1;
  *out_channel_count = -1;
  *out_bitrate_bps = -1;
  WriteOutputText("", out_container_format_utf8, out_container_format_utf8_capacity);
  WriteOutputText("", out_codec_utf8, out_codec_utf8_capacity);
  WriteOutputText("", out_codec_profile_utf8, out_codec_profile_utf8_capacity);

  NSString* input_path = [NSString stringWithUTF8String:input_path_utf8];
  if (input_path.length == 0) {
    WriteError("Input path UTF-8 decoding failed.", error_utf8, error_utf8_capacity);
    return -2;
  }

  NSURL* input_url = [NSURL fileURLWithPath:input_path];
  AVURLAsset* asset = [AVURLAsset URLAssetWithURL:input_url options:nil];
  NSArray<AVAssetTrack*>* audio_tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
  if (audio_tracks.count == 0) {
    WriteError("Input file does not contain an audio track.", error_utf8, error_utf8_capacity);
    return -3;
  }

  CMTime duration = asset.duration;
  if (!CMTIME_IS_VALID(duration) || duration.timescale <= 0 || duration.value < 0) {
    WriteError("Input audio duration is invalid or unavailable.", error_utf8, error_utf8_capacity);
    return -4;
  }
  *out_duration_micros = static_cast<int64_t>((duration.value * 1000000LL) / duration.timescale);

  AVAssetTrack* audio_track = audio_tracks.firstObject;
  if (!ResolveAudioTrackMetadata(audio_track, out_sample_rate_hz, out_channel_count,
                                 out_bitrate_bps)) {
    WriteError("Failed to resolve audio track metadata.", error_utf8, error_utf8_capacity);
    return -5;
  }

  NSString* container_format_ns = [[input_url pathExtension] lowercaseString];
  if (container_format_ns.length > 0) {
    const char* container_format_utf8 = [container_format_ns UTF8String];
    if (container_format_utf8 != nullptr) {
      WriteOutputText(container_format_utf8, out_container_format_utf8,
                      out_container_format_utf8_capacity);
    }
  }

  const AudioFormatID format_id = ResolveAudioFormatId(audio_track);
  if (format_id != 0) {
    const std::string codec = AudioFormatIdToCodec(format_id);
    if (!codec.empty()) {
      WriteOutputText(codec, out_codec_utf8, out_codec_utf8_capacity);
    }
    const std::string codec_profile = AudioFormatIdToCodecProfile(format_id);
    if (!codec_profile.empty()) {
      WriteOutputText(codec_profile, out_codec_profile_utf8, out_codec_profile_utf8_capacity);
    }
  }

  return 0;
}
}  // namespace speech_utils::apple_aac
