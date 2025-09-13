sealed class KeyId<T> {
  T get id;

  const KeyId();

  T toJson();
}

abstract class IntId extends KeyId<int> {
  const IntId();

  @override
  int get id;

  @override
  String toString() {
    return id.toString();
  }

  @override
  int toJson() {
    return id;
  }
}

abstract class StringId extends KeyId<String> {
  const StringId();

  @override
  String get id;

  @override
  String toString() {
    return id;
  }

  @override
  String toJson() {
    return id;
  }
}
