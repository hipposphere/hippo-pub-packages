import 'dart:convert';

import 'package:hippo_core/hippo_core.dart';

/// A controller for a key-value store that manages a single value of type [T].
/// Json encoding and decoding is used to store complex data structures as strings in the key-value store.
class StoreController<T> {
  final KeyValueStore _keyValueStore;
  final ItemDecoder<T> _itemDecoder;
  final ItemEncoder<T> _itemEncoder;
  final String _storeKey;
  final T _defaultValue;

  StoreController({
    required this._keyValueStore,
    required this._storeKey,
    required this._defaultValue,
    required this._itemDecoder,
    required this._itemEncoder,
    T? initialValue,
    bool initializeOnCreation = true,
  }) {
    if (initialValue != null) {
      subject.add(initialValue);
    } else {
      subject.add(null);
    }
    initialize();
  }

  final subject = DataSubject<T?>.empty();

  /// Throws if the current value is null. This can happen if the value has not been initialized yet or if the stored value was null.
  T get currentValue => subject.value!;

  bool get hasValue => subject.hasValue;

  Future<void> initialize() async {
    final value = await _getStoredValue();
    subject.add(value);
  }

  Future<void> update(T newValue) async {
    subject.add(newValue);
    await _storeValue(newValue);
  }

  Future<void> updateBuilder({required T Function(T currentValue) builder}) async {
    final newValue = builder(currentValue);
    await update(newValue);
  }

  Future<T> _getStoredValue() async {
    final data = await _keyValueStore.getString(_storeKey);
    if (data == null) {
      return _defaultValue;
    }
    return _itemDecoder(jsonDecode(data));
  }

  Future<void> _storeValue(T value) async {
    await _keyValueStore.setString(_storeKey, jsonEncode(_itemEncoder(value)));
  }

  void dispose() {
    subject.close();
  }
}
