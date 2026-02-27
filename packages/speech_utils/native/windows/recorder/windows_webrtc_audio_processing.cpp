#include "windows_webrtc_audio_processing.h"

#include <algorithm>
#include <cmath>
#include <limits>
#include <string>
#include <utility>
#include <vector>

#if defined(SPEECH_UTILS_ENABLE_WEBRTC_APM) && SPEECH_UTILS_ENABLE_WEBRTC_APM
#if __has_include("modules/audio_processing/include/audio_processing.h")
#include "modules/audio_processing/include/audio_processing.h"
#define SPEECH_UTILS_HAS_WEBRTC_APM_HEADERS 1
#else
#define SPEECH_UTILS_HAS_WEBRTC_APM_HEADERS 0
#endif
#else
#define SPEECH_UTILS_HAS_WEBRTC_APM_HEADERS 0
#endif

namespace speech_utils::windows_recorder {

namespace {
bool IsSupportedSampleRate(uint32_t sample_rate_hz) {
  return sample_rate_hz == 8000 || sample_rate_hz == 16000 || sample_rate_hz == 32000 ||
         sample_rate_hz == 48000;
}

void AssignError(std::string* out_error, const std::string& error) {
  if (out_error != nullptr) {
    *out_error = error;
  }
}

}  // namespace

#if SPEECH_UTILS_HAS_WEBRTC_APM_HEADERS
struct WebRtcAudioProcessor::Impl {
  webrtc::AudioProcessing* apm = nullptr;
  uint32_t sample_rate_hz = 0;
  uint32_t channel_count = 0;
  uint32_t frame_samples_per_channel = 0;
  std::vector<float> interleaved_in;
  std::vector<float> interleaved_out;
  std::vector<std::vector<float>> deinterleaved_in;
  std::vector<std::vector<float>> deinterleaved_out;
  std::vector<const float*> in_channel_ptrs;
  std::vector<float*> out_channel_ptrs;
  std::vector<int16_t> processed_int16;
};
#else
struct WebRtcAudioProcessor::Impl {};
#endif

WebRtcAudioProcessor::WebRtcAudioProcessor() : impl_(std::make_unique<Impl>()) {}

WebRtcAudioProcessor::~WebRtcAudioProcessor() {
  Reset();
}

bool WebRtcAudioProcessor::IsSupported() const {
#if SPEECH_UTILS_HAS_WEBRTC_APM_HEADERS
  return true;
#else
  return false;
#endif
}

bool WebRtcAudioProcessor::Initialize(const WebRtcProcessingConfig& config,
                                      std::string* out_error) {
  Reset();

#if SPEECH_UTILS_HAS_WEBRTC_APM_HEADERS
  if (!IsSupportedSampleRate(config.sample_rate_hz)) {
    AssignError(out_error, "WebRTC APM supports 8/16/32/48 kHz capture rates.");
    return false;
  }
  if (config.channel_count == 0 || config.channel_count > 2) {
    AssignError(out_error, "WebRTC APM integration currently supports mono or stereo only.");
    return false;
  }
  if (config.sample_rate_hz % 100 != 0) {
    AssignError(out_error, "WebRTC APM requires 10ms-compatible sample rates.");
    return false;
  }

  webrtc::AudioProcessing* apm = webrtc::AudioProcessing::Create();
  if (apm == nullptr) {
    AssignError(out_error, "Failed to create WebRTC AudioProcessing instance.");
    return false;
  }

  const auto channel_layout = config.channel_count == 1 ? webrtc::AudioProcessing::kMono
                                                         : webrtc::AudioProcessing::kStereo;
  const int initialize_result =
      apm->Initialize(static_cast<int>(config.sample_rate_hz),
                      static_cast<int>(config.sample_rate_hz),
                      static_cast<int>(config.sample_rate_hz),
                      channel_layout,
                      channel_layout,
                      channel_layout);
  if (initialize_result != webrtc::AudioProcessing::kNoError) {
    apm->Release();
    AssignError(out_error, "Failed to initialize WebRTC AudioProcessing.");
    return false;
  }

  webrtc::AudioProcessing::Config apm_config;
  apm_config.high_pass_filter.enabled = config.enable_high_pass_filter;
  apm->ApplyConfig(apm_config);

  if (config.enable_noise_suppression) {
    if (apm->noise_suppression()->Enable(true) != webrtc::AudioProcessing::kNoError) {
      apm->Release();
      AssignError(out_error, "Failed to enable WebRTC noise suppression.");
      return false;
    }
    const auto level = config.prefer_strong_voice_isolation
                           ? webrtc::AudioProcessing::kHighSuppression
                           : webrtc::AudioProcessing::kModerateSuppression;
    if (apm->noise_suppression()->set_level(level) != webrtc::AudioProcessing::kNoError) {
      apm->Release();
      AssignError(out_error, "Failed to set WebRTC noise suppression level.");
      return false;
    }
  } else {
    (void)apm->noise_suppression()->Enable(false);
  }

  if (config.enable_automatic_gain_control) {
    if (apm->gain_control()->Enable(true) != webrtc::AudioProcessing::kNoError) {
      apm->Release();
      AssignError(out_error, "Failed to enable WebRTC automatic gain control.");
      return false;
    }
    (void)apm->gain_control()->set_mode(webrtc::GainControl::kAdaptiveDigital);
    (void)apm->set_stream_analog_level(255);
  } else {
    (void)apm->gain_control()->Enable(false);
  }

  const uint32_t frame_samples_per_channel = config.sample_rate_hz / 100;
  const auto frame_sample_count =
      static_cast<std::size_t>(frame_samples_per_channel) * config.channel_count;

  impl_->apm = apm;
  impl_->sample_rate_hz = config.sample_rate_hz;
  impl_->channel_count = config.channel_count;
  impl_->frame_samples_per_channel = frame_samples_per_channel;
  impl_->interleaved_in.assign(frame_sample_count, 0.0f);
  impl_->interleaved_out.assign(frame_sample_count, 0.0f);
  impl_->deinterleaved_in.assign(config.channel_count,
                                 std::vector<float>(frame_samples_per_channel, 0.0f));
  impl_->deinterleaved_out.assign(config.channel_count,
                                  std::vector<float>(frame_samples_per_channel, 0.0f));
  impl_->in_channel_ptrs.assign(config.channel_count, nullptr);
  impl_->out_channel_ptrs.assign(config.channel_count, nullptr);
  for (uint32_t channel = 0; channel < config.channel_count; channel++) {
    impl_->in_channel_ptrs[channel] = impl_->deinterleaved_in[channel].data();
    impl_->out_channel_ptrs[channel] = impl_->deinterleaved_out[channel].data();
  }

  return true;
#else
  (void)config;
  AssignError(out_error,
              "WebRTC APM headers are unavailable. Configure SPEECH_UTILS_ENABLE_WEBRTC_APM "
              "and provide APM include/lib paths.");
  return false;
#endif
}

const int16_t* WebRtcAudioProcessor::ProcessInterleaved(const int16_t* input_samples,
                                                        std::size_t sample_count,
                                                        std::size_t* out_sample_count,
                                                        std::string* out_error) {
  if (out_sample_count != nullptr) {
    *out_sample_count = 0;
  }

#if SPEECH_UTILS_HAS_WEBRTC_APM_HEADERS
  if (input_samples == nullptr || sample_count == 0 || impl_->apm == nullptr) {
    AssignError(out_error, "WebRTC APM processor is not initialized.");
    return nullptr;
  }

  const auto frame_sample_count =
      static_cast<std::size_t>(impl_->frame_samples_per_channel) * impl_->channel_count;
  if (frame_sample_count == 0 || sample_count % frame_sample_count != 0) {
    AssignError(out_error,
                "WebRTC APM expects chunks aligned to 10ms frames for the active sample rate.");
    return nullptr;
  }

  impl_->processed_int16.resize(sample_count);
  const std::size_t frame_count = sample_count / frame_sample_count;
  webrtc::StreamConfig stream_config(static_cast<int>(impl_->sample_rate_hz),
                                     static_cast<int>(impl_->channel_count), false);

  for (std::size_t frame_index = 0; frame_index < frame_count; frame_index++) {
    const std::size_t frame_offset = frame_index * frame_sample_count;
    for (std::size_t i = 0; i < frame_sample_count; i++) {
      impl_->interleaved_in[i] =
          static_cast<float>(input_samples[frame_offset + i]) / 32768.0f;
    }

    for (uint32_t channel = 0; channel < impl_->channel_count; channel++) {
      for (uint32_t frame = 0; frame < impl_->frame_samples_per_channel; frame++) {
        impl_->deinterleaved_in[channel][frame] =
            impl_->interleaved_in[static_cast<std::size_t>(frame) * impl_->channel_count +
                                  channel];
      }
    }

    const int process_result = impl_->apm->ProcessStream(
        impl_->in_channel_ptrs.data(),
        stream_config,
        stream_config,
        impl_->out_channel_ptrs.data());
    if (process_result != webrtc::AudioProcessing::kNoError) {
      AssignError(out_error, "WebRTC APM failed while processing input stream.");
      return nullptr;
    }

    for (uint32_t frame = 0; frame < impl_->frame_samples_per_channel; frame++) {
      for (uint32_t channel = 0; channel < impl_->channel_count; channel++) {
        const float value = std::clamp(impl_->deinterleaved_out[channel][frame], -1.0f, 1.0f);
        const int32_t scaled =
            static_cast<int32_t>(std::lrint(static_cast<double>(value) * 32767.0));
        impl_->processed_int16[frame_offset +
                               static_cast<std::size_t>(frame) * impl_->channel_count + channel] =
            static_cast<int16_t>(std::clamp(scaled, -32768, 32767));
      }
    }
  }

  if (out_sample_count != nullptr) {
    *out_sample_count = sample_count;
  }
  return impl_->processed_int16.data();
#else
  (void)input_samples;
  (void)sample_count;
  AssignError(out_error, "WebRTC APM support is not compiled in.");
  return nullptr;
#endif
}

void WebRtcAudioProcessor::Reset() {
#if SPEECH_UTILS_HAS_WEBRTC_APM_HEADERS
  if (impl_ != nullptr && impl_->apm != nullptr) {
    impl_->apm->Release();
    impl_->apm = nullptr;
  }
  if (impl_ != nullptr) {
    impl_->sample_rate_hz = 0;
    impl_->channel_count = 0;
    impl_->frame_samples_per_channel = 0;
    impl_->interleaved_in.clear();
    impl_->interleaved_out.clear();
    impl_->deinterleaved_in.clear();
    impl_->deinterleaved_out.clear();
    impl_->in_channel_ptrs.clear();
    impl_->out_channel_ptrs.clear();
    impl_->processed_int16.clear();
  }
#endif
}

}  // namespace speech_utils::windows_recorder
