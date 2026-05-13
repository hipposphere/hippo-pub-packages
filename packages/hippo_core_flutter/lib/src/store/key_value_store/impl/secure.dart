/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hippo_core/hippo_core.dart';

class SecureKeyValueStore implements KeyValueStore {
  SecureKeyValueStore({this.storePrefix, FlutterSecureStorage? secureStorage})
    : secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage secureStorage;
  final String? storePrefix;

  @override
  Future<bool> containsKey(String key) {
    return secureStorage.containsKey(key: _buildKey(key));
  }

  @override
  Future<bool?> getBool(String key) async {
    final value = await secureStorage.read(key: _buildKey(key));
    if (value == null) {
      return null;
    }
    return bool.tryParse(value);
  }

  @override
  Future<double?> getDouble(String key) async {
    final value = await secureStorage.read(key: _buildKey(key));
    if (value == null) {
      return null;
    }
    return double.tryParse(value);
  }

  @override
  Future<int?> getInt(String key) async {
    final value = await secureStorage.read(key: _buildKey(key));
    if (value == null) {
      return null;
    }
    return int.tryParse(value);
  }

  @override
  Future<String?> getString(String key) {
    return secureStorage.read(key: _buildKey(key));
  }

  @override
  Future<void> setBool(String key, bool value) {
    return secureStorage.write(key: _buildKey(key), value: value.toString());
  }

  @override
  Future<void> setDouble(String key, double value) {
    return secureStorage.write(key: _buildKey(key), value: value.toString());
  }

  @override
  Future<void> setInt(String key, int value) {
    return secureStorage.write(key: _buildKey(key), value: value.toString());
  }

  @override
  Future<void> setString(String key, String value) {
    return secureStorage.write(key: _buildKey(key), value: value);
  }

  @override
  Future<void> removeValue(String key) {
    return secureStorage.delete(key: _buildKey(key));
  }

  String _buildKey(String key) {
    final prefix = storePrefix;
    if (prefix == null) {
      return key;
    }
    return '$prefix.$key';
  }
}
