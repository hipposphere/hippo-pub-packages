/// Represents the status of a permission.
enum PermissionStatus {
  /// Permission has been granted by the user.
  granted,

  /// Permission has been explicitly denied by the user.
  denied,

  /// Permission has not been requested yet.
  notDetermined,

  /// This permission is not required on the current platform.
  notRequired,
}
