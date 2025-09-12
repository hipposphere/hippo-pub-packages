abstract class KeyValueStore {
  Future<bool> containsKey(String key);

  Future<double?> getDouble(String key);

  Future<int?> getInt(String key);

  Future<String?> getString(String key);

  Future<bool?> getBool(String key);

  Future<void> setDouble(String key, double value);

  Future<void> setInt(String key, int value);

  Future<void> setString(String key, String value);

  Future<void> setBool(String key, bool value);

  Future<void> removeValue(String key);
}
