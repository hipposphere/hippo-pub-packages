class HidException implements Exception {
  final String message;
  HidException(this.message);

  @override
  String toString() => 'HidException: $message';
}

class HidTimeoutException extends HidException {
  HidTimeoutException() : super("Read timeout");
}

class HidDeviceNotFoundException extends HidException {
  HidDeviceNotFoundException() : super("Device not found");
}

class HidPermissionException extends HidException {
  HidPermissionException() : super("Permission denied");
}
