import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:speech_utils/speech_utils.dart';
import 'package:test/test.dart';

void main() {
  test('slow native-style command does not block the caller isolate', () async {
    final executor = NativeWorkerExecutor(
      entrypoint: _testNativeWorkerMain,
      debugName: 'speech_utils worker test',
    );
    addTearDown(executor.shutdown);

    var timerFired = false;
    final timerFuture = Future<void>.delayed(const Duration(milliseconds: 25), () {
      timerFired = true;
    });
    final commandFuture = executor.execute<int>(<String, Object?>{'delayMs': 150, 'value': 7});

    await timerFuture;
    expect(timerFired, isTrue);
    expect(await commandFuture, 7);
  });

  test('native-style commands execute in FIFO order', () async {
    final executor = NativeWorkerExecutor(
      entrypoint: _testNativeWorkerMain,
      debugName: 'speech_utils FIFO worker test',
    );
    addTearDown(executor.shutdown);

    final completed = <int>[];
    final futures = <Future<void>>[
      executor.execute<int>(<String, Object?>{'delayMs': 80, 'value': 1}).then(completed.add),
      executor.execute<int>(<String, Object?>{'delayMs': 0, 'value': 2}).then(completed.add),
      executor.execute<int>(<String, Object?>{'delayMs': 0, 'value': 3}).then(completed.add),
    ];

    await Future.wait(futures);
    expect(completed, <int>[1, 2, 3]);
  });

  test('executor fails pending work and restarts after a worker exit', () async {
    final executor = NativeWorkerExecutor(
      entrypoint: _testNativeWorkerMain,
      debugName: 'speech_utils restart worker test',
    );
    addTearDown(executor.shutdown);

    await expectLater(executor.execute<int>(<String, Object?>{'exit': true}), throwsStateError);
    expect(await executor.execute<int>(<String, Object?>{'delayMs': 0, 'value': 11}), 11);
  });

  test('shutdown releases the worker and execute starts a fresh one', () async {
    final executor = NativeWorkerExecutor(
      entrypoint: _testNativeWorkerMain,
      debugName: 'speech_utils shutdown worker test',
    );
    addTearDown(executor.shutdown);

    expect(await executor.execute<int>(<String, Object?>{'delayMs': 0, 'value': 1}), 1);
    await executor.shutdown();
    expect(await executor.execute<int>(<String, Object?>{'delayMs': 0, 'value': 2}), 2);
  });

  test('permanent shutdown prevents the worker from being revived', () async {
    final executor = NativeWorkerExecutor(
      entrypoint: _testNativeWorkerMain,
      debugName: 'speech_utils permanent shutdown worker test',
    );

    expect(await executor.execute<int>(<String, Object?>{'delayMs': 0, 'value': 1}), 1);
    await executor.shutdown(permanently: true);

    await expectLater(
      executor.execute<int>(<String, Object?>{'delayMs': 0, 'value': 2}),
      throwsA(isA<StateError>()),
    );
  });

  test('default desktop codec and metadata workers call bundled native assets', () async {
    if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) {
      return;
    }

    final tempDirectory = await Directory.systemTemp.createTemp('speech_utils_worker_smoke_');
    addTearDown(() => tempDirectory.delete(recursive: true));
    final outputPath = '${tempDirectory.path}${Platform.pathSeparator}worker-smoke.m4a';
    final pcm = Uint8List(1600 * 2);

    final encoder = NativeAudioEncoder();
    expect(await encoder.isAvailable(), isTrue);
    await encoder.encodePcm16BytesToAac(
      pcm16leBytes: pcm,
      sampleRateHz: 16000,
      channelCount: 1,
      outputPath: outputPath,
    );

    expect(await File(outputPath).length(), greaterThan(0));
    final metadata = await NativeAudioMetadataReader().readAudioMetadata(inputPath: outputPath);
    expect(metadata.duration, greaterThan(Duration.zero));
  });

  test('default desktop recorder control worker can query permission', () async {
    if (!Platform.isMacOS && !Platform.isWindows) {
      return;
    }

    final recorder = NativeAudioRecorder();
    expect(await recorder.hasPermission(), isA<bool>());
    await recorder.setContinousRecording(false);
    await recorder.dispose();
  });
}

@pragma('vm:entry-point')
void _testNativeWorkerMain(SendPort replyPort) {
  runNativeWorker(replyPort, (Object? rawRequest) {
    final request = rawRequest! as Map<Object?, Object?>;
    if (request['exit'] == true) {
      Isolate.exit();
    }
    sleep(Duration(milliseconds: request['delayMs']! as int));
    return request['value']! as int;
  });
}
