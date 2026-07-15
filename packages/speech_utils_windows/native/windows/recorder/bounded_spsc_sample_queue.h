#ifndef SPEECH_UTILS_WINDOWS_BOUNDED_SPSC_SAMPLE_QUEUE_H_
#define SPEECH_UTILS_WINDOWS_BOUNDED_SPSC_SAMPLE_QUEUE_H_

#include <algorithm>
#include <atomic>
#include <cstddef>
#include <cstdint>
#include <cstring>
#include <vector>

namespace speech_utils::windows_recorder {

// A fixed-capacity single-producer/single-consumer queue for interleaved PCM16
// samples. Configure() and Clear() may only be called while the producer and
// consumer are paused. When full, the producer rejects the newest samples and
// records the loss without modifying the consumer-owned read index.
class BoundedSpscSampleQueue {
 public:
  void Configure(std::size_t capacity) {
    samples_.assign(std::max<std::size_t>(capacity, 1), 0);
    read_index_.store(0, std::memory_order_relaxed);
    write_index_.store(0, std::memory_order_relaxed);
    dropped_samples_.store(0, std::memory_order_relaxed);
  }

  bool TryPush(const int16_t* samples, std::size_t sample_count) noexcept {
    if (samples == nullptr || sample_count == 0) {
      return true;
    }

    const std::size_t capacity = samples_.size();
    const uint64_t write_index = write_index_.load(std::memory_order_relaxed);
    const uint64_t read_index = read_index_.load(std::memory_order_acquire);
    const uint64_t used = write_index - read_index;
    if (used > capacity || sample_count > capacity || sample_count > capacity - used) {
      dropped_samples_.fetch_add(sample_count, std::memory_order_relaxed);
      return false;
    }

    const std::size_t offset = static_cast<std::size_t>(write_index % capacity);
    const std::size_t first_count = std::min(sample_count, capacity - offset);
    std::memcpy(samples_.data() + offset, samples, first_count * sizeof(int16_t));
    if (sample_count > first_count) {
      std::memcpy(samples_.data(), samples + first_count,
                  (sample_count - first_count) * sizeof(int16_t));
    }
    write_index_.store(write_index + sample_count, std::memory_order_release);
    return true;
  }

  std::size_t Pop(int16_t* output, std::size_t output_capacity) noexcept {
    if (output == nullptr || output_capacity == 0) {
      return 0;
    }

    const std::size_t capacity = samples_.size();
    const uint64_t read_index = read_index_.load(std::memory_order_relaxed);
    const uint64_t write_index = write_index_.load(std::memory_order_acquire);
    const std::size_t readable = static_cast<std::size_t>(
        std::min<uint64_t>(write_index - read_index, output_capacity));
    if (readable == 0) {
      return 0;
    }

    const std::size_t offset = static_cast<std::size_t>(read_index % capacity);
    const std::size_t first_count = std::min(readable, capacity - offset);
    std::memcpy(output, samples_.data() + offset, first_count * sizeof(int16_t));
    if (readable > first_count) {
      std::memcpy(output + first_count, samples_.data(),
                  (readable - first_count) * sizeof(int16_t));
    }
    read_index_.store(read_index + readable, std::memory_order_release);
    return readable;
  }

  std::size_t Size() const noexcept {
    const uint64_t write_index = write_index_.load(std::memory_order_acquire);
    const uint64_t read_index = read_index_.load(std::memory_order_acquire);
    return static_cast<std::size_t>(write_index - read_index);
  }

  std::size_t Capacity() const noexcept { return samples_.size(); }

  uint64_t DroppedSamples() const noexcept {
    return dropped_samples_.load(std::memory_order_relaxed);
  }

  void Clear() noexcept {
    const uint64_t write_index = write_index_.load(std::memory_order_relaxed);
    read_index_.store(write_index, std::memory_order_relaxed);
  }

 private:
  std::vector<int16_t> samples_{1, 0};
  alignas(64) std::atomic<uint64_t> read_index_{0};
  alignas(64) std::atomic<uint64_t> write_index_{0};
  std::atomic<uint64_t> dropped_samples_{0};
};

}  // namespace speech_utils::windows_recorder

#endif  // SPEECH_UTILS_WINDOWS_BOUNDED_SPSC_SAMPLE_QUEUE_H_
