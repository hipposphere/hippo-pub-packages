class PartialValue<T> {
  final T value;

  PartialValue(this.value);

  @override
  String toString() {
    return 'PartialValue(value: $value)';
  }

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PartialValue<T> && other.value == value;
  }
}
