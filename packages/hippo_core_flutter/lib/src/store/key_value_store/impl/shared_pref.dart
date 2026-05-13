/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:hippo_core/hippo_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesKeyValueStore implements KeyValueStore {
  SharedPreferencesKeyValueStore({this.storePrefix, SharedPreferencesAsync? sharedPreferencesAsync})
    : sharedPreferencesAsync = sharedPreferencesAsync ?? SharedPreferencesAsync();

  final SharedPreferencesAsync sharedPreferencesAsync;
  final String? storePrefix;

  @override
  Future<bool> containsKey(String key) {
    return sharedPreferencesAsync.containsKey(_buildKey(key));
  }

  @override
  Future<bool?> getBool(String key) {
    return sharedPreferencesAsync.getBool(_buildKey(key));
  }

  @override
  Future<double?> getDouble(String key) {
    return sharedPreferencesAsync.getDouble(_buildKey(key));
  }

  @override
  Future<int?> getInt(String key) {
    return sharedPreferencesAsync.getInt(_buildKey(key));
  }

  @override
  Future<String?> getString(String key) {
    return sharedPreferencesAsync.getString(_buildKey(key));
  }

  @override
  Future<void> setBool(String key, bool value) {
    return sharedPreferencesAsync.setBool(_buildKey(key), value);
  }

  @override
  Future<void> setDouble(String key, double value) {
    return sharedPreferencesAsync.setDouble(_buildKey(key), value);
  }

  @override
  Future<void> setInt(String key, int value) {
    return sharedPreferencesAsync.setInt(_buildKey(key), value);
  }

  @override
  Future<void> setString(String key, String value) {
    return sharedPreferencesAsync.setString(_buildKey(key), value);
  }

  @override
  Future<void> removeValue(String key) {
    return sharedPreferencesAsync.remove(_buildKey(key));
  }

  String _buildKey(String key) {
    final prefix = storePrefix;
    if (prefix == null) {
      return key;
    }
    return '$prefix.$key';
  }
}
