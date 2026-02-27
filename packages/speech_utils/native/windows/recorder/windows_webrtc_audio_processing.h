#ifndef SPEECH_UTILS_WINDOWS_WEBRTC_AUDIO_PROCESSING_H_
#define SPEECH_UTILS_WINDOWS_WEBRTC_AUDIO_PROCESSING_H_

#include <cstddef>
#include <cstdint>
#include <memory>
#include <string>

namespace speech_utils::windows_recorder {

struct WebRtcProcessingConfig {
  uint32_t sample_rate_hz = 16000;
  uint32_t channel_count = 1;
  bool enable_noise_suppression = false;
  bool enable_automatic_gain_control = false;
  bool enable_high_pass_filter = false;
  bool prefer_strong_voice_isolation = false;
};

class WebRtcAudioProcessor {
 public:
  WebRtcAudioProcessor();
  ~WebRtcAudioProcessor();

  WebRtcAudioProcessor(const WebRtcAudioProcessor&) = delete;
  WebRtcAudioProcessor& operator=(const WebRtcAudioProcessor&) = delete;

  bool IsSupported() const;

  bool Initialize(const WebRtcProcessingConfig& config, std::string* out_error);

  const int16_t* ProcessInterleaved(const int16_t* input_samples,
                                    std::size_t sample_count,
                                    std::size_t* out_sample_count,
                                    std::string* out_error);

  void Reset();

 private:
  struct Impl;
  std::unique_ptr<Impl> impl_;
};

}  // namespace speech_utils::windows_recorder

#endif  // SPEECH_UTILS_WINDOWS_WEBRTC_AUDIO_PROCESSING_H_
