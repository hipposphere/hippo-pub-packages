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
  HidDeviceNotFoundException([super.message = "Device not found"]);
}

class HidPermissionException extends HidException {
  HidPermissionException([super.message = "Permission denied"]);
}

class HidExclusiveAccessException extends HidException {
  HidExclusiveAccessException()
    : super(
        "Exclusive access unavailable because the device is already in use",
      );
}
