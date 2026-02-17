// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';
import 'dart:convert';

import 'openapi.enums.swagger.dart' as enums;

part 'openapi.models.swagger.g.dart';

@JsonSerializable(explicitToJson: true)
class ApiV1ApiKeysPost$RequestBody {
  const ApiV1ApiKeysPost$RequestBody({required this.name});

  factory ApiV1ApiKeysPost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$ApiV1ApiKeysPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$ApiV1ApiKeysPost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$ApiV1ApiKeysPost$RequestBodyToJson(this);

  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  static const fromJsonFactory = _$ApiV1ApiKeysPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ApiKeysPost$RequestBody &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(name) ^ runtimeType.hashCode;
}

extension $ApiV1ApiKeysPost$RequestBodyExtension
    on ApiV1ApiKeysPost$RequestBody {
  ApiV1ApiKeysPost$RequestBody copyWith({String? name}) {
    return ApiV1ApiKeysPost$RequestBody(name: name ?? this.name);
  }

  ApiV1ApiKeysPost$RequestBody copyWithWrapped({Wrapped<String>? name}) {
    return ApiV1ApiKeysPost$RequestBody(
      name: (name != null ? name.value : this.name),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1AppsPost$RequestBody {
  const ApiV1AppsPost$RequestBody({
    required this.slug,
    required this.name,
    this.bundleId,
  });

  factory ApiV1AppsPost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$ApiV1AppsPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$ApiV1AppsPost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$ApiV1AppsPost$RequestBodyToJson(this);

  @JsonKey(name: 'slug', includeIfNull: false)
  final String slug;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'bundleId', includeIfNull: false)
  final String? bundleId;
  static const fromJsonFactory = _$ApiV1AppsPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1AppsPost$RequestBody &&
            (identical(other.slug, slug) ||
                const DeepCollectionEquality().equals(other.slug, slug)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.bundleId, bundleId) ||
                const DeepCollectionEquality().equals(
                  other.bundleId,
                  bundleId,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(slug) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(bundleId) ^
      runtimeType.hashCode;
}

extension $ApiV1AppsPost$RequestBodyExtension on ApiV1AppsPost$RequestBody {
  ApiV1AppsPost$RequestBody copyWith({
    String? slug,
    String? name,
    String? bundleId,
  }) {
    return ApiV1AppsPost$RequestBody(
      slug: slug ?? this.slug,
      name: name ?? this.name,
      bundleId: bundleId ?? this.bundleId,
    );
  }

  ApiV1AppsPost$RequestBody copyWithWrapped({
    Wrapped<String>? slug,
    Wrapped<String>? name,
    Wrapped<String?>? bundleId,
  }) {
    return ApiV1AppsPost$RequestBody(
      slug: (slug != null ? slug.value : this.slug),
      name: (name != null ? name.value : this.name),
      bundleId: (bundleId != null ? bundleId.value : this.bundleId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1AppsAppIdRepositoryConnectionPut$RequestBody {
  const ApiV1AppsAppIdRepositoryConnectionPut$RequestBody({
    required this.owner,
    required this.repo,
    this.installationId,
    this.defaultBranch,
    this.workflowFile,
  });

  factory ApiV1AppsAppIdRepositoryConnectionPut$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1AppsAppIdRepositoryConnectionPut$RequestBodyFromJson(json);

  static const toJsonFactory =
      _$ApiV1AppsAppIdRepositoryConnectionPut$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1AppsAppIdRepositoryConnectionPut$RequestBodyToJson(this);

  @JsonKey(name: 'owner', includeIfNull: false)
  final String owner;
  @JsonKey(name: 'repo', includeIfNull: false)
  final String repo;
  @JsonKey(name: 'installationId', includeIfNull: false)
  final String? installationId;
  @JsonKey(name: 'defaultBranch', includeIfNull: false)
  final String? defaultBranch;
  @JsonKey(name: 'workflowFile', includeIfNull: false)
  final String? workflowFile;
  static const fromJsonFactory =
      _$ApiV1AppsAppIdRepositoryConnectionPut$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1AppsAppIdRepositoryConnectionPut$RequestBody &&
            (identical(other.owner, owner) ||
                const DeepCollectionEquality().equals(other.owner, owner)) &&
            (identical(other.repo, repo) ||
                const DeepCollectionEquality().equals(other.repo, repo)) &&
            (identical(other.installationId, installationId) ||
                const DeepCollectionEquality().equals(
                  other.installationId,
                  installationId,
                )) &&
            (identical(other.defaultBranch, defaultBranch) ||
                const DeepCollectionEquality().equals(
                  other.defaultBranch,
                  defaultBranch,
                )) &&
            (identical(other.workflowFile, workflowFile) ||
                const DeepCollectionEquality().equals(
                  other.workflowFile,
                  workflowFile,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(owner) ^
      const DeepCollectionEquality().hash(repo) ^
      const DeepCollectionEquality().hash(installationId) ^
      const DeepCollectionEquality().hash(defaultBranch) ^
      const DeepCollectionEquality().hash(workflowFile) ^
      runtimeType.hashCode;
}

extension $ApiV1AppsAppIdRepositoryConnectionPut$RequestBodyExtension
    on ApiV1AppsAppIdRepositoryConnectionPut$RequestBody {
  ApiV1AppsAppIdRepositoryConnectionPut$RequestBody copyWith({
    String? owner,
    String? repo,
    String? installationId,
    String? defaultBranch,
    String? workflowFile,
  }) {
    return ApiV1AppsAppIdRepositoryConnectionPut$RequestBody(
      owner: owner ?? this.owner,
      repo: repo ?? this.repo,
      installationId: installationId ?? this.installationId,
      defaultBranch: defaultBranch ?? this.defaultBranch,
      workflowFile: workflowFile ?? this.workflowFile,
    );
  }

  ApiV1AppsAppIdRepositoryConnectionPut$RequestBody copyWithWrapped({
    Wrapped<String>? owner,
    Wrapped<String>? repo,
    Wrapped<String?>? installationId,
    Wrapped<String?>? defaultBranch,
    Wrapped<String?>? workflowFile,
  }) {
    return ApiV1AppsAppIdRepositoryConnectionPut$RequestBody(
      owner: (owner != null ? owner.value : this.owner),
      repo: (repo != null ? repo.value : this.repo),
      installationId: (installationId != null
          ? installationId.value
          : this.installationId),
      defaultBranch: (defaultBranch != null
          ? defaultBranch.value
          : this.defaultBranch),
      workflowFile: (workflowFile != null
          ? workflowFile.value
          : this.workflowFile),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1AppsAppIdDeploymentTargetsPost$RequestBody {
  const ApiV1AppsAppIdDeploymentTargetsPost$RequestBody({
    required this.kind,
    required this.name,
    this.config,
  });

  factory ApiV1AppsAppIdDeploymentTargetsPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyFromJson(json);

  static const toJsonFactory =
      _$ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyToJson(this);

  @JsonKey(
    name: 'kind',
    includeIfNull: false,
    toJson: apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKindToJson,
    fromJson: apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKindFromJson,
  )
  final enums.ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind kind;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'config', includeIfNull: false)
  final Map<String, dynamic>? config;
  static const fromJsonFactory =
      _$ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1AppsAppIdDeploymentTargetsPost$RequestBody &&
            (identical(other.kind, kind) ||
                const DeepCollectionEquality().equals(other.kind, kind)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.config, config) ||
                const DeepCollectionEquality().equals(other.config, config)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(kind) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(config) ^
      runtimeType.hashCode;
}

extension $ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyExtension
    on ApiV1AppsAppIdDeploymentTargetsPost$RequestBody {
  ApiV1AppsAppIdDeploymentTargetsPost$RequestBody copyWith({
    enums.ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind? kind,
    String? name,
    Map<String, dynamic>? config,
  }) {
    return ApiV1AppsAppIdDeploymentTargetsPost$RequestBody(
      kind: kind ?? this.kind,
      name: name ?? this.name,
      config: config ?? this.config,
    );
  }

  ApiV1AppsAppIdDeploymentTargetsPost$RequestBody copyWithWrapped({
    Wrapped<enums.ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind>? kind,
    Wrapped<String>? name,
    Wrapped<Map<String, dynamic>?>? config,
  }) {
    return ApiV1AppsAppIdDeploymentTargetsPost$RequestBody(
      kind: (kind != null ? kind.value : this.kind),
      name: (name != null ? name.value : this.name),
      config: (config != null ? config.value : this.config),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1AppsAppIdBuildProfilesPost$RequestBody {
  const ApiV1AppsAppIdBuildProfilesPost$RequestBody({
    required this.name,
    required this.platform,
    required this.packageType,
    this.arch,
    required this.workflowIdentifier,
    this.workflowRef,
    this.workflowInputs,
    this.artifactPathGlob,
    this.autoDeployTargetId,
  });

  factory ApiV1AppsAppIdBuildProfilesPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1AppsAppIdBuildProfilesPost$RequestBodyFromJson(json);

  static const toJsonFactory =
      _$ApiV1AppsAppIdBuildProfilesPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1AppsAppIdBuildProfilesPost$RequestBodyToJson(this);

  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(
    name: 'platform',
    includeIfNull: false,
    toJson: apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatformToJson,
    fromJson: apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatformFromJson,
  )
  final enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform platform;
  @JsonKey(name: 'packageType', includeIfNull: false)
  final String packageType;
  @JsonKey(
    name: 'arch',
    includeIfNull: false,
    toJson: apiV1AppsAppIdBuildProfilesPost$RequestBodyArchNullableToJson,
    fromJson: apiV1AppsAppIdBuildProfilesPost$RequestBodyArchNullableFromJson,
  )
  final enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch? arch;
  @JsonKey(name: 'workflowIdentifier', includeIfNull: false)
  final String workflowIdentifier;
  @JsonKey(name: 'workflowRef', includeIfNull: false)
  final String? workflowRef;
  @JsonKey(name: 'workflowInputs', includeIfNull: false)
  final Map<String, dynamic>? workflowInputs;
  @JsonKey(name: 'artifactPathGlob', includeIfNull: false)
  final String? artifactPathGlob;
  @JsonKey(name: 'autoDeployTargetId', includeIfNull: false)
  final String? autoDeployTargetId;
  static const fromJsonFactory =
      _$ApiV1AppsAppIdBuildProfilesPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1AppsAppIdBuildProfilesPost$RequestBody &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.platform, platform) ||
                const DeepCollectionEquality().equals(
                  other.platform,
                  platform,
                )) &&
            (identical(other.packageType, packageType) ||
                const DeepCollectionEquality().equals(
                  other.packageType,
                  packageType,
                )) &&
            (identical(other.arch, arch) ||
                const DeepCollectionEquality().equals(other.arch, arch)) &&
            (identical(other.workflowIdentifier, workflowIdentifier) ||
                const DeepCollectionEquality().equals(
                  other.workflowIdentifier,
                  workflowIdentifier,
                )) &&
            (identical(other.workflowRef, workflowRef) ||
                const DeepCollectionEquality().equals(
                  other.workflowRef,
                  workflowRef,
                )) &&
            (identical(other.workflowInputs, workflowInputs) ||
                const DeepCollectionEquality().equals(
                  other.workflowInputs,
                  workflowInputs,
                )) &&
            (identical(other.artifactPathGlob, artifactPathGlob) ||
                const DeepCollectionEquality().equals(
                  other.artifactPathGlob,
                  artifactPathGlob,
                )) &&
            (identical(other.autoDeployTargetId, autoDeployTargetId) ||
                const DeepCollectionEquality().equals(
                  other.autoDeployTargetId,
                  autoDeployTargetId,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(platform) ^
      const DeepCollectionEquality().hash(packageType) ^
      const DeepCollectionEquality().hash(arch) ^
      const DeepCollectionEquality().hash(workflowIdentifier) ^
      const DeepCollectionEquality().hash(workflowRef) ^
      const DeepCollectionEquality().hash(workflowInputs) ^
      const DeepCollectionEquality().hash(artifactPathGlob) ^
      const DeepCollectionEquality().hash(autoDeployTargetId) ^
      runtimeType.hashCode;
}

extension $ApiV1AppsAppIdBuildProfilesPost$RequestBodyExtension
    on ApiV1AppsAppIdBuildProfilesPost$RequestBody {
  ApiV1AppsAppIdBuildProfilesPost$RequestBody copyWith({
    String? name,
    enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform? platform,
    String? packageType,
    enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch? arch,
    String? workflowIdentifier,
    String? workflowRef,
    Map<String, dynamic>? workflowInputs,
    String? artifactPathGlob,
    String? autoDeployTargetId,
  }) {
    return ApiV1AppsAppIdBuildProfilesPost$RequestBody(
      name: name ?? this.name,
      platform: platform ?? this.platform,
      packageType: packageType ?? this.packageType,
      arch: arch ?? this.arch,
      workflowIdentifier: workflowIdentifier ?? this.workflowIdentifier,
      workflowRef: workflowRef ?? this.workflowRef,
      workflowInputs: workflowInputs ?? this.workflowInputs,
      artifactPathGlob: artifactPathGlob ?? this.artifactPathGlob,
      autoDeployTargetId: autoDeployTargetId ?? this.autoDeployTargetId,
    );
  }

  ApiV1AppsAppIdBuildProfilesPost$RequestBody copyWithWrapped({
    Wrapped<String>? name,
    Wrapped<enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform>?
    platform,
    Wrapped<String>? packageType,
    Wrapped<enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch?>? arch,
    Wrapped<String>? workflowIdentifier,
    Wrapped<String?>? workflowRef,
    Wrapped<Map<String, dynamic>?>? workflowInputs,
    Wrapped<String?>? artifactPathGlob,
    Wrapped<String?>? autoDeployTargetId,
  }) {
    return ApiV1AppsAppIdBuildProfilesPost$RequestBody(
      name: (name != null ? name.value : this.name),
      platform: (platform != null ? platform.value : this.platform),
      packageType: (packageType != null ? packageType.value : this.packageType),
      arch: (arch != null ? arch.value : this.arch),
      workflowIdentifier: (workflowIdentifier != null
          ? workflowIdentifier.value
          : this.workflowIdentifier),
      workflowRef: (workflowRef != null ? workflowRef.value : this.workflowRef),
      workflowInputs: (workflowInputs != null
          ? workflowInputs.value
          : this.workflowInputs),
      artifactPathGlob: (artifactPathGlob != null
          ? artifactPathGlob.value
          : this.artifactPathGlob),
      autoDeployTargetId: (autoDeployTargetId != null
          ? autoDeployTargetId.value
          : this.autoDeployTargetId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1AppsAppIdPipelineRunsPost$RequestBody {
  const ApiV1AppsAppIdPipelineRunsPost$RequestBody({
    this.branch,
    required this.profileIds,
    this.triggerMode,
    this.releaseId,
    this.commitSha,
  });

  factory ApiV1AppsAppIdPipelineRunsPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1AppsAppIdPipelineRunsPost$RequestBodyFromJson(json);

  static const toJsonFactory =
      _$ApiV1AppsAppIdPipelineRunsPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1AppsAppIdPipelineRunsPost$RequestBodyToJson(this);

  @JsonKey(name: 'branch', includeIfNull: false)
  final String? branch;
  @JsonKey(name: 'profileIds', includeIfNull: false, defaultValue: <String>[])
  final List<String> profileIds;
  @JsonKey(
    name: 'triggerMode',
    includeIfNull: false,
    toJson: apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerModeNullableToJson,
    fromJson:
        apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerModeNullableFromJson,
  )
  final enums.ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode?
  triggerMode;
  @JsonKey(name: 'releaseId', includeIfNull: false)
  final String? releaseId;
  @JsonKey(name: 'commitSha', includeIfNull: false)
  final String? commitSha;
  static const fromJsonFactory =
      _$ApiV1AppsAppIdPipelineRunsPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1AppsAppIdPipelineRunsPost$RequestBody &&
            (identical(other.branch, branch) ||
                const DeepCollectionEquality().equals(other.branch, branch)) &&
            (identical(other.profileIds, profileIds) ||
                const DeepCollectionEquality().equals(
                  other.profileIds,
                  profileIds,
                )) &&
            (identical(other.triggerMode, triggerMode) ||
                const DeepCollectionEquality().equals(
                  other.triggerMode,
                  triggerMode,
                )) &&
            (identical(other.releaseId, releaseId) ||
                const DeepCollectionEquality().equals(
                  other.releaseId,
                  releaseId,
                )) &&
            (identical(other.commitSha, commitSha) ||
                const DeepCollectionEquality().equals(
                  other.commitSha,
                  commitSha,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(branch) ^
      const DeepCollectionEquality().hash(profileIds) ^
      const DeepCollectionEquality().hash(triggerMode) ^
      const DeepCollectionEquality().hash(releaseId) ^
      const DeepCollectionEquality().hash(commitSha) ^
      runtimeType.hashCode;
}

extension $ApiV1AppsAppIdPipelineRunsPost$RequestBodyExtension
    on ApiV1AppsAppIdPipelineRunsPost$RequestBody {
  ApiV1AppsAppIdPipelineRunsPost$RequestBody copyWith({
    String? branch,
    List<String>? profileIds,
    enums.ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode? triggerMode,
    String? releaseId,
    String? commitSha,
  }) {
    return ApiV1AppsAppIdPipelineRunsPost$RequestBody(
      branch: branch ?? this.branch,
      profileIds: profileIds ?? this.profileIds,
      triggerMode: triggerMode ?? this.triggerMode,
      releaseId: releaseId ?? this.releaseId,
      commitSha: commitSha ?? this.commitSha,
    );
  }

  ApiV1AppsAppIdPipelineRunsPost$RequestBody copyWithWrapped({
    Wrapped<String?>? branch,
    Wrapped<List<String>>? profileIds,
    Wrapped<enums.ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode?>?
    triggerMode,
    Wrapped<String?>? releaseId,
    Wrapped<String?>? commitSha,
  }) {
    return ApiV1AppsAppIdPipelineRunsPost$RequestBody(
      branch: (branch != null ? branch.value : this.branch),
      profileIds: (profileIds != null ? profileIds.value : this.profileIds),
      triggerMode: (triggerMode != null ? triggerMode.value : this.triggerMode),
      releaseId: (releaseId != null ? releaseId.value : this.releaseId),
      commitSha: (commitSha != null ? commitSha.value : this.commitSha),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ChannelsPost$RequestBody {
  const ApiV1ChannelsPost$RequestBody({
    required this.appId,
    required this.slug,
    this.displayName,
    required this.kind,
    this.visibility,
    this.parentChannelId,
    this.rolloutPercent,
  });

  factory ApiV1ChannelsPost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$ApiV1ChannelsPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$ApiV1ChannelsPost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$ApiV1ChannelsPost$RequestBodyToJson(this);

  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(name: 'slug', includeIfNull: false)
  final String slug;
  @JsonKey(name: 'displayName', includeIfNull: false)
  final String? displayName;
  @JsonKey(
    name: 'kind',
    includeIfNull: false,
    toJson: apiV1ChannelsPost$RequestBodyKindToJson,
    fromJson: apiV1ChannelsPost$RequestBodyKindFromJson,
  )
  final enums.ApiV1ChannelsPost$RequestBodyKind kind;
  @JsonKey(
    name: 'visibility',
    includeIfNull: false,
    toJson: apiV1ChannelsPost$RequestBodyVisibilityNullableToJson,
    fromJson: apiV1ChannelsPost$RequestBodyVisibilityNullableFromJson,
  )
  final enums.ApiV1ChannelsPost$RequestBodyVisibility? visibility;
  @JsonKey(name: 'parentChannelId', includeIfNull: false)
  final String? parentChannelId;
  @JsonKey(name: 'rolloutPercent', includeIfNull: false)
  final int? rolloutPercent;
  static const fromJsonFactory = _$ApiV1ChannelsPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ChannelsPost$RequestBody &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.slug, slug) ||
                const DeepCollectionEquality().equals(other.slug, slug)) &&
            (identical(other.displayName, displayName) ||
                const DeepCollectionEquality().equals(
                  other.displayName,
                  displayName,
                )) &&
            (identical(other.kind, kind) ||
                const DeepCollectionEquality().equals(other.kind, kind)) &&
            (identical(other.visibility, visibility) ||
                const DeepCollectionEquality().equals(
                  other.visibility,
                  visibility,
                )) &&
            (identical(other.parentChannelId, parentChannelId) ||
                const DeepCollectionEquality().equals(
                  other.parentChannelId,
                  parentChannelId,
                )) &&
            (identical(other.rolloutPercent, rolloutPercent) ||
                const DeepCollectionEquality().equals(
                  other.rolloutPercent,
                  rolloutPercent,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(slug) ^
      const DeepCollectionEquality().hash(displayName) ^
      const DeepCollectionEquality().hash(kind) ^
      const DeepCollectionEquality().hash(visibility) ^
      const DeepCollectionEquality().hash(parentChannelId) ^
      const DeepCollectionEquality().hash(rolloutPercent) ^
      runtimeType.hashCode;
}

extension $ApiV1ChannelsPost$RequestBodyExtension
    on ApiV1ChannelsPost$RequestBody {
  ApiV1ChannelsPost$RequestBody copyWith({
    String? appId,
    String? slug,
    String? displayName,
    enums.ApiV1ChannelsPost$RequestBodyKind? kind,
    enums.ApiV1ChannelsPost$RequestBodyVisibility? visibility,
    String? parentChannelId,
    int? rolloutPercent,
  }) {
    return ApiV1ChannelsPost$RequestBody(
      appId: appId ?? this.appId,
      slug: slug ?? this.slug,
      displayName: displayName ?? this.displayName,
      kind: kind ?? this.kind,
      visibility: visibility ?? this.visibility,
      parentChannelId: parentChannelId ?? this.parentChannelId,
      rolloutPercent: rolloutPercent ?? this.rolloutPercent,
    );
  }

  ApiV1ChannelsPost$RequestBody copyWithWrapped({
    Wrapped<String>? appId,
    Wrapped<String>? slug,
    Wrapped<String?>? displayName,
    Wrapped<enums.ApiV1ChannelsPost$RequestBodyKind>? kind,
    Wrapped<enums.ApiV1ChannelsPost$RequestBodyVisibility?>? visibility,
    Wrapped<String?>? parentChannelId,
    Wrapped<int?>? rolloutPercent,
  }) {
    return ApiV1ChannelsPost$RequestBody(
      appId: (appId != null ? appId.value : this.appId),
      slug: (slug != null ? slug.value : this.slug),
      displayName: (displayName != null ? displayName.value : this.displayName),
      kind: (kind != null ? kind.value : this.kind),
      visibility: (visibility != null ? visibility.value : this.visibility),
      parentChannelId: (parentChannelId != null
          ? parentChannelId.value
          : this.parentChannelId),
      rolloutPercent: (rolloutPercent != null
          ? rolloutPercent.value
          : this.rolloutPercent),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ChannelsChannelIdPatch$RequestBody {
  const ApiV1ChannelsChannelIdPatch$RequestBody({
    this.displayName,
    this.visibility,
    this.rolloutPercent,
  });

  factory ApiV1ChannelsChannelIdPatch$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1ChannelsChannelIdPatch$RequestBodyFromJson(json);

  static const toJsonFactory = _$ApiV1ChannelsChannelIdPatch$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1ChannelsChannelIdPatch$RequestBodyToJson(this);

  @JsonKey(name: 'displayName', includeIfNull: false)
  final String? displayName;
  @JsonKey(
    name: 'visibility',
    includeIfNull: false,
    toJson: apiV1ChannelsChannelIdPatch$RequestBodyVisibilityNullableToJson,
    fromJson: apiV1ChannelsChannelIdPatch$RequestBodyVisibilityNullableFromJson,
  )
  final enums.ApiV1ChannelsChannelIdPatch$RequestBodyVisibility? visibility;
  @JsonKey(name: 'rolloutPercent', includeIfNull: false)
  final int? rolloutPercent;
  static const fromJsonFactory =
      _$ApiV1ChannelsChannelIdPatch$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ChannelsChannelIdPatch$RequestBody &&
            (identical(other.displayName, displayName) ||
                const DeepCollectionEquality().equals(
                  other.displayName,
                  displayName,
                )) &&
            (identical(other.visibility, visibility) ||
                const DeepCollectionEquality().equals(
                  other.visibility,
                  visibility,
                )) &&
            (identical(other.rolloutPercent, rolloutPercent) ||
                const DeepCollectionEquality().equals(
                  other.rolloutPercent,
                  rolloutPercent,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(displayName) ^
      const DeepCollectionEquality().hash(visibility) ^
      const DeepCollectionEquality().hash(rolloutPercent) ^
      runtimeType.hashCode;
}

extension $ApiV1ChannelsChannelIdPatch$RequestBodyExtension
    on ApiV1ChannelsChannelIdPatch$RequestBody {
  ApiV1ChannelsChannelIdPatch$RequestBody copyWith({
    String? displayName,
    enums.ApiV1ChannelsChannelIdPatch$RequestBodyVisibility? visibility,
    int? rolloutPercent,
  }) {
    return ApiV1ChannelsChannelIdPatch$RequestBody(
      displayName: displayName ?? this.displayName,
      visibility: visibility ?? this.visibility,
      rolloutPercent: rolloutPercent ?? this.rolloutPercent,
    );
  }

  ApiV1ChannelsChannelIdPatch$RequestBody copyWithWrapped({
    Wrapped<String?>? displayName,
    Wrapped<enums.ApiV1ChannelsChannelIdPatch$RequestBodyVisibility?>?
    visibility,
    Wrapped<int?>? rolloutPercent,
  }) {
    return ApiV1ChannelsChannelIdPatch$RequestBody(
      displayName: (displayName != null ? displayName.value : this.displayName),
      visibility: (visibility != null ? visibility.value : this.visibility),
      rolloutPercent: (rolloutPercent != null
          ? rolloutPercent.value
          : this.rolloutPercent),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ChannelsChannelIdRollbackPost$RequestBody {
  const ApiV1ChannelsChannelIdRollbackPost$RequestBody({
    this.platform,
    this.arch,
    this.toReleaseId,
  });

  factory ApiV1ChannelsChannelIdRollbackPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1ChannelsChannelIdRollbackPost$RequestBodyFromJson(json);

  static const toJsonFactory =
      _$ApiV1ChannelsChannelIdRollbackPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1ChannelsChannelIdRollbackPost$RequestBodyToJson(this);

  @JsonKey(
    name: 'platform',
    includeIfNull: false,
    toJson:
        apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatformNullableToJson,
    fromJson:
        apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatformNullableFromJson,
  )
  final enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform? platform;
  @JsonKey(
    name: 'arch',
    includeIfNull: false,
    toJson: apiV1ChannelsChannelIdRollbackPost$RequestBodyArchNullableToJson,
    fromJson:
        apiV1ChannelsChannelIdRollbackPost$RequestBodyArchNullableFromJson,
  )
  final enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch? arch;
  @JsonKey(name: 'toReleaseId', includeIfNull: false)
  final String? toReleaseId;
  static const fromJsonFactory =
      _$ApiV1ChannelsChannelIdRollbackPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ChannelsChannelIdRollbackPost$RequestBody &&
            (identical(other.platform, platform) ||
                const DeepCollectionEquality().equals(
                  other.platform,
                  platform,
                )) &&
            (identical(other.arch, arch) ||
                const DeepCollectionEquality().equals(other.arch, arch)) &&
            (identical(other.toReleaseId, toReleaseId) ||
                const DeepCollectionEquality().equals(
                  other.toReleaseId,
                  toReleaseId,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(platform) ^
      const DeepCollectionEquality().hash(arch) ^
      const DeepCollectionEquality().hash(toReleaseId) ^
      runtimeType.hashCode;
}

extension $ApiV1ChannelsChannelIdRollbackPost$RequestBodyExtension
    on ApiV1ChannelsChannelIdRollbackPost$RequestBody {
  ApiV1ChannelsChannelIdRollbackPost$RequestBody copyWith({
    enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform? platform,
    enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch? arch,
    String? toReleaseId,
  }) {
    return ApiV1ChannelsChannelIdRollbackPost$RequestBody(
      platform: platform ?? this.platform,
      arch: arch ?? this.arch,
      toReleaseId: toReleaseId ?? this.toReleaseId,
    );
  }

  ApiV1ChannelsChannelIdRollbackPost$RequestBody copyWithWrapped({
    Wrapped<enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform?>?
    platform,
    Wrapped<enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch?>? arch,
    Wrapped<String?>? toReleaseId,
  }) {
    return ApiV1ChannelsChannelIdRollbackPost$RequestBody(
      platform: (platform != null ? platform.value : this.platform),
      arch: (arch != null ? arch.value : this.arch),
      toReleaseId: (toReleaseId != null ? toReleaseId.value : this.toReleaseId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ReleasesPost$RequestBody {
  const ApiV1ReleasesPost$RequestBody({
    required this.appId,
    required this.version,
    this.buildNumber,
    this.notes,
  });

  factory ApiV1ReleasesPost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$ApiV1ReleasesPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$ApiV1ReleasesPost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$ApiV1ReleasesPost$RequestBodyToJson(this);

  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(name: 'version', includeIfNull: false)
  final String version;
  @JsonKey(name: 'buildNumber', includeIfNull: false)
  final String? buildNumber;
  @JsonKey(name: 'notes', includeIfNull: false)
  final String? notes;
  static const fromJsonFactory = _$ApiV1ReleasesPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ReleasesPost$RequestBody &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(
                  other.version,
                  version,
                )) &&
            (identical(other.buildNumber, buildNumber) ||
                const DeepCollectionEquality().equals(
                  other.buildNumber,
                  buildNumber,
                )) &&
            (identical(other.notes, notes) ||
                const DeepCollectionEquality().equals(other.notes, notes)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(version) ^
      const DeepCollectionEquality().hash(buildNumber) ^
      const DeepCollectionEquality().hash(notes) ^
      runtimeType.hashCode;
}

extension $ApiV1ReleasesPost$RequestBodyExtension
    on ApiV1ReleasesPost$RequestBody {
  ApiV1ReleasesPost$RequestBody copyWith({
    String? appId,
    String? version,
    String? buildNumber,
    String? notes,
  }) {
    return ApiV1ReleasesPost$RequestBody(
      appId: appId ?? this.appId,
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
      notes: notes ?? this.notes,
    );
  }

  ApiV1ReleasesPost$RequestBody copyWithWrapped({
    Wrapped<String>? appId,
    Wrapped<String>? version,
    Wrapped<String?>? buildNumber,
    Wrapped<String?>? notes,
  }) {
    return ApiV1ReleasesPost$RequestBody(
      appId: (appId != null ? appId.value : this.appId),
      version: (version != null ? version.value : this.version),
      buildNumber: (buildNumber != null ? buildNumber.value : this.buildNumber),
      notes: (notes != null ? notes.value : this.notes),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ReleasesReleaseIdPublishPost$RequestBody {
  const ApiV1ReleasesReleaseIdPublishPost$RequestBody({required this.targets});

  factory ApiV1ReleasesReleaseIdPublishPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1ReleasesReleaseIdPublishPost$RequestBodyFromJson(json);

  static const toJsonFactory =
      _$ApiV1ReleasesReleaseIdPublishPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1ReleasesReleaseIdPublishPost$RequestBodyToJson(this);

  @JsonKey(name: 'targets', includeIfNull: false)
  final List<ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$Item>
  targets;
  static const fromJsonFactory =
      _$ApiV1ReleasesReleaseIdPublishPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ReleasesReleaseIdPublishPost$RequestBody &&
            (identical(other.targets, targets) ||
                const DeepCollectionEquality().equals(other.targets, targets)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(targets) ^ runtimeType.hashCode;
}

extension $ApiV1ReleasesReleaseIdPublishPost$RequestBodyExtension
    on ApiV1ReleasesReleaseIdPublishPost$RequestBody {
  ApiV1ReleasesReleaseIdPublishPost$RequestBody copyWith({
    List<ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$Item>? targets,
  }) {
    return ApiV1ReleasesReleaseIdPublishPost$RequestBody(
      targets: targets ?? this.targets,
    );
  }

  ApiV1ReleasesReleaseIdPublishPost$RequestBody copyWithWrapped({
    Wrapped<List<ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$Item>>?
    targets,
  }) {
    return ApiV1ReleasesReleaseIdPublishPost$RequestBody(
      targets: (targets != null ? targets.value : this.targets),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ReleasesReleaseIdPromotePost$RequestBody {
  const ApiV1ReleasesReleaseIdPromotePost$RequestBody({
    required this.fromChannelId,
    required this.toChannelId,
    this.platform,
    this.arch,
  });

  factory ApiV1ReleasesReleaseIdPromotePost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1ReleasesReleaseIdPromotePost$RequestBodyFromJson(json);

  static const toJsonFactory =
      _$ApiV1ReleasesReleaseIdPromotePost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1ReleasesReleaseIdPromotePost$RequestBodyToJson(this);

  @JsonKey(name: 'fromChannelId', includeIfNull: false)
  final String fromChannelId;
  @JsonKey(name: 'toChannelId', includeIfNull: false)
  final String toChannelId;
  @JsonKey(
    name: 'platform',
    includeIfNull: false,
    toJson: apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatformNullableToJson,
    fromJson:
        apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatformNullableFromJson,
  )
  final enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform? platform;
  @JsonKey(
    name: 'arch',
    includeIfNull: false,
    toJson: apiV1ReleasesReleaseIdPromotePost$RequestBodyArchNullableToJson,
    fromJson: apiV1ReleasesReleaseIdPromotePost$RequestBodyArchNullableFromJson,
  )
  final enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch? arch;
  static const fromJsonFactory =
      _$ApiV1ReleasesReleaseIdPromotePost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ReleasesReleaseIdPromotePost$RequestBody &&
            (identical(other.fromChannelId, fromChannelId) ||
                const DeepCollectionEquality().equals(
                  other.fromChannelId,
                  fromChannelId,
                )) &&
            (identical(other.toChannelId, toChannelId) ||
                const DeepCollectionEquality().equals(
                  other.toChannelId,
                  toChannelId,
                )) &&
            (identical(other.platform, platform) ||
                const DeepCollectionEquality().equals(
                  other.platform,
                  platform,
                )) &&
            (identical(other.arch, arch) ||
                const DeepCollectionEquality().equals(other.arch, arch)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(fromChannelId) ^
      const DeepCollectionEquality().hash(toChannelId) ^
      const DeepCollectionEquality().hash(platform) ^
      const DeepCollectionEquality().hash(arch) ^
      runtimeType.hashCode;
}

extension $ApiV1ReleasesReleaseIdPromotePost$RequestBodyExtension
    on ApiV1ReleasesReleaseIdPromotePost$RequestBody {
  ApiV1ReleasesReleaseIdPromotePost$RequestBody copyWith({
    String? fromChannelId,
    String? toChannelId,
    enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform? platform,
    enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch? arch,
  }) {
    return ApiV1ReleasesReleaseIdPromotePost$RequestBody(
      fromChannelId: fromChannelId ?? this.fromChannelId,
      toChannelId: toChannelId ?? this.toChannelId,
      platform: platform ?? this.platform,
      arch: arch ?? this.arch,
    );
  }

  ApiV1ReleasesReleaseIdPromotePost$RequestBody copyWithWrapped({
    Wrapped<String>? fromChannelId,
    Wrapped<String>? toChannelId,
    Wrapped<enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform?>?
    platform,
    Wrapped<enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch?>? arch,
  }) {
    return ApiV1ReleasesReleaseIdPromotePost$RequestBody(
      fromChannelId: (fromChannelId != null
          ? fromChannelId.value
          : this.fromChannelId),
      toChannelId: (toChannelId != null ? toChannelId.value : this.toChannelId),
      platform: (platform != null ? platform.value : this.platform),
      arch: (arch != null ? arch.value : this.arch),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ArtifactsUploadUrlPost$RequestBody {
  const ApiV1ArtifactsUploadUrlPost$RequestBody({
    required this.platform,
    this.arch,
    required this.packageType,
    required this.fileName,
    this.sizeBytes,
    this.sha256,
    this.assignChannelSlug,
    required this.appSlug,
    required this.version,
    this.buildNumber,
    this.notes,
  });

  factory ApiV1ArtifactsUploadUrlPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1ArtifactsUploadUrlPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$ApiV1ArtifactsUploadUrlPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1ArtifactsUploadUrlPost$RequestBodyToJson(this);

  @JsonKey(
    name: 'platform',
    includeIfNull: false,
    toJson: apiV1ArtifactsUploadUrlPost$RequestBodyPlatformToJson,
    fromJson: apiV1ArtifactsUploadUrlPost$RequestBodyPlatformFromJson,
  )
  final enums.ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform platform;
  @JsonKey(
    name: 'arch',
    includeIfNull: false,
    toJson: apiV1ArtifactsUploadUrlPost$RequestBodyArchNullableToJson,
    fromJson: apiV1ArtifactsUploadUrlPost$RequestBodyArchNullableFromJson,
  )
  final enums.ApiV1ArtifactsUploadUrlPost$RequestBodyArch? arch;
  @JsonKey(name: 'packageType', includeIfNull: false)
  final String packageType;
  @JsonKey(name: 'fileName', includeIfNull: false)
  final String fileName;
  @JsonKey(name: 'sizeBytes', includeIfNull: false)
  final int? sizeBytes;
  @JsonKey(name: 'sha256', includeIfNull: false)
  final String? sha256;
  @JsonKey(name: 'assignChannelSlug', includeIfNull: false)
  final String? assignChannelSlug;
  @JsonKey(name: 'appSlug', includeIfNull: false)
  final String appSlug;
  @JsonKey(name: 'version', includeIfNull: false)
  final String version;
  @JsonKey(name: 'buildNumber', includeIfNull: false)
  final String? buildNumber;
  @JsonKey(name: 'notes', includeIfNull: false)
  final String? notes;
  static const fromJsonFactory =
      _$ApiV1ArtifactsUploadUrlPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ArtifactsUploadUrlPost$RequestBody &&
            (identical(other.platform, platform) ||
                const DeepCollectionEquality().equals(
                  other.platform,
                  platform,
                )) &&
            (identical(other.arch, arch) ||
                const DeepCollectionEquality().equals(other.arch, arch)) &&
            (identical(other.packageType, packageType) ||
                const DeepCollectionEquality().equals(
                  other.packageType,
                  packageType,
                )) &&
            (identical(other.fileName, fileName) ||
                const DeepCollectionEquality().equals(
                  other.fileName,
                  fileName,
                )) &&
            (identical(other.sizeBytes, sizeBytes) ||
                const DeepCollectionEquality().equals(
                  other.sizeBytes,
                  sizeBytes,
                )) &&
            (identical(other.sha256, sha256) ||
                const DeepCollectionEquality().equals(other.sha256, sha256)) &&
            (identical(other.assignChannelSlug, assignChannelSlug) ||
                const DeepCollectionEquality().equals(
                  other.assignChannelSlug,
                  assignChannelSlug,
                )) &&
            (identical(other.appSlug, appSlug) ||
                const DeepCollectionEquality().equals(
                  other.appSlug,
                  appSlug,
                )) &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(
                  other.version,
                  version,
                )) &&
            (identical(other.buildNumber, buildNumber) ||
                const DeepCollectionEquality().equals(
                  other.buildNumber,
                  buildNumber,
                )) &&
            (identical(other.notes, notes) ||
                const DeepCollectionEquality().equals(other.notes, notes)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(platform) ^
      const DeepCollectionEquality().hash(arch) ^
      const DeepCollectionEquality().hash(packageType) ^
      const DeepCollectionEquality().hash(fileName) ^
      const DeepCollectionEquality().hash(sizeBytes) ^
      const DeepCollectionEquality().hash(sha256) ^
      const DeepCollectionEquality().hash(assignChannelSlug) ^
      const DeepCollectionEquality().hash(appSlug) ^
      const DeepCollectionEquality().hash(version) ^
      const DeepCollectionEquality().hash(buildNumber) ^
      const DeepCollectionEquality().hash(notes) ^
      runtimeType.hashCode;
}

extension $ApiV1ArtifactsUploadUrlPost$RequestBodyExtension
    on ApiV1ArtifactsUploadUrlPost$RequestBody {
  ApiV1ArtifactsUploadUrlPost$RequestBody copyWith({
    enums.ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform? platform,
    enums.ApiV1ArtifactsUploadUrlPost$RequestBodyArch? arch,
    String? packageType,
    String? fileName,
    int? sizeBytes,
    String? sha256,
    String? assignChannelSlug,
    String? appSlug,
    String? version,
    String? buildNumber,
    String? notes,
  }) {
    return ApiV1ArtifactsUploadUrlPost$RequestBody(
      platform: platform ?? this.platform,
      arch: arch ?? this.arch,
      packageType: packageType ?? this.packageType,
      fileName: fileName ?? this.fileName,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      sha256: sha256 ?? this.sha256,
      assignChannelSlug: assignChannelSlug ?? this.assignChannelSlug,
      appSlug: appSlug ?? this.appSlug,
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
      notes: notes ?? this.notes,
    );
  }

  ApiV1ArtifactsUploadUrlPost$RequestBody copyWithWrapped({
    Wrapped<enums.ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform>? platform,
    Wrapped<enums.ApiV1ArtifactsUploadUrlPost$RequestBodyArch?>? arch,
    Wrapped<String>? packageType,
    Wrapped<String>? fileName,
    Wrapped<int?>? sizeBytes,
    Wrapped<String?>? sha256,
    Wrapped<String?>? assignChannelSlug,
    Wrapped<String>? appSlug,
    Wrapped<String>? version,
    Wrapped<String?>? buildNumber,
    Wrapped<String?>? notes,
  }) {
    return ApiV1ArtifactsUploadUrlPost$RequestBody(
      platform: (platform != null ? platform.value : this.platform),
      arch: (arch != null ? arch.value : this.arch),
      packageType: (packageType != null ? packageType.value : this.packageType),
      fileName: (fileName != null ? fileName.value : this.fileName),
      sizeBytes: (sizeBytes != null ? sizeBytes.value : this.sizeBytes),
      sha256: (sha256 != null ? sha256.value : this.sha256),
      assignChannelSlug: (assignChannelSlug != null
          ? assignChannelSlug.value
          : this.assignChannelSlug),
      appSlug: (appSlug != null ? appSlug.value : this.appSlug),
      version: (version != null ? version.value : this.version),
      buildNumber: (buildNumber != null ? buildNumber.value : this.buildNumber),
      notes: (notes != null ? notes.value : this.notes),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBody {
  const ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBody({
    required this.platform,
    this.arch,
    required this.packageType,
    required this.fileName,
    this.sizeBytes,
    this.sha256,
    this.assignChannelSlug,
  });

  factory ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyFromJson(json);

  static const toJsonFactory =
      _$ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyToJson(this);

  @JsonKey(
    name: 'platform',
    includeIfNull: false,
    toJson:
        apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatformToJson,
    fromJson:
        apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatformFromJson,
  )
  final enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform
  platform;
  @JsonKey(
    name: 'arch',
    includeIfNull: false,
    toJson:
        apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArchNullableToJson,
    fromJson:
        apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArchNullableFromJson,
  )
  final enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch?
  arch;
  @JsonKey(name: 'packageType', includeIfNull: false)
  final String packageType;
  @JsonKey(name: 'fileName', includeIfNull: false)
  final String fileName;
  @JsonKey(name: 'sizeBytes', includeIfNull: false)
  final int? sizeBytes;
  @JsonKey(name: 'sha256', includeIfNull: false)
  final String? sha256;
  @JsonKey(name: 'assignChannelSlug', includeIfNull: false)
  final String? assignChannelSlug;
  static const fromJsonFactory =
      _$ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBody &&
            (identical(other.platform, platform) ||
                const DeepCollectionEquality().equals(
                  other.platform,
                  platform,
                )) &&
            (identical(other.arch, arch) ||
                const DeepCollectionEquality().equals(other.arch, arch)) &&
            (identical(other.packageType, packageType) ||
                const DeepCollectionEquality().equals(
                  other.packageType,
                  packageType,
                )) &&
            (identical(other.fileName, fileName) ||
                const DeepCollectionEquality().equals(
                  other.fileName,
                  fileName,
                )) &&
            (identical(other.sizeBytes, sizeBytes) ||
                const DeepCollectionEquality().equals(
                  other.sizeBytes,
                  sizeBytes,
                )) &&
            (identical(other.sha256, sha256) ||
                const DeepCollectionEquality().equals(other.sha256, sha256)) &&
            (identical(other.assignChannelSlug, assignChannelSlug) ||
                const DeepCollectionEquality().equals(
                  other.assignChannelSlug,
                  assignChannelSlug,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(platform) ^
      const DeepCollectionEquality().hash(arch) ^
      const DeepCollectionEquality().hash(packageType) ^
      const DeepCollectionEquality().hash(fileName) ^
      const DeepCollectionEquality().hash(sizeBytes) ^
      const DeepCollectionEquality().hash(sha256) ^
      const DeepCollectionEquality().hash(assignChannelSlug) ^
      runtimeType.hashCode;
}

extension $ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyExtension
    on ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBody {
  ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBody copyWith({
    enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform?
    platform,
    enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch? arch,
    String? packageType,
    String? fileName,
    int? sizeBytes,
    String? sha256,
    String? assignChannelSlug,
  }) {
    return ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBody(
      platform: platform ?? this.platform,
      arch: arch ?? this.arch,
      packageType: packageType ?? this.packageType,
      fileName: fileName ?? this.fileName,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      sha256: sha256 ?? this.sha256,
      assignChannelSlug: assignChannelSlug ?? this.assignChannelSlug,
    );
  }

  ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBody copyWithWrapped({
    Wrapped<
      enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform
    >?
    platform,
    Wrapped<
      enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch?
    >?
    arch,
    Wrapped<String>? packageType,
    Wrapped<String>? fileName,
    Wrapped<int?>? sizeBytes,
    Wrapped<String?>? sha256,
    Wrapped<String?>? assignChannelSlug,
  }) {
    return ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBody(
      platform: (platform != null ? platform.value : this.platform),
      arch: (arch != null ? arch.value : this.arch),
      packageType: (packageType != null ? packageType.value : this.packageType),
      fileName: (fileName != null ? fileName.value : this.fileName),
      sizeBytes: (sizeBytes != null ? sizeBytes.value : this.sizeBytes),
      sha256: (sha256 != null ? sha256.value : this.sha256),
      assignChannelSlug: (assignChannelSlug != null
          ? assignChannelSlug.value
          : this.assignChannelSlug),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiHealthzGet$Response {
  const ApiHealthzGet$Response({
    required this.service,
    required this.version,
    required this.status,
    required this.now,
  });

  factory ApiHealthzGet$Response.fromJson(Map<String, dynamic> json) =>
      _$ApiHealthzGet$ResponseFromJson(json);

  static const toJsonFactory = _$ApiHealthzGet$ResponseToJson;
  Map<String, dynamic> toJson() => _$ApiHealthzGet$ResponseToJson(this);

  @JsonKey(name: 'service', includeIfNull: false)
  final String service;
  @JsonKey(name: 'version', includeIfNull: false)
  final String version;
  @JsonKey(name: 'status', includeIfNull: false)
  final String status;
  @JsonKey(name: 'now', includeIfNull: false)
  final String now;
  static const fromJsonFactory = _$ApiHealthzGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiHealthzGet$Response &&
            (identical(other.service, service) ||
                const DeepCollectionEquality().equals(
                  other.service,
                  service,
                )) &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(
                  other.version,
                  version,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.now, now) ||
                const DeepCollectionEquality().equals(other.now, now)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(service) ^
      const DeepCollectionEquality().hash(version) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(now) ^
      runtimeType.hashCode;
}

extension $ApiHealthzGet$ResponseExtension on ApiHealthzGet$Response {
  ApiHealthzGet$Response copyWith({
    String? service,
    String? version,
    String? status,
    String? now,
  }) {
    return ApiHealthzGet$Response(
      service: service ?? this.service,
      version: version ?? this.version,
      status: status ?? this.status,
      now: now ?? this.now,
    );
  }

  ApiHealthzGet$Response copyWithWrapped({
    Wrapped<String>? service,
    Wrapped<String>? version,
    Wrapped<String>? status,
    Wrapped<String>? now,
  }) {
    return ApiHealthzGet$Response(
      service: (service != null ? service.value : this.service),
      version: (version != null ? version.value : this.version),
      status: (status != null ? status.value : this.status),
      now: (now != null ? now.value : this.now),
    );
  }
}

typedef ApiV1ApiKeysGet$Response = List<ApiV1ApiKeysGet$Response$Item>;

@JsonSerializable(explicitToJson: true)
class ApiV1ApiKeysGet$Response$Item {
  const ApiV1ApiKeysGet$Response$Item({
    required this.id,
    required this.name,
    required this.tokenId,
    required this.keyPrefix,
    required this.createdByUserId,
    required this.createdAt,
    required this.lastUsedAt,
    required this.revokedAt,
    required this.revokedByUserId,
  });

  factory ApiV1ApiKeysGet$Response$Item.fromJson(Map<String, dynamic> json) =>
      _$ApiV1ApiKeysGet$Response$ItemFromJson(json);

  static const toJsonFactory = _$ApiV1ApiKeysGet$Response$ItemToJson;
  Map<String, dynamic> toJson() => _$ApiV1ApiKeysGet$Response$ItemToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'tokenId', includeIfNull: false)
  final String tokenId;
  @JsonKey(name: 'keyPrefix', includeIfNull: false)
  final String keyPrefix;
  @JsonKey(name: 'createdByUserId', includeIfNull: false)
  final String? createdByUserId;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  @JsonKey(name: 'lastUsedAt', includeIfNull: false)
  final String? lastUsedAt;
  @JsonKey(name: 'revokedAt', includeIfNull: false)
  final String? revokedAt;
  @JsonKey(name: 'revokedByUserId', includeIfNull: false)
  final String? revokedByUserId;
  static const fromJsonFactory = _$ApiV1ApiKeysGet$Response$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ApiKeysGet$Response$Item &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.tokenId, tokenId) ||
                const DeepCollectionEquality().equals(
                  other.tokenId,
                  tokenId,
                )) &&
            (identical(other.keyPrefix, keyPrefix) ||
                const DeepCollectionEquality().equals(
                  other.keyPrefix,
                  keyPrefix,
                )) &&
            (identical(other.createdByUserId, createdByUserId) ||
                const DeepCollectionEquality().equals(
                  other.createdByUserId,
                  createdByUserId,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.lastUsedAt, lastUsedAt) ||
                const DeepCollectionEquality().equals(
                  other.lastUsedAt,
                  lastUsedAt,
                )) &&
            (identical(other.revokedAt, revokedAt) ||
                const DeepCollectionEquality().equals(
                  other.revokedAt,
                  revokedAt,
                )) &&
            (identical(other.revokedByUserId, revokedByUserId) ||
                const DeepCollectionEquality().equals(
                  other.revokedByUserId,
                  revokedByUserId,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(tokenId) ^
      const DeepCollectionEquality().hash(keyPrefix) ^
      const DeepCollectionEquality().hash(createdByUserId) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(lastUsedAt) ^
      const DeepCollectionEquality().hash(revokedAt) ^
      const DeepCollectionEquality().hash(revokedByUserId) ^
      runtimeType.hashCode;
}

extension $ApiV1ApiKeysGet$Response$ItemExtension
    on ApiV1ApiKeysGet$Response$Item {
  ApiV1ApiKeysGet$Response$Item copyWith({
    String? id,
    String? name,
    String? tokenId,
    String? keyPrefix,
    String? createdByUserId,
    String? createdAt,
    String? lastUsedAt,
    String? revokedAt,
    String? revokedByUserId,
  }) {
    return ApiV1ApiKeysGet$Response$Item(
      id: id ?? this.id,
      name: name ?? this.name,
      tokenId: tokenId ?? this.tokenId,
      keyPrefix: keyPrefix ?? this.keyPrefix,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      revokedAt: revokedAt ?? this.revokedAt,
      revokedByUserId: revokedByUserId ?? this.revokedByUserId,
    );
  }

  ApiV1ApiKeysGet$Response$Item copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? name,
    Wrapped<String>? tokenId,
    Wrapped<String>? keyPrefix,
    Wrapped<String?>? createdByUserId,
    Wrapped<String>? createdAt,
    Wrapped<String?>? lastUsedAt,
    Wrapped<String?>? revokedAt,
    Wrapped<String?>? revokedByUserId,
  }) {
    return ApiV1ApiKeysGet$Response$Item(
      id: (id != null ? id.value : this.id),
      name: (name != null ? name.value : this.name),
      tokenId: (tokenId != null ? tokenId.value : this.tokenId),
      keyPrefix: (keyPrefix != null ? keyPrefix.value : this.keyPrefix),
      createdByUserId: (createdByUserId != null
          ? createdByUserId.value
          : this.createdByUserId),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      lastUsedAt: (lastUsedAt != null ? lastUsedAt.value : this.lastUsedAt),
      revokedAt: (revokedAt != null ? revokedAt.value : this.revokedAt),
      revokedByUserId: (revokedByUserId != null
          ? revokedByUserId.value
          : this.revokedByUserId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ApiKeysPost$Response {
  const ApiV1ApiKeysPost$Response({
    required this.apiKey,
    required this.plainTextKey,
  });

  factory ApiV1ApiKeysPost$Response.fromJson(Map<String, dynamic> json) =>
      _$ApiV1ApiKeysPost$ResponseFromJson(json);

  static const toJsonFactory = _$ApiV1ApiKeysPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$ApiV1ApiKeysPost$ResponseToJson(this);

  @JsonKey(name: 'apiKey', includeIfNull: false)
  final ApiV1ApiKeysPost$Response$ApiKey apiKey;
  @JsonKey(name: 'plainTextKey', includeIfNull: false)
  final String plainTextKey;
  static const fromJsonFactory = _$ApiV1ApiKeysPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ApiKeysPost$Response &&
            (identical(other.apiKey, apiKey) ||
                const DeepCollectionEquality().equals(other.apiKey, apiKey)) &&
            (identical(other.plainTextKey, plainTextKey) ||
                const DeepCollectionEquality().equals(
                  other.plainTextKey,
                  plainTextKey,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(apiKey) ^
      const DeepCollectionEquality().hash(plainTextKey) ^
      runtimeType.hashCode;
}

extension $ApiV1ApiKeysPost$ResponseExtension on ApiV1ApiKeysPost$Response {
  ApiV1ApiKeysPost$Response copyWith({
    ApiV1ApiKeysPost$Response$ApiKey? apiKey,
    String? plainTextKey,
  }) {
    return ApiV1ApiKeysPost$Response(
      apiKey: apiKey ?? this.apiKey,
      plainTextKey: plainTextKey ?? this.plainTextKey,
    );
  }

  ApiV1ApiKeysPost$Response copyWithWrapped({
    Wrapped<ApiV1ApiKeysPost$Response$ApiKey>? apiKey,
    Wrapped<String>? plainTextKey,
  }) {
    return ApiV1ApiKeysPost$Response(
      apiKey: (apiKey != null ? apiKey.value : this.apiKey),
      plainTextKey: (plainTextKey != null
          ? plainTextKey.value
          : this.plainTextKey),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ApiKeysApiKeyIdRevokePost$Response {
  const ApiV1ApiKeysApiKeyIdRevokePost$Response({
    required this.id,
    required this.name,
    required this.tokenId,
    required this.keyPrefix,
    required this.createdByUserId,
    required this.createdAt,
    required this.lastUsedAt,
    required this.revokedAt,
    required this.revokedByUserId,
  });

  factory ApiV1ApiKeysApiKeyIdRevokePost$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1ApiKeysApiKeyIdRevokePost$ResponseFromJson(json);

  static const toJsonFactory = _$ApiV1ApiKeysApiKeyIdRevokePost$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1ApiKeysApiKeyIdRevokePost$ResponseToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'tokenId', includeIfNull: false)
  final String tokenId;
  @JsonKey(name: 'keyPrefix', includeIfNull: false)
  final String keyPrefix;
  @JsonKey(name: 'createdByUserId', includeIfNull: false)
  final String? createdByUserId;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  @JsonKey(name: 'lastUsedAt', includeIfNull: false)
  final String? lastUsedAt;
  @JsonKey(name: 'revokedAt', includeIfNull: false)
  final String? revokedAt;
  @JsonKey(name: 'revokedByUserId', includeIfNull: false)
  final String? revokedByUserId;
  static const fromJsonFactory =
      _$ApiV1ApiKeysApiKeyIdRevokePost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ApiKeysApiKeyIdRevokePost$Response &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.tokenId, tokenId) ||
                const DeepCollectionEquality().equals(
                  other.tokenId,
                  tokenId,
                )) &&
            (identical(other.keyPrefix, keyPrefix) ||
                const DeepCollectionEquality().equals(
                  other.keyPrefix,
                  keyPrefix,
                )) &&
            (identical(other.createdByUserId, createdByUserId) ||
                const DeepCollectionEquality().equals(
                  other.createdByUserId,
                  createdByUserId,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.lastUsedAt, lastUsedAt) ||
                const DeepCollectionEquality().equals(
                  other.lastUsedAt,
                  lastUsedAt,
                )) &&
            (identical(other.revokedAt, revokedAt) ||
                const DeepCollectionEquality().equals(
                  other.revokedAt,
                  revokedAt,
                )) &&
            (identical(other.revokedByUserId, revokedByUserId) ||
                const DeepCollectionEquality().equals(
                  other.revokedByUserId,
                  revokedByUserId,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(tokenId) ^
      const DeepCollectionEquality().hash(keyPrefix) ^
      const DeepCollectionEquality().hash(createdByUserId) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(lastUsedAt) ^
      const DeepCollectionEquality().hash(revokedAt) ^
      const DeepCollectionEquality().hash(revokedByUserId) ^
      runtimeType.hashCode;
}

extension $ApiV1ApiKeysApiKeyIdRevokePost$ResponseExtension
    on ApiV1ApiKeysApiKeyIdRevokePost$Response {
  ApiV1ApiKeysApiKeyIdRevokePost$Response copyWith({
    String? id,
    String? name,
    String? tokenId,
    String? keyPrefix,
    String? createdByUserId,
    String? createdAt,
    String? lastUsedAt,
    String? revokedAt,
    String? revokedByUserId,
  }) {
    return ApiV1ApiKeysApiKeyIdRevokePost$Response(
      id: id ?? this.id,
      name: name ?? this.name,
      tokenId: tokenId ?? this.tokenId,
      keyPrefix: keyPrefix ?? this.keyPrefix,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      revokedAt: revokedAt ?? this.revokedAt,
      revokedByUserId: revokedByUserId ?? this.revokedByUserId,
    );
  }

  ApiV1ApiKeysApiKeyIdRevokePost$Response copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? name,
    Wrapped<String>? tokenId,
    Wrapped<String>? keyPrefix,
    Wrapped<String?>? createdByUserId,
    Wrapped<String>? createdAt,
    Wrapped<String?>? lastUsedAt,
    Wrapped<String?>? revokedAt,
    Wrapped<String?>? revokedByUserId,
  }) {
    return ApiV1ApiKeysApiKeyIdRevokePost$Response(
      id: (id != null ? id.value : this.id),
      name: (name != null ? name.value : this.name),
      tokenId: (tokenId != null ? tokenId.value : this.tokenId),
      keyPrefix: (keyPrefix != null ? keyPrefix.value : this.keyPrefix),
      createdByUserId: (createdByUserId != null
          ? createdByUserId.value
          : this.createdByUserId),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      lastUsedAt: (lastUsedAt != null ? lastUsedAt.value : this.lastUsedAt),
      revokedAt: (revokedAt != null ? revokedAt.value : this.revokedAt),
      revokedByUserId: (revokedByUserId != null
          ? revokedByUserId.value
          : this.revokedByUserId),
    );
  }
}

typedef ApiV1AppsGet$Response = List<ApiV1AppsGet$Response$Item>;

@JsonSerializable(explicitToJson: true)
class ApiV1AppsGet$Response$Item {
  const ApiV1AppsGet$Response$Item({
    required this.id,
    required this.slug,
    required this.name,
    required this.bundleId,
    required this.createdAt,
  });

  factory ApiV1AppsGet$Response$Item.fromJson(Map<String, dynamic> json) =>
      _$ApiV1AppsGet$Response$ItemFromJson(json);

  static const toJsonFactory = _$ApiV1AppsGet$Response$ItemToJson;
  Map<String, dynamic> toJson() => _$ApiV1AppsGet$Response$ItemToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'slug', includeIfNull: false)
  final String slug;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'bundleId', includeIfNull: false)
  final String? bundleId;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  static const fromJsonFactory = _$ApiV1AppsGet$Response$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1AppsGet$Response$Item &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.slug, slug) ||
                const DeepCollectionEquality().equals(other.slug, slug)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.bundleId, bundleId) ||
                const DeepCollectionEquality().equals(
                  other.bundleId,
                  bundleId,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(slug) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(bundleId) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $ApiV1AppsGet$Response$ItemExtension on ApiV1AppsGet$Response$Item {
  ApiV1AppsGet$Response$Item copyWith({
    String? id,
    String? slug,
    String? name,
    String? bundleId,
    String? createdAt,
  }) {
    return ApiV1AppsGet$Response$Item(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      bundleId: bundleId ?? this.bundleId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  ApiV1AppsGet$Response$Item copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? slug,
    Wrapped<String>? name,
    Wrapped<String?>? bundleId,
    Wrapped<String>? createdAt,
  }) {
    return ApiV1AppsGet$Response$Item(
      id: (id != null ? id.value : this.id),
      slug: (slug != null ? slug.value : this.slug),
      name: (name != null ? name.value : this.name),
      bundleId: (bundleId != null ? bundleId.value : this.bundleId),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1AppsPost$Response {
  const ApiV1AppsPost$Response({
    required this.id,
    required this.slug,
    required this.name,
    required this.bundleId,
    required this.createdAt,
  });

  factory ApiV1AppsPost$Response.fromJson(Map<String, dynamic> json) =>
      _$ApiV1AppsPost$ResponseFromJson(json);

  static const toJsonFactory = _$ApiV1AppsPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$ApiV1AppsPost$ResponseToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'slug', includeIfNull: false)
  final String slug;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'bundleId', includeIfNull: false)
  final String? bundleId;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  static const fromJsonFactory = _$ApiV1AppsPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1AppsPost$Response &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.slug, slug) ||
                const DeepCollectionEquality().equals(other.slug, slug)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.bundleId, bundleId) ||
                const DeepCollectionEquality().equals(
                  other.bundleId,
                  bundleId,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(slug) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(bundleId) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $ApiV1AppsPost$ResponseExtension on ApiV1AppsPost$Response {
  ApiV1AppsPost$Response copyWith({
    String? id,
    String? slug,
    String? name,
    String? bundleId,
    String? createdAt,
  }) {
    return ApiV1AppsPost$Response(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      bundleId: bundleId ?? this.bundleId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  ApiV1AppsPost$Response copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? slug,
    Wrapped<String>? name,
    Wrapped<String?>? bundleId,
    Wrapped<String>? createdAt,
  }) {
    return ApiV1AppsPost$Response(
      id: (id != null ? id.value : this.id),
      slug: (slug != null ? slug.value : this.slug),
      name: (name != null ? name.value : this.name),
      bundleId: (bundleId != null ? bundleId.value : this.bundleId),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1AppsAppIdRepositoryConnectionGet$Response {
  const ApiV1AppsAppIdRepositoryConnectionGet$Response({
    required this.id,
    required this.appId,
    required this.provider,
    required this.owner,
    required this.repo,
    required this.installationId,
    required this.defaultBranch,
    required this.workflowFile,
    required this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiV1AppsAppIdRepositoryConnectionGet$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1AppsAppIdRepositoryConnectionGet$ResponseFromJson(json);

  static const toJsonFactory =
      _$ApiV1AppsAppIdRepositoryConnectionGet$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1AppsAppIdRepositoryConnectionGet$ResponseToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(
    name: 'provider',
    includeIfNull: false,
    toJson: apiV1AppsAppIdRepositoryConnectionGet$ResponseProviderToJson,
    fromJson: apiV1AppsAppIdRepositoryConnectionGet$ResponseProviderFromJson,
  )
  final enums.ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider provider;
  @JsonKey(name: 'owner', includeIfNull: false)
  final String owner;
  @JsonKey(name: 'repo', includeIfNull: false)
  final String repo;
  @JsonKey(name: 'installationId', includeIfNull: false)
  final String? installationId;
  @JsonKey(name: 'defaultBranch', includeIfNull: false)
  final String defaultBranch;
  @JsonKey(name: 'workflowFile', includeIfNull: false)
  final String? workflowFile;
  @JsonKey(name: 'createdByUserId', includeIfNull: false)
  final String? createdByUserId;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  final String updatedAt;
  static const fromJsonFactory =
      _$ApiV1AppsAppIdRepositoryConnectionGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1AppsAppIdRepositoryConnectionGet$Response &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.provider, provider) ||
                const DeepCollectionEquality().equals(
                  other.provider,
                  provider,
                )) &&
            (identical(other.owner, owner) ||
                const DeepCollectionEquality().equals(other.owner, owner)) &&
            (identical(other.repo, repo) ||
                const DeepCollectionEquality().equals(other.repo, repo)) &&
            (identical(other.installationId, installationId) ||
                const DeepCollectionEquality().equals(
                  other.installationId,
                  installationId,
                )) &&
            (identical(other.defaultBranch, defaultBranch) ||
                const DeepCollectionEquality().equals(
                  other.defaultBranch,
                  defaultBranch,
                )) &&
            (identical(other.workflowFile, workflowFile) ||
                const DeepCollectionEquality().equals(
                  other.workflowFile,
                  workflowFile,
                )) &&
            (identical(other.createdByUserId, createdByUserId) ||
                const DeepCollectionEquality().equals(
                  other.createdByUserId,
                  createdByUserId,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(provider) ^
      const DeepCollectionEquality().hash(owner) ^
      const DeepCollectionEquality().hash(repo) ^
      const DeepCollectionEquality().hash(installationId) ^
      const DeepCollectionEquality().hash(defaultBranch) ^
      const DeepCollectionEquality().hash(workflowFile) ^
      const DeepCollectionEquality().hash(createdByUserId) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $ApiV1AppsAppIdRepositoryConnectionGet$ResponseExtension
    on ApiV1AppsAppIdRepositoryConnectionGet$Response {
  ApiV1AppsAppIdRepositoryConnectionGet$Response copyWith({
    String? id,
    String? appId,
    enums.ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider? provider,
    String? owner,
    String? repo,
    String? installationId,
    String? defaultBranch,
    String? workflowFile,
    String? createdByUserId,
    String? createdAt,
    String? updatedAt,
  }) {
    return ApiV1AppsAppIdRepositoryConnectionGet$Response(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      provider: provider ?? this.provider,
      owner: owner ?? this.owner,
      repo: repo ?? this.repo,
      installationId: installationId ?? this.installationId,
      defaultBranch: defaultBranch ?? this.defaultBranch,
      workflowFile: workflowFile ?? this.workflowFile,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  ApiV1AppsAppIdRepositoryConnectionGet$Response copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? appId,
    Wrapped<enums.ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider>?
    provider,
    Wrapped<String>? owner,
    Wrapped<String>? repo,
    Wrapped<String?>? installationId,
    Wrapped<String>? defaultBranch,
    Wrapped<String?>? workflowFile,
    Wrapped<String?>? createdByUserId,
    Wrapped<String>? createdAt,
    Wrapped<String>? updatedAt,
  }) {
    return ApiV1AppsAppIdRepositoryConnectionGet$Response(
      id: (id != null ? id.value : this.id),
      appId: (appId != null ? appId.value : this.appId),
      provider: (provider != null ? provider.value : this.provider),
      owner: (owner != null ? owner.value : this.owner),
      repo: (repo != null ? repo.value : this.repo),
      installationId: (installationId != null
          ? installationId.value
          : this.installationId),
      defaultBranch: (defaultBranch != null
          ? defaultBranch.value
          : this.defaultBranch),
      workflowFile: (workflowFile != null
          ? workflowFile.value
          : this.workflowFile),
      createdByUserId: (createdByUserId != null
          ? createdByUserId.value
          : this.createdByUserId),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1AppsAppIdRepositoryConnectionPut$Response {
  const ApiV1AppsAppIdRepositoryConnectionPut$Response({
    required this.id,
    required this.appId,
    required this.provider,
    required this.owner,
    required this.repo,
    required this.installationId,
    required this.defaultBranch,
    required this.workflowFile,
    required this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiV1AppsAppIdRepositoryConnectionPut$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1AppsAppIdRepositoryConnectionPut$ResponseFromJson(json);

  static const toJsonFactory =
      _$ApiV1AppsAppIdRepositoryConnectionPut$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1AppsAppIdRepositoryConnectionPut$ResponseToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(
    name: 'provider',
    includeIfNull: false,
    toJson: apiV1AppsAppIdRepositoryConnectionPut$ResponseProviderToJson,
    fromJson: apiV1AppsAppIdRepositoryConnectionPut$ResponseProviderFromJson,
  )
  final enums.ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider provider;
  @JsonKey(name: 'owner', includeIfNull: false)
  final String owner;
  @JsonKey(name: 'repo', includeIfNull: false)
  final String repo;
  @JsonKey(name: 'installationId', includeIfNull: false)
  final String? installationId;
  @JsonKey(name: 'defaultBranch', includeIfNull: false)
  final String defaultBranch;
  @JsonKey(name: 'workflowFile', includeIfNull: false)
  final String? workflowFile;
  @JsonKey(name: 'createdByUserId', includeIfNull: false)
  final String? createdByUserId;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  final String updatedAt;
  static const fromJsonFactory =
      _$ApiV1AppsAppIdRepositoryConnectionPut$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1AppsAppIdRepositoryConnectionPut$Response &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.provider, provider) ||
                const DeepCollectionEquality().equals(
                  other.provider,
                  provider,
                )) &&
            (identical(other.owner, owner) ||
                const DeepCollectionEquality().equals(other.owner, owner)) &&
            (identical(other.repo, repo) ||
                const DeepCollectionEquality().equals(other.repo, repo)) &&
            (identical(other.installationId, installationId) ||
                const DeepCollectionEquality().equals(
                  other.installationId,
                  installationId,
                )) &&
            (identical(other.defaultBranch, defaultBranch) ||
                const DeepCollectionEquality().equals(
                  other.defaultBranch,
                  defaultBranch,
                )) &&
            (identical(other.workflowFile, workflowFile) ||
                const DeepCollectionEquality().equals(
                  other.workflowFile,
                  workflowFile,
                )) &&
            (identical(other.createdByUserId, createdByUserId) ||
                const DeepCollectionEquality().equals(
                  other.createdByUserId,
                  createdByUserId,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(provider) ^
      const DeepCollectionEquality().hash(owner) ^
      const DeepCollectionEquality().hash(repo) ^
      const DeepCollectionEquality().hash(installationId) ^
      const DeepCollectionEquality().hash(defaultBranch) ^
      const DeepCollectionEquality().hash(workflowFile) ^
      const DeepCollectionEquality().hash(createdByUserId) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $ApiV1AppsAppIdRepositoryConnectionPut$ResponseExtension
    on ApiV1AppsAppIdRepositoryConnectionPut$Response {
  ApiV1AppsAppIdRepositoryConnectionPut$Response copyWith({
    String? id,
    String? appId,
    enums.ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider? provider,
    String? owner,
    String? repo,
    String? installationId,
    String? defaultBranch,
    String? workflowFile,
    String? createdByUserId,
    String? createdAt,
    String? updatedAt,
  }) {
    return ApiV1AppsAppIdRepositoryConnectionPut$Response(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      provider: provider ?? this.provider,
      owner: owner ?? this.owner,
      repo: repo ?? this.repo,
      installationId: installationId ?? this.installationId,
      defaultBranch: defaultBranch ?? this.defaultBranch,
      workflowFile: workflowFile ?? this.workflowFile,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  ApiV1AppsAppIdRepositoryConnectionPut$Response copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? appId,
    Wrapped<enums.ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider>?
    provider,
    Wrapped<String>? owner,
    Wrapped<String>? repo,
    Wrapped<String?>? installationId,
    Wrapped<String>? defaultBranch,
    Wrapped<String?>? workflowFile,
    Wrapped<String?>? createdByUserId,
    Wrapped<String>? createdAt,
    Wrapped<String>? updatedAt,
  }) {
    return ApiV1AppsAppIdRepositoryConnectionPut$Response(
      id: (id != null ? id.value : this.id),
      appId: (appId != null ? appId.value : this.appId),
      provider: (provider != null ? provider.value : this.provider),
      owner: (owner != null ? owner.value : this.owner),
      repo: (repo != null ? repo.value : this.repo),
      installationId: (installationId != null
          ? installationId.value
          : this.installationId),
      defaultBranch: (defaultBranch != null
          ? defaultBranch.value
          : this.defaultBranch),
      workflowFile: (workflowFile != null
          ? workflowFile.value
          : this.workflowFile),
      createdByUserId: (createdByUserId != null
          ? createdByUserId.value
          : this.createdByUserId),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

typedef ApiV1AppsAppIdDeploymentTargetsGet$Response =
    List<ApiV1AppsAppIdDeploymentTargetsGet$Response$Item>;

@JsonSerializable(explicitToJson: true)
class ApiV1AppsAppIdDeploymentTargetsGet$Response$Item {
  const ApiV1AppsAppIdDeploymentTargetsGet$Response$Item({
    required this.id,
    required this.appId,
    required this.kind,
    required this.name,
    required this.config,
    required this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
    required this.disabledAt,
  });

  factory ApiV1AppsAppIdDeploymentTargetsGet$Response$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemFromJson(json);

  static const toJsonFactory =
      _$ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(
    name: 'kind',
    includeIfNull: false,
    toJson: apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKindToJson,
    fromJson: apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKindFromJson,
  )
  final enums.ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind kind;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'config', includeIfNull: false)
  final Map<String, dynamic> config;
  @JsonKey(name: 'createdByUserId', includeIfNull: false)
  final String? createdByUserId;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  final String updatedAt;
  @JsonKey(name: 'disabledAt', includeIfNull: false)
  final String? disabledAt;
  static const fromJsonFactory =
      _$ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1AppsAppIdDeploymentTargetsGet$Response$Item &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.kind, kind) ||
                const DeepCollectionEquality().equals(other.kind, kind)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.config, config) ||
                const DeepCollectionEquality().equals(other.config, config)) &&
            (identical(other.createdByUserId, createdByUserId) ||
                const DeepCollectionEquality().equals(
                  other.createdByUserId,
                  createdByUserId,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )) &&
            (identical(other.disabledAt, disabledAt) ||
                const DeepCollectionEquality().equals(
                  other.disabledAt,
                  disabledAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(kind) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(config) ^
      const DeepCollectionEquality().hash(createdByUserId) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      const DeepCollectionEquality().hash(disabledAt) ^
      runtimeType.hashCode;
}

extension $ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemExtension
    on ApiV1AppsAppIdDeploymentTargetsGet$Response$Item {
  ApiV1AppsAppIdDeploymentTargetsGet$Response$Item copyWith({
    String? id,
    String? appId,
    enums.ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind? kind,
    String? name,
    Map<String, dynamic>? config,
    String? createdByUserId,
    String? createdAt,
    String? updatedAt,
    String? disabledAt,
  }) {
    return ApiV1AppsAppIdDeploymentTargetsGet$Response$Item(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      config: config ?? this.config,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      disabledAt: disabledAt ?? this.disabledAt,
    );
  }

  ApiV1AppsAppIdDeploymentTargetsGet$Response$Item copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? appId,
    Wrapped<enums.ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind>? kind,
    Wrapped<String>? name,
    Wrapped<Map<String, dynamic>>? config,
    Wrapped<String?>? createdByUserId,
    Wrapped<String>? createdAt,
    Wrapped<String>? updatedAt,
    Wrapped<String?>? disabledAt,
  }) {
    return ApiV1AppsAppIdDeploymentTargetsGet$Response$Item(
      id: (id != null ? id.value : this.id),
      appId: (appId != null ? appId.value : this.appId),
      kind: (kind != null ? kind.value : this.kind),
      name: (name != null ? name.value : this.name),
      config: (config != null ? config.value : this.config),
      createdByUserId: (createdByUserId != null
          ? createdByUserId.value
          : this.createdByUserId),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
      disabledAt: (disabledAt != null ? disabledAt.value : this.disabledAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1AppsAppIdDeploymentTargetsPost$Response {
  const ApiV1AppsAppIdDeploymentTargetsPost$Response({
    required this.id,
    required this.appId,
    required this.kind,
    required this.name,
    required this.config,
    required this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
    required this.disabledAt,
  });

  factory ApiV1AppsAppIdDeploymentTargetsPost$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1AppsAppIdDeploymentTargetsPost$ResponseFromJson(json);

  static const toJsonFactory =
      _$ApiV1AppsAppIdDeploymentTargetsPost$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1AppsAppIdDeploymentTargetsPost$ResponseToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(
    name: 'kind',
    includeIfNull: false,
    toJson: apiV1AppsAppIdDeploymentTargetsPost$ResponseKindToJson,
    fromJson: apiV1AppsAppIdDeploymentTargetsPost$ResponseKindFromJson,
  )
  final enums.ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind kind;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'config', includeIfNull: false)
  final Map<String, dynamic> config;
  @JsonKey(name: 'createdByUserId', includeIfNull: false)
  final String? createdByUserId;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  final String updatedAt;
  @JsonKey(name: 'disabledAt', includeIfNull: false)
  final String? disabledAt;
  static const fromJsonFactory =
      _$ApiV1AppsAppIdDeploymentTargetsPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1AppsAppIdDeploymentTargetsPost$Response &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.kind, kind) ||
                const DeepCollectionEquality().equals(other.kind, kind)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.config, config) ||
                const DeepCollectionEquality().equals(other.config, config)) &&
            (identical(other.createdByUserId, createdByUserId) ||
                const DeepCollectionEquality().equals(
                  other.createdByUserId,
                  createdByUserId,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )) &&
            (identical(other.disabledAt, disabledAt) ||
                const DeepCollectionEquality().equals(
                  other.disabledAt,
                  disabledAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(kind) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(config) ^
      const DeepCollectionEquality().hash(createdByUserId) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      const DeepCollectionEquality().hash(disabledAt) ^
      runtimeType.hashCode;
}

extension $ApiV1AppsAppIdDeploymentTargetsPost$ResponseExtension
    on ApiV1AppsAppIdDeploymentTargetsPost$Response {
  ApiV1AppsAppIdDeploymentTargetsPost$Response copyWith({
    String? id,
    String? appId,
    enums.ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind? kind,
    String? name,
    Map<String, dynamic>? config,
    String? createdByUserId,
    String? createdAt,
    String? updatedAt,
    String? disabledAt,
  }) {
    return ApiV1AppsAppIdDeploymentTargetsPost$Response(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      config: config ?? this.config,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      disabledAt: disabledAt ?? this.disabledAt,
    );
  }

  ApiV1AppsAppIdDeploymentTargetsPost$Response copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? appId,
    Wrapped<enums.ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind>? kind,
    Wrapped<String>? name,
    Wrapped<Map<String, dynamic>>? config,
    Wrapped<String?>? createdByUserId,
    Wrapped<String>? createdAt,
    Wrapped<String>? updatedAt,
    Wrapped<String?>? disabledAt,
  }) {
    return ApiV1AppsAppIdDeploymentTargetsPost$Response(
      id: (id != null ? id.value : this.id),
      appId: (appId != null ? appId.value : this.appId),
      kind: (kind != null ? kind.value : this.kind),
      name: (name != null ? name.value : this.name),
      config: (config != null ? config.value : this.config),
      createdByUserId: (createdByUserId != null
          ? createdByUserId.value
          : this.createdByUserId),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
      disabledAt: (disabledAt != null ? disabledAt.value : this.disabledAt),
    );
  }
}

typedef ApiV1AppsAppIdBuildProfilesGet$Response =
    List<ApiV1AppsAppIdBuildProfilesGet$Response$Item>;

@JsonSerializable(explicitToJson: true)
class ApiV1AppsAppIdBuildProfilesGet$Response$Item {
  const ApiV1AppsAppIdBuildProfilesGet$Response$Item({
    required this.id,
    required this.appId,
    required this.name,
    required this.platform,
    required this.packageType,
    this.arch,
    required this.workflowIdentifier,
    required this.workflowRef,
    required this.workflowInputs,
    required this.artifactPathGlob,
    required this.autoDeployTargetId,
    required this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
    required this.disabledAt,
  });

  factory ApiV1AppsAppIdBuildProfilesGet$Response$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1AppsAppIdBuildProfilesGet$Response$ItemFromJson(json);

  static const toJsonFactory =
      _$ApiV1AppsAppIdBuildProfilesGet$Response$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1AppsAppIdBuildProfilesGet$Response$ItemToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(
    name: 'platform',
    includeIfNull: false,
    toJson: apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatformToJson,
    fromJson: apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatformFromJson,
  )
  final enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform platform;
  @JsonKey(name: 'packageType', includeIfNull: false)
  final String packageType;
  @JsonKey(
    name: 'arch',
    includeIfNull: false,
    toJson: apiV1AppsAppIdBuildProfilesGet$Response$ItemArchNullableToJson,
    fromJson: apiV1AppsAppIdBuildProfilesGet$Response$ItemArchNullableFromJson,
  )
  final enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch? arch;
  @JsonKey(name: 'workflowIdentifier', includeIfNull: false)
  final String workflowIdentifier;
  @JsonKey(name: 'workflowRef', includeIfNull: false)
  final String? workflowRef;
  @JsonKey(name: 'workflowInputs', includeIfNull: false)
  final Map<String, dynamic> workflowInputs;
  @JsonKey(name: 'artifactPathGlob', includeIfNull: false)
  final String? artifactPathGlob;
  @JsonKey(name: 'autoDeployTargetId', includeIfNull: false)
  final String? autoDeployTargetId;
  @JsonKey(name: 'createdByUserId', includeIfNull: false)
  final String? createdByUserId;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  final String updatedAt;
  @JsonKey(name: 'disabledAt', includeIfNull: false)
  final String? disabledAt;
  static const fromJsonFactory =
      _$ApiV1AppsAppIdBuildProfilesGet$Response$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1AppsAppIdBuildProfilesGet$Response$Item &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.platform, platform) ||
                const DeepCollectionEquality().equals(
                  other.platform,
                  platform,
                )) &&
            (identical(other.packageType, packageType) ||
                const DeepCollectionEquality().equals(
                  other.packageType,
                  packageType,
                )) &&
            (identical(other.arch, arch) ||
                const DeepCollectionEquality().equals(other.arch, arch)) &&
            (identical(other.workflowIdentifier, workflowIdentifier) ||
                const DeepCollectionEquality().equals(
                  other.workflowIdentifier,
                  workflowIdentifier,
                )) &&
            (identical(other.workflowRef, workflowRef) ||
                const DeepCollectionEquality().equals(
                  other.workflowRef,
                  workflowRef,
                )) &&
            (identical(other.workflowInputs, workflowInputs) ||
                const DeepCollectionEquality().equals(
                  other.workflowInputs,
                  workflowInputs,
                )) &&
            (identical(other.artifactPathGlob, artifactPathGlob) ||
                const DeepCollectionEquality().equals(
                  other.artifactPathGlob,
                  artifactPathGlob,
                )) &&
            (identical(other.autoDeployTargetId, autoDeployTargetId) ||
                const DeepCollectionEquality().equals(
                  other.autoDeployTargetId,
                  autoDeployTargetId,
                )) &&
            (identical(other.createdByUserId, createdByUserId) ||
                const DeepCollectionEquality().equals(
                  other.createdByUserId,
                  createdByUserId,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )) &&
            (identical(other.disabledAt, disabledAt) ||
                const DeepCollectionEquality().equals(
                  other.disabledAt,
                  disabledAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(platform) ^
      const DeepCollectionEquality().hash(packageType) ^
      const DeepCollectionEquality().hash(arch) ^
      const DeepCollectionEquality().hash(workflowIdentifier) ^
      const DeepCollectionEquality().hash(workflowRef) ^
      const DeepCollectionEquality().hash(workflowInputs) ^
      const DeepCollectionEquality().hash(artifactPathGlob) ^
      const DeepCollectionEquality().hash(autoDeployTargetId) ^
      const DeepCollectionEquality().hash(createdByUserId) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      const DeepCollectionEquality().hash(disabledAt) ^
      runtimeType.hashCode;
}

extension $ApiV1AppsAppIdBuildProfilesGet$Response$ItemExtension
    on ApiV1AppsAppIdBuildProfilesGet$Response$Item {
  ApiV1AppsAppIdBuildProfilesGet$Response$Item copyWith({
    String? id,
    String? appId,
    String? name,
    enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform? platform,
    String? packageType,
    enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch? arch,
    String? workflowIdentifier,
    String? workflowRef,
    Map<String, dynamic>? workflowInputs,
    String? artifactPathGlob,
    String? autoDeployTargetId,
    String? createdByUserId,
    String? createdAt,
    String? updatedAt,
    String? disabledAt,
  }) {
    return ApiV1AppsAppIdBuildProfilesGet$Response$Item(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      packageType: packageType ?? this.packageType,
      arch: arch ?? this.arch,
      workflowIdentifier: workflowIdentifier ?? this.workflowIdentifier,
      workflowRef: workflowRef ?? this.workflowRef,
      workflowInputs: workflowInputs ?? this.workflowInputs,
      artifactPathGlob: artifactPathGlob ?? this.artifactPathGlob,
      autoDeployTargetId: autoDeployTargetId ?? this.autoDeployTargetId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      disabledAt: disabledAt ?? this.disabledAt,
    );
  }

  ApiV1AppsAppIdBuildProfilesGet$Response$Item copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? appId,
    Wrapped<String>? name,
    Wrapped<enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform>?
    platform,
    Wrapped<String>? packageType,
    Wrapped<enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch?>? arch,
    Wrapped<String>? workflowIdentifier,
    Wrapped<String?>? workflowRef,
    Wrapped<Map<String, dynamic>>? workflowInputs,
    Wrapped<String?>? artifactPathGlob,
    Wrapped<String?>? autoDeployTargetId,
    Wrapped<String?>? createdByUserId,
    Wrapped<String>? createdAt,
    Wrapped<String>? updatedAt,
    Wrapped<String?>? disabledAt,
  }) {
    return ApiV1AppsAppIdBuildProfilesGet$Response$Item(
      id: (id != null ? id.value : this.id),
      appId: (appId != null ? appId.value : this.appId),
      name: (name != null ? name.value : this.name),
      platform: (platform != null ? platform.value : this.platform),
      packageType: (packageType != null ? packageType.value : this.packageType),
      arch: (arch != null ? arch.value : this.arch),
      workflowIdentifier: (workflowIdentifier != null
          ? workflowIdentifier.value
          : this.workflowIdentifier),
      workflowRef: (workflowRef != null ? workflowRef.value : this.workflowRef),
      workflowInputs: (workflowInputs != null
          ? workflowInputs.value
          : this.workflowInputs),
      artifactPathGlob: (artifactPathGlob != null
          ? artifactPathGlob.value
          : this.artifactPathGlob),
      autoDeployTargetId: (autoDeployTargetId != null
          ? autoDeployTargetId.value
          : this.autoDeployTargetId),
      createdByUserId: (createdByUserId != null
          ? createdByUserId.value
          : this.createdByUserId),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
      disabledAt: (disabledAt != null ? disabledAt.value : this.disabledAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1AppsAppIdBuildProfilesPost$Response {
  const ApiV1AppsAppIdBuildProfilesPost$Response({
    required this.id,
    required this.appId,
    required this.name,
    required this.platform,
    required this.packageType,
    this.arch,
    required this.workflowIdentifier,
    required this.workflowRef,
    required this.workflowInputs,
    required this.artifactPathGlob,
    required this.autoDeployTargetId,
    required this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
    required this.disabledAt,
  });

  factory ApiV1AppsAppIdBuildProfilesPost$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1AppsAppIdBuildProfilesPost$ResponseFromJson(json);

  static const toJsonFactory = _$ApiV1AppsAppIdBuildProfilesPost$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1AppsAppIdBuildProfilesPost$ResponseToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(
    name: 'platform',
    includeIfNull: false,
    toJson: apiV1AppsAppIdBuildProfilesPost$ResponsePlatformToJson,
    fromJson: apiV1AppsAppIdBuildProfilesPost$ResponsePlatformFromJson,
  )
  final enums.ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform platform;
  @JsonKey(name: 'packageType', includeIfNull: false)
  final String packageType;
  @JsonKey(
    name: 'arch',
    includeIfNull: false,
    toJson: apiV1AppsAppIdBuildProfilesPost$ResponseArchNullableToJson,
    fromJson: apiV1AppsAppIdBuildProfilesPost$ResponseArchNullableFromJson,
  )
  final enums.ApiV1AppsAppIdBuildProfilesPost$ResponseArch? arch;
  @JsonKey(name: 'workflowIdentifier', includeIfNull: false)
  final String workflowIdentifier;
  @JsonKey(name: 'workflowRef', includeIfNull: false)
  final String? workflowRef;
  @JsonKey(name: 'workflowInputs', includeIfNull: false)
  final Map<String, dynamic> workflowInputs;
  @JsonKey(name: 'artifactPathGlob', includeIfNull: false)
  final String? artifactPathGlob;
  @JsonKey(name: 'autoDeployTargetId', includeIfNull: false)
  final String? autoDeployTargetId;
  @JsonKey(name: 'createdByUserId', includeIfNull: false)
  final String? createdByUserId;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  final String updatedAt;
  @JsonKey(name: 'disabledAt', includeIfNull: false)
  final String? disabledAt;
  static const fromJsonFactory =
      _$ApiV1AppsAppIdBuildProfilesPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1AppsAppIdBuildProfilesPost$Response &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.platform, platform) ||
                const DeepCollectionEquality().equals(
                  other.platform,
                  platform,
                )) &&
            (identical(other.packageType, packageType) ||
                const DeepCollectionEquality().equals(
                  other.packageType,
                  packageType,
                )) &&
            (identical(other.arch, arch) ||
                const DeepCollectionEquality().equals(other.arch, arch)) &&
            (identical(other.workflowIdentifier, workflowIdentifier) ||
                const DeepCollectionEquality().equals(
                  other.workflowIdentifier,
                  workflowIdentifier,
                )) &&
            (identical(other.workflowRef, workflowRef) ||
                const DeepCollectionEquality().equals(
                  other.workflowRef,
                  workflowRef,
                )) &&
            (identical(other.workflowInputs, workflowInputs) ||
                const DeepCollectionEquality().equals(
                  other.workflowInputs,
                  workflowInputs,
                )) &&
            (identical(other.artifactPathGlob, artifactPathGlob) ||
                const DeepCollectionEquality().equals(
                  other.artifactPathGlob,
                  artifactPathGlob,
                )) &&
            (identical(other.autoDeployTargetId, autoDeployTargetId) ||
                const DeepCollectionEquality().equals(
                  other.autoDeployTargetId,
                  autoDeployTargetId,
                )) &&
            (identical(other.createdByUserId, createdByUserId) ||
                const DeepCollectionEquality().equals(
                  other.createdByUserId,
                  createdByUserId,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )) &&
            (identical(other.disabledAt, disabledAt) ||
                const DeepCollectionEquality().equals(
                  other.disabledAt,
                  disabledAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(platform) ^
      const DeepCollectionEquality().hash(packageType) ^
      const DeepCollectionEquality().hash(arch) ^
      const DeepCollectionEquality().hash(workflowIdentifier) ^
      const DeepCollectionEquality().hash(workflowRef) ^
      const DeepCollectionEquality().hash(workflowInputs) ^
      const DeepCollectionEquality().hash(artifactPathGlob) ^
      const DeepCollectionEquality().hash(autoDeployTargetId) ^
      const DeepCollectionEquality().hash(createdByUserId) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      const DeepCollectionEquality().hash(disabledAt) ^
      runtimeType.hashCode;
}

extension $ApiV1AppsAppIdBuildProfilesPost$ResponseExtension
    on ApiV1AppsAppIdBuildProfilesPost$Response {
  ApiV1AppsAppIdBuildProfilesPost$Response copyWith({
    String? id,
    String? appId,
    String? name,
    enums.ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform? platform,
    String? packageType,
    enums.ApiV1AppsAppIdBuildProfilesPost$ResponseArch? arch,
    String? workflowIdentifier,
    String? workflowRef,
    Map<String, dynamic>? workflowInputs,
    String? artifactPathGlob,
    String? autoDeployTargetId,
    String? createdByUserId,
    String? createdAt,
    String? updatedAt,
    String? disabledAt,
  }) {
    return ApiV1AppsAppIdBuildProfilesPost$Response(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      packageType: packageType ?? this.packageType,
      arch: arch ?? this.arch,
      workflowIdentifier: workflowIdentifier ?? this.workflowIdentifier,
      workflowRef: workflowRef ?? this.workflowRef,
      workflowInputs: workflowInputs ?? this.workflowInputs,
      artifactPathGlob: artifactPathGlob ?? this.artifactPathGlob,
      autoDeployTargetId: autoDeployTargetId ?? this.autoDeployTargetId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      disabledAt: disabledAt ?? this.disabledAt,
    );
  }

  ApiV1AppsAppIdBuildProfilesPost$Response copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? appId,
    Wrapped<String>? name,
    Wrapped<enums.ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform>? platform,
    Wrapped<String>? packageType,
    Wrapped<enums.ApiV1AppsAppIdBuildProfilesPost$ResponseArch?>? arch,
    Wrapped<String>? workflowIdentifier,
    Wrapped<String?>? workflowRef,
    Wrapped<Map<String, dynamic>>? workflowInputs,
    Wrapped<String?>? artifactPathGlob,
    Wrapped<String?>? autoDeployTargetId,
    Wrapped<String?>? createdByUserId,
    Wrapped<String>? createdAt,
    Wrapped<String>? updatedAt,
    Wrapped<String?>? disabledAt,
  }) {
    return ApiV1AppsAppIdBuildProfilesPost$Response(
      id: (id != null ? id.value : this.id),
      appId: (appId != null ? appId.value : this.appId),
      name: (name != null ? name.value : this.name),
      platform: (platform != null ? platform.value : this.platform),
      packageType: (packageType != null ? packageType.value : this.packageType),
      arch: (arch != null ? arch.value : this.arch),
      workflowIdentifier: (workflowIdentifier != null
          ? workflowIdentifier.value
          : this.workflowIdentifier),
      workflowRef: (workflowRef != null ? workflowRef.value : this.workflowRef),
      workflowInputs: (workflowInputs != null
          ? workflowInputs.value
          : this.workflowInputs),
      artifactPathGlob: (artifactPathGlob != null
          ? artifactPathGlob.value
          : this.artifactPathGlob),
      autoDeployTargetId: (autoDeployTargetId != null
          ? autoDeployTargetId.value
          : this.autoDeployTargetId),
      createdByUserId: (createdByUserId != null
          ? createdByUserId.value
          : this.createdByUserId),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
      disabledAt: (disabledAt != null ? disabledAt.value : this.disabledAt),
    );
  }
}

typedef ApiV1AppsAppIdPipelineRunsGet$Response =
    List<ApiV1AppsAppIdPipelineRunsGet$Response$Item>;

@JsonSerializable(explicitToJson: true)
class ApiV1AppsAppIdPipelineRunsGet$Response$Item {
  const ApiV1AppsAppIdPipelineRunsGet$Response$Item({
    required this.id,
    required this.appId,
    required this.repositoryConnectionId,
    required this.releaseId,
    required this.triggerMode,
    required this.branch,
    required this.commitSha,
    required this.status,
    required this.requestedByUserId,
    required this.externalRunId,
    required this.startedAt,
    required this.finishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiV1AppsAppIdPipelineRunsGet$Response$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1AppsAppIdPipelineRunsGet$Response$ItemFromJson(json);

  static const toJsonFactory =
      _$ApiV1AppsAppIdPipelineRunsGet$Response$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1AppsAppIdPipelineRunsGet$Response$ItemToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(name: 'repositoryConnectionId', includeIfNull: false)
  final String? repositoryConnectionId;
  @JsonKey(name: 'releaseId', includeIfNull: false)
  final String? releaseId;
  @JsonKey(
    name: 'triggerMode',
    includeIfNull: false,
    toJson: apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerModeToJson,
    fromJson: apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerModeFromJson,
  )
  final enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode
  triggerMode;
  @JsonKey(name: 'branch', includeIfNull: false)
  final String branch;
  @JsonKey(name: 'commitSha', includeIfNull: false)
  final String? commitSha;
  @JsonKey(
    name: 'status',
    includeIfNull: false,
    toJson: apiV1AppsAppIdPipelineRunsGet$Response$ItemStatusToJson,
    fromJson: apiV1AppsAppIdPipelineRunsGet$Response$ItemStatusFromJson,
  )
  final enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus status;
  @JsonKey(name: 'requestedByUserId', includeIfNull: false)
  final String? requestedByUserId;
  @JsonKey(name: 'externalRunId', includeIfNull: false)
  final String? externalRunId;
  @JsonKey(name: 'startedAt', includeIfNull: false)
  final String? startedAt;
  @JsonKey(name: 'finishedAt', includeIfNull: false)
  final String? finishedAt;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  final String updatedAt;
  static const fromJsonFactory =
      _$ApiV1AppsAppIdPipelineRunsGet$Response$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1AppsAppIdPipelineRunsGet$Response$Item &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.repositoryConnectionId, repositoryConnectionId) ||
                const DeepCollectionEquality().equals(
                  other.repositoryConnectionId,
                  repositoryConnectionId,
                )) &&
            (identical(other.releaseId, releaseId) ||
                const DeepCollectionEquality().equals(
                  other.releaseId,
                  releaseId,
                )) &&
            (identical(other.triggerMode, triggerMode) ||
                const DeepCollectionEquality().equals(
                  other.triggerMode,
                  triggerMode,
                )) &&
            (identical(other.branch, branch) ||
                const DeepCollectionEquality().equals(other.branch, branch)) &&
            (identical(other.commitSha, commitSha) ||
                const DeepCollectionEquality().equals(
                  other.commitSha,
                  commitSha,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.requestedByUserId, requestedByUserId) ||
                const DeepCollectionEquality().equals(
                  other.requestedByUserId,
                  requestedByUserId,
                )) &&
            (identical(other.externalRunId, externalRunId) ||
                const DeepCollectionEquality().equals(
                  other.externalRunId,
                  externalRunId,
                )) &&
            (identical(other.startedAt, startedAt) ||
                const DeepCollectionEquality().equals(
                  other.startedAt,
                  startedAt,
                )) &&
            (identical(other.finishedAt, finishedAt) ||
                const DeepCollectionEquality().equals(
                  other.finishedAt,
                  finishedAt,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(repositoryConnectionId) ^
      const DeepCollectionEquality().hash(releaseId) ^
      const DeepCollectionEquality().hash(triggerMode) ^
      const DeepCollectionEquality().hash(branch) ^
      const DeepCollectionEquality().hash(commitSha) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(requestedByUserId) ^
      const DeepCollectionEquality().hash(externalRunId) ^
      const DeepCollectionEquality().hash(startedAt) ^
      const DeepCollectionEquality().hash(finishedAt) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $ApiV1AppsAppIdPipelineRunsGet$Response$ItemExtension
    on ApiV1AppsAppIdPipelineRunsGet$Response$Item {
  ApiV1AppsAppIdPipelineRunsGet$Response$Item copyWith({
    String? id,
    String? appId,
    String? repositoryConnectionId,
    String? releaseId,
    enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode? triggerMode,
    String? branch,
    String? commitSha,
    enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus? status,
    String? requestedByUserId,
    String? externalRunId,
    String? startedAt,
    String? finishedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return ApiV1AppsAppIdPipelineRunsGet$Response$Item(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      repositoryConnectionId:
          repositoryConnectionId ?? this.repositoryConnectionId,
      releaseId: releaseId ?? this.releaseId,
      triggerMode: triggerMode ?? this.triggerMode,
      branch: branch ?? this.branch,
      commitSha: commitSha ?? this.commitSha,
      status: status ?? this.status,
      requestedByUserId: requestedByUserId ?? this.requestedByUserId,
      externalRunId: externalRunId ?? this.externalRunId,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  ApiV1AppsAppIdPipelineRunsGet$Response$Item copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? appId,
    Wrapped<String?>? repositoryConnectionId,
    Wrapped<String?>? releaseId,
    Wrapped<enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode>?
    triggerMode,
    Wrapped<String>? branch,
    Wrapped<String?>? commitSha,
    Wrapped<enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus>? status,
    Wrapped<String?>? requestedByUserId,
    Wrapped<String?>? externalRunId,
    Wrapped<String?>? startedAt,
    Wrapped<String?>? finishedAt,
    Wrapped<String>? createdAt,
    Wrapped<String>? updatedAt,
  }) {
    return ApiV1AppsAppIdPipelineRunsGet$Response$Item(
      id: (id != null ? id.value : this.id),
      appId: (appId != null ? appId.value : this.appId),
      repositoryConnectionId: (repositoryConnectionId != null
          ? repositoryConnectionId.value
          : this.repositoryConnectionId),
      releaseId: (releaseId != null ? releaseId.value : this.releaseId),
      triggerMode: (triggerMode != null ? triggerMode.value : this.triggerMode),
      branch: (branch != null ? branch.value : this.branch),
      commitSha: (commitSha != null ? commitSha.value : this.commitSha),
      status: (status != null ? status.value : this.status),
      requestedByUserId: (requestedByUserId != null
          ? requestedByUserId.value
          : this.requestedByUserId),
      externalRunId: (externalRunId != null
          ? externalRunId.value
          : this.externalRunId),
      startedAt: (startedAt != null ? startedAt.value : this.startedAt),
      finishedAt: (finishedAt != null ? finishedAt.value : this.finishedAt),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1AppsAppIdPipelineRunsPost$Response {
  const ApiV1AppsAppIdPipelineRunsPost$Response({
    required this.id,
    required this.appId,
    required this.repositoryConnectionId,
    required this.releaseId,
    required this.triggerMode,
    required this.branch,
    required this.commitSha,
    required this.status,
    required this.requestedByUserId,
    required this.externalRunId,
    required this.startedAt,
    required this.finishedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.jobs,
  });

  factory ApiV1AppsAppIdPipelineRunsPost$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1AppsAppIdPipelineRunsPost$ResponseFromJson(json);

  static const toJsonFactory = _$ApiV1AppsAppIdPipelineRunsPost$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1AppsAppIdPipelineRunsPost$ResponseToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(name: 'repositoryConnectionId', includeIfNull: false)
  final String? repositoryConnectionId;
  @JsonKey(name: 'releaseId', includeIfNull: false)
  final String? releaseId;
  @JsonKey(
    name: 'triggerMode',
    includeIfNull: false,
    toJson: apiV1AppsAppIdPipelineRunsPost$ResponseTriggerModeToJson,
    fromJson: apiV1AppsAppIdPipelineRunsPost$ResponseTriggerModeFromJson,
  )
  final enums.ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode triggerMode;
  @JsonKey(name: 'branch', includeIfNull: false)
  final String branch;
  @JsonKey(name: 'commitSha', includeIfNull: false)
  final String? commitSha;
  @JsonKey(
    name: 'status',
    includeIfNull: false,
    toJson: apiV1AppsAppIdPipelineRunsPost$ResponseStatusToJson,
    fromJson: apiV1AppsAppIdPipelineRunsPost$ResponseStatusFromJson,
  )
  final enums.ApiV1AppsAppIdPipelineRunsPost$ResponseStatus status;
  @JsonKey(name: 'requestedByUserId', includeIfNull: false)
  final String? requestedByUserId;
  @JsonKey(name: 'externalRunId', includeIfNull: false)
  final String? externalRunId;
  @JsonKey(name: 'startedAt', includeIfNull: false)
  final String? startedAt;
  @JsonKey(name: 'finishedAt', includeIfNull: false)
  final String? finishedAt;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  final String updatedAt;
  @JsonKey(name: 'jobs', includeIfNull: false)
  final List<ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$Item> jobs;
  static const fromJsonFactory =
      _$ApiV1AppsAppIdPipelineRunsPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1AppsAppIdPipelineRunsPost$Response &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.repositoryConnectionId, repositoryConnectionId) ||
                const DeepCollectionEquality().equals(
                  other.repositoryConnectionId,
                  repositoryConnectionId,
                )) &&
            (identical(other.releaseId, releaseId) ||
                const DeepCollectionEquality().equals(
                  other.releaseId,
                  releaseId,
                )) &&
            (identical(other.triggerMode, triggerMode) ||
                const DeepCollectionEquality().equals(
                  other.triggerMode,
                  triggerMode,
                )) &&
            (identical(other.branch, branch) ||
                const DeepCollectionEquality().equals(other.branch, branch)) &&
            (identical(other.commitSha, commitSha) ||
                const DeepCollectionEquality().equals(
                  other.commitSha,
                  commitSha,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.requestedByUserId, requestedByUserId) ||
                const DeepCollectionEquality().equals(
                  other.requestedByUserId,
                  requestedByUserId,
                )) &&
            (identical(other.externalRunId, externalRunId) ||
                const DeepCollectionEquality().equals(
                  other.externalRunId,
                  externalRunId,
                )) &&
            (identical(other.startedAt, startedAt) ||
                const DeepCollectionEquality().equals(
                  other.startedAt,
                  startedAt,
                )) &&
            (identical(other.finishedAt, finishedAt) ||
                const DeepCollectionEquality().equals(
                  other.finishedAt,
                  finishedAt,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )) &&
            (identical(other.jobs, jobs) ||
                const DeepCollectionEquality().equals(other.jobs, jobs)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(repositoryConnectionId) ^
      const DeepCollectionEquality().hash(releaseId) ^
      const DeepCollectionEquality().hash(triggerMode) ^
      const DeepCollectionEquality().hash(branch) ^
      const DeepCollectionEquality().hash(commitSha) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(requestedByUserId) ^
      const DeepCollectionEquality().hash(externalRunId) ^
      const DeepCollectionEquality().hash(startedAt) ^
      const DeepCollectionEquality().hash(finishedAt) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      const DeepCollectionEquality().hash(jobs) ^
      runtimeType.hashCode;
}

extension $ApiV1AppsAppIdPipelineRunsPost$ResponseExtension
    on ApiV1AppsAppIdPipelineRunsPost$Response {
  ApiV1AppsAppIdPipelineRunsPost$Response copyWith({
    String? id,
    String? appId,
    String? repositoryConnectionId,
    String? releaseId,
    enums.ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode? triggerMode,
    String? branch,
    String? commitSha,
    enums.ApiV1AppsAppIdPipelineRunsPost$ResponseStatus? status,
    String? requestedByUserId,
    String? externalRunId,
    String? startedAt,
    String? finishedAt,
    String? createdAt,
    String? updatedAt,
    List<ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$Item>? jobs,
  }) {
    return ApiV1AppsAppIdPipelineRunsPost$Response(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      repositoryConnectionId:
          repositoryConnectionId ?? this.repositoryConnectionId,
      releaseId: releaseId ?? this.releaseId,
      triggerMode: triggerMode ?? this.triggerMode,
      branch: branch ?? this.branch,
      commitSha: commitSha ?? this.commitSha,
      status: status ?? this.status,
      requestedByUserId: requestedByUserId ?? this.requestedByUserId,
      externalRunId: externalRunId ?? this.externalRunId,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      jobs: jobs ?? this.jobs,
    );
  }

  ApiV1AppsAppIdPipelineRunsPost$Response copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? appId,
    Wrapped<String?>? repositoryConnectionId,
    Wrapped<String?>? releaseId,
    Wrapped<enums.ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode>?
    triggerMode,
    Wrapped<String>? branch,
    Wrapped<String?>? commitSha,
    Wrapped<enums.ApiV1AppsAppIdPipelineRunsPost$ResponseStatus>? status,
    Wrapped<String?>? requestedByUserId,
    Wrapped<String?>? externalRunId,
    Wrapped<String?>? startedAt,
    Wrapped<String?>? finishedAt,
    Wrapped<String>? createdAt,
    Wrapped<String>? updatedAt,
    Wrapped<List<ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$Item>>? jobs,
  }) {
    return ApiV1AppsAppIdPipelineRunsPost$Response(
      id: (id != null ? id.value : this.id),
      appId: (appId != null ? appId.value : this.appId),
      repositoryConnectionId: (repositoryConnectionId != null
          ? repositoryConnectionId.value
          : this.repositoryConnectionId),
      releaseId: (releaseId != null ? releaseId.value : this.releaseId),
      triggerMode: (triggerMode != null ? triggerMode.value : this.triggerMode),
      branch: (branch != null ? branch.value : this.branch),
      commitSha: (commitSha != null ? commitSha.value : this.commitSha),
      status: (status != null ? status.value : this.status),
      requestedByUserId: (requestedByUserId != null
          ? requestedByUserId.value
          : this.requestedByUserId),
      externalRunId: (externalRunId != null
          ? externalRunId.value
          : this.externalRunId),
      startedAt: (startedAt != null ? startedAt.value : this.startedAt),
      finishedAt: (finishedAt != null ? finishedAt.value : this.finishedAt),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
      jobs: (jobs != null ? jobs.value : this.jobs),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1PipelineRunsPipelineRunIdGet$Response {
  const ApiV1PipelineRunsPipelineRunIdGet$Response({
    required this.id,
    required this.appId,
    required this.repositoryConnectionId,
    required this.releaseId,
    required this.triggerMode,
    required this.branch,
    required this.commitSha,
    required this.status,
    required this.requestedByUserId,
    required this.externalRunId,
    required this.startedAt,
    required this.finishedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.jobs,
  });

  factory ApiV1PipelineRunsPipelineRunIdGet$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1PipelineRunsPipelineRunIdGet$ResponseFromJson(json);

  static const toJsonFactory =
      _$ApiV1PipelineRunsPipelineRunIdGet$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1PipelineRunsPipelineRunIdGet$ResponseToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(name: 'repositoryConnectionId', includeIfNull: false)
  final String? repositoryConnectionId;
  @JsonKey(name: 'releaseId', includeIfNull: false)
  final String? releaseId;
  @JsonKey(
    name: 'triggerMode',
    includeIfNull: false,
    toJson: apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerModeToJson,
    fromJson: apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerModeFromJson,
  )
  final enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode triggerMode;
  @JsonKey(name: 'branch', includeIfNull: false)
  final String branch;
  @JsonKey(name: 'commitSha', includeIfNull: false)
  final String? commitSha;
  @JsonKey(
    name: 'status',
    includeIfNull: false,
    toJson: apiV1PipelineRunsPipelineRunIdGet$ResponseStatusToJson,
    fromJson: apiV1PipelineRunsPipelineRunIdGet$ResponseStatusFromJson,
  )
  final enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus status;
  @JsonKey(name: 'requestedByUserId', includeIfNull: false)
  final String? requestedByUserId;
  @JsonKey(name: 'externalRunId', includeIfNull: false)
  final String? externalRunId;
  @JsonKey(name: 'startedAt', includeIfNull: false)
  final String? startedAt;
  @JsonKey(name: 'finishedAt', includeIfNull: false)
  final String? finishedAt;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  final String updatedAt;
  @JsonKey(name: 'jobs', includeIfNull: false)
  final List<ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$Item> jobs;
  static const fromJsonFactory =
      _$ApiV1PipelineRunsPipelineRunIdGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1PipelineRunsPipelineRunIdGet$Response &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.repositoryConnectionId, repositoryConnectionId) ||
                const DeepCollectionEquality().equals(
                  other.repositoryConnectionId,
                  repositoryConnectionId,
                )) &&
            (identical(other.releaseId, releaseId) ||
                const DeepCollectionEquality().equals(
                  other.releaseId,
                  releaseId,
                )) &&
            (identical(other.triggerMode, triggerMode) ||
                const DeepCollectionEquality().equals(
                  other.triggerMode,
                  triggerMode,
                )) &&
            (identical(other.branch, branch) ||
                const DeepCollectionEquality().equals(other.branch, branch)) &&
            (identical(other.commitSha, commitSha) ||
                const DeepCollectionEquality().equals(
                  other.commitSha,
                  commitSha,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.requestedByUserId, requestedByUserId) ||
                const DeepCollectionEquality().equals(
                  other.requestedByUserId,
                  requestedByUserId,
                )) &&
            (identical(other.externalRunId, externalRunId) ||
                const DeepCollectionEquality().equals(
                  other.externalRunId,
                  externalRunId,
                )) &&
            (identical(other.startedAt, startedAt) ||
                const DeepCollectionEquality().equals(
                  other.startedAt,
                  startedAt,
                )) &&
            (identical(other.finishedAt, finishedAt) ||
                const DeepCollectionEquality().equals(
                  other.finishedAt,
                  finishedAt,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )) &&
            (identical(other.jobs, jobs) ||
                const DeepCollectionEquality().equals(other.jobs, jobs)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(repositoryConnectionId) ^
      const DeepCollectionEquality().hash(releaseId) ^
      const DeepCollectionEquality().hash(triggerMode) ^
      const DeepCollectionEquality().hash(branch) ^
      const DeepCollectionEquality().hash(commitSha) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(requestedByUserId) ^
      const DeepCollectionEquality().hash(externalRunId) ^
      const DeepCollectionEquality().hash(startedAt) ^
      const DeepCollectionEquality().hash(finishedAt) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      const DeepCollectionEquality().hash(jobs) ^
      runtimeType.hashCode;
}

extension $ApiV1PipelineRunsPipelineRunIdGet$ResponseExtension
    on ApiV1PipelineRunsPipelineRunIdGet$Response {
  ApiV1PipelineRunsPipelineRunIdGet$Response copyWith({
    String? id,
    String? appId,
    String? repositoryConnectionId,
    String? releaseId,
    enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode? triggerMode,
    String? branch,
    String? commitSha,
    enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus? status,
    String? requestedByUserId,
    String? externalRunId,
    String? startedAt,
    String? finishedAt,
    String? createdAt,
    String? updatedAt,
    List<ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$Item>? jobs,
  }) {
    return ApiV1PipelineRunsPipelineRunIdGet$Response(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      repositoryConnectionId:
          repositoryConnectionId ?? this.repositoryConnectionId,
      releaseId: releaseId ?? this.releaseId,
      triggerMode: triggerMode ?? this.triggerMode,
      branch: branch ?? this.branch,
      commitSha: commitSha ?? this.commitSha,
      status: status ?? this.status,
      requestedByUserId: requestedByUserId ?? this.requestedByUserId,
      externalRunId: externalRunId ?? this.externalRunId,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      jobs: jobs ?? this.jobs,
    );
  }

  ApiV1PipelineRunsPipelineRunIdGet$Response copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? appId,
    Wrapped<String?>? repositoryConnectionId,
    Wrapped<String?>? releaseId,
    Wrapped<enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode>?
    triggerMode,
    Wrapped<String>? branch,
    Wrapped<String?>? commitSha,
    Wrapped<enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus>? status,
    Wrapped<String?>? requestedByUserId,
    Wrapped<String?>? externalRunId,
    Wrapped<String?>? startedAt,
    Wrapped<String?>? finishedAt,
    Wrapped<String>? createdAt,
    Wrapped<String>? updatedAt,
    Wrapped<List<ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$Item>>? jobs,
  }) {
    return ApiV1PipelineRunsPipelineRunIdGet$Response(
      id: (id != null ? id.value : this.id),
      appId: (appId != null ? appId.value : this.appId),
      repositoryConnectionId: (repositoryConnectionId != null
          ? repositoryConnectionId.value
          : this.repositoryConnectionId),
      releaseId: (releaseId != null ? releaseId.value : this.releaseId),
      triggerMode: (triggerMode != null ? triggerMode.value : this.triggerMode),
      branch: (branch != null ? branch.value : this.branch),
      commitSha: (commitSha != null ? commitSha.value : this.commitSha),
      status: (status != null ? status.value : this.status),
      requestedByUserId: (requestedByUserId != null
          ? requestedByUserId.value
          : this.requestedByUserId),
      externalRunId: (externalRunId != null
          ? externalRunId.value
          : this.externalRunId),
      startedAt: (startedAt != null ? startedAt.value : this.startedAt),
      finishedAt: (finishedAt != null ? finishedAt.value : this.finishedAt),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
      jobs: (jobs != null ? jobs.value : this.jobs),
    );
  }
}

typedef ApiV1ChannelsGet$Response = List<ApiV1ChannelsGet$Response$Item>;

@JsonSerializable(explicitToJson: true)
class ApiV1ChannelsGet$Response$Item {
  const ApiV1ChannelsGet$Response$Item({
    required this.id,
    required this.appId,
    required this.slug,
    required this.displayName,
    required this.kind,
    required this.visibility,
    required this.isSystem,
    required this.rolloutPercent,
    required this.parentChannelId,
    required this.createdByUserId,
    required this.createdAt,
  });

  factory ApiV1ChannelsGet$Response$Item.fromJson(Map<String, dynamic> json) =>
      _$ApiV1ChannelsGet$Response$ItemFromJson(json);

  static const toJsonFactory = _$ApiV1ChannelsGet$Response$ItemToJson;
  Map<String, dynamic> toJson() => _$ApiV1ChannelsGet$Response$ItemToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(name: 'slug', includeIfNull: false)
  final String slug;
  @JsonKey(name: 'displayName', includeIfNull: false)
  final String? displayName;
  @JsonKey(
    name: 'kind',
    includeIfNull: false,
    toJson: apiV1ChannelsGet$Response$ItemKindToJson,
    fromJson: apiV1ChannelsGet$Response$ItemKindFromJson,
  )
  final enums.ApiV1ChannelsGet$Response$ItemKind kind;
  @JsonKey(
    name: 'visibility',
    includeIfNull: false,
    toJson: apiV1ChannelsGet$Response$ItemVisibilityToJson,
    fromJson: apiV1ChannelsGet$Response$ItemVisibilityFromJson,
  )
  final enums.ApiV1ChannelsGet$Response$ItemVisibility visibility;
  @JsonKey(name: 'isSystem', includeIfNull: false)
  final bool isSystem;
  @JsonKey(name: 'rolloutPercent', includeIfNull: false)
  final int rolloutPercent;
  @JsonKey(name: 'parentChannelId', includeIfNull: false)
  final String? parentChannelId;
  @JsonKey(name: 'createdByUserId', includeIfNull: false)
  final String? createdByUserId;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  static const fromJsonFactory = _$ApiV1ChannelsGet$Response$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ChannelsGet$Response$Item &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.slug, slug) ||
                const DeepCollectionEquality().equals(other.slug, slug)) &&
            (identical(other.displayName, displayName) ||
                const DeepCollectionEquality().equals(
                  other.displayName,
                  displayName,
                )) &&
            (identical(other.kind, kind) ||
                const DeepCollectionEquality().equals(other.kind, kind)) &&
            (identical(other.visibility, visibility) ||
                const DeepCollectionEquality().equals(
                  other.visibility,
                  visibility,
                )) &&
            (identical(other.isSystem, isSystem) ||
                const DeepCollectionEquality().equals(
                  other.isSystem,
                  isSystem,
                )) &&
            (identical(other.rolloutPercent, rolloutPercent) ||
                const DeepCollectionEquality().equals(
                  other.rolloutPercent,
                  rolloutPercent,
                )) &&
            (identical(other.parentChannelId, parentChannelId) ||
                const DeepCollectionEquality().equals(
                  other.parentChannelId,
                  parentChannelId,
                )) &&
            (identical(other.createdByUserId, createdByUserId) ||
                const DeepCollectionEquality().equals(
                  other.createdByUserId,
                  createdByUserId,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(slug) ^
      const DeepCollectionEquality().hash(displayName) ^
      const DeepCollectionEquality().hash(kind) ^
      const DeepCollectionEquality().hash(visibility) ^
      const DeepCollectionEquality().hash(isSystem) ^
      const DeepCollectionEquality().hash(rolloutPercent) ^
      const DeepCollectionEquality().hash(parentChannelId) ^
      const DeepCollectionEquality().hash(createdByUserId) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $ApiV1ChannelsGet$Response$ItemExtension
    on ApiV1ChannelsGet$Response$Item {
  ApiV1ChannelsGet$Response$Item copyWith({
    String? id,
    String? appId,
    String? slug,
    String? displayName,
    enums.ApiV1ChannelsGet$Response$ItemKind? kind,
    enums.ApiV1ChannelsGet$Response$ItemVisibility? visibility,
    bool? isSystem,
    int? rolloutPercent,
    String? parentChannelId,
    String? createdByUserId,
    String? createdAt,
  }) {
    return ApiV1ChannelsGet$Response$Item(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      slug: slug ?? this.slug,
      displayName: displayName ?? this.displayName,
      kind: kind ?? this.kind,
      visibility: visibility ?? this.visibility,
      isSystem: isSystem ?? this.isSystem,
      rolloutPercent: rolloutPercent ?? this.rolloutPercent,
      parentChannelId: parentChannelId ?? this.parentChannelId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  ApiV1ChannelsGet$Response$Item copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? appId,
    Wrapped<String>? slug,
    Wrapped<String?>? displayName,
    Wrapped<enums.ApiV1ChannelsGet$Response$ItemKind>? kind,
    Wrapped<enums.ApiV1ChannelsGet$Response$ItemVisibility>? visibility,
    Wrapped<bool>? isSystem,
    Wrapped<int>? rolloutPercent,
    Wrapped<String?>? parentChannelId,
    Wrapped<String?>? createdByUserId,
    Wrapped<String>? createdAt,
  }) {
    return ApiV1ChannelsGet$Response$Item(
      id: (id != null ? id.value : this.id),
      appId: (appId != null ? appId.value : this.appId),
      slug: (slug != null ? slug.value : this.slug),
      displayName: (displayName != null ? displayName.value : this.displayName),
      kind: (kind != null ? kind.value : this.kind),
      visibility: (visibility != null ? visibility.value : this.visibility),
      isSystem: (isSystem != null ? isSystem.value : this.isSystem),
      rolloutPercent: (rolloutPercent != null
          ? rolloutPercent.value
          : this.rolloutPercent),
      parentChannelId: (parentChannelId != null
          ? parentChannelId.value
          : this.parentChannelId),
      createdByUserId: (createdByUserId != null
          ? createdByUserId.value
          : this.createdByUserId),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ChannelsPost$Response {
  const ApiV1ChannelsPost$Response({
    required this.id,
    required this.appId,
    required this.slug,
    required this.displayName,
    required this.kind,
    required this.visibility,
    required this.isSystem,
    required this.rolloutPercent,
    required this.parentChannelId,
    required this.createdByUserId,
    required this.createdAt,
  });

  factory ApiV1ChannelsPost$Response.fromJson(Map<String, dynamic> json) =>
      _$ApiV1ChannelsPost$ResponseFromJson(json);

  static const toJsonFactory = _$ApiV1ChannelsPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$ApiV1ChannelsPost$ResponseToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(name: 'slug', includeIfNull: false)
  final String slug;
  @JsonKey(name: 'displayName', includeIfNull: false)
  final String? displayName;
  @JsonKey(
    name: 'kind',
    includeIfNull: false,
    toJson: apiV1ChannelsPost$ResponseKindToJson,
    fromJson: apiV1ChannelsPost$ResponseKindFromJson,
  )
  final enums.ApiV1ChannelsPost$ResponseKind kind;
  @JsonKey(
    name: 'visibility',
    includeIfNull: false,
    toJson: apiV1ChannelsPost$ResponseVisibilityToJson,
    fromJson: apiV1ChannelsPost$ResponseVisibilityFromJson,
  )
  final enums.ApiV1ChannelsPost$ResponseVisibility visibility;
  @JsonKey(name: 'isSystem', includeIfNull: false)
  final bool isSystem;
  @JsonKey(name: 'rolloutPercent', includeIfNull: false)
  final int rolloutPercent;
  @JsonKey(name: 'parentChannelId', includeIfNull: false)
  final String? parentChannelId;
  @JsonKey(name: 'createdByUserId', includeIfNull: false)
  final String? createdByUserId;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  static const fromJsonFactory = _$ApiV1ChannelsPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ChannelsPost$Response &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.slug, slug) ||
                const DeepCollectionEquality().equals(other.slug, slug)) &&
            (identical(other.displayName, displayName) ||
                const DeepCollectionEquality().equals(
                  other.displayName,
                  displayName,
                )) &&
            (identical(other.kind, kind) ||
                const DeepCollectionEquality().equals(other.kind, kind)) &&
            (identical(other.visibility, visibility) ||
                const DeepCollectionEquality().equals(
                  other.visibility,
                  visibility,
                )) &&
            (identical(other.isSystem, isSystem) ||
                const DeepCollectionEquality().equals(
                  other.isSystem,
                  isSystem,
                )) &&
            (identical(other.rolloutPercent, rolloutPercent) ||
                const DeepCollectionEquality().equals(
                  other.rolloutPercent,
                  rolloutPercent,
                )) &&
            (identical(other.parentChannelId, parentChannelId) ||
                const DeepCollectionEquality().equals(
                  other.parentChannelId,
                  parentChannelId,
                )) &&
            (identical(other.createdByUserId, createdByUserId) ||
                const DeepCollectionEquality().equals(
                  other.createdByUserId,
                  createdByUserId,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(slug) ^
      const DeepCollectionEquality().hash(displayName) ^
      const DeepCollectionEquality().hash(kind) ^
      const DeepCollectionEquality().hash(visibility) ^
      const DeepCollectionEquality().hash(isSystem) ^
      const DeepCollectionEquality().hash(rolloutPercent) ^
      const DeepCollectionEquality().hash(parentChannelId) ^
      const DeepCollectionEquality().hash(createdByUserId) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $ApiV1ChannelsPost$ResponseExtension on ApiV1ChannelsPost$Response {
  ApiV1ChannelsPost$Response copyWith({
    String? id,
    String? appId,
    String? slug,
    String? displayName,
    enums.ApiV1ChannelsPost$ResponseKind? kind,
    enums.ApiV1ChannelsPost$ResponseVisibility? visibility,
    bool? isSystem,
    int? rolloutPercent,
    String? parentChannelId,
    String? createdByUserId,
    String? createdAt,
  }) {
    return ApiV1ChannelsPost$Response(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      slug: slug ?? this.slug,
      displayName: displayName ?? this.displayName,
      kind: kind ?? this.kind,
      visibility: visibility ?? this.visibility,
      isSystem: isSystem ?? this.isSystem,
      rolloutPercent: rolloutPercent ?? this.rolloutPercent,
      parentChannelId: parentChannelId ?? this.parentChannelId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  ApiV1ChannelsPost$Response copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? appId,
    Wrapped<String>? slug,
    Wrapped<String?>? displayName,
    Wrapped<enums.ApiV1ChannelsPost$ResponseKind>? kind,
    Wrapped<enums.ApiV1ChannelsPost$ResponseVisibility>? visibility,
    Wrapped<bool>? isSystem,
    Wrapped<int>? rolloutPercent,
    Wrapped<String?>? parentChannelId,
    Wrapped<String?>? createdByUserId,
    Wrapped<String>? createdAt,
  }) {
    return ApiV1ChannelsPost$Response(
      id: (id != null ? id.value : this.id),
      appId: (appId != null ? appId.value : this.appId),
      slug: (slug != null ? slug.value : this.slug),
      displayName: (displayName != null ? displayName.value : this.displayName),
      kind: (kind != null ? kind.value : this.kind),
      visibility: (visibility != null ? visibility.value : this.visibility),
      isSystem: (isSystem != null ? isSystem.value : this.isSystem),
      rolloutPercent: (rolloutPercent != null
          ? rolloutPercent.value
          : this.rolloutPercent),
      parentChannelId: (parentChannelId != null
          ? parentChannelId.value
          : this.parentChannelId),
      createdByUserId: (createdByUserId != null
          ? createdByUserId.value
          : this.createdByUserId),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ChannelsChannelIdPatch$Response {
  const ApiV1ChannelsChannelIdPatch$Response({
    required this.id,
    required this.appId,
    required this.slug,
    required this.displayName,
    required this.kind,
    required this.visibility,
    required this.isSystem,
    required this.rolloutPercent,
    required this.parentChannelId,
    required this.createdByUserId,
    required this.createdAt,
  });

  factory ApiV1ChannelsChannelIdPatch$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1ChannelsChannelIdPatch$ResponseFromJson(json);

  static const toJsonFactory = _$ApiV1ChannelsChannelIdPatch$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1ChannelsChannelIdPatch$ResponseToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(name: 'slug', includeIfNull: false)
  final String slug;
  @JsonKey(name: 'displayName', includeIfNull: false)
  final String? displayName;
  @JsonKey(
    name: 'kind',
    includeIfNull: false,
    toJson: apiV1ChannelsChannelIdPatch$ResponseKindToJson,
    fromJson: apiV1ChannelsChannelIdPatch$ResponseKindFromJson,
  )
  final enums.ApiV1ChannelsChannelIdPatch$ResponseKind kind;
  @JsonKey(
    name: 'visibility',
    includeIfNull: false,
    toJson: apiV1ChannelsChannelIdPatch$ResponseVisibilityToJson,
    fromJson: apiV1ChannelsChannelIdPatch$ResponseVisibilityFromJson,
  )
  final enums.ApiV1ChannelsChannelIdPatch$ResponseVisibility visibility;
  @JsonKey(name: 'isSystem', includeIfNull: false)
  final bool isSystem;
  @JsonKey(name: 'rolloutPercent', includeIfNull: false)
  final int rolloutPercent;
  @JsonKey(name: 'parentChannelId', includeIfNull: false)
  final String? parentChannelId;
  @JsonKey(name: 'createdByUserId', includeIfNull: false)
  final String? createdByUserId;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  static const fromJsonFactory = _$ApiV1ChannelsChannelIdPatch$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ChannelsChannelIdPatch$Response &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.slug, slug) ||
                const DeepCollectionEquality().equals(other.slug, slug)) &&
            (identical(other.displayName, displayName) ||
                const DeepCollectionEquality().equals(
                  other.displayName,
                  displayName,
                )) &&
            (identical(other.kind, kind) ||
                const DeepCollectionEquality().equals(other.kind, kind)) &&
            (identical(other.visibility, visibility) ||
                const DeepCollectionEquality().equals(
                  other.visibility,
                  visibility,
                )) &&
            (identical(other.isSystem, isSystem) ||
                const DeepCollectionEquality().equals(
                  other.isSystem,
                  isSystem,
                )) &&
            (identical(other.rolloutPercent, rolloutPercent) ||
                const DeepCollectionEquality().equals(
                  other.rolloutPercent,
                  rolloutPercent,
                )) &&
            (identical(other.parentChannelId, parentChannelId) ||
                const DeepCollectionEquality().equals(
                  other.parentChannelId,
                  parentChannelId,
                )) &&
            (identical(other.createdByUserId, createdByUserId) ||
                const DeepCollectionEquality().equals(
                  other.createdByUserId,
                  createdByUserId,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(slug) ^
      const DeepCollectionEquality().hash(displayName) ^
      const DeepCollectionEquality().hash(kind) ^
      const DeepCollectionEquality().hash(visibility) ^
      const DeepCollectionEquality().hash(isSystem) ^
      const DeepCollectionEquality().hash(rolloutPercent) ^
      const DeepCollectionEquality().hash(parentChannelId) ^
      const DeepCollectionEquality().hash(createdByUserId) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $ApiV1ChannelsChannelIdPatch$ResponseExtension
    on ApiV1ChannelsChannelIdPatch$Response {
  ApiV1ChannelsChannelIdPatch$Response copyWith({
    String? id,
    String? appId,
    String? slug,
    String? displayName,
    enums.ApiV1ChannelsChannelIdPatch$ResponseKind? kind,
    enums.ApiV1ChannelsChannelIdPatch$ResponseVisibility? visibility,
    bool? isSystem,
    int? rolloutPercent,
    String? parentChannelId,
    String? createdByUserId,
    String? createdAt,
  }) {
    return ApiV1ChannelsChannelIdPatch$Response(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      slug: slug ?? this.slug,
      displayName: displayName ?? this.displayName,
      kind: kind ?? this.kind,
      visibility: visibility ?? this.visibility,
      isSystem: isSystem ?? this.isSystem,
      rolloutPercent: rolloutPercent ?? this.rolloutPercent,
      parentChannelId: parentChannelId ?? this.parentChannelId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  ApiV1ChannelsChannelIdPatch$Response copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? appId,
    Wrapped<String>? slug,
    Wrapped<String?>? displayName,
    Wrapped<enums.ApiV1ChannelsChannelIdPatch$ResponseKind>? kind,
    Wrapped<enums.ApiV1ChannelsChannelIdPatch$ResponseVisibility>? visibility,
    Wrapped<bool>? isSystem,
    Wrapped<int>? rolloutPercent,
    Wrapped<String?>? parentChannelId,
    Wrapped<String?>? createdByUserId,
    Wrapped<String>? createdAt,
  }) {
    return ApiV1ChannelsChannelIdPatch$Response(
      id: (id != null ? id.value : this.id),
      appId: (appId != null ? appId.value : this.appId),
      slug: (slug != null ? slug.value : this.slug),
      displayName: (displayName != null ? displayName.value : this.displayName),
      kind: (kind != null ? kind.value : this.kind),
      visibility: (visibility != null ? visibility.value : this.visibility),
      isSystem: (isSystem != null ? isSystem.value : this.isSystem),
      rolloutPercent: (rolloutPercent != null
          ? rolloutPercent.value
          : this.rolloutPercent),
      parentChannelId: (parentChannelId != null
          ? parentChannelId.value
          : this.parentChannelId),
      createdByUserId: (createdByUserId != null
          ? createdByUserId.value
          : this.createdByUserId),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ChannelsChannelIdRollbackPost$Response {
  const ApiV1ChannelsChannelIdRollbackPost$Response({
    required this.id,
    required this.channelId,
    required this.releaseId,
    this.platform,
    this.arch,
    required this.rolloutPercent,
    required this.createdAt,
  });

  factory ApiV1ChannelsChannelIdRollbackPost$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1ChannelsChannelIdRollbackPost$ResponseFromJson(json);

  static const toJsonFactory =
      _$ApiV1ChannelsChannelIdRollbackPost$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1ChannelsChannelIdRollbackPost$ResponseToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'channelId', includeIfNull: false)
  final String channelId;
  @JsonKey(name: 'releaseId', includeIfNull: false)
  final String releaseId;
  @JsonKey(
    name: 'platform',
    includeIfNull: false,
    toJson: apiV1ChannelsChannelIdRollbackPost$ResponsePlatformNullableToJson,
    fromJson:
        apiV1ChannelsChannelIdRollbackPost$ResponsePlatformNullableFromJson,
  )
  final enums.ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform? platform;
  @JsonKey(
    name: 'arch',
    includeIfNull: false,
    toJson: apiV1ChannelsChannelIdRollbackPost$ResponseArchNullableToJson,
    fromJson: apiV1ChannelsChannelIdRollbackPost$ResponseArchNullableFromJson,
  )
  final enums.ApiV1ChannelsChannelIdRollbackPost$ResponseArch? arch;
  @JsonKey(name: 'rolloutPercent', includeIfNull: false)
  final int rolloutPercent;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  static const fromJsonFactory =
      _$ApiV1ChannelsChannelIdRollbackPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ChannelsChannelIdRollbackPost$Response &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.channelId, channelId) ||
                const DeepCollectionEquality().equals(
                  other.channelId,
                  channelId,
                )) &&
            (identical(other.releaseId, releaseId) ||
                const DeepCollectionEquality().equals(
                  other.releaseId,
                  releaseId,
                )) &&
            (identical(other.platform, platform) ||
                const DeepCollectionEquality().equals(
                  other.platform,
                  platform,
                )) &&
            (identical(other.arch, arch) ||
                const DeepCollectionEquality().equals(other.arch, arch)) &&
            (identical(other.rolloutPercent, rolloutPercent) ||
                const DeepCollectionEquality().equals(
                  other.rolloutPercent,
                  rolloutPercent,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(channelId) ^
      const DeepCollectionEquality().hash(releaseId) ^
      const DeepCollectionEquality().hash(platform) ^
      const DeepCollectionEquality().hash(arch) ^
      const DeepCollectionEquality().hash(rolloutPercent) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $ApiV1ChannelsChannelIdRollbackPost$ResponseExtension
    on ApiV1ChannelsChannelIdRollbackPost$Response {
  ApiV1ChannelsChannelIdRollbackPost$Response copyWith({
    String? id,
    String? channelId,
    String? releaseId,
    enums.ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform? platform,
    enums.ApiV1ChannelsChannelIdRollbackPost$ResponseArch? arch,
    int? rolloutPercent,
    String? createdAt,
  }) {
    return ApiV1ChannelsChannelIdRollbackPost$Response(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      releaseId: releaseId ?? this.releaseId,
      platform: platform ?? this.platform,
      arch: arch ?? this.arch,
      rolloutPercent: rolloutPercent ?? this.rolloutPercent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  ApiV1ChannelsChannelIdRollbackPost$Response copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? channelId,
    Wrapped<String>? releaseId,
    Wrapped<enums.ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform?>?
    platform,
    Wrapped<enums.ApiV1ChannelsChannelIdRollbackPost$ResponseArch?>? arch,
    Wrapped<int>? rolloutPercent,
    Wrapped<String>? createdAt,
  }) {
    return ApiV1ChannelsChannelIdRollbackPost$Response(
      id: (id != null ? id.value : this.id),
      channelId: (channelId != null ? channelId.value : this.channelId),
      releaseId: (releaseId != null ? releaseId.value : this.releaseId),
      platform: (platform != null ? platform.value : this.platform),
      arch: (arch != null ? arch.value : this.arch),
      rolloutPercent: (rolloutPercent != null
          ? rolloutPercent.value
          : this.rolloutPercent),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

typedef ApiV1ReleasesGet$Response = List<ApiV1ReleasesGet$Response$Item>;

@JsonSerializable(explicitToJson: true)
class ApiV1ReleasesGet$Response$Item {
  const ApiV1ReleasesGet$Response$Item({
    required this.id,
    required this.appId,
    required this.version,
    required this.buildNumber,
    required this.status,
    required this.notes,
    required this.publishedAt,
    required this.createdAt,
  });

  factory ApiV1ReleasesGet$Response$Item.fromJson(Map<String, dynamic> json) =>
      _$ApiV1ReleasesGet$Response$ItemFromJson(json);

  static const toJsonFactory = _$ApiV1ReleasesGet$Response$ItemToJson;
  Map<String, dynamic> toJson() => _$ApiV1ReleasesGet$Response$ItemToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(name: 'version', includeIfNull: false)
  final String version;
  @JsonKey(name: 'buildNumber', includeIfNull: false)
  final String? buildNumber;
  @JsonKey(
    name: 'status',
    includeIfNull: false,
    toJson: apiV1ReleasesGet$Response$ItemStatusToJson,
    fromJson: apiV1ReleasesGet$Response$ItemStatusFromJson,
  )
  final enums.ApiV1ReleasesGet$Response$ItemStatus status;
  @JsonKey(name: 'notes', includeIfNull: false)
  final String? notes;
  @JsonKey(name: 'publishedAt', includeIfNull: false)
  final String? publishedAt;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  static const fromJsonFactory = _$ApiV1ReleasesGet$Response$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ReleasesGet$Response$Item &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(
                  other.version,
                  version,
                )) &&
            (identical(other.buildNumber, buildNumber) ||
                const DeepCollectionEquality().equals(
                  other.buildNumber,
                  buildNumber,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.notes, notes) ||
                const DeepCollectionEquality().equals(other.notes, notes)) &&
            (identical(other.publishedAt, publishedAt) ||
                const DeepCollectionEquality().equals(
                  other.publishedAt,
                  publishedAt,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(version) ^
      const DeepCollectionEquality().hash(buildNumber) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(notes) ^
      const DeepCollectionEquality().hash(publishedAt) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $ApiV1ReleasesGet$Response$ItemExtension
    on ApiV1ReleasesGet$Response$Item {
  ApiV1ReleasesGet$Response$Item copyWith({
    String? id,
    String? appId,
    String? version,
    String? buildNumber,
    enums.ApiV1ReleasesGet$Response$ItemStatus? status,
    String? notes,
    String? publishedAt,
    String? createdAt,
  }) {
    return ApiV1ReleasesGet$Response$Item(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  ApiV1ReleasesGet$Response$Item copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? appId,
    Wrapped<String>? version,
    Wrapped<String?>? buildNumber,
    Wrapped<enums.ApiV1ReleasesGet$Response$ItemStatus>? status,
    Wrapped<String?>? notes,
    Wrapped<String?>? publishedAt,
    Wrapped<String>? createdAt,
  }) {
    return ApiV1ReleasesGet$Response$Item(
      id: (id != null ? id.value : this.id),
      appId: (appId != null ? appId.value : this.appId),
      version: (version != null ? version.value : this.version),
      buildNumber: (buildNumber != null ? buildNumber.value : this.buildNumber),
      status: (status != null ? status.value : this.status),
      notes: (notes != null ? notes.value : this.notes),
      publishedAt: (publishedAt != null ? publishedAt.value : this.publishedAt),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ReleasesPost$Response {
  const ApiV1ReleasesPost$Response({
    required this.id,
    required this.appId,
    required this.version,
    required this.buildNumber,
    required this.status,
    required this.notes,
    required this.publishedAt,
    required this.createdAt,
  });

  factory ApiV1ReleasesPost$Response.fromJson(Map<String, dynamic> json) =>
      _$ApiV1ReleasesPost$ResponseFromJson(json);

  static const toJsonFactory = _$ApiV1ReleasesPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$ApiV1ReleasesPost$ResponseToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(name: 'version', includeIfNull: false)
  final String version;
  @JsonKey(name: 'buildNumber', includeIfNull: false)
  final String? buildNumber;
  @JsonKey(
    name: 'status',
    includeIfNull: false,
    toJson: apiV1ReleasesPost$ResponseStatusToJson,
    fromJson: apiV1ReleasesPost$ResponseStatusFromJson,
  )
  final enums.ApiV1ReleasesPost$ResponseStatus status;
  @JsonKey(name: 'notes', includeIfNull: false)
  final String? notes;
  @JsonKey(name: 'publishedAt', includeIfNull: false)
  final String? publishedAt;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  static const fromJsonFactory = _$ApiV1ReleasesPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ReleasesPost$Response &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(
                  other.version,
                  version,
                )) &&
            (identical(other.buildNumber, buildNumber) ||
                const DeepCollectionEquality().equals(
                  other.buildNumber,
                  buildNumber,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.notes, notes) ||
                const DeepCollectionEquality().equals(other.notes, notes)) &&
            (identical(other.publishedAt, publishedAt) ||
                const DeepCollectionEquality().equals(
                  other.publishedAt,
                  publishedAt,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(version) ^
      const DeepCollectionEquality().hash(buildNumber) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(notes) ^
      const DeepCollectionEquality().hash(publishedAt) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $ApiV1ReleasesPost$ResponseExtension on ApiV1ReleasesPost$Response {
  ApiV1ReleasesPost$Response copyWith({
    String? id,
    String? appId,
    String? version,
    String? buildNumber,
    enums.ApiV1ReleasesPost$ResponseStatus? status,
    String? notes,
    String? publishedAt,
    String? createdAt,
  }) {
    return ApiV1ReleasesPost$Response(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  ApiV1ReleasesPost$Response copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? appId,
    Wrapped<String>? version,
    Wrapped<String?>? buildNumber,
    Wrapped<enums.ApiV1ReleasesPost$ResponseStatus>? status,
    Wrapped<String?>? notes,
    Wrapped<String?>? publishedAt,
    Wrapped<String>? createdAt,
  }) {
    return ApiV1ReleasesPost$Response(
      id: (id != null ? id.value : this.id),
      appId: (appId != null ? appId.value : this.appId),
      version: (version != null ? version.value : this.version),
      buildNumber: (buildNumber != null ? buildNumber.value : this.buildNumber),
      status: (status != null ? status.value : this.status),
      notes: (notes != null ? notes.value : this.notes),
      publishedAt: (publishedAt != null ? publishedAt.value : this.publishedAt),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ReleasesReleaseIdGet$Response {
  const ApiV1ReleasesReleaseIdGet$Response({
    required this.id,
    required this.appId,
    required this.version,
    required this.buildNumber,
    required this.status,
    required this.notes,
    required this.publishedAt,
    required this.createdAt,
    required this.artifacts,
  });

  factory ApiV1ReleasesReleaseIdGet$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1ReleasesReleaseIdGet$ResponseFromJson(json);

  static const toJsonFactory = _$ApiV1ReleasesReleaseIdGet$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1ReleasesReleaseIdGet$ResponseToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(name: 'version', includeIfNull: false)
  final String version;
  @JsonKey(name: 'buildNumber', includeIfNull: false)
  final String? buildNumber;
  @JsonKey(
    name: 'status',
    includeIfNull: false,
    toJson: apiV1ReleasesReleaseIdGet$ResponseStatusToJson,
    fromJson: apiV1ReleasesReleaseIdGet$ResponseStatusFromJson,
  )
  final enums.ApiV1ReleasesReleaseIdGet$ResponseStatus status;
  @JsonKey(name: 'notes', includeIfNull: false)
  final String? notes;
  @JsonKey(name: 'publishedAt', includeIfNull: false)
  final String? publishedAt;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  @JsonKey(name: 'artifacts', includeIfNull: false)
  final List<ApiV1ReleasesReleaseIdGet$Response$Artifacts$Item> artifacts;
  static const fromJsonFactory = _$ApiV1ReleasesReleaseIdGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ReleasesReleaseIdGet$Response &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(
                  other.version,
                  version,
                )) &&
            (identical(other.buildNumber, buildNumber) ||
                const DeepCollectionEquality().equals(
                  other.buildNumber,
                  buildNumber,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.notes, notes) ||
                const DeepCollectionEquality().equals(other.notes, notes)) &&
            (identical(other.publishedAt, publishedAt) ||
                const DeepCollectionEquality().equals(
                  other.publishedAt,
                  publishedAt,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.artifacts, artifacts) ||
                const DeepCollectionEquality().equals(
                  other.artifacts,
                  artifacts,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(version) ^
      const DeepCollectionEquality().hash(buildNumber) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(notes) ^
      const DeepCollectionEquality().hash(publishedAt) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(artifacts) ^
      runtimeType.hashCode;
}

extension $ApiV1ReleasesReleaseIdGet$ResponseExtension
    on ApiV1ReleasesReleaseIdGet$Response {
  ApiV1ReleasesReleaseIdGet$Response copyWith({
    String? id,
    String? appId,
    String? version,
    String? buildNumber,
    enums.ApiV1ReleasesReleaseIdGet$ResponseStatus? status,
    String? notes,
    String? publishedAt,
    String? createdAt,
    List<ApiV1ReleasesReleaseIdGet$Response$Artifacts$Item>? artifacts,
  }) {
    return ApiV1ReleasesReleaseIdGet$Response(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      artifacts: artifacts ?? this.artifacts,
    );
  }

  ApiV1ReleasesReleaseIdGet$Response copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? appId,
    Wrapped<String>? version,
    Wrapped<String?>? buildNumber,
    Wrapped<enums.ApiV1ReleasesReleaseIdGet$ResponseStatus>? status,
    Wrapped<String?>? notes,
    Wrapped<String?>? publishedAt,
    Wrapped<String>? createdAt,
    Wrapped<List<ApiV1ReleasesReleaseIdGet$Response$Artifacts$Item>>? artifacts,
  }) {
    return ApiV1ReleasesReleaseIdGet$Response(
      id: (id != null ? id.value : this.id),
      appId: (appId != null ? appId.value : this.appId),
      version: (version != null ? version.value : this.version),
      buildNumber: (buildNumber != null ? buildNumber.value : this.buildNumber),
      status: (status != null ? status.value : this.status),
      notes: (notes != null ? notes.value : this.notes),
      publishedAt: (publishedAt != null ? publishedAt.value : this.publishedAt),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      artifacts: (artifacts != null ? artifacts.value : this.artifacts),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ReleasesReleaseIdVerifyPost$Response {
  const ApiV1ReleasesReleaseIdVerifyPost$Response({
    required this.id,
    required this.appId,
    required this.version,
    required this.buildNumber,
    required this.status,
    required this.notes,
    required this.publishedAt,
    required this.createdAt,
  });

  factory ApiV1ReleasesReleaseIdVerifyPost$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1ReleasesReleaseIdVerifyPost$ResponseFromJson(json);

  static const toJsonFactory =
      _$ApiV1ReleasesReleaseIdVerifyPost$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1ReleasesReleaseIdVerifyPost$ResponseToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(name: 'version', includeIfNull: false)
  final String version;
  @JsonKey(name: 'buildNumber', includeIfNull: false)
  final String? buildNumber;
  @JsonKey(
    name: 'status',
    includeIfNull: false,
    toJson: apiV1ReleasesReleaseIdVerifyPost$ResponseStatusToJson,
    fromJson: apiV1ReleasesReleaseIdVerifyPost$ResponseStatusFromJson,
  )
  final enums.ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus status;
  @JsonKey(name: 'notes', includeIfNull: false)
  final String? notes;
  @JsonKey(name: 'publishedAt', includeIfNull: false)
  final String? publishedAt;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  static const fromJsonFactory =
      _$ApiV1ReleasesReleaseIdVerifyPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ReleasesReleaseIdVerifyPost$Response &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(
                  other.version,
                  version,
                )) &&
            (identical(other.buildNumber, buildNumber) ||
                const DeepCollectionEquality().equals(
                  other.buildNumber,
                  buildNumber,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.notes, notes) ||
                const DeepCollectionEquality().equals(other.notes, notes)) &&
            (identical(other.publishedAt, publishedAt) ||
                const DeepCollectionEquality().equals(
                  other.publishedAt,
                  publishedAt,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(version) ^
      const DeepCollectionEquality().hash(buildNumber) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(notes) ^
      const DeepCollectionEquality().hash(publishedAt) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $ApiV1ReleasesReleaseIdVerifyPost$ResponseExtension
    on ApiV1ReleasesReleaseIdVerifyPost$Response {
  ApiV1ReleasesReleaseIdVerifyPost$Response copyWith({
    String? id,
    String? appId,
    String? version,
    String? buildNumber,
    enums.ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus? status,
    String? notes,
    String? publishedAt,
    String? createdAt,
  }) {
    return ApiV1ReleasesReleaseIdVerifyPost$Response(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  ApiV1ReleasesReleaseIdVerifyPost$Response copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? appId,
    Wrapped<String>? version,
    Wrapped<String?>? buildNumber,
    Wrapped<enums.ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus>? status,
    Wrapped<String?>? notes,
    Wrapped<String?>? publishedAt,
    Wrapped<String>? createdAt,
  }) {
    return ApiV1ReleasesReleaseIdVerifyPost$Response(
      id: (id != null ? id.value : this.id),
      appId: (appId != null ? appId.value : this.appId),
      version: (version != null ? version.value : this.version),
      buildNumber: (buildNumber != null ? buildNumber.value : this.buildNumber),
      status: (status != null ? status.value : this.status),
      notes: (notes != null ? notes.value : this.notes),
      publishedAt: (publishedAt != null ? publishedAt.value : this.publishedAt),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ReleasesReleaseIdPublishPost$Response {
  const ApiV1ReleasesReleaseIdPublishPost$Response({
    required this.id,
    required this.appId,
    required this.version,
    required this.buildNumber,
    required this.status,
    required this.notes,
    required this.publishedAt,
    required this.createdAt,
  });

  factory ApiV1ReleasesReleaseIdPublishPost$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1ReleasesReleaseIdPublishPost$ResponseFromJson(json);

  static const toJsonFactory =
      _$ApiV1ReleasesReleaseIdPublishPost$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1ReleasesReleaseIdPublishPost$ResponseToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(name: 'version', includeIfNull: false)
  final String version;
  @JsonKey(name: 'buildNumber', includeIfNull: false)
  final String? buildNumber;
  @JsonKey(
    name: 'status',
    includeIfNull: false,
    toJson: apiV1ReleasesReleaseIdPublishPost$ResponseStatusToJson,
    fromJson: apiV1ReleasesReleaseIdPublishPost$ResponseStatusFromJson,
  )
  final enums.ApiV1ReleasesReleaseIdPublishPost$ResponseStatus status;
  @JsonKey(name: 'notes', includeIfNull: false)
  final String? notes;
  @JsonKey(name: 'publishedAt', includeIfNull: false)
  final String? publishedAt;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  static const fromJsonFactory =
      _$ApiV1ReleasesReleaseIdPublishPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ReleasesReleaseIdPublishPost$Response &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(
                  other.version,
                  version,
                )) &&
            (identical(other.buildNumber, buildNumber) ||
                const DeepCollectionEquality().equals(
                  other.buildNumber,
                  buildNumber,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.notes, notes) ||
                const DeepCollectionEquality().equals(other.notes, notes)) &&
            (identical(other.publishedAt, publishedAt) ||
                const DeepCollectionEquality().equals(
                  other.publishedAt,
                  publishedAt,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(version) ^
      const DeepCollectionEquality().hash(buildNumber) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(notes) ^
      const DeepCollectionEquality().hash(publishedAt) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $ApiV1ReleasesReleaseIdPublishPost$ResponseExtension
    on ApiV1ReleasesReleaseIdPublishPost$Response {
  ApiV1ReleasesReleaseIdPublishPost$Response copyWith({
    String? id,
    String? appId,
    String? version,
    String? buildNumber,
    enums.ApiV1ReleasesReleaseIdPublishPost$ResponseStatus? status,
    String? notes,
    String? publishedAt,
    String? createdAt,
  }) {
    return ApiV1ReleasesReleaseIdPublishPost$Response(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  ApiV1ReleasesReleaseIdPublishPost$Response copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? appId,
    Wrapped<String>? version,
    Wrapped<String?>? buildNumber,
    Wrapped<enums.ApiV1ReleasesReleaseIdPublishPost$ResponseStatus>? status,
    Wrapped<String?>? notes,
    Wrapped<String?>? publishedAt,
    Wrapped<String>? createdAt,
  }) {
    return ApiV1ReleasesReleaseIdPublishPost$Response(
      id: (id != null ? id.value : this.id),
      appId: (appId != null ? appId.value : this.appId),
      version: (version != null ? version.value : this.version),
      buildNumber: (buildNumber != null ? buildNumber.value : this.buildNumber),
      status: (status != null ? status.value : this.status),
      notes: (notes != null ? notes.value : this.notes),
      publishedAt: (publishedAt != null ? publishedAt.value : this.publishedAt),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ReleasesReleaseIdPromotePost$Response {
  const ApiV1ReleasesReleaseIdPromotePost$Response({
    required this.id,
    required this.channelId,
    required this.releaseId,
    this.platform,
    this.arch,
    required this.rolloutPercent,
    required this.createdAt,
  });

  factory ApiV1ReleasesReleaseIdPromotePost$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1ReleasesReleaseIdPromotePost$ResponseFromJson(json);

  static const toJsonFactory =
      _$ApiV1ReleasesReleaseIdPromotePost$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1ReleasesReleaseIdPromotePost$ResponseToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'channelId', includeIfNull: false)
  final String channelId;
  @JsonKey(name: 'releaseId', includeIfNull: false)
  final String releaseId;
  @JsonKey(
    name: 'platform',
    includeIfNull: false,
    toJson: apiV1ReleasesReleaseIdPromotePost$ResponsePlatformNullableToJson,
    fromJson:
        apiV1ReleasesReleaseIdPromotePost$ResponsePlatformNullableFromJson,
  )
  final enums.ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform? platform;
  @JsonKey(
    name: 'arch',
    includeIfNull: false,
    toJson: apiV1ReleasesReleaseIdPromotePost$ResponseArchNullableToJson,
    fromJson: apiV1ReleasesReleaseIdPromotePost$ResponseArchNullableFromJson,
  )
  final enums.ApiV1ReleasesReleaseIdPromotePost$ResponseArch? arch;
  @JsonKey(name: 'rolloutPercent', includeIfNull: false)
  final int rolloutPercent;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  static const fromJsonFactory =
      _$ApiV1ReleasesReleaseIdPromotePost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ReleasesReleaseIdPromotePost$Response &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.channelId, channelId) ||
                const DeepCollectionEquality().equals(
                  other.channelId,
                  channelId,
                )) &&
            (identical(other.releaseId, releaseId) ||
                const DeepCollectionEquality().equals(
                  other.releaseId,
                  releaseId,
                )) &&
            (identical(other.platform, platform) ||
                const DeepCollectionEquality().equals(
                  other.platform,
                  platform,
                )) &&
            (identical(other.arch, arch) ||
                const DeepCollectionEquality().equals(other.arch, arch)) &&
            (identical(other.rolloutPercent, rolloutPercent) ||
                const DeepCollectionEquality().equals(
                  other.rolloutPercent,
                  rolloutPercent,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(channelId) ^
      const DeepCollectionEquality().hash(releaseId) ^
      const DeepCollectionEquality().hash(platform) ^
      const DeepCollectionEquality().hash(arch) ^
      const DeepCollectionEquality().hash(rolloutPercent) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $ApiV1ReleasesReleaseIdPromotePost$ResponseExtension
    on ApiV1ReleasesReleaseIdPromotePost$Response {
  ApiV1ReleasesReleaseIdPromotePost$Response copyWith({
    String? id,
    String? channelId,
    String? releaseId,
    enums.ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform? platform,
    enums.ApiV1ReleasesReleaseIdPromotePost$ResponseArch? arch,
    int? rolloutPercent,
    String? createdAt,
  }) {
    return ApiV1ReleasesReleaseIdPromotePost$Response(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      releaseId: releaseId ?? this.releaseId,
      platform: platform ?? this.platform,
      arch: arch ?? this.arch,
      rolloutPercent: rolloutPercent ?? this.rolloutPercent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  ApiV1ReleasesReleaseIdPromotePost$Response copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? channelId,
    Wrapped<String>? releaseId,
    Wrapped<enums.ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform?>?
    platform,
    Wrapped<enums.ApiV1ReleasesReleaseIdPromotePost$ResponseArch?>? arch,
    Wrapped<int>? rolloutPercent,
    Wrapped<String>? createdAt,
  }) {
    return ApiV1ReleasesReleaseIdPromotePost$Response(
      id: (id != null ? id.value : this.id),
      channelId: (channelId != null ? channelId.value : this.channelId),
      releaseId: (releaseId != null ? releaseId.value : this.releaseId),
      platform: (platform != null ? platform.value : this.platform),
      arch: (arch != null ? arch.value : this.arch),
      rolloutPercent: (rolloutPercent != null
          ? rolloutPercent.value
          : this.rolloutPercent),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ArtifactsUploadUrlPost$Response {
  const ApiV1ArtifactsUploadUrlPost$Response({
    required this.artifactId,
    required this.uploadUrl,
    required this.s3Key,
    required this.expiresAt,
    required this.releaseId,
    required this.releaseCreated,
  });

  factory ApiV1ArtifactsUploadUrlPost$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1ArtifactsUploadUrlPost$ResponseFromJson(json);

  static const toJsonFactory = _$ApiV1ArtifactsUploadUrlPost$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1ArtifactsUploadUrlPost$ResponseToJson(this);

  @JsonKey(name: 'artifactId', includeIfNull: false)
  final String artifactId;
  @JsonKey(name: 'uploadUrl', includeIfNull: false)
  final String uploadUrl;
  @JsonKey(name: 's3Key', includeIfNull: false)
  final String s3Key;
  @JsonKey(name: 'expiresAt', includeIfNull: false)
  final String expiresAt;
  @JsonKey(name: 'releaseId', includeIfNull: false)
  final String releaseId;
  @JsonKey(name: 'releaseCreated', includeIfNull: false)
  final bool releaseCreated;
  static const fromJsonFactory = _$ApiV1ArtifactsUploadUrlPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ArtifactsUploadUrlPost$Response &&
            (identical(other.artifactId, artifactId) ||
                const DeepCollectionEquality().equals(
                  other.artifactId,
                  artifactId,
                )) &&
            (identical(other.uploadUrl, uploadUrl) ||
                const DeepCollectionEquality().equals(
                  other.uploadUrl,
                  uploadUrl,
                )) &&
            (identical(other.s3Key, s3Key) ||
                const DeepCollectionEquality().equals(other.s3Key, s3Key)) &&
            (identical(other.expiresAt, expiresAt) ||
                const DeepCollectionEquality().equals(
                  other.expiresAt,
                  expiresAt,
                )) &&
            (identical(other.releaseId, releaseId) ||
                const DeepCollectionEquality().equals(
                  other.releaseId,
                  releaseId,
                )) &&
            (identical(other.releaseCreated, releaseCreated) ||
                const DeepCollectionEquality().equals(
                  other.releaseCreated,
                  releaseCreated,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(artifactId) ^
      const DeepCollectionEquality().hash(uploadUrl) ^
      const DeepCollectionEquality().hash(s3Key) ^
      const DeepCollectionEquality().hash(expiresAt) ^
      const DeepCollectionEquality().hash(releaseId) ^
      const DeepCollectionEquality().hash(releaseCreated) ^
      runtimeType.hashCode;
}

extension $ApiV1ArtifactsUploadUrlPost$ResponseExtension
    on ApiV1ArtifactsUploadUrlPost$Response {
  ApiV1ArtifactsUploadUrlPost$Response copyWith({
    String? artifactId,
    String? uploadUrl,
    String? s3Key,
    String? expiresAt,
    String? releaseId,
    bool? releaseCreated,
  }) {
    return ApiV1ArtifactsUploadUrlPost$Response(
      artifactId: artifactId ?? this.artifactId,
      uploadUrl: uploadUrl ?? this.uploadUrl,
      s3Key: s3Key ?? this.s3Key,
      expiresAt: expiresAt ?? this.expiresAt,
      releaseId: releaseId ?? this.releaseId,
      releaseCreated: releaseCreated ?? this.releaseCreated,
    );
  }

  ApiV1ArtifactsUploadUrlPost$Response copyWithWrapped({
    Wrapped<String>? artifactId,
    Wrapped<String>? uploadUrl,
    Wrapped<String>? s3Key,
    Wrapped<String>? expiresAt,
    Wrapped<String>? releaseId,
    Wrapped<bool>? releaseCreated,
  }) {
    return ApiV1ArtifactsUploadUrlPost$Response(
      artifactId: (artifactId != null ? artifactId.value : this.artifactId),
      uploadUrl: (uploadUrl != null ? uploadUrl.value : this.uploadUrl),
      s3Key: (s3Key != null ? s3Key.value : this.s3Key),
      expiresAt: (expiresAt != null ? expiresAt.value : this.expiresAt),
      releaseId: (releaseId != null ? releaseId.value : this.releaseId),
      releaseCreated: (releaseCreated != null
          ? releaseCreated.value
          : this.releaseCreated),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$Response {
  const ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$Response({
    required this.artifactId,
    required this.uploadUrl,
    required this.s3Key,
    required this.expiresAt,
  });

  factory ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$ResponseFromJson(json);

  static const toJsonFactory =
      _$ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$ResponseToJson(this);

  @JsonKey(name: 'artifactId', includeIfNull: false)
  final String artifactId;
  @JsonKey(name: 'uploadUrl', includeIfNull: false)
  final String uploadUrl;
  @JsonKey(name: 's3Key', includeIfNull: false)
  final String s3Key;
  @JsonKey(name: 'expiresAt', includeIfNull: false)
  final String expiresAt;
  static const fromJsonFactory =
      _$ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$Response &&
            (identical(other.artifactId, artifactId) ||
                const DeepCollectionEquality().equals(
                  other.artifactId,
                  artifactId,
                )) &&
            (identical(other.uploadUrl, uploadUrl) ||
                const DeepCollectionEquality().equals(
                  other.uploadUrl,
                  uploadUrl,
                )) &&
            (identical(other.s3Key, s3Key) ||
                const DeepCollectionEquality().equals(other.s3Key, s3Key)) &&
            (identical(other.expiresAt, expiresAt) ||
                const DeepCollectionEquality().equals(
                  other.expiresAt,
                  expiresAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(artifactId) ^
      const DeepCollectionEquality().hash(uploadUrl) ^
      const DeepCollectionEquality().hash(s3Key) ^
      const DeepCollectionEquality().hash(expiresAt) ^
      runtimeType.hashCode;
}

extension $ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$ResponseExtension
    on ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$Response {
  ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$Response copyWith({
    String? artifactId,
    String? uploadUrl,
    String? s3Key,
    String? expiresAt,
  }) {
    return ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$Response(
      artifactId: artifactId ?? this.artifactId,
      uploadUrl: uploadUrl ?? this.uploadUrl,
      s3Key: s3Key ?? this.s3Key,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$Response copyWithWrapped({
    Wrapped<String>? artifactId,
    Wrapped<String>? uploadUrl,
    Wrapped<String>? s3Key,
    Wrapped<String>? expiresAt,
  }) {
    return ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$Response(
      artifactId: (artifactId != null ? artifactId.value : this.artifactId),
      uploadUrl: (uploadUrl != null ? uploadUrl.value : this.uploadUrl),
      s3Key: (s3Key != null ? s3Key.value : this.s3Key),
      expiresAt: (expiresAt != null ? expiresAt.value : this.expiresAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1MetricsDownloadsGet$Response {
  const ApiV1MetricsDownloadsGet$Response({required this.series});

  factory ApiV1MetricsDownloadsGet$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1MetricsDownloadsGet$ResponseFromJson(json);

  static const toJsonFactory = _$ApiV1MetricsDownloadsGet$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1MetricsDownloadsGet$ResponseToJson(this);

  @JsonKey(name: 'series', includeIfNull: false)
  final List<ApiV1MetricsDownloadsGet$Response$Series$Item> series;
  static const fromJsonFactory = _$ApiV1MetricsDownloadsGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1MetricsDownloadsGet$Response &&
            (identical(other.series, series) ||
                const DeepCollectionEquality().equals(other.series, series)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(series) ^ runtimeType.hashCode;
}

extension $ApiV1MetricsDownloadsGet$ResponseExtension
    on ApiV1MetricsDownloadsGet$Response {
  ApiV1MetricsDownloadsGet$Response copyWith({
    List<ApiV1MetricsDownloadsGet$Response$Series$Item>? series,
  }) {
    return ApiV1MetricsDownloadsGet$Response(series: series ?? this.series);
  }

  ApiV1MetricsDownloadsGet$Response copyWithWrapped({
    Wrapped<List<ApiV1MetricsDownloadsGet$Response$Series$Item>>? series,
  }) {
    return ApiV1MetricsDownloadsGet$Response(
      series: (series != null ? series.value : this.series),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1MetricsUpdateChecksGet$Response {
  const ApiV1MetricsUpdateChecksGet$Response({required this.series});

  factory ApiV1MetricsUpdateChecksGet$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1MetricsUpdateChecksGet$ResponseFromJson(json);

  static const toJsonFactory = _$ApiV1MetricsUpdateChecksGet$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1MetricsUpdateChecksGet$ResponseToJson(this);

  @JsonKey(name: 'series', includeIfNull: false)
  final List<ApiV1MetricsUpdateChecksGet$Response$Series$Item> series;
  static const fromJsonFactory = _$ApiV1MetricsUpdateChecksGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1MetricsUpdateChecksGet$Response &&
            (identical(other.series, series) ||
                const DeepCollectionEquality().equals(other.series, series)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(series) ^ runtimeType.hashCode;
}

extension $ApiV1MetricsUpdateChecksGet$ResponseExtension
    on ApiV1MetricsUpdateChecksGet$Response {
  ApiV1MetricsUpdateChecksGet$Response copyWith({
    List<ApiV1MetricsUpdateChecksGet$Response$Series$Item>? series,
  }) {
    return ApiV1MetricsUpdateChecksGet$Response(series: series ?? this.series);
  }

  ApiV1MetricsUpdateChecksGet$Response copyWithWrapped({
    Wrapped<List<ApiV1MetricsUpdateChecksGet$Response$Series$Item>>? series,
  }) {
    return ApiV1MetricsUpdateChecksGet$Response(
      series: (series != null ? series.value : this.series),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1DashboardSummaryGet$Response {
  const ApiV1DashboardSummaryGet$Response({
    required this.generatedAt,
    required this.totals,
    required this.apps,
    required this.activeAssignments,
  });

  factory ApiV1DashboardSummaryGet$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1DashboardSummaryGet$ResponseFromJson(json);

  static const toJsonFactory = _$ApiV1DashboardSummaryGet$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1DashboardSummaryGet$ResponseToJson(this);

  @JsonKey(name: 'generatedAt', includeIfNull: false)
  final String generatedAt;
  @JsonKey(name: 'totals', includeIfNull: false)
  final ApiV1DashboardSummaryGet$Response$Totals totals;
  @JsonKey(name: 'apps', includeIfNull: false)
  final List<ApiV1DashboardSummaryGet$Response$Apps$Item> apps;
  @JsonKey(name: 'activeAssignments', includeIfNull: false)
  final List<ApiV1DashboardSummaryGet$Response$ActiveAssignments$Item>
  activeAssignments;
  static const fromJsonFactory = _$ApiV1DashboardSummaryGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1DashboardSummaryGet$Response &&
            (identical(other.generatedAt, generatedAt) ||
                const DeepCollectionEquality().equals(
                  other.generatedAt,
                  generatedAt,
                )) &&
            (identical(other.totals, totals) ||
                const DeepCollectionEquality().equals(other.totals, totals)) &&
            (identical(other.apps, apps) ||
                const DeepCollectionEquality().equals(other.apps, apps)) &&
            (identical(other.activeAssignments, activeAssignments) ||
                const DeepCollectionEquality().equals(
                  other.activeAssignments,
                  activeAssignments,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(generatedAt) ^
      const DeepCollectionEquality().hash(totals) ^
      const DeepCollectionEquality().hash(apps) ^
      const DeepCollectionEquality().hash(activeAssignments) ^
      runtimeType.hashCode;
}

extension $ApiV1DashboardSummaryGet$ResponseExtension
    on ApiV1DashboardSummaryGet$Response {
  ApiV1DashboardSummaryGet$Response copyWith({
    String? generatedAt,
    ApiV1DashboardSummaryGet$Response$Totals? totals,
    List<ApiV1DashboardSummaryGet$Response$Apps$Item>? apps,
    List<ApiV1DashboardSummaryGet$Response$ActiveAssignments$Item>?
    activeAssignments,
  }) {
    return ApiV1DashboardSummaryGet$Response(
      generatedAt: generatedAt ?? this.generatedAt,
      totals: totals ?? this.totals,
      apps: apps ?? this.apps,
      activeAssignments: activeAssignments ?? this.activeAssignments,
    );
  }

  ApiV1DashboardSummaryGet$Response copyWithWrapped({
    Wrapped<String>? generatedAt,
    Wrapped<ApiV1DashboardSummaryGet$Response$Totals>? totals,
    Wrapped<List<ApiV1DashboardSummaryGet$Response$Apps$Item>>? apps,
    Wrapped<List<ApiV1DashboardSummaryGet$Response$ActiveAssignments$Item>>?
    activeAssignments,
  }) {
    return ApiV1DashboardSummaryGet$Response(
      generatedAt: (generatedAt != null ? generatedAt.value : this.generatedAt),
      totals: (totals != null ? totals.value : this.totals),
      apps: (apps != null ? apps.value : this.apps),
      activeAssignments: (activeAssignments != null
          ? activeAssignments.value
          : this.activeAssignments),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$Item {
  const ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$Item({
    required this.channelId,
    this.platform,
    this.arch,
    this.rolloutPercent,
  });

  factory ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemFromJson(
    json,
  );

  static const toJsonFactory =
      _$ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemToJson(this);

  @JsonKey(name: 'channelId', includeIfNull: false)
  final String channelId;
  @JsonKey(
    name: 'platform',
    includeIfNull: false,
    toJson:
        apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatformNullableToJson,
    fromJson:
        apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatformNullableFromJson,
  )
  final enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform?
  platform;
  @JsonKey(
    name: 'arch',
    includeIfNull: false,
    toJson:
        apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArchNullableToJson,
    fromJson:
        apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArchNullableFromJson,
  )
  final enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch?
  arch;
  @JsonKey(name: 'rolloutPercent', includeIfNull: false)
  final int? rolloutPercent;
  static const fromJsonFactory =
      _$ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$Item &&
            (identical(other.channelId, channelId) ||
                const DeepCollectionEquality().equals(
                  other.channelId,
                  channelId,
                )) &&
            (identical(other.platform, platform) ||
                const DeepCollectionEquality().equals(
                  other.platform,
                  platform,
                )) &&
            (identical(other.arch, arch) ||
                const DeepCollectionEquality().equals(other.arch, arch)) &&
            (identical(other.rolloutPercent, rolloutPercent) ||
                const DeepCollectionEquality().equals(
                  other.rolloutPercent,
                  rolloutPercent,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(channelId) ^
      const DeepCollectionEquality().hash(platform) ^
      const DeepCollectionEquality().hash(arch) ^
      const DeepCollectionEquality().hash(rolloutPercent) ^
      runtimeType.hashCode;
}

extension $ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemExtension
    on ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$Item {
  ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$Item copyWith({
    String? channelId,
    enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform?
    platform,
    enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch? arch,
    int? rolloutPercent,
  }) {
    return ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$Item(
      channelId: channelId ?? this.channelId,
      platform: platform ?? this.platform,
      arch: arch ?? this.arch,
      rolloutPercent: rolloutPercent ?? this.rolloutPercent,
    );
  }

  ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$Item copyWithWrapped({
    Wrapped<String>? channelId,
    Wrapped<
      enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform?
    >?
    platform,
    Wrapped<
      enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch?
    >?
    arch,
    Wrapped<int?>? rolloutPercent,
  }) {
    return ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$Item(
      channelId: (channelId != null ? channelId.value : this.channelId),
      platform: (platform != null ? platform.value : this.platform),
      arch: (arch != null ? arch.value : this.arch),
      rolloutPercent: (rolloutPercent != null
          ? rolloutPercent.value
          : this.rolloutPercent),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ApiKeysPost$Response$ApiKey {
  const ApiV1ApiKeysPost$Response$ApiKey({
    required this.id,
    required this.name,
    required this.tokenId,
    required this.keyPrefix,
    required this.createdByUserId,
    required this.createdAt,
    required this.lastUsedAt,
    required this.revokedAt,
    required this.revokedByUserId,
  });

  factory ApiV1ApiKeysPost$Response$ApiKey.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1ApiKeysPost$Response$ApiKeyFromJson(json);

  static const toJsonFactory = _$ApiV1ApiKeysPost$Response$ApiKeyToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1ApiKeysPost$Response$ApiKeyToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'tokenId', includeIfNull: false)
  final String tokenId;
  @JsonKey(name: 'keyPrefix', includeIfNull: false)
  final String keyPrefix;
  @JsonKey(name: 'createdByUserId', includeIfNull: false)
  final String? createdByUserId;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  @JsonKey(name: 'lastUsedAt', includeIfNull: false)
  final String? lastUsedAt;
  @JsonKey(name: 'revokedAt', includeIfNull: false)
  final String? revokedAt;
  @JsonKey(name: 'revokedByUserId', includeIfNull: false)
  final String? revokedByUserId;
  static const fromJsonFactory = _$ApiV1ApiKeysPost$Response$ApiKeyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ApiKeysPost$Response$ApiKey &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.tokenId, tokenId) ||
                const DeepCollectionEquality().equals(
                  other.tokenId,
                  tokenId,
                )) &&
            (identical(other.keyPrefix, keyPrefix) ||
                const DeepCollectionEquality().equals(
                  other.keyPrefix,
                  keyPrefix,
                )) &&
            (identical(other.createdByUserId, createdByUserId) ||
                const DeepCollectionEquality().equals(
                  other.createdByUserId,
                  createdByUserId,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.lastUsedAt, lastUsedAt) ||
                const DeepCollectionEquality().equals(
                  other.lastUsedAt,
                  lastUsedAt,
                )) &&
            (identical(other.revokedAt, revokedAt) ||
                const DeepCollectionEquality().equals(
                  other.revokedAt,
                  revokedAt,
                )) &&
            (identical(other.revokedByUserId, revokedByUserId) ||
                const DeepCollectionEquality().equals(
                  other.revokedByUserId,
                  revokedByUserId,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(tokenId) ^
      const DeepCollectionEquality().hash(keyPrefix) ^
      const DeepCollectionEquality().hash(createdByUserId) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(lastUsedAt) ^
      const DeepCollectionEquality().hash(revokedAt) ^
      const DeepCollectionEquality().hash(revokedByUserId) ^
      runtimeType.hashCode;
}

extension $ApiV1ApiKeysPost$Response$ApiKeyExtension
    on ApiV1ApiKeysPost$Response$ApiKey {
  ApiV1ApiKeysPost$Response$ApiKey copyWith({
    String? id,
    String? name,
    String? tokenId,
    String? keyPrefix,
    String? createdByUserId,
    String? createdAt,
    String? lastUsedAt,
    String? revokedAt,
    String? revokedByUserId,
  }) {
    return ApiV1ApiKeysPost$Response$ApiKey(
      id: id ?? this.id,
      name: name ?? this.name,
      tokenId: tokenId ?? this.tokenId,
      keyPrefix: keyPrefix ?? this.keyPrefix,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      revokedAt: revokedAt ?? this.revokedAt,
      revokedByUserId: revokedByUserId ?? this.revokedByUserId,
    );
  }

  ApiV1ApiKeysPost$Response$ApiKey copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? name,
    Wrapped<String>? tokenId,
    Wrapped<String>? keyPrefix,
    Wrapped<String?>? createdByUserId,
    Wrapped<String>? createdAt,
    Wrapped<String?>? lastUsedAt,
    Wrapped<String?>? revokedAt,
    Wrapped<String?>? revokedByUserId,
  }) {
    return ApiV1ApiKeysPost$Response$ApiKey(
      id: (id != null ? id.value : this.id),
      name: (name != null ? name.value : this.name),
      tokenId: (tokenId != null ? tokenId.value : this.tokenId),
      keyPrefix: (keyPrefix != null ? keyPrefix.value : this.keyPrefix),
      createdByUserId: (createdByUserId != null
          ? createdByUserId.value
          : this.createdByUserId),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      lastUsedAt: (lastUsedAt != null ? lastUsedAt.value : this.lastUsedAt),
      revokedAt: (revokedAt != null ? revokedAt.value : this.revokedAt),
      revokedByUserId: (revokedByUserId != null
          ? revokedByUserId.value
          : this.revokedByUserId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$Item {
  const ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$Item({
    required this.id,
    required this.pipelineRunId,
    required this.buildProfileId,
    required this.platform,
    required this.packageType,
    this.arch,
    required this.status,
    required this.externalJobId,
    required this.artifactId,
    required this.deploymentTargetId,
    this.deploymentStatus,
    required this.logsUrl,
    required this.errorMessage,
    required this.startedAt,
    required this.finishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemFromJson(json);

  static const toJsonFactory =
      _$ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'pipelineRunId', includeIfNull: false)
  final String pipelineRunId;
  @JsonKey(name: 'buildProfileId', includeIfNull: false)
  final String? buildProfileId;
  @JsonKey(
    name: 'platform',
    includeIfNull: false,
    toJson: apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatformToJson,
    fromJson: apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatformFromJson,
  )
  final enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform
  platform;
  @JsonKey(name: 'packageType', includeIfNull: false)
  final String packageType;
  @JsonKey(
    name: 'arch',
    includeIfNull: false,
    toJson: apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArchNullableToJson,
    fromJson:
        apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArchNullableFromJson,
  )
  final enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch? arch;
  @JsonKey(
    name: 'status',
    includeIfNull: false,
    toJson: apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatusToJson,
    fromJson: apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatusFromJson,
  )
  final enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus status;
  @JsonKey(name: 'externalJobId', includeIfNull: false)
  final String? externalJobId;
  @JsonKey(name: 'artifactId', includeIfNull: false)
  final String? artifactId;
  @JsonKey(name: 'deploymentTargetId', includeIfNull: false)
  final String? deploymentTargetId;
  @JsonKey(
    name: 'deploymentStatus',
    includeIfNull: false,
    toJson:
        apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatusNullableToJson,
    fromJson:
        apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatusNullableFromJson,
  )
  final enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus?
  deploymentStatus;
  @JsonKey(name: 'logsUrl', includeIfNull: false)
  final String? logsUrl;
  @JsonKey(name: 'errorMessage', includeIfNull: false)
  final String? errorMessage;
  @JsonKey(name: 'startedAt', includeIfNull: false)
  final String? startedAt;
  @JsonKey(name: 'finishedAt', includeIfNull: false)
  final String? finishedAt;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  final String updatedAt;
  static const fromJsonFactory =
      _$ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$Item &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.pipelineRunId, pipelineRunId) ||
                const DeepCollectionEquality().equals(
                  other.pipelineRunId,
                  pipelineRunId,
                )) &&
            (identical(other.buildProfileId, buildProfileId) ||
                const DeepCollectionEquality().equals(
                  other.buildProfileId,
                  buildProfileId,
                )) &&
            (identical(other.platform, platform) ||
                const DeepCollectionEquality().equals(
                  other.platform,
                  platform,
                )) &&
            (identical(other.packageType, packageType) ||
                const DeepCollectionEquality().equals(
                  other.packageType,
                  packageType,
                )) &&
            (identical(other.arch, arch) ||
                const DeepCollectionEquality().equals(other.arch, arch)) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.externalJobId, externalJobId) ||
                const DeepCollectionEquality().equals(
                  other.externalJobId,
                  externalJobId,
                )) &&
            (identical(other.artifactId, artifactId) ||
                const DeepCollectionEquality().equals(
                  other.artifactId,
                  artifactId,
                )) &&
            (identical(other.deploymentTargetId, deploymentTargetId) ||
                const DeepCollectionEquality().equals(
                  other.deploymentTargetId,
                  deploymentTargetId,
                )) &&
            (identical(other.deploymentStatus, deploymentStatus) ||
                const DeepCollectionEquality().equals(
                  other.deploymentStatus,
                  deploymentStatus,
                )) &&
            (identical(other.logsUrl, logsUrl) ||
                const DeepCollectionEquality().equals(
                  other.logsUrl,
                  logsUrl,
                )) &&
            (identical(other.errorMessage, errorMessage) ||
                const DeepCollectionEquality().equals(
                  other.errorMessage,
                  errorMessage,
                )) &&
            (identical(other.startedAt, startedAt) ||
                const DeepCollectionEquality().equals(
                  other.startedAt,
                  startedAt,
                )) &&
            (identical(other.finishedAt, finishedAt) ||
                const DeepCollectionEquality().equals(
                  other.finishedAt,
                  finishedAt,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(pipelineRunId) ^
      const DeepCollectionEquality().hash(buildProfileId) ^
      const DeepCollectionEquality().hash(platform) ^
      const DeepCollectionEquality().hash(packageType) ^
      const DeepCollectionEquality().hash(arch) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(externalJobId) ^
      const DeepCollectionEquality().hash(artifactId) ^
      const DeepCollectionEquality().hash(deploymentTargetId) ^
      const DeepCollectionEquality().hash(deploymentStatus) ^
      const DeepCollectionEquality().hash(logsUrl) ^
      const DeepCollectionEquality().hash(errorMessage) ^
      const DeepCollectionEquality().hash(startedAt) ^
      const DeepCollectionEquality().hash(finishedAt) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemExtension
    on ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$Item {
  ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$Item copyWith({
    String? id,
    String? pipelineRunId,
    String? buildProfileId,
    enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform? platform,
    String? packageType,
    enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch? arch,
    enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus? status,
    String? externalJobId,
    String? artifactId,
    String? deploymentTargetId,
    enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus?
    deploymentStatus,
    String? logsUrl,
    String? errorMessage,
    String? startedAt,
    String? finishedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$Item(
      id: id ?? this.id,
      pipelineRunId: pipelineRunId ?? this.pipelineRunId,
      buildProfileId: buildProfileId ?? this.buildProfileId,
      platform: platform ?? this.platform,
      packageType: packageType ?? this.packageType,
      arch: arch ?? this.arch,
      status: status ?? this.status,
      externalJobId: externalJobId ?? this.externalJobId,
      artifactId: artifactId ?? this.artifactId,
      deploymentTargetId: deploymentTargetId ?? this.deploymentTargetId,
      deploymentStatus: deploymentStatus ?? this.deploymentStatus,
      logsUrl: logsUrl ?? this.logsUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$Item copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? pipelineRunId,
    Wrapped<String?>? buildProfileId,
    Wrapped<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform>?
    platform,
    Wrapped<String>? packageType,
    Wrapped<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch?>? arch,
    Wrapped<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus>?
    status,
    Wrapped<String?>? externalJobId,
    Wrapped<String?>? artifactId,
    Wrapped<String?>? deploymentTargetId,
    Wrapped<
      enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus?
    >?
    deploymentStatus,
    Wrapped<String?>? logsUrl,
    Wrapped<String?>? errorMessage,
    Wrapped<String?>? startedAt,
    Wrapped<String?>? finishedAt,
    Wrapped<String>? createdAt,
    Wrapped<String>? updatedAt,
  }) {
    return ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$Item(
      id: (id != null ? id.value : this.id),
      pipelineRunId: (pipelineRunId != null
          ? pipelineRunId.value
          : this.pipelineRunId),
      buildProfileId: (buildProfileId != null
          ? buildProfileId.value
          : this.buildProfileId),
      platform: (platform != null ? platform.value : this.platform),
      packageType: (packageType != null ? packageType.value : this.packageType),
      arch: (arch != null ? arch.value : this.arch),
      status: (status != null ? status.value : this.status),
      externalJobId: (externalJobId != null
          ? externalJobId.value
          : this.externalJobId),
      artifactId: (artifactId != null ? artifactId.value : this.artifactId),
      deploymentTargetId: (deploymentTargetId != null
          ? deploymentTargetId.value
          : this.deploymentTargetId),
      deploymentStatus: (deploymentStatus != null
          ? deploymentStatus.value
          : this.deploymentStatus),
      logsUrl: (logsUrl != null ? logsUrl.value : this.logsUrl),
      errorMessage: (errorMessage != null
          ? errorMessage.value
          : this.errorMessage),
      startedAt: (startedAt != null ? startedAt.value : this.startedAt),
      finishedAt: (finishedAt != null ? finishedAt.value : this.finishedAt),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$Item {
  const ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$Item({
    required this.id,
    required this.pipelineRunId,
    required this.buildProfileId,
    required this.platform,
    required this.packageType,
    this.arch,
    required this.status,
    required this.externalJobId,
    required this.artifactId,
    required this.deploymentTargetId,
    this.deploymentStatus,
    required this.logsUrl,
    required this.errorMessage,
    required this.startedAt,
    required this.finishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemFromJson(json);

  static const toJsonFactory =
      _$ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'pipelineRunId', includeIfNull: false)
  final String pipelineRunId;
  @JsonKey(name: 'buildProfileId', includeIfNull: false)
  final String? buildProfileId;
  @JsonKey(
    name: 'platform',
    includeIfNull: false,
    toJson: apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatformToJson,
    fromJson:
        apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatformFromJson,
  )
  final enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform
  platform;
  @JsonKey(name: 'packageType', includeIfNull: false)
  final String packageType;
  @JsonKey(
    name: 'arch',
    includeIfNull: false,
    toJson:
        apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArchNullableToJson,
    fromJson:
        apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArchNullableFromJson,
  )
  final enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch? arch;
  @JsonKey(
    name: 'status',
    includeIfNull: false,
    toJson: apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatusToJson,
    fromJson:
        apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatusFromJson,
  )
  final enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus status;
  @JsonKey(name: 'externalJobId', includeIfNull: false)
  final String? externalJobId;
  @JsonKey(name: 'artifactId', includeIfNull: false)
  final String? artifactId;
  @JsonKey(name: 'deploymentTargetId', includeIfNull: false)
  final String? deploymentTargetId;
  @JsonKey(
    name: 'deploymentStatus',
    includeIfNull: false,
    toJson:
        apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatusNullableToJson,
    fromJson:
        apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatusNullableFromJson,
  )
  final enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus?
  deploymentStatus;
  @JsonKey(name: 'logsUrl', includeIfNull: false)
  final String? logsUrl;
  @JsonKey(name: 'errorMessage', includeIfNull: false)
  final String? errorMessage;
  @JsonKey(name: 'startedAt', includeIfNull: false)
  final String? startedAt;
  @JsonKey(name: 'finishedAt', includeIfNull: false)
  final String? finishedAt;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  final String updatedAt;
  static const fromJsonFactory =
      _$ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$Item &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.pipelineRunId, pipelineRunId) ||
                const DeepCollectionEquality().equals(
                  other.pipelineRunId,
                  pipelineRunId,
                )) &&
            (identical(other.buildProfileId, buildProfileId) ||
                const DeepCollectionEquality().equals(
                  other.buildProfileId,
                  buildProfileId,
                )) &&
            (identical(other.platform, platform) ||
                const DeepCollectionEquality().equals(
                  other.platform,
                  platform,
                )) &&
            (identical(other.packageType, packageType) ||
                const DeepCollectionEquality().equals(
                  other.packageType,
                  packageType,
                )) &&
            (identical(other.arch, arch) ||
                const DeepCollectionEquality().equals(other.arch, arch)) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.externalJobId, externalJobId) ||
                const DeepCollectionEquality().equals(
                  other.externalJobId,
                  externalJobId,
                )) &&
            (identical(other.artifactId, artifactId) ||
                const DeepCollectionEquality().equals(
                  other.artifactId,
                  artifactId,
                )) &&
            (identical(other.deploymentTargetId, deploymentTargetId) ||
                const DeepCollectionEquality().equals(
                  other.deploymentTargetId,
                  deploymentTargetId,
                )) &&
            (identical(other.deploymentStatus, deploymentStatus) ||
                const DeepCollectionEquality().equals(
                  other.deploymentStatus,
                  deploymentStatus,
                )) &&
            (identical(other.logsUrl, logsUrl) ||
                const DeepCollectionEquality().equals(
                  other.logsUrl,
                  logsUrl,
                )) &&
            (identical(other.errorMessage, errorMessage) ||
                const DeepCollectionEquality().equals(
                  other.errorMessage,
                  errorMessage,
                )) &&
            (identical(other.startedAt, startedAt) ||
                const DeepCollectionEquality().equals(
                  other.startedAt,
                  startedAt,
                )) &&
            (identical(other.finishedAt, finishedAt) ||
                const DeepCollectionEquality().equals(
                  other.finishedAt,
                  finishedAt,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(pipelineRunId) ^
      const DeepCollectionEquality().hash(buildProfileId) ^
      const DeepCollectionEquality().hash(platform) ^
      const DeepCollectionEquality().hash(packageType) ^
      const DeepCollectionEquality().hash(arch) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(externalJobId) ^
      const DeepCollectionEquality().hash(artifactId) ^
      const DeepCollectionEquality().hash(deploymentTargetId) ^
      const DeepCollectionEquality().hash(deploymentStatus) ^
      const DeepCollectionEquality().hash(logsUrl) ^
      const DeepCollectionEquality().hash(errorMessage) ^
      const DeepCollectionEquality().hash(startedAt) ^
      const DeepCollectionEquality().hash(finishedAt) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemExtension
    on ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$Item {
  ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$Item copyWith({
    String? id,
    String? pipelineRunId,
    String? buildProfileId,
    enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform?
    platform,
    String? packageType,
    enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch? arch,
    enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus? status,
    String? externalJobId,
    String? artifactId,
    String? deploymentTargetId,
    enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus?
    deploymentStatus,
    String? logsUrl,
    String? errorMessage,
    String? startedAt,
    String? finishedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$Item(
      id: id ?? this.id,
      pipelineRunId: pipelineRunId ?? this.pipelineRunId,
      buildProfileId: buildProfileId ?? this.buildProfileId,
      platform: platform ?? this.platform,
      packageType: packageType ?? this.packageType,
      arch: arch ?? this.arch,
      status: status ?? this.status,
      externalJobId: externalJobId ?? this.externalJobId,
      artifactId: artifactId ?? this.artifactId,
      deploymentTargetId: deploymentTargetId ?? this.deploymentTargetId,
      deploymentStatus: deploymentStatus ?? this.deploymentStatus,
      logsUrl: logsUrl ?? this.logsUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$Item copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? pipelineRunId,
    Wrapped<String?>? buildProfileId,
    Wrapped<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform>?
    platform,
    Wrapped<String>? packageType,
    Wrapped<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch?>?
    arch,
    Wrapped<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus>?
    status,
    Wrapped<String?>? externalJobId,
    Wrapped<String?>? artifactId,
    Wrapped<String?>? deploymentTargetId,
    Wrapped<
      enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus?
    >?
    deploymentStatus,
    Wrapped<String?>? logsUrl,
    Wrapped<String?>? errorMessage,
    Wrapped<String?>? startedAt,
    Wrapped<String?>? finishedAt,
    Wrapped<String>? createdAt,
    Wrapped<String>? updatedAt,
  }) {
    return ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$Item(
      id: (id != null ? id.value : this.id),
      pipelineRunId: (pipelineRunId != null
          ? pipelineRunId.value
          : this.pipelineRunId),
      buildProfileId: (buildProfileId != null
          ? buildProfileId.value
          : this.buildProfileId),
      platform: (platform != null ? platform.value : this.platform),
      packageType: (packageType != null ? packageType.value : this.packageType),
      arch: (arch != null ? arch.value : this.arch),
      status: (status != null ? status.value : this.status),
      externalJobId: (externalJobId != null
          ? externalJobId.value
          : this.externalJobId),
      artifactId: (artifactId != null ? artifactId.value : this.artifactId),
      deploymentTargetId: (deploymentTargetId != null
          ? deploymentTargetId.value
          : this.deploymentTargetId),
      deploymentStatus: (deploymentStatus != null
          ? deploymentStatus.value
          : this.deploymentStatus),
      logsUrl: (logsUrl != null ? logsUrl.value : this.logsUrl),
      errorMessage: (errorMessage != null
          ? errorMessage.value
          : this.errorMessage),
      startedAt: (startedAt != null ? startedAt.value : this.startedAt),
      finishedAt: (finishedAt != null ? finishedAt.value : this.finishedAt),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1ReleasesReleaseIdGet$Response$Artifacts$Item {
  const ApiV1ReleasesReleaseIdGet$Response$Artifacts$Item({
    required this.id,
    required this.releaseId,
    required this.platform,
    required this.arch,
    required this.packageType,
    required this.fileName,
    required this.s3Key,
    required this.sha256,
    required this.signature,
    required this.sizeBytes,
    required this.verified,
    required this.createdAt,
  });

  factory ApiV1ReleasesReleaseIdGet$Response$Artifacts$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemFromJson(json);

  static const toJsonFactory =
      _$ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'releaseId', includeIfNull: false)
  final String releaseId;
  @JsonKey(
    name: 'platform',
    includeIfNull: false,
    toJson: apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatformToJson,
    fromJson: apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatformFromJson,
  )
  final enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform
  platform;
  @JsonKey(
    name: 'arch',
    includeIfNull: false,
    toJson: apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArchToJson,
    fromJson: apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArchFromJson,
  )
  final enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch arch;
  @JsonKey(name: 'packageType', includeIfNull: false)
  final String packageType;
  @JsonKey(name: 'fileName', includeIfNull: false)
  final String fileName;
  @JsonKey(name: 's3Key', includeIfNull: false)
  final String s3Key;
  @JsonKey(name: 'sha256', includeIfNull: false)
  final String? sha256;
  @JsonKey(name: 'signature', includeIfNull: false)
  final String? signature;
  @JsonKey(name: 'sizeBytes', includeIfNull: false)
  final int sizeBytes;
  @JsonKey(name: 'verified', includeIfNull: false)
  final bool verified;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final String createdAt;
  static const fromJsonFactory =
      _$ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1ReleasesReleaseIdGet$Response$Artifacts$Item &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.releaseId, releaseId) ||
                const DeepCollectionEquality().equals(
                  other.releaseId,
                  releaseId,
                )) &&
            (identical(other.platform, platform) ||
                const DeepCollectionEquality().equals(
                  other.platform,
                  platform,
                )) &&
            (identical(other.arch, arch) ||
                const DeepCollectionEquality().equals(other.arch, arch)) &&
            (identical(other.packageType, packageType) ||
                const DeepCollectionEquality().equals(
                  other.packageType,
                  packageType,
                )) &&
            (identical(other.fileName, fileName) ||
                const DeepCollectionEquality().equals(
                  other.fileName,
                  fileName,
                )) &&
            (identical(other.s3Key, s3Key) ||
                const DeepCollectionEquality().equals(other.s3Key, s3Key)) &&
            (identical(other.sha256, sha256) ||
                const DeepCollectionEquality().equals(other.sha256, sha256)) &&
            (identical(other.signature, signature) ||
                const DeepCollectionEquality().equals(
                  other.signature,
                  signature,
                )) &&
            (identical(other.sizeBytes, sizeBytes) ||
                const DeepCollectionEquality().equals(
                  other.sizeBytes,
                  sizeBytes,
                )) &&
            (identical(other.verified, verified) ||
                const DeepCollectionEquality().equals(
                  other.verified,
                  verified,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(releaseId) ^
      const DeepCollectionEquality().hash(platform) ^
      const DeepCollectionEquality().hash(arch) ^
      const DeepCollectionEquality().hash(packageType) ^
      const DeepCollectionEquality().hash(fileName) ^
      const DeepCollectionEquality().hash(s3Key) ^
      const DeepCollectionEquality().hash(sha256) ^
      const DeepCollectionEquality().hash(signature) ^
      const DeepCollectionEquality().hash(sizeBytes) ^
      const DeepCollectionEquality().hash(verified) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemExtension
    on ApiV1ReleasesReleaseIdGet$Response$Artifacts$Item {
  ApiV1ReleasesReleaseIdGet$Response$Artifacts$Item copyWith({
    String? id,
    String? releaseId,
    enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform? platform,
    enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch? arch,
    String? packageType,
    String? fileName,
    String? s3Key,
    String? sha256,
    String? signature,
    int? sizeBytes,
    bool? verified,
    String? createdAt,
  }) {
    return ApiV1ReleasesReleaseIdGet$Response$Artifacts$Item(
      id: id ?? this.id,
      releaseId: releaseId ?? this.releaseId,
      platform: platform ?? this.platform,
      arch: arch ?? this.arch,
      packageType: packageType ?? this.packageType,
      fileName: fileName ?? this.fileName,
      s3Key: s3Key ?? this.s3Key,
      sha256: sha256 ?? this.sha256,
      signature: signature ?? this.signature,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      verified: verified ?? this.verified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  ApiV1ReleasesReleaseIdGet$Response$Artifacts$Item copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? releaseId,
    Wrapped<enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform>?
    platform,
    Wrapped<enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch>? arch,
    Wrapped<String>? packageType,
    Wrapped<String>? fileName,
    Wrapped<String>? s3Key,
    Wrapped<String?>? sha256,
    Wrapped<String?>? signature,
    Wrapped<int>? sizeBytes,
    Wrapped<bool>? verified,
    Wrapped<String>? createdAt,
  }) {
    return ApiV1ReleasesReleaseIdGet$Response$Artifacts$Item(
      id: (id != null ? id.value : this.id),
      releaseId: (releaseId != null ? releaseId.value : this.releaseId),
      platform: (platform != null ? platform.value : this.platform),
      arch: (arch != null ? arch.value : this.arch),
      packageType: (packageType != null ? packageType.value : this.packageType),
      fileName: (fileName != null ? fileName.value : this.fileName),
      s3Key: (s3Key != null ? s3Key.value : this.s3Key),
      sha256: (sha256 != null ? sha256.value : this.sha256),
      signature: (signature != null ? signature.value : this.signature),
      sizeBytes: (sizeBytes != null ? sizeBytes.value : this.sizeBytes),
      verified: (verified != null ? verified.value : this.verified),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1MetricsDownloadsGet$Response$Series$Item {
  const ApiV1MetricsDownloadsGet$Response$Series$Item({
    required this.bucketStart,
    required this.count,
    this.channel,
    this.platform,
    this.arch,
    this.version,
  });

  factory ApiV1MetricsDownloadsGet$Response$Series$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1MetricsDownloadsGet$Response$Series$ItemFromJson(json);

  static const toJsonFactory =
      _$ApiV1MetricsDownloadsGet$Response$Series$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1MetricsDownloadsGet$Response$Series$ItemToJson(this);

  @JsonKey(name: 'bucketStart', includeIfNull: false)
  final String bucketStart;
  @JsonKey(name: 'count', includeIfNull: false)
  final int count;
  @JsonKey(name: 'channel', includeIfNull: false)
  final String? channel;
  @JsonKey(name: 'platform', includeIfNull: false)
  final String? platform;
  @JsonKey(name: 'arch', includeIfNull: false)
  final String? arch;
  @JsonKey(name: 'version', includeIfNull: false)
  final String? version;
  static const fromJsonFactory =
      _$ApiV1MetricsDownloadsGet$Response$Series$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1MetricsDownloadsGet$Response$Series$Item &&
            (identical(other.bucketStart, bucketStart) ||
                const DeepCollectionEquality().equals(
                  other.bucketStart,
                  bucketStart,
                )) &&
            (identical(other.count, count) ||
                const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.channel, channel) ||
                const DeepCollectionEquality().equals(
                  other.channel,
                  channel,
                )) &&
            (identical(other.platform, platform) ||
                const DeepCollectionEquality().equals(
                  other.platform,
                  platform,
                )) &&
            (identical(other.arch, arch) ||
                const DeepCollectionEquality().equals(other.arch, arch)) &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(other.version, version)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(bucketStart) ^
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(channel) ^
      const DeepCollectionEquality().hash(platform) ^
      const DeepCollectionEquality().hash(arch) ^
      const DeepCollectionEquality().hash(version) ^
      runtimeType.hashCode;
}

extension $ApiV1MetricsDownloadsGet$Response$Series$ItemExtension
    on ApiV1MetricsDownloadsGet$Response$Series$Item {
  ApiV1MetricsDownloadsGet$Response$Series$Item copyWith({
    String? bucketStart,
    int? count,
    String? channel,
    String? platform,
    String? arch,
    String? version,
  }) {
    return ApiV1MetricsDownloadsGet$Response$Series$Item(
      bucketStart: bucketStart ?? this.bucketStart,
      count: count ?? this.count,
      channel: channel ?? this.channel,
      platform: platform ?? this.platform,
      arch: arch ?? this.arch,
      version: version ?? this.version,
    );
  }

  ApiV1MetricsDownloadsGet$Response$Series$Item copyWithWrapped({
    Wrapped<String>? bucketStart,
    Wrapped<int>? count,
    Wrapped<String?>? channel,
    Wrapped<String?>? platform,
    Wrapped<String?>? arch,
    Wrapped<String?>? version,
  }) {
    return ApiV1MetricsDownloadsGet$Response$Series$Item(
      bucketStart: (bucketStart != null ? bucketStart.value : this.bucketStart),
      count: (count != null ? count.value : this.count),
      channel: (channel != null ? channel.value : this.channel),
      platform: (platform != null ? platform.value : this.platform),
      arch: (arch != null ? arch.value : this.arch),
      version: (version != null ? version.value : this.version),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1MetricsUpdateChecksGet$Response$Series$Item {
  const ApiV1MetricsUpdateChecksGet$Response$Series$Item({
    required this.bucketStart,
    required this.count,
    this.channel,
    this.platform,
    this.arch,
    this.version,
  });

  factory ApiV1MetricsUpdateChecksGet$Response$Series$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1MetricsUpdateChecksGet$Response$Series$ItemFromJson(json);

  static const toJsonFactory =
      _$ApiV1MetricsUpdateChecksGet$Response$Series$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1MetricsUpdateChecksGet$Response$Series$ItemToJson(this);

  @JsonKey(name: 'bucketStart', includeIfNull: false)
  final String bucketStart;
  @JsonKey(name: 'count', includeIfNull: false)
  final int count;
  @JsonKey(name: 'channel', includeIfNull: false)
  final String? channel;
  @JsonKey(name: 'platform', includeIfNull: false)
  final String? platform;
  @JsonKey(name: 'arch', includeIfNull: false)
  final String? arch;
  @JsonKey(name: 'version', includeIfNull: false)
  final String? version;
  static const fromJsonFactory =
      _$ApiV1MetricsUpdateChecksGet$Response$Series$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1MetricsUpdateChecksGet$Response$Series$Item &&
            (identical(other.bucketStart, bucketStart) ||
                const DeepCollectionEquality().equals(
                  other.bucketStart,
                  bucketStart,
                )) &&
            (identical(other.count, count) ||
                const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.channel, channel) ||
                const DeepCollectionEquality().equals(
                  other.channel,
                  channel,
                )) &&
            (identical(other.platform, platform) ||
                const DeepCollectionEquality().equals(
                  other.platform,
                  platform,
                )) &&
            (identical(other.arch, arch) ||
                const DeepCollectionEquality().equals(other.arch, arch)) &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(other.version, version)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(bucketStart) ^
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(channel) ^
      const DeepCollectionEquality().hash(platform) ^
      const DeepCollectionEquality().hash(arch) ^
      const DeepCollectionEquality().hash(version) ^
      runtimeType.hashCode;
}

extension $ApiV1MetricsUpdateChecksGet$Response$Series$ItemExtension
    on ApiV1MetricsUpdateChecksGet$Response$Series$Item {
  ApiV1MetricsUpdateChecksGet$Response$Series$Item copyWith({
    String? bucketStart,
    int? count,
    String? channel,
    String? platform,
    String? arch,
    String? version,
  }) {
    return ApiV1MetricsUpdateChecksGet$Response$Series$Item(
      bucketStart: bucketStart ?? this.bucketStart,
      count: count ?? this.count,
      channel: channel ?? this.channel,
      platform: platform ?? this.platform,
      arch: arch ?? this.arch,
      version: version ?? this.version,
    );
  }

  ApiV1MetricsUpdateChecksGet$Response$Series$Item copyWithWrapped({
    Wrapped<String>? bucketStart,
    Wrapped<int>? count,
    Wrapped<String?>? channel,
    Wrapped<String?>? platform,
    Wrapped<String?>? arch,
    Wrapped<String?>? version,
  }) {
    return ApiV1MetricsUpdateChecksGet$Response$Series$Item(
      bucketStart: (bucketStart != null ? bucketStart.value : this.bucketStart),
      count: (count != null ? count.value : this.count),
      channel: (channel != null ? channel.value : this.channel),
      platform: (platform != null ? platform.value : this.platform),
      arch: (arch != null ? arch.value : this.arch),
      version: (version != null ? version.value : this.version),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1DashboardSummaryGet$Response$Totals {
  const ApiV1DashboardSummaryGet$Response$Totals({
    required this.apps,
    required this.channels,
    required this.releases,
    required this.publishedReleases,
    required this.artifacts,
    required this.channelAssignments,
    required this.downloadsTotal,
    required this.updateChecksTotal,
    required this.downloadsLast7Days,
    required this.updateChecksLast7Days,
  });

  factory ApiV1DashboardSummaryGet$Response$Totals.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1DashboardSummaryGet$Response$TotalsFromJson(json);

  static const toJsonFactory = _$ApiV1DashboardSummaryGet$Response$TotalsToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1DashboardSummaryGet$Response$TotalsToJson(this);

  @JsonKey(name: 'apps', includeIfNull: false)
  final int apps;
  @JsonKey(name: 'channels', includeIfNull: false)
  final int channels;
  @JsonKey(name: 'releases', includeIfNull: false)
  final int releases;
  @JsonKey(name: 'publishedReleases', includeIfNull: false)
  final int publishedReleases;
  @JsonKey(name: 'artifacts', includeIfNull: false)
  final int artifacts;
  @JsonKey(name: 'channelAssignments', includeIfNull: false)
  final int channelAssignments;
  @JsonKey(name: 'downloadsTotal', includeIfNull: false)
  final int downloadsTotal;
  @JsonKey(name: 'updateChecksTotal', includeIfNull: false)
  final int updateChecksTotal;
  @JsonKey(name: 'downloadsLast7Days', includeIfNull: false)
  final int downloadsLast7Days;
  @JsonKey(name: 'updateChecksLast7Days', includeIfNull: false)
  final int updateChecksLast7Days;
  static const fromJsonFactory =
      _$ApiV1DashboardSummaryGet$Response$TotalsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1DashboardSummaryGet$Response$Totals &&
            (identical(other.apps, apps) ||
                const DeepCollectionEquality().equals(other.apps, apps)) &&
            (identical(other.channels, channels) ||
                const DeepCollectionEquality().equals(
                  other.channels,
                  channels,
                )) &&
            (identical(other.releases, releases) ||
                const DeepCollectionEquality().equals(
                  other.releases,
                  releases,
                )) &&
            (identical(other.publishedReleases, publishedReleases) ||
                const DeepCollectionEquality().equals(
                  other.publishedReleases,
                  publishedReleases,
                )) &&
            (identical(other.artifacts, artifacts) ||
                const DeepCollectionEquality().equals(
                  other.artifacts,
                  artifacts,
                )) &&
            (identical(other.channelAssignments, channelAssignments) ||
                const DeepCollectionEquality().equals(
                  other.channelAssignments,
                  channelAssignments,
                )) &&
            (identical(other.downloadsTotal, downloadsTotal) ||
                const DeepCollectionEquality().equals(
                  other.downloadsTotal,
                  downloadsTotal,
                )) &&
            (identical(other.updateChecksTotal, updateChecksTotal) ||
                const DeepCollectionEquality().equals(
                  other.updateChecksTotal,
                  updateChecksTotal,
                )) &&
            (identical(other.downloadsLast7Days, downloadsLast7Days) ||
                const DeepCollectionEquality().equals(
                  other.downloadsLast7Days,
                  downloadsLast7Days,
                )) &&
            (identical(other.updateChecksLast7Days, updateChecksLast7Days) ||
                const DeepCollectionEquality().equals(
                  other.updateChecksLast7Days,
                  updateChecksLast7Days,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(apps) ^
      const DeepCollectionEquality().hash(channels) ^
      const DeepCollectionEquality().hash(releases) ^
      const DeepCollectionEquality().hash(publishedReleases) ^
      const DeepCollectionEquality().hash(artifacts) ^
      const DeepCollectionEquality().hash(channelAssignments) ^
      const DeepCollectionEquality().hash(downloadsTotal) ^
      const DeepCollectionEquality().hash(updateChecksTotal) ^
      const DeepCollectionEquality().hash(downloadsLast7Days) ^
      const DeepCollectionEquality().hash(updateChecksLast7Days) ^
      runtimeType.hashCode;
}

extension $ApiV1DashboardSummaryGet$Response$TotalsExtension
    on ApiV1DashboardSummaryGet$Response$Totals {
  ApiV1DashboardSummaryGet$Response$Totals copyWith({
    int? apps,
    int? channels,
    int? releases,
    int? publishedReleases,
    int? artifacts,
    int? channelAssignments,
    int? downloadsTotal,
    int? updateChecksTotal,
    int? downloadsLast7Days,
    int? updateChecksLast7Days,
  }) {
    return ApiV1DashboardSummaryGet$Response$Totals(
      apps: apps ?? this.apps,
      channels: channels ?? this.channels,
      releases: releases ?? this.releases,
      publishedReleases: publishedReleases ?? this.publishedReleases,
      artifacts: artifacts ?? this.artifacts,
      channelAssignments: channelAssignments ?? this.channelAssignments,
      downloadsTotal: downloadsTotal ?? this.downloadsTotal,
      updateChecksTotal: updateChecksTotal ?? this.updateChecksTotal,
      downloadsLast7Days: downloadsLast7Days ?? this.downloadsLast7Days,
      updateChecksLast7Days:
          updateChecksLast7Days ?? this.updateChecksLast7Days,
    );
  }

  ApiV1DashboardSummaryGet$Response$Totals copyWithWrapped({
    Wrapped<int>? apps,
    Wrapped<int>? channels,
    Wrapped<int>? releases,
    Wrapped<int>? publishedReleases,
    Wrapped<int>? artifacts,
    Wrapped<int>? channelAssignments,
    Wrapped<int>? downloadsTotal,
    Wrapped<int>? updateChecksTotal,
    Wrapped<int>? downloadsLast7Days,
    Wrapped<int>? updateChecksLast7Days,
  }) {
    return ApiV1DashboardSummaryGet$Response$Totals(
      apps: (apps != null ? apps.value : this.apps),
      channels: (channels != null ? channels.value : this.channels),
      releases: (releases != null ? releases.value : this.releases),
      publishedReleases: (publishedReleases != null
          ? publishedReleases.value
          : this.publishedReleases),
      artifacts: (artifacts != null ? artifacts.value : this.artifacts),
      channelAssignments: (channelAssignments != null
          ? channelAssignments.value
          : this.channelAssignments),
      downloadsTotal: (downloadsTotal != null
          ? downloadsTotal.value
          : this.downloadsTotal),
      updateChecksTotal: (updateChecksTotal != null
          ? updateChecksTotal.value
          : this.updateChecksTotal),
      downloadsLast7Days: (downloadsLast7Days != null
          ? downloadsLast7Days.value
          : this.downloadsLast7Days),
      updateChecksLast7Days: (updateChecksLast7Days != null
          ? updateChecksLast7Days.value
          : this.updateChecksLast7Days),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1DashboardSummaryGet$Response$Apps$Item {
  const ApiV1DashboardSummaryGet$Response$Apps$Item({
    required this.appId,
    required this.appSlug,
    required this.appName,
    required this.channels,
    required this.releases,
    required this.publishedReleases,
    required this.downloadsTotal,
    required this.updateChecksTotal,
    required this.lastDownloadAt,
    required this.lastUpdateCheckAt,
  });

  factory ApiV1DashboardSummaryGet$Response$Apps$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1DashboardSummaryGet$Response$Apps$ItemFromJson(json);

  static const toJsonFactory =
      _$ApiV1DashboardSummaryGet$Response$Apps$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1DashboardSummaryGet$Response$Apps$ItemToJson(this);

  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(name: 'appSlug', includeIfNull: false)
  final String appSlug;
  @JsonKey(name: 'appName', includeIfNull: false)
  final String appName;
  @JsonKey(name: 'channels', includeIfNull: false)
  final int channels;
  @JsonKey(name: 'releases', includeIfNull: false)
  final int releases;
  @JsonKey(name: 'publishedReleases', includeIfNull: false)
  final int publishedReleases;
  @JsonKey(name: 'downloadsTotal', includeIfNull: false)
  final int downloadsTotal;
  @JsonKey(name: 'updateChecksTotal', includeIfNull: false)
  final int updateChecksTotal;
  @JsonKey(name: 'lastDownloadAt', includeIfNull: false)
  final String? lastDownloadAt;
  @JsonKey(name: 'lastUpdateCheckAt', includeIfNull: false)
  final String? lastUpdateCheckAt;
  static const fromJsonFactory =
      _$ApiV1DashboardSummaryGet$Response$Apps$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1DashboardSummaryGet$Response$Apps$Item &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.appSlug, appSlug) ||
                const DeepCollectionEquality().equals(
                  other.appSlug,
                  appSlug,
                )) &&
            (identical(other.appName, appName) ||
                const DeepCollectionEquality().equals(
                  other.appName,
                  appName,
                )) &&
            (identical(other.channels, channels) ||
                const DeepCollectionEquality().equals(
                  other.channels,
                  channels,
                )) &&
            (identical(other.releases, releases) ||
                const DeepCollectionEquality().equals(
                  other.releases,
                  releases,
                )) &&
            (identical(other.publishedReleases, publishedReleases) ||
                const DeepCollectionEquality().equals(
                  other.publishedReleases,
                  publishedReleases,
                )) &&
            (identical(other.downloadsTotal, downloadsTotal) ||
                const DeepCollectionEquality().equals(
                  other.downloadsTotal,
                  downloadsTotal,
                )) &&
            (identical(other.updateChecksTotal, updateChecksTotal) ||
                const DeepCollectionEquality().equals(
                  other.updateChecksTotal,
                  updateChecksTotal,
                )) &&
            (identical(other.lastDownloadAt, lastDownloadAt) ||
                const DeepCollectionEquality().equals(
                  other.lastDownloadAt,
                  lastDownloadAt,
                )) &&
            (identical(other.lastUpdateCheckAt, lastUpdateCheckAt) ||
                const DeepCollectionEquality().equals(
                  other.lastUpdateCheckAt,
                  lastUpdateCheckAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(appSlug) ^
      const DeepCollectionEquality().hash(appName) ^
      const DeepCollectionEquality().hash(channels) ^
      const DeepCollectionEquality().hash(releases) ^
      const DeepCollectionEquality().hash(publishedReleases) ^
      const DeepCollectionEquality().hash(downloadsTotal) ^
      const DeepCollectionEquality().hash(updateChecksTotal) ^
      const DeepCollectionEquality().hash(lastDownloadAt) ^
      const DeepCollectionEquality().hash(lastUpdateCheckAt) ^
      runtimeType.hashCode;
}

extension $ApiV1DashboardSummaryGet$Response$Apps$ItemExtension
    on ApiV1DashboardSummaryGet$Response$Apps$Item {
  ApiV1DashboardSummaryGet$Response$Apps$Item copyWith({
    String? appId,
    String? appSlug,
    String? appName,
    int? channels,
    int? releases,
    int? publishedReleases,
    int? downloadsTotal,
    int? updateChecksTotal,
    String? lastDownloadAt,
    String? lastUpdateCheckAt,
  }) {
    return ApiV1DashboardSummaryGet$Response$Apps$Item(
      appId: appId ?? this.appId,
      appSlug: appSlug ?? this.appSlug,
      appName: appName ?? this.appName,
      channels: channels ?? this.channels,
      releases: releases ?? this.releases,
      publishedReleases: publishedReleases ?? this.publishedReleases,
      downloadsTotal: downloadsTotal ?? this.downloadsTotal,
      updateChecksTotal: updateChecksTotal ?? this.updateChecksTotal,
      lastDownloadAt: lastDownloadAt ?? this.lastDownloadAt,
      lastUpdateCheckAt: lastUpdateCheckAt ?? this.lastUpdateCheckAt,
    );
  }

  ApiV1DashboardSummaryGet$Response$Apps$Item copyWithWrapped({
    Wrapped<String>? appId,
    Wrapped<String>? appSlug,
    Wrapped<String>? appName,
    Wrapped<int>? channels,
    Wrapped<int>? releases,
    Wrapped<int>? publishedReleases,
    Wrapped<int>? downloadsTotal,
    Wrapped<int>? updateChecksTotal,
    Wrapped<String?>? lastDownloadAt,
    Wrapped<String?>? lastUpdateCheckAt,
  }) {
    return ApiV1DashboardSummaryGet$Response$Apps$Item(
      appId: (appId != null ? appId.value : this.appId),
      appSlug: (appSlug != null ? appSlug.value : this.appSlug),
      appName: (appName != null ? appName.value : this.appName),
      channels: (channels != null ? channels.value : this.channels),
      releases: (releases != null ? releases.value : this.releases),
      publishedReleases: (publishedReleases != null
          ? publishedReleases.value
          : this.publishedReleases),
      downloadsTotal: (downloadsTotal != null
          ? downloadsTotal.value
          : this.downloadsTotal),
      updateChecksTotal: (updateChecksTotal != null
          ? updateChecksTotal.value
          : this.updateChecksTotal),
      lastDownloadAt: (lastDownloadAt != null
          ? lastDownloadAt.value
          : this.lastDownloadAt),
      lastUpdateCheckAt: (lastUpdateCheckAt != null
          ? lastUpdateCheckAt.value
          : this.lastUpdateCheckAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1DashboardSummaryGet$Response$ActiveAssignments$Item {
  const ApiV1DashboardSummaryGet$Response$ActiveAssignments$Item({
    required this.appId,
    required this.appSlug,
    required this.channelId,
    required this.channelSlug,
    required this.channelKind,
    required this.releaseId,
    required this.releaseVersion,
    this.platform,
    this.arch,
    required this.rolloutPercent,
    required this.assignedAt,
  });

  factory ApiV1DashboardSummaryGet$Response$ActiveAssignments$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemFromJson(json);

  static const toJsonFactory =
      _$ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemToJson(this);

  @JsonKey(name: 'appId', includeIfNull: false)
  final String appId;
  @JsonKey(name: 'appSlug', includeIfNull: false)
  final String appSlug;
  @JsonKey(name: 'channelId', includeIfNull: false)
  final String channelId;
  @JsonKey(name: 'channelSlug', includeIfNull: false)
  final String channelSlug;
  @JsonKey(
    name: 'channelKind',
    includeIfNull: false,
    toJson:
        apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKindToJson,
    fromJson:
        apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKindFromJson,
  )
  final enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind
  channelKind;
  @JsonKey(name: 'releaseId', includeIfNull: false)
  final String releaseId;
  @JsonKey(name: 'releaseVersion', includeIfNull: false)
  final String releaseVersion;
  @JsonKey(
    name: 'platform',
    includeIfNull: false,
    toJson:
        apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatformNullableToJson,
    fromJson:
        apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatformNullableFromJson,
  )
  final enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform?
  platform;
  @JsonKey(
    name: 'arch',
    includeIfNull: false,
    toJson:
        apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArchNullableToJson,
    fromJson:
        apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArchNullableFromJson,
  )
  final enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch?
  arch;
  @JsonKey(name: 'rolloutPercent', includeIfNull: false)
  final int rolloutPercent;
  @JsonKey(name: 'assignedAt', includeIfNull: false)
  final String assignedAt;
  static const fromJsonFactory =
      _$ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1DashboardSummaryGet$Response$ActiveAssignments$Item &&
            (identical(other.appId, appId) ||
                const DeepCollectionEquality().equals(other.appId, appId)) &&
            (identical(other.appSlug, appSlug) ||
                const DeepCollectionEquality().equals(
                  other.appSlug,
                  appSlug,
                )) &&
            (identical(other.channelId, channelId) ||
                const DeepCollectionEquality().equals(
                  other.channelId,
                  channelId,
                )) &&
            (identical(other.channelSlug, channelSlug) ||
                const DeepCollectionEquality().equals(
                  other.channelSlug,
                  channelSlug,
                )) &&
            (identical(other.channelKind, channelKind) ||
                const DeepCollectionEquality().equals(
                  other.channelKind,
                  channelKind,
                )) &&
            (identical(other.releaseId, releaseId) ||
                const DeepCollectionEquality().equals(
                  other.releaseId,
                  releaseId,
                )) &&
            (identical(other.releaseVersion, releaseVersion) ||
                const DeepCollectionEquality().equals(
                  other.releaseVersion,
                  releaseVersion,
                )) &&
            (identical(other.platform, platform) ||
                const DeepCollectionEquality().equals(
                  other.platform,
                  platform,
                )) &&
            (identical(other.arch, arch) ||
                const DeepCollectionEquality().equals(other.arch, arch)) &&
            (identical(other.rolloutPercent, rolloutPercent) ||
                const DeepCollectionEquality().equals(
                  other.rolloutPercent,
                  rolloutPercent,
                )) &&
            (identical(other.assignedAt, assignedAt) ||
                const DeepCollectionEquality().equals(
                  other.assignedAt,
                  assignedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(appId) ^
      const DeepCollectionEquality().hash(appSlug) ^
      const DeepCollectionEquality().hash(channelId) ^
      const DeepCollectionEquality().hash(channelSlug) ^
      const DeepCollectionEquality().hash(channelKind) ^
      const DeepCollectionEquality().hash(releaseId) ^
      const DeepCollectionEquality().hash(releaseVersion) ^
      const DeepCollectionEquality().hash(platform) ^
      const DeepCollectionEquality().hash(arch) ^
      const DeepCollectionEquality().hash(rolloutPercent) ^
      const DeepCollectionEquality().hash(assignedAt) ^
      runtimeType.hashCode;
}

extension $ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemExtension
    on ApiV1DashboardSummaryGet$Response$ActiveAssignments$Item {
  ApiV1DashboardSummaryGet$Response$ActiveAssignments$Item copyWith({
    String? appId,
    String? appSlug,
    String? channelId,
    String? channelSlug,
    enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind?
    channelKind,
    String? releaseId,
    String? releaseVersion,
    enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform?
    platform,
    enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch? arch,
    int? rolloutPercent,
    String? assignedAt,
  }) {
    return ApiV1DashboardSummaryGet$Response$ActiveAssignments$Item(
      appId: appId ?? this.appId,
      appSlug: appSlug ?? this.appSlug,
      channelId: channelId ?? this.channelId,
      channelSlug: channelSlug ?? this.channelSlug,
      channelKind: channelKind ?? this.channelKind,
      releaseId: releaseId ?? this.releaseId,
      releaseVersion: releaseVersion ?? this.releaseVersion,
      platform: platform ?? this.platform,
      arch: arch ?? this.arch,
      rolloutPercent: rolloutPercent ?? this.rolloutPercent,
      assignedAt: assignedAt ?? this.assignedAt,
    );
  }

  ApiV1DashboardSummaryGet$Response$ActiveAssignments$Item copyWithWrapped({
    Wrapped<String>? appId,
    Wrapped<String>? appSlug,
    Wrapped<String>? channelId,
    Wrapped<String>? channelSlug,
    Wrapped<
      enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind
    >?
    channelKind,
    Wrapped<String>? releaseId,
    Wrapped<String>? releaseVersion,
    Wrapped<
      enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform?
    >?
    platform,
    Wrapped<
      enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch?
    >?
    arch,
    Wrapped<int>? rolloutPercent,
    Wrapped<String>? assignedAt,
  }) {
    return ApiV1DashboardSummaryGet$Response$ActiveAssignments$Item(
      appId: (appId != null ? appId.value : this.appId),
      appSlug: (appSlug != null ? appSlug.value : this.appSlug),
      channelId: (channelId != null ? channelId.value : this.channelId),
      channelSlug: (channelSlug != null ? channelSlug.value : this.channelSlug),
      channelKind: (channelKind != null ? channelKind.value : this.channelKind),
      releaseId: (releaseId != null ? releaseId.value : this.releaseId),
      releaseVersion: (releaseVersion != null
          ? releaseVersion.value
          : this.releaseVersion),
      platform: (platform != null ? platform.value : this.platform),
      arch: (arch != null ? arch.value : this.arch),
      rolloutPercent: (rolloutPercent != null
          ? rolloutPercent.value
          : this.rolloutPercent),
      assignedAt: (assignedAt != null ? assignedAt.value : this.assignedAt),
    );
  }
}

String? apiV1AppsAppIdRepositoryConnectionGet$ResponseProviderNullableToJson(
  enums.ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider?
  apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider,
) {
  return apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider?.value;
}

String? apiV1AppsAppIdRepositoryConnectionGet$ResponseProviderToJson(
  enums.ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider
  apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider,
) {
  return apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider.value;
}

enums.ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider
apiV1AppsAppIdRepositoryConnectionGet$ResponseProviderFromJson(
  Object? apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider, [
  enums.ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider? defaultValue,
]) {
  return enums.ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider?
apiV1AppsAppIdRepositoryConnectionGet$ResponseProviderNullableFromJson(
  Object? apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider, [
  enums.ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider? defaultValue,
]) {
  if (apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider == null) {
    return null;
  }
  return enums.ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider,
          ) ??
      defaultValue;
}

String apiV1AppsAppIdRepositoryConnectionGet$ResponseProviderExplodedListToJson(
  List<enums.ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider>?
  apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider,
) {
  return apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1AppsAppIdRepositoryConnectionGet$ResponseProviderListToJson(
  List<enums.ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider>?
  apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider,
) {
  if (apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider == null) {
    return [];
  }

  return apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider>
apiV1AppsAppIdRepositoryConnectionGet$ResponseProviderListFromJson(
  List? apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider, [
  List<enums.ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider>?
  defaultValue,
]) {
  if (apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider == null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider
      .map(
        (e) => apiV1AppsAppIdRepositoryConnectionGet$ResponseProviderFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider>?
apiV1AppsAppIdRepositoryConnectionGet$ResponseProviderNullableListFromJson(
  List? apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider, [
  List<enums.ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider>?
  defaultValue,
]) {
  if (apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider == null) {
    return defaultValue;
  }

  return apiV1AppsAppIdRepositoryConnectionGet$ResponseProvider
      .map(
        (e) => apiV1AppsAppIdRepositoryConnectionGet$ResponseProviderFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1AppsAppIdRepositoryConnectionPut$ResponseProviderNullableToJson(
  enums.ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider?
  apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider,
) {
  return apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider?.value;
}

String? apiV1AppsAppIdRepositoryConnectionPut$ResponseProviderToJson(
  enums.ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider
  apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider,
) {
  return apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider.value;
}

enums.ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider
apiV1AppsAppIdRepositoryConnectionPut$ResponseProviderFromJson(
  Object? apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider, [
  enums.ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider? defaultValue,
]) {
  return enums.ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider?
apiV1AppsAppIdRepositoryConnectionPut$ResponseProviderNullableFromJson(
  Object? apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider, [
  enums.ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider? defaultValue,
]) {
  if (apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider == null) {
    return null;
  }
  return enums.ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider,
          ) ??
      defaultValue;
}

String apiV1AppsAppIdRepositoryConnectionPut$ResponseProviderExplodedListToJson(
  List<enums.ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider>?
  apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider,
) {
  return apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1AppsAppIdRepositoryConnectionPut$ResponseProviderListToJson(
  List<enums.ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider>?
  apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider,
) {
  if (apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider == null) {
    return [];
  }

  return apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider>
apiV1AppsAppIdRepositoryConnectionPut$ResponseProviderListFromJson(
  List? apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider, [
  List<enums.ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider>?
  defaultValue,
]) {
  if (apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider == null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider
      .map(
        (e) => apiV1AppsAppIdRepositoryConnectionPut$ResponseProviderFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider>?
apiV1AppsAppIdRepositoryConnectionPut$ResponseProviderNullableListFromJson(
  List? apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider, [
  List<enums.ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider>?
  defaultValue,
]) {
  if (apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider == null) {
    return defaultValue;
  }

  return apiV1AppsAppIdRepositoryConnectionPut$ResponseProvider
      .map(
        (e) => apiV1AppsAppIdRepositoryConnectionPut$ResponseProviderFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKindNullableToJson(
  enums.ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind?
  apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind,
) {
  return apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind?.value;
}

String? apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKindToJson(
  enums.ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind
  apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind,
) {
  return apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind.value;
}

enums.ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind
apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKindFromJson(
  Object? apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind, [
  enums.ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind? defaultValue,
]) {
  return enums.ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind.values
          .firstWhereOrNull(
            (e) =>
                e.value == apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind?
apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKindNullableFromJson(
  Object? apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind, [
  enums.ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind? defaultValue,
]) {
  if (apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind == null) {
    return null;
  }
  return enums.ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind.values
          .firstWhereOrNull(
            (e) =>
                e.value == apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind,
          ) ??
      defaultValue;
}

String apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKindExplodedListToJson(
  List<enums.ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind>?
  apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind,
) {
  return apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKindListToJson(
  List<enums.ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind>?
  apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind,
) {
  if (apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind == null) {
    return [];
  }

  return apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind>
apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKindListFromJson(
  List? apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind, [
  List<enums.ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind>?
  defaultValue,
]) {
  if (apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind == null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind
      .map(
        (e) => apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKindFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind>?
apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKindNullableListFromJson(
  List? apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind, [
  List<enums.ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind>?
  defaultValue,
]) {
  if (apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind == null) {
    return defaultValue;
  }

  return apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind
      .map(
        (e) => apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKindFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1AppsAppIdDeploymentTargetsPost$ResponseKindNullableToJson(
  enums.ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind?
  apiV1AppsAppIdDeploymentTargetsPost$ResponseKind,
) {
  return apiV1AppsAppIdDeploymentTargetsPost$ResponseKind?.value;
}

String? apiV1AppsAppIdDeploymentTargetsPost$ResponseKindToJson(
  enums.ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind
  apiV1AppsAppIdDeploymentTargetsPost$ResponseKind,
) {
  return apiV1AppsAppIdDeploymentTargetsPost$ResponseKind.value;
}

enums.ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind
apiV1AppsAppIdDeploymentTargetsPost$ResponseKindFromJson(
  Object? apiV1AppsAppIdDeploymentTargetsPost$ResponseKind, [
  enums.ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind? defaultValue,
]) {
  return enums.ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind.values
          .firstWhereOrNull(
            (e) => e.value == apiV1AppsAppIdDeploymentTargetsPost$ResponseKind,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind?
apiV1AppsAppIdDeploymentTargetsPost$ResponseKindNullableFromJson(
  Object? apiV1AppsAppIdDeploymentTargetsPost$ResponseKind, [
  enums.ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind? defaultValue,
]) {
  if (apiV1AppsAppIdDeploymentTargetsPost$ResponseKind == null) {
    return null;
  }
  return enums.ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind.values
          .firstWhereOrNull(
            (e) => e.value == apiV1AppsAppIdDeploymentTargetsPost$ResponseKind,
          ) ??
      defaultValue;
}

String apiV1AppsAppIdDeploymentTargetsPost$ResponseKindExplodedListToJson(
  List<enums.ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind>?
  apiV1AppsAppIdDeploymentTargetsPost$ResponseKind,
) {
  return apiV1AppsAppIdDeploymentTargetsPost$ResponseKind
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1AppsAppIdDeploymentTargetsPost$ResponseKindListToJson(
  List<enums.ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind>?
  apiV1AppsAppIdDeploymentTargetsPost$ResponseKind,
) {
  if (apiV1AppsAppIdDeploymentTargetsPost$ResponseKind == null) {
    return [];
  }

  return apiV1AppsAppIdDeploymentTargetsPost$ResponseKind
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind>
apiV1AppsAppIdDeploymentTargetsPost$ResponseKindListFromJson(
  List? apiV1AppsAppIdDeploymentTargetsPost$ResponseKind, [
  List<enums.ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind>? defaultValue,
]) {
  if (apiV1AppsAppIdDeploymentTargetsPost$ResponseKind == null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdDeploymentTargetsPost$ResponseKind
      .map(
        (e) => apiV1AppsAppIdDeploymentTargetsPost$ResponseKindFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind>?
apiV1AppsAppIdDeploymentTargetsPost$ResponseKindNullableListFromJson(
  List? apiV1AppsAppIdDeploymentTargetsPost$ResponseKind, [
  List<enums.ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind>? defaultValue,
]) {
  if (apiV1AppsAppIdDeploymentTargetsPost$ResponseKind == null) {
    return defaultValue;
  }

  return apiV1AppsAppIdDeploymentTargetsPost$ResponseKind
      .map(
        (e) => apiV1AppsAppIdDeploymentTargetsPost$ResponseKindFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatformNullableToJson(
  enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform?
  apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform,
) {
  return apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform?.value;
}

String? apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatformToJson(
  enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform
  apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform,
) {
  return apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform.value;
}

enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform
apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatformFromJson(
  Object? apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform, [
  enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform? defaultValue,
]) {
  return enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform.values
          .firstWhereOrNull(
            (e) =>
                e.value == apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform?
apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatformNullableFromJson(
  Object? apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform, [
  enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform? defaultValue,
]) {
  if (apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform == null) {
    return null;
  }
  return enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform.values
          .firstWhereOrNull(
            (e) =>
                e.value == apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform,
          ) ??
      defaultValue;
}

String apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatformExplodedListToJson(
  List<enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform>?
  apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform,
) {
  return apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatformListToJson(
  List<enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform>?
  apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform,
) {
  if (apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform == null) {
    return [];
  }

  return apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform>
apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatformListFromJson(
  List? apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform, [
  List<enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform>?
  defaultValue,
]) {
  if (apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform == null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform
      .map(
        (e) => apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatformFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform>?
apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatformNullableListFromJson(
  List? apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform, [
  List<enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform>?
  defaultValue,
]) {
  if (apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform == null) {
    return defaultValue;
  }

  return apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform
      .map(
        (e) => apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatformFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1AppsAppIdBuildProfilesGet$Response$ItemArchNullableToJson(
  enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch?
  apiV1AppsAppIdBuildProfilesGet$Response$ItemArch,
) {
  return apiV1AppsAppIdBuildProfilesGet$Response$ItemArch?.value;
}

String? apiV1AppsAppIdBuildProfilesGet$Response$ItemArchToJson(
  enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch
  apiV1AppsAppIdBuildProfilesGet$Response$ItemArch,
) {
  return apiV1AppsAppIdBuildProfilesGet$Response$ItemArch.value;
}

enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch
apiV1AppsAppIdBuildProfilesGet$Response$ItemArchFromJson(
  Object? apiV1AppsAppIdBuildProfilesGet$Response$ItemArch, [
  enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch? defaultValue,
]) {
  return enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch.values
          .firstWhereOrNull(
            (e) => e.value == apiV1AppsAppIdBuildProfilesGet$Response$ItemArch,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch?
apiV1AppsAppIdBuildProfilesGet$Response$ItemArchNullableFromJson(
  Object? apiV1AppsAppIdBuildProfilesGet$Response$ItemArch, [
  enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch? defaultValue,
]) {
  if (apiV1AppsAppIdBuildProfilesGet$Response$ItemArch == null) {
    return null;
  }
  return enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch.values
          .firstWhereOrNull(
            (e) => e.value == apiV1AppsAppIdBuildProfilesGet$Response$ItemArch,
          ) ??
      defaultValue;
}

String apiV1AppsAppIdBuildProfilesGet$Response$ItemArchExplodedListToJson(
  List<enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch>?
  apiV1AppsAppIdBuildProfilesGet$Response$ItemArch,
) {
  return apiV1AppsAppIdBuildProfilesGet$Response$ItemArch
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1AppsAppIdBuildProfilesGet$Response$ItemArchListToJson(
  List<enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch>?
  apiV1AppsAppIdBuildProfilesGet$Response$ItemArch,
) {
  if (apiV1AppsAppIdBuildProfilesGet$Response$ItemArch == null) {
    return [];
  }

  return apiV1AppsAppIdBuildProfilesGet$Response$ItemArch
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch>
apiV1AppsAppIdBuildProfilesGet$Response$ItemArchListFromJson(
  List? apiV1AppsAppIdBuildProfilesGet$Response$ItemArch, [
  List<enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch>? defaultValue,
]) {
  if (apiV1AppsAppIdBuildProfilesGet$Response$ItemArch == null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdBuildProfilesGet$Response$ItemArch
      .map(
        (e) => apiV1AppsAppIdBuildProfilesGet$Response$ItemArchFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch>?
apiV1AppsAppIdBuildProfilesGet$Response$ItemArchNullableListFromJson(
  List? apiV1AppsAppIdBuildProfilesGet$Response$ItemArch, [
  List<enums.ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch>? defaultValue,
]) {
  if (apiV1AppsAppIdBuildProfilesGet$Response$ItemArch == null) {
    return defaultValue;
  }

  return apiV1AppsAppIdBuildProfilesGet$Response$ItemArch
      .map(
        (e) => apiV1AppsAppIdBuildProfilesGet$Response$ItemArchFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1AppsAppIdBuildProfilesPost$ResponsePlatformNullableToJson(
  enums.ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform?
  apiV1AppsAppIdBuildProfilesPost$ResponsePlatform,
) {
  return apiV1AppsAppIdBuildProfilesPost$ResponsePlatform?.value;
}

String? apiV1AppsAppIdBuildProfilesPost$ResponsePlatformToJson(
  enums.ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform
  apiV1AppsAppIdBuildProfilesPost$ResponsePlatform,
) {
  return apiV1AppsAppIdBuildProfilesPost$ResponsePlatform.value;
}

enums.ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform
apiV1AppsAppIdBuildProfilesPost$ResponsePlatformFromJson(
  Object? apiV1AppsAppIdBuildProfilesPost$ResponsePlatform, [
  enums.ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform? defaultValue,
]) {
  return enums.ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform.values
          .firstWhereOrNull(
            (e) => e.value == apiV1AppsAppIdBuildProfilesPost$ResponsePlatform,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform?
apiV1AppsAppIdBuildProfilesPost$ResponsePlatformNullableFromJson(
  Object? apiV1AppsAppIdBuildProfilesPost$ResponsePlatform, [
  enums.ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform? defaultValue,
]) {
  if (apiV1AppsAppIdBuildProfilesPost$ResponsePlatform == null) {
    return null;
  }
  return enums.ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform.values
          .firstWhereOrNull(
            (e) => e.value == apiV1AppsAppIdBuildProfilesPost$ResponsePlatform,
          ) ??
      defaultValue;
}

String apiV1AppsAppIdBuildProfilesPost$ResponsePlatformExplodedListToJson(
  List<enums.ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform>?
  apiV1AppsAppIdBuildProfilesPost$ResponsePlatform,
) {
  return apiV1AppsAppIdBuildProfilesPost$ResponsePlatform
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1AppsAppIdBuildProfilesPost$ResponsePlatformListToJson(
  List<enums.ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform>?
  apiV1AppsAppIdBuildProfilesPost$ResponsePlatform,
) {
  if (apiV1AppsAppIdBuildProfilesPost$ResponsePlatform == null) {
    return [];
  }

  return apiV1AppsAppIdBuildProfilesPost$ResponsePlatform
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform>
apiV1AppsAppIdBuildProfilesPost$ResponsePlatformListFromJson(
  List? apiV1AppsAppIdBuildProfilesPost$ResponsePlatform, [
  List<enums.ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform>? defaultValue,
]) {
  if (apiV1AppsAppIdBuildProfilesPost$ResponsePlatform == null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdBuildProfilesPost$ResponsePlatform
      .map(
        (e) => apiV1AppsAppIdBuildProfilesPost$ResponsePlatformFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform>?
apiV1AppsAppIdBuildProfilesPost$ResponsePlatformNullableListFromJson(
  List? apiV1AppsAppIdBuildProfilesPost$ResponsePlatform, [
  List<enums.ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform>? defaultValue,
]) {
  if (apiV1AppsAppIdBuildProfilesPost$ResponsePlatform == null) {
    return defaultValue;
  }

  return apiV1AppsAppIdBuildProfilesPost$ResponsePlatform
      .map(
        (e) => apiV1AppsAppIdBuildProfilesPost$ResponsePlatformFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1AppsAppIdBuildProfilesPost$ResponseArchNullableToJson(
  enums.ApiV1AppsAppIdBuildProfilesPost$ResponseArch?
  apiV1AppsAppIdBuildProfilesPost$ResponseArch,
) {
  return apiV1AppsAppIdBuildProfilesPost$ResponseArch?.value;
}

String? apiV1AppsAppIdBuildProfilesPost$ResponseArchToJson(
  enums.ApiV1AppsAppIdBuildProfilesPost$ResponseArch
  apiV1AppsAppIdBuildProfilesPost$ResponseArch,
) {
  return apiV1AppsAppIdBuildProfilesPost$ResponseArch.value;
}

enums.ApiV1AppsAppIdBuildProfilesPost$ResponseArch
apiV1AppsAppIdBuildProfilesPost$ResponseArchFromJson(
  Object? apiV1AppsAppIdBuildProfilesPost$ResponseArch, [
  enums.ApiV1AppsAppIdBuildProfilesPost$ResponseArch? defaultValue,
]) {
  return enums.ApiV1AppsAppIdBuildProfilesPost$ResponseArch.values
          .firstWhereOrNull(
            (e) => e.value == apiV1AppsAppIdBuildProfilesPost$ResponseArch,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdBuildProfilesPost$ResponseArch
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdBuildProfilesPost$ResponseArch?
apiV1AppsAppIdBuildProfilesPost$ResponseArchNullableFromJson(
  Object? apiV1AppsAppIdBuildProfilesPost$ResponseArch, [
  enums.ApiV1AppsAppIdBuildProfilesPost$ResponseArch? defaultValue,
]) {
  if (apiV1AppsAppIdBuildProfilesPost$ResponseArch == null) {
    return null;
  }
  return enums.ApiV1AppsAppIdBuildProfilesPost$ResponseArch.values
          .firstWhereOrNull(
            (e) => e.value == apiV1AppsAppIdBuildProfilesPost$ResponseArch,
          ) ??
      defaultValue;
}

String apiV1AppsAppIdBuildProfilesPost$ResponseArchExplodedListToJson(
  List<enums.ApiV1AppsAppIdBuildProfilesPost$ResponseArch>?
  apiV1AppsAppIdBuildProfilesPost$ResponseArch,
) {
  return apiV1AppsAppIdBuildProfilesPost$ResponseArch
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1AppsAppIdBuildProfilesPost$ResponseArchListToJson(
  List<enums.ApiV1AppsAppIdBuildProfilesPost$ResponseArch>?
  apiV1AppsAppIdBuildProfilesPost$ResponseArch,
) {
  if (apiV1AppsAppIdBuildProfilesPost$ResponseArch == null) {
    return [];
  }

  return apiV1AppsAppIdBuildProfilesPost$ResponseArch
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdBuildProfilesPost$ResponseArch>
apiV1AppsAppIdBuildProfilesPost$ResponseArchListFromJson(
  List? apiV1AppsAppIdBuildProfilesPost$ResponseArch, [
  List<enums.ApiV1AppsAppIdBuildProfilesPost$ResponseArch>? defaultValue,
]) {
  if (apiV1AppsAppIdBuildProfilesPost$ResponseArch == null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdBuildProfilesPost$ResponseArch
      .map(
        (e) =>
            apiV1AppsAppIdBuildProfilesPost$ResponseArchFromJson(e.toString()),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdBuildProfilesPost$ResponseArch>?
apiV1AppsAppIdBuildProfilesPost$ResponseArchNullableListFromJson(
  List? apiV1AppsAppIdBuildProfilesPost$ResponseArch, [
  List<enums.ApiV1AppsAppIdBuildProfilesPost$ResponseArch>? defaultValue,
]) {
  if (apiV1AppsAppIdBuildProfilesPost$ResponseArch == null) {
    return defaultValue;
  }

  return apiV1AppsAppIdBuildProfilesPost$ResponseArch
      .map(
        (e) =>
            apiV1AppsAppIdBuildProfilesPost$ResponseArchFromJson(e.toString()),
      )
      .toList();
}

String? apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerModeNullableToJson(
  enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode?
  apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode,
) {
  return apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode?.value;
}

String? apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerModeToJson(
  enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode
  apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode,
) {
  return apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode.value;
}

enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode
apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerModeFromJson(
  Object? apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode, [
  enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode? defaultValue,
]) {
  return enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode?
apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerModeNullableFromJson(
  Object? apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode, [
  enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode? defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode == null) {
    return null;
  }
  return enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode,
          ) ??
      defaultValue;
}

String apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerModeExplodedListToJson(
  List<enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode>?
  apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode,
) {
  return apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerModeListToJson(
  List<enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode>?
  apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode,
) {
  if (apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode == null) {
    return [];
  }

  return apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode>
apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerModeListFromJson(
  List? apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode, [
  List<enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode>?
  defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode == null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode
      .map(
        (e) => apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerModeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode>?
apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerModeNullableListFromJson(
  List? apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode, [
  List<enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode>?
  defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode == null) {
    return defaultValue;
  }

  return apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode
      .map(
        (e) => apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerModeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1AppsAppIdPipelineRunsGet$Response$ItemStatusNullableToJson(
  enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus?
  apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus,
) {
  return apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus?.value;
}

String? apiV1AppsAppIdPipelineRunsGet$Response$ItemStatusToJson(
  enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus
  apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus,
) {
  return apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus.value;
}

enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus
apiV1AppsAppIdPipelineRunsGet$Response$ItemStatusFromJson(
  Object? apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus, [
  enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus? defaultValue,
]) {
  return enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus.values
          .firstWhereOrNull(
            (e) => e.value == apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus?
apiV1AppsAppIdPipelineRunsGet$Response$ItemStatusNullableFromJson(
  Object? apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus, [
  enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus? defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus == null) {
    return null;
  }
  return enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus.values
          .firstWhereOrNull(
            (e) => e.value == apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus,
          ) ??
      defaultValue;
}

String apiV1AppsAppIdPipelineRunsGet$Response$ItemStatusExplodedListToJson(
  List<enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus>?
  apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus,
) {
  return apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1AppsAppIdPipelineRunsGet$Response$ItemStatusListToJson(
  List<enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus>?
  apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus,
) {
  if (apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus == null) {
    return [];
  }

  return apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus>
apiV1AppsAppIdPipelineRunsGet$Response$ItemStatusListFromJson(
  List? apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus, [
  List<enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus>? defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus == null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus
      .map(
        (e) => apiV1AppsAppIdPipelineRunsGet$Response$ItemStatusFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus>?
apiV1AppsAppIdPipelineRunsGet$Response$ItemStatusNullableListFromJson(
  List? apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus, [
  List<enums.ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus>? defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus == null) {
    return defaultValue;
  }

  return apiV1AppsAppIdPipelineRunsGet$Response$ItemStatus
      .map(
        (e) => apiV1AppsAppIdPipelineRunsGet$Response$ItemStatusFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1AppsAppIdPipelineRunsPost$ResponseTriggerModeNullableToJson(
  enums.ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode?
  apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode,
) {
  return apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode?.value;
}

String? apiV1AppsAppIdPipelineRunsPost$ResponseTriggerModeToJson(
  enums.ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode
  apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode,
) {
  return apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode.value;
}

enums.ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode
apiV1AppsAppIdPipelineRunsPost$ResponseTriggerModeFromJson(
  Object? apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode, [
  enums.ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode? defaultValue,
]) {
  return enums.ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode.values
          .firstWhereOrNull(
            (e) =>
                e.value == apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode?
apiV1AppsAppIdPipelineRunsPost$ResponseTriggerModeNullableFromJson(
  Object? apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode, [
  enums.ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode? defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode == null) {
    return null;
  }
  return enums.ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode.values
          .firstWhereOrNull(
            (e) =>
                e.value == apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode,
          ) ??
      defaultValue;
}

String apiV1AppsAppIdPipelineRunsPost$ResponseTriggerModeExplodedListToJson(
  List<enums.ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode>?
  apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode,
) {
  return apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1AppsAppIdPipelineRunsPost$ResponseTriggerModeListToJson(
  List<enums.ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode>?
  apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode,
) {
  if (apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode == null) {
    return [];
  }

  return apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode>
apiV1AppsAppIdPipelineRunsPost$ResponseTriggerModeListFromJson(
  List? apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode, [
  List<enums.ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode>? defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode == null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode
      .map(
        (e) => apiV1AppsAppIdPipelineRunsPost$ResponseTriggerModeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode>?
apiV1AppsAppIdPipelineRunsPost$ResponseTriggerModeNullableListFromJson(
  List? apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode, [
  List<enums.ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode>? defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode == null) {
    return defaultValue;
  }

  return apiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode
      .map(
        (e) => apiV1AppsAppIdPipelineRunsPost$ResponseTriggerModeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1AppsAppIdPipelineRunsPost$ResponseStatusNullableToJson(
  enums.ApiV1AppsAppIdPipelineRunsPost$ResponseStatus?
  apiV1AppsAppIdPipelineRunsPost$ResponseStatus,
) {
  return apiV1AppsAppIdPipelineRunsPost$ResponseStatus?.value;
}

String? apiV1AppsAppIdPipelineRunsPost$ResponseStatusToJson(
  enums.ApiV1AppsAppIdPipelineRunsPost$ResponseStatus
  apiV1AppsAppIdPipelineRunsPost$ResponseStatus,
) {
  return apiV1AppsAppIdPipelineRunsPost$ResponseStatus.value;
}

enums.ApiV1AppsAppIdPipelineRunsPost$ResponseStatus
apiV1AppsAppIdPipelineRunsPost$ResponseStatusFromJson(
  Object? apiV1AppsAppIdPipelineRunsPost$ResponseStatus, [
  enums.ApiV1AppsAppIdPipelineRunsPost$ResponseStatus? defaultValue,
]) {
  return enums.ApiV1AppsAppIdPipelineRunsPost$ResponseStatus.values
          .firstWhereOrNull(
            (e) => e.value == apiV1AppsAppIdPipelineRunsPost$ResponseStatus,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdPipelineRunsPost$ResponseStatus
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdPipelineRunsPost$ResponseStatus?
apiV1AppsAppIdPipelineRunsPost$ResponseStatusNullableFromJson(
  Object? apiV1AppsAppIdPipelineRunsPost$ResponseStatus, [
  enums.ApiV1AppsAppIdPipelineRunsPost$ResponseStatus? defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$ResponseStatus == null) {
    return null;
  }
  return enums.ApiV1AppsAppIdPipelineRunsPost$ResponseStatus.values
          .firstWhereOrNull(
            (e) => e.value == apiV1AppsAppIdPipelineRunsPost$ResponseStatus,
          ) ??
      defaultValue;
}

String apiV1AppsAppIdPipelineRunsPost$ResponseStatusExplodedListToJson(
  List<enums.ApiV1AppsAppIdPipelineRunsPost$ResponseStatus>?
  apiV1AppsAppIdPipelineRunsPost$ResponseStatus,
) {
  return apiV1AppsAppIdPipelineRunsPost$ResponseStatus
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1AppsAppIdPipelineRunsPost$ResponseStatusListToJson(
  List<enums.ApiV1AppsAppIdPipelineRunsPost$ResponseStatus>?
  apiV1AppsAppIdPipelineRunsPost$ResponseStatus,
) {
  if (apiV1AppsAppIdPipelineRunsPost$ResponseStatus == null) {
    return [];
  }

  return apiV1AppsAppIdPipelineRunsPost$ResponseStatus
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdPipelineRunsPost$ResponseStatus>
apiV1AppsAppIdPipelineRunsPost$ResponseStatusListFromJson(
  List? apiV1AppsAppIdPipelineRunsPost$ResponseStatus, [
  List<enums.ApiV1AppsAppIdPipelineRunsPost$ResponseStatus>? defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$ResponseStatus == null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdPipelineRunsPost$ResponseStatus
      .map(
        (e) =>
            apiV1AppsAppIdPipelineRunsPost$ResponseStatusFromJson(e.toString()),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdPipelineRunsPost$ResponseStatus>?
apiV1AppsAppIdPipelineRunsPost$ResponseStatusNullableListFromJson(
  List? apiV1AppsAppIdPipelineRunsPost$ResponseStatus, [
  List<enums.ApiV1AppsAppIdPipelineRunsPost$ResponseStatus>? defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$ResponseStatus == null) {
    return defaultValue;
  }

  return apiV1AppsAppIdPipelineRunsPost$ResponseStatus
      .map(
        (e) =>
            apiV1AppsAppIdPipelineRunsPost$ResponseStatusFromJson(e.toString()),
      )
      .toList();
}

String? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatformNullableToJson(
  enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform?
  apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform,
) {
  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform?.value;
}

String? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatformToJson(
  enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform
  apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform,
) {
  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform.value;
}

enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatformFromJson(
  Object? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform, [
  enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform? defaultValue,
]) {
  return enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform?
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatformNullableFromJson(
  Object? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform, [
  enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform? defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform == null) {
    return null;
  }
  return enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform,
          ) ??
      defaultValue;
}

String
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatformExplodedListToJson(
  List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform>?
  apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform,
) {
  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatformListToJson(
  List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform>?
  apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform,
) {
  if (apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform == null) {
    return [];
  }

  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform>
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatformListFromJson(
  List? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform, [
  List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform>?
  defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform == null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform
      .map(
        (e) =>
            apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatformFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform>?
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatformNullableListFromJson(
  List? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform, [
  List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform>?
  defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform == null) {
    return defaultValue;
  }

  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform
      .map(
        (e) =>
            apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatformFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArchNullableToJson(
  enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch?
  apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch,
) {
  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch?.value;
}

String? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArchToJson(
  enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch
  apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch,
) {
  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch.value;
}

enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArchFromJson(
  Object? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch, [
  enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch? defaultValue,
]) {
  return enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch?
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArchNullableFromJson(
  Object? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch, [
  enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch? defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch == null) {
    return null;
  }
  return enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch,
          ) ??
      defaultValue;
}

String apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArchExplodedListToJson(
  List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch>?
  apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch,
) {
  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArchListToJson(
  List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch>?
  apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch,
) {
  if (apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch == null) {
    return [];
  }

  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch>
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArchListFromJson(
  List? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch, [
  List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch>?
  defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch == null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch
      .map(
        (e) => apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArchFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch>?
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArchNullableListFromJson(
  List? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch, [
  List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch>?
  defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch == null) {
    return defaultValue;
  }

  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch
      .map(
        (e) => apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArchFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatusNullableToJson(
  enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus?
  apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus,
) {
  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus?.value;
}

String? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatusToJson(
  enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus
  apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus,
) {
  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus.value;
}

enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatusFromJson(
  Object? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus, [
  enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus? defaultValue,
]) {
  return enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus?
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatusNullableFromJson(
  Object? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus, [
  enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus? defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus == null) {
    return null;
  }
  return enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus,
          ) ??
      defaultValue;
}

String
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatusExplodedListToJson(
  List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus>?
  apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus,
) {
  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatusListToJson(
  List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus>?
  apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus,
) {
  if (apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus == null) {
    return [];
  }

  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus>
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatusListFromJson(
  List? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus, [
  List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus>?
  defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus == null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus
      .map(
        (e) => apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatusFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus>?
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatusNullableListFromJson(
  List? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus, [
  List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus>?
  defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus == null) {
    return defaultValue;
  }

  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus
      .map(
        (e) => apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatusFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String?
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatusNullableToJson(
  enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus?
  apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus,
) {
  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus
      ?.value;
}

String? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatusToJson(
  enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus
  apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus,
) {
  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus
      .value;
}

enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatusFromJson(
  Object? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus, [
  enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus?
  defaultValue,
]) {
  return enums
          .ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus?
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatusNullableFromJson(
  Object? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus, [
  enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus?
  defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus ==
      null) {
    return null;
  }
  return enums
          .ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus,
          ) ??
      defaultValue;
}

String
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatusExplodedListToJson(
  List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus>?
  apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus,
) {
  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatusListToJson(
  List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus>?
  apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus,
) {
  if (apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus ==
      null) {
    return [];
  }

  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus>
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatusListFromJson(
  List? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus, [
  List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus>?
  defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus ==
      null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus
      .map(
        (e) =>
            apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatusFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus>?
apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatusNullableListFromJson(
  List? apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus, [
  List<enums.ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus>?
  defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus ==
      null) {
    return defaultValue;
  }

  return apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus
      .map(
        (e) =>
            apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatusFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String? apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerModeNullableToJson(
  enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode?
  apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode,
) {
  return apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode?.value;
}

String? apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerModeToJson(
  enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode
  apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode,
) {
  return apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode.value;
}

enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode
apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerModeFromJson(
  Object? apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode, [
  enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode? defaultValue,
]) {
  return enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode,
          ) ??
      defaultValue ??
      enums
          .ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode
          .swaggerGeneratedUnknown;
}

enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode?
apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerModeNullableFromJson(
  Object? apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode, [
  enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode? defaultValue,
]) {
  if (apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode == null) {
    return null;
  }
  return enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode,
          ) ??
      defaultValue;
}

String apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerModeExplodedListToJson(
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode>?
  apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode,
) {
  return apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerModeListToJson(
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode>?
  apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode,
) {
  if (apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode == null) {
    return [];
  }

  return apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode>
apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerModeListFromJson(
  List? apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode, [
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode>?
  defaultValue,
]) {
  if (apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode == null) {
    return defaultValue ?? [];
  }

  return apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode
      .map(
        (e) => apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerModeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode>?
apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerModeNullableListFromJson(
  List? apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode, [
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode>?
  defaultValue,
]) {
  if (apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode == null) {
    return defaultValue;
  }

  return apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode
      .map(
        (e) => apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerModeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1PipelineRunsPipelineRunIdGet$ResponseStatusNullableToJson(
  enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus?
  apiV1PipelineRunsPipelineRunIdGet$ResponseStatus,
) {
  return apiV1PipelineRunsPipelineRunIdGet$ResponseStatus?.value;
}

String? apiV1PipelineRunsPipelineRunIdGet$ResponseStatusToJson(
  enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus
  apiV1PipelineRunsPipelineRunIdGet$ResponseStatus,
) {
  return apiV1PipelineRunsPipelineRunIdGet$ResponseStatus.value;
}

enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus
apiV1PipelineRunsPipelineRunIdGet$ResponseStatusFromJson(
  Object? apiV1PipelineRunsPipelineRunIdGet$ResponseStatus, [
  enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus? defaultValue,
]) {
  return enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus.values
          .firstWhereOrNull(
            (e) => e.value == apiV1PipelineRunsPipelineRunIdGet$ResponseStatus,
          ) ??
      defaultValue ??
      enums
          .ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus
          .swaggerGeneratedUnknown;
}

enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus?
apiV1PipelineRunsPipelineRunIdGet$ResponseStatusNullableFromJson(
  Object? apiV1PipelineRunsPipelineRunIdGet$ResponseStatus, [
  enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus? defaultValue,
]) {
  if (apiV1PipelineRunsPipelineRunIdGet$ResponseStatus == null) {
    return null;
  }
  return enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus.values
          .firstWhereOrNull(
            (e) => e.value == apiV1PipelineRunsPipelineRunIdGet$ResponseStatus,
          ) ??
      defaultValue;
}

String apiV1PipelineRunsPipelineRunIdGet$ResponseStatusExplodedListToJson(
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus>?
  apiV1PipelineRunsPipelineRunIdGet$ResponseStatus,
) {
  return apiV1PipelineRunsPipelineRunIdGet$ResponseStatus
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1PipelineRunsPipelineRunIdGet$ResponseStatusListToJson(
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus>?
  apiV1PipelineRunsPipelineRunIdGet$ResponseStatus,
) {
  if (apiV1PipelineRunsPipelineRunIdGet$ResponseStatus == null) {
    return [];
  }

  return apiV1PipelineRunsPipelineRunIdGet$ResponseStatus
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus>
apiV1PipelineRunsPipelineRunIdGet$ResponseStatusListFromJson(
  List? apiV1PipelineRunsPipelineRunIdGet$ResponseStatus, [
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus>? defaultValue,
]) {
  if (apiV1PipelineRunsPipelineRunIdGet$ResponseStatus == null) {
    return defaultValue ?? [];
  }

  return apiV1PipelineRunsPipelineRunIdGet$ResponseStatus
      .map(
        (e) => apiV1PipelineRunsPipelineRunIdGet$ResponseStatusFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus>?
apiV1PipelineRunsPipelineRunIdGet$ResponseStatusNullableListFromJson(
  List? apiV1PipelineRunsPipelineRunIdGet$ResponseStatus, [
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus>? defaultValue,
]) {
  if (apiV1PipelineRunsPipelineRunIdGet$ResponseStatus == null) {
    return defaultValue;
  }

  return apiV1PipelineRunsPipelineRunIdGet$ResponseStatus
      .map(
        (e) => apiV1PipelineRunsPipelineRunIdGet$ResponseStatusFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String?
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatformNullableToJson(
  enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform?
  apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform,
) {
  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform?.value;
}

String? apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatformToJson(
  enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform
  apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform,
) {
  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform.value;
}

enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatformFromJson(
  Object? apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform, [
  enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform?
  defaultValue,
]) {
  return enums
          .ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform,
          ) ??
      defaultValue ??
      enums
          .ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform
          .swaggerGeneratedUnknown;
}

enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform?
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatformNullableFromJson(
  Object? apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform, [
  enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform?
  defaultValue,
]) {
  if (apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform == null) {
    return null;
  }
  return enums
          .ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform,
          ) ??
      defaultValue;
}

String
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatformExplodedListToJson(
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform>?
  apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform,
) {
  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatformListToJson(
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform>?
  apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform,
) {
  if (apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform == null) {
    return [];
  }

  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform>
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatformListFromJson(
  List? apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform, [
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform>?
  defaultValue,
]) {
  if (apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform == null) {
    return defaultValue ?? [];
  }

  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform
      .map(
        (e) =>
            apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatformFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform>?
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatformNullableListFromJson(
  List? apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform, [
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform>?
  defaultValue,
]) {
  if (apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform == null) {
    return defaultValue;
  }

  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform
      .map(
        (e) =>
            apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatformFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String? apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArchNullableToJson(
  enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch?
  apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch,
) {
  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch?.value;
}

String? apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArchToJson(
  enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch
  apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch,
) {
  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch.value;
}

enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArchFromJson(
  Object? apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch, [
  enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch? defaultValue,
]) {
  return enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch,
          ) ??
      defaultValue ??
      enums
          .ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch
          .swaggerGeneratedUnknown;
}

enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch?
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArchNullableFromJson(
  Object? apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch, [
  enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch? defaultValue,
]) {
  if (apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch == null) {
    return null;
  }
  return enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch,
          ) ??
      defaultValue;
}

String
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArchExplodedListToJson(
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch>?
  apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch,
) {
  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArchListToJson(
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch>?
  apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch,
) {
  if (apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch == null) {
    return [];
  }

  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch>
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArchListFromJson(
  List? apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch, [
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch>?
  defaultValue,
]) {
  if (apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch == null) {
    return defaultValue ?? [];
  }

  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch
      .map(
        (e) => apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArchFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch>?
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArchNullableListFromJson(
  List? apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch, [
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch>?
  defaultValue,
]) {
  if (apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch == null) {
    return defaultValue;
  }

  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch
      .map(
        (e) => apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArchFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String?
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatusNullableToJson(
  enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus?
  apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus,
) {
  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus?.value;
}

String? apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatusToJson(
  enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus
  apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus,
) {
  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus.value;
}

enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatusFromJson(
  Object? apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus, [
  enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus?
  defaultValue,
]) {
  return enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus,
          ) ??
      defaultValue ??
      enums
          .ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus
          .swaggerGeneratedUnknown;
}

enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus?
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatusNullableFromJson(
  Object? apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus, [
  enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus?
  defaultValue,
]) {
  if (apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus == null) {
    return null;
  }
  return enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus,
          ) ??
      defaultValue;
}

String
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatusExplodedListToJson(
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus>?
  apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus,
) {
  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatusListToJson(
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus>?
  apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus,
) {
  if (apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus == null) {
    return [];
  }

  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus>
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatusListFromJson(
  List? apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus, [
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus>?
  defaultValue,
]) {
  if (apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus == null) {
    return defaultValue ?? [];
  }

  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus
      .map(
        (e) =>
            apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatusFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus>?
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatusNullableListFromJson(
  List? apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus, [
  List<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus>?
  defaultValue,
]) {
  if (apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus == null) {
    return defaultValue;
  }

  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus
      .map(
        (e) =>
            apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatusFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String?
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatusNullableToJson(
  enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus?
  apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus,
) {
  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus
      ?.value;
}

String?
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatusToJson(
  enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus
  apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus,
) {
  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus
      .value;
}

enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatusFromJson(
  Object?
  apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus, [
  enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus?
  defaultValue,
]) {
  return enums
          .ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus,
          ) ??
      defaultValue ??
      enums
          .ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus
          .swaggerGeneratedUnknown;
}

enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus?
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatusNullableFromJson(
  Object?
  apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus, [
  enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus?
  defaultValue,
]) {
  if (apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus ==
      null) {
    return null;
  }
  return enums
          .ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus,
          ) ??
      defaultValue;
}

String
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatusExplodedListToJson(
  List<
    enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus
  >?
  apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus,
) {
  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatusListToJson(
  List<
    enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus
  >?
  apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus,
) {
  if (apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus ==
      null) {
    return [];
  }

  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus>
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatusListFromJson(
  List? apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus, [
  List<
    enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus
  >?
  defaultValue,
]) {
  if (apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus ==
      null) {
    return defaultValue ?? [];
  }

  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus
      .map(
        (e) =>
            apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatusFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<
  enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus
>?
apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatusNullableListFromJson(
  List? apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus, [
  List<
    enums.ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus
  >?
  defaultValue,
]) {
  if (apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus ==
      null) {
    return defaultValue;
  }

  return apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus
      .map(
        (e) =>
            apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatusFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String? apiV1ChannelsGet$Response$ItemKindNullableToJson(
  enums.ApiV1ChannelsGet$Response$ItemKind? apiV1ChannelsGet$Response$ItemKind,
) {
  return apiV1ChannelsGet$Response$ItemKind?.value;
}

String? apiV1ChannelsGet$Response$ItemKindToJson(
  enums.ApiV1ChannelsGet$Response$ItemKind apiV1ChannelsGet$Response$ItemKind,
) {
  return apiV1ChannelsGet$Response$ItemKind.value;
}

enums.ApiV1ChannelsGet$Response$ItemKind
apiV1ChannelsGet$Response$ItemKindFromJson(
  Object? apiV1ChannelsGet$Response$ItemKind, [
  enums.ApiV1ChannelsGet$Response$ItemKind? defaultValue,
]) {
  return enums.ApiV1ChannelsGet$Response$ItemKind.values.firstWhereOrNull(
        (e) => e.value == apiV1ChannelsGet$Response$ItemKind,
      ) ??
      defaultValue ??
      enums.ApiV1ChannelsGet$Response$ItemKind.swaggerGeneratedUnknown;
}

enums.ApiV1ChannelsGet$Response$ItemKind?
apiV1ChannelsGet$Response$ItemKindNullableFromJson(
  Object? apiV1ChannelsGet$Response$ItemKind, [
  enums.ApiV1ChannelsGet$Response$ItemKind? defaultValue,
]) {
  if (apiV1ChannelsGet$Response$ItemKind == null) {
    return null;
  }
  return enums.ApiV1ChannelsGet$Response$ItemKind.values.firstWhereOrNull(
        (e) => e.value == apiV1ChannelsGet$Response$ItemKind,
      ) ??
      defaultValue;
}

String apiV1ChannelsGet$Response$ItemKindExplodedListToJson(
  List<enums.ApiV1ChannelsGet$Response$ItemKind>?
  apiV1ChannelsGet$Response$ItemKind,
) {
  return apiV1ChannelsGet$Response$ItemKind?.map((e) => e.value!).join(',') ??
      '';
}

List<String> apiV1ChannelsGet$Response$ItemKindListToJson(
  List<enums.ApiV1ChannelsGet$Response$ItemKind>?
  apiV1ChannelsGet$Response$ItemKind,
) {
  if (apiV1ChannelsGet$Response$ItemKind == null) {
    return [];
  }

  return apiV1ChannelsGet$Response$ItemKind.map((e) => e.value!).toList();
}

List<enums.ApiV1ChannelsGet$Response$ItemKind>
apiV1ChannelsGet$Response$ItemKindListFromJson(
  List? apiV1ChannelsGet$Response$ItemKind, [
  List<enums.ApiV1ChannelsGet$Response$ItemKind>? defaultValue,
]) {
  if (apiV1ChannelsGet$Response$ItemKind == null) {
    return defaultValue ?? [];
  }

  return apiV1ChannelsGet$Response$ItemKind
      .map((e) => apiV1ChannelsGet$Response$ItemKindFromJson(e.toString()))
      .toList();
}

List<enums.ApiV1ChannelsGet$Response$ItemKind>?
apiV1ChannelsGet$Response$ItemKindNullableListFromJson(
  List? apiV1ChannelsGet$Response$ItemKind, [
  List<enums.ApiV1ChannelsGet$Response$ItemKind>? defaultValue,
]) {
  if (apiV1ChannelsGet$Response$ItemKind == null) {
    return defaultValue;
  }

  return apiV1ChannelsGet$Response$ItemKind
      .map((e) => apiV1ChannelsGet$Response$ItemKindFromJson(e.toString()))
      .toList();
}

String? apiV1ChannelsGet$Response$ItemVisibilityNullableToJson(
  enums.ApiV1ChannelsGet$Response$ItemVisibility?
  apiV1ChannelsGet$Response$ItemVisibility,
) {
  return apiV1ChannelsGet$Response$ItemVisibility?.value;
}

String? apiV1ChannelsGet$Response$ItemVisibilityToJson(
  enums.ApiV1ChannelsGet$Response$ItemVisibility
  apiV1ChannelsGet$Response$ItemVisibility,
) {
  return apiV1ChannelsGet$Response$ItemVisibility.value;
}

enums.ApiV1ChannelsGet$Response$ItemVisibility
apiV1ChannelsGet$Response$ItemVisibilityFromJson(
  Object? apiV1ChannelsGet$Response$ItemVisibility, [
  enums.ApiV1ChannelsGet$Response$ItemVisibility? defaultValue,
]) {
  return enums.ApiV1ChannelsGet$Response$ItemVisibility.values.firstWhereOrNull(
        (e) => e.value == apiV1ChannelsGet$Response$ItemVisibility,
      ) ??
      defaultValue ??
      enums.ApiV1ChannelsGet$Response$ItemVisibility.swaggerGeneratedUnknown;
}

enums.ApiV1ChannelsGet$Response$ItemVisibility?
apiV1ChannelsGet$Response$ItemVisibilityNullableFromJson(
  Object? apiV1ChannelsGet$Response$ItemVisibility, [
  enums.ApiV1ChannelsGet$Response$ItemVisibility? defaultValue,
]) {
  if (apiV1ChannelsGet$Response$ItemVisibility == null) {
    return null;
  }
  return enums.ApiV1ChannelsGet$Response$ItemVisibility.values.firstWhereOrNull(
        (e) => e.value == apiV1ChannelsGet$Response$ItemVisibility,
      ) ??
      defaultValue;
}

String apiV1ChannelsGet$Response$ItemVisibilityExplodedListToJson(
  List<enums.ApiV1ChannelsGet$Response$ItemVisibility>?
  apiV1ChannelsGet$Response$ItemVisibility,
) {
  return apiV1ChannelsGet$Response$ItemVisibility
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1ChannelsGet$Response$ItemVisibilityListToJson(
  List<enums.ApiV1ChannelsGet$Response$ItemVisibility>?
  apiV1ChannelsGet$Response$ItemVisibility,
) {
  if (apiV1ChannelsGet$Response$ItemVisibility == null) {
    return [];
  }

  return apiV1ChannelsGet$Response$ItemVisibility.map((e) => e.value!).toList();
}

List<enums.ApiV1ChannelsGet$Response$ItemVisibility>
apiV1ChannelsGet$Response$ItemVisibilityListFromJson(
  List? apiV1ChannelsGet$Response$ItemVisibility, [
  List<enums.ApiV1ChannelsGet$Response$ItemVisibility>? defaultValue,
]) {
  if (apiV1ChannelsGet$Response$ItemVisibility == null) {
    return defaultValue ?? [];
  }

  return apiV1ChannelsGet$Response$ItemVisibility
      .map(
        (e) => apiV1ChannelsGet$Response$ItemVisibilityFromJson(e.toString()),
      )
      .toList();
}

List<enums.ApiV1ChannelsGet$Response$ItemVisibility>?
apiV1ChannelsGet$Response$ItemVisibilityNullableListFromJson(
  List? apiV1ChannelsGet$Response$ItemVisibility, [
  List<enums.ApiV1ChannelsGet$Response$ItemVisibility>? defaultValue,
]) {
  if (apiV1ChannelsGet$Response$ItemVisibility == null) {
    return defaultValue;
  }

  return apiV1ChannelsGet$Response$ItemVisibility
      .map(
        (e) => apiV1ChannelsGet$Response$ItemVisibilityFromJson(e.toString()),
      )
      .toList();
}

String? apiV1ChannelsPost$ResponseKindNullableToJson(
  enums.ApiV1ChannelsPost$ResponseKind? apiV1ChannelsPost$ResponseKind,
) {
  return apiV1ChannelsPost$ResponseKind?.value;
}

String? apiV1ChannelsPost$ResponseKindToJson(
  enums.ApiV1ChannelsPost$ResponseKind apiV1ChannelsPost$ResponseKind,
) {
  return apiV1ChannelsPost$ResponseKind.value;
}

enums.ApiV1ChannelsPost$ResponseKind apiV1ChannelsPost$ResponseKindFromJson(
  Object? apiV1ChannelsPost$ResponseKind, [
  enums.ApiV1ChannelsPost$ResponseKind? defaultValue,
]) {
  return enums.ApiV1ChannelsPost$ResponseKind.values.firstWhereOrNull(
        (e) => e.value == apiV1ChannelsPost$ResponseKind,
      ) ??
      defaultValue ??
      enums.ApiV1ChannelsPost$ResponseKind.swaggerGeneratedUnknown;
}

enums.ApiV1ChannelsPost$ResponseKind?
apiV1ChannelsPost$ResponseKindNullableFromJson(
  Object? apiV1ChannelsPost$ResponseKind, [
  enums.ApiV1ChannelsPost$ResponseKind? defaultValue,
]) {
  if (apiV1ChannelsPost$ResponseKind == null) {
    return null;
  }
  return enums.ApiV1ChannelsPost$ResponseKind.values.firstWhereOrNull(
        (e) => e.value == apiV1ChannelsPost$ResponseKind,
      ) ??
      defaultValue;
}

String apiV1ChannelsPost$ResponseKindExplodedListToJson(
  List<enums.ApiV1ChannelsPost$ResponseKind>? apiV1ChannelsPost$ResponseKind,
) {
  return apiV1ChannelsPost$ResponseKind?.map((e) => e.value!).join(',') ?? '';
}

List<String> apiV1ChannelsPost$ResponseKindListToJson(
  List<enums.ApiV1ChannelsPost$ResponseKind>? apiV1ChannelsPost$ResponseKind,
) {
  if (apiV1ChannelsPost$ResponseKind == null) {
    return [];
  }

  return apiV1ChannelsPost$ResponseKind.map((e) => e.value!).toList();
}

List<enums.ApiV1ChannelsPost$ResponseKind>
apiV1ChannelsPost$ResponseKindListFromJson(
  List? apiV1ChannelsPost$ResponseKind, [
  List<enums.ApiV1ChannelsPost$ResponseKind>? defaultValue,
]) {
  if (apiV1ChannelsPost$ResponseKind == null) {
    return defaultValue ?? [];
  }

  return apiV1ChannelsPost$ResponseKind
      .map((e) => apiV1ChannelsPost$ResponseKindFromJson(e.toString()))
      .toList();
}

List<enums.ApiV1ChannelsPost$ResponseKind>?
apiV1ChannelsPost$ResponseKindNullableListFromJson(
  List? apiV1ChannelsPost$ResponseKind, [
  List<enums.ApiV1ChannelsPost$ResponseKind>? defaultValue,
]) {
  if (apiV1ChannelsPost$ResponseKind == null) {
    return defaultValue;
  }

  return apiV1ChannelsPost$ResponseKind
      .map((e) => apiV1ChannelsPost$ResponseKindFromJson(e.toString()))
      .toList();
}

String? apiV1ChannelsPost$ResponseVisibilityNullableToJson(
  enums.ApiV1ChannelsPost$ResponseVisibility?
  apiV1ChannelsPost$ResponseVisibility,
) {
  return apiV1ChannelsPost$ResponseVisibility?.value;
}

String? apiV1ChannelsPost$ResponseVisibilityToJson(
  enums.ApiV1ChannelsPost$ResponseVisibility
  apiV1ChannelsPost$ResponseVisibility,
) {
  return apiV1ChannelsPost$ResponseVisibility.value;
}

enums.ApiV1ChannelsPost$ResponseVisibility
apiV1ChannelsPost$ResponseVisibilityFromJson(
  Object? apiV1ChannelsPost$ResponseVisibility, [
  enums.ApiV1ChannelsPost$ResponseVisibility? defaultValue,
]) {
  return enums.ApiV1ChannelsPost$ResponseVisibility.values.firstWhereOrNull(
        (e) => e.value == apiV1ChannelsPost$ResponseVisibility,
      ) ??
      defaultValue ??
      enums.ApiV1ChannelsPost$ResponseVisibility.swaggerGeneratedUnknown;
}

enums.ApiV1ChannelsPost$ResponseVisibility?
apiV1ChannelsPost$ResponseVisibilityNullableFromJson(
  Object? apiV1ChannelsPost$ResponseVisibility, [
  enums.ApiV1ChannelsPost$ResponseVisibility? defaultValue,
]) {
  if (apiV1ChannelsPost$ResponseVisibility == null) {
    return null;
  }
  return enums.ApiV1ChannelsPost$ResponseVisibility.values.firstWhereOrNull(
        (e) => e.value == apiV1ChannelsPost$ResponseVisibility,
      ) ??
      defaultValue;
}

String apiV1ChannelsPost$ResponseVisibilityExplodedListToJson(
  List<enums.ApiV1ChannelsPost$ResponseVisibility>?
  apiV1ChannelsPost$ResponseVisibility,
) {
  return apiV1ChannelsPost$ResponseVisibility?.map((e) => e.value!).join(',') ??
      '';
}

List<String> apiV1ChannelsPost$ResponseVisibilityListToJson(
  List<enums.ApiV1ChannelsPost$ResponseVisibility>?
  apiV1ChannelsPost$ResponseVisibility,
) {
  if (apiV1ChannelsPost$ResponseVisibility == null) {
    return [];
  }

  return apiV1ChannelsPost$ResponseVisibility.map((e) => e.value!).toList();
}

List<enums.ApiV1ChannelsPost$ResponseVisibility>
apiV1ChannelsPost$ResponseVisibilityListFromJson(
  List? apiV1ChannelsPost$ResponseVisibility, [
  List<enums.ApiV1ChannelsPost$ResponseVisibility>? defaultValue,
]) {
  if (apiV1ChannelsPost$ResponseVisibility == null) {
    return defaultValue ?? [];
  }

  return apiV1ChannelsPost$ResponseVisibility
      .map((e) => apiV1ChannelsPost$ResponseVisibilityFromJson(e.toString()))
      .toList();
}

List<enums.ApiV1ChannelsPost$ResponseVisibility>?
apiV1ChannelsPost$ResponseVisibilityNullableListFromJson(
  List? apiV1ChannelsPost$ResponseVisibility, [
  List<enums.ApiV1ChannelsPost$ResponseVisibility>? defaultValue,
]) {
  if (apiV1ChannelsPost$ResponseVisibility == null) {
    return defaultValue;
  }

  return apiV1ChannelsPost$ResponseVisibility
      .map((e) => apiV1ChannelsPost$ResponseVisibilityFromJson(e.toString()))
      .toList();
}

String? apiV1ChannelsChannelIdPatch$ResponseKindNullableToJson(
  enums.ApiV1ChannelsChannelIdPatch$ResponseKind?
  apiV1ChannelsChannelIdPatch$ResponseKind,
) {
  return apiV1ChannelsChannelIdPatch$ResponseKind?.value;
}

String? apiV1ChannelsChannelIdPatch$ResponseKindToJson(
  enums.ApiV1ChannelsChannelIdPatch$ResponseKind
  apiV1ChannelsChannelIdPatch$ResponseKind,
) {
  return apiV1ChannelsChannelIdPatch$ResponseKind.value;
}

enums.ApiV1ChannelsChannelIdPatch$ResponseKind
apiV1ChannelsChannelIdPatch$ResponseKindFromJson(
  Object? apiV1ChannelsChannelIdPatch$ResponseKind, [
  enums.ApiV1ChannelsChannelIdPatch$ResponseKind? defaultValue,
]) {
  return enums.ApiV1ChannelsChannelIdPatch$ResponseKind.values.firstWhereOrNull(
        (e) => e.value == apiV1ChannelsChannelIdPatch$ResponseKind,
      ) ??
      defaultValue ??
      enums.ApiV1ChannelsChannelIdPatch$ResponseKind.swaggerGeneratedUnknown;
}

enums.ApiV1ChannelsChannelIdPatch$ResponseKind?
apiV1ChannelsChannelIdPatch$ResponseKindNullableFromJson(
  Object? apiV1ChannelsChannelIdPatch$ResponseKind, [
  enums.ApiV1ChannelsChannelIdPatch$ResponseKind? defaultValue,
]) {
  if (apiV1ChannelsChannelIdPatch$ResponseKind == null) {
    return null;
  }
  return enums.ApiV1ChannelsChannelIdPatch$ResponseKind.values.firstWhereOrNull(
        (e) => e.value == apiV1ChannelsChannelIdPatch$ResponseKind,
      ) ??
      defaultValue;
}

String apiV1ChannelsChannelIdPatch$ResponseKindExplodedListToJson(
  List<enums.ApiV1ChannelsChannelIdPatch$ResponseKind>?
  apiV1ChannelsChannelIdPatch$ResponseKind,
) {
  return apiV1ChannelsChannelIdPatch$ResponseKind
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1ChannelsChannelIdPatch$ResponseKindListToJson(
  List<enums.ApiV1ChannelsChannelIdPatch$ResponseKind>?
  apiV1ChannelsChannelIdPatch$ResponseKind,
) {
  if (apiV1ChannelsChannelIdPatch$ResponseKind == null) {
    return [];
  }

  return apiV1ChannelsChannelIdPatch$ResponseKind.map((e) => e.value!).toList();
}

List<enums.ApiV1ChannelsChannelIdPatch$ResponseKind>
apiV1ChannelsChannelIdPatch$ResponseKindListFromJson(
  List? apiV1ChannelsChannelIdPatch$ResponseKind, [
  List<enums.ApiV1ChannelsChannelIdPatch$ResponseKind>? defaultValue,
]) {
  if (apiV1ChannelsChannelIdPatch$ResponseKind == null) {
    return defaultValue ?? [];
  }

  return apiV1ChannelsChannelIdPatch$ResponseKind
      .map(
        (e) => apiV1ChannelsChannelIdPatch$ResponseKindFromJson(e.toString()),
      )
      .toList();
}

List<enums.ApiV1ChannelsChannelIdPatch$ResponseKind>?
apiV1ChannelsChannelIdPatch$ResponseKindNullableListFromJson(
  List? apiV1ChannelsChannelIdPatch$ResponseKind, [
  List<enums.ApiV1ChannelsChannelIdPatch$ResponseKind>? defaultValue,
]) {
  if (apiV1ChannelsChannelIdPatch$ResponseKind == null) {
    return defaultValue;
  }

  return apiV1ChannelsChannelIdPatch$ResponseKind
      .map(
        (e) => apiV1ChannelsChannelIdPatch$ResponseKindFromJson(e.toString()),
      )
      .toList();
}

String? apiV1ChannelsChannelIdPatch$ResponseVisibilityNullableToJson(
  enums.ApiV1ChannelsChannelIdPatch$ResponseVisibility?
  apiV1ChannelsChannelIdPatch$ResponseVisibility,
) {
  return apiV1ChannelsChannelIdPatch$ResponseVisibility?.value;
}

String? apiV1ChannelsChannelIdPatch$ResponseVisibilityToJson(
  enums.ApiV1ChannelsChannelIdPatch$ResponseVisibility
  apiV1ChannelsChannelIdPatch$ResponseVisibility,
) {
  return apiV1ChannelsChannelIdPatch$ResponseVisibility.value;
}

enums.ApiV1ChannelsChannelIdPatch$ResponseVisibility
apiV1ChannelsChannelIdPatch$ResponseVisibilityFromJson(
  Object? apiV1ChannelsChannelIdPatch$ResponseVisibility, [
  enums.ApiV1ChannelsChannelIdPatch$ResponseVisibility? defaultValue,
]) {
  return enums.ApiV1ChannelsChannelIdPatch$ResponseVisibility.values
          .firstWhereOrNull(
            (e) => e.value == apiV1ChannelsChannelIdPatch$ResponseVisibility,
          ) ??
      defaultValue ??
      enums
          .ApiV1ChannelsChannelIdPatch$ResponseVisibility
          .swaggerGeneratedUnknown;
}

enums.ApiV1ChannelsChannelIdPatch$ResponseVisibility?
apiV1ChannelsChannelIdPatch$ResponseVisibilityNullableFromJson(
  Object? apiV1ChannelsChannelIdPatch$ResponseVisibility, [
  enums.ApiV1ChannelsChannelIdPatch$ResponseVisibility? defaultValue,
]) {
  if (apiV1ChannelsChannelIdPatch$ResponseVisibility == null) {
    return null;
  }
  return enums.ApiV1ChannelsChannelIdPatch$ResponseVisibility.values
          .firstWhereOrNull(
            (e) => e.value == apiV1ChannelsChannelIdPatch$ResponseVisibility,
          ) ??
      defaultValue;
}

String apiV1ChannelsChannelIdPatch$ResponseVisibilityExplodedListToJson(
  List<enums.ApiV1ChannelsChannelIdPatch$ResponseVisibility>?
  apiV1ChannelsChannelIdPatch$ResponseVisibility,
) {
  return apiV1ChannelsChannelIdPatch$ResponseVisibility
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1ChannelsChannelIdPatch$ResponseVisibilityListToJson(
  List<enums.ApiV1ChannelsChannelIdPatch$ResponseVisibility>?
  apiV1ChannelsChannelIdPatch$ResponseVisibility,
) {
  if (apiV1ChannelsChannelIdPatch$ResponseVisibility == null) {
    return [];
  }

  return apiV1ChannelsChannelIdPatch$ResponseVisibility
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ChannelsChannelIdPatch$ResponseVisibility>
apiV1ChannelsChannelIdPatch$ResponseVisibilityListFromJson(
  List? apiV1ChannelsChannelIdPatch$ResponseVisibility, [
  List<enums.ApiV1ChannelsChannelIdPatch$ResponseVisibility>? defaultValue,
]) {
  if (apiV1ChannelsChannelIdPatch$ResponseVisibility == null) {
    return defaultValue ?? [];
  }

  return apiV1ChannelsChannelIdPatch$ResponseVisibility
      .map(
        (e) => apiV1ChannelsChannelIdPatch$ResponseVisibilityFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1ChannelsChannelIdPatch$ResponseVisibility>?
apiV1ChannelsChannelIdPatch$ResponseVisibilityNullableListFromJson(
  List? apiV1ChannelsChannelIdPatch$ResponseVisibility, [
  List<enums.ApiV1ChannelsChannelIdPatch$ResponseVisibility>? defaultValue,
]) {
  if (apiV1ChannelsChannelIdPatch$ResponseVisibility == null) {
    return defaultValue;
  }

  return apiV1ChannelsChannelIdPatch$ResponseVisibility
      .map(
        (e) => apiV1ChannelsChannelIdPatch$ResponseVisibilityFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1ChannelsChannelIdRollbackPost$ResponsePlatformNullableToJson(
  enums.ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform?
  apiV1ChannelsChannelIdRollbackPost$ResponsePlatform,
) {
  return apiV1ChannelsChannelIdRollbackPost$ResponsePlatform?.value;
}

String? apiV1ChannelsChannelIdRollbackPost$ResponsePlatformToJson(
  enums.ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform
  apiV1ChannelsChannelIdRollbackPost$ResponsePlatform,
) {
  return apiV1ChannelsChannelIdRollbackPost$ResponsePlatform.value;
}

enums.ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform
apiV1ChannelsChannelIdRollbackPost$ResponsePlatformFromJson(
  Object? apiV1ChannelsChannelIdRollbackPost$ResponsePlatform, [
  enums.ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform? defaultValue,
]) {
  return enums.ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform.values
          .firstWhereOrNull(
            (e) =>
                e.value == apiV1ChannelsChannelIdRollbackPost$ResponsePlatform,
          ) ??
      defaultValue ??
      enums
          .ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform
          .swaggerGeneratedUnknown;
}

enums.ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform?
apiV1ChannelsChannelIdRollbackPost$ResponsePlatformNullableFromJson(
  Object? apiV1ChannelsChannelIdRollbackPost$ResponsePlatform, [
  enums.ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform? defaultValue,
]) {
  if (apiV1ChannelsChannelIdRollbackPost$ResponsePlatform == null) {
    return null;
  }
  return enums.ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform.values
          .firstWhereOrNull(
            (e) =>
                e.value == apiV1ChannelsChannelIdRollbackPost$ResponsePlatform,
          ) ??
      defaultValue;
}

String apiV1ChannelsChannelIdRollbackPost$ResponsePlatformExplodedListToJson(
  List<enums.ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform>?
  apiV1ChannelsChannelIdRollbackPost$ResponsePlatform,
) {
  return apiV1ChannelsChannelIdRollbackPost$ResponsePlatform
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1ChannelsChannelIdRollbackPost$ResponsePlatformListToJson(
  List<enums.ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform>?
  apiV1ChannelsChannelIdRollbackPost$ResponsePlatform,
) {
  if (apiV1ChannelsChannelIdRollbackPost$ResponsePlatform == null) {
    return [];
  }

  return apiV1ChannelsChannelIdRollbackPost$ResponsePlatform
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform>
apiV1ChannelsChannelIdRollbackPost$ResponsePlatformListFromJson(
  List? apiV1ChannelsChannelIdRollbackPost$ResponsePlatform, [
  List<enums.ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform>? defaultValue,
]) {
  if (apiV1ChannelsChannelIdRollbackPost$ResponsePlatform == null) {
    return defaultValue ?? [];
  }

  return apiV1ChannelsChannelIdRollbackPost$ResponsePlatform
      .map(
        (e) => apiV1ChannelsChannelIdRollbackPost$ResponsePlatformFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform>?
apiV1ChannelsChannelIdRollbackPost$ResponsePlatformNullableListFromJson(
  List? apiV1ChannelsChannelIdRollbackPost$ResponsePlatform, [
  List<enums.ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform>? defaultValue,
]) {
  if (apiV1ChannelsChannelIdRollbackPost$ResponsePlatform == null) {
    return defaultValue;
  }

  return apiV1ChannelsChannelIdRollbackPost$ResponsePlatform
      .map(
        (e) => apiV1ChannelsChannelIdRollbackPost$ResponsePlatformFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1ChannelsChannelIdRollbackPost$ResponseArchNullableToJson(
  enums.ApiV1ChannelsChannelIdRollbackPost$ResponseArch?
  apiV1ChannelsChannelIdRollbackPost$ResponseArch,
) {
  return apiV1ChannelsChannelIdRollbackPost$ResponseArch?.value;
}

String? apiV1ChannelsChannelIdRollbackPost$ResponseArchToJson(
  enums.ApiV1ChannelsChannelIdRollbackPost$ResponseArch
  apiV1ChannelsChannelIdRollbackPost$ResponseArch,
) {
  return apiV1ChannelsChannelIdRollbackPost$ResponseArch.value;
}

enums.ApiV1ChannelsChannelIdRollbackPost$ResponseArch
apiV1ChannelsChannelIdRollbackPost$ResponseArchFromJson(
  Object? apiV1ChannelsChannelIdRollbackPost$ResponseArch, [
  enums.ApiV1ChannelsChannelIdRollbackPost$ResponseArch? defaultValue,
]) {
  return enums.ApiV1ChannelsChannelIdRollbackPost$ResponseArch.values
          .firstWhereOrNull(
            (e) => e.value == apiV1ChannelsChannelIdRollbackPost$ResponseArch,
          ) ??
      defaultValue ??
      enums
          .ApiV1ChannelsChannelIdRollbackPost$ResponseArch
          .swaggerGeneratedUnknown;
}

enums.ApiV1ChannelsChannelIdRollbackPost$ResponseArch?
apiV1ChannelsChannelIdRollbackPost$ResponseArchNullableFromJson(
  Object? apiV1ChannelsChannelIdRollbackPost$ResponseArch, [
  enums.ApiV1ChannelsChannelIdRollbackPost$ResponseArch? defaultValue,
]) {
  if (apiV1ChannelsChannelIdRollbackPost$ResponseArch == null) {
    return null;
  }
  return enums.ApiV1ChannelsChannelIdRollbackPost$ResponseArch.values
          .firstWhereOrNull(
            (e) => e.value == apiV1ChannelsChannelIdRollbackPost$ResponseArch,
          ) ??
      defaultValue;
}

String apiV1ChannelsChannelIdRollbackPost$ResponseArchExplodedListToJson(
  List<enums.ApiV1ChannelsChannelIdRollbackPost$ResponseArch>?
  apiV1ChannelsChannelIdRollbackPost$ResponseArch,
) {
  return apiV1ChannelsChannelIdRollbackPost$ResponseArch
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1ChannelsChannelIdRollbackPost$ResponseArchListToJson(
  List<enums.ApiV1ChannelsChannelIdRollbackPost$ResponseArch>?
  apiV1ChannelsChannelIdRollbackPost$ResponseArch,
) {
  if (apiV1ChannelsChannelIdRollbackPost$ResponseArch == null) {
    return [];
  }

  return apiV1ChannelsChannelIdRollbackPost$ResponseArch
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ChannelsChannelIdRollbackPost$ResponseArch>
apiV1ChannelsChannelIdRollbackPost$ResponseArchListFromJson(
  List? apiV1ChannelsChannelIdRollbackPost$ResponseArch, [
  List<enums.ApiV1ChannelsChannelIdRollbackPost$ResponseArch>? defaultValue,
]) {
  if (apiV1ChannelsChannelIdRollbackPost$ResponseArch == null) {
    return defaultValue ?? [];
  }

  return apiV1ChannelsChannelIdRollbackPost$ResponseArch
      .map(
        (e) => apiV1ChannelsChannelIdRollbackPost$ResponseArchFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1ChannelsChannelIdRollbackPost$ResponseArch>?
apiV1ChannelsChannelIdRollbackPost$ResponseArchNullableListFromJson(
  List? apiV1ChannelsChannelIdRollbackPost$ResponseArch, [
  List<enums.ApiV1ChannelsChannelIdRollbackPost$ResponseArch>? defaultValue,
]) {
  if (apiV1ChannelsChannelIdRollbackPost$ResponseArch == null) {
    return defaultValue;
  }

  return apiV1ChannelsChannelIdRollbackPost$ResponseArch
      .map(
        (e) => apiV1ChannelsChannelIdRollbackPost$ResponseArchFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1ReleasesGet$Response$ItemStatusNullableToJson(
  enums.ApiV1ReleasesGet$Response$ItemStatus?
  apiV1ReleasesGet$Response$ItemStatus,
) {
  return apiV1ReleasesGet$Response$ItemStatus?.value;
}

String? apiV1ReleasesGet$Response$ItemStatusToJson(
  enums.ApiV1ReleasesGet$Response$ItemStatus
  apiV1ReleasesGet$Response$ItemStatus,
) {
  return apiV1ReleasesGet$Response$ItemStatus.value;
}

enums.ApiV1ReleasesGet$Response$ItemStatus
apiV1ReleasesGet$Response$ItemStatusFromJson(
  Object? apiV1ReleasesGet$Response$ItemStatus, [
  enums.ApiV1ReleasesGet$Response$ItemStatus? defaultValue,
]) {
  return enums.ApiV1ReleasesGet$Response$ItemStatus.values.firstWhereOrNull(
        (e) => e.value == apiV1ReleasesGet$Response$ItemStatus,
      ) ??
      defaultValue ??
      enums.ApiV1ReleasesGet$Response$ItemStatus.swaggerGeneratedUnknown;
}

enums.ApiV1ReleasesGet$Response$ItemStatus?
apiV1ReleasesGet$Response$ItemStatusNullableFromJson(
  Object? apiV1ReleasesGet$Response$ItemStatus, [
  enums.ApiV1ReleasesGet$Response$ItemStatus? defaultValue,
]) {
  if (apiV1ReleasesGet$Response$ItemStatus == null) {
    return null;
  }
  return enums.ApiV1ReleasesGet$Response$ItemStatus.values.firstWhereOrNull(
        (e) => e.value == apiV1ReleasesGet$Response$ItemStatus,
      ) ??
      defaultValue;
}

String apiV1ReleasesGet$Response$ItemStatusExplodedListToJson(
  List<enums.ApiV1ReleasesGet$Response$ItemStatus>?
  apiV1ReleasesGet$Response$ItemStatus,
) {
  return apiV1ReleasesGet$Response$ItemStatus?.map((e) => e.value!).join(',') ??
      '';
}

List<String> apiV1ReleasesGet$Response$ItemStatusListToJson(
  List<enums.ApiV1ReleasesGet$Response$ItemStatus>?
  apiV1ReleasesGet$Response$ItemStatus,
) {
  if (apiV1ReleasesGet$Response$ItemStatus == null) {
    return [];
  }

  return apiV1ReleasesGet$Response$ItemStatus.map((e) => e.value!).toList();
}

List<enums.ApiV1ReleasesGet$Response$ItemStatus>
apiV1ReleasesGet$Response$ItemStatusListFromJson(
  List? apiV1ReleasesGet$Response$ItemStatus, [
  List<enums.ApiV1ReleasesGet$Response$ItemStatus>? defaultValue,
]) {
  if (apiV1ReleasesGet$Response$ItemStatus == null) {
    return defaultValue ?? [];
  }

  return apiV1ReleasesGet$Response$ItemStatus
      .map((e) => apiV1ReleasesGet$Response$ItemStatusFromJson(e.toString()))
      .toList();
}

List<enums.ApiV1ReleasesGet$Response$ItemStatus>?
apiV1ReleasesGet$Response$ItemStatusNullableListFromJson(
  List? apiV1ReleasesGet$Response$ItemStatus, [
  List<enums.ApiV1ReleasesGet$Response$ItemStatus>? defaultValue,
]) {
  if (apiV1ReleasesGet$Response$ItemStatus == null) {
    return defaultValue;
  }

  return apiV1ReleasesGet$Response$ItemStatus
      .map((e) => apiV1ReleasesGet$Response$ItemStatusFromJson(e.toString()))
      .toList();
}

String? apiV1ReleasesGetStatusNullableToJson(
  enums.ApiV1ReleasesGetStatus? apiV1ReleasesGetStatus,
) {
  return apiV1ReleasesGetStatus?.value;
}

String? apiV1ReleasesGetStatusToJson(
  enums.ApiV1ReleasesGetStatus apiV1ReleasesGetStatus,
) {
  return apiV1ReleasesGetStatus.value;
}

enums.ApiV1ReleasesGetStatus apiV1ReleasesGetStatusFromJson(
  Object? apiV1ReleasesGetStatus, [
  enums.ApiV1ReleasesGetStatus? defaultValue,
]) {
  return enums.ApiV1ReleasesGetStatus.values.firstWhereOrNull(
        (e) => e.value == apiV1ReleasesGetStatus,
      ) ??
      defaultValue ??
      enums.ApiV1ReleasesGetStatus.swaggerGeneratedUnknown;
}

enums.ApiV1ReleasesGetStatus? apiV1ReleasesGetStatusNullableFromJson(
  Object? apiV1ReleasesGetStatus, [
  enums.ApiV1ReleasesGetStatus? defaultValue,
]) {
  if (apiV1ReleasesGetStatus == null) {
    return null;
  }
  return enums.ApiV1ReleasesGetStatus.values.firstWhereOrNull(
        (e) => e.value == apiV1ReleasesGetStatus,
      ) ??
      defaultValue;
}

String apiV1ReleasesGetStatusExplodedListToJson(
  List<enums.ApiV1ReleasesGetStatus>? apiV1ReleasesGetStatus,
) {
  return apiV1ReleasesGetStatus?.map((e) => e.value!).join(',') ?? '';
}

List<String> apiV1ReleasesGetStatusListToJson(
  List<enums.ApiV1ReleasesGetStatus>? apiV1ReleasesGetStatus,
) {
  if (apiV1ReleasesGetStatus == null) {
    return [];
  }

  return apiV1ReleasesGetStatus.map((e) => e.value!).toList();
}

List<enums.ApiV1ReleasesGetStatus> apiV1ReleasesGetStatusListFromJson(
  List? apiV1ReleasesGetStatus, [
  List<enums.ApiV1ReleasesGetStatus>? defaultValue,
]) {
  if (apiV1ReleasesGetStatus == null) {
    return defaultValue ?? [];
  }

  return apiV1ReleasesGetStatus
      .map((e) => apiV1ReleasesGetStatusFromJson(e.toString()))
      .toList();
}

List<enums.ApiV1ReleasesGetStatus>? apiV1ReleasesGetStatusNullableListFromJson(
  List? apiV1ReleasesGetStatus, [
  List<enums.ApiV1ReleasesGetStatus>? defaultValue,
]) {
  if (apiV1ReleasesGetStatus == null) {
    return defaultValue;
  }

  return apiV1ReleasesGetStatus
      .map((e) => apiV1ReleasesGetStatusFromJson(e.toString()))
      .toList();
}

String? apiV1ReleasesPost$ResponseStatusNullableToJson(
  enums.ApiV1ReleasesPost$ResponseStatus? apiV1ReleasesPost$ResponseStatus,
) {
  return apiV1ReleasesPost$ResponseStatus?.value;
}

String? apiV1ReleasesPost$ResponseStatusToJson(
  enums.ApiV1ReleasesPost$ResponseStatus apiV1ReleasesPost$ResponseStatus,
) {
  return apiV1ReleasesPost$ResponseStatus.value;
}

enums.ApiV1ReleasesPost$ResponseStatus apiV1ReleasesPost$ResponseStatusFromJson(
  Object? apiV1ReleasesPost$ResponseStatus, [
  enums.ApiV1ReleasesPost$ResponseStatus? defaultValue,
]) {
  return enums.ApiV1ReleasesPost$ResponseStatus.values.firstWhereOrNull(
        (e) => e.value == apiV1ReleasesPost$ResponseStatus,
      ) ??
      defaultValue ??
      enums.ApiV1ReleasesPost$ResponseStatus.swaggerGeneratedUnknown;
}

enums.ApiV1ReleasesPost$ResponseStatus?
apiV1ReleasesPost$ResponseStatusNullableFromJson(
  Object? apiV1ReleasesPost$ResponseStatus, [
  enums.ApiV1ReleasesPost$ResponseStatus? defaultValue,
]) {
  if (apiV1ReleasesPost$ResponseStatus == null) {
    return null;
  }
  return enums.ApiV1ReleasesPost$ResponseStatus.values.firstWhereOrNull(
        (e) => e.value == apiV1ReleasesPost$ResponseStatus,
      ) ??
      defaultValue;
}

String apiV1ReleasesPost$ResponseStatusExplodedListToJson(
  List<enums.ApiV1ReleasesPost$ResponseStatus>?
  apiV1ReleasesPost$ResponseStatus,
) {
  return apiV1ReleasesPost$ResponseStatus?.map((e) => e.value!).join(',') ?? '';
}

List<String> apiV1ReleasesPost$ResponseStatusListToJson(
  List<enums.ApiV1ReleasesPost$ResponseStatus>?
  apiV1ReleasesPost$ResponseStatus,
) {
  if (apiV1ReleasesPost$ResponseStatus == null) {
    return [];
  }

  return apiV1ReleasesPost$ResponseStatus.map((e) => e.value!).toList();
}

List<enums.ApiV1ReleasesPost$ResponseStatus>
apiV1ReleasesPost$ResponseStatusListFromJson(
  List? apiV1ReleasesPost$ResponseStatus, [
  List<enums.ApiV1ReleasesPost$ResponseStatus>? defaultValue,
]) {
  if (apiV1ReleasesPost$ResponseStatus == null) {
    return defaultValue ?? [];
  }

  return apiV1ReleasesPost$ResponseStatus
      .map((e) => apiV1ReleasesPost$ResponseStatusFromJson(e.toString()))
      .toList();
}

List<enums.ApiV1ReleasesPost$ResponseStatus>?
apiV1ReleasesPost$ResponseStatusNullableListFromJson(
  List? apiV1ReleasesPost$ResponseStatus, [
  List<enums.ApiV1ReleasesPost$ResponseStatus>? defaultValue,
]) {
  if (apiV1ReleasesPost$ResponseStatus == null) {
    return defaultValue;
  }

  return apiV1ReleasesPost$ResponseStatus
      .map((e) => apiV1ReleasesPost$ResponseStatusFromJson(e.toString()))
      .toList();
}

String? apiV1ReleasesReleaseIdGet$ResponseStatusNullableToJson(
  enums.ApiV1ReleasesReleaseIdGet$ResponseStatus?
  apiV1ReleasesReleaseIdGet$ResponseStatus,
) {
  return apiV1ReleasesReleaseIdGet$ResponseStatus?.value;
}

String? apiV1ReleasesReleaseIdGet$ResponseStatusToJson(
  enums.ApiV1ReleasesReleaseIdGet$ResponseStatus
  apiV1ReleasesReleaseIdGet$ResponseStatus,
) {
  return apiV1ReleasesReleaseIdGet$ResponseStatus.value;
}

enums.ApiV1ReleasesReleaseIdGet$ResponseStatus
apiV1ReleasesReleaseIdGet$ResponseStatusFromJson(
  Object? apiV1ReleasesReleaseIdGet$ResponseStatus, [
  enums.ApiV1ReleasesReleaseIdGet$ResponseStatus? defaultValue,
]) {
  return enums.ApiV1ReleasesReleaseIdGet$ResponseStatus.values.firstWhereOrNull(
        (e) => e.value == apiV1ReleasesReleaseIdGet$ResponseStatus,
      ) ??
      defaultValue ??
      enums.ApiV1ReleasesReleaseIdGet$ResponseStatus.swaggerGeneratedUnknown;
}

enums.ApiV1ReleasesReleaseIdGet$ResponseStatus?
apiV1ReleasesReleaseIdGet$ResponseStatusNullableFromJson(
  Object? apiV1ReleasesReleaseIdGet$ResponseStatus, [
  enums.ApiV1ReleasesReleaseIdGet$ResponseStatus? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdGet$ResponseStatus == null) {
    return null;
  }
  return enums.ApiV1ReleasesReleaseIdGet$ResponseStatus.values.firstWhereOrNull(
        (e) => e.value == apiV1ReleasesReleaseIdGet$ResponseStatus,
      ) ??
      defaultValue;
}

String apiV1ReleasesReleaseIdGet$ResponseStatusExplodedListToJson(
  List<enums.ApiV1ReleasesReleaseIdGet$ResponseStatus>?
  apiV1ReleasesReleaseIdGet$ResponseStatus,
) {
  return apiV1ReleasesReleaseIdGet$ResponseStatus
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1ReleasesReleaseIdGet$ResponseStatusListToJson(
  List<enums.ApiV1ReleasesReleaseIdGet$ResponseStatus>?
  apiV1ReleasesReleaseIdGet$ResponseStatus,
) {
  if (apiV1ReleasesReleaseIdGet$ResponseStatus == null) {
    return [];
  }

  return apiV1ReleasesReleaseIdGet$ResponseStatus.map((e) => e.value!).toList();
}

List<enums.ApiV1ReleasesReleaseIdGet$ResponseStatus>
apiV1ReleasesReleaseIdGet$ResponseStatusListFromJson(
  List? apiV1ReleasesReleaseIdGet$ResponseStatus, [
  List<enums.ApiV1ReleasesReleaseIdGet$ResponseStatus>? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdGet$ResponseStatus == null) {
    return defaultValue ?? [];
  }

  return apiV1ReleasesReleaseIdGet$ResponseStatus
      .map(
        (e) => apiV1ReleasesReleaseIdGet$ResponseStatusFromJson(e.toString()),
      )
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdGet$ResponseStatus>?
apiV1ReleasesReleaseIdGet$ResponseStatusNullableListFromJson(
  List? apiV1ReleasesReleaseIdGet$ResponseStatus, [
  List<enums.ApiV1ReleasesReleaseIdGet$ResponseStatus>? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdGet$ResponseStatus == null) {
    return defaultValue;
  }

  return apiV1ReleasesReleaseIdGet$ResponseStatus
      .map(
        (e) => apiV1ReleasesReleaseIdGet$ResponseStatusFromJson(e.toString()),
      )
      .toList();
}

String? apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatformNullableToJson(
  enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform?
  apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform,
) {
  return apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform?.value;
}

String? apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatformToJson(
  enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform
  apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform,
) {
  return apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform.value;
}

enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform
apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatformFromJson(
  Object? apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform, [
  enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform? defaultValue,
]) {
  return enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform,
          ) ??
      defaultValue ??
      enums
          .ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform
          .swaggerGeneratedUnknown;
}

enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform?
apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatformNullableFromJson(
  Object? apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform, [
  enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform == null) {
    return null;
  }
  return enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform,
          ) ??
      defaultValue;
}

String
apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatformExplodedListToJson(
  List<enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform>?
  apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform,
) {
  return apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatformListToJson(
  List<enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform>?
  apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform,
) {
  if (apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform == null) {
    return [];
  }

  return apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform>
apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatformListFromJson(
  List? apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform, [
  List<enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform>?
  defaultValue,
]) {
  if (apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform == null) {
    return defaultValue ?? [];
  }

  return apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform
      .map(
        (e) =>
            apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatformFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform>?
apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatformNullableListFromJson(
  List? apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform, [
  List<enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform>?
  defaultValue,
]) {
  if (apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform == null) {
    return defaultValue;
  }

  return apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform
      .map(
        (e) =>
            apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatformFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String? apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArchNullableToJson(
  enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch?
  apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch,
) {
  return apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch?.value;
}

String? apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArchToJson(
  enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch
  apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch,
) {
  return apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch.value;
}

enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch
apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArchFromJson(
  Object? apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch, [
  enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch? defaultValue,
]) {
  return enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch,
          ) ??
      defaultValue ??
      enums
          .ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch
          .swaggerGeneratedUnknown;
}

enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch?
apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArchNullableFromJson(
  Object? apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch, [
  enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch == null) {
    return null;
  }
  return enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch,
          ) ??
      defaultValue;
}

String apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArchExplodedListToJson(
  List<enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch>?
  apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch,
) {
  return apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArchListToJson(
  List<enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch>?
  apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch,
) {
  if (apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch == null) {
    return [];
  }

  return apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch>
apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArchListFromJson(
  List? apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch, [
  List<enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch>?
  defaultValue,
]) {
  if (apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch == null) {
    return defaultValue ?? [];
  }

  return apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch
      .map(
        (e) => apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArchFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch>?
apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArchNullableListFromJson(
  List? apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch, [
  List<enums.ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch>?
  defaultValue,
]) {
  if (apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch == null) {
    return defaultValue;
  }

  return apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch
      .map(
        (e) => apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArchFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1ReleasesReleaseIdVerifyPost$ResponseStatusNullableToJson(
  enums.ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus?
  apiV1ReleasesReleaseIdVerifyPost$ResponseStatus,
) {
  return apiV1ReleasesReleaseIdVerifyPost$ResponseStatus?.value;
}

String? apiV1ReleasesReleaseIdVerifyPost$ResponseStatusToJson(
  enums.ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus
  apiV1ReleasesReleaseIdVerifyPost$ResponseStatus,
) {
  return apiV1ReleasesReleaseIdVerifyPost$ResponseStatus.value;
}

enums.ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus
apiV1ReleasesReleaseIdVerifyPost$ResponseStatusFromJson(
  Object? apiV1ReleasesReleaseIdVerifyPost$ResponseStatus, [
  enums.ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus? defaultValue,
]) {
  return enums.ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus.values
          .firstWhereOrNull(
            (e) => e.value == apiV1ReleasesReleaseIdVerifyPost$ResponseStatus,
          ) ??
      defaultValue ??
      enums
          .ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus
          .swaggerGeneratedUnknown;
}

enums.ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus?
apiV1ReleasesReleaseIdVerifyPost$ResponseStatusNullableFromJson(
  Object? apiV1ReleasesReleaseIdVerifyPost$ResponseStatus, [
  enums.ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdVerifyPost$ResponseStatus == null) {
    return null;
  }
  return enums.ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus.values
          .firstWhereOrNull(
            (e) => e.value == apiV1ReleasesReleaseIdVerifyPost$ResponseStatus,
          ) ??
      defaultValue;
}

String apiV1ReleasesReleaseIdVerifyPost$ResponseStatusExplodedListToJson(
  List<enums.ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus>?
  apiV1ReleasesReleaseIdVerifyPost$ResponseStatus,
) {
  return apiV1ReleasesReleaseIdVerifyPost$ResponseStatus
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1ReleasesReleaseIdVerifyPost$ResponseStatusListToJson(
  List<enums.ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus>?
  apiV1ReleasesReleaseIdVerifyPost$ResponseStatus,
) {
  if (apiV1ReleasesReleaseIdVerifyPost$ResponseStatus == null) {
    return [];
  }

  return apiV1ReleasesReleaseIdVerifyPost$ResponseStatus
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus>
apiV1ReleasesReleaseIdVerifyPost$ResponseStatusListFromJson(
  List? apiV1ReleasesReleaseIdVerifyPost$ResponseStatus, [
  List<enums.ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus>? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdVerifyPost$ResponseStatus == null) {
    return defaultValue ?? [];
  }

  return apiV1ReleasesReleaseIdVerifyPost$ResponseStatus
      .map(
        (e) => apiV1ReleasesReleaseIdVerifyPost$ResponseStatusFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus>?
apiV1ReleasesReleaseIdVerifyPost$ResponseStatusNullableListFromJson(
  List? apiV1ReleasesReleaseIdVerifyPost$ResponseStatus, [
  List<enums.ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus>? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdVerifyPost$ResponseStatus == null) {
    return defaultValue;
  }

  return apiV1ReleasesReleaseIdVerifyPost$ResponseStatus
      .map(
        (e) => apiV1ReleasesReleaseIdVerifyPost$ResponseStatusFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1ReleasesReleaseIdPublishPost$ResponseStatusNullableToJson(
  enums.ApiV1ReleasesReleaseIdPublishPost$ResponseStatus?
  apiV1ReleasesReleaseIdPublishPost$ResponseStatus,
) {
  return apiV1ReleasesReleaseIdPublishPost$ResponseStatus?.value;
}

String? apiV1ReleasesReleaseIdPublishPost$ResponseStatusToJson(
  enums.ApiV1ReleasesReleaseIdPublishPost$ResponseStatus
  apiV1ReleasesReleaseIdPublishPost$ResponseStatus,
) {
  return apiV1ReleasesReleaseIdPublishPost$ResponseStatus.value;
}

enums.ApiV1ReleasesReleaseIdPublishPost$ResponseStatus
apiV1ReleasesReleaseIdPublishPost$ResponseStatusFromJson(
  Object? apiV1ReleasesReleaseIdPublishPost$ResponseStatus, [
  enums.ApiV1ReleasesReleaseIdPublishPost$ResponseStatus? defaultValue,
]) {
  return enums.ApiV1ReleasesReleaseIdPublishPost$ResponseStatus.values
          .firstWhereOrNull(
            (e) => e.value == apiV1ReleasesReleaseIdPublishPost$ResponseStatus,
          ) ??
      defaultValue ??
      enums
          .ApiV1ReleasesReleaseIdPublishPost$ResponseStatus
          .swaggerGeneratedUnknown;
}

enums.ApiV1ReleasesReleaseIdPublishPost$ResponseStatus?
apiV1ReleasesReleaseIdPublishPost$ResponseStatusNullableFromJson(
  Object? apiV1ReleasesReleaseIdPublishPost$ResponseStatus, [
  enums.ApiV1ReleasesReleaseIdPublishPost$ResponseStatus? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPublishPost$ResponseStatus == null) {
    return null;
  }
  return enums.ApiV1ReleasesReleaseIdPublishPost$ResponseStatus.values
          .firstWhereOrNull(
            (e) => e.value == apiV1ReleasesReleaseIdPublishPost$ResponseStatus,
          ) ??
      defaultValue;
}

String apiV1ReleasesReleaseIdPublishPost$ResponseStatusExplodedListToJson(
  List<enums.ApiV1ReleasesReleaseIdPublishPost$ResponseStatus>?
  apiV1ReleasesReleaseIdPublishPost$ResponseStatus,
) {
  return apiV1ReleasesReleaseIdPublishPost$ResponseStatus
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1ReleasesReleaseIdPublishPost$ResponseStatusListToJson(
  List<enums.ApiV1ReleasesReleaseIdPublishPost$ResponseStatus>?
  apiV1ReleasesReleaseIdPublishPost$ResponseStatus,
) {
  if (apiV1ReleasesReleaseIdPublishPost$ResponseStatus == null) {
    return [];
  }

  return apiV1ReleasesReleaseIdPublishPost$ResponseStatus
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdPublishPost$ResponseStatus>
apiV1ReleasesReleaseIdPublishPost$ResponseStatusListFromJson(
  List? apiV1ReleasesReleaseIdPublishPost$ResponseStatus, [
  List<enums.ApiV1ReleasesReleaseIdPublishPost$ResponseStatus>? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPublishPost$ResponseStatus == null) {
    return defaultValue ?? [];
  }

  return apiV1ReleasesReleaseIdPublishPost$ResponseStatus
      .map(
        (e) => apiV1ReleasesReleaseIdPublishPost$ResponseStatusFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdPublishPost$ResponseStatus>?
apiV1ReleasesReleaseIdPublishPost$ResponseStatusNullableListFromJson(
  List? apiV1ReleasesReleaseIdPublishPost$ResponseStatus, [
  List<enums.ApiV1ReleasesReleaseIdPublishPost$ResponseStatus>? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPublishPost$ResponseStatus == null) {
    return defaultValue;
  }

  return apiV1ReleasesReleaseIdPublishPost$ResponseStatus
      .map(
        (e) => apiV1ReleasesReleaseIdPublishPost$ResponseStatusFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1ReleasesReleaseIdPromotePost$ResponsePlatformNullableToJson(
  enums.ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform?
  apiV1ReleasesReleaseIdPromotePost$ResponsePlatform,
) {
  return apiV1ReleasesReleaseIdPromotePost$ResponsePlatform?.value;
}

String? apiV1ReleasesReleaseIdPromotePost$ResponsePlatformToJson(
  enums.ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform
  apiV1ReleasesReleaseIdPromotePost$ResponsePlatform,
) {
  return apiV1ReleasesReleaseIdPromotePost$ResponsePlatform.value;
}

enums.ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform
apiV1ReleasesReleaseIdPromotePost$ResponsePlatformFromJson(
  Object? apiV1ReleasesReleaseIdPromotePost$ResponsePlatform, [
  enums.ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform? defaultValue,
]) {
  return enums.ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform.values
          .firstWhereOrNull(
            (e) =>
                e.value == apiV1ReleasesReleaseIdPromotePost$ResponsePlatform,
          ) ??
      defaultValue ??
      enums
          .ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform
          .swaggerGeneratedUnknown;
}

enums.ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform?
apiV1ReleasesReleaseIdPromotePost$ResponsePlatformNullableFromJson(
  Object? apiV1ReleasesReleaseIdPromotePost$ResponsePlatform, [
  enums.ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPromotePost$ResponsePlatform == null) {
    return null;
  }
  return enums.ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform.values
          .firstWhereOrNull(
            (e) =>
                e.value == apiV1ReleasesReleaseIdPromotePost$ResponsePlatform,
          ) ??
      defaultValue;
}

String apiV1ReleasesReleaseIdPromotePost$ResponsePlatformExplodedListToJson(
  List<enums.ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform>?
  apiV1ReleasesReleaseIdPromotePost$ResponsePlatform,
) {
  return apiV1ReleasesReleaseIdPromotePost$ResponsePlatform
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1ReleasesReleaseIdPromotePost$ResponsePlatformListToJson(
  List<enums.ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform>?
  apiV1ReleasesReleaseIdPromotePost$ResponsePlatform,
) {
  if (apiV1ReleasesReleaseIdPromotePost$ResponsePlatform == null) {
    return [];
  }

  return apiV1ReleasesReleaseIdPromotePost$ResponsePlatform
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform>
apiV1ReleasesReleaseIdPromotePost$ResponsePlatformListFromJson(
  List? apiV1ReleasesReleaseIdPromotePost$ResponsePlatform, [
  List<enums.ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform>? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPromotePost$ResponsePlatform == null) {
    return defaultValue ?? [];
  }

  return apiV1ReleasesReleaseIdPromotePost$ResponsePlatform
      .map(
        (e) => apiV1ReleasesReleaseIdPromotePost$ResponsePlatformFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform>?
apiV1ReleasesReleaseIdPromotePost$ResponsePlatformNullableListFromJson(
  List? apiV1ReleasesReleaseIdPromotePost$ResponsePlatform, [
  List<enums.ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform>? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPromotePost$ResponsePlatform == null) {
    return defaultValue;
  }

  return apiV1ReleasesReleaseIdPromotePost$ResponsePlatform
      .map(
        (e) => apiV1ReleasesReleaseIdPromotePost$ResponsePlatformFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1ReleasesReleaseIdPromotePost$ResponseArchNullableToJson(
  enums.ApiV1ReleasesReleaseIdPromotePost$ResponseArch?
  apiV1ReleasesReleaseIdPromotePost$ResponseArch,
) {
  return apiV1ReleasesReleaseIdPromotePost$ResponseArch?.value;
}

String? apiV1ReleasesReleaseIdPromotePost$ResponseArchToJson(
  enums.ApiV1ReleasesReleaseIdPromotePost$ResponseArch
  apiV1ReleasesReleaseIdPromotePost$ResponseArch,
) {
  return apiV1ReleasesReleaseIdPromotePost$ResponseArch.value;
}

enums.ApiV1ReleasesReleaseIdPromotePost$ResponseArch
apiV1ReleasesReleaseIdPromotePost$ResponseArchFromJson(
  Object? apiV1ReleasesReleaseIdPromotePost$ResponseArch, [
  enums.ApiV1ReleasesReleaseIdPromotePost$ResponseArch? defaultValue,
]) {
  return enums.ApiV1ReleasesReleaseIdPromotePost$ResponseArch.values
          .firstWhereOrNull(
            (e) => e.value == apiV1ReleasesReleaseIdPromotePost$ResponseArch,
          ) ??
      defaultValue ??
      enums
          .ApiV1ReleasesReleaseIdPromotePost$ResponseArch
          .swaggerGeneratedUnknown;
}

enums.ApiV1ReleasesReleaseIdPromotePost$ResponseArch?
apiV1ReleasesReleaseIdPromotePost$ResponseArchNullableFromJson(
  Object? apiV1ReleasesReleaseIdPromotePost$ResponseArch, [
  enums.ApiV1ReleasesReleaseIdPromotePost$ResponseArch? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPromotePost$ResponseArch == null) {
    return null;
  }
  return enums.ApiV1ReleasesReleaseIdPromotePost$ResponseArch.values
          .firstWhereOrNull(
            (e) => e.value == apiV1ReleasesReleaseIdPromotePost$ResponseArch,
          ) ??
      defaultValue;
}

String apiV1ReleasesReleaseIdPromotePost$ResponseArchExplodedListToJson(
  List<enums.ApiV1ReleasesReleaseIdPromotePost$ResponseArch>?
  apiV1ReleasesReleaseIdPromotePost$ResponseArch,
) {
  return apiV1ReleasesReleaseIdPromotePost$ResponseArch
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1ReleasesReleaseIdPromotePost$ResponseArchListToJson(
  List<enums.ApiV1ReleasesReleaseIdPromotePost$ResponseArch>?
  apiV1ReleasesReleaseIdPromotePost$ResponseArch,
) {
  if (apiV1ReleasesReleaseIdPromotePost$ResponseArch == null) {
    return [];
  }

  return apiV1ReleasesReleaseIdPromotePost$ResponseArch
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdPromotePost$ResponseArch>
apiV1ReleasesReleaseIdPromotePost$ResponseArchListFromJson(
  List? apiV1ReleasesReleaseIdPromotePost$ResponseArch, [
  List<enums.ApiV1ReleasesReleaseIdPromotePost$ResponseArch>? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPromotePost$ResponseArch == null) {
    return defaultValue ?? [];
  }

  return apiV1ReleasesReleaseIdPromotePost$ResponseArch
      .map(
        (e) => apiV1ReleasesReleaseIdPromotePost$ResponseArchFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdPromotePost$ResponseArch>?
apiV1ReleasesReleaseIdPromotePost$ResponseArchNullableListFromJson(
  List? apiV1ReleasesReleaseIdPromotePost$ResponseArch, [
  List<enums.ApiV1ReleasesReleaseIdPromotePost$ResponseArch>? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPromotePost$ResponseArch == null) {
    return defaultValue;
  }

  return apiV1ReleasesReleaseIdPromotePost$ResponseArch
      .map(
        (e) => apiV1ReleasesReleaseIdPromotePost$ResponseArchFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String?
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKindNullableToJson(
  enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind?
  apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind,
) {
  return apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind
      ?.value;
}

String?
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKindToJson(
  enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind
  apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind,
) {
  return apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind
      .value;
}

enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKindFromJson(
  Object? apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind, [
  enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind?
  defaultValue,
]) {
  return enums
          .ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind,
          ) ??
      defaultValue ??
      enums
          .ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind
          .swaggerGeneratedUnknown;
}

enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind?
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKindNullableFromJson(
  Object? apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind, [
  enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind?
  defaultValue,
]) {
  if (apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind ==
      null) {
    return null;
  }
  return enums
          .ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind,
          ) ??
      defaultValue;
}

String
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKindExplodedListToJson(
  List<
    enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind
  >?
  apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind,
) {
  return apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKindListToJson(
  List<
    enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind
  >?
  apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind,
) {
  if (apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind ==
      null) {
    return [];
  }

  return apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind>
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKindListFromJson(
  List? apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind, [
  List<
    enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind
  >?
  defaultValue,
]) {
  if (apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind ==
      null) {
    return defaultValue ?? [];
  }

  return apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind
      .map(
        (e) =>
            apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKindFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind>?
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKindNullableListFromJson(
  List? apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind, [
  List<
    enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind
  >?
  defaultValue,
]) {
  if (apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind ==
      null) {
    return defaultValue;
  }

  return apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind
      .map(
        (e) =>
            apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKindFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String?
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatformNullableToJson(
  enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform?
  apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform,
) {
  return apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform
      ?.value;
}

String? apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatformToJson(
  enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform
  apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform,
) {
  return apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform.value;
}

enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatformFromJson(
  Object? apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform, [
  enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform?
  defaultValue,
]) {
  return enums
          .ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform,
          ) ??
      defaultValue ??
      enums
          .ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform
          .swaggerGeneratedUnknown;
}

enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform?
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatformNullableFromJson(
  Object? apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform, [
  enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform?
  defaultValue,
]) {
  if (apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform ==
      null) {
    return null;
  }
  return enums
          .ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform,
          ) ??
      defaultValue;
}

String
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatformExplodedListToJson(
  List<enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform>?
  apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform,
) {
  return apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatformListToJson(
  List<enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform>?
  apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform,
) {
  if (apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform ==
      null) {
    return [];
  }

  return apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform>
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatformListFromJson(
  List? apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform, [
  List<enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform>?
  defaultValue,
]) {
  if (apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform ==
      null) {
    return defaultValue ?? [];
  }

  return apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform
      .map(
        (e) =>
            apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatformFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform>?
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatformNullableListFromJson(
  List? apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform, [
  List<enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform>?
  defaultValue,
]) {
  if (apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform ==
      null) {
    return defaultValue;
  }

  return apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform
      .map(
        (e) =>
            apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatformFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String?
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArchNullableToJson(
  enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch?
  apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch,
) {
  return apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch?.value;
}

String? apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArchToJson(
  enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch
  apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch,
) {
  return apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch.value;
}

enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArchFromJson(
  Object? apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch, [
  enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch?
  defaultValue,
]) {
  return enums
          .ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch,
          ) ??
      defaultValue ??
      enums
          .ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch
          .swaggerGeneratedUnknown;
}

enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch?
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArchNullableFromJson(
  Object? apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch, [
  enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch?
  defaultValue,
]) {
  if (apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch == null) {
    return null;
  }
  return enums
          .ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch,
          ) ??
      defaultValue;
}

String
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArchExplodedListToJson(
  List<enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch>?
  apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch,
) {
  return apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArchListToJson(
  List<enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch>?
  apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch,
) {
  if (apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch == null) {
    return [];
  }

  return apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch>
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArchListFromJson(
  List? apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch, [
  List<enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch>?
  defaultValue,
]) {
  if (apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch == null) {
    return defaultValue ?? [];
  }

  return apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch
      .map(
        (e) =>
            apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArchFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch>?
apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArchNullableListFromJson(
  List? apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch, [
  List<enums.ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch>?
  defaultValue,
]) {
  if (apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch == null) {
    return defaultValue;
  }

  return apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch
      .map(
        (e) =>
            apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArchFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String?
apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatformNullableToJson(
  enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform?
  apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform,
) {
  return apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform?.value;
}

String? apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatformToJson(
  enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform
  apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform,
) {
  return apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform.value;
}

enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform
apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatformFromJson(
  Object? apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform, [
  enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform?
  defaultValue,
]) {
  return enums
          .ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform,
          ) ??
      defaultValue ??
      enums
          .ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform
          .swaggerGeneratedUnknown;
}

enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform?
apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatformNullableFromJson(
  Object? apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform, [
  enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform?
  defaultValue,
]) {
  if (apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform == null) {
    return null;
  }
  return enums
          .ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform,
          ) ??
      defaultValue;
}

String
apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatformExplodedListToJson(
  List<enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform>?
  apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform,
) {
  return apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatformListToJson(
  List<enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform>?
  apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform,
) {
  if (apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform == null) {
    return [];
  }

  return apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform>
apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatformListFromJson(
  List? apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform, [
  List<enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform>?
  defaultValue,
]) {
  if (apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform == null) {
    return defaultValue ?? [];
  }

  return apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform
      .map(
        (e) =>
            apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatformFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform>?
apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatformNullableListFromJson(
  List? apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform, [
  List<enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform>?
  defaultValue,
]) {
  if (apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform == null) {
    return defaultValue;
  }

  return apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform
      .map(
        (e) =>
            apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatformFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String? apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArchNullableToJson(
  enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch?
  apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch,
) {
  return apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch?.value;
}

String? apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArchToJson(
  enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch
  apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch,
) {
  return apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch.value;
}

enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch
apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArchFromJson(
  Object? apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch, [
  enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch? defaultValue,
]) {
  return enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch,
          ) ??
      defaultValue ??
      enums
          .ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch
          .swaggerGeneratedUnknown;
}

enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch?
apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArchNullableFromJson(
  Object? apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch, [
  enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch? defaultValue,
]) {
  if (apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch == null) {
    return null;
  }
  return enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch,
          ) ??
      defaultValue;
}

String
apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArchExplodedListToJson(
  List<enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch>?
  apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch,
) {
  return apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArchListToJson(
  List<enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch>?
  apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch,
) {
  if (apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch == null) {
    return [];
  }

  return apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch>
apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArchListFromJson(
  List? apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch, [
  List<enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch>?
  defaultValue,
]) {
  if (apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch == null) {
    return defaultValue ?? [];
  }

  return apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch
      .map(
        (e) =>
            apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArchFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch>?
apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArchNullableListFromJson(
  List? apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch, [
  List<enums.ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch>?
  defaultValue,
]) {
  if (apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch == null) {
    return defaultValue;
  }

  return apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch
      .map(
        (e) =>
            apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArchFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String? apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKindNullableToJson(
  enums.ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind?
  apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind,
) {
  return apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind?.value;
}

String? apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKindToJson(
  enums.ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind
  apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind,
) {
  return apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind.value;
}

enums.ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind
apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKindFromJson(
  Object? apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind, [
  enums.ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind? defaultValue,
]) {
  return enums.ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind.values
          .firstWhereOrNull(
            (e) =>
                e.value == apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind?
apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKindNullableFromJson(
  Object? apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind, [
  enums.ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind? defaultValue,
]) {
  if (apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind == null) {
    return null;
  }
  return enums.ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind.values
          .firstWhereOrNull(
            (e) =>
                e.value == apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind,
          ) ??
      defaultValue;
}

String apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKindExplodedListToJson(
  List<enums.ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind>?
  apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind,
) {
  return apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKindListToJson(
  List<enums.ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind>?
  apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind,
) {
  if (apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind == null) {
    return [];
  }

  return apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind>
apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKindListFromJson(
  List? apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind, [
  List<enums.ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind>? defaultValue,
]) {
  if (apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind == null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind
      .map(
        (e) => apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKindFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind>?
apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKindNullableListFromJson(
  List? apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind, [
  List<enums.ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind>? defaultValue,
]) {
  if (apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind == null) {
    return defaultValue;
  }

  return apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind
      .map(
        (e) => apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKindFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatformNullableToJson(
  enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform?
  apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform,
) {
  return apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform?.value;
}

String? apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatformToJson(
  enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform
  apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform,
) {
  return apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform.value;
}

enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform
apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatformFromJson(
  Object? apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform, [
  enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform? defaultValue,
]) {
  return enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform.values
          .firstWhereOrNull(
            (e) =>
                e.value == apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform?
apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatformNullableFromJson(
  Object? apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform, [
  enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform? defaultValue,
]) {
  if (apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform == null) {
    return null;
  }
  return enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform.values
          .firstWhereOrNull(
            (e) =>
                e.value == apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform,
          ) ??
      defaultValue;
}

String apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatformExplodedListToJson(
  List<enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform>?
  apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform,
) {
  return apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatformListToJson(
  List<enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform>?
  apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform,
) {
  if (apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform == null) {
    return [];
  }

  return apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform>
apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatformListFromJson(
  List? apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform, [
  List<enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform>? defaultValue,
]) {
  if (apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform == null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform
      .map(
        (e) => apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatformFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform>?
apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatformNullableListFromJson(
  List? apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform, [
  List<enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform>? defaultValue,
]) {
  if (apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform == null) {
    return defaultValue;
  }

  return apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform
      .map(
        (e) => apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatformFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1AppsAppIdBuildProfilesPost$RequestBodyArchNullableToJson(
  enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch?
  apiV1AppsAppIdBuildProfilesPost$RequestBodyArch,
) {
  return apiV1AppsAppIdBuildProfilesPost$RequestBodyArch?.value;
}

String? apiV1AppsAppIdBuildProfilesPost$RequestBodyArchToJson(
  enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch
  apiV1AppsAppIdBuildProfilesPost$RequestBodyArch,
) {
  return apiV1AppsAppIdBuildProfilesPost$RequestBodyArch.value;
}

enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch
apiV1AppsAppIdBuildProfilesPost$RequestBodyArchFromJson(
  Object? apiV1AppsAppIdBuildProfilesPost$RequestBodyArch, [
  enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch? defaultValue,
]) {
  return enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch.values
          .firstWhereOrNull(
            (e) => e.value == apiV1AppsAppIdBuildProfilesPost$RequestBodyArch,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch?
apiV1AppsAppIdBuildProfilesPost$RequestBodyArchNullableFromJson(
  Object? apiV1AppsAppIdBuildProfilesPost$RequestBodyArch, [
  enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch? defaultValue,
]) {
  if (apiV1AppsAppIdBuildProfilesPost$RequestBodyArch == null) {
    return null;
  }
  return enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch.values
          .firstWhereOrNull(
            (e) => e.value == apiV1AppsAppIdBuildProfilesPost$RequestBodyArch,
          ) ??
      defaultValue;
}

String apiV1AppsAppIdBuildProfilesPost$RequestBodyArchExplodedListToJson(
  List<enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch>?
  apiV1AppsAppIdBuildProfilesPost$RequestBodyArch,
) {
  return apiV1AppsAppIdBuildProfilesPost$RequestBodyArch
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1AppsAppIdBuildProfilesPost$RequestBodyArchListToJson(
  List<enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch>?
  apiV1AppsAppIdBuildProfilesPost$RequestBodyArch,
) {
  if (apiV1AppsAppIdBuildProfilesPost$RequestBodyArch == null) {
    return [];
  }

  return apiV1AppsAppIdBuildProfilesPost$RequestBodyArch
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch>
apiV1AppsAppIdBuildProfilesPost$RequestBodyArchListFromJson(
  List? apiV1AppsAppIdBuildProfilesPost$RequestBodyArch, [
  List<enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch>? defaultValue,
]) {
  if (apiV1AppsAppIdBuildProfilesPost$RequestBodyArch == null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdBuildProfilesPost$RequestBodyArch
      .map(
        (e) => apiV1AppsAppIdBuildProfilesPost$RequestBodyArchFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch>?
apiV1AppsAppIdBuildProfilesPost$RequestBodyArchNullableListFromJson(
  List? apiV1AppsAppIdBuildProfilesPost$RequestBodyArch, [
  List<enums.ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch>? defaultValue,
]) {
  if (apiV1AppsAppIdBuildProfilesPost$RequestBodyArch == null) {
    return defaultValue;
  }

  return apiV1AppsAppIdBuildProfilesPost$RequestBodyArch
      .map(
        (e) => apiV1AppsAppIdBuildProfilesPost$RequestBodyArchFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerModeNullableToJson(
  enums.ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode?
  apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode,
) {
  return apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode?.value;
}

String? apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerModeToJson(
  enums.ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode
  apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode,
) {
  return apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode.value;
}

enums.ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode
apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerModeFromJson(
  Object? apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode, [
  enums.ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode? defaultValue,
]) {
  return enums.ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode,
          ) ??
      defaultValue ??
      enums
          .ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode
          .swaggerGeneratedUnknown;
}

enums.ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode?
apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerModeNullableFromJson(
  Object? apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode, [
  enums.ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode? defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode == null) {
    return null;
  }
  return enums.ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode,
          ) ??
      defaultValue;
}

String apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerModeExplodedListToJson(
  List<enums.ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode>?
  apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode,
) {
  return apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerModeListToJson(
  List<enums.ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode>?
  apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode,
) {
  if (apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode == null) {
    return [];
  }

  return apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode>
apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerModeListFromJson(
  List? apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode, [
  List<enums.ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode>?
  defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode == null) {
    return defaultValue ?? [];
  }

  return apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode
      .map(
        (e) => apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerModeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode>?
apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerModeNullableListFromJson(
  List? apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode, [
  List<enums.ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode>?
  defaultValue,
]) {
  if (apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode == null) {
    return defaultValue;
  }

  return apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode
      .map(
        (e) => apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerModeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1ChannelsPost$RequestBodyKindNullableToJson(
  enums.ApiV1ChannelsPost$RequestBodyKind? apiV1ChannelsPost$RequestBodyKind,
) {
  return apiV1ChannelsPost$RequestBodyKind?.value;
}

String? apiV1ChannelsPost$RequestBodyKindToJson(
  enums.ApiV1ChannelsPost$RequestBodyKind apiV1ChannelsPost$RequestBodyKind,
) {
  return apiV1ChannelsPost$RequestBodyKind.value;
}

enums.ApiV1ChannelsPost$RequestBodyKind
apiV1ChannelsPost$RequestBodyKindFromJson(
  Object? apiV1ChannelsPost$RequestBodyKind, [
  enums.ApiV1ChannelsPost$RequestBodyKind? defaultValue,
]) {
  return enums.ApiV1ChannelsPost$RequestBodyKind.values.firstWhereOrNull(
        (e) => e.value == apiV1ChannelsPost$RequestBodyKind,
      ) ??
      defaultValue ??
      enums.ApiV1ChannelsPost$RequestBodyKind.swaggerGeneratedUnknown;
}

enums.ApiV1ChannelsPost$RequestBodyKind?
apiV1ChannelsPost$RequestBodyKindNullableFromJson(
  Object? apiV1ChannelsPost$RequestBodyKind, [
  enums.ApiV1ChannelsPost$RequestBodyKind? defaultValue,
]) {
  if (apiV1ChannelsPost$RequestBodyKind == null) {
    return null;
  }
  return enums.ApiV1ChannelsPost$RequestBodyKind.values.firstWhereOrNull(
        (e) => e.value == apiV1ChannelsPost$RequestBodyKind,
      ) ??
      defaultValue;
}

String apiV1ChannelsPost$RequestBodyKindExplodedListToJson(
  List<enums.ApiV1ChannelsPost$RequestBodyKind>?
  apiV1ChannelsPost$RequestBodyKind,
) {
  return apiV1ChannelsPost$RequestBodyKind?.map((e) => e.value!).join(',') ??
      '';
}

List<String> apiV1ChannelsPost$RequestBodyKindListToJson(
  List<enums.ApiV1ChannelsPost$RequestBodyKind>?
  apiV1ChannelsPost$RequestBodyKind,
) {
  if (apiV1ChannelsPost$RequestBodyKind == null) {
    return [];
  }

  return apiV1ChannelsPost$RequestBodyKind.map((e) => e.value!).toList();
}

List<enums.ApiV1ChannelsPost$RequestBodyKind>
apiV1ChannelsPost$RequestBodyKindListFromJson(
  List? apiV1ChannelsPost$RequestBodyKind, [
  List<enums.ApiV1ChannelsPost$RequestBodyKind>? defaultValue,
]) {
  if (apiV1ChannelsPost$RequestBodyKind == null) {
    return defaultValue ?? [];
  }

  return apiV1ChannelsPost$RequestBodyKind
      .map((e) => apiV1ChannelsPost$RequestBodyKindFromJson(e.toString()))
      .toList();
}

List<enums.ApiV1ChannelsPost$RequestBodyKind>?
apiV1ChannelsPost$RequestBodyKindNullableListFromJson(
  List? apiV1ChannelsPost$RequestBodyKind, [
  List<enums.ApiV1ChannelsPost$RequestBodyKind>? defaultValue,
]) {
  if (apiV1ChannelsPost$RequestBodyKind == null) {
    return defaultValue;
  }

  return apiV1ChannelsPost$RequestBodyKind
      .map((e) => apiV1ChannelsPost$RequestBodyKindFromJson(e.toString()))
      .toList();
}

String? apiV1ChannelsPost$RequestBodyVisibilityNullableToJson(
  enums.ApiV1ChannelsPost$RequestBodyVisibility?
  apiV1ChannelsPost$RequestBodyVisibility,
) {
  return apiV1ChannelsPost$RequestBodyVisibility?.value;
}

String? apiV1ChannelsPost$RequestBodyVisibilityToJson(
  enums.ApiV1ChannelsPost$RequestBodyVisibility
  apiV1ChannelsPost$RequestBodyVisibility,
) {
  return apiV1ChannelsPost$RequestBodyVisibility.value;
}

enums.ApiV1ChannelsPost$RequestBodyVisibility
apiV1ChannelsPost$RequestBodyVisibilityFromJson(
  Object? apiV1ChannelsPost$RequestBodyVisibility, [
  enums.ApiV1ChannelsPost$RequestBodyVisibility? defaultValue,
]) {
  return enums.ApiV1ChannelsPost$RequestBodyVisibility.values.firstWhereOrNull(
        (e) => e.value == apiV1ChannelsPost$RequestBodyVisibility,
      ) ??
      defaultValue ??
      enums.ApiV1ChannelsPost$RequestBodyVisibility.swaggerGeneratedUnknown;
}

enums.ApiV1ChannelsPost$RequestBodyVisibility?
apiV1ChannelsPost$RequestBodyVisibilityNullableFromJson(
  Object? apiV1ChannelsPost$RequestBodyVisibility, [
  enums.ApiV1ChannelsPost$RequestBodyVisibility? defaultValue,
]) {
  if (apiV1ChannelsPost$RequestBodyVisibility == null) {
    return null;
  }
  return enums.ApiV1ChannelsPost$RequestBodyVisibility.values.firstWhereOrNull(
        (e) => e.value == apiV1ChannelsPost$RequestBodyVisibility,
      ) ??
      defaultValue;
}

String apiV1ChannelsPost$RequestBodyVisibilityExplodedListToJson(
  List<enums.ApiV1ChannelsPost$RequestBodyVisibility>?
  apiV1ChannelsPost$RequestBodyVisibility,
) {
  return apiV1ChannelsPost$RequestBodyVisibility
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1ChannelsPost$RequestBodyVisibilityListToJson(
  List<enums.ApiV1ChannelsPost$RequestBodyVisibility>?
  apiV1ChannelsPost$RequestBodyVisibility,
) {
  if (apiV1ChannelsPost$RequestBodyVisibility == null) {
    return [];
  }

  return apiV1ChannelsPost$RequestBodyVisibility.map((e) => e.value!).toList();
}

List<enums.ApiV1ChannelsPost$RequestBodyVisibility>
apiV1ChannelsPost$RequestBodyVisibilityListFromJson(
  List? apiV1ChannelsPost$RequestBodyVisibility, [
  List<enums.ApiV1ChannelsPost$RequestBodyVisibility>? defaultValue,
]) {
  if (apiV1ChannelsPost$RequestBodyVisibility == null) {
    return defaultValue ?? [];
  }

  return apiV1ChannelsPost$RequestBodyVisibility
      .map((e) => apiV1ChannelsPost$RequestBodyVisibilityFromJson(e.toString()))
      .toList();
}

List<enums.ApiV1ChannelsPost$RequestBodyVisibility>?
apiV1ChannelsPost$RequestBodyVisibilityNullableListFromJson(
  List? apiV1ChannelsPost$RequestBodyVisibility, [
  List<enums.ApiV1ChannelsPost$RequestBodyVisibility>? defaultValue,
]) {
  if (apiV1ChannelsPost$RequestBodyVisibility == null) {
    return defaultValue;
  }

  return apiV1ChannelsPost$RequestBodyVisibility
      .map((e) => apiV1ChannelsPost$RequestBodyVisibilityFromJson(e.toString()))
      .toList();
}

String? apiV1ChannelsChannelIdPatch$RequestBodyVisibilityNullableToJson(
  enums.ApiV1ChannelsChannelIdPatch$RequestBodyVisibility?
  apiV1ChannelsChannelIdPatch$RequestBodyVisibility,
) {
  return apiV1ChannelsChannelIdPatch$RequestBodyVisibility?.value;
}

String? apiV1ChannelsChannelIdPatch$RequestBodyVisibilityToJson(
  enums.ApiV1ChannelsChannelIdPatch$RequestBodyVisibility
  apiV1ChannelsChannelIdPatch$RequestBodyVisibility,
) {
  return apiV1ChannelsChannelIdPatch$RequestBodyVisibility.value;
}

enums.ApiV1ChannelsChannelIdPatch$RequestBodyVisibility
apiV1ChannelsChannelIdPatch$RequestBodyVisibilityFromJson(
  Object? apiV1ChannelsChannelIdPatch$RequestBodyVisibility, [
  enums.ApiV1ChannelsChannelIdPatch$RequestBodyVisibility? defaultValue,
]) {
  return enums.ApiV1ChannelsChannelIdPatch$RequestBodyVisibility.values
          .firstWhereOrNull(
            (e) => e.value == apiV1ChannelsChannelIdPatch$RequestBodyVisibility,
          ) ??
      defaultValue ??
      enums
          .ApiV1ChannelsChannelIdPatch$RequestBodyVisibility
          .swaggerGeneratedUnknown;
}

enums.ApiV1ChannelsChannelIdPatch$RequestBodyVisibility?
apiV1ChannelsChannelIdPatch$RequestBodyVisibilityNullableFromJson(
  Object? apiV1ChannelsChannelIdPatch$RequestBodyVisibility, [
  enums.ApiV1ChannelsChannelIdPatch$RequestBodyVisibility? defaultValue,
]) {
  if (apiV1ChannelsChannelIdPatch$RequestBodyVisibility == null) {
    return null;
  }
  return enums.ApiV1ChannelsChannelIdPatch$RequestBodyVisibility.values
          .firstWhereOrNull(
            (e) => e.value == apiV1ChannelsChannelIdPatch$RequestBodyVisibility,
          ) ??
      defaultValue;
}

String apiV1ChannelsChannelIdPatch$RequestBodyVisibilityExplodedListToJson(
  List<enums.ApiV1ChannelsChannelIdPatch$RequestBodyVisibility>?
  apiV1ChannelsChannelIdPatch$RequestBodyVisibility,
) {
  return apiV1ChannelsChannelIdPatch$RequestBodyVisibility
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1ChannelsChannelIdPatch$RequestBodyVisibilityListToJson(
  List<enums.ApiV1ChannelsChannelIdPatch$RequestBodyVisibility>?
  apiV1ChannelsChannelIdPatch$RequestBodyVisibility,
) {
  if (apiV1ChannelsChannelIdPatch$RequestBodyVisibility == null) {
    return [];
  }

  return apiV1ChannelsChannelIdPatch$RequestBodyVisibility
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ChannelsChannelIdPatch$RequestBodyVisibility>
apiV1ChannelsChannelIdPatch$RequestBodyVisibilityListFromJson(
  List? apiV1ChannelsChannelIdPatch$RequestBodyVisibility, [
  List<enums.ApiV1ChannelsChannelIdPatch$RequestBodyVisibility>? defaultValue,
]) {
  if (apiV1ChannelsChannelIdPatch$RequestBodyVisibility == null) {
    return defaultValue ?? [];
  }

  return apiV1ChannelsChannelIdPatch$RequestBodyVisibility
      .map(
        (e) => apiV1ChannelsChannelIdPatch$RequestBodyVisibilityFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1ChannelsChannelIdPatch$RequestBodyVisibility>?
apiV1ChannelsChannelIdPatch$RequestBodyVisibilityNullableListFromJson(
  List? apiV1ChannelsChannelIdPatch$RequestBodyVisibility, [
  List<enums.ApiV1ChannelsChannelIdPatch$RequestBodyVisibility>? defaultValue,
]) {
  if (apiV1ChannelsChannelIdPatch$RequestBodyVisibility == null) {
    return defaultValue;
  }

  return apiV1ChannelsChannelIdPatch$RequestBodyVisibility
      .map(
        (e) => apiV1ChannelsChannelIdPatch$RequestBodyVisibilityFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatformNullableToJson(
  enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform?
  apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform,
) {
  return apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform?.value;
}

String? apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatformToJson(
  enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform
  apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform,
) {
  return apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform.value;
}

enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform
apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatformFromJson(
  Object? apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform, [
  enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform? defaultValue,
]) {
  return enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform,
          ) ??
      defaultValue ??
      enums
          .ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform
          .swaggerGeneratedUnknown;
}

enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform?
apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatformNullableFromJson(
  Object? apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform, [
  enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform? defaultValue,
]) {
  if (apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform == null) {
    return null;
  }
  return enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform,
          ) ??
      defaultValue;
}

String apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatformExplodedListToJson(
  List<enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform>?
  apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform,
) {
  return apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatformListToJson(
  List<enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform>?
  apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform,
) {
  if (apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform == null) {
    return [];
  }

  return apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform>
apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatformListFromJson(
  List? apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform, [
  List<enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform>?
  defaultValue,
]) {
  if (apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform == null) {
    return defaultValue ?? [];
  }

  return apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform
      .map(
        (e) => apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatformFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform>?
apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatformNullableListFromJson(
  List? apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform, [
  List<enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform>?
  defaultValue,
]) {
  if (apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform == null) {
    return defaultValue;
  }

  return apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform
      .map(
        (e) => apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatformFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1ChannelsChannelIdRollbackPost$RequestBodyArchNullableToJson(
  enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch?
  apiV1ChannelsChannelIdRollbackPost$RequestBodyArch,
) {
  return apiV1ChannelsChannelIdRollbackPost$RequestBodyArch?.value;
}

String? apiV1ChannelsChannelIdRollbackPost$RequestBodyArchToJson(
  enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch
  apiV1ChannelsChannelIdRollbackPost$RequestBodyArch,
) {
  return apiV1ChannelsChannelIdRollbackPost$RequestBodyArch.value;
}

enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch
apiV1ChannelsChannelIdRollbackPost$RequestBodyArchFromJson(
  Object? apiV1ChannelsChannelIdRollbackPost$RequestBodyArch, [
  enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch? defaultValue,
]) {
  return enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch.values
          .firstWhereOrNull(
            (e) =>
                e.value == apiV1ChannelsChannelIdRollbackPost$RequestBodyArch,
          ) ??
      defaultValue ??
      enums
          .ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch
          .swaggerGeneratedUnknown;
}

enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch?
apiV1ChannelsChannelIdRollbackPost$RequestBodyArchNullableFromJson(
  Object? apiV1ChannelsChannelIdRollbackPost$RequestBodyArch, [
  enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch? defaultValue,
]) {
  if (apiV1ChannelsChannelIdRollbackPost$RequestBodyArch == null) {
    return null;
  }
  return enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch.values
          .firstWhereOrNull(
            (e) =>
                e.value == apiV1ChannelsChannelIdRollbackPost$RequestBodyArch,
          ) ??
      defaultValue;
}

String apiV1ChannelsChannelIdRollbackPost$RequestBodyArchExplodedListToJson(
  List<enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch>?
  apiV1ChannelsChannelIdRollbackPost$RequestBodyArch,
) {
  return apiV1ChannelsChannelIdRollbackPost$RequestBodyArch
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1ChannelsChannelIdRollbackPost$RequestBodyArchListToJson(
  List<enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch>?
  apiV1ChannelsChannelIdRollbackPost$RequestBodyArch,
) {
  if (apiV1ChannelsChannelIdRollbackPost$RequestBodyArch == null) {
    return [];
  }

  return apiV1ChannelsChannelIdRollbackPost$RequestBodyArch
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch>
apiV1ChannelsChannelIdRollbackPost$RequestBodyArchListFromJson(
  List? apiV1ChannelsChannelIdRollbackPost$RequestBodyArch, [
  List<enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch>? defaultValue,
]) {
  if (apiV1ChannelsChannelIdRollbackPost$RequestBodyArch == null) {
    return defaultValue ?? [];
  }

  return apiV1ChannelsChannelIdRollbackPost$RequestBodyArch
      .map(
        (e) => apiV1ChannelsChannelIdRollbackPost$RequestBodyArchFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch>?
apiV1ChannelsChannelIdRollbackPost$RequestBodyArchNullableListFromJson(
  List? apiV1ChannelsChannelIdRollbackPost$RequestBodyArch, [
  List<enums.ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch>? defaultValue,
]) {
  if (apiV1ChannelsChannelIdRollbackPost$RequestBodyArch == null) {
    return defaultValue;
  }

  return apiV1ChannelsChannelIdRollbackPost$RequestBodyArch
      .map(
        (e) => apiV1ChannelsChannelIdRollbackPost$RequestBodyArchFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String?
apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatformNullableToJson(
  enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform?
  apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform,
) {
  return apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform
      ?.value;
}

String?
apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatformToJson(
  enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform
  apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform,
) {
  return apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform
      .value;
}

enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform
apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatformFromJson(
  Object? apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform, [
  enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform?
  defaultValue,
]) {
  return enums
          .ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform,
          ) ??
      defaultValue ??
      enums
          .ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform
          .swaggerGeneratedUnknown;
}

enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform?
apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatformNullableFromJson(
  Object? apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform, [
  enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform?
  defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform ==
      null) {
    return null;
  }
  return enums
          .ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform,
          ) ??
      defaultValue;
}

String
apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatformExplodedListToJson(
  List<
    enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform
  >?
  apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform,
) {
  return apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatformListToJson(
  List<
    enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform
  >?
  apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform,
) {
  if (apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform ==
      null) {
    return [];
  }

  return apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform>
apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatformListFromJson(
  List? apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform, [
  List<
    enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform
  >?
  defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform ==
      null) {
    return defaultValue ?? [];
  }

  return apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform
      .map(
        (e) =>
            apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatformFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform>?
apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatformNullableListFromJson(
  List? apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform, [
  List<
    enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform
  >?
  defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform ==
      null) {
    return defaultValue;
  }

  return apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform
      .map(
        (e) =>
            apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatformFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String?
apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArchNullableToJson(
  enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch?
  apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch,
) {
  return apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch?.value;
}

String? apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArchToJson(
  enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch
  apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch,
) {
  return apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch.value;
}

enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch
apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArchFromJson(
  Object? apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch, [
  enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch?
  defaultValue,
]) {
  return enums
          .ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch,
          ) ??
      defaultValue ??
      enums
          .ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch
          .swaggerGeneratedUnknown;
}

enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch?
apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArchNullableFromJson(
  Object? apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch, [
  enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch?
  defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch == null) {
    return null;
  }
  return enums
          .ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch,
          ) ??
      defaultValue;
}

String
apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArchExplodedListToJson(
  List<enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch>?
  apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch,
) {
  return apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArchListToJson(
  List<enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch>?
  apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch,
) {
  if (apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch == null) {
    return [];
  }

  return apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch>
apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArchListFromJson(
  List? apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch, [
  List<enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch>?
  defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch == null) {
    return defaultValue ?? [];
  }

  return apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch
      .map(
        (e) =>
            apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArchFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch>?
apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArchNullableListFromJson(
  List? apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch, [
  List<enums.ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch>?
  defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch == null) {
    return defaultValue;
  }

  return apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch
      .map(
        (e) =>
            apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArchFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String? apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatformNullableToJson(
  enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform?
  apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform,
) {
  return apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform?.value;
}

String? apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatformToJson(
  enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform
  apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform,
) {
  return apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform.value;
}

enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform
apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatformFromJson(
  Object? apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform, [
  enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform? defaultValue,
]) {
  return enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform,
          ) ??
      defaultValue ??
      enums
          .ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform
          .swaggerGeneratedUnknown;
}

enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform?
apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatformNullableFromJson(
  Object? apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform, [
  enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform == null) {
    return null;
  }
  return enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform,
          ) ??
      defaultValue;
}

String apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatformExplodedListToJson(
  List<enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform>?
  apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform,
) {
  return apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatformListToJson(
  List<enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform>?
  apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform,
) {
  if (apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform == null) {
    return [];
  }

  return apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform>
apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatformListFromJson(
  List? apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform, [
  List<enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform>?
  defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform == null) {
    return defaultValue ?? [];
  }

  return apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform
      .map(
        (e) => apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatformFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform>?
apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatformNullableListFromJson(
  List? apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform, [
  List<enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform>?
  defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform == null) {
    return defaultValue;
  }

  return apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform
      .map(
        (e) => apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatformFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1ReleasesReleaseIdPromotePost$RequestBodyArchNullableToJson(
  enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch?
  apiV1ReleasesReleaseIdPromotePost$RequestBodyArch,
) {
  return apiV1ReleasesReleaseIdPromotePost$RequestBodyArch?.value;
}

String? apiV1ReleasesReleaseIdPromotePost$RequestBodyArchToJson(
  enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch
  apiV1ReleasesReleaseIdPromotePost$RequestBodyArch,
) {
  return apiV1ReleasesReleaseIdPromotePost$RequestBodyArch.value;
}

enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch
apiV1ReleasesReleaseIdPromotePost$RequestBodyArchFromJson(
  Object? apiV1ReleasesReleaseIdPromotePost$RequestBodyArch, [
  enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch? defaultValue,
]) {
  return enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch.values
          .firstWhereOrNull(
            (e) => e.value == apiV1ReleasesReleaseIdPromotePost$RequestBodyArch,
          ) ??
      defaultValue ??
      enums
          .ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch
          .swaggerGeneratedUnknown;
}

enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch?
apiV1ReleasesReleaseIdPromotePost$RequestBodyArchNullableFromJson(
  Object? apiV1ReleasesReleaseIdPromotePost$RequestBodyArch, [
  enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPromotePost$RequestBodyArch == null) {
    return null;
  }
  return enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch.values
          .firstWhereOrNull(
            (e) => e.value == apiV1ReleasesReleaseIdPromotePost$RequestBodyArch,
          ) ??
      defaultValue;
}

String apiV1ReleasesReleaseIdPromotePost$RequestBodyArchExplodedListToJson(
  List<enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch>?
  apiV1ReleasesReleaseIdPromotePost$RequestBodyArch,
) {
  return apiV1ReleasesReleaseIdPromotePost$RequestBodyArch
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1ReleasesReleaseIdPromotePost$RequestBodyArchListToJson(
  List<enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch>?
  apiV1ReleasesReleaseIdPromotePost$RequestBodyArch,
) {
  if (apiV1ReleasesReleaseIdPromotePost$RequestBodyArch == null) {
    return [];
  }

  return apiV1ReleasesReleaseIdPromotePost$RequestBodyArch
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch>
apiV1ReleasesReleaseIdPromotePost$RequestBodyArchListFromJson(
  List? apiV1ReleasesReleaseIdPromotePost$RequestBodyArch, [
  List<enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch>? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPromotePost$RequestBodyArch == null) {
    return defaultValue ?? [];
  }

  return apiV1ReleasesReleaseIdPromotePost$RequestBodyArch
      .map(
        (e) => apiV1ReleasesReleaseIdPromotePost$RequestBodyArchFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch>?
apiV1ReleasesReleaseIdPromotePost$RequestBodyArchNullableListFromJson(
  List? apiV1ReleasesReleaseIdPromotePost$RequestBodyArch, [
  List<enums.ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch>? defaultValue,
]) {
  if (apiV1ReleasesReleaseIdPromotePost$RequestBodyArch == null) {
    return defaultValue;
  }

  return apiV1ReleasesReleaseIdPromotePost$RequestBodyArch
      .map(
        (e) => apiV1ReleasesReleaseIdPromotePost$RequestBodyArchFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1ArtifactsUploadUrlPost$RequestBodyPlatformNullableToJson(
  enums.ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform?
  apiV1ArtifactsUploadUrlPost$RequestBodyPlatform,
) {
  return apiV1ArtifactsUploadUrlPost$RequestBodyPlatform?.value;
}

String? apiV1ArtifactsUploadUrlPost$RequestBodyPlatformToJson(
  enums.ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform
  apiV1ArtifactsUploadUrlPost$RequestBodyPlatform,
) {
  return apiV1ArtifactsUploadUrlPost$RequestBodyPlatform.value;
}

enums.ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform
apiV1ArtifactsUploadUrlPost$RequestBodyPlatformFromJson(
  Object? apiV1ArtifactsUploadUrlPost$RequestBodyPlatform, [
  enums.ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform? defaultValue,
]) {
  return enums.ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform.values
          .firstWhereOrNull(
            (e) => e.value == apiV1ArtifactsUploadUrlPost$RequestBodyPlatform,
          ) ??
      defaultValue ??
      enums
          .ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform
          .swaggerGeneratedUnknown;
}

enums.ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform?
apiV1ArtifactsUploadUrlPost$RequestBodyPlatformNullableFromJson(
  Object? apiV1ArtifactsUploadUrlPost$RequestBodyPlatform, [
  enums.ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform? defaultValue,
]) {
  if (apiV1ArtifactsUploadUrlPost$RequestBodyPlatform == null) {
    return null;
  }
  return enums.ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform.values
          .firstWhereOrNull(
            (e) => e.value == apiV1ArtifactsUploadUrlPost$RequestBodyPlatform,
          ) ??
      defaultValue;
}

String apiV1ArtifactsUploadUrlPost$RequestBodyPlatformExplodedListToJson(
  List<enums.ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform>?
  apiV1ArtifactsUploadUrlPost$RequestBodyPlatform,
) {
  return apiV1ArtifactsUploadUrlPost$RequestBodyPlatform
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1ArtifactsUploadUrlPost$RequestBodyPlatformListToJson(
  List<enums.ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform>?
  apiV1ArtifactsUploadUrlPost$RequestBodyPlatform,
) {
  if (apiV1ArtifactsUploadUrlPost$RequestBodyPlatform == null) {
    return [];
  }

  return apiV1ArtifactsUploadUrlPost$RequestBodyPlatform
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform>
apiV1ArtifactsUploadUrlPost$RequestBodyPlatformListFromJson(
  List? apiV1ArtifactsUploadUrlPost$RequestBodyPlatform, [
  List<enums.ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform>? defaultValue,
]) {
  if (apiV1ArtifactsUploadUrlPost$RequestBodyPlatform == null) {
    return defaultValue ?? [];
  }

  return apiV1ArtifactsUploadUrlPost$RequestBodyPlatform
      .map(
        (e) => apiV1ArtifactsUploadUrlPost$RequestBodyPlatformFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform>?
apiV1ArtifactsUploadUrlPost$RequestBodyPlatformNullableListFromJson(
  List? apiV1ArtifactsUploadUrlPost$RequestBodyPlatform, [
  List<enums.ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform>? defaultValue,
]) {
  if (apiV1ArtifactsUploadUrlPost$RequestBodyPlatform == null) {
    return defaultValue;
  }

  return apiV1ArtifactsUploadUrlPost$RequestBodyPlatform
      .map(
        (e) => apiV1ArtifactsUploadUrlPost$RequestBodyPlatformFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? apiV1ArtifactsUploadUrlPost$RequestBodyArchNullableToJson(
  enums.ApiV1ArtifactsUploadUrlPost$RequestBodyArch?
  apiV1ArtifactsUploadUrlPost$RequestBodyArch,
) {
  return apiV1ArtifactsUploadUrlPost$RequestBodyArch?.value;
}

String? apiV1ArtifactsUploadUrlPost$RequestBodyArchToJson(
  enums.ApiV1ArtifactsUploadUrlPost$RequestBodyArch
  apiV1ArtifactsUploadUrlPost$RequestBodyArch,
) {
  return apiV1ArtifactsUploadUrlPost$RequestBodyArch.value;
}

enums.ApiV1ArtifactsUploadUrlPost$RequestBodyArch
apiV1ArtifactsUploadUrlPost$RequestBodyArchFromJson(
  Object? apiV1ArtifactsUploadUrlPost$RequestBodyArch, [
  enums.ApiV1ArtifactsUploadUrlPost$RequestBodyArch? defaultValue,
]) {
  return enums.ApiV1ArtifactsUploadUrlPost$RequestBodyArch.values
          .firstWhereOrNull(
            (e) => e.value == apiV1ArtifactsUploadUrlPost$RequestBodyArch,
          ) ??
      defaultValue ??
      enums.ApiV1ArtifactsUploadUrlPost$RequestBodyArch.swaggerGeneratedUnknown;
}

enums.ApiV1ArtifactsUploadUrlPost$RequestBodyArch?
apiV1ArtifactsUploadUrlPost$RequestBodyArchNullableFromJson(
  Object? apiV1ArtifactsUploadUrlPost$RequestBodyArch, [
  enums.ApiV1ArtifactsUploadUrlPost$RequestBodyArch? defaultValue,
]) {
  if (apiV1ArtifactsUploadUrlPost$RequestBodyArch == null) {
    return null;
  }
  return enums.ApiV1ArtifactsUploadUrlPost$RequestBodyArch.values
          .firstWhereOrNull(
            (e) => e.value == apiV1ArtifactsUploadUrlPost$RequestBodyArch,
          ) ??
      defaultValue;
}

String apiV1ArtifactsUploadUrlPost$RequestBodyArchExplodedListToJson(
  List<enums.ApiV1ArtifactsUploadUrlPost$RequestBodyArch>?
  apiV1ArtifactsUploadUrlPost$RequestBodyArch,
) {
  return apiV1ArtifactsUploadUrlPost$RequestBodyArch
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> apiV1ArtifactsUploadUrlPost$RequestBodyArchListToJson(
  List<enums.ApiV1ArtifactsUploadUrlPost$RequestBodyArch>?
  apiV1ArtifactsUploadUrlPost$RequestBodyArch,
) {
  if (apiV1ArtifactsUploadUrlPost$RequestBodyArch == null) {
    return [];
  }

  return apiV1ArtifactsUploadUrlPost$RequestBodyArch
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ArtifactsUploadUrlPost$RequestBodyArch>
apiV1ArtifactsUploadUrlPost$RequestBodyArchListFromJson(
  List? apiV1ArtifactsUploadUrlPost$RequestBodyArch, [
  List<enums.ApiV1ArtifactsUploadUrlPost$RequestBodyArch>? defaultValue,
]) {
  if (apiV1ArtifactsUploadUrlPost$RequestBodyArch == null) {
    return defaultValue ?? [];
  }

  return apiV1ArtifactsUploadUrlPost$RequestBodyArch
      .map(
        (e) =>
            apiV1ArtifactsUploadUrlPost$RequestBodyArchFromJson(e.toString()),
      )
      .toList();
}

List<enums.ApiV1ArtifactsUploadUrlPost$RequestBodyArch>?
apiV1ArtifactsUploadUrlPost$RequestBodyArchNullableListFromJson(
  List? apiV1ArtifactsUploadUrlPost$RequestBodyArch, [
  List<enums.ApiV1ArtifactsUploadUrlPost$RequestBodyArch>? defaultValue,
]) {
  if (apiV1ArtifactsUploadUrlPost$RequestBodyArch == null) {
    return defaultValue;
  }

  return apiV1ArtifactsUploadUrlPost$RequestBodyArch
      .map(
        (e) =>
            apiV1ArtifactsUploadUrlPost$RequestBodyArchFromJson(e.toString()),
      )
      .toList();
}

String?
apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatformNullableToJson(
  enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform?
  apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform,
) {
  return apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform
      ?.value;
}

String? apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatformToJson(
  enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform
  apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform,
) {
  return apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform.value;
}

enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform
apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatformFromJson(
  Object? apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform, [
  enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform?
  defaultValue,
]) {
  return enums
          .ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform,
          ) ??
      defaultValue ??
      enums
          .ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform
          .swaggerGeneratedUnknown;
}

enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform?
apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatformNullableFromJson(
  Object? apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform, [
  enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform?
  defaultValue,
]) {
  if (apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform ==
      null) {
    return null;
  }
  return enums
          .ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform,
          ) ??
      defaultValue;
}

String
apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatformExplodedListToJson(
  List<enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform>?
  apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform,
) {
  return apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatformListToJson(
  List<enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform>?
  apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform,
) {
  if (apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform ==
      null) {
    return [];
  }

  return apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform>
apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatformListFromJson(
  List? apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform, [
  List<enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform>?
  defaultValue,
]) {
  if (apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform ==
      null) {
    return defaultValue ?? [];
  }

  return apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform
      .map(
        (e) =>
            apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatformFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform>?
apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatformNullableListFromJson(
  List? apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform, [
  List<enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform>?
  defaultValue,
]) {
  if (apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform ==
      null) {
    return defaultValue;
  }

  return apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform
      .map(
        (e) =>
            apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatformFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String?
apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArchNullableToJson(
  enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch?
  apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch,
) {
  return apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch?.value;
}

String? apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArchToJson(
  enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch
  apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch,
) {
  return apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch.value;
}

enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch
apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArchFromJson(
  Object? apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch, [
  enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch?
  defaultValue,
]) {
  return enums
          .ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch,
          ) ??
      defaultValue ??
      enums
          .ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch
          .swaggerGeneratedUnknown;
}

enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch?
apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArchNullableFromJson(
  Object? apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch, [
  enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch?
  defaultValue,
]) {
  if (apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch == null) {
    return null;
  }
  return enums
          .ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch,
          ) ??
      defaultValue;
}

String
apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArchExplodedListToJson(
  List<enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch>?
  apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch,
) {
  return apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArchListToJson(
  List<enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch>?
  apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch,
) {
  if (apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch == null) {
    return [];
  }

  return apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch
      .map((e) => e.value!)
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch>
apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArchListFromJson(
  List? apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch, [
  List<enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch>?
  defaultValue,
]) {
  if (apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch == null) {
    return defaultValue ?? [];
  }

  return apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch
      .map(
        (e) =>
            apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArchFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch>?
apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArchNullableListFromJson(
  List? apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch, [
  List<enums.ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch>?
  defaultValue,
]) {
  if (apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch == null) {
    return defaultValue;
  }

  return apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch
      .map(
        (e) =>
            apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArchFromJson(
              e.toString(),
            ),
      )
      .toList();
}

// ignore: unused_element
String? _dateToJson(DateTime? date) {
  if (date == null) {
    return null;
  }

  final year = date.year.toString();
  final month = date.month < 10 ? '0${date.month}' : date.month.toString();
  final day = date.day < 10 ? '0${date.day}' : date.day.toString();

  return '$year-$month-$day';
}

class Wrapped<T> {
  final T value;
  const Wrapped.value(this.value);
}
