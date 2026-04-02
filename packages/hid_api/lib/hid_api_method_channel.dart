import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'hid_api_platform_interface.dart';
import 'src/method_channel_hid_device.dart';

/// An implementation of [HidApiPlatform] that uses method channels.
class MethodChannelHidApi extends HidApiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hid_api');

  @override
  Future<void> initialize() async {
    await methodChannel.invokeMethod<void>('initialize');
  }

  @override
  Future<void> shutdown() async {
    await methodChannel.invokeMethod<void>('shutdown');
  }

  @override
  Future<List<HidDeviceInfo>> enumerate({
    int? vendorId,
    int? productId,
    String? serialNumber,
  }) async {
    final result = await methodChannel.invokeListMethod<Map<dynamic, dynamic>>(
      'enumerate',
      {
        'vendorId': vendorId,
        'productId': productId,
        'serialNumber': serialNumber,
      },
    );

    if (result == null) return [];

    return result.map((deviceMap) {
      return _mapToDeviceInfo(deviceMap);
    }).toList();
  }

  @override
  Future<HidDevice> open(String devicePath, {bool exclusive = false}) async {
    try {
      final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'open',
        {'path': devicePath, 'exclusive': exclusive},
      );

      if (result == null) {
        throw HidDeviceNotFoundException();
      }

      final info = _mapToDeviceInfo(result);

      return MethodChannelHidDevice(
        path: devicePath,
        channel: methodChannel,
        info: info,
      );
    } on PlatformException catch (e) {
      final code = e.code.toUpperCase();

      if (code == 'DEVICE_NOT_FOUND' || code == 'NOT_FOUND') {
        throw HidDeviceNotFoundException();
      } else if (code == 'PERMISSION_DENIED' || code == 'ACCESS_DENIED') {
        throw HidPermissionException();
      } else if (code == 'SHARING_VIOLATION' || code == 'EXCLUSIVE_ACCESS') {
        throw HidExclusiveAccessException();
      }
      throw HidException(e.message ?? 'Failed to open device');
    }
  }

  @override
  Stream<List<HidDeviceInfo>> get deviceListStream {
    const eventChannel = EventChannel('hid_api/device_updates');
    return eventChannel.receiveBroadcastStream().map((event) {
      final list = event as List<dynamic>;
      return list
          .map((e) => _mapToDeviceInfo(e as Map<dynamic, dynamic>))
          .toList();
    });
  }

  HidDeviceInfo _mapToDeviceInfo(Map<dynamic, dynamic> map) {
    return HidDeviceInfo(
      path: map['path'] as String,
      vendorId: map['vendorId'] as int,
      productId: map['productId'] as int,
      releaseNumber: map['releaseNumber'] as int,
      usagePage: map['usagePage'] as int,
      usage: map['usage'] as int,
      manufacturer: map['manufacturer'] as String?,
      product: map['product'] as String?,
      serialNumber: map['serialNumber'] as String?,
      interfaceNumber: map['interfaceNumber'] as int,
    );
  }
}
