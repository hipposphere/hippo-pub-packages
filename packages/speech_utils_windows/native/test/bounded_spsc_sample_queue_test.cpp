#include "../windows/recorder/bounded_spsc_sample_queue.h"

#include <atomic>
#include <cassert>
#include <cstdint>
#include <thread>

using speech_utils::windows_recorder::BoundedSpscSampleQueue;

void TestWraparoundAndOverflow() {
  BoundedSpscSampleQueue queue;
  queue.Configure(8);

  const int16_t first[] = {1, 2, 3, 4, 5, 6};
  assert(queue.TryPush(first, 6));

  int16_t output[8]{};
  assert(queue.Pop(output, 4) == 4);
  for (int i = 0; i < 4; i++) {
    assert(output[i] == i + 1);
  }

  const int16_t second[] = {7, 8, 9, 10, 11, 12};
  assert(queue.TryPush(second, 6));
  assert(!queue.TryPush(second, 1));
  assert(queue.DroppedSamples() == 1);
  assert(queue.Pop(output, 8) == 8);

  const int16_t expected[] = {5, 6, 7, 8, 9, 10, 11, 12};
  for (int i = 0; i < 8; i++) {
    assert(output[i] == expected[i]);
  }
}

void TestConcurrentProducerAndConsumer() {
  constexpr int kSampleCount = 200000;
  BoundedSpscSampleQueue queue;
  queue.Configure(4096);
  std::atomic<bool> producer_done{false};

  std::thread producer([&] {
    for (int value = 0; value < kSampleCount;) {
      const int16_t sample = static_cast<int16_t>(value % 30000);
      if (queue.TryPush(&sample, 1)) {
        value++;
      } else {
        std::this_thread::yield();
      }
    }
    producer_done.store(true, std::memory_order_release);
  });

  int expected = 0;
  int16_t samples[127]{};
  while (!producer_done.load(std::memory_order_acquire) || queue.Size() > 0) {
    const std::size_t count = queue.Pop(samples, 127);
    if (count == 0) {
      std::this_thread::yield();
      continue;
    }
    for (std::size_t i = 0; i < count; i++) {
      assert(samples[i] == static_cast<int16_t>(expected % 30000));
      expected++;
    }
  }

  producer.join();
  assert(expected == kSampleCount);
}

int main() {
  TestWraparoundAndOverflow();
  TestConcurrentProducerAndConsumer();
  return 0;
}
