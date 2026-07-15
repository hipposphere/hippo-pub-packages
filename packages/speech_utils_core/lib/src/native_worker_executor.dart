import 'dart:async';
import 'dart:isolate';

typedef NativeWorkerEntrypoint = void Function(SendPort replyPort);
typedef NativeWorkerHandler = FutureOr<Object?> Function(Object? request);

/// A lazily started, long-lived isolate that executes native commands in FIFO
/// order without blocking Flutter's UI isolate.
final class NativeWorkerExecutor {
  factory NativeWorkerExecutor({
    required NativeWorkerEntrypoint entrypoint,
    required String debugName,
  }) {
    return NativeWorkerExecutor._(entrypoint, debugName);
  }

  NativeWorkerExecutor._(this._entrypoint, this._debugName) {
    _instances.add(this);
  }

  final NativeWorkerEntrypoint _entrypoint;
  final String _debugName;

  static final Set<NativeWorkerExecutor> _instances = <NativeWorkerExecutor>{};

  final Map<int, Completer<Object?>> _pending = <int, Completer<Object?>>{};
  Future<SendPort>? _startFuture;
  int _nextRequestId = 0;
  int _generation = 0;
  ReceivePort? _replyPort;
  ReceivePort? _errorPort;
  ReceivePort? _exitPort;
  Isolate? _isolate;
  Future<void>? _shutdownFuture;
  bool _isPermanentlyShutdown = false;

  Future<T> execute<T>(Object? request) async {
    while (true) {
      _ensureNotPermanentlyShutdown();
      final shutdownFuture = _shutdownFuture;
      if (shutdownFuture != null) {
        await shutdownFuture;
        continue;
      }

      final commandPort = await (_startFuture ??= _start());
      _ensureNotPermanentlyShutdown();

      // Shutdown can begin while the worker isolate is starting. Let it finish
      // and retry with a fresh worker instead of sending to the isolate that is
      // about to be killed.
      final shutdownAfterStart = _shutdownFuture;
      if (shutdownAfterStart != null) {
        await shutdownAfterStart;
        continue;
      }

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
  }

  /// Stops the current worker after its queued commands finish.
  ///
  /// A later [execute] call starts a fresh worker, so shared executors can be
  /// released during a session and reused by a subsequent session. Set
  /// [permanently] only during final application shutdown; later [execute]
  /// calls then fail instead of starting a new isolate.
  Future<void> shutdown({bool permanently = false}) {
    if (permanently) {
      _isPermanentlyShutdown = true;
    }
    return _shutdownFuture ??= _shutdown().whenComplete(() {
      _shutdownFuture = null;
    });
  }

  /// Stops every native worker created in this isolate.
  ///
  /// Set [permanently] during final application shutdown so background work
  /// cannot revive a worker after recorder cleanup has completed.
  static Future<void> shutdownAll({bool permanently = false}) async {
    await Future.wait(
      _instances
          .toList(growable: false)
          .map((executor) => executor.shutdown(permanently: permanently)),
    );
  }

  void _ensureNotPermanentlyShutdown() {
    if (_isPermanentlyShutdown) {
      throw StateError('$_debugName has been permanently shut down');
    }
  }

  Future<void> _shutdown() async {
    final startFuture = _startFuture;
    if (startFuture != null) {
      try {
        await startFuture;
      } on Object {
        // Startup failure already tears down the worker and completes callers.
      }
    }

    final pending = _pending.values
        .map((completer) => completer.future)
        .toList(growable: false);
    if (pending.isNotEmpty) {
      await Future.wait(
        pending.map((future) => future.then<void>((_) {}, onError: (_, _) {})),
      );
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
        <Object?>[_, final Object? value] => StackTrace.fromString(
          value?.toString() ?? '',
        ),
        _ => StackTrace.current,
      };
      final failure =
          error ?? StateError('$_debugName terminated during startup');
      if (!ready.isCompleted) {
        ready.completeError(failure, stackTrace);
      }
      _handleWorkerTermination(
        generation,
        error: failure,
        stackTrace: stackTrace,
      );
    });
    exitPort.listen((Object? _) {
      final error = StateError('$_debugName exited unexpectedly');
      final stackTrace = StackTrace.current;
      if (!ready.isCompleted) {
        ready.completeError(error, stackTrace);
      }
      _handleWorkerTermination(
        generation,
        error: error,
        stackTrace: stackTrace,
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
      _handleWorkerTermination(
        generation,
        error: error,
        stackTrace: stackTrace,
      );
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
    if (message is! List<Object?> ||
        message.length != 2 ||
        message[0] is! int) {
      return;
    }
    tail = tail.then(
      (_) => _runNativeWorkerCommand(replyPort, handler, message),
    );
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
