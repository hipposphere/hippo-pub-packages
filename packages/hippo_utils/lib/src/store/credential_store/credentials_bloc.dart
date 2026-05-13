import 'package:flutter/widgets.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_utils/hippo_utils.dart';

class CredentialsBloc extends BlocBase {
  final KeyValueStore keyValueStore;

  CredentialsBloc({required this.keyValueStore});

  CredentialKey generateKey() {
    return CredentialKey(IdGenerator.uuidV4());
  }

  Future<String?> readValue(CredentialKey key) async {
    return keyValueStore.getString(key.toKey());
  }

  Future<void> writeValue(CredentialKey key, String value) async {
    await keyValueStore.setString(key.toKey(), value);
  }

  Future<void> removeValue(CredentialKey key) async {
    await keyValueStore.removeValue(key.toKey());
  }

  @override
  void dispose() {}

  static CredentialsBloc of(BuildContext context) => BlocProvider.of<CredentialsBloc>(context);
}
