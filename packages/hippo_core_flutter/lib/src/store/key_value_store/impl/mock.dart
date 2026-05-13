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

class MockKeyValueStore implements KeyValueStore {
  MockKeyValueStore({Map<String, Object?>? initialDataMap}) : dataMap = initialDataMap ?? {};

  final Map<String, Object?> dataMap;

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
