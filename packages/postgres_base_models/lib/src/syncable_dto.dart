import 'package:postgres_base_models/postgres_base_models.dart';

/// A commonly used interface for database models which allow caching and syncing on the client.
abstract class SyncableDto {
  const SyncableDto();
  KeyId get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;

  DateTime? get metaDataLocalUpdatedAt {
    final localUpdatedAt = metadata?['local_updated_at'];
    if (localUpdatedAt == null) {
      return null;
    } else {
      return DateTime.parse(localUpdatedAt).toLocal();
    }
  }

  dynamic get metadata;

  bool isUpdatedAfter(SyncableDto other) {
    final localUpdatedAt = metaDataLocalUpdatedAt;
    final otherLocalUpdatedAt = other.metaDataLocalUpdatedAt;

    // Choose the one that is after the other
    final thisLatestUpdatedAt = chooseTheLater(updatedAt, localUpdatedAt);
    final otherLatestUpdatedAt = chooseTheLater(
      other.updatedAt,
      otherLocalUpdatedAt,
    );
    return thisLatestUpdatedAt.isAfter(otherLatestUpdatedAt);
  }

  bool isDeleted() {
    return deletedAt != null;
  }
}

DateTime chooseTheLater(DateTime a, DateTime? b) {
  if (b == null) {
    return a;
  } else if (a.isAfter(b)) {
    return a;
  } else {
    return b;
  }
}
