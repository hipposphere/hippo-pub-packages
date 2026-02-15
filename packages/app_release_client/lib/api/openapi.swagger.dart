// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element_parameter

import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart' as json;
import 'package:collection/collection.dart';
import 'dart:convert';

import 'openapi.models.swagger.dart';
import 'package:chopper/chopper.dart';

import 'client_mapping.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show MultipartFile;
import 'package:chopper/chopper.dart' as chopper;
import 'openapi.enums.swagger.dart' as enums;
import 'openapi.metadata.swagger.dart';
export 'openapi.enums.swagger.dart';
export 'openapi.models.swagger.dart';

part 'openapi.swagger.chopper.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class Openapi extends ChopperService {
  static Openapi create({
    ChopperClient? client,
    http.Client? httpClient,
    Authenticator? authenticator,
    ErrorConverter? errorConverter,
    Converter? converter,
    Uri? baseUrl,
    List<Interceptor>? interceptors,
  }) {
    if (client != null) {
      return _$Openapi(client);
    }

    final newClient = ChopperClient(
      services: [_$Openapi()],
      converter: converter ?? $JsonSerializableConverter(),
      interceptors: interceptors ?? [],
      client: httpClient,
      authenticator: authenticator,
      errorConverter: errorConverter,
      baseUrl: baseUrl ?? Uri.parse('http://'),
    );
    return _$Openapi(newClient);
  }

  ///Health check
  Future<chopper.Response<ApiHealthzGet$Response>> apiHealthzGet() {
    generatedMapping.putIfAbsent(
      ApiHealthzGet$Response,
      () => ApiHealthzGet$Response.fromJsonFactory,
    );

    return _apiHealthzGet();
  }

  ///Health check
  @GET(path: '/api/healthz')
  Future<chopper.Response<ApiHealthzGet$Response>> _apiHealthzGet({
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Health check',
      operationId: 'getHealth',
      consumes: [],
      produces: [],
      security: [],
      tags: ["System"],
      deprecated: false,
    ),
  });

  ///List API keys
  Future<chopper.Response<ApiV1ApiKeysGet$Response>> apiV1ApiKeysGet() {
    generatedMapping.putIfAbsent(
      ApiV1ApiKeysGet$Response$Item,
      () => ApiV1ApiKeysGet$Response$Item.fromJsonFactory,
    );

    return _apiV1ApiKeysGet();
  }

  ///List API keys
  @GET(path: '/api/v1/api-keys')
  Future<chopper.Response<ApiV1ApiKeysGet$Response>> _apiV1ApiKeysGet({
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'List API keys',
      operationId: 'listApiKeys',
      consumes: [],
      produces: [],
      security: [],
      tags: ["API Keys"],
      deprecated: false,
    ),
  });

  ///Create API key
  Future<chopper.Response<ApiV1ApiKeysPost$Response>> apiV1ApiKeysPost({
    required ApiV1ApiKeysPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ApiV1ApiKeysPost$Response,
      () => ApiV1ApiKeysPost$Response.fromJsonFactory,
    );

    return _apiV1ApiKeysPost(body: body);
  }

  ///Create API key
  @POST(path: '/api/v1/api-keys', optionalBody: true)
  Future<chopper.Response<ApiV1ApiKeysPost$Response>> _apiV1ApiKeysPost({
    @Body() required ApiV1ApiKeysPost$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Create API key',
      operationId: 'createApiKey',
      consumes: [],
      produces: [],
      security: [],
      tags: ["API Keys"],
      deprecated: false,
    ),
  });

  ///Revoke API key
  ///@param apiKeyId
  Future<chopper.Response<ApiV1ApiKeysApiKeyIdRevokePost$Response>>
  apiV1ApiKeysApiKeyIdRevokePost({required String? apiKeyId}) {
    generatedMapping.putIfAbsent(
      ApiV1ApiKeysApiKeyIdRevokePost$Response,
      () => ApiV1ApiKeysApiKeyIdRevokePost$Response.fromJsonFactory,
    );

    return _apiV1ApiKeysApiKeyIdRevokePost(apiKeyId: apiKeyId);
  }

  ///Revoke API key
  ///@param apiKeyId
  @POST(path: '/api/v1/api-keys/{apiKeyId}/revoke', optionalBody: true)
  Future<chopper.Response<ApiV1ApiKeysApiKeyIdRevokePost$Response>>
  _apiV1ApiKeysApiKeyIdRevokePost({
    @Path('apiKeyId') required String? apiKeyId,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Revoke API key',
      operationId: 'revokeApiKey',
      consumes: [],
      produces: [],
      security: [],
      tags: ["API Keys"],
      deprecated: false,
    ),
  });

  ///List apps
  Future<chopper.Response<ApiV1AppsGet$Response>> apiV1AppsGet() {
    generatedMapping.putIfAbsent(
      ApiV1AppsGet$Response$Item,
      () => ApiV1AppsGet$Response$Item.fromJsonFactory,
    );

    return _apiV1AppsGet();
  }

  ///List apps
  @GET(path: '/api/v1/apps')
  Future<chopper.Response<ApiV1AppsGet$Response>> _apiV1AppsGet({
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'List apps',
      operationId: 'listApps',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Apps"],
      deprecated: false,
    ),
  });

  ///Create app
  Future<chopper.Response<ApiV1AppsPost$Response>> apiV1AppsPost({
    required ApiV1AppsPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ApiV1AppsPost$Response,
      () => ApiV1AppsPost$Response.fromJsonFactory,
    );

    return _apiV1AppsPost(body: body);
  }

  ///Create app
  @POST(path: '/api/v1/apps', optionalBody: true)
  Future<chopper.Response<ApiV1AppsPost$Response>> _apiV1AppsPost({
    @Body() required ApiV1AppsPost$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Create app',
      operationId: 'createApp',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Apps"],
      deprecated: false,
    ),
  });

  ///Get GitHub repository connection for an app
  ///@param appId
  Future<chopper.Response<ApiV1AppsAppIdRepositoryConnectionGet$Response>>
  apiV1AppsAppIdRepositoryConnectionGet({required String? appId}) {
    generatedMapping.putIfAbsent(
      ApiV1AppsAppIdRepositoryConnectionGet$Response,
      () => ApiV1AppsAppIdRepositoryConnectionGet$Response.fromJsonFactory,
    );

    return _apiV1AppsAppIdRepositoryConnectionGet(appId: appId);
  }

  ///Get GitHub repository connection for an app
  ///@param appId
  @GET(path: '/api/v1/apps/{appId}/repository-connection')
  Future<chopper.Response<ApiV1AppsAppIdRepositoryConnectionGet$Response>>
  _apiV1AppsAppIdRepositoryConnectionGet({
    @Path('appId') required String? appId,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Get GitHub repository connection for an app',
      operationId: 'getRepositoryConnection',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Repositories"],
      deprecated: false,
    ),
  });

  ///Create or update app GitHub repository connection
  ///@param appId
  Future<chopper.Response<ApiV1AppsAppIdRepositoryConnectionPut$Response>>
  apiV1AppsAppIdRepositoryConnectionPut({
    required String? appId,
    required ApiV1AppsAppIdRepositoryConnectionPut$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ApiV1AppsAppIdRepositoryConnectionPut$Response,
      () => ApiV1AppsAppIdRepositoryConnectionPut$Response.fromJsonFactory,
    );

    return _apiV1AppsAppIdRepositoryConnectionPut(appId: appId, body: body);
  }

  ///Create or update app GitHub repository connection
  ///@param appId
  @PUT(path: '/api/v1/apps/{appId}/repository-connection', optionalBody: true)
  Future<chopper.Response<ApiV1AppsAppIdRepositoryConnectionPut$Response>>
  _apiV1AppsAppIdRepositoryConnectionPut({
    @Path('appId') required String? appId,
    @Body() required ApiV1AppsAppIdRepositoryConnectionPut$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Create or update app GitHub repository connection',
      operationId: 'upsertRepositoryConnection',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Repositories"],
      deprecated: false,
    ),
  });

  ///List app deployment targets
  ///@param appId
  Future<chopper.Response<ApiV1AppsAppIdDeploymentTargetsGet$Response>>
  apiV1AppsAppIdDeploymentTargetsGet({required String? appId}) {
    generatedMapping.putIfAbsent(
      ApiV1AppsAppIdDeploymentTargetsGet$Response$Item,
      () => ApiV1AppsAppIdDeploymentTargetsGet$Response$Item.fromJsonFactory,
    );

    return _apiV1AppsAppIdDeploymentTargetsGet(appId: appId);
  }

  ///List app deployment targets
  ///@param appId
  @GET(path: '/api/v1/apps/{appId}/deployment-targets')
  Future<chopper.Response<ApiV1AppsAppIdDeploymentTargetsGet$Response>>
  _apiV1AppsAppIdDeploymentTargetsGet({
    @Path('appId') required String? appId,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'List app deployment targets',
      operationId: 'listDeploymentTargets',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Deployment Targets"],
      deprecated: false,
    ),
  });

  ///Create app deployment target
  ///@param appId
  Future<chopper.Response<ApiV1AppsAppIdDeploymentTargetsPost$Response>>
  apiV1AppsAppIdDeploymentTargetsPost({
    required String? appId,
    required ApiV1AppsAppIdDeploymentTargetsPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ApiV1AppsAppIdDeploymentTargetsPost$Response,
      () => ApiV1AppsAppIdDeploymentTargetsPost$Response.fromJsonFactory,
    );

    return _apiV1AppsAppIdDeploymentTargetsPost(appId: appId, body: body);
  }

  ///Create app deployment target
  ///@param appId
  @POST(path: '/api/v1/apps/{appId}/deployment-targets', optionalBody: true)
  Future<chopper.Response<ApiV1AppsAppIdDeploymentTargetsPost$Response>>
  _apiV1AppsAppIdDeploymentTargetsPost({
    @Path('appId') required String? appId,
    @Body() required ApiV1AppsAppIdDeploymentTargetsPost$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Create app deployment target',
      operationId: 'createDeploymentTarget',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Deployment Targets"],
      deprecated: false,
    ),
  });

  ///List app build profiles
  ///@param appId
  Future<chopper.Response<ApiV1AppsAppIdBuildProfilesGet$Response>>
  apiV1AppsAppIdBuildProfilesGet({required String? appId}) {
    generatedMapping.putIfAbsent(
      ApiV1AppsAppIdBuildProfilesGet$Response$Item,
      () => ApiV1AppsAppIdBuildProfilesGet$Response$Item.fromJsonFactory,
    );

    return _apiV1AppsAppIdBuildProfilesGet(appId: appId);
  }

  ///List app build profiles
  ///@param appId
  @GET(path: '/api/v1/apps/{appId}/build-profiles')
  Future<chopper.Response<ApiV1AppsAppIdBuildProfilesGet$Response>>
  _apiV1AppsAppIdBuildProfilesGet({
    @Path('appId') required String? appId,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'List app build profiles',
      operationId: 'listBuildProfiles',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Build Profiles"],
      deprecated: false,
    ),
  });

  ///Create app build profile
  ///@param appId
  Future<chopper.Response<ApiV1AppsAppIdBuildProfilesPost$Response>>
  apiV1AppsAppIdBuildProfilesPost({
    required String? appId,
    required ApiV1AppsAppIdBuildProfilesPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ApiV1AppsAppIdBuildProfilesPost$Response,
      () => ApiV1AppsAppIdBuildProfilesPost$Response.fromJsonFactory,
    );

    return _apiV1AppsAppIdBuildProfilesPost(appId: appId, body: body);
  }

  ///Create app build profile
  ///@param appId
  @POST(path: '/api/v1/apps/{appId}/build-profiles', optionalBody: true)
  Future<chopper.Response<ApiV1AppsAppIdBuildProfilesPost$Response>>
  _apiV1AppsAppIdBuildProfilesPost({
    @Path('appId') required String? appId,
    @Body() required ApiV1AppsAppIdBuildProfilesPost$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Create app build profile',
      operationId: 'createBuildProfile',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Build Profiles"],
      deprecated: false,
    ),
  });

  ///List pipeline runs for an app
  ///@param appId
  Future<chopper.Response<ApiV1AppsAppIdPipelineRunsGet$Response>>
  apiV1AppsAppIdPipelineRunsGet({required String? appId}) {
    generatedMapping.putIfAbsent(
      ApiV1AppsAppIdPipelineRunsGet$Response$Item,
      () => ApiV1AppsAppIdPipelineRunsGet$Response$Item.fromJsonFactory,
    );

    return _apiV1AppsAppIdPipelineRunsGet(appId: appId);
  }

  ///List pipeline runs for an app
  ///@param appId
  @GET(path: '/api/v1/apps/{appId}/pipeline-runs')
  Future<chopper.Response<ApiV1AppsAppIdPipelineRunsGet$Response>>
  _apiV1AppsAppIdPipelineRunsGet({
    @Path('appId') required String? appId,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'List pipeline runs for an app',
      operationId: 'listPipelineRuns',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Pipeline Runs"],
      deprecated: false,
    ),
  });

  ///Create and queue a pipeline run
  ///@param appId
  Future<chopper.Response<ApiV1AppsAppIdPipelineRunsPost$Response>>
  apiV1AppsAppIdPipelineRunsPost({
    required String? appId,
    required ApiV1AppsAppIdPipelineRunsPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ApiV1AppsAppIdPipelineRunsPost$Response,
      () => ApiV1AppsAppIdPipelineRunsPost$Response.fromJsonFactory,
    );

    return _apiV1AppsAppIdPipelineRunsPost(appId: appId, body: body);
  }

  ///Create and queue a pipeline run
  ///@param appId
  @POST(path: '/api/v1/apps/{appId}/pipeline-runs', optionalBody: true)
  Future<chopper.Response<ApiV1AppsAppIdPipelineRunsPost$Response>>
  _apiV1AppsAppIdPipelineRunsPost({
    @Path('appId') required String? appId,
    @Body() required ApiV1AppsAppIdPipelineRunsPost$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Create and queue a pipeline run',
      operationId: 'createPipelineRun',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Pipeline Runs"],
      deprecated: false,
    ),
  });

  ///Get pipeline run details
  ///@param pipelineRunId
  Future<chopper.Response<ApiV1PipelineRunsPipelineRunIdGet$Response>>
  apiV1PipelineRunsPipelineRunIdGet({required String? pipelineRunId}) {
    generatedMapping.putIfAbsent(
      ApiV1PipelineRunsPipelineRunIdGet$Response,
      () => ApiV1PipelineRunsPipelineRunIdGet$Response.fromJsonFactory,
    );

    return _apiV1PipelineRunsPipelineRunIdGet(pipelineRunId: pipelineRunId);
  }

  ///Get pipeline run details
  ///@param pipelineRunId
  @GET(path: '/api/v1/pipeline-runs/{pipelineRunId}')
  Future<chopper.Response<ApiV1PipelineRunsPipelineRunIdGet$Response>>
  _apiV1PipelineRunsPipelineRunIdGet({
    @Path('pipelineRunId') required String? pipelineRunId,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Get pipeline run details',
      operationId: 'getPipelineRun',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Pipeline Runs"],
      deprecated: false,
    ),
  });

  ///List channels for an app
  ///@param appId
  Future<chopper.Response<ApiV1ChannelsGet$Response>> apiV1ChannelsGet({
    required String? appId,
  }) {
    generatedMapping.putIfAbsent(
      ApiV1ChannelsGet$Response$Item,
      () => ApiV1ChannelsGet$Response$Item.fromJsonFactory,
    );

    return _apiV1ChannelsGet(appId: appId);
  }

  ///List channels for an app
  ///@param appId
  @GET(path: '/api/v1/channels')
  Future<chopper.Response<ApiV1ChannelsGet$Response>> _apiV1ChannelsGet({
    @Query('appId') required String? appId,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'List channels for an app',
      operationId: 'listChannels',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Channels"],
      deprecated: false,
    ),
  });

  ///Create channel (system or custom)
  Future<chopper.Response<ApiV1ChannelsPost$Response>> apiV1ChannelsPost({
    required ApiV1ChannelsPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ApiV1ChannelsPost$Response,
      () => ApiV1ChannelsPost$Response.fromJsonFactory,
    );

    return _apiV1ChannelsPost(body: body);
  }

  ///Create channel (system or custom)
  @POST(path: '/api/v1/channels', optionalBody: true)
  Future<chopper.Response<ApiV1ChannelsPost$Response>> _apiV1ChannelsPost({
    @Body() required ApiV1ChannelsPost$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Create channel (system or custom)',
      operationId: 'createChannel',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Channels"],
      deprecated: false,
    ),
  });

  ///Update channel policy
  ///@param channelId
  Future<chopper.Response<ApiV1ChannelsChannelIdPatch$Response>>
  apiV1ChannelsChannelIdPatch({
    required String? channelId,
    required ApiV1ChannelsChannelIdPatch$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ApiV1ChannelsChannelIdPatch$Response,
      () => ApiV1ChannelsChannelIdPatch$Response.fromJsonFactory,
    );

    return _apiV1ChannelsChannelIdPatch(channelId: channelId, body: body);
  }

  ///Update channel policy
  ///@param channelId
  @PATCH(path: '/api/v1/channels/{channelId}', optionalBody: true)
  Future<chopper.Response<ApiV1ChannelsChannelIdPatch$Response>>
  _apiV1ChannelsChannelIdPatch({
    @Path('channelId') required String? channelId,
    @Body() required ApiV1ChannelsChannelIdPatch$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Update channel policy',
      operationId: 'updateChannel',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Channels"],
      deprecated: false,
    ),
  });

  ///Rollback channel assignment
  ///@param channelId
  Future<chopper.Response<ApiV1ChannelsChannelIdRollbackPost$Response>>
  apiV1ChannelsChannelIdRollbackPost({
    required String? channelId,
    required ApiV1ChannelsChannelIdRollbackPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ApiV1ChannelsChannelIdRollbackPost$Response,
      () => ApiV1ChannelsChannelIdRollbackPost$Response.fromJsonFactory,
    );

    return _apiV1ChannelsChannelIdRollbackPost(
      channelId: channelId,
      body: body,
    );
  }

  ///Rollback channel assignment
  ///@param channelId
  @POST(path: '/api/v1/channels/{channelId}/rollback', optionalBody: true)
  Future<chopper.Response<ApiV1ChannelsChannelIdRollbackPost$Response>>
  _apiV1ChannelsChannelIdRollbackPost({
    @Path('channelId') required String? channelId,
    @Body() required ApiV1ChannelsChannelIdRollbackPost$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Rollback channel assignment',
      operationId: 'rollbackChannel',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Channels"],
      deprecated: false,
    ),
  });

  ///List releases for an app
  ///@param appId
  ///@param status
  Future<chopper.Response<ApiV1ReleasesGet$Response>> apiV1ReleasesGet({
    required String? appId,
    enums.ApiV1ReleasesGetStatus? status,
  }) {
    generatedMapping.putIfAbsent(
      ApiV1ReleasesGet$Response$Item,
      () => ApiV1ReleasesGet$Response$Item.fromJsonFactory,
    );

    return _apiV1ReleasesGet(appId: appId, status: status?.value?.toString());
  }

  ///List releases for an app
  ///@param appId
  ///@param status
  @GET(path: '/api/v1/releases')
  Future<chopper.Response<ApiV1ReleasesGet$Response>> _apiV1ReleasesGet({
    @Query('appId') required String? appId,
    @Query('status') String? status,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'List releases for an app',
      operationId: 'listReleases',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Releases"],
      deprecated: false,
    ),
  });

  ///Create release draft
  Future<chopper.Response<ApiV1ReleasesPost$Response>> apiV1ReleasesPost({
    required ApiV1ReleasesPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ApiV1ReleasesPost$Response,
      () => ApiV1ReleasesPost$Response.fromJsonFactory,
    );

    return _apiV1ReleasesPost(body: body);
  }

  ///Create release draft
  @POST(path: '/api/v1/releases', optionalBody: true)
  Future<chopper.Response<ApiV1ReleasesPost$Response>> _apiV1ReleasesPost({
    @Body() required ApiV1ReleasesPost$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Create release draft',
      operationId: 'createRelease',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Releases"],
      deprecated: false,
    ),
  });

  ///Get release details
  ///@param releaseId
  Future<chopper.Response<ApiV1ReleasesReleaseIdGet$Response>>
  apiV1ReleasesReleaseIdGet({required String? releaseId}) {
    generatedMapping.putIfAbsent(
      ApiV1ReleasesReleaseIdGet$Response,
      () => ApiV1ReleasesReleaseIdGet$Response.fromJsonFactory,
    );

    return _apiV1ReleasesReleaseIdGet(releaseId: releaseId);
  }

  ///Get release details
  ///@param releaseId
  @GET(path: '/api/v1/releases/{releaseId}')
  Future<chopper.Response<ApiV1ReleasesReleaseIdGet$Response>>
  _apiV1ReleasesReleaseIdGet({
    @Path('releaseId') required String? releaseId,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Get release details',
      operationId: 'getRelease',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Releases"],
      deprecated: false,
    ),
  });

  ///Verify release artifact integrity and policy coverage
  ///@param releaseId
  Future<chopper.Response<ApiV1ReleasesReleaseIdVerifyPost$Response>>
  apiV1ReleasesReleaseIdVerifyPost({required String? releaseId}) {
    generatedMapping.putIfAbsent(
      ApiV1ReleasesReleaseIdVerifyPost$Response,
      () => ApiV1ReleasesReleaseIdVerifyPost$Response.fromJsonFactory,
    );

    return _apiV1ReleasesReleaseIdVerifyPost(releaseId: releaseId);
  }

  ///Verify release artifact integrity and policy coverage
  ///@param releaseId
  @POST(path: '/api/v1/releases/{releaseId}/verify', optionalBody: true)
  Future<chopper.Response<ApiV1ReleasesReleaseIdVerifyPost$Response>>
  _apiV1ReleasesReleaseIdVerifyPost({
    @Path('releaseId') required String? releaseId,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Verify release artifact integrity and policy coverage',
      operationId: 'verifyRelease',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Releases"],
      deprecated: false,
    ),
  });

  ///Publish release to one or more channels
  ///@param releaseId
  Future<chopper.Response<ApiV1ReleasesReleaseIdPublishPost$Response>>
  apiV1ReleasesReleaseIdPublishPost({
    required String? releaseId,
    required ApiV1ReleasesReleaseIdPublishPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ApiV1ReleasesReleaseIdPublishPost$Response,
      () => ApiV1ReleasesReleaseIdPublishPost$Response.fromJsonFactory,
    );

    return _apiV1ReleasesReleaseIdPublishPost(releaseId: releaseId, body: body);
  }

  ///Publish release to one or more channels
  ///@param releaseId
  @POST(path: '/api/v1/releases/{releaseId}/publish', optionalBody: true)
  Future<chopper.Response<ApiV1ReleasesReleaseIdPublishPost$Response>>
  _apiV1ReleasesReleaseIdPublishPost({
    @Path('releaseId') required String? releaseId,
    @Body() required ApiV1ReleasesReleaseIdPublishPost$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Publish release to one or more channels',
      operationId: 'publishRelease',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Releases"],
      deprecated: false,
    ),
  });

  ///Promote release between channels
  ///@param releaseId
  Future<chopper.Response<ApiV1ReleasesReleaseIdPromotePost$Response>>
  apiV1ReleasesReleaseIdPromotePost({
    required String? releaseId,
    required ApiV1ReleasesReleaseIdPromotePost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ApiV1ReleasesReleaseIdPromotePost$Response,
      () => ApiV1ReleasesReleaseIdPromotePost$Response.fromJsonFactory,
    );

    return _apiV1ReleasesReleaseIdPromotePost(releaseId: releaseId, body: body);
  }

  ///Promote release between channels
  ///@param releaseId
  @POST(path: '/api/v1/releases/{releaseId}/promote', optionalBody: true)
  Future<chopper.Response<ApiV1ReleasesReleaseIdPromotePost$Response>>
  _apiV1ReleasesReleaseIdPromotePost({
    @Path('releaseId') required String? releaseId,
    @Body() required ApiV1ReleasesReleaseIdPromotePost$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Promote release between channels',
      operationId: 'promoteRelease',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Releases"],
      deprecated: false,
    ),
  });

  ///Create upload URL for an artifact and resolve release by app slug + version
  Future<chopper.Response<ApiV1ArtifactsUploadUrlPost$Response>>
  apiV1ArtifactsUploadUrlPost({
    required ApiV1ArtifactsUploadUrlPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ApiV1ArtifactsUploadUrlPost$Response,
      () => ApiV1ArtifactsUploadUrlPost$Response.fromJsonFactory,
    );

    return _apiV1ArtifactsUploadUrlPost(body: body);
  }

  ///Create upload URL for an artifact and resolve release by app slug + version
  @POST(path: '/api/v1/artifacts/upload-url', optionalBody: true)
  Future<chopper.Response<ApiV1ArtifactsUploadUrlPost$Response>>
  _apiV1ArtifactsUploadUrlPost({
    @Body() required ApiV1ArtifactsUploadUrlPost$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Create upload URL for an artifact and resolve release by app slug + version',
      operationId: 'createArtifactUploadUrlByVersion',
      consumes: [],
      produces: [],
      security: ["HippoAuthBearer", "ApiKeyHeader"],
      tags: ["Artifacts"],
      deprecated: false,
    ),
  });

  ///Create upload URL for an artifact
  ///@param releaseId
  Future<
    chopper.Response<ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$Response>
  >
  apiV1ReleasesReleaseIdArtifactsUploadUrlPost({
    required String? releaseId,
    required ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$Response,
      () =>
          ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$Response.fromJsonFactory,
    );

    return _apiV1ReleasesReleaseIdArtifactsUploadUrlPost(
      releaseId: releaseId,
      body: body,
    );
  }

  ///Create upload URL for an artifact
  ///@param releaseId
  @POST(
    path: '/api/v1/releases/{releaseId}/artifacts/upload-url',
    optionalBody: true,
  )
  Future<
    chopper.Response<ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$Response>
  >
  _apiV1ReleasesReleaseIdArtifactsUploadUrlPost({
    @Path('releaseId') required String? releaseId,
    @Body()
    required ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Create upload URL for an artifact',
      operationId: 'createArtifactUploadUrl',
      consumes: [],
      produces: [],
      security: ["HippoAuthBearer", "ApiKeyHeader"],
      tags: ["Artifacts"],
      deprecated: false,
    ),
  });

  ///Get aggregated download metrics
  ///@param appId
  ///@param from
  ///@param to
  ///@param channel
  Future<chopper.Response<ApiV1MetricsDownloadsGet$Response>>
  apiV1MetricsDownloadsGet({
    required String? appId,
    String? from,
    String? to,
    String? channel,
  }) {
    generatedMapping.putIfAbsent(
      ApiV1MetricsDownloadsGet$Response,
      () => ApiV1MetricsDownloadsGet$Response.fromJsonFactory,
    );

    return _apiV1MetricsDownloadsGet(
      appId: appId,
      from: from,
      to: to,
      channel: channel,
    );
  }

  ///Get aggregated download metrics
  ///@param appId
  ///@param from
  ///@param to
  ///@param channel
  @GET(path: '/api/v1/metrics/downloads')
  Future<chopper.Response<ApiV1MetricsDownloadsGet$Response>>
  _apiV1MetricsDownloadsGet({
    @Query('appId') required String? appId,
    @Query('from') String? from,
    @Query('to') String? to,
    @Query('channel') String? channel,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Get aggregated download metrics',
      operationId: 'getDownloadMetrics',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Metrics"],
      deprecated: false,
    ),
  });

  ///Get aggregated update-check metrics
  ///@param appId
  ///@param from
  ///@param to
  ///@param channel
  Future<chopper.Response<ApiV1MetricsUpdateChecksGet$Response>>
  apiV1MetricsUpdateChecksGet({
    required String? appId,
    String? from,
    String? to,
    String? channel,
  }) {
    generatedMapping.putIfAbsent(
      ApiV1MetricsUpdateChecksGet$Response,
      () => ApiV1MetricsUpdateChecksGet$Response.fromJsonFactory,
    );

    return _apiV1MetricsUpdateChecksGet(
      appId: appId,
      from: from,
      to: to,
      channel: channel,
    );
  }

  ///Get aggregated update-check metrics
  ///@param appId
  ///@param from
  ///@param to
  ///@param channel
  @GET(path: '/api/v1/metrics/update-checks')
  Future<chopper.Response<ApiV1MetricsUpdateChecksGet$Response>>
  _apiV1MetricsUpdateChecksGet({
    @Query('appId') required String? appId,
    @Query('from') String? from,
    @Query('to') String? to,
    @Query('channel') String? channel,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Get aggregated update-check metrics',
      operationId: 'getUpdateCheckMetrics',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Metrics"],
      deprecated: false,
    ),
  });

  ///Get dashboard summary data
  Future<chopper.Response<ApiV1DashboardSummaryGet$Response>>
  apiV1DashboardSummaryGet() {
    generatedMapping.putIfAbsent(
      ApiV1DashboardSummaryGet$Response,
      () => ApiV1DashboardSummaryGet$Response.fromJsonFactory,
    );

    return _apiV1DashboardSummaryGet();
  }

  ///Get dashboard summary data
  @GET(path: '/api/v1/dashboard/summary')
  Future<chopper.Response<ApiV1DashboardSummaryGet$Response>>
  _apiV1DashboardSummaryGet({
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Get dashboard summary data',
      operationId: 'getDashboardSummary',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Dashboard"],
      deprecated: false,
    ),
  });

  ///Get appcast XML for update clients
  ///@param appSlug
  ///@param platform
  ///@param arch
  ///@param channel
  ///@param currentVersion
  Future<chopper.Response<String>>
  apiPublicV1AppcastAppSlugPlatformArchChannelAppcastXmlGet({
    required String? appSlug,
    required enums.ApiPublicV1AppcastAppSlugPlatformArchChannelAppcastXmlGetPlatform?
    platform,
    required enums.ApiPublicV1AppcastAppSlugPlatformArchChannelAppcastXmlGetArch?
    arch,
    required String? channel,
    String? currentVersion,
  }) {
    return _apiPublicV1AppcastAppSlugPlatformArchChannelAppcastXmlGet(
      appSlug: appSlug,
      platform: platform?.value?.toString(),
      arch: arch?.value?.toString(),
      channel: channel,
      currentVersion: currentVersion,
    );
  }

  ///Get appcast XML for update clients
  ///@param appSlug
  ///@param platform
  ///@param arch
  ///@param channel
  ///@param currentVersion
  @GET(
    path:
        '/api/public/v1/appcast/{appSlug}/{platform}/{arch}/{channel}/appcast.xml',
  )
  Future<chopper.Response<String>>
  _apiPublicV1AppcastAppSlugPlatformArchChannelAppcastXmlGet({
    @Path('appSlug') required String? appSlug,
    @Path('platform') required String? platform,
    @Path('arch') required String? arch,
    @Path('channel') required String? channel,
    @Query('currentVersion') String? currentVersion,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Get appcast XML for update clients',
      operationId: 'getAppcast',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Public"],
      deprecated: false,
    ),
  });

  ///Track and redirect to artifact download scoped to an app channel
  ///@param appSlug
  ///@param channelSlug
  ///@param artifactId
  Future<chopper.Response>
  apiPublicV1ChannelsAppSlugChannelSlugDownloadArtifactIdGet({
    required String? appSlug,
    required String? channelSlug,
    required String? artifactId,
  }) {
    return _apiPublicV1ChannelsAppSlugChannelSlugDownloadArtifactIdGet(
      appSlug: appSlug,
      channelSlug: channelSlug,
      artifactId: artifactId,
    );
  }

  ///Track and redirect to artifact download scoped to an app channel
  ///@param appSlug
  ///@param channelSlug
  ///@param artifactId
  @GET(
    path:
        '/api/public/v1/channels/{appSlug}/{channelSlug}/download/{artifactId}',
  )
  Future<chopper.Response>
  _apiPublicV1ChannelsAppSlugChannelSlugDownloadArtifactIdGet({
    @Path('appSlug') required String? appSlug,
    @Path('channelSlug') required String? channelSlug,
    @Path('artifactId') required String? artifactId,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Track and redirect to artifact download scoped to an app channel',
      operationId: 'downloadChannelArtifact',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Public"],
      deprecated: false,
    ),
  });

  ///Track and redirect to artifact download
  ///@param artifactId
  Future<chopper.Response> apiPublicV1DownloadArtifactIdGet({
    required String? artifactId,
  }) {
    return _apiPublicV1DownloadArtifactIdGet(artifactId: artifactId);
  }

  ///Track and redirect to artifact download
  ///@param artifactId
  @GET(path: '/api/public/v1/download/{artifactId}')
  Future<chopper.Response> _apiPublicV1DownloadArtifactIdGet({
    @Path('artifactId') required String? artifactId,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Track and redirect to artifact download',
      operationId: 'downloadArtifact',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Public"],
      deprecated: false,
    ),
  });

  ///Local fallback endpoint when S3 is not configured
  ///@param key
  Future<chopper.Response> apiPublicV1MockS3KeyGet({required String? key}) {
    return _apiPublicV1MockS3KeyGet(key: key);
  }

  ///Local fallback endpoint when S3 is not configured
  ///@param key
  @GET(path: '/api/public/v1/mock-s3/{key}')
  Future<chopper.Response> _apiPublicV1MockS3KeyGet({
    @Path('key') required String? key,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Local fallback endpoint when S3 is not configured',
      operationId: 'mockS3Download',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Public"],
      deprecated: false,
    ),
  });
}

typedef $JsonFactory<T> = T Function(Map<String, dynamic> json);

class $CustomJsonDecoder {
  $CustomJsonDecoder(this.factories);

  final Map<Type, $JsonFactory> factories;

  dynamic decode<T>(dynamic entity) {
    if (entity is Iterable) {
      return _decodeList<T>(entity);
    }

    if (entity is T) {
      return entity;
    }

    if (isTypeOf<T, Map>()) {
      return entity;
    }

    if (isTypeOf<T, Iterable>()) {
      return entity;
    }

    if (entity is Map<String, dynamic>) {
      return _decodeMap<T>(entity);
    }

    return entity;
  }

  T _decodeMap<T>(Map<String, dynamic> values) {
    final jsonFactory = factories[T];
    if (jsonFactory == null || jsonFactory is! $JsonFactory<T>) {
      return throw "Could not find factory for type $T. Is '$T: $T.fromJsonFactory' included in the CustomJsonDecoder instance creation in bootstrapper.dart?";
    }

    return jsonFactory(values);
  }

  List<T> _decodeList<T>(Iterable values) =>
      values.where((v) => v != null).map<T>((v) => decode<T>(v) as T).toList();
}

class $JsonSerializableConverter extends chopper.JsonConverter {
  @override
  FutureOr<chopper.Response<ResultType>> convertResponse<ResultType, Item>(
    chopper.Response response,
  ) async {
    if (response.bodyString.isEmpty) {
      // In rare cases, when let's say 204 (no content) is returned -
      // we cannot decode the missing json with the result type specified
      return chopper.Response(response.base, null, error: response.error);
    }

    if (ResultType == String) {
      return response.copyWith();
    }

    if (ResultType == DateTime) {
      return response.copyWith(
        body:
            DateTime.parse((response.body as String).replaceAll('"', ''))
                as ResultType,
      );
    }

    final jsonRes = await super.convertResponse(response);
    return jsonRes.copyWith<ResultType>(
      body: $jsonDecoder.decode<Item>(jsonRes.body) as ResultType,
    );
  }
}

final $jsonDecoder = $CustomJsonDecoder(generatedMapping);
