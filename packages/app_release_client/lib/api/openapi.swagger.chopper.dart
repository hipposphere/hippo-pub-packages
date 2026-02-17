// dart format width=80
// Generated code

part of 'openapi.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$Openapi extends Openapi {
  _$Openapi([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = Openapi;

  @override
  Future<Response<ApiHealthzGet$Response>> _apiHealthzGet({
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
  }) {
    final Uri $url = Uri.parse('/api/healthz');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<ApiHealthzGet$Response, ApiHealthzGet$Response>(
      $request,
    );
  }

  @override
  Future<Response<List<ApiV1ApiKeysGet$Response$Item>>> _apiV1ApiKeysGet({
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
  }) {
    final Uri $url = Uri.parse('/api/v1/api-keys');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<
      List<ApiV1ApiKeysGet$Response$Item>,
      ApiV1ApiKeysGet$Response$Item
    >($request);
  }

  @override
  Future<Response<ApiV1ApiKeysPost$Response>> _apiV1ApiKeysPost({
    required ApiV1ApiKeysPost$RequestBody? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/api-keys');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ApiV1ApiKeysPost$Response, ApiV1ApiKeysPost$Response>(
      $request,
    );
  }

  @override
  Future<Response<ApiV1ApiKeysApiKeyIdRevokePost$Response>>
  _apiV1ApiKeysApiKeyIdRevokePost({
    required String? apiKeyId,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/api-keys/${apiKeyId}/revoke');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<
      ApiV1ApiKeysApiKeyIdRevokePost$Response,
      ApiV1ApiKeysApiKeyIdRevokePost$Response
    >($request);
  }

  @override
  Future<Response<List<ApiV1AppsGet$Response$Item>>> _apiV1AppsGet({
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
  }) {
    final Uri $url = Uri.parse('/api/v1/apps');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client
        .send<List<ApiV1AppsGet$Response$Item>, ApiV1AppsGet$Response$Item>(
          $request,
        );
  }

  @override
  Future<Response<ApiV1AppsPost$Response>> _apiV1AppsPost({
    required ApiV1AppsPost$RequestBody? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/apps');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ApiV1AppsPost$Response, ApiV1AppsPost$Response>(
      $request,
    );
  }

  @override
  Future<Response<ApiV1AppsAppIdRepositoryConnectionGet$Response>>
  _apiV1AppsAppIdRepositoryConnectionGet({
    required String? appId,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/apps/${appId}/repository-connection');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<
      ApiV1AppsAppIdRepositoryConnectionGet$Response,
      ApiV1AppsAppIdRepositoryConnectionGet$Response
    >($request);
  }

  @override
  Future<Response<ApiV1AppsAppIdRepositoryConnectionPut$Response>>
  _apiV1AppsAppIdRepositoryConnectionPut({
    required String? appId,
    required ApiV1AppsAppIdRepositoryConnectionPut$RequestBody? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/apps/${appId}/repository-connection');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<
      ApiV1AppsAppIdRepositoryConnectionPut$Response,
      ApiV1AppsAppIdRepositoryConnectionPut$Response
    >($request);
  }

  @override
  Future<Response<List<ApiV1AppsAppIdDeploymentTargetsGet$Response$Item>>>
  _apiV1AppsAppIdDeploymentTargetsGet({
    required String? appId,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/apps/${appId}/deployment-targets');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<
      List<ApiV1AppsAppIdDeploymentTargetsGet$Response$Item>,
      ApiV1AppsAppIdDeploymentTargetsGet$Response$Item
    >($request);
  }

  @override
  Future<Response<ApiV1AppsAppIdDeploymentTargetsPost$Response>>
  _apiV1AppsAppIdDeploymentTargetsPost({
    required String? appId,
    required ApiV1AppsAppIdDeploymentTargetsPost$RequestBody? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/apps/${appId}/deployment-targets');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<
      ApiV1AppsAppIdDeploymentTargetsPost$Response,
      ApiV1AppsAppIdDeploymentTargetsPost$Response
    >($request);
  }

  @override
  Future<Response<List<ApiV1AppsAppIdBuildProfilesGet$Response$Item>>>
  _apiV1AppsAppIdBuildProfilesGet({
    required String? appId,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/apps/${appId}/build-profiles');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<
      List<ApiV1AppsAppIdBuildProfilesGet$Response$Item>,
      ApiV1AppsAppIdBuildProfilesGet$Response$Item
    >($request);
  }

  @override
  Future<Response<ApiV1AppsAppIdBuildProfilesPost$Response>>
  _apiV1AppsAppIdBuildProfilesPost({
    required String? appId,
    required ApiV1AppsAppIdBuildProfilesPost$RequestBody? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/apps/${appId}/build-profiles');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<
      ApiV1AppsAppIdBuildProfilesPost$Response,
      ApiV1AppsAppIdBuildProfilesPost$Response
    >($request);
  }

  @override
  Future<Response<List<ApiV1AppsAppIdPipelineRunsGet$Response$Item>>>
  _apiV1AppsAppIdPipelineRunsGet({
    required String? appId,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/apps/${appId}/pipeline-runs');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<
      List<ApiV1AppsAppIdPipelineRunsGet$Response$Item>,
      ApiV1AppsAppIdPipelineRunsGet$Response$Item
    >($request);
  }

  @override
  Future<Response<ApiV1AppsAppIdPipelineRunsPost$Response>>
  _apiV1AppsAppIdPipelineRunsPost({
    required String? appId,
    required ApiV1AppsAppIdPipelineRunsPost$RequestBody? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/apps/${appId}/pipeline-runs');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<
      ApiV1AppsAppIdPipelineRunsPost$Response,
      ApiV1AppsAppIdPipelineRunsPost$Response
    >($request);
  }

  @override
  Future<Response<ApiV1PipelineRunsPipelineRunIdGet$Response>>
  _apiV1PipelineRunsPipelineRunIdGet({
    required String? pipelineRunId,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/pipeline-runs/${pipelineRunId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<
      ApiV1PipelineRunsPipelineRunIdGet$Response,
      ApiV1PipelineRunsPipelineRunIdGet$Response
    >($request);
  }

  @override
  Future<Response<List<ApiV1ChannelsGet$Response$Item>>> _apiV1ChannelsGet({
    required String? appId,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/channels');
    final Map<String, dynamic> $params = <String, dynamic>{'appId': appId};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<
      List<ApiV1ChannelsGet$Response$Item>,
      ApiV1ChannelsGet$Response$Item
    >($request);
  }

  @override
  Future<Response<ApiV1ChannelsPost$Response>> _apiV1ChannelsPost({
    required ApiV1ChannelsPost$RequestBody? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/channels');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ApiV1ChannelsPost$Response, ApiV1ChannelsPost$Response>(
      $request,
    );
  }

  @override
  Future<Response<ApiV1ChannelsChannelIdPatch$Response>>
  _apiV1ChannelsChannelIdPatch({
    required String? channelId,
    required ApiV1ChannelsChannelIdPatch$RequestBody? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/channels/${channelId}');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<
      ApiV1ChannelsChannelIdPatch$Response,
      ApiV1ChannelsChannelIdPatch$Response
    >($request);
  }

  @override
  Future<Response<ApiV1ChannelsChannelIdRollbackPost$Response>>
  _apiV1ChannelsChannelIdRollbackPost({
    required String? channelId,
    required ApiV1ChannelsChannelIdRollbackPost$RequestBody? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/channels/${channelId}/rollback');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<
      ApiV1ChannelsChannelIdRollbackPost$Response,
      ApiV1ChannelsChannelIdRollbackPost$Response
    >($request);
  }

  @override
  Future<Response<List<ApiV1ReleasesGet$Response$Item>>> _apiV1ReleasesGet({
    required String? appId,
    String? status,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/releases');
    final Map<String, dynamic> $params = <String, dynamic>{
      'appId': appId,
      'status': status,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<
      List<ApiV1ReleasesGet$Response$Item>,
      ApiV1ReleasesGet$Response$Item
    >($request);
  }

  @override
  Future<Response<ApiV1ReleasesPost$Response>> _apiV1ReleasesPost({
    required ApiV1ReleasesPost$RequestBody? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/releases');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ApiV1ReleasesPost$Response, ApiV1ReleasesPost$Response>(
      $request,
    );
  }

  @override
  Future<Response<ApiV1ReleasesReleaseIdGet$Response>>
  _apiV1ReleasesReleaseIdGet({
    required String? releaseId,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/releases/${releaseId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<
      ApiV1ReleasesReleaseIdGet$Response,
      ApiV1ReleasesReleaseIdGet$Response
    >($request);
  }

  @override
  Future<Response<ApiV1ReleasesReleaseIdVerifyPost$Response>>
  _apiV1ReleasesReleaseIdVerifyPost({
    required String? releaseId,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/releases/${releaseId}/verify');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<
      ApiV1ReleasesReleaseIdVerifyPost$Response,
      ApiV1ReleasesReleaseIdVerifyPost$Response
    >($request);
  }

  @override
  Future<Response<ApiV1ReleasesReleaseIdPublishPost$Response>>
  _apiV1ReleasesReleaseIdPublishPost({
    required String? releaseId,
    required ApiV1ReleasesReleaseIdPublishPost$RequestBody? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/releases/${releaseId}/publish');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<
      ApiV1ReleasesReleaseIdPublishPost$Response,
      ApiV1ReleasesReleaseIdPublishPost$Response
    >($request);
  }

  @override
  Future<Response<ApiV1ReleasesReleaseIdPromotePost$Response>>
  _apiV1ReleasesReleaseIdPromotePost({
    required String? releaseId,
    required ApiV1ReleasesReleaseIdPromotePost$RequestBody? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/releases/${releaseId}/promote');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<
      ApiV1ReleasesReleaseIdPromotePost$Response,
      ApiV1ReleasesReleaseIdPromotePost$Response
    >($request);
  }

  @override
  Future<Response<ApiV1ArtifactsUploadUrlPost$Response>>
  _apiV1ArtifactsUploadUrlPost({
    required ApiV1ArtifactsUploadUrlPost$RequestBody? body,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/artifacts/upload-url');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<
      ApiV1ArtifactsUploadUrlPost$Response,
      ApiV1ArtifactsUploadUrlPost$Response
    >($request);
  }

  @override
  Future<Response<ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$Response>>
  _apiV1ReleasesReleaseIdArtifactsUploadUrlPost({
    required String? releaseId,
    required ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBody? body,
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
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/releases/${releaseId}/artifacts/upload-url',
    );
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<
      ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$Response,
      ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$Response
    >($request);
  }

  @override
  Future<Response<ApiV1MetricsDownloadsGet$Response>>
  _apiV1MetricsDownloadsGet({
    required String? appId,
    String? from,
    String? to,
    String? channel,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/metrics/downloads');
    final Map<String, dynamic> $params = <String, dynamic>{
      'appId': appId,
      'from': from,
      'to': to,
      'channel': channel,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<
      ApiV1MetricsDownloadsGet$Response,
      ApiV1MetricsDownloadsGet$Response
    >($request);
  }

  @override
  Future<Response<ApiV1MetricsUpdateChecksGet$Response>>
  _apiV1MetricsUpdateChecksGet({
    required String? appId,
    String? from,
    String? to,
    String? channel,
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
  }) {
    final Uri $url = Uri.parse('/api/v1/metrics/update-checks');
    final Map<String, dynamic> $params = <String, dynamic>{
      'appId': appId,
      'from': from,
      'to': to,
      'channel': channel,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<
      ApiV1MetricsUpdateChecksGet$Response,
      ApiV1MetricsUpdateChecksGet$Response
    >($request);
  }

  @override
  Future<Response<ApiV1DashboardSummaryGet$Response>>
  _apiV1DashboardSummaryGet({
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
  }) {
    final Uri $url = Uri.parse('/api/v1/dashboard/summary');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<
      ApiV1DashboardSummaryGet$Response,
      ApiV1DashboardSummaryGet$Response
    >($request);
  }

  @override
  Future<Response<String>>
  _apiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGet({
    required String? appSlug,
    required String? platform,
    required String? channel,
    String? currentVersion,
    String? arch,
    String? packageType,
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
  }) {
    final Uri $url = Uri.parse(
      '/api/public/v1/appcast/${appSlug}/${platform}/${channel}/appcast.xml',
    );
    final Map<String, dynamic> $params = <String, dynamic>{
      'currentVersion': currentVersion,
      'arch': arch,
      'packageType': packageType,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<dynamic>>
  _apiPublicV1ChannelsAppSlugChannelSlugDownloadArtifactIdGet({
    required String? appSlug,
    required String? channelSlug,
    required String? artifactId,
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
  }) {
    final Uri $url = Uri.parse(
      '/api/public/v1/channels/${appSlug}/${channelSlug}/download/${artifactId}',
    );
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiPublicV1DownloadArtifactIdGet({
    required String? artifactId,
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
  }) {
    final Uri $url = Uri.parse('/api/public/v1/download/${artifactId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiPublicV1MockS3KeyGet({
    required String? key,
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
  }) {
    final Uri $url = Uri.parse('/api/public/v1/mock-s3/${key}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
