// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openapi.models.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV1ApiKeysPost$RequestBody _$ApiV1ApiKeysPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV1ApiKeysPost$RequestBody(name: json['name'] as String);

Map<String, dynamic> _$ApiV1ApiKeysPost$RequestBodyToJson(
  ApiV1ApiKeysPost$RequestBody instance,
) => <String, dynamic>{'name': instance.name};

ApiV1AppsPost$RequestBody _$ApiV1AppsPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsPost$RequestBody(
  slug: json['slug'] as String,
  name: json['name'] as String,
  bundleId: json['bundleId'] as String?,
);

Map<String, dynamic> _$ApiV1AppsPost$RequestBodyToJson(
  ApiV1AppsPost$RequestBody instance,
) => <String, dynamic>{
  'slug': instance.slug,
  'name': instance.name,
  'bundleId': ?instance.bundleId,
};

ApiV1AppsAppIdRepositoryConnectionPut$RequestBody
_$ApiV1AppsAppIdRepositoryConnectionPut$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdRepositoryConnectionPut$RequestBody(
  owner: json['owner'] as String,
  repo: json['repo'] as String,
  installationId: json['installationId'] as String?,
  defaultBranch: json['defaultBranch'] as String?,
  workflowFile: json['workflowFile'] as String?,
);

Map<String, dynamic> _$ApiV1AppsAppIdRepositoryConnectionPut$RequestBodyToJson(
  ApiV1AppsAppIdRepositoryConnectionPut$RequestBody instance,
) => <String, dynamic>{
  'owner': instance.owner,
  'repo': instance.repo,
  'installationId': ?instance.installationId,
  'defaultBranch': ?instance.defaultBranch,
  'workflowFile': ?instance.workflowFile,
};

ApiV1AppsAppIdDeploymentTargetsPost$RequestBody
_$ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdDeploymentTargetsPost$RequestBody(
  kind: apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKindFromJson(
    json['kind'],
  ),
  name: json['name'] as String,
  config: json['config'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyToJson(
  ApiV1AppsAppIdDeploymentTargetsPost$RequestBody instance,
) => <String, dynamic>{
  'kind': ?apiV1AppsAppIdDeploymentTargetsPost$RequestBodyKindToJson(
    instance.kind,
  ),
  'name': instance.name,
  'config': ?instance.config,
};

ApiV1AppsAppIdBuildProfilesPost$RequestBody
_$ApiV1AppsAppIdBuildProfilesPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdBuildProfilesPost$RequestBody(
  name: json['name'] as String,
  platform: apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatformFromJson(
    json['platform'],
  ),
  packageType: json['packageType'] as String,
  arch: apiV1AppsAppIdBuildProfilesPost$RequestBodyArchNullableFromJson(
    json['arch'],
  ),
  workflowIdentifier: json['workflowIdentifier'] as String,
  workflowRef: json['workflowRef'] as String?,
  workflowInputs: json['workflowInputs'] as Map<String, dynamic>?,
  artifactPathGlob: json['artifactPathGlob'] as String?,
  autoDeployTargetId: json['autoDeployTargetId'] as String?,
);

Map<String, dynamic> _$ApiV1AppsAppIdBuildProfilesPost$RequestBodyToJson(
  ApiV1AppsAppIdBuildProfilesPost$RequestBody instance,
) => <String, dynamic>{
  'name': instance.name,
  'platform': ?apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatformToJson(
    instance.platform,
  ),
  'packageType': instance.packageType,
  'arch': ?apiV1AppsAppIdBuildProfilesPost$RequestBodyArchNullableToJson(
    instance.arch,
  ),
  'workflowIdentifier': instance.workflowIdentifier,
  'workflowRef': ?instance.workflowRef,
  'workflowInputs': ?instance.workflowInputs,
  'artifactPathGlob': ?instance.artifactPathGlob,
  'autoDeployTargetId': ?instance.autoDeployTargetId,
};

ApiV1AppsAppIdPipelineRunsPost$RequestBody
_$ApiV1AppsAppIdPipelineRunsPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdPipelineRunsPost$RequestBody(
  branch: json['branch'] as String?,
  profileIds:
      (json['profileIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  triggerMode:
      apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerModeNullableFromJson(
        json['triggerMode'],
      ),
  releaseId: json['releaseId'] as String?,
  commitSha: json['commitSha'] as String?,
);

Map<String, dynamic> _$ApiV1AppsAppIdPipelineRunsPost$RequestBodyToJson(
  ApiV1AppsAppIdPipelineRunsPost$RequestBody instance,
) => <String, dynamic>{
  'branch': ?instance.branch,
  'profileIds': instance.profileIds,
  'triggerMode':
      ?apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerModeNullableToJson(
        instance.triggerMode,
      ),
  'releaseId': ?instance.releaseId,
  'commitSha': ?instance.commitSha,
};

ApiV1ChannelsPost$RequestBody _$ApiV1ChannelsPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV1ChannelsPost$RequestBody(
  appId: json['appId'] as String,
  slug: json['slug'] as String,
  displayName: json['displayName'] as String?,
  kind: apiV1ChannelsPost$RequestBodyKindFromJson(json['kind']),
  visibility: apiV1ChannelsPost$RequestBodyVisibilityNullableFromJson(
    json['visibility'],
  ),
  parentChannelId: json['parentChannelId'] as String?,
  rolloutPercent: (json['rolloutPercent'] as num?)?.toInt(),
);

Map<String, dynamic> _$ApiV1ChannelsPost$RequestBodyToJson(
  ApiV1ChannelsPost$RequestBody instance,
) => <String, dynamic>{
  'appId': instance.appId,
  'slug': instance.slug,
  'displayName': ?instance.displayName,
  'kind': ?apiV1ChannelsPost$RequestBodyKindToJson(instance.kind),
  'visibility': ?apiV1ChannelsPost$RequestBodyVisibilityNullableToJson(
    instance.visibility,
  ),
  'parentChannelId': ?instance.parentChannelId,
  'rolloutPercent': ?instance.rolloutPercent,
};

ApiV1ChannelsChannelIdPatch$RequestBody
_$ApiV1ChannelsChannelIdPatch$RequestBodyFromJson(Map<String, dynamic> json) =>
    ApiV1ChannelsChannelIdPatch$RequestBody(
      displayName: json['displayName'] as String?,
      visibility:
          apiV1ChannelsChannelIdPatch$RequestBodyVisibilityNullableFromJson(
            json['visibility'],
          ),
      rolloutPercent: (json['rolloutPercent'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ApiV1ChannelsChannelIdPatch$RequestBodyToJson(
  ApiV1ChannelsChannelIdPatch$RequestBody instance,
) => <String, dynamic>{
  'displayName': ?instance.displayName,
  'visibility':
      ?apiV1ChannelsChannelIdPatch$RequestBodyVisibilityNullableToJson(
        instance.visibility,
      ),
  'rolloutPercent': ?instance.rolloutPercent,
};

ApiV1ChannelsChannelIdRollbackPost$RequestBody
_$ApiV1ChannelsChannelIdRollbackPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV1ChannelsChannelIdRollbackPost$RequestBody(
  platform:
      apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatformNullableFromJson(
        json['platform'],
      ),
  arch: apiV1ChannelsChannelIdRollbackPost$RequestBodyArchNullableFromJson(
    json['arch'],
  ),
  toReleaseId: json['toReleaseId'] as String?,
);

Map<String, dynamic> _$ApiV1ChannelsChannelIdRollbackPost$RequestBodyToJson(
  ApiV1ChannelsChannelIdRollbackPost$RequestBody instance,
) => <String, dynamic>{
  'platform':
      ?apiV1ChannelsChannelIdRollbackPost$RequestBodyPlatformNullableToJson(
        instance.platform,
      ),
  'arch': ?apiV1ChannelsChannelIdRollbackPost$RequestBodyArchNullableToJson(
    instance.arch,
  ),
  'toReleaseId': ?instance.toReleaseId,
};

ApiV1ReleasesPost$RequestBody _$ApiV1ReleasesPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesPost$RequestBody(
  appId: json['appId'] as String,
  version: json['version'] as String,
  buildNumber: json['buildNumber'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$ApiV1ReleasesPost$RequestBodyToJson(
  ApiV1ReleasesPost$RequestBody instance,
) => <String, dynamic>{
  'appId': instance.appId,
  'version': instance.version,
  'buildNumber': ?instance.buildNumber,
  'notes': ?instance.notes,
};

ApiV1ReleasesReleaseIdPublishPost$RequestBody
_$ApiV1ReleasesReleaseIdPublishPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesReleaseIdPublishPost$RequestBody(
  targets: (json['targets'] as List<dynamic>)
      .map(
        (e) =>
            ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$Item.fromJson(
              e as Map<String, dynamic>,
            ),
      )
      .toList(),
);

Map<String, dynamic> _$ApiV1ReleasesReleaseIdPublishPost$RequestBodyToJson(
  ApiV1ReleasesReleaseIdPublishPost$RequestBody instance,
) => <String, dynamic>{
  'targets': instance.targets.map((e) => e.toJson()).toList(),
};

ApiV1ReleasesReleaseIdPromotePost$RequestBody
_$ApiV1ReleasesReleaseIdPromotePost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesReleaseIdPromotePost$RequestBody(
  fromChannelId: json['fromChannelId'] as String,
  toChannelId: json['toChannelId'] as String,
  platform:
      apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatformNullableFromJson(
        json['platform'],
      ),
  arch: apiV1ReleasesReleaseIdPromotePost$RequestBodyArchNullableFromJson(
    json['arch'],
  ),
);

Map<String, dynamic> _$ApiV1ReleasesReleaseIdPromotePost$RequestBodyToJson(
  ApiV1ReleasesReleaseIdPromotePost$RequestBody instance,
) => <String, dynamic>{
  'fromChannelId': instance.fromChannelId,
  'toChannelId': instance.toChannelId,
  'platform':
      ?apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatformNullableToJson(
        instance.platform,
      ),
  'arch': ?apiV1ReleasesReleaseIdPromotePost$RequestBodyArchNullableToJson(
    instance.arch,
  ),
};

ApiV1ArtifactsUploadUrlPost$RequestBody
_$ApiV1ArtifactsUploadUrlPost$RequestBodyFromJson(Map<String, dynamic> json) =>
    ApiV1ArtifactsUploadUrlPost$RequestBody(
      platform: apiV1ArtifactsUploadUrlPost$RequestBodyPlatformFromJson(
        json['platform'],
      ),
      arch: apiV1ArtifactsUploadUrlPost$RequestBodyArchNullableFromJson(
        json['arch'],
      ),
      packageType: json['packageType'] as String,
      fileName: json['fileName'] as String,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      sha256: json['sha256'] as String?,
      assignChannelSlug: json['assignChannelSlug'] as String?,
      appSlug: json['appSlug'] as String,
      version: json['version'] as String,
      buildNumber: json['buildNumber'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ApiV1ArtifactsUploadUrlPost$RequestBodyToJson(
  ApiV1ArtifactsUploadUrlPost$RequestBody instance,
) => <String, dynamic>{
  'platform': ?apiV1ArtifactsUploadUrlPost$RequestBodyPlatformToJson(
    instance.platform,
  ),
  'arch': ?apiV1ArtifactsUploadUrlPost$RequestBodyArchNullableToJson(
    instance.arch,
  ),
  'packageType': instance.packageType,
  'fileName': instance.fileName,
  'sizeBytes': ?instance.sizeBytes,
  'sha256': ?instance.sha256,
  'assignChannelSlug': ?instance.assignChannelSlug,
  'appSlug': instance.appSlug,
  'version': instance.version,
  'buildNumber': ?instance.buildNumber,
  'notes': ?instance.notes,
};

ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBody
_$ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBody(
  platform:
      apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatformFromJson(
        json['platform'],
      ),
  arch:
      apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArchNullableFromJson(
        json['arch'],
      ),
  packageType: json['packageType'] as String,
  fileName: json['fileName'] as String,
  sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
  sha256: json['sha256'] as String?,
  assignChannelSlug: json['assignChannelSlug'] as String?,
);

Map<String, dynamic>
_$ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyToJson(
  ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBody instance,
) => <String, dynamic>{
  'platform':
      ?apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatformToJson(
        instance.platform,
      ),
  'arch':
      ?apiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArchNullableToJson(
        instance.arch,
      ),
  'packageType': instance.packageType,
  'fileName': instance.fileName,
  'sizeBytes': ?instance.sizeBytes,
  'sha256': ?instance.sha256,
  'assignChannelSlug': ?instance.assignChannelSlug,
};

ApiHealthzGet$Response _$ApiHealthzGet$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiHealthzGet$Response(
  service: json['service'] as String,
  version: json['version'] as String,
  status: json['status'] as String,
  now: json['now'] as String,
);

Map<String, dynamic> _$ApiHealthzGet$ResponseToJson(
  ApiHealthzGet$Response instance,
) => <String, dynamic>{
  'service': instance.service,
  'version': instance.version,
  'status': instance.status,
  'now': instance.now,
};

ApiV1ApiKeysGet$Response$Item _$ApiV1ApiKeysGet$Response$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1ApiKeysGet$Response$Item(
  id: json['id'] as String,
  name: json['name'] as String,
  tokenId: json['tokenId'] as String,
  keyPrefix: json['keyPrefix'] as String,
  createdByUserId: json['createdByUserId'] as String?,
  createdAt: json['createdAt'] as String,
  lastUsedAt: json['lastUsedAt'] as String?,
  revokedAt: json['revokedAt'] as String?,
  revokedByUserId: json['revokedByUserId'] as String?,
);

Map<String, dynamic> _$ApiV1ApiKeysGet$Response$ItemToJson(
  ApiV1ApiKeysGet$Response$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'tokenId': instance.tokenId,
  'keyPrefix': instance.keyPrefix,
  'createdByUserId': ?instance.createdByUserId,
  'createdAt': instance.createdAt,
  'lastUsedAt': ?instance.lastUsedAt,
  'revokedAt': ?instance.revokedAt,
  'revokedByUserId': ?instance.revokedByUserId,
};

ApiV1ApiKeysPost$Response _$ApiV1ApiKeysPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1ApiKeysPost$Response(
  apiKey: ApiV1ApiKeysPost$Response$ApiKey.fromJson(
    json['apiKey'] as Map<String, dynamic>,
  ),
  plainTextKey: json['plainTextKey'] as String,
);

Map<String, dynamic> _$ApiV1ApiKeysPost$ResponseToJson(
  ApiV1ApiKeysPost$Response instance,
) => <String, dynamic>{
  'apiKey': instance.apiKey.toJson(),
  'plainTextKey': instance.plainTextKey,
};

ApiV1ApiKeysApiKeyIdRevokePost$Response
_$ApiV1ApiKeysApiKeyIdRevokePost$ResponseFromJson(Map<String, dynamic> json) =>
    ApiV1ApiKeysApiKeyIdRevokePost$Response(
      id: json['id'] as String,
      name: json['name'] as String,
      tokenId: json['tokenId'] as String,
      keyPrefix: json['keyPrefix'] as String,
      createdByUserId: json['createdByUserId'] as String?,
      createdAt: json['createdAt'] as String,
      lastUsedAt: json['lastUsedAt'] as String?,
      revokedAt: json['revokedAt'] as String?,
      revokedByUserId: json['revokedByUserId'] as String?,
    );

Map<String, dynamic> _$ApiV1ApiKeysApiKeyIdRevokePost$ResponseToJson(
  ApiV1ApiKeysApiKeyIdRevokePost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'tokenId': instance.tokenId,
  'keyPrefix': instance.keyPrefix,
  'createdByUserId': ?instance.createdByUserId,
  'createdAt': instance.createdAt,
  'lastUsedAt': ?instance.lastUsedAt,
  'revokedAt': ?instance.revokedAt,
  'revokedByUserId': ?instance.revokedByUserId,
};

ApiV1AppsGet$Response$Item _$ApiV1AppsGet$Response$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsGet$Response$Item(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String,
  bundleId: json['bundleId'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$ApiV1AppsGet$Response$ItemToJson(
  ApiV1AppsGet$Response$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'bundleId': ?instance.bundleId,
  'createdAt': instance.createdAt,
};

ApiV1AppsPost$Response _$ApiV1AppsPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsPost$Response(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String,
  bundleId: json['bundleId'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$ApiV1AppsPost$ResponseToJson(
  ApiV1AppsPost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'bundleId': ?instance.bundleId,
  'createdAt': instance.createdAt,
};

ApiV1AppsAppIdRepositoryConnectionGet$Response
_$ApiV1AppsAppIdRepositoryConnectionGet$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdRepositoryConnectionGet$Response(
  id: json['id'] as String,
  appId: json['appId'] as String,
  provider: apiV1AppsAppIdRepositoryConnectionGet$ResponseProviderFromJson(
    json['provider'],
  ),
  owner: json['owner'] as String,
  repo: json['repo'] as String,
  installationId: json['installationId'] as String?,
  defaultBranch: json['defaultBranch'] as String,
  workflowFile: json['workflowFile'] as String?,
  createdByUserId: json['createdByUserId'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$ApiV1AppsAppIdRepositoryConnectionGet$ResponseToJson(
  ApiV1AppsAppIdRepositoryConnectionGet$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'appId': instance.appId,
  'provider': ?apiV1AppsAppIdRepositoryConnectionGet$ResponseProviderToJson(
    instance.provider,
  ),
  'owner': instance.owner,
  'repo': instance.repo,
  'installationId': ?instance.installationId,
  'defaultBranch': instance.defaultBranch,
  'workflowFile': ?instance.workflowFile,
  'createdByUserId': ?instance.createdByUserId,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

ApiV1AppsAppIdRepositoryConnectionPut$Response
_$ApiV1AppsAppIdRepositoryConnectionPut$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdRepositoryConnectionPut$Response(
  id: json['id'] as String,
  appId: json['appId'] as String,
  provider: apiV1AppsAppIdRepositoryConnectionPut$ResponseProviderFromJson(
    json['provider'],
  ),
  owner: json['owner'] as String,
  repo: json['repo'] as String,
  installationId: json['installationId'] as String?,
  defaultBranch: json['defaultBranch'] as String,
  workflowFile: json['workflowFile'] as String?,
  createdByUserId: json['createdByUserId'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$ApiV1AppsAppIdRepositoryConnectionPut$ResponseToJson(
  ApiV1AppsAppIdRepositoryConnectionPut$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'appId': instance.appId,
  'provider': ?apiV1AppsAppIdRepositoryConnectionPut$ResponseProviderToJson(
    instance.provider,
  ),
  'owner': instance.owner,
  'repo': instance.repo,
  'installationId': ?instance.installationId,
  'defaultBranch': instance.defaultBranch,
  'workflowFile': ?instance.workflowFile,
  'createdByUserId': ?instance.createdByUserId,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

ApiV1AppsAppIdDeploymentTargetsGet$Response$Item
_$ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdDeploymentTargetsGet$Response$Item(
  id: json['id'] as String,
  appId: json['appId'] as String,
  kind: apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKindFromJson(
    json['kind'],
  ),
  name: json['name'] as String,
  config: json['config'] as Map<String, dynamic>,
  createdByUserId: json['createdByUserId'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  disabledAt: json['disabledAt'] as String?,
);

Map<String, dynamic> _$ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemToJson(
  ApiV1AppsAppIdDeploymentTargetsGet$Response$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'appId': instance.appId,
  'kind': ?apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKindToJson(
    instance.kind,
  ),
  'name': instance.name,
  'config': instance.config,
  'createdByUserId': ?instance.createdByUserId,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'disabledAt': ?instance.disabledAt,
};

ApiV1AppsAppIdDeploymentTargetsPost$Response
_$ApiV1AppsAppIdDeploymentTargetsPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdDeploymentTargetsPost$Response(
  id: json['id'] as String,
  appId: json['appId'] as String,
  kind: apiV1AppsAppIdDeploymentTargetsPost$ResponseKindFromJson(json['kind']),
  name: json['name'] as String,
  config: json['config'] as Map<String, dynamic>,
  createdByUserId: json['createdByUserId'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  disabledAt: json['disabledAt'] as String?,
);

Map<String, dynamic> _$ApiV1AppsAppIdDeploymentTargetsPost$ResponseToJson(
  ApiV1AppsAppIdDeploymentTargetsPost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'appId': instance.appId,
  'kind': ?apiV1AppsAppIdDeploymentTargetsPost$ResponseKindToJson(
    instance.kind,
  ),
  'name': instance.name,
  'config': instance.config,
  'createdByUserId': ?instance.createdByUserId,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'disabledAt': ?instance.disabledAt,
};

ApiV1AppsAppIdBuildProfilesGet$Response$Item
_$ApiV1AppsAppIdBuildProfilesGet$Response$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdBuildProfilesGet$Response$Item(
  id: json['id'] as String,
  appId: json['appId'] as String,
  name: json['name'] as String,
  platform: apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatformFromJson(
    json['platform'],
  ),
  packageType: json['packageType'] as String,
  arch: apiV1AppsAppIdBuildProfilesGet$Response$ItemArchNullableFromJson(
    json['arch'],
  ),
  workflowIdentifier: json['workflowIdentifier'] as String,
  workflowRef: json['workflowRef'] as String?,
  workflowInputs: json['workflowInputs'] as Map<String, dynamic>,
  artifactPathGlob: json['artifactPathGlob'] as String?,
  autoDeployTargetId: json['autoDeployTargetId'] as String?,
  createdByUserId: json['createdByUserId'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  disabledAt: json['disabledAt'] as String?,
);

Map<String, dynamic> _$ApiV1AppsAppIdBuildProfilesGet$Response$ItemToJson(
  ApiV1AppsAppIdBuildProfilesGet$Response$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'appId': instance.appId,
  'name': instance.name,
  'platform': ?apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatformToJson(
    instance.platform,
  ),
  'packageType': instance.packageType,
  'arch': ?apiV1AppsAppIdBuildProfilesGet$Response$ItemArchNullableToJson(
    instance.arch,
  ),
  'workflowIdentifier': instance.workflowIdentifier,
  'workflowRef': ?instance.workflowRef,
  'workflowInputs': instance.workflowInputs,
  'artifactPathGlob': ?instance.artifactPathGlob,
  'autoDeployTargetId': ?instance.autoDeployTargetId,
  'createdByUserId': ?instance.createdByUserId,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'disabledAt': ?instance.disabledAt,
};

ApiV1AppsAppIdBuildProfilesPost$Response
_$ApiV1AppsAppIdBuildProfilesPost$ResponseFromJson(Map<String, dynamic> json) =>
    ApiV1AppsAppIdBuildProfilesPost$Response(
      id: json['id'] as String,
      appId: json['appId'] as String,
      name: json['name'] as String,
      platform: apiV1AppsAppIdBuildProfilesPost$ResponsePlatformFromJson(
        json['platform'],
      ),
      packageType: json['packageType'] as String,
      arch: apiV1AppsAppIdBuildProfilesPost$ResponseArchNullableFromJson(
        json['arch'],
      ),
      workflowIdentifier: json['workflowIdentifier'] as String,
      workflowRef: json['workflowRef'] as String?,
      workflowInputs: json['workflowInputs'] as Map<String, dynamic>,
      artifactPathGlob: json['artifactPathGlob'] as String?,
      autoDeployTargetId: json['autoDeployTargetId'] as String?,
      createdByUserId: json['createdByUserId'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      disabledAt: json['disabledAt'] as String?,
    );

Map<String, dynamic> _$ApiV1AppsAppIdBuildProfilesPost$ResponseToJson(
  ApiV1AppsAppIdBuildProfilesPost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'appId': instance.appId,
  'name': instance.name,
  'platform': ?apiV1AppsAppIdBuildProfilesPost$ResponsePlatformToJson(
    instance.platform,
  ),
  'packageType': instance.packageType,
  'arch': ?apiV1AppsAppIdBuildProfilesPost$ResponseArchNullableToJson(
    instance.arch,
  ),
  'workflowIdentifier': instance.workflowIdentifier,
  'workflowRef': ?instance.workflowRef,
  'workflowInputs': instance.workflowInputs,
  'artifactPathGlob': ?instance.artifactPathGlob,
  'autoDeployTargetId': ?instance.autoDeployTargetId,
  'createdByUserId': ?instance.createdByUserId,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'disabledAt': ?instance.disabledAt,
};

ApiV1AppsAppIdPipelineRunsGet$Response$Item
_$ApiV1AppsAppIdPipelineRunsGet$Response$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdPipelineRunsGet$Response$Item(
  id: json['id'] as String,
  appId: json['appId'] as String,
  repositoryConnectionId: json['repositoryConnectionId'] as String?,
  releaseId: json['releaseId'] as String?,
  triggerMode: apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerModeFromJson(
    json['triggerMode'],
  ),
  branch: json['branch'] as String,
  commitSha: json['commitSha'] as String?,
  status: apiV1AppsAppIdPipelineRunsGet$Response$ItemStatusFromJson(
    json['status'],
  ),
  requestedByUserId: json['requestedByUserId'] as String?,
  externalRunId: json['externalRunId'] as String?,
  startedAt: json['startedAt'] as String?,
  finishedAt: json['finishedAt'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$ApiV1AppsAppIdPipelineRunsGet$Response$ItemToJson(
  ApiV1AppsAppIdPipelineRunsGet$Response$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'appId': instance.appId,
  'repositoryConnectionId': ?instance.repositoryConnectionId,
  'releaseId': ?instance.releaseId,
  'triggerMode': ?apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerModeToJson(
    instance.triggerMode,
  ),
  'branch': instance.branch,
  'commitSha': ?instance.commitSha,
  'status': ?apiV1AppsAppIdPipelineRunsGet$Response$ItemStatusToJson(
    instance.status,
  ),
  'requestedByUserId': ?instance.requestedByUserId,
  'externalRunId': ?instance.externalRunId,
  'startedAt': ?instance.startedAt,
  'finishedAt': ?instance.finishedAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

ApiV1AppsAppIdPipelineRunsPost$Response
_$ApiV1AppsAppIdPipelineRunsPost$ResponseFromJson(Map<String, dynamic> json) =>
    ApiV1AppsAppIdPipelineRunsPost$Response(
      id: json['id'] as String,
      appId: json['appId'] as String,
      repositoryConnectionId: json['repositoryConnectionId'] as String?,
      releaseId: json['releaseId'] as String?,
      triggerMode: apiV1AppsAppIdPipelineRunsPost$ResponseTriggerModeFromJson(
        json['triggerMode'],
      ),
      branch: json['branch'] as String,
      commitSha: json['commitSha'] as String?,
      status: apiV1AppsAppIdPipelineRunsPost$ResponseStatusFromJson(
        json['status'],
      ),
      requestedByUserId: json['requestedByUserId'] as String?,
      externalRunId: json['externalRunId'] as String?,
      startedAt: json['startedAt'] as String?,
      finishedAt: json['finishedAt'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      jobs: (json['jobs'] as List<dynamic>)
          .map(
            (e) => ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$Item.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );

Map<String, dynamic> _$ApiV1AppsAppIdPipelineRunsPost$ResponseToJson(
  ApiV1AppsAppIdPipelineRunsPost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'appId': instance.appId,
  'repositoryConnectionId': ?instance.repositoryConnectionId,
  'releaseId': ?instance.releaseId,
  'triggerMode': ?apiV1AppsAppIdPipelineRunsPost$ResponseTriggerModeToJson(
    instance.triggerMode,
  ),
  'branch': instance.branch,
  'commitSha': ?instance.commitSha,
  'status': ?apiV1AppsAppIdPipelineRunsPost$ResponseStatusToJson(
    instance.status,
  ),
  'requestedByUserId': ?instance.requestedByUserId,
  'externalRunId': ?instance.externalRunId,
  'startedAt': ?instance.startedAt,
  'finishedAt': ?instance.finishedAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'jobs': instance.jobs.map((e) => e.toJson()).toList(),
};

ApiV1PipelineRunsPipelineRunIdGet$Response
_$ApiV1PipelineRunsPipelineRunIdGet$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1PipelineRunsPipelineRunIdGet$Response(
  id: json['id'] as String,
  appId: json['appId'] as String,
  repositoryConnectionId: json['repositoryConnectionId'] as String?,
  releaseId: json['releaseId'] as String?,
  triggerMode: apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerModeFromJson(
    json['triggerMode'],
  ),
  branch: json['branch'] as String,
  commitSha: json['commitSha'] as String?,
  status: apiV1PipelineRunsPipelineRunIdGet$ResponseStatusFromJson(
    json['status'],
  ),
  requestedByUserId: json['requestedByUserId'] as String?,
  externalRunId: json['externalRunId'] as String?,
  startedAt: json['startedAt'] as String?,
  finishedAt: json['finishedAt'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  jobs: (json['jobs'] as List<dynamic>)
      .map(
        (e) => ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$Item.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
);

Map<String, dynamic> _$ApiV1PipelineRunsPipelineRunIdGet$ResponseToJson(
  ApiV1PipelineRunsPipelineRunIdGet$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'appId': instance.appId,
  'repositoryConnectionId': ?instance.repositoryConnectionId,
  'releaseId': ?instance.releaseId,
  'triggerMode': ?apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerModeToJson(
    instance.triggerMode,
  ),
  'branch': instance.branch,
  'commitSha': ?instance.commitSha,
  'status': ?apiV1PipelineRunsPipelineRunIdGet$ResponseStatusToJson(
    instance.status,
  ),
  'requestedByUserId': ?instance.requestedByUserId,
  'externalRunId': ?instance.externalRunId,
  'startedAt': ?instance.startedAt,
  'finishedAt': ?instance.finishedAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'jobs': instance.jobs.map((e) => e.toJson()).toList(),
};

ApiV1ChannelsGet$Response$Item _$ApiV1ChannelsGet$Response$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1ChannelsGet$Response$Item(
  id: json['id'] as String,
  appId: json['appId'] as String,
  slug: json['slug'] as String,
  displayName: json['displayName'] as String?,
  kind: apiV1ChannelsGet$Response$ItemKindFromJson(json['kind']),
  visibility: apiV1ChannelsGet$Response$ItemVisibilityFromJson(
    json['visibility'],
  ),
  isSystem: json['isSystem'] as bool,
  rolloutPercent: (json['rolloutPercent'] as num).toInt(),
  parentChannelId: json['parentChannelId'] as String?,
  createdByUserId: json['createdByUserId'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$ApiV1ChannelsGet$Response$ItemToJson(
  ApiV1ChannelsGet$Response$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'appId': instance.appId,
  'slug': instance.slug,
  'displayName': ?instance.displayName,
  'kind': ?apiV1ChannelsGet$Response$ItemKindToJson(instance.kind),
  'visibility': ?apiV1ChannelsGet$Response$ItemVisibilityToJson(
    instance.visibility,
  ),
  'isSystem': instance.isSystem,
  'rolloutPercent': instance.rolloutPercent,
  'parentChannelId': ?instance.parentChannelId,
  'createdByUserId': ?instance.createdByUserId,
  'createdAt': instance.createdAt,
};

ApiV1ChannelsPost$Response _$ApiV1ChannelsPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1ChannelsPost$Response(
  id: json['id'] as String,
  appId: json['appId'] as String,
  slug: json['slug'] as String,
  displayName: json['displayName'] as String?,
  kind: apiV1ChannelsPost$ResponseKindFromJson(json['kind']),
  visibility: apiV1ChannelsPost$ResponseVisibilityFromJson(json['visibility']),
  isSystem: json['isSystem'] as bool,
  rolloutPercent: (json['rolloutPercent'] as num).toInt(),
  parentChannelId: json['parentChannelId'] as String?,
  createdByUserId: json['createdByUserId'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$ApiV1ChannelsPost$ResponseToJson(
  ApiV1ChannelsPost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'appId': instance.appId,
  'slug': instance.slug,
  'displayName': ?instance.displayName,
  'kind': ?apiV1ChannelsPost$ResponseKindToJson(instance.kind),
  'visibility': ?apiV1ChannelsPost$ResponseVisibilityToJson(
    instance.visibility,
  ),
  'isSystem': instance.isSystem,
  'rolloutPercent': instance.rolloutPercent,
  'parentChannelId': ?instance.parentChannelId,
  'createdByUserId': ?instance.createdByUserId,
  'createdAt': instance.createdAt,
};

ApiV1ChannelsChannelIdPatch$Response
_$ApiV1ChannelsChannelIdPatch$ResponseFromJson(Map<String, dynamic> json) =>
    ApiV1ChannelsChannelIdPatch$Response(
      id: json['id'] as String,
      appId: json['appId'] as String,
      slug: json['slug'] as String,
      displayName: json['displayName'] as String?,
      kind: apiV1ChannelsChannelIdPatch$ResponseKindFromJson(json['kind']),
      visibility: apiV1ChannelsChannelIdPatch$ResponseVisibilityFromJson(
        json['visibility'],
      ),
      isSystem: json['isSystem'] as bool,
      rolloutPercent: (json['rolloutPercent'] as num).toInt(),
      parentChannelId: json['parentChannelId'] as String?,
      createdByUserId: json['createdByUserId'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$ApiV1ChannelsChannelIdPatch$ResponseToJson(
  ApiV1ChannelsChannelIdPatch$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'appId': instance.appId,
  'slug': instance.slug,
  'displayName': ?instance.displayName,
  'kind': ?apiV1ChannelsChannelIdPatch$ResponseKindToJson(instance.kind),
  'visibility': ?apiV1ChannelsChannelIdPatch$ResponseVisibilityToJson(
    instance.visibility,
  ),
  'isSystem': instance.isSystem,
  'rolloutPercent': instance.rolloutPercent,
  'parentChannelId': ?instance.parentChannelId,
  'createdByUserId': ?instance.createdByUserId,
  'createdAt': instance.createdAt,
};

ApiV1ChannelsChannelIdRollbackPost$Response
_$ApiV1ChannelsChannelIdRollbackPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1ChannelsChannelIdRollbackPost$Response(
  id: json['id'] as String,
  channelId: json['channelId'] as String,
  releaseId: json['releaseId'] as String,
  platform: apiV1ChannelsChannelIdRollbackPost$ResponsePlatformNullableFromJson(
    json['platform'],
  ),
  arch: apiV1ChannelsChannelIdRollbackPost$ResponseArchNullableFromJson(
    json['arch'],
  ),
  rolloutPercent: (json['rolloutPercent'] as num).toInt(),
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$ApiV1ChannelsChannelIdRollbackPost$ResponseToJson(
  ApiV1ChannelsChannelIdRollbackPost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'channelId': instance.channelId,
  'releaseId': instance.releaseId,
  'platform':
      ?apiV1ChannelsChannelIdRollbackPost$ResponsePlatformNullableToJson(
        instance.platform,
      ),
  'arch': ?apiV1ChannelsChannelIdRollbackPost$ResponseArchNullableToJson(
    instance.arch,
  ),
  'rolloutPercent': instance.rolloutPercent,
  'createdAt': instance.createdAt,
};

ApiV1ReleasesGet$Response$Item _$ApiV1ReleasesGet$Response$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesGet$Response$Item(
  id: json['id'] as String,
  appId: json['appId'] as String,
  version: json['version'] as String,
  buildNumber: json['buildNumber'] as String?,
  status: apiV1ReleasesGet$Response$ItemStatusFromJson(json['status']),
  notes: json['notes'] as String?,
  publishedAt: json['publishedAt'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$ApiV1ReleasesGet$Response$ItemToJson(
  ApiV1ReleasesGet$Response$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'appId': instance.appId,
  'version': instance.version,
  'buildNumber': ?instance.buildNumber,
  'status': ?apiV1ReleasesGet$Response$ItemStatusToJson(instance.status),
  'notes': ?instance.notes,
  'publishedAt': ?instance.publishedAt,
  'createdAt': instance.createdAt,
};

ApiV1ReleasesPost$Response _$ApiV1ReleasesPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesPost$Response(
  id: json['id'] as String,
  appId: json['appId'] as String,
  version: json['version'] as String,
  buildNumber: json['buildNumber'] as String?,
  status: apiV1ReleasesPost$ResponseStatusFromJson(json['status']),
  notes: json['notes'] as String?,
  publishedAt: json['publishedAt'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$ApiV1ReleasesPost$ResponseToJson(
  ApiV1ReleasesPost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'appId': instance.appId,
  'version': instance.version,
  'buildNumber': ?instance.buildNumber,
  'status': ?apiV1ReleasesPost$ResponseStatusToJson(instance.status),
  'notes': ?instance.notes,
  'publishedAt': ?instance.publishedAt,
  'createdAt': instance.createdAt,
};

ApiV1ReleasesReleaseIdGet$Response _$ApiV1ReleasesReleaseIdGet$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesReleaseIdGet$Response(
  id: json['id'] as String,
  appId: json['appId'] as String,
  version: json['version'] as String,
  buildNumber: json['buildNumber'] as String?,
  status: apiV1ReleasesReleaseIdGet$ResponseStatusFromJson(json['status']),
  notes: json['notes'] as String?,
  publishedAt: json['publishedAt'] as String?,
  createdAt: json['createdAt'] as String,
  artifacts: (json['artifacts'] as List<dynamic>)
      .map(
        (e) => ApiV1ReleasesReleaseIdGet$Response$Artifacts$Item.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
);

Map<String, dynamic> _$ApiV1ReleasesReleaseIdGet$ResponseToJson(
  ApiV1ReleasesReleaseIdGet$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'appId': instance.appId,
  'version': instance.version,
  'buildNumber': ?instance.buildNumber,
  'status': ?apiV1ReleasesReleaseIdGet$ResponseStatusToJson(instance.status),
  'notes': ?instance.notes,
  'publishedAt': ?instance.publishedAt,
  'createdAt': instance.createdAt,
  'artifacts': instance.artifacts.map((e) => e.toJson()).toList(),
};

ApiV1ReleasesReleaseIdVerifyPost$Response
_$ApiV1ReleasesReleaseIdVerifyPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesReleaseIdVerifyPost$Response(
  id: json['id'] as String,
  appId: json['appId'] as String,
  version: json['version'] as String,
  buildNumber: json['buildNumber'] as String?,
  status: apiV1ReleasesReleaseIdVerifyPost$ResponseStatusFromJson(
    json['status'],
  ),
  notes: json['notes'] as String?,
  publishedAt: json['publishedAt'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$ApiV1ReleasesReleaseIdVerifyPost$ResponseToJson(
  ApiV1ReleasesReleaseIdVerifyPost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'appId': instance.appId,
  'version': instance.version,
  'buildNumber': ?instance.buildNumber,
  'status': ?apiV1ReleasesReleaseIdVerifyPost$ResponseStatusToJson(
    instance.status,
  ),
  'notes': ?instance.notes,
  'publishedAt': ?instance.publishedAt,
  'createdAt': instance.createdAt,
};

ApiV1ReleasesReleaseIdPublishPost$Response
_$ApiV1ReleasesReleaseIdPublishPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesReleaseIdPublishPost$Response(
  id: json['id'] as String,
  appId: json['appId'] as String,
  version: json['version'] as String,
  buildNumber: json['buildNumber'] as String?,
  status: apiV1ReleasesReleaseIdPublishPost$ResponseStatusFromJson(
    json['status'],
  ),
  notes: json['notes'] as String?,
  publishedAt: json['publishedAt'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$ApiV1ReleasesReleaseIdPublishPost$ResponseToJson(
  ApiV1ReleasesReleaseIdPublishPost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'appId': instance.appId,
  'version': instance.version,
  'buildNumber': ?instance.buildNumber,
  'status': ?apiV1ReleasesReleaseIdPublishPost$ResponseStatusToJson(
    instance.status,
  ),
  'notes': ?instance.notes,
  'publishedAt': ?instance.publishedAt,
  'createdAt': instance.createdAt,
};

ApiV1ReleasesReleaseIdPromotePost$Response
_$ApiV1ReleasesReleaseIdPromotePost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesReleaseIdPromotePost$Response(
  id: json['id'] as String,
  channelId: json['channelId'] as String,
  releaseId: json['releaseId'] as String,
  platform: apiV1ReleasesReleaseIdPromotePost$ResponsePlatformNullableFromJson(
    json['platform'],
  ),
  arch: apiV1ReleasesReleaseIdPromotePost$ResponseArchNullableFromJson(
    json['arch'],
  ),
  rolloutPercent: (json['rolloutPercent'] as num).toInt(),
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$ApiV1ReleasesReleaseIdPromotePost$ResponseToJson(
  ApiV1ReleasesReleaseIdPromotePost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'channelId': instance.channelId,
  'releaseId': instance.releaseId,
  'platform': ?apiV1ReleasesReleaseIdPromotePost$ResponsePlatformNullableToJson(
    instance.platform,
  ),
  'arch': ?apiV1ReleasesReleaseIdPromotePost$ResponseArchNullableToJson(
    instance.arch,
  ),
  'rolloutPercent': instance.rolloutPercent,
  'createdAt': instance.createdAt,
};

ApiV1ArtifactsUploadUrlPost$Response
_$ApiV1ArtifactsUploadUrlPost$ResponseFromJson(Map<String, dynamic> json) =>
    ApiV1ArtifactsUploadUrlPost$Response(
      artifactId: json['artifactId'] as String,
      uploadUrl: json['uploadUrl'] as String,
      s3Key: json['s3Key'] as String,
      expiresAt: json['expiresAt'] as String,
      releaseId: json['releaseId'] as String,
      releaseCreated: json['releaseCreated'] as bool,
    );

Map<String, dynamic> _$ApiV1ArtifactsUploadUrlPost$ResponseToJson(
  ApiV1ArtifactsUploadUrlPost$Response instance,
) => <String, dynamic>{
  'artifactId': instance.artifactId,
  'uploadUrl': instance.uploadUrl,
  's3Key': instance.s3Key,
  'expiresAt': instance.expiresAt,
  'releaseId': instance.releaseId,
  'releaseCreated': instance.releaseCreated,
};

ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$Response
_$ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$Response(
  artifactId: json['artifactId'] as String,
  uploadUrl: json['uploadUrl'] as String,
  s3Key: json['s3Key'] as String,
  expiresAt: json['expiresAt'] as String,
);

Map<String, dynamic>
_$ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$ResponseToJson(
  ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$Response instance,
) => <String, dynamic>{
  'artifactId': instance.artifactId,
  'uploadUrl': instance.uploadUrl,
  's3Key': instance.s3Key,
  'expiresAt': instance.expiresAt,
};

ApiV1MetricsDownloadsGet$Response _$ApiV1MetricsDownloadsGet$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1MetricsDownloadsGet$Response(
  series: (json['series'] as List<dynamic>)
      .map(
        (e) => ApiV1MetricsDownloadsGet$Response$Series$Item.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
);

Map<String, dynamic> _$ApiV1MetricsDownloadsGet$ResponseToJson(
  ApiV1MetricsDownloadsGet$Response instance,
) => <String, dynamic>{
  'series': instance.series.map((e) => e.toJson()).toList(),
};

ApiV1MetricsUpdateChecksGet$Response
_$ApiV1MetricsUpdateChecksGet$ResponseFromJson(Map<String, dynamic> json) =>
    ApiV1MetricsUpdateChecksGet$Response(
      series: (json['series'] as List<dynamic>)
          .map(
            (e) => ApiV1MetricsUpdateChecksGet$Response$Series$Item.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );

Map<String, dynamic> _$ApiV1MetricsUpdateChecksGet$ResponseToJson(
  ApiV1MetricsUpdateChecksGet$Response instance,
) => <String, dynamic>{
  'series': instance.series.map((e) => e.toJson()).toList(),
};

ApiV1DashboardSummaryGet$Response _$ApiV1DashboardSummaryGet$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1DashboardSummaryGet$Response(
  generatedAt: json['generatedAt'] as String,
  totals: ApiV1DashboardSummaryGet$Response$Totals.fromJson(
    json['totals'] as Map<String, dynamic>,
  ),
  apps: (json['apps'] as List<dynamic>)
      .map(
        (e) => ApiV1DashboardSummaryGet$Response$Apps$Item.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  activeAssignments: (json['activeAssignments'] as List<dynamic>)
      .map(
        (e) =>
            ApiV1DashboardSummaryGet$Response$ActiveAssignments$Item.fromJson(
              e as Map<String, dynamic>,
            ),
      )
      .toList(),
);

Map<String, dynamic> _$ApiV1DashboardSummaryGet$ResponseToJson(
  ApiV1DashboardSummaryGet$Response instance,
) => <String, dynamic>{
  'generatedAt': instance.generatedAt,
  'totals': instance.totals.toJson(),
  'apps': instance.apps.map((e) => e.toJson()).toList(),
  'activeAssignments': instance.activeAssignments
      .map((e) => e.toJson())
      .toList(),
};

ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$Item
_$ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$Item(
  channelId: json['channelId'] as String,
  platform:
      apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatformNullableFromJson(
        json['platform'],
      ),
  arch:
      apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArchNullableFromJson(
        json['arch'],
      ),
  rolloutPercent: (json['rolloutPercent'] as num?)?.toInt(),
);

Map<String, dynamic>
_$ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemToJson(
  ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$Item instance,
) => <String, dynamic>{
  'channelId': instance.channelId,
  'platform':
      ?apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatformNullableToJson(
        instance.platform,
      ),
  'arch':
      ?apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArchNullableToJson(
        instance.arch,
      ),
  'rolloutPercent': ?instance.rolloutPercent,
};

ApiV1ApiKeysPost$Response$ApiKey _$ApiV1ApiKeysPost$Response$ApiKeyFromJson(
  Map<String, dynamic> json,
) => ApiV1ApiKeysPost$Response$ApiKey(
  id: json['id'] as String,
  name: json['name'] as String,
  tokenId: json['tokenId'] as String,
  keyPrefix: json['keyPrefix'] as String,
  createdByUserId: json['createdByUserId'] as String?,
  createdAt: json['createdAt'] as String,
  lastUsedAt: json['lastUsedAt'] as String?,
  revokedAt: json['revokedAt'] as String?,
  revokedByUserId: json['revokedByUserId'] as String?,
);

Map<String, dynamic> _$ApiV1ApiKeysPost$Response$ApiKeyToJson(
  ApiV1ApiKeysPost$Response$ApiKey instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'tokenId': instance.tokenId,
  'keyPrefix': instance.keyPrefix,
  'createdByUserId': ?instance.createdByUserId,
  'createdAt': instance.createdAt,
  'lastUsedAt': ?instance.lastUsedAt,
  'revokedAt': ?instance.revokedAt,
  'revokedByUserId': ?instance.revokedByUserId,
};

ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$Item
_$ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$Item(
  id: json['id'] as String,
  pipelineRunId: json['pipelineRunId'] as String,
  buildProfileId: json['buildProfileId'] as String?,
  platform: apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatformFromJson(
    json['platform'],
  ),
  packageType: json['packageType'] as String,
  arch: apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArchNullableFromJson(
    json['arch'],
  ),
  status: apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatusFromJson(
    json['status'],
  ),
  externalJobId: json['externalJobId'] as String?,
  artifactId: json['artifactId'] as String?,
  deploymentTargetId: json['deploymentTargetId'] as String?,
  deploymentStatus:
      apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatusNullableFromJson(
        json['deploymentStatus'],
      ),
  logsUrl: json['logsUrl'] as String?,
  errorMessage: json['errorMessage'] as String?,
  startedAt: json['startedAt'] as String?,
  finishedAt: json['finishedAt'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemToJson(
  ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'pipelineRunId': instance.pipelineRunId,
  'buildProfileId': ?instance.buildProfileId,
  'platform': ?apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatformToJson(
    instance.platform,
  ),
  'packageType': instance.packageType,
  'arch': ?apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArchNullableToJson(
    instance.arch,
  ),
  'status': ?apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatusToJson(
    instance.status,
  ),
  'externalJobId': ?instance.externalJobId,
  'artifactId': ?instance.artifactId,
  'deploymentTargetId': ?instance.deploymentTargetId,
  'deploymentStatus':
      ?apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatusNullableToJson(
        instance.deploymentStatus,
      ),
  'logsUrl': ?instance.logsUrl,
  'errorMessage': ?instance.errorMessage,
  'startedAt': ?instance.startedAt,
  'finishedAt': ?instance.finishedAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$Item
_$ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$Item(
  id: json['id'] as String,
  pipelineRunId: json['pipelineRunId'] as String,
  buildProfileId: json['buildProfileId'] as String?,
  platform:
      apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatformFromJson(
        json['platform'],
      ),
  packageType: json['packageType'] as String,
  arch:
      apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArchNullableFromJson(
        json['arch'],
      ),
  status: apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatusFromJson(
    json['status'],
  ),
  externalJobId: json['externalJobId'] as String?,
  artifactId: json['artifactId'] as String?,
  deploymentTargetId: json['deploymentTargetId'] as String?,
  deploymentStatus:
      apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatusNullableFromJson(
        json['deploymentStatus'],
      ),
  logsUrl: json['logsUrl'] as String?,
  errorMessage: json['errorMessage'] as String?,
  startedAt: json['startedAt'] as String?,
  finishedAt: json['finishedAt'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic>
_$ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemToJson(
  ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'pipelineRunId': instance.pipelineRunId,
  'buildProfileId': ?instance.buildProfileId,
  'platform':
      ?apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatformToJson(
        instance.platform,
      ),
  'packageType': instance.packageType,
  'arch':
      ?apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArchNullableToJson(
        instance.arch,
      ),
  'status': ?apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatusToJson(
    instance.status,
  ),
  'externalJobId': ?instance.externalJobId,
  'artifactId': ?instance.artifactId,
  'deploymentTargetId': ?instance.deploymentTargetId,
  'deploymentStatus':
      ?apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatusNullableToJson(
        instance.deploymentStatus,
      ),
  'logsUrl': ?instance.logsUrl,
  'errorMessage': ?instance.errorMessage,
  'startedAt': ?instance.startedAt,
  'finishedAt': ?instance.finishedAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

ApiV1ReleasesReleaseIdGet$Response$Artifacts$Item
_$ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesReleaseIdGet$Response$Artifacts$Item(
  id: json['id'] as String,
  releaseId: json['releaseId'] as String,
  platform: apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatformFromJson(
    json['platform'],
  ),
  arch: apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArchFromJson(
    json['arch'],
  ),
  packageType: json['packageType'] as String,
  fileName: json['fileName'] as String,
  s3Key: json['s3Key'] as String,
  sha256: json['sha256'] as String?,
  signature: json['signature'] as String?,
  sizeBytes: (json['sizeBytes'] as num).toInt(),
  verified: json['verified'] as bool,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemToJson(
  ApiV1ReleasesReleaseIdGet$Response$Artifacts$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'releaseId': instance.releaseId,
  'platform': ?apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatformToJson(
    instance.platform,
  ),
  'arch': ?apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArchToJson(
    instance.arch,
  ),
  'packageType': instance.packageType,
  'fileName': instance.fileName,
  's3Key': instance.s3Key,
  'sha256': ?instance.sha256,
  'signature': ?instance.signature,
  'sizeBytes': instance.sizeBytes,
  'verified': instance.verified,
  'createdAt': instance.createdAt,
};

ApiV1MetricsDownloadsGet$Response$Series$Item
_$ApiV1MetricsDownloadsGet$Response$Series$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1MetricsDownloadsGet$Response$Series$Item(
  bucketStart: json['bucketStart'] as String,
  count: (json['count'] as num).toInt(),
  channel: json['channel'] as String?,
  platform: json['platform'] as String?,
  arch: json['arch'] as String?,
  version: json['version'] as String?,
);

Map<String, dynamic> _$ApiV1MetricsDownloadsGet$Response$Series$ItemToJson(
  ApiV1MetricsDownloadsGet$Response$Series$Item instance,
) => <String, dynamic>{
  'bucketStart': instance.bucketStart,
  'count': instance.count,
  'channel': ?instance.channel,
  'platform': ?instance.platform,
  'arch': ?instance.arch,
  'version': ?instance.version,
};

ApiV1MetricsUpdateChecksGet$Response$Series$Item
_$ApiV1MetricsUpdateChecksGet$Response$Series$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1MetricsUpdateChecksGet$Response$Series$Item(
  bucketStart: json['bucketStart'] as String,
  count: (json['count'] as num).toInt(),
  channel: json['channel'] as String?,
  platform: json['platform'] as String?,
  arch: json['arch'] as String?,
  version: json['version'] as String?,
);

Map<String, dynamic> _$ApiV1MetricsUpdateChecksGet$Response$Series$ItemToJson(
  ApiV1MetricsUpdateChecksGet$Response$Series$Item instance,
) => <String, dynamic>{
  'bucketStart': instance.bucketStart,
  'count': instance.count,
  'channel': ?instance.channel,
  'platform': ?instance.platform,
  'arch': ?instance.arch,
  'version': ?instance.version,
};

ApiV1DashboardSummaryGet$Response$Totals
_$ApiV1DashboardSummaryGet$Response$TotalsFromJson(Map<String, dynamic> json) =>
    ApiV1DashboardSummaryGet$Response$Totals(
      apps: (json['apps'] as num).toInt(),
      channels: (json['channels'] as num).toInt(),
      releases: (json['releases'] as num).toInt(),
      publishedReleases: (json['publishedReleases'] as num).toInt(),
      artifacts: (json['artifacts'] as num).toInt(),
      channelAssignments: (json['channelAssignments'] as num).toInt(),
      downloadsTotal: (json['downloadsTotal'] as num).toInt(),
      updateChecksTotal: (json['updateChecksTotal'] as num).toInt(),
      downloadsLast7Days: (json['downloadsLast7Days'] as num).toInt(),
      updateChecksLast7Days: (json['updateChecksLast7Days'] as num).toInt(),
    );

Map<String, dynamic> _$ApiV1DashboardSummaryGet$Response$TotalsToJson(
  ApiV1DashboardSummaryGet$Response$Totals instance,
) => <String, dynamic>{
  'apps': instance.apps,
  'channels': instance.channels,
  'releases': instance.releases,
  'publishedReleases': instance.publishedReleases,
  'artifacts': instance.artifacts,
  'channelAssignments': instance.channelAssignments,
  'downloadsTotal': instance.downloadsTotal,
  'updateChecksTotal': instance.updateChecksTotal,
  'downloadsLast7Days': instance.downloadsLast7Days,
  'updateChecksLast7Days': instance.updateChecksLast7Days,
};

ApiV1DashboardSummaryGet$Response$Apps$Item
_$ApiV1DashboardSummaryGet$Response$Apps$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1DashboardSummaryGet$Response$Apps$Item(
  appId: json['appId'] as String,
  appSlug: json['appSlug'] as String,
  appName: json['appName'] as String,
  channels: (json['channels'] as num).toInt(),
  releases: (json['releases'] as num).toInt(),
  publishedReleases: (json['publishedReleases'] as num).toInt(),
  downloadsTotal: (json['downloadsTotal'] as num).toInt(),
  updateChecksTotal: (json['updateChecksTotal'] as num).toInt(),
  lastDownloadAt: json['lastDownloadAt'] as String?,
  lastUpdateCheckAt: json['lastUpdateCheckAt'] as String?,
);

Map<String, dynamic> _$ApiV1DashboardSummaryGet$Response$Apps$ItemToJson(
  ApiV1DashboardSummaryGet$Response$Apps$Item instance,
) => <String, dynamic>{
  'appId': instance.appId,
  'appSlug': instance.appSlug,
  'appName': instance.appName,
  'channels': instance.channels,
  'releases': instance.releases,
  'publishedReleases': instance.publishedReleases,
  'downloadsTotal': instance.downloadsTotal,
  'updateChecksTotal': instance.updateChecksTotal,
  'lastDownloadAt': ?instance.lastDownloadAt,
  'lastUpdateCheckAt': ?instance.lastUpdateCheckAt,
};

ApiV1DashboardSummaryGet$Response$ActiveAssignments$Item
_$ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1DashboardSummaryGet$Response$ActiveAssignments$Item(
  appId: json['appId'] as String,
  appSlug: json['appSlug'] as String,
  channelId: json['channelId'] as String,
  channelSlug: json['channelSlug'] as String,
  channelKind:
      apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKindFromJson(
        json['channelKind'],
      ),
  releaseId: json['releaseId'] as String,
  releaseVersion: json['releaseVersion'] as String,
  platform:
      apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatformNullableFromJson(
        json['platform'],
      ),
  arch:
      apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArchNullableFromJson(
        json['arch'],
      ),
  rolloutPercent: (json['rolloutPercent'] as num).toInt(),
  assignedAt: json['assignedAt'] as String,
);

Map<String, dynamic>
_$ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemToJson(
  ApiV1DashboardSummaryGet$Response$ActiveAssignments$Item instance,
) => <String, dynamic>{
  'appId': instance.appId,
  'appSlug': instance.appSlug,
  'channelId': instance.channelId,
  'channelSlug': instance.channelSlug,
  'channelKind':
      ?apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKindToJson(
        instance.channelKind,
      ),
  'releaseId': instance.releaseId,
  'releaseVersion': instance.releaseVersion,
  'platform':
      ?apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatformNullableToJson(
        instance.platform,
      ),
  'arch':
      ?apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArchNullableToJson(
        instance.arch,
      ),
  'rolloutPercent': instance.rolloutPercent,
  'assignedAt': instance.assignedAt,
};
