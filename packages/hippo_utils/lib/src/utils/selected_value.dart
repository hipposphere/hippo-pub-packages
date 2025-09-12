class SelectedValue<T> {
  final T value;

  const SelectedValue(this.value);

  @override
  String toString() {
    return 'SelectedValue(value: $value)';
  }

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SelectedValue<T> && other.value == value;
  }
}
