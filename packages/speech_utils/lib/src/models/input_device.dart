/// A discoverable microphone/input capture device exposed by native recorder backends.
final class InputDevice {
  const InputDevice({required this.id, required this.label, this.isDefault = false});

  final String id;
  final String label;
  final bool isDefault;

  factory InputDevice.fromJson(Map<String, Object?> json) {
    return InputDevice(
      id: (json['id'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
      isDefault: (json['isDefault'] as bool?) ?? false,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{'id': id, 'label': label, 'isDefault': isDefault};
  }

  @override
  bool operator ==(Object other) {
    return other is InputDevice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'InputDevice(id: $id, label: $label, isDefault: $isDefault)';
  }
}
