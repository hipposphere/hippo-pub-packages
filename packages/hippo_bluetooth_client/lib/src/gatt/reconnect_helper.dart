import '../errors.dart';
import 'ble_gatt_client.dart';

/// Configuration for reconnect backoff behavior.
class BleReconnectOptions {
  /// Maximum reconnect attempts. `null` means retry forever.
  final int? maxAttempts;

  /// Initial backoff delay.
  final Duration initialDelay;

  /// Maximum backoff delay cap.
  final Duration maxDelay;

  /// Multiplicative backoff factor.
  final double multiplier;

  /// Creates [BleReconnectOptions].
  const BleReconnectOptions({
    this.maxAttempts = 5,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 8),
    this.multiplier = 2,
  });
}

/// Simple reconnect helper with configurable exponential backoff.
class BleReconnectHelper {
  /// Creates a reconnect helper.
  const BleReconnectHelper({
    required this.gattClient,
    this.options = const BleReconnectOptions(),
  });

  /// BLE transport used for reconnect attempts.
  final BleGattClient gattClient;

  /// Backoff configuration.
  final BleReconnectOptions options;

  /// Attempts to reconnect to [remoteId] until success or max attempts reached.
  Future<void> reconnect(
    String remoteId, {
    Duration? connectTimeout,
    bool autoConnect = false,
    int? mtu,
  }) async {
    var attempt = 0;
    var delay = options.initialDelay;

    while (true) {
      attempt += 1;
      try {
        await gattClient.connect(
          remoteId,
          timeout: connectTimeout,
          autoConnect: autoConnect,
          mtu: mtu,
        );
        return;
      } on Object catch (error, stackTrace) {
        final maxAttempts = options.maxAttempts;
        if (maxAttempts != null && attempt >= maxAttempts) {
          throw ConnectionError(
            'Reconnect failed after $attempt attempts for $remoteId',
            cause: error,
            stackTrace: stackTrace,
          );
        }

        await Future<void>.delayed(delay);
        final nextDelay = Duration(
          milliseconds: (delay.inMilliseconds * options.multiplier).round(),
        );
        delay = nextDelay > options.maxDelay ? options.maxDelay : nextDelay;
      }
    }
  }
}
