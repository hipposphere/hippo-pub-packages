#include "windows_webrtc_audio_processing.h"

#include <string>
#include <utility>
#include <vector>

#include "modules/audio_processing/include/audio_processing.h"

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

struct WebRtcAudioProcessor::Impl {
  rtc::scoped_refptr<webrtc::AudioProcessing> apm;
  uint32_t sample_rate_hz = 0;
  uint32_t channel_count = 0;
  uint32_t frame_samples_per_channel = 0;
  uint32_t frame_sample_count = 0;
  std::vector<int16_t> processed_int16;
};

WebRtcAudioProcessor::WebRtcAudioProcessor() : impl_(std::make_unique<Impl>()) {}

WebRtcAudioProcessor::~WebRtcAudioProcessor() {
  Reset();
}

bool WebRtcAudioProcessor::Initialize(const WebRtcProcessingConfig& config,
                                      std::string* out_error) {
  Reset();

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

  rtc::scoped_refptr<webrtc::AudioProcessing> apm = webrtc::AudioProcessingBuilder().Create();
  if (!apm) {
    AssignError(out_error, "Failed to create WebRTC AudioProcessing instance.");
    return false;
  }

  const webrtc::StreamConfig stream_config(static_cast<int>(config.sample_rate_hz),
                                           static_cast<size_t>(config.channel_count), false);
  webrtc::ProcessingConfig processing_config;
  processing_config.input_stream() = stream_config;
  processing_config.output_stream() = stream_config;
  processing_config.reverse_input_stream() = stream_config;
  processing_config.reverse_output_stream() = stream_config;
  if (apm->Initialize(processing_config) != webrtc::AudioProcessing::kNoError) {
    AssignError(out_error, "Failed to initialize WebRTC AudioProcessing with stream config.");
    return false;
  }

  webrtc::AudioProcessing::Config apm_config;
  apm_config.high_pass_filter.enabled = config.enable_high_pass_filter;

  apm_config.noise_suppression.enabled = config.enable_noise_suppression;
  if (config.enable_noise_suppression) {
    apm_config.noise_suppression.level = config.prefer_strong_voice_isolation
                                             ? webrtc::AudioProcessing::Config::NoiseSuppression::kVeryHigh
                                             : webrtc::AudioProcessing::Config::NoiseSuppression::kHigh;
  }

  apm_config.gain_controller1.enabled = config.enable_automatic_gain_control;
  if (config.enable_automatic_gain_control) {
    apm_config.gain_controller1.mode =
        webrtc::AudioProcessing::Config::GainController1::kAdaptiveDigital;
    apm_config.gain_controller1.analog_gain_controller.enabled = false;
  }

  apm->ApplyConfig(apm_config);

  impl_->apm = std::move(apm);
  impl_->sample_rate_hz = config.sample_rate_hz;
  impl_->channel_count = config.channel_count;
  impl_->frame_samples_per_channel = config.sample_rate_hz / 100;
  impl_->frame_sample_count = impl_->frame_samples_per_channel * impl_->channel_count;
  impl_->processed_int16.clear();
  return true;
}

const int16_t* WebRtcAudioProcessor::ProcessInterleaved(const int16_t* input_samples,
                                                        std::size_t sample_count,
                                                        std::size_t* out_sample_count,
                                                        std::string* out_error) {
  if (out_sample_count != nullptr) {
    *out_sample_count = 0;
  }

  if (input_samples == nullptr || sample_count == 0 || !impl_->apm) {
    AssignError(out_error, "WebRTC APM processor is not initialized.");
    return nullptr;
  }

  if (impl_->frame_sample_count == 0 || sample_count % impl_->frame_sample_count != 0) {
    AssignError(out_error,
                "WebRTC APM expects chunks aligned to 10ms frames for the active sample rate.");
    return nullptr;
  }

  impl_->processed_int16.resize(sample_count);
  const webrtc::StreamConfig stream_config(static_cast<int>(impl_->sample_rate_hz),
                                           static_cast<size_t>(impl_->channel_count), false);

  const std::size_t frame_count = sample_count / impl_->frame_sample_count;
  for (std::size_t frame_index = 0; frame_index < frame_count; frame_index++) {
    const std::size_t frame_offset = frame_index * impl_->frame_sample_count;
    const int process_result = impl_->apm->ProcessStream(input_samples + frame_offset,
                                                         stream_config,
                                                         stream_config,
                                                         impl_->processed_int16.data() + frame_offset);
    if (process_result != webrtc::AudioProcessing::kNoError) {
      AssignError(out_error, "WebRTC APM failed while processing input stream.");
      return nullptr;
    }
  }

  if (out_sample_count != nullptr) {
    *out_sample_count = sample_count;
  }
  return impl_->processed_int16.data();
}

void WebRtcAudioProcessor::Reset() {
  if (impl_ != nullptr) {
    impl_->apm = nullptr;
    impl_->sample_rate_hz = 0;
    impl_->channel_count = 0;
    impl_->frame_samples_per_channel = 0;
    impl_->frame_sample_count = 0;
    impl_->processed_int16.clear();
  }
}

}  // namespace speech_utils::windows_recorder
