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
  Future<HidDevice> open(String devicePath) async {
    try {
      final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'open',
        {'path': devicePath},
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
      if (e.code == 'device_not_found') {
        throw HidDeviceNotFoundException();
      } else if (e.code == 'permission_denied') {
        throw HidPermissionException();
      }
      rethrow;
    }
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
