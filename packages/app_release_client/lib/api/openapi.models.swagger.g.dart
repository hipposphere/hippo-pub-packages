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
  bundleId: json['bundle_id'] as String?,
);

Map<String, dynamic> _$ApiV1AppsPost$RequestBodyToJson(
  ApiV1AppsPost$RequestBody instance,
) => <String, dynamic>{
  'slug': instance.slug,
  'name': instance.name,
  'bundle_id': ?instance.bundleId,
};

ApiV1AppsAppIdRepositoryConnectionPut$RequestBody
_$ApiV1AppsAppIdRepositoryConnectionPut$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdRepositoryConnectionPut$RequestBody(
  owner: json['owner'] as String,
  repo: json['repo'] as String,
  installationId: json['installation_id'] as String?,
  defaultBranch: json['default_branch'] as String?,
  workflowFile: json['workflow_file'] as String?,
);

Map<String, dynamic> _$ApiV1AppsAppIdRepositoryConnectionPut$RequestBodyToJson(
  ApiV1AppsAppIdRepositoryConnectionPut$RequestBody instance,
) => <String, dynamic>{
  'owner': instance.owner,
  'repo': instance.repo,
  'installation_id': ?instance.installationId,
  'default_branch': ?instance.defaultBranch,
  'workflow_file': ?instance.workflowFile,
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
  packageType: json['package_type'] as String,
  arch: apiV1AppsAppIdBuildProfilesPost$RequestBodyArchNullableFromJson(
    json['arch'],
  ),
  workflowIdentifier: json['workflow_identifier'] as String,
  workflowRef: json['workflow_ref'] as String?,
  workflowInputs: json['workflow_inputs'] as Map<String, dynamic>?,
  artifactPathGlob: json['artifact_path_glob'] as String?,
  autoDeployTargetId: json['auto_deploy_target_id'] as String?,
);

Map<String, dynamic> _$ApiV1AppsAppIdBuildProfilesPost$RequestBodyToJson(
  ApiV1AppsAppIdBuildProfilesPost$RequestBody instance,
) => <String, dynamic>{
  'name': instance.name,
  'platform': ?apiV1AppsAppIdBuildProfilesPost$RequestBodyPlatformToJson(
    instance.platform,
  ),
  'package_type': instance.packageType,
  'arch': ?apiV1AppsAppIdBuildProfilesPost$RequestBodyArchNullableToJson(
    instance.arch,
  ),
  'workflow_identifier': instance.workflowIdentifier,
  'workflow_ref': ?instance.workflowRef,
  'workflow_inputs': ?instance.workflowInputs,
  'artifact_path_glob': ?instance.artifactPathGlob,
  'auto_deploy_target_id': ?instance.autoDeployTargetId,
};

ApiV1AppsAppIdPipelineRunsPost$RequestBody
_$ApiV1AppsAppIdPipelineRunsPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdPipelineRunsPost$RequestBody(
  branch: json['branch'] as String?,
  profileIds:
      (json['profile_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  triggerMode:
      apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerModeNullableFromJson(
        json['trigger_mode'],
      ),
  releaseId: json['release_id'] as String?,
  commitSha: json['commit_sha'] as String?,
);

Map<String, dynamic> _$ApiV1AppsAppIdPipelineRunsPost$RequestBodyToJson(
  ApiV1AppsAppIdPipelineRunsPost$RequestBody instance,
) => <String, dynamic>{
  'branch': ?instance.branch,
  'profile_ids': instance.profileIds,
  'trigger_mode':
      ?apiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerModeNullableToJson(
        instance.triggerMode,
      ),
  'release_id': ?instance.releaseId,
  'commit_sha': ?instance.commitSha,
};

ApiV1ChannelsPost$RequestBody _$ApiV1ChannelsPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV1ChannelsPost$RequestBody(
  appId: json['app_id'] as String,
  slug: json['slug'] as String,
  displayName: json['display_name'] as String?,
  kind: apiV1ChannelsPost$RequestBodyKindFromJson(json['kind']),
  visibility: apiV1ChannelsPost$RequestBodyVisibilityNullableFromJson(
    json['visibility'],
  ),
  parentChannelId: json['parent_channel_id'] as String?,
  rolloutPercent: (json['rollout_percent'] as num?)?.toInt(),
);

Map<String, dynamic> _$ApiV1ChannelsPost$RequestBodyToJson(
  ApiV1ChannelsPost$RequestBody instance,
) => <String, dynamic>{
  'app_id': instance.appId,
  'slug': instance.slug,
  'display_name': ?instance.displayName,
  'kind': ?apiV1ChannelsPost$RequestBodyKindToJson(instance.kind),
  'visibility': ?apiV1ChannelsPost$RequestBodyVisibilityNullableToJson(
    instance.visibility,
  ),
  'parent_channel_id': ?instance.parentChannelId,
  'rollout_percent': ?instance.rolloutPercent,
};

ApiV1ChannelsChannelIdPatch$RequestBody
_$ApiV1ChannelsChannelIdPatch$RequestBodyFromJson(Map<String, dynamic> json) =>
    ApiV1ChannelsChannelIdPatch$RequestBody(
      displayName: json['display_name'] as String?,
      visibility:
          apiV1ChannelsChannelIdPatch$RequestBodyVisibilityNullableFromJson(
            json['visibility'],
          ),
      rolloutPercent: (json['rollout_percent'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ApiV1ChannelsChannelIdPatch$RequestBodyToJson(
  ApiV1ChannelsChannelIdPatch$RequestBody instance,
) => <String, dynamic>{
  'display_name': ?instance.displayName,
  'visibility':
      ?apiV1ChannelsChannelIdPatch$RequestBodyVisibilityNullableToJson(
        instance.visibility,
      ),
  'rollout_percent': ?instance.rolloutPercent,
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
  toReleaseId: json['to_release_id'] as String?,
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
  'to_release_id': ?instance.toReleaseId,
};

ApiV1ReleasesPost$RequestBody _$ApiV1ReleasesPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesPost$RequestBody(
  appId: json['app_id'] as String,
  version: json['version'] as String,
  buildNumber: json['build_number'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$ApiV1ReleasesPost$RequestBodyToJson(
  ApiV1ReleasesPost$RequestBody instance,
) => <String, dynamic>{
  'app_id': instance.appId,
  'version': instance.version,
  'build_number': ?instance.buildNumber,
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
  fromChannelId: json['from_channel_id'] as String,
  toChannelId: json['to_channel_id'] as String,
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
  'from_channel_id': instance.fromChannelId,
  'to_channel_id': instance.toChannelId,
  'platform':
      ?apiV1ReleasesReleaseIdPromotePost$RequestBodyPlatformNullableToJson(
        instance.platform,
      ),
  'arch': ?apiV1ReleasesReleaseIdPromotePost$RequestBodyArchNullableToJson(
    instance.arch,
  ),
};

ApiV1ArtifactsPost$RequestBody _$ApiV1ArtifactsPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV1ArtifactsPost$RequestBody(
  platform: apiV1ArtifactsPost$RequestBodyPlatformFromJson(json['platform']),
  arch: apiV1ArtifactsPost$RequestBodyArchNullableFromJson(json['arch']),
  packageType: json['package_type'] as String,
  fileName: json['file_name'] as String?,
  edSignature: json['ed_signature'] as String?,
  dsaSignature: json['dsa_signature'] as String?,
  assignChannelSlug: json['assign_channel_slug'] as String?,
  makeLive: json['make_live'] as bool?,
  file: json['file'] as String,
  appSlug: json['app_slug'] as String,
  version: json['version'] as String,
  buildNumber: json['build_number'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$ApiV1ArtifactsPost$RequestBodyToJson(
  ApiV1ArtifactsPost$RequestBody instance,
) => <String, dynamic>{
  'platform': ?apiV1ArtifactsPost$RequestBodyPlatformToJson(instance.platform),
  'arch': ?apiV1ArtifactsPost$RequestBodyArchNullableToJson(instance.arch),
  'package_type': instance.packageType,
  'file_name': ?instance.fileName,
  'ed_signature': ?instance.edSignature,
  'dsa_signature': ?instance.dsaSignature,
  'assign_channel_slug': ?instance.assignChannelSlug,
  'make_live': ?instance.makeLive,
  'file': instance.file,
  'app_slug': instance.appSlug,
  'version': instance.version,
  'build_number': ?instance.buildNumber,
  'notes': ?instance.notes,
};

ApiV1ReleasesReleaseIdArtifactsPost$RequestBody
_$ApiV1ReleasesReleaseIdArtifactsPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesReleaseIdArtifactsPost$RequestBody(
  platform: apiV1ReleasesReleaseIdArtifactsPost$RequestBodyPlatformFromJson(
    json['platform'],
  ),
  arch: apiV1ReleasesReleaseIdArtifactsPost$RequestBodyArchNullableFromJson(
    json['arch'],
  ),
  packageType: json['package_type'] as String,
  fileName: json['file_name'] as String?,
  edSignature: json['ed_signature'] as String?,
  dsaSignature: json['dsa_signature'] as String?,
  assignChannelSlug: json['assign_channel_slug'] as String?,
  makeLive: json['make_live'] as bool?,
  file: json['file'] as String,
);

Map<String, dynamic> _$ApiV1ReleasesReleaseIdArtifactsPost$RequestBodyToJson(
  ApiV1ReleasesReleaseIdArtifactsPost$RequestBody instance,
) => <String, dynamic>{
  'platform': ?apiV1ReleasesReleaseIdArtifactsPost$RequestBodyPlatformToJson(
    instance.platform,
  ),
  'arch': ?apiV1ReleasesReleaseIdArtifactsPost$RequestBodyArchNullableToJson(
    instance.arch,
  ),
  'package_type': instance.packageType,
  'file_name': ?instance.fileName,
  'ed_signature': ?instance.edSignature,
  'dsa_signature': ?instance.dsaSignature,
  'assign_channel_slug': ?instance.assignChannelSlug,
  'make_live': ?instance.makeLive,
  'file': instance.file,
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
  tokenId: json['token_id'] as String,
  keyPrefix: json['key_prefix'] as String,
  createdByUserId: json['created_by_user_id'] as String?,
  createdAt: json['created_at'] as String,
  lastUsedAt: json['last_used_at'] as String?,
  revokedAt: json['revoked_at'] as String?,
  revokedByUserId: json['revoked_by_user_id'] as String?,
);

Map<String, dynamic> _$ApiV1ApiKeysGet$Response$ItemToJson(
  ApiV1ApiKeysGet$Response$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'token_id': instance.tokenId,
  'key_prefix': instance.keyPrefix,
  'created_by_user_id': ?instance.createdByUserId,
  'created_at': instance.createdAt,
  'last_used_at': ?instance.lastUsedAt,
  'revoked_at': ?instance.revokedAt,
  'revoked_by_user_id': ?instance.revokedByUserId,
};

ApiV1ApiKeysPost$Response _$ApiV1ApiKeysPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1ApiKeysPost$Response(
  apiKey: ApiV1ApiKeysPost$Response$ApiKey.fromJson(
    json['api_key'] as Map<String, dynamic>,
  ),
  plainTextKey: json['plain_text_key'] as String,
);

Map<String, dynamic> _$ApiV1ApiKeysPost$ResponseToJson(
  ApiV1ApiKeysPost$Response instance,
) => <String, dynamic>{
  'api_key': instance.apiKey.toJson(),
  'plain_text_key': instance.plainTextKey,
};

ApiV1ApiKeysApiKeyIdRevokePost$Response
_$ApiV1ApiKeysApiKeyIdRevokePost$ResponseFromJson(Map<String, dynamic> json) =>
    ApiV1ApiKeysApiKeyIdRevokePost$Response(
      id: json['id'] as String,
      name: json['name'] as String,
      tokenId: json['token_id'] as String,
      keyPrefix: json['key_prefix'] as String,
      createdByUserId: json['created_by_user_id'] as String?,
      createdAt: json['created_at'] as String,
      lastUsedAt: json['last_used_at'] as String?,
      revokedAt: json['revoked_at'] as String?,
      revokedByUserId: json['revoked_by_user_id'] as String?,
    );

Map<String, dynamic> _$ApiV1ApiKeysApiKeyIdRevokePost$ResponseToJson(
  ApiV1ApiKeysApiKeyIdRevokePost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'token_id': instance.tokenId,
  'key_prefix': instance.keyPrefix,
  'created_by_user_id': ?instance.createdByUserId,
  'created_at': instance.createdAt,
  'last_used_at': ?instance.lastUsedAt,
  'revoked_at': ?instance.revokedAt,
  'revoked_by_user_id': ?instance.revokedByUserId,
};

ApiV1AppsGet$Response$Item _$ApiV1AppsGet$Response$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsGet$Response$Item(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String,
  bundleId: json['bundle_id'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$ApiV1AppsGet$Response$ItemToJson(
  ApiV1AppsGet$Response$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'bundle_id': ?instance.bundleId,
  'created_at': instance.createdAt,
};

ApiV1AppsPost$Response _$ApiV1AppsPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsPost$Response(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String,
  bundleId: json['bundle_id'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$ApiV1AppsPost$ResponseToJson(
  ApiV1AppsPost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'bundle_id': ?instance.bundleId,
  'created_at': instance.createdAt,
};

ApiV1AppsAppIdRepositoryConnectionGet$Response
_$ApiV1AppsAppIdRepositoryConnectionGet$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdRepositoryConnectionGet$Response(
  id: json['id'] as String,
  appId: json['app_id'] as String,
  provider: apiV1AppsAppIdRepositoryConnectionGet$ResponseProviderFromJson(
    json['provider'],
  ),
  owner: json['owner'] as String,
  repo: json['repo'] as String,
  installationId: json['installation_id'] as String?,
  defaultBranch: json['default_branch'] as String,
  workflowFile: json['workflow_file'] as String?,
  createdByUserId: json['created_by_user_id'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$ApiV1AppsAppIdRepositoryConnectionGet$ResponseToJson(
  ApiV1AppsAppIdRepositoryConnectionGet$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'app_id': instance.appId,
  'provider': ?apiV1AppsAppIdRepositoryConnectionGet$ResponseProviderToJson(
    instance.provider,
  ),
  'owner': instance.owner,
  'repo': instance.repo,
  'installation_id': ?instance.installationId,
  'default_branch': instance.defaultBranch,
  'workflow_file': ?instance.workflowFile,
  'created_by_user_id': ?instance.createdByUserId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

ApiV1AppsAppIdRepositoryConnectionPut$Response
_$ApiV1AppsAppIdRepositoryConnectionPut$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdRepositoryConnectionPut$Response(
  id: json['id'] as String,
  appId: json['app_id'] as String,
  provider: apiV1AppsAppIdRepositoryConnectionPut$ResponseProviderFromJson(
    json['provider'],
  ),
  owner: json['owner'] as String,
  repo: json['repo'] as String,
  installationId: json['installation_id'] as String?,
  defaultBranch: json['default_branch'] as String,
  workflowFile: json['workflow_file'] as String?,
  createdByUserId: json['created_by_user_id'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$ApiV1AppsAppIdRepositoryConnectionPut$ResponseToJson(
  ApiV1AppsAppIdRepositoryConnectionPut$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'app_id': instance.appId,
  'provider': ?apiV1AppsAppIdRepositoryConnectionPut$ResponseProviderToJson(
    instance.provider,
  ),
  'owner': instance.owner,
  'repo': instance.repo,
  'installation_id': ?instance.installationId,
  'default_branch': instance.defaultBranch,
  'workflow_file': ?instance.workflowFile,
  'created_by_user_id': ?instance.createdByUserId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

ApiV1AppsAppIdDeploymentTargetsGet$Response$Item
_$ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdDeploymentTargetsGet$Response$Item(
  id: json['id'] as String,
  appId: json['app_id'] as String,
  kind: apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKindFromJson(
    json['kind'],
  ),
  name: json['name'] as String,
  config: json['config'] as Map<String, dynamic>,
  createdByUserId: json['created_by_user_id'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  disabledAt: json['disabled_at'] as String?,
);

Map<String, dynamic> _$ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemToJson(
  ApiV1AppsAppIdDeploymentTargetsGet$Response$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'app_id': instance.appId,
  'kind': ?apiV1AppsAppIdDeploymentTargetsGet$Response$ItemKindToJson(
    instance.kind,
  ),
  'name': instance.name,
  'config': instance.config,
  'created_by_user_id': ?instance.createdByUserId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'disabled_at': ?instance.disabledAt,
};

ApiV1AppsAppIdDeploymentTargetsPost$Response
_$ApiV1AppsAppIdDeploymentTargetsPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdDeploymentTargetsPost$Response(
  id: json['id'] as String,
  appId: json['app_id'] as String,
  kind: apiV1AppsAppIdDeploymentTargetsPost$ResponseKindFromJson(json['kind']),
  name: json['name'] as String,
  config: json['config'] as Map<String, dynamic>,
  createdByUserId: json['created_by_user_id'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  disabledAt: json['disabled_at'] as String?,
);

Map<String, dynamic> _$ApiV1AppsAppIdDeploymentTargetsPost$ResponseToJson(
  ApiV1AppsAppIdDeploymentTargetsPost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'app_id': instance.appId,
  'kind': ?apiV1AppsAppIdDeploymentTargetsPost$ResponseKindToJson(
    instance.kind,
  ),
  'name': instance.name,
  'config': instance.config,
  'created_by_user_id': ?instance.createdByUserId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'disabled_at': ?instance.disabledAt,
};

ApiV1AppsAppIdBuildProfilesGet$Response$Item
_$ApiV1AppsAppIdBuildProfilesGet$Response$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdBuildProfilesGet$Response$Item(
  id: json['id'] as String,
  appId: json['app_id'] as String,
  name: json['name'] as String,
  platform: apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatformFromJson(
    json['platform'],
  ),
  packageType: json['package_type'] as String,
  arch: apiV1AppsAppIdBuildProfilesGet$Response$ItemArchNullableFromJson(
    json['arch'],
  ),
  workflowIdentifier: json['workflow_identifier'] as String,
  workflowRef: json['workflow_ref'] as String?,
  workflowInputs: json['workflow_inputs'] as Map<String, dynamic>,
  artifactPathGlob: json['artifact_path_glob'] as String?,
  autoDeployTargetId: json['auto_deploy_target_id'] as String?,
  createdByUserId: json['created_by_user_id'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  disabledAt: json['disabled_at'] as String?,
);

Map<String, dynamic> _$ApiV1AppsAppIdBuildProfilesGet$Response$ItemToJson(
  ApiV1AppsAppIdBuildProfilesGet$Response$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'app_id': instance.appId,
  'name': instance.name,
  'platform': ?apiV1AppsAppIdBuildProfilesGet$Response$ItemPlatformToJson(
    instance.platform,
  ),
  'package_type': instance.packageType,
  'arch': ?apiV1AppsAppIdBuildProfilesGet$Response$ItemArchNullableToJson(
    instance.arch,
  ),
  'workflow_identifier': instance.workflowIdentifier,
  'workflow_ref': ?instance.workflowRef,
  'workflow_inputs': instance.workflowInputs,
  'artifact_path_glob': ?instance.artifactPathGlob,
  'auto_deploy_target_id': ?instance.autoDeployTargetId,
  'created_by_user_id': ?instance.createdByUserId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'disabled_at': ?instance.disabledAt,
};

ApiV1AppsAppIdBuildProfilesPost$Response
_$ApiV1AppsAppIdBuildProfilesPost$ResponseFromJson(Map<String, dynamic> json) =>
    ApiV1AppsAppIdBuildProfilesPost$Response(
      id: json['id'] as String,
      appId: json['app_id'] as String,
      name: json['name'] as String,
      platform: apiV1AppsAppIdBuildProfilesPost$ResponsePlatformFromJson(
        json['platform'],
      ),
      packageType: json['package_type'] as String,
      arch: apiV1AppsAppIdBuildProfilesPost$ResponseArchNullableFromJson(
        json['arch'],
      ),
      workflowIdentifier: json['workflow_identifier'] as String,
      workflowRef: json['workflow_ref'] as String?,
      workflowInputs: json['workflow_inputs'] as Map<String, dynamic>,
      artifactPathGlob: json['artifact_path_glob'] as String?,
      autoDeployTargetId: json['auto_deploy_target_id'] as String?,
      createdByUserId: json['created_by_user_id'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      disabledAt: json['disabled_at'] as String?,
    );

Map<String, dynamic> _$ApiV1AppsAppIdBuildProfilesPost$ResponseToJson(
  ApiV1AppsAppIdBuildProfilesPost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'app_id': instance.appId,
  'name': instance.name,
  'platform': ?apiV1AppsAppIdBuildProfilesPost$ResponsePlatformToJson(
    instance.platform,
  ),
  'package_type': instance.packageType,
  'arch': ?apiV1AppsAppIdBuildProfilesPost$ResponseArchNullableToJson(
    instance.arch,
  ),
  'workflow_identifier': instance.workflowIdentifier,
  'workflow_ref': ?instance.workflowRef,
  'workflow_inputs': instance.workflowInputs,
  'artifact_path_glob': ?instance.artifactPathGlob,
  'auto_deploy_target_id': ?instance.autoDeployTargetId,
  'created_by_user_id': ?instance.createdByUserId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'disabled_at': ?instance.disabledAt,
};

ApiV1AppsAppIdPipelineRunsGet$Response$Item
_$ApiV1AppsAppIdPipelineRunsGet$Response$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdPipelineRunsGet$Response$Item(
  id: json['id'] as String,
  appId: json['app_id'] as String,
  repositoryConnectionId: json['repository_connection_id'] as String?,
  releaseId: json['release_id'] as String?,
  triggerMode: apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerModeFromJson(
    json['trigger_mode'],
  ),
  branch: json['branch'] as String,
  commitSha: json['commit_sha'] as String?,
  status: apiV1AppsAppIdPipelineRunsGet$Response$ItemStatusFromJson(
    json['status'],
  ),
  requestedByUserId: json['requested_by_user_id'] as String?,
  externalRunId: json['external_run_id'] as String?,
  startedAt: json['started_at'] as String?,
  finishedAt: json['finished_at'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$ApiV1AppsAppIdPipelineRunsGet$Response$ItemToJson(
  ApiV1AppsAppIdPipelineRunsGet$Response$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'app_id': instance.appId,
  'repository_connection_id': ?instance.repositoryConnectionId,
  'release_id': ?instance.releaseId,
  'trigger_mode': ?apiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerModeToJson(
    instance.triggerMode,
  ),
  'branch': instance.branch,
  'commit_sha': ?instance.commitSha,
  'status': ?apiV1AppsAppIdPipelineRunsGet$Response$ItemStatusToJson(
    instance.status,
  ),
  'requested_by_user_id': ?instance.requestedByUserId,
  'external_run_id': ?instance.externalRunId,
  'started_at': ?instance.startedAt,
  'finished_at': ?instance.finishedAt,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

ApiV1AppsAppIdPipelineRunsPost$Response
_$ApiV1AppsAppIdPipelineRunsPost$ResponseFromJson(Map<String, dynamic> json) =>
    ApiV1AppsAppIdPipelineRunsPost$Response(
      id: json['id'] as String,
      appId: json['app_id'] as String,
      repositoryConnectionId: json['repository_connection_id'] as String?,
      releaseId: json['release_id'] as String?,
      triggerMode: apiV1AppsAppIdPipelineRunsPost$ResponseTriggerModeFromJson(
        json['trigger_mode'],
      ),
      branch: json['branch'] as String,
      commitSha: json['commit_sha'] as String?,
      status: apiV1AppsAppIdPipelineRunsPost$ResponseStatusFromJson(
        json['status'],
      ),
      requestedByUserId: json['requested_by_user_id'] as String?,
      externalRunId: json['external_run_id'] as String?,
      startedAt: json['started_at'] as String?,
      finishedAt: json['finished_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
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
  'app_id': instance.appId,
  'repository_connection_id': ?instance.repositoryConnectionId,
  'release_id': ?instance.releaseId,
  'trigger_mode': ?apiV1AppsAppIdPipelineRunsPost$ResponseTriggerModeToJson(
    instance.triggerMode,
  ),
  'branch': instance.branch,
  'commit_sha': ?instance.commitSha,
  'status': ?apiV1AppsAppIdPipelineRunsPost$ResponseStatusToJson(
    instance.status,
  ),
  'requested_by_user_id': ?instance.requestedByUserId,
  'external_run_id': ?instance.externalRunId,
  'started_at': ?instance.startedAt,
  'finished_at': ?instance.finishedAt,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'jobs': instance.jobs.map((e) => e.toJson()).toList(),
};

ApiV1PipelineRunsPipelineRunIdGet$Response
_$ApiV1PipelineRunsPipelineRunIdGet$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1PipelineRunsPipelineRunIdGet$Response(
  id: json['id'] as String,
  appId: json['app_id'] as String,
  repositoryConnectionId: json['repository_connection_id'] as String?,
  releaseId: json['release_id'] as String?,
  triggerMode: apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerModeFromJson(
    json['trigger_mode'],
  ),
  branch: json['branch'] as String,
  commitSha: json['commit_sha'] as String?,
  status: apiV1PipelineRunsPipelineRunIdGet$ResponseStatusFromJson(
    json['status'],
  ),
  requestedByUserId: json['requested_by_user_id'] as String?,
  externalRunId: json['external_run_id'] as String?,
  startedAt: json['started_at'] as String?,
  finishedAt: json['finished_at'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
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
  'app_id': instance.appId,
  'repository_connection_id': ?instance.repositoryConnectionId,
  'release_id': ?instance.releaseId,
  'trigger_mode': ?apiV1PipelineRunsPipelineRunIdGet$ResponseTriggerModeToJson(
    instance.triggerMode,
  ),
  'branch': instance.branch,
  'commit_sha': ?instance.commitSha,
  'status': ?apiV1PipelineRunsPipelineRunIdGet$ResponseStatusToJson(
    instance.status,
  ),
  'requested_by_user_id': ?instance.requestedByUserId,
  'external_run_id': ?instance.externalRunId,
  'started_at': ?instance.startedAt,
  'finished_at': ?instance.finishedAt,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'jobs': instance.jobs.map((e) => e.toJson()).toList(),
};

ApiV1ChannelsGet$Response$Item _$ApiV1ChannelsGet$Response$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1ChannelsGet$Response$Item(
  id: json['id'] as String,
  appId: json['app_id'] as String,
  slug: json['slug'] as String,
  displayName: json['display_name'] as String?,
  kind: apiV1ChannelsGet$Response$ItemKindFromJson(json['kind']),
  visibility: apiV1ChannelsGet$Response$ItemVisibilityFromJson(
    json['visibility'],
  ),
  isSystem: json['is_system'] as bool,
  rolloutPercent: (json['rollout_percent'] as num).toInt(),
  parentChannelId: json['parent_channel_id'] as String?,
  createdByUserId: json['created_by_user_id'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$ApiV1ChannelsGet$Response$ItemToJson(
  ApiV1ChannelsGet$Response$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'app_id': instance.appId,
  'slug': instance.slug,
  'display_name': ?instance.displayName,
  'kind': ?apiV1ChannelsGet$Response$ItemKindToJson(instance.kind),
  'visibility': ?apiV1ChannelsGet$Response$ItemVisibilityToJson(
    instance.visibility,
  ),
  'is_system': instance.isSystem,
  'rollout_percent': instance.rolloutPercent,
  'parent_channel_id': ?instance.parentChannelId,
  'created_by_user_id': ?instance.createdByUserId,
  'created_at': instance.createdAt,
};

ApiV1ChannelsPost$Response _$ApiV1ChannelsPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1ChannelsPost$Response(
  id: json['id'] as String,
  appId: json['app_id'] as String,
  slug: json['slug'] as String,
  displayName: json['display_name'] as String?,
  kind: apiV1ChannelsPost$ResponseKindFromJson(json['kind']),
  visibility: apiV1ChannelsPost$ResponseVisibilityFromJson(json['visibility']),
  isSystem: json['is_system'] as bool,
  rolloutPercent: (json['rollout_percent'] as num).toInt(),
  parentChannelId: json['parent_channel_id'] as String?,
  createdByUserId: json['created_by_user_id'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$ApiV1ChannelsPost$ResponseToJson(
  ApiV1ChannelsPost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'app_id': instance.appId,
  'slug': instance.slug,
  'display_name': ?instance.displayName,
  'kind': ?apiV1ChannelsPost$ResponseKindToJson(instance.kind),
  'visibility': ?apiV1ChannelsPost$ResponseVisibilityToJson(
    instance.visibility,
  ),
  'is_system': instance.isSystem,
  'rollout_percent': instance.rolloutPercent,
  'parent_channel_id': ?instance.parentChannelId,
  'created_by_user_id': ?instance.createdByUserId,
  'created_at': instance.createdAt,
};

ApiV1ChannelsChannelIdPatch$Response
_$ApiV1ChannelsChannelIdPatch$ResponseFromJson(Map<String, dynamic> json) =>
    ApiV1ChannelsChannelIdPatch$Response(
      id: json['id'] as String,
      appId: json['app_id'] as String,
      slug: json['slug'] as String,
      displayName: json['display_name'] as String?,
      kind: apiV1ChannelsChannelIdPatch$ResponseKindFromJson(json['kind']),
      visibility: apiV1ChannelsChannelIdPatch$ResponseVisibilityFromJson(
        json['visibility'],
      ),
      isSystem: json['is_system'] as bool,
      rolloutPercent: (json['rollout_percent'] as num).toInt(),
      parentChannelId: json['parent_channel_id'] as String?,
      createdByUserId: json['created_by_user_id'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$ApiV1ChannelsChannelIdPatch$ResponseToJson(
  ApiV1ChannelsChannelIdPatch$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'app_id': instance.appId,
  'slug': instance.slug,
  'display_name': ?instance.displayName,
  'kind': ?apiV1ChannelsChannelIdPatch$ResponseKindToJson(instance.kind),
  'visibility': ?apiV1ChannelsChannelIdPatch$ResponseVisibilityToJson(
    instance.visibility,
  ),
  'is_system': instance.isSystem,
  'rollout_percent': instance.rolloutPercent,
  'parent_channel_id': ?instance.parentChannelId,
  'created_by_user_id': ?instance.createdByUserId,
  'created_at': instance.createdAt,
};

ApiV1ChannelsChannelIdRollbackPost$Response
_$ApiV1ChannelsChannelIdRollbackPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1ChannelsChannelIdRollbackPost$Response(
  id: json['id'] as String,
  channelId: json['channel_id'] as String,
  releaseId: json['release_id'] as String,
  platform: apiV1ChannelsChannelIdRollbackPost$ResponsePlatformNullableFromJson(
    json['platform'],
  ),
  arch: apiV1ChannelsChannelIdRollbackPost$ResponseArchNullableFromJson(
    json['arch'],
  ),
  rolloutPercent: (json['rollout_percent'] as num).toInt(),
  isLive: json['is_live'] as bool,
  createdByUserId: json['created_by_user_id'] as String?,
  sourceChannelId: json['source_channel_id'] as String?,
  sourceDeploymentId: json['source_deployment_id'] as String?,
  createdAt: json['created_at'] as String,
  retiredAt: json['retired_at'] as String?,
);

Map<String, dynamic> _$ApiV1ChannelsChannelIdRollbackPost$ResponseToJson(
  ApiV1ChannelsChannelIdRollbackPost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'channel_id': instance.channelId,
  'release_id': instance.releaseId,
  'platform':
      ?apiV1ChannelsChannelIdRollbackPost$ResponsePlatformNullableToJson(
        instance.platform,
      ),
  'arch': ?apiV1ChannelsChannelIdRollbackPost$ResponseArchNullableToJson(
    instance.arch,
  ),
  'rollout_percent': instance.rolloutPercent,
  'is_live': instance.isLive,
  'created_by_user_id': ?instance.createdByUserId,
  'source_channel_id': ?instance.sourceChannelId,
  'source_deployment_id': ?instance.sourceDeploymentId,
  'created_at': instance.createdAt,
  'retired_at': ?instance.retiredAt,
};

ApiV1ReleasesGet$Response$Item _$ApiV1ReleasesGet$Response$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesGet$Response$Item(
  id: json['id'] as String,
  appId: json['app_id'] as String,
  version: json['version'] as String,
  buildNumber: json['build_number'] as String?,
  status: apiV1ReleasesGet$Response$ItemStatusFromJson(json['status']),
  notes: json['notes'] as String?,
  publishedAt: json['published_at'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$ApiV1ReleasesGet$Response$ItemToJson(
  ApiV1ReleasesGet$Response$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'app_id': instance.appId,
  'version': instance.version,
  'build_number': ?instance.buildNumber,
  'status': ?apiV1ReleasesGet$Response$ItemStatusToJson(instance.status),
  'notes': ?instance.notes,
  'published_at': ?instance.publishedAt,
  'created_at': instance.createdAt,
};

ApiV1ReleasesPost$Response _$ApiV1ReleasesPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesPost$Response(
  id: json['id'] as String,
  appId: json['app_id'] as String,
  version: json['version'] as String,
  buildNumber: json['build_number'] as String?,
  status: apiV1ReleasesPost$ResponseStatusFromJson(json['status']),
  notes: json['notes'] as String?,
  publishedAt: json['published_at'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$ApiV1ReleasesPost$ResponseToJson(
  ApiV1ReleasesPost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'app_id': instance.appId,
  'version': instance.version,
  'build_number': ?instance.buildNumber,
  'status': ?apiV1ReleasesPost$ResponseStatusToJson(instance.status),
  'notes': ?instance.notes,
  'published_at': ?instance.publishedAt,
  'created_at': instance.createdAt,
};

ApiV1ReleasesReleaseIdGet$Response _$ApiV1ReleasesReleaseIdGet$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesReleaseIdGet$Response(
  id: json['id'] as String,
  appId: json['app_id'] as String,
  version: json['version'] as String,
  buildNumber: json['build_number'] as String?,
  status: apiV1ReleasesReleaseIdGet$ResponseStatusFromJson(json['status']),
  notes: json['notes'] as String?,
  publishedAt: json['published_at'] as String?,
  createdAt: json['created_at'] as String,
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
  'app_id': instance.appId,
  'version': instance.version,
  'build_number': ?instance.buildNumber,
  'status': ?apiV1ReleasesReleaseIdGet$ResponseStatusToJson(instance.status),
  'notes': ?instance.notes,
  'published_at': ?instance.publishedAt,
  'created_at': instance.createdAt,
  'artifacts': instance.artifacts.map((e) => e.toJson()).toList(),
};

ApiV1ReleasesReleaseIdVerifyPost$Response
_$ApiV1ReleasesReleaseIdVerifyPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesReleaseIdVerifyPost$Response(
  id: json['id'] as String,
  appId: json['app_id'] as String,
  version: json['version'] as String,
  buildNumber: json['build_number'] as String?,
  status: apiV1ReleasesReleaseIdVerifyPost$ResponseStatusFromJson(
    json['status'],
  ),
  notes: json['notes'] as String?,
  publishedAt: json['published_at'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$ApiV1ReleasesReleaseIdVerifyPost$ResponseToJson(
  ApiV1ReleasesReleaseIdVerifyPost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'app_id': instance.appId,
  'version': instance.version,
  'build_number': ?instance.buildNumber,
  'status': ?apiV1ReleasesReleaseIdVerifyPost$ResponseStatusToJson(
    instance.status,
  ),
  'notes': ?instance.notes,
  'published_at': ?instance.publishedAt,
  'created_at': instance.createdAt,
};

ApiV1ReleasesReleaseIdPublishPost$Response
_$ApiV1ReleasesReleaseIdPublishPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesReleaseIdPublishPost$Response(
  id: json['id'] as String,
  appId: json['app_id'] as String,
  version: json['version'] as String,
  buildNumber: json['build_number'] as String?,
  status: apiV1ReleasesReleaseIdPublishPost$ResponseStatusFromJson(
    json['status'],
  ),
  notes: json['notes'] as String?,
  publishedAt: json['published_at'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$ApiV1ReleasesReleaseIdPublishPost$ResponseToJson(
  ApiV1ReleasesReleaseIdPublishPost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'app_id': instance.appId,
  'version': instance.version,
  'build_number': ?instance.buildNumber,
  'status': ?apiV1ReleasesReleaseIdPublishPost$ResponseStatusToJson(
    instance.status,
  ),
  'notes': ?instance.notes,
  'published_at': ?instance.publishedAt,
  'created_at': instance.createdAt,
};

ApiV1ReleasesReleaseIdPromotePost$Response
_$ApiV1ReleasesReleaseIdPromotePost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesReleaseIdPromotePost$Response(
  id: json['id'] as String,
  channelId: json['channel_id'] as String,
  releaseId: json['release_id'] as String,
  platform: apiV1ReleasesReleaseIdPromotePost$ResponsePlatformNullableFromJson(
    json['platform'],
  ),
  arch: apiV1ReleasesReleaseIdPromotePost$ResponseArchNullableFromJson(
    json['arch'],
  ),
  rolloutPercent: (json['rollout_percent'] as num).toInt(),
  isLive: json['is_live'] as bool,
  createdByUserId: json['created_by_user_id'] as String?,
  sourceChannelId: json['source_channel_id'] as String?,
  sourceDeploymentId: json['source_deployment_id'] as String?,
  createdAt: json['created_at'] as String,
  retiredAt: json['retired_at'] as String?,
);

Map<String, dynamic> _$ApiV1ReleasesReleaseIdPromotePost$ResponseToJson(
  ApiV1ReleasesReleaseIdPromotePost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'channel_id': instance.channelId,
  'release_id': instance.releaseId,
  'platform': ?apiV1ReleasesReleaseIdPromotePost$ResponsePlatformNullableToJson(
    instance.platform,
  ),
  'arch': ?apiV1ReleasesReleaseIdPromotePost$ResponseArchNullableToJson(
    instance.arch,
  ),
  'rollout_percent': instance.rolloutPercent,
  'is_live': instance.isLive,
  'created_by_user_id': ?instance.createdByUserId,
  'source_channel_id': ?instance.sourceChannelId,
  'source_deployment_id': ?instance.sourceDeploymentId,
  'created_at': instance.createdAt,
  'retired_at': ?instance.retiredAt,
};

ApiV1ArtifactsPost$Response _$ApiV1ArtifactsPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1ArtifactsPost$Response(
  releaseId: json['release_id'] as String,
  releaseCreated: json['release_created'] as bool,
  artifact: ApiV1ArtifactsPost$Response$Artifact.fromJson(
    json['artifact'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ApiV1ArtifactsPost$ResponseToJson(
  ApiV1ArtifactsPost$Response instance,
) => <String, dynamic>{
  'release_id': instance.releaseId,
  'release_created': instance.releaseCreated,
  'artifact': instance.artifact.toJson(),
};

ApiV1ReleasesReleaseIdArtifactsPost$Response
_$ApiV1ReleasesReleaseIdArtifactsPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesReleaseIdArtifactsPost$Response(
  id: json['id'] as String,
  releaseId: json['release_id'] as String,
  platform: apiV1ReleasesReleaseIdArtifactsPost$ResponsePlatformFromJson(
    json['platform'],
  ),
  arch: apiV1ReleasesReleaseIdArtifactsPost$ResponseArchFromJson(json['arch']),
  packageType: json['package_type'] as String,
  fileName: json['file_name'] as String,
  s3Key: json['s3_key'] as String,
  sha256: json['sha256'] as String?,
  signature: json['signature'] as String?,
  sizeBytes: (json['size_bytes'] as num).toInt(),
  verified: json['verified'] as bool,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$ApiV1ReleasesReleaseIdArtifactsPost$ResponseToJson(
  ApiV1ReleasesReleaseIdArtifactsPost$Response instance,
) => <String, dynamic>{
  'id': instance.id,
  'release_id': instance.releaseId,
  'platform': ?apiV1ReleasesReleaseIdArtifactsPost$ResponsePlatformToJson(
    instance.platform,
  ),
  'arch': ?apiV1ReleasesReleaseIdArtifactsPost$ResponseArchToJson(
    instance.arch,
  ),
  'package_type': instance.packageType,
  'file_name': instance.fileName,
  's3_key': instance.s3Key,
  'sha256': ?instance.sha256,
  'signature': ?instance.signature,
  'size_bytes': instance.sizeBytes,
  'verified': instance.verified,
  'created_at': instance.createdAt,
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
  generatedAt: json['generated_at'] as String,
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
  activeAssignments: (json['active_assignments'] as List<dynamic>)
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
  'generated_at': instance.generatedAt,
  'totals': instance.totals.toJson(),
  'apps': instance.apps.map((e) => e.toJson()).toList(),
  'active_assignments': instance.activeAssignments
      .map((e) => e.toJson())
      .toList(),
};

ApiPublicV1ChannelsGet$Response$Item
_$ApiPublicV1ChannelsGet$Response$ItemFromJson(Map<String, dynamic> json) =>
    ApiPublicV1ChannelsGet$Response$Item(
      id: json['id'] as String,
      appId: json['app_id'] as String,
      slug: json['slug'] as String,
      displayName: json['display_name'] as String?,
      kind: apiPublicV1ChannelsGet$Response$ItemKindFromJson(json['kind']),
      isSystem: json['is_system'] as bool,
      rolloutPercent: (json['rollout_percent'] as num).toInt(),
      parentChannelId: json['parent_channel_id'] as String?,
      createdByUserId: json['created_by_user_id'] as String?,
      createdAt: json['created_at'] as String,
      visibility: apiPublicV1ChannelsGet$Response$ItemVisibilityFromJson(
        json['visibility'],
      ),
    );

Map<String, dynamic> _$ApiPublicV1ChannelsGet$Response$ItemToJson(
  ApiPublicV1ChannelsGet$Response$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'app_id': instance.appId,
  'slug': instance.slug,
  'display_name': ?instance.displayName,
  'kind': ?apiPublicV1ChannelsGet$Response$ItemKindToJson(instance.kind),
  'is_system': instance.isSystem,
  'rollout_percent': instance.rolloutPercent,
  'parent_channel_id': ?instance.parentChannelId,
  'created_by_user_id': ?instance.createdByUserId,
  'created_at': instance.createdAt,
  'visibility': ?apiPublicV1ChannelsGet$Response$ItemVisibilityToJson(
    instance.visibility,
  ),
};

ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$Item
_$ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$Item(
  channelId: json['channel_id'] as String,
  platform:
      apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatformNullableFromJson(
        json['platform'],
      ),
  arch:
      apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArchNullableFromJson(
        json['arch'],
      ),
  rolloutPercent: (json['rollout_percent'] as num?)?.toInt(),
);

Map<String, dynamic>
_$ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemToJson(
  ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$Item instance,
) => <String, dynamic>{
  'channel_id': instance.channelId,
  'platform':
      ?apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatformNullableToJson(
        instance.platform,
      ),
  'arch':
      ?apiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArchNullableToJson(
        instance.arch,
      ),
  'rollout_percent': ?instance.rolloutPercent,
};

ApiV1ApiKeysPost$Response$ApiKey _$ApiV1ApiKeysPost$Response$ApiKeyFromJson(
  Map<String, dynamic> json,
) => ApiV1ApiKeysPost$Response$ApiKey(
  id: json['id'] as String,
  name: json['name'] as String,
  tokenId: json['token_id'] as String,
  keyPrefix: json['key_prefix'] as String,
  createdByUserId: json['created_by_user_id'] as String?,
  createdAt: json['created_at'] as String,
  lastUsedAt: json['last_used_at'] as String?,
  revokedAt: json['revoked_at'] as String?,
  revokedByUserId: json['revoked_by_user_id'] as String?,
);

Map<String, dynamic> _$ApiV1ApiKeysPost$Response$ApiKeyToJson(
  ApiV1ApiKeysPost$Response$ApiKey instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'token_id': instance.tokenId,
  'key_prefix': instance.keyPrefix,
  'created_by_user_id': ?instance.createdByUserId,
  'created_at': instance.createdAt,
  'last_used_at': ?instance.lastUsedAt,
  'revoked_at': ?instance.revokedAt,
  'revoked_by_user_id': ?instance.revokedByUserId,
};

ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$Item
_$ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$Item(
  id: json['id'] as String,
  pipelineRunId: json['pipeline_run_id'] as String,
  buildProfileId: json['build_profile_id'] as String?,
  platform: apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatformFromJson(
    json['platform'],
  ),
  packageType: json['package_type'] as String,
  arch: apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArchNullableFromJson(
    json['arch'],
  ),
  status: apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatusFromJson(
    json['status'],
  ),
  externalJobId: json['external_job_id'] as String?,
  artifactId: json['artifact_id'] as String?,
  deploymentTargetId: json['deployment_target_id'] as String?,
  deploymentStatus:
      apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatusNullableFromJson(
        json['deployment_status'],
      ),
  logsUrl: json['logs_url'] as String?,
  errorMessage: json['error_message'] as String?,
  startedAt: json['started_at'] as String?,
  finishedAt: json['finished_at'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemToJson(
  ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'pipeline_run_id': instance.pipelineRunId,
  'build_profile_id': ?instance.buildProfileId,
  'platform': ?apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatformToJson(
    instance.platform,
  ),
  'package_type': instance.packageType,
  'arch': ?apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArchNullableToJson(
    instance.arch,
  ),
  'status': ?apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatusToJson(
    instance.status,
  ),
  'external_job_id': ?instance.externalJobId,
  'artifact_id': ?instance.artifactId,
  'deployment_target_id': ?instance.deploymentTargetId,
  'deployment_status':
      ?apiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatusNullableToJson(
        instance.deploymentStatus,
      ),
  'logs_url': ?instance.logsUrl,
  'error_message': ?instance.errorMessage,
  'started_at': ?instance.startedAt,
  'finished_at': ?instance.finishedAt,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$Item
_$ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$Item(
  id: json['id'] as String,
  pipelineRunId: json['pipeline_run_id'] as String,
  buildProfileId: json['build_profile_id'] as String?,
  platform:
      apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatformFromJson(
        json['platform'],
      ),
  packageType: json['package_type'] as String,
  arch:
      apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArchNullableFromJson(
        json['arch'],
      ),
  status: apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatusFromJson(
    json['status'],
  ),
  externalJobId: json['external_job_id'] as String?,
  artifactId: json['artifact_id'] as String?,
  deploymentTargetId: json['deployment_target_id'] as String?,
  deploymentStatus:
      apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatusNullableFromJson(
        json['deployment_status'],
      ),
  logsUrl: json['logs_url'] as String?,
  errorMessage: json['error_message'] as String?,
  startedAt: json['started_at'] as String?,
  finishedAt: json['finished_at'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic>
_$ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemToJson(
  ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'pipeline_run_id': instance.pipelineRunId,
  'build_profile_id': ?instance.buildProfileId,
  'platform':
      ?apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatformToJson(
        instance.platform,
      ),
  'package_type': instance.packageType,
  'arch':
      ?apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArchNullableToJson(
        instance.arch,
      ),
  'status': ?apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatusToJson(
    instance.status,
  ),
  'external_job_id': ?instance.externalJobId,
  'artifact_id': ?instance.artifactId,
  'deployment_target_id': ?instance.deploymentTargetId,
  'deployment_status':
      ?apiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatusNullableToJson(
        instance.deploymentStatus,
      ),
  'logs_url': ?instance.logsUrl,
  'error_message': ?instance.errorMessage,
  'started_at': ?instance.startedAt,
  'finished_at': ?instance.finishedAt,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

ApiV1ReleasesReleaseIdGet$Response$Artifacts$Item
_$ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1ReleasesReleaseIdGet$Response$Artifacts$Item(
  id: json['id'] as String,
  releaseId: json['release_id'] as String,
  platform: apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatformFromJson(
    json['platform'],
  ),
  arch: apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArchFromJson(
    json['arch'],
  ),
  packageType: json['package_type'] as String,
  fileName: json['file_name'] as String,
  s3Key: json['s3_key'] as String,
  sha256: json['sha256'] as String?,
  signature: json['signature'] as String?,
  sizeBytes: (json['size_bytes'] as num).toInt(),
  verified: json['verified'] as bool,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemToJson(
  ApiV1ReleasesReleaseIdGet$Response$Artifacts$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'release_id': instance.releaseId,
  'platform': ?apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatformToJson(
    instance.platform,
  ),
  'arch': ?apiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArchToJson(
    instance.arch,
  ),
  'package_type': instance.packageType,
  'file_name': instance.fileName,
  's3_key': instance.s3Key,
  'sha256': ?instance.sha256,
  'signature': ?instance.signature,
  'size_bytes': instance.sizeBytes,
  'verified': instance.verified,
  'created_at': instance.createdAt,
};

ApiV1ArtifactsPost$Response$Artifact
_$ApiV1ArtifactsPost$Response$ArtifactFromJson(Map<String, dynamic> json) =>
    ApiV1ArtifactsPost$Response$Artifact(
      id: json['id'] as String,
      releaseId: json['release_id'] as String,
      platform: apiV1ArtifactsPost$Response$ArtifactPlatformFromJson(
        json['platform'],
      ),
      arch: apiV1ArtifactsPost$Response$ArtifactArchFromJson(json['arch']),
      packageType: json['package_type'] as String,
      fileName: json['file_name'] as String,
      s3Key: json['s3_key'] as String,
      sha256: json['sha256'] as String?,
      signature: json['signature'] as String?,
      sizeBytes: (json['size_bytes'] as num).toInt(),
      verified: json['verified'] as bool,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$ApiV1ArtifactsPost$Response$ArtifactToJson(
  ApiV1ArtifactsPost$Response$Artifact instance,
) => <String, dynamic>{
  'id': instance.id,
  'release_id': instance.releaseId,
  'platform': ?apiV1ArtifactsPost$Response$ArtifactPlatformToJson(
    instance.platform,
  ),
  'arch': ?apiV1ArtifactsPost$Response$ArtifactArchToJson(instance.arch),
  'package_type': instance.packageType,
  'file_name': instance.fileName,
  's3_key': instance.s3Key,
  'sha256': ?instance.sha256,
  'signature': ?instance.signature,
  'size_bytes': instance.sizeBytes,
  'verified': instance.verified,
  'created_at': instance.createdAt,
};

ApiV1MetricsDownloadsGet$Response$Series$Item
_$ApiV1MetricsDownloadsGet$Response$Series$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1MetricsDownloadsGet$Response$Series$Item(
  bucketStart: json['bucket_start'] as String,
  count: (json['count'] as num).toInt(),
  channel: json['channel'] as String?,
  platform: json['platform'] as String?,
  arch: json['arch'] as String?,
  version: json['version'] as String?,
);

Map<String, dynamic> _$ApiV1MetricsDownloadsGet$Response$Series$ItemToJson(
  ApiV1MetricsDownloadsGet$Response$Series$Item instance,
) => <String, dynamic>{
  'bucket_start': instance.bucketStart,
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
  bucketStart: json['bucket_start'] as String,
  count: (json['count'] as num).toInt(),
  channel: json['channel'] as String?,
  platform: json['platform'] as String?,
  arch: json['arch'] as String?,
  version: json['version'] as String?,
);

Map<String, dynamic> _$ApiV1MetricsUpdateChecksGet$Response$Series$ItemToJson(
  ApiV1MetricsUpdateChecksGet$Response$Series$Item instance,
) => <String, dynamic>{
  'bucket_start': instance.bucketStart,
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
      publishedReleases: (json['published_releases'] as num).toInt(),
      artifacts: (json['artifacts'] as num).toInt(),
      channelDeployments: (json['channel_deployments'] as num).toInt(),
      downloadsTotal: (json['downloads_total'] as num).toInt(),
      updateChecksTotal: (json['update_checks_total'] as num).toInt(),
      downloadsLast7Days: (json['downloads_last_7_days'] as num).toInt(),
      updateChecksLast7Days: (json['update_checks_last_7_days'] as num).toInt(),
    );

Map<String, dynamic> _$ApiV1DashboardSummaryGet$Response$TotalsToJson(
  ApiV1DashboardSummaryGet$Response$Totals instance,
) => <String, dynamic>{
  'apps': instance.apps,
  'channels': instance.channels,
  'releases': instance.releases,
  'published_releases': instance.publishedReleases,
  'artifacts': instance.artifacts,
  'channel_deployments': instance.channelDeployments,
  'downloads_total': instance.downloadsTotal,
  'update_checks_total': instance.updateChecksTotal,
  'downloads_last_7_days': instance.downloadsLast7Days,
  'update_checks_last_7_days': instance.updateChecksLast7Days,
};

ApiV1DashboardSummaryGet$Response$Apps$Item
_$ApiV1DashboardSummaryGet$Response$Apps$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1DashboardSummaryGet$Response$Apps$Item(
  appId: json['app_id'] as String,
  appSlug: json['app_slug'] as String,
  appName: json['app_name'] as String,
  channels: (json['channels'] as num).toInt(),
  releases: (json['releases'] as num).toInt(),
  publishedReleases: (json['published_releases'] as num).toInt(),
  downloadsTotal: (json['downloads_total'] as num).toInt(),
  updateChecksTotal: (json['update_checks_total'] as num).toInt(),
  lastDownloadAt: json['last_download_at'] as String?,
  lastUpdateCheckAt: json['last_update_check_at'] as String?,
);

Map<String, dynamic> _$ApiV1DashboardSummaryGet$Response$Apps$ItemToJson(
  ApiV1DashboardSummaryGet$Response$Apps$Item instance,
) => <String, dynamic>{
  'app_id': instance.appId,
  'app_slug': instance.appSlug,
  'app_name': instance.appName,
  'channels': instance.channels,
  'releases': instance.releases,
  'published_releases': instance.publishedReleases,
  'downloads_total': instance.downloadsTotal,
  'update_checks_total': instance.updateChecksTotal,
  'last_download_at': ?instance.lastDownloadAt,
  'last_update_check_at': ?instance.lastUpdateCheckAt,
};

ApiV1DashboardSummaryGet$Response$ActiveAssignments$Item
_$ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemFromJson(
  Map<String, dynamic> json,
) => ApiV1DashboardSummaryGet$Response$ActiveAssignments$Item(
  appId: json['app_id'] as String,
  appSlug: json['app_slug'] as String,
  channelId: json['channel_id'] as String,
  channelSlug: json['channel_slug'] as String,
  channelKind:
      apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKindFromJson(
        json['channel_kind'],
      ),
  releaseId: json['release_id'] as String,
  releaseVersion: json['release_version'] as String,
  platform:
      apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatformNullableFromJson(
        json['platform'],
      ),
  arch:
      apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArchNullableFromJson(
        json['arch'],
      ),
  rolloutPercent: (json['rollout_percent'] as num).toInt(),
  assignedAt: json['assigned_at'] as String,
);

Map<String, dynamic>
_$ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemToJson(
  ApiV1DashboardSummaryGet$Response$ActiveAssignments$Item instance,
) => <String, dynamic>{
  'app_id': instance.appId,
  'app_slug': instance.appSlug,
  'channel_id': instance.channelId,
  'channel_slug': instance.channelSlug,
  'channel_kind':
      ?apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKindToJson(
        instance.channelKind,
      ),
  'release_id': instance.releaseId,
  'release_version': instance.releaseVersion,
  'platform':
      ?apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatformNullableToJson(
        instance.platform,
      ),
  'arch':
      ?apiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArchNullableToJson(
        instance.arch,
      ),
  'rollout_percent': instance.rolloutPercent,
  'assigned_at': instance.assignedAt,
};
