import 'channel_codec.dart';

/// Read/write/notify capability declaration for a channel.
class BleChannelProperties {
  /// Whether channel can be read.
  final bool read;

  /// Whether channel can be written.
  final bool write;

  /// Whether channel can be subscribed.
  final bool notify;

  /// Creates [BleChannelProperties].
  const BleChannelProperties({
    this.read = false,
    this.write = false,
    this.notify = false,
  });
}

/// Protocol channel definition.
class BleChannelDefinition<T> {
  /// Logical channel id used by app code.
  final String channelId;

  /// Characteristic UUID for this channel.
  final String channelUuid;

  /// Declared channel properties.
  final BleChannelProperties properties;

  /// Value codec for this channel.
  final ChannelCodec<T> codec;

  /// Creates [BleChannelDefinition].
  const BleChannelDefinition({
    required this.channelId,
    required this.channelUuid,
    required this.properties,
    required this.codec,
  });
}

/// Protocol definition containing service UUID and channel definitions.
class BleProtocolDefinition {
  /// Stable protocol identifier.
  final String protocolId;

  /// BLE service UUID hosting the channels.
  final String serviceUuid;

  /// Channels available within this protocol.
  final List<BleChannelDefinition<dynamic>> channels;

  /// Creates [BleProtocolDefinition].
  BleProtocolDefinition({
    required this.protocolId,
    required this.serviceUuid,
    required List<BleChannelDefinition<dynamic>> channels,
  }) : channels = List<BleChannelDefinition<dynamic>>.unmodifiable(channels);

  /// Looks up one channel by [channelId].
  BleChannelDefinition<dynamic>? channelById(String channelId) {
    for (final channel in channels) {
      if (channel.channelId == channelId) {
        return channel;
      }
    }
    return null;
  }
}
