import '../key_value_store.dart';

class MockKeyValueStore implements KeyValueStore {
  final Map<String, dynamic> dataMap;

  MockKeyValueStore({Map<String, dynamic>? initialDataMap}) : dataMap = initialDataMap ?? {};
  @override
  Future<bool> containsKey(String key) async {
    return dataMap.containsKey(key);
  }

  @override
  Future<bool?> getBool(String key) async {
    return dataMap[key] as bool?;
  }

  @override
  Future<double?> getDouble(String key) async {
    return dataMap[key] as double?;
  }

  @override
  Future<int?> getInt(String key) async {
    return dataMap[key] as int?;
  }

  @override
  Future<String?> getString(String key) async {
    return dataMap[key] as String?;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    dataMap[key] = value;
  }

  @override
  Future<void> setDouble(String key, double value) async {
    dataMap[key] = value;
  }

  @override
  Future<void> setInt(String key, int value) async {
    dataMap[key] = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    dataMap[key] = value;
  }

  @override
  Future<void> removeValue(String key) async {
    dataMap.remove(key);
  }
}
