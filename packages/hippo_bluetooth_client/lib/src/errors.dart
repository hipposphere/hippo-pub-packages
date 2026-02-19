/// Base error type for all Bluetooth client failures.
class BleClientError implements Exception {
  /// Human-readable error message.
  final String message;

  /// Optional underlying error.
  final Object? cause;

  /// Optional stack trace from underlying error.
  final StackTrace? stackTrace;

  /// Creates a new [BleClientError].
  const BleClientError(this.message, {this.cause, this.stackTrace});

  @override
  String toString() => '$runtimeType: $message';
}

/// Error thrown when a BLE connection-level operation fails.
class ConnectionError extends BleClientError {
  /// Creates a new [ConnectionError].
  const ConnectionError(super.message, {super.cause, super.stackTrace});
}

/// Error thrown for malformed protocol definitions or protocol violations.
class ProtocolError extends BleClientError {
  /// Creates a new [ProtocolError].
  const ProtocolError(super.message, {super.cause, super.stackTrace});
}

/// Error thrown when authentication fails.
class AuthError extends BleClientError {
  /// Creates a new [AuthError].
  const AuthError(super.message, {super.cause, super.stackTrace});
}

/// Error thrown for chunk framing or chunk reassembly failures.
class ChunkError extends BleClientError {
  /// Creates a new [ChunkError].
  const ChunkError(super.message, {super.cause, super.stackTrace});
}

/// Error thrown when an operation exceeds a configured timeout.
class OperationTimeoutError extends BleClientError {
  /// Operation name.
  final String operation;

  /// Timeout used by the failed operation.
  final Duration timeout;

  /// Creates a new [OperationTimeoutError].
  OperationTimeoutError(
    this.operation,
    this.timeout, {
    super.cause,
    super.stackTrace,
  }) : super(
         'Operation "$operation" timed out after ${timeout.inMicroseconds}us',
       );
}
