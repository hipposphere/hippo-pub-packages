class CredentialKey {
  final String id;

  const CredentialKey(this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CredentialKey && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => id;

  String toKey() {
    return 'credential_$id';
  }
}
