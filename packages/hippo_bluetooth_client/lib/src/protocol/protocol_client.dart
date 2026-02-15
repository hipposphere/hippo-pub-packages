import 'dart:async';
import 'dart:typed_data';

import '../chunk/chunk_frame.dart';
import '../chunk/chunk_reassembler.dart';
import '../errors.dart';
import '../gatt/ble_gatt_client.dart';
import '../gatt/ble_types.dart';
import 'protocol_definition.dart';

/// Options for chunked writes.
class ChunkSendOptions {
  /// Explicit sequence number. If null, a monotonically incrementing sequence
  /// is used per client.
  final int? sequence;

  /// Max payload size per chunk, excluding frame header.
  final int? maxChunkPayloadSize;

  /// Max write payload size before ATT overhead, used when
  /// [maxChunkPayloadSize] is not provided.
  final int? maxWritePayloadSize;

  /// ATT overhead in bytes subtracted from MTU.
  final int attOverheadBytes;

  /// Write mode.
  final bool withoutResponse;

  /// Optional delay between frame writes.
  final Duration? interChunkDelay;

  /// Creates [ChunkSendOptions].
  const ChunkSendOptions({
    this.sequence,
    this.maxChunkPayloadSize,
    this.maxWritePayloadSize,
    this.attOverheadBytes = 3,
    this.withoutResponse = true,
    this.interChunkDelay,
  });
}

/// High-level typed protocol client bound to one remote BLE device.
class BleProtocolClient {
  /// Creates a protocol client for one device.
  BleProtocolClient({
    required this.gattClient,
    required this.remoteId,
    required List<BleProtocolDefinition> protocols,
    this.defaultOperationTimeout = const Duration(seconds: 15),
    ChunkReassembler? chunkReassembler,
  }) : _chunkReassembler = chunkReassembler ?? ChunkReassembler() {
    for (final protocol in protocols) {
      if (_protocolsById.containsKey(protocol.protocolId)) {
        throw ProtocolError('Duplicate protocolId: ${protocol.protocolId}');
      }
      _protocolsById[protocol.protocolId] = protocol;
    }
  }

  /// Low-level GATT transport.
  final BleGattClient gattClient;

  /// Connected remote device id.
  final String remoteId;

  /// Default timeout for protocol operations.
  final Duration defaultOperationTimeout;

  final Map<String, BleProtocolDefinition> _protocolsById =
      <String, BleProtocolDefinition>{};
  final Map<String, _ResolvedCharacteristic> _resolvedChannels =
      <String, _ResolvedCharacteristic>{};
  final ChunkReassembler _chunkReassembler;

  int _nextSequence = 0;

  /// Connection state stream for this device.
  Stream<BleConnectionState> get connectionState =>
      gattClient.observeConnectionState(remoteId);

  /// Returns characteristic reference for one protocol channel.
  Future<BleCharacteristicRef> getChannelCharacteristicRef(
    String protocolId,
    String channelId, {
    bool refresh = false,
    Duration? timeout,
  }) async {
    final resolved = await _resolveCharacteristic(
      protocolId,
      channelId,
      refresh: refresh,
      timeout: timeout,
    );
    return resolved.ref;
  }

  /// Reads and decodes one protocol channel.
  Future<T> readChannel<T>(
    String protocolId,
    String channelId, {
    Duration? timeout,
  }) async {
    final resolved = await _resolveCharacteristic(
      protocolId,
      channelId,
      timeout: timeout,
    );

    if (!resolved.channel.properties.read) {
      throw ProtocolError('Channel $channelId in $protocolId is not readable');
    }
    if (!resolved.properties.read) {
      throw ProtocolError(
        'Characteristic ${resolved.channel.channelUuid} does not support read',
      );
    }

    final raw = await gattClient.readCharacteristic(
      resolved.ref,
      timeout: timeout ?? defaultOperationTimeout,
    );

    final decoded = resolved.channel.codec.decode(raw);
    if (decoded is! T) {
      throw ProtocolError(
        'Decoded value type mismatch for $protocolId/$channelId: '
        'expected $T, got ${decoded.runtimeType}',
      );
    }

    return decoded;
  }

  /// Encodes and writes one protocol channel.
  Future<void> writeChannel<T>(
    String protocolId,
    String channelId,
    T value, {
    bool withoutResponse = false,
    Duration? timeout,
  }) async {
    final resolved = await _resolveCharacteristic(
      protocolId,
      channelId,
      timeout: timeout,
    );

    if (!resolved.channel.properties.write) {
      throw ProtocolError('Channel $channelId in $protocolId is not writable');
    }

    if (withoutResponse && !resolved.properties.writeWithoutResponse) {
      throw ProtocolError(
        'Characteristic ${resolved.channel.channelUuid} does not support '
        'write without response',
      );
    }

    if (!withoutResponse && !resolved.properties.write) {
      throw ProtocolError(
        'Characteristic ${resolved.channel.channelUuid} does not support '
        'write with response',
      );
    }

    final Uint8List encoded;
    try {
      final dynamic codec = resolved.channel.codec;
      encoded = codec.encode(value) as Uint8List;
    } on Object catch (error, stackTrace) {
      throw ProtocolError(
        'Failed to encode write payload for $protocolId/$channelId',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    await gattClient.writeCharacteristic(
      resolved.ref,
      encoded,
      withoutResponse: withoutResponse,
      timeout: timeout ?? defaultOperationTimeout,
    );
  }

  /// Subscribes to a channel and decodes notification payloads.
  Stream<T> subscribeChannel<T>(
    String protocolId,
    String channelId, {
    bool emitCurrentValue = false,
    Duration? timeout,
  }) async* {
    final resolved = await _resolveCharacteristic(
      protocolId,
      channelId,
      timeout: timeout,
    );

    if (!resolved.channel.properties.notify) {
      throw ProtocolError(
        'Channel $channelId in $protocolId is not subscribable',
      );
    }

    if (!resolved.properties.canNotify) {
      throw ProtocolError(
        'Characteristic ${resolved.channel.channelUuid} does not support notify/indicate',
      );
    }

    await for (final raw in gattClient.subscribeToCharacteristic(
      resolved.ref,
      emitCurrentValue: emitCurrentValue,
      timeout: timeout ?? defaultOperationTimeout,
    )) {
      final decoded = resolved.channel.codec.decode(raw);
      if (decoded is! T) {
        throw ProtocolError(
          'Decoded stream value type mismatch for $protocolId/$channelId: '
          'expected $T, got ${decoded.runtimeType}',
        );
      }
      yield decoded;
    }
  }

  /// Encodes and sends data as chunked wire frames over one writable channel.
  Future<void> sendChunked<T>(
    String protocolId,
    String channelId,
    T value, {
    ChunkSendOptions options = const ChunkSendOptions(),
    Duration? timeout,
  }) async {
    final resolved = await _resolveCharacteristic(
      protocolId,
      channelId,
      timeout: timeout,
    );

    if (!resolved.channel.properties.write) {
      throw ProtocolError('Channel $channelId in $protocolId is not writable');
    }

    final Uint8List payload;
    try {
      final dynamic codec = resolved.channel.codec;
      payload = codec.encode(value) as Uint8List;
    } on Object catch (error, stackTrace) {
      throw ProtocolError(
        'Failed to encode chunked payload for $protocolId/$channelId',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    final mtu = gattClient.mtuNow(remoteId);
    final maxWritePayload =
        options.maxWritePayloadSize ??
        (mtu - options.attOverheadBytes).clamp(1, 0xFFFF);

    final maxChunkPayloadSize =
        options.maxChunkPayloadSize ?? (maxWritePayload - chunkFrameHeaderSize);

    if (maxChunkPayloadSize <= 0) {
      throw ChunkError(
        'maxChunkPayloadSize resolved to $maxChunkPayloadSize. '
        'Increase MTU or set maxChunkPayloadSize explicitly.',
      );
    }

    final chunks = chunkPayload(
      payload,
      maxChunkPayloadSize: maxChunkPayloadSize,
    );

    final sequence = options.sequence ?? _takeSequence();
    final opTimeout = timeout ?? defaultOperationTimeout;

    for (var index = 0; index < chunks.length; index += 1) {
      final frame = ChunkFrame(
        version: chunkWireVersion,
        sequence: sequence,
        totalChunks: chunks.length,
        chunkIndex: index,
        payload: chunks[index],
      );
      final encodedFrame = encodeChunkFrame(frame);

      await gattClient.writeCharacteristic(
        resolved.ref,
        encodedFrame,
        withoutResponse: options.withoutResponse,
        timeout: opTimeout,
      );

      final pause = options.interChunkDelay;
      if (pause != null && index + 1 < chunks.length) {
        await Future<void>.delayed(pause);
      }
    }
  }

  /// Subscribes to chunk frames and yields fully reassembled typed payloads.
  Stream<T> subscribeChunkedChannel<T>(
    String protocolId,
    String channelId, {
    String? sessionId,
    bool emitCurrentValue = false,
    Duration? timeout,
  }) async* {
    final resolved = await _resolveCharacteristic(
      protocolId,
      channelId,
      timeout: timeout,
    );

    if (!resolved.channel.properties.notify) {
      throw ProtocolError(
        'Channel $channelId in $protocolId is not subscribable',
      );
    }

    final channelSessionId = sessionId ?? '$remoteId:$protocolId:$channelId';

    await for (final packet in gattClient.subscribeToCharacteristic(
      resolved.ref,
      emitCurrentValue: emitCurrentValue,
      timeout: timeout ?? defaultOperationTimeout,
    )) {
      final frame = decodeChunkFrame(packet);
      final assembled = _chunkReassembler.addFrame(
        sessionId: channelSessionId,
        frame: frame,
      );
      if (assembled == null) {
        continue;
      }
      final decoded = resolved.channel.codec.decode(assembled);
      if (decoded is! T) {
        throw ProtocolError(
          'Decoded chunked value type mismatch for $protocolId/$channelId: '
          'expected $T, got ${decoded.runtimeType}',
        );
      }
      yield decoded;
    }
  }

  /// Clears all cached channel -> characteristic mappings.
  void clearResolvedChannels() {
    _resolvedChannels.clear();
  }

  /// Disposes client-owned state.
  Future<void> dispose() async {
    clearResolvedChannels();
  }

  Future<_ResolvedCharacteristic> _resolveCharacteristic(
    String protocolId,
    String channelId, {
    bool refresh = false,
    Duration? timeout,
  }) async {
    final cacheKey = '$protocolId::$channelId';
    if (!refresh) {
      final cached = _resolvedChannels[cacheKey];
      if (cached != null) {
        return cached;
      }
    }

    final protocol = _protocolsById[protocolId];
    if (protocol == null) {
      throw ProtocolError('Unknown protocolId: $protocolId');
    }

    final channel = protocol.channelById(channelId);
    if (channel == null) {
      throw ProtocolError(
        'Unknown channel "$channelId" in protocol "$protocolId"',
      );
    }

    final services = await gattClient.discoverServices(
      remoteId,
      timeout: timeout ?? defaultOperationTimeout,
    );

    final normalizedServiceUuid = _normalizeUuid(protocol.serviceUuid);
    BleServiceInfo? service;
    for (final candidate in services) {
      if (_normalizeUuid(candidate.uuid) == normalizedServiceUuid) {
        service = candidate;
        break;
      }
    }

    if (service == null) {
      throw ProtocolError(
        'Service ${protocol.serviceUuid} not found for protocol $protocolId',
      );
    }

    final normalizedCharacteristicUuid = _normalizeUuid(channel.channelUuid);
    BleCharacteristicInfo? characteristic;
    for (final candidate in service.characteristics) {
      if (_normalizeUuid(candidate.uuid) == normalizedCharacteristicUuid) {
        characteristic = candidate;
        break;
      }
    }

    if (characteristic == null) {
      throw ProtocolError(
        'Characteristic ${channel.channelUuid} not found for '
        '$protocolId/$channelId',
      );
    }

    final resolved = _ResolvedCharacteristic(
      channel: channel,
      ref: BleCharacteristicRef(
        remoteId: remoteId,
        serviceUuid: service.uuid,
        primaryServiceUuid: service.primaryServiceUuid,
        characteristicUuid: characteristic.uuid,
        instanceId: characteristic.instanceId,
      ),
      properties: characteristic.properties,
    );

    _resolvedChannels[cacheKey] = resolved;
    return resolved;
  }

  String _normalizeUuid(String value) {
    final compact = value.trim().toLowerCase().replaceAll('-', '');
    if (compact.length == 4) {
      return '0000${compact}00001000800000805f9b34fb';
    }
    if (compact.length == 8) {
      return '${compact}00001000800000805f9b34fb';
    }
    return compact;
  }

  int _takeSequence() {
    _nextSequence = (_nextSequence + 1) & 0xFFFFFFFF;
    if (_nextSequence == 0) {
      _nextSequence = 1;
    }
    return _nextSequence;
  }
}

class _ResolvedCharacteristic {
  final BleChannelDefinition<dynamic> channel;
  final BleCharacteristicRef ref;
  final BleCharacteristicProperties properties;

  _ResolvedCharacteristic({
    required this.channel,
    required this.ref,
    required this.properties,
  });
}
