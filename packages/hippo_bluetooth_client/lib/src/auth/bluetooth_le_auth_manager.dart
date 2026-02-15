import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../errors.dart';
import '../gatt/ble_types.dart';
import '../protocol/protocol_client.dart';

/// Channel mapping for challenge/response authorization.
class BluetoothLeAuthChannels {
  /// Protocol id containing auth channels.
  final String protocolId;

  /// Channel id used to fetch the current challenge.
  final String challengeChannelId;

  /// Channel id used to send signed challenge responses.
  final String responseChannelId;

  /// Optional channel id used to verify auth result.
  final String? resultChannelId;

  /// Creates [BluetoothLeAuthChannels].
  const BluetoothLeAuthChannels({
    required this.protocolId,
    required this.challengeChannelId,
    required this.responseChannelId,
    this.resultChannelId,
  });
}

/// Optional auth field name overrides.
class BluetoothLeAuthFieldNames {
  /// Challenge nonce key.
  final String nonce;

  /// Session id key used in challenge and response payloads.
  final String sessionId;

  /// Response signature key.
  final String signature;

  /// Result payload authorization flag key.
  final String authorized;

  /// Creates [BluetoothLeAuthFieldNames].
  const BluetoothLeAuthFieldNames({
    this.nonce = 'nonce',
    this.sessionId = 'sessionId',
    this.signature = 'signature',
    this.authorized = 'authorized',
  });
}

/// Parsed challenge data from the server.
class AuthChallenge {
  /// Nonce to sign.
  final String nonce;

  /// Session id used in HMAC input.
  final String sessionId;

  /// Raw challenge payload.
  final Map<String, dynamic> payload;

  /// Creates [AuthChallenge].
  const AuthChallenge({
    required this.nonce,
    required this.sessionId,
    required this.payload,
  });
}

/// Authorization result state.
class AuthResult {
  /// Whether authorization succeeded.
  final bool authorized;

  /// Session id used for this authorization cycle.
  final String sessionId;

  /// Optional raw result payload.
  final Object? payload;

  /// Creates [AuthResult].
  const AuthResult({
    required this.authorized,
    required this.sessionId,
    this.payload,
  });
}

/// Stateful challenge-response auth helper for BLE protocol channels.
class BluetoothLeAuthManager {
  /// Creates an auth manager.
  BluetoothLeAuthManager({
    required this.protocolClient,
    required this.channels,
    required Uint8List secret,
    this.fields = const BluetoothLeAuthFieldNames(),
    this.defaultTimeout = const Duration(seconds: 10),
    this.sessionId,
    this.autoRevokeOnDisconnect = true,
  }) : _secret = Uint8List.fromList(secret) {
    if (autoRevokeOnDisconnect) {
      _disconnectSubscription = protocolClient.connectionState.listen((
        connectionState,
      ) {
        if (connectionState == BleConnectionState.disconnected) {
          revoke();
        }
      });
    }
  }

  /// Typed protocol client.
  final BleProtocolClient protocolClient;

  /// Auth channel mapping.
  final BluetoothLeAuthChannels channels;

  /// Field names used for challenge/response payloads.
  final BluetoothLeAuthFieldNames fields;

  /// Default timeout for auth operations.
  final Duration defaultTimeout;

  /// Optional static session id override.
  final String? sessionId;

  /// Revoke local auth state automatically on disconnect.
  final bool autoRevokeOnDisconnect;

  final Uint8List _secret;

  StreamSubscription<BleConnectionState>? _disconnectSubscription;
  bool _authorized = false;
  String? _authorizedSessionId;
  DateTime? _authorizedAt;

  /// Returns true when current session is locally marked authorized.
  bool get isAuthorized => _authorized;

  /// Last authorized session id, if available.
  String? get authorizedSessionId => _authorizedSessionId;

  /// Timestamp for last successful authorization.
  DateTime? get authorizedAt => _authorizedAt;

  /// Requests a challenge from server channel.
  Future<AuthChallenge> issueChallenge({Duration? timeout}) async {
    final payload = await protocolClient.readChannel<Map<String, dynamic>>(
      channels.protocolId,
      channels.challengeChannelId,
      timeout: timeout ?? defaultTimeout,
    );

    final nonceValue = payload[fields.nonce];
    if (nonceValue is! String || nonceValue.isEmpty) {
      throw AuthError(
        'Challenge payload is missing a non-empty "${fields.nonce}" string',
      );
    }

    final payloadSessionId = payload[fields.sessionId];
    final resolvedSessionId = _resolveSessionId(payloadSessionId);

    return AuthChallenge(
      nonce: nonceValue,
      sessionId: resolvedSessionId,
      payload: payload,
    );
  }

  /// Signs and sends a challenge response to the server channel.
  Future<AuthResult> respondToChallenge(
    AuthChallenge challenge, {
    Duration? timeout,
  }) async {
    final signature = createSignature(
      sessionId: challenge.sessionId,
      nonce: challenge.nonce,
    );

    final payload = <String, dynamic>{
      fields.sessionId: challenge.sessionId,
      fields.nonce: challenge.nonce,
      fields.signature: signature,
    };

    final opTimeout = timeout ?? defaultTimeout;

    await protocolClient.writeChannel<Map<String, dynamic>>(
      channels.protocolId,
      channels.responseChannelId,
      payload,
      timeout: opTimeout,
    );

    Object? resultPayload;
    var authorized = true;
    if (channels.resultChannelId != null) {
      resultPayload = await protocolClient.readChannel<Object?>(
        channels.protocolId,
        channels.resultChannelId!,
        timeout: opTimeout,
      );
      authorized = _parseAuthorizationFlag(resultPayload);
    }

    if (!authorized) {
      revoke();
      throw const AuthError('Authorization rejected by server');
    }

    _authorized = true;
    _authorizedSessionId = challenge.sessionId;
    _authorizedAt = DateTime.now();

    return AuthResult(
      authorized: true,
      sessionId: challenge.sessionId,
      payload: resultPayload,
    );
  }

  /// Runs complete challenge -> sign -> verify authorization flow.
  Future<AuthResult> authorize({Duration? timeout}) async {
    final challenge = await issueChallenge(timeout: timeout);
    return respondToChallenge(challenge, timeout: timeout);
  }

  /// Executes [handler] only after session authorization succeeds.
  Future<T> ensureAuthorized<T>(
    Future<T> Function() handler, {
    Duration? timeout,
  }) async {
    if (!isAuthorized) {
      await authorize(timeout: timeout);
    }
    return handler();
  }

  /// Clears local authorization state.
  void revoke() {
    _authorized = false;
    _authorizedSessionId = null;
    _authorizedAt = null;
  }

  /// Creates HMAC signature as lowercase hex.
  ///
  /// Format: `HMAC(secret, sessionId + ":" + nonce)`.
  String createSignature({required String sessionId, required String nonce}) {
    final input = '$sessionId:$nonce';
    final mac = Hmac(sha256, _secret).convert(utf8.encode(input));
    return mac.toString();
  }

  /// Disposes subscriptions and local state.
  Future<void> dispose() async {
    await _disconnectSubscription?.cancel();
    _disconnectSubscription = null;
    revoke();
  }

  String _resolveSessionId(Object? challengeSessionId) {
    final configured = sessionId;
    if (configured != null && configured.isNotEmpty) {
      return normalizeSessionId(configured);
    }

    if (challengeSessionId is String && challengeSessionId.isNotEmpty) {
      return normalizeSessionId(challengeSessionId);
    }

    return normalizeSessionId(protocolClient.remoteId);
  }

  bool _parseAuthorizationFlag(Object? payload) {
    if (payload is bool) {
      return payload;
    }

    if (payload is Map<String, dynamic>) {
      final flag = payload[fields.authorized];
      return flag == true;
    }

    if (payload is Map) {
      final value = payload[fields.authorized];
      return value == true;
    }

    if (payload is String) {
      final normalized = payload.trim().toLowerCase();
      return normalized == 'ok' ||
          normalized == 'authorized' ||
          normalized == 'true';
    }

    throw AuthError(
      'Unable to parse authorization result payload of type ${payload.runtimeType}',
    );
  }
}

/// Normalizes device/session identifiers for portable HMAC session IDs.
String normalizeSessionId(String value) {
  final normalized = value.trim().toLowerCase().replaceAll(
    RegExp(r'[^a-z0-9_-]'),
    '',
  );
  return normalized.isEmpty ? 'session' : normalized;
}
