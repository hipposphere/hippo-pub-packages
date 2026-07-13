import 'dart:async';
import 'dart:isolate';

typedef NativeWorkerEntrypoint = void Function(SendPort replyPort);
typedef NativeWorkerHandler = FutureOr<Object?> Function(Object? request);

/// A lazily started, long-lived isolate that executes native commands in FIFO
/// order without blocking Flutter's UI isolate.
final class NativeWorkerExecutor {
  NativeWorkerExecutor({required NativeWorkerEntrypoint entrypoint, required String debugName})
    : this._(entrypoint, debugName);

  NativeWorkerExecutor._(this._entrypoint, this._debugName);

  final NativeWorkerEntrypoint _entrypoint;
  final String _debugName;

  final Map<int, Completer<Object?>> _pending = <int, Completer<Object?>>{};
  Future<SendPort>? _startFuture;
  int _nextRequestId = 0;
  int _generation = 0;
  ReceivePort? _replyPort;
  ReceivePort? _errorPort;
  ReceivePort? _exitPort;
  Isolate? _isolate;

  Future<T> execute<T>(Object? request) async {
    final commandPort = await (_startFuture ??= _start());
    final requestId = _nextRequestId++;
    final completer = Completer<Object?>();
    _pending[requestId] = completer;
    try {
      commandPort.send(<Object?>[requestId, request]);
    } on Object catch (error, stackTrace) {
      _pending.remove(requestId);
      Error.throwWithStackTrace(error, stackTrace);
    }
    return (await completer.future) as T;
  }

  Future<SendPort> _start() async {
    final generation = ++_generation;
    final ready = Completer<SendPort>();
    final receivePort = ReceivePort('$_debugName replies');
    final errorPort = ReceivePort('$_debugName errors');
    final exitPort = ReceivePort('$_debugName exit');
    _replyPort = receivePort;
    _errorPort = errorPort;
    _exitPort = exitPort;
    receivePort.listen((Object? message) {
      if (message is SendPort) {
        if (!ready.isCompleted) {
          ready.complete(message);
        }
        return;
      }
      if (message is! List<Object?> || message.length != 4) {
        return;
      }

      final requestId = message[0];
      if (requestId is! int) {
        return;
      }
      final completer = _pending.remove(requestId);
      if (completer == null) {
        return;
      }

      if (message[1] == true) {
        completer.complete(message[2]);
      } else {
        final error = message[2] ?? StateError('$_debugName command failed');
        final stackTrace = message[3] is StackTrace
            ? message[3] as StackTrace
            : StackTrace.fromString(message[3]?.toString() ?? '');
        completer.completeError(error, stackTrace);
      }
    });
    errorPort.listen((Object? message) {
      final error = switch (message) {
        <Object?>[final Object? value, _] => value,
        _ => message,
      };
      final stackTrace = switch (message) {
        <Object?>[_, final Object? value] => StackTrace.fromString(value?.toString() ?? ''),
        _ => StackTrace.current,
      };
      _handleWorkerTermination(generation, error: error, stackTrace: stackTrace);
    });
    exitPort.listen((Object? _) {
      _handleWorkerTermination(
        generation,
        error: StateError('$_debugName exited unexpectedly'),
        stackTrace: StackTrace.current,
      );
    });

    try {
      _isolate = await Isolate.spawn<SendPort>(
        _entrypoint,
        receivePort.sendPort,
        debugName: _debugName,
        onError: errorPort.sendPort,
        onExit: exitPort.sendPort,
        errorsAreFatal: true,
      );
      return await ready.future;
    } on Object catch (error, stackTrace) {
      _handleWorkerTermination(generation, error: error, stackTrace: stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  void _handleWorkerTermination(
    int generation, {
    required Object? error,
    required StackTrace stackTrace,
  }) {
    if (generation != _generation) {
      return;
    }
    _generation++;
    _startFuture = null;
    _replyPort?.close();
    _errorPort?.close();
    _exitPort?.close();
    _replyPort = null;
    _errorPort = null;
    _exitPort = null;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;

    final failure = error ?? StateError('$_debugName terminated unexpectedly');
    final pending = _pending.values.toList(growable: false);
    _pending.clear();
    for (final completer in pending) {
      if (!completer.isCompleted) {
        completer.completeError(failure, stackTrace);
      }
    }
  }
}

/// Runs a worker command loop. A synchronous native call naturally blocks only
/// this worker, and ReceivePort ordering provides bounded concurrency of one.
void runNativeWorker(SendPort replyPort, NativeWorkerHandler handler) {
  final commandPort = ReceivePort();
  var tail = Future<void>.value();
  replyPort.send(commandPort.sendPort);
  commandPort.listen((Object? message) {
    if (message is! List<Object?> || message.length != 2 || message[0] is! int) {
      return;
    }
    tail = tail.then((_) => _runNativeWorkerCommand(replyPort, handler, message));
  });
}

Future<void> _runNativeWorkerCommand(
  SendPort replyPort,
  NativeWorkerHandler handler,
  List<Object?> message,
) async {
  final requestId = message[0]! as int;
  try {
    final result = await handler(message[1]);
    replyPort.send(<Object?>[requestId, true, result, null]);
  } on Object catch (error, stackTrace) {
    try {
      replyPort.send(<Object?>[requestId, false, error, stackTrace]);
    } on Object {
      try {
        replyPort.send(<Object?>[
          requestId,
          false,
          StateError(error.toString()),
          stackTrace.toString(),
        ]);
      } on Object {
        // The caller's isolate may already be gone during application exit.
      }
    }
  }
}
