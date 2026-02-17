// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

enum ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('github')
  github('github');

  final String? value;

  const ApiV1AppsAppIdRepositoryConnectionGet$ResponseProvider(this.value);
}

enum ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('github')
  github('github');

  final String? value;

  const ApiV1AppsAppIdRepositoryConnectionPut$ResponseProvider(this.value);
}

enum ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('app-store-connect')
  appStoreConnect('app-store-connect'),
  @JsonValue('play-store')
  playStore('play-store'),
  @JsonValue('artifact-upload')
  artifactUpload('artifact-upload');

  final String? value;

  const ApiV1AppsAppIdDeploymentTargetsGet$Response$ItemKind(this.value);
}

enum ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('app-store-connect')
  appStoreConnect('app-store-connect'),
  @JsonValue('play-store')
  playStore('play-store'),
  @JsonValue('artifact-upload')
  artifactUpload('artifact-upload');

  final String? value;

  const ApiV1AppsAppIdDeploymentTargetsPost$ResponseKind(this.value);
}

enum ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('macos')
  macos('macos'),
  @JsonValue('windows')
  windows('windows'),
  @JsonValue('linux')
  linux('linux'),
  @JsonValue('ios')
  ios('ios'),
  @JsonValue('android')
  android('android');

  final String? value;

  const ApiV1AppsAppIdBuildProfilesGet$Response$ItemPlatform(this.value);
}

enum ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('x64')
  x64('x64'),
  @JsonValue('arm64')
  arm64('arm64');

  final String? value;

  const ApiV1AppsAppIdBuildProfilesGet$Response$ItemArch(this.value);
}

enum ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('macos')
  macos('macos'),
  @JsonValue('windows')
  windows('windows'),
  @JsonValue('linux')
  linux('linux'),
  @JsonValue('ios')
  ios('ios'),
  @JsonValue('android')
  android('android');

  final String? value;

  const ApiV1AppsAppIdBuildProfilesPost$ResponsePlatform(this.value);
}

enum ApiV1AppsAppIdBuildProfilesPost$ResponseArch {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('x64')
  x64('x64'),
  @JsonValue('arm64')
  arm64('arm64');

  final String? value;

  const ApiV1AppsAppIdBuildProfilesPost$ResponseArch(this.value);
}

enum ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('manual')
  manual('manual'),
  @JsonValue('webhook')
  webhook('webhook');

  final String? value;

  const ApiV1AppsAppIdPipelineRunsGet$Response$ItemTriggerMode(this.value);
}

enum ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('queued')
  queued('queued'),
  @JsonValue('running')
  running('running'),
  @JsonValue('succeeded')
  succeeded('succeeded'),
  @JsonValue('failed')
  failed('failed'),
  @JsonValue('cancelled')
  cancelled('cancelled'),
  @JsonValue('partially_succeeded')
  partiallySucceeded('partially_succeeded');

  final String? value;

  const ApiV1AppsAppIdPipelineRunsGet$Response$ItemStatus(this.value);
}

enum ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('manual')
  manual('manual'),
  @JsonValue('webhook')
  webhook('webhook');

  final String? value;

  const ApiV1AppsAppIdPipelineRunsPost$ResponseTriggerMode(this.value);
}

enum ApiV1AppsAppIdPipelineRunsPost$ResponseStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('queued')
  queued('queued'),
  @JsonValue('running')
  running('running'),
  @JsonValue('succeeded')
  succeeded('succeeded'),
  @JsonValue('failed')
  failed('failed'),
  @JsonValue('cancelled')
  cancelled('cancelled'),
  @JsonValue('partially_succeeded')
  partiallySucceeded('partially_succeeded');

  final String? value;

  const ApiV1AppsAppIdPipelineRunsPost$ResponseStatus(this.value);
}

enum ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('macos')
  macos('macos'),
  @JsonValue('windows')
  windows('windows'),
  @JsonValue('linux')
  linux('linux'),
  @JsonValue('ios')
  ios('ios'),
  @JsonValue('android')
  android('android');

  final String? value;

  const ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemPlatform(this.value);
}

enum ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('x64')
  x64('x64'),
  @JsonValue('arm64')
  arm64('arm64');

  final String? value;

  const ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemArch(this.value);
}

enum ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('queued')
  queued('queued'),
  @JsonValue('running')
  running('running'),
  @JsonValue('succeeded')
  succeeded('succeeded'),
  @JsonValue('failed')
  failed('failed'),
  @JsonValue('cancelled')
  cancelled('cancelled'),
  @JsonValue('skipped')
  skipped('skipped');

  final String? value;

  const ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemStatus(this.value);
}

enum ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('queued')
  queued('queued'),
  @JsonValue('running')
  running('running'),
  @JsonValue('succeeded')
  succeeded('succeeded'),
  @JsonValue('failed')
  failed('failed'),
  @JsonValue('skipped')
  skipped('skipped');

  final String? value;

  const ApiV1AppsAppIdPipelineRunsPost$Response$Jobs$ItemDeploymentStatus(
    this.value,
  );
}

enum ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('manual')
  manual('manual'),
  @JsonValue('webhook')
  webhook('webhook');

  final String? value;

  const ApiV1PipelineRunsPipelineRunIdGet$ResponseTriggerMode(this.value);
}

enum ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('queued')
  queued('queued'),
  @JsonValue('running')
  running('running'),
  @JsonValue('succeeded')
  succeeded('succeeded'),
  @JsonValue('failed')
  failed('failed'),
  @JsonValue('cancelled')
  cancelled('cancelled'),
  @JsonValue('partially_succeeded')
  partiallySucceeded('partially_succeeded');

  final String? value;

  const ApiV1PipelineRunsPipelineRunIdGet$ResponseStatus(this.value);
}

enum ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('macos')
  macos('macos'),
  @JsonValue('windows')
  windows('windows'),
  @JsonValue('linux')
  linux('linux'),
  @JsonValue('ios')
  ios('ios'),
  @JsonValue('android')
  android('android');

  final String? value;

  const ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemPlatform(
    this.value,
  );
}

enum ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('x64')
  x64('x64'),
  @JsonValue('arm64')
  arm64('arm64');

  final String? value;

  const ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemArch(this.value);
}

enum ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('queued')
  queued('queued'),
  @JsonValue('running')
  running('running'),
  @JsonValue('succeeded')
  succeeded('succeeded'),
  @JsonValue('failed')
  failed('failed'),
  @JsonValue('cancelled')
  cancelled('cancelled'),
  @JsonValue('skipped')
  skipped('skipped');

  final String? value;

  const ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemStatus(this.value);
}

enum ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('queued')
  queued('queued'),
  @JsonValue('running')
  running('running'),
  @JsonValue('succeeded')
  succeeded('succeeded'),
  @JsonValue('failed')
  failed('failed'),
  @JsonValue('skipped')
  skipped('skipped');

  final String? value;

  const ApiV1PipelineRunsPipelineRunIdGet$Response$Jobs$ItemDeploymentStatus(
    this.value,
  );
}

enum ApiV1ChannelsGet$Response$ItemKind {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('system')
  system('system'),
  @JsonValue('custom')
  custom('custom');

  final String? value;

  const ApiV1ChannelsGet$Response$ItemKind(this.value);
}

enum ApiV1ChannelsGet$Response$ItemVisibility {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('public')
  public('public'),
  @JsonValue('private')
  private('private');

  final String? value;

  const ApiV1ChannelsGet$Response$ItemVisibility(this.value);
}

enum ApiV1ChannelsPost$ResponseKind {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('system')
  system('system'),
  @JsonValue('custom')
  custom('custom');

  final String? value;

  const ApiV1ChannelsPost$ResponseKind(this.value);
}

enum ApiV1ChannelsPost$ResponseVisibility {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('public')
  public('public'),
  @JsonValue('private')
  private('private');

  final String? value;

  const ApiV1ChannelsPost$ResponseVisibility(this.value);
}

enum ApiV1ChannelsChannelIdPatch$ResponseKind {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('system')
  system('system'),
  @JsonValue('custom')
  custom('custom');

  final String? value;

  const ApiV1ChannelsChannelIdPatch$ResponseKind(this.value);
}

enum ApiV1ChannelsChannelIdPatch$ResponseVisibility {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('public')
  public('public'),
  @JsonValue('private')
  private('private');

  final String? value;

  const ApiV1ChannelsChannelIdPatch$ResponseVisibility(this.value);
}

enum ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('macos')
  macos('macos'),
  @JsonValue('windows')
  windows('windows'),
  @JsonValue('linux')
  linux('linux'),
  @JsonValue('ios')
  ios('ios'),
  @JsonValue('android')
  android('android');

  final String? value;

  const ApiV1ChannelsChannelIdRollbackPost$ResponsePlatform(this.value);
}

enum ApiV1ChannelsChannelIdRollbackPost$ResponseArch {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('x64')
  x64('x64'),
  @JsonValue('arm64')
  arm64('arm64');

  final String? value;

  const ApiV1ChannelsChannelIdRollbackPost$ResponseArch(this.value);
}

enum ApiV1ReleasesGet$Response$ItemStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('draft')
  draft('draft'),
  @JsonValue('verified')
  verified('verified'),
  @JsonValue('published')
  published('published'),
  @JsonValue('archived')
  archived('archived');

  final String? value;

  const ApiV1ReleasesGet$Response$ItemStatus(this.value);
}

enum ApiV1ReleasesGetStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('draft')
  draft('draft'),
  @JsonValue('verified')
  verified('verified'),
  @JsonValue('published')
  published('published'),
  @JsonValue('archived')
  archived('archived');

  final String? value;

  const ApiV1ReleasesGetStatus(this.value);
}

enum ApiV1ReleasesPost$ResponseStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('draft')
  draft('draft'),
  @JsonValue('verified')
  verified('verified'),
  @JsonValue('published')
  published('published'),
  @JsonValue('archived')
  archived('archived');

  final String? value;

  const ApiV1ReleasesPost$ResponseStatus(this.value);
}

enum ApiV1ReleasesReleaseIdGet$ResponseStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('draft')
  draft('draft'),
  @JsonValue('verified')
  verified('verified'),
  @JsonValue('published')
  published('published'),
  @JsonValue('archived')
  archived('archived');

  final String? value;

  const ApiV1ReleasesReleaseIdGet$ResponseStatus(this.value);
}

enum ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('macos')
  macos('macos'),
  @JsonValue('windows')
  windows('windows'),
  @JsonValue('linux')
  linux('linux'),
  @JsonValue('ios')
  ios('ios'),
  @JsonValue('android')
  android('android');

  final String? value;

  const ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemPlatform(this.value);
}

enum ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('x64')
  x64('x64'),
  @JsonValue('arm64')
  arm64('arm64'),
  @JsonValue('universal')
  universal('universal');

  final String? value;

  const ApiV1ReleasesReleaseIdGet$Response$Artifacts$ItemArch(this.value);
}

enum ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('draft')
  draft('draft'),
  @JsonValue('verified')
  verified('verified'),
  @JsonValue('published')
  published('published'),
  @JsonValue('archived')
  archived('archived');

  final String? value;

  const ApiV1ReleasesReleaseIdVerifyPost$ResponseStatus(this.value);
}

enum ApiV1ReleasesReleaseIdPublishPost$ResponseStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('draft')
  draft('draft'),
  @JsonValue('verified')
  verified('verified'),
  @JsonValue('published')
  published('published'),
  @JsonValue('archived')
  archived('archived');

  final String? value;

  const ApiV1ReleasesReleaseIdPublishPost$ResponseStatus(this.value);
}

enum ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('macos')
  macos('macos'),
  @JsonValue('windows')
  windows('windows'),
  @JsonValue('linux')
  linux('linux'),
  @JsonValue('ios')
  ios('ios'),
  @JsonValue('android')
  android('android');

  final String? value;

  const ApiV1ReleasesReleaseIdPromotePost$ResponsePlatform(this.value);
}

enum ApiV1ReleasesReleaseIdPromotePost$ResponseArch {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('x64')
  x64('x64'),
  @JsonValue('arm64')
  arm64('arm64');

  final String? value;

  const ApiV1ReleasesReleaseIdPromotePost$ResponseArch(this.value);
}

enum ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('system')
  system('system'),
  @JsonValue('custom')
  custom('custom');

  final String? value;

  const ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemChannelKind(
    this.value,
  );
}

enum ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('macos')
  macos('macos'),
  @JsonValue('windows')
  windows('windows'),
  @JsonValue('linux')
  linux('linux'),
  @JsonValue('ios')
  ios('ios'),
  @JsonValue('android')
  android('android');

  final String? value;

  const ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemPlatform(
    this.value,
  );
}

enum ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('x64')
  x64('x64'),
  @JsonValue('arm64')
  arm64('arm64');

  final String? value;

  const ApiV1DashboardSummaryGet$Response$ActiveAssignments$ItemArch(
    this.value,
  );
}

enum ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('macos')
  macos('macos'),
  @JsonValue('windows')
  windows('windows'),
  @JsonValue('linux')
  linux('linux');

  final String? value;

  const ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetPlatform(
    this.value,
  );
}

enum ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('x64')
  x64('x64'),
  @JsonValue('arm64')
  arm64('arm64'),
  @JsonValue('universal')
  universal('universal');

  final String? value;

  const ApiPublicV1AppcastAppSlugPlatformChannelAppcastXmlGetArch(this.value);
}

enum ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('app-store-connect')
  appStoreConnect('app-store-connect'),
  @JsonValue('play-store')
  playStore('play-store'),
  @JsonValue('artifact-upload')
  artifactUpload('artifact-upload');

  final String? value;

  const ApiV1AppsAppIdDeploymentTargetsPost$RequestBodyKind(this.value);
}

enum ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('macos')
  macos('macos'),
  @JsonValue('windows')
  windows('windows'),
  @JsonValue('linux')
  linux('linux'),
  @JsonValue('ios')
  ios('ios'),
  @JsonValue('android')
  android('android');

  final String? value;

  const ApiV1AppsAppIdBuildProfilesPost$RequestBodyPlatform(this.value);
}

enum ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('x64')
  x64('x64'),
  @JsonValue('arm64')
  arm64('arm64');

  final String? value;

  const ApiV1AppsAppIdBuildProfilesPost$RequestBodyArch(this.value);
}

enum ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('manual')
  manual('manual'),
  @JsonValue('webhook')
  webhook('webhook');

  final String? value;

  const ApiV1AppsAppIdPipelineRunsPost$RequestBodyTriggerMode(this.value);
}

enum ApiV1ChannelsPost$RequestBodyKind {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('system')
  system('system'),
  @JsonValue('custom')
  custom('custom');

  final String? value;

  const ApiV1ChannelsPost$RequestBodyKind(this.value);
}

enum ApiV1ChannelsPost$RequestBodyVisibility {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('public')
  public('public'),
  @JsonValue('private')
  private('private');

  final String? value;

  const ApiV1ChannelsPost$RequestBodyVisibility(this.value);
}

enum ApiV1ChannelsChannelIdPatch$RequestBodyVisibility {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('public')
  public('public'),
  @JsonValue('private')
  private('private');

  final String? value;

  const ApiV1ChannelsChannelIdPatch$RequestBodyVisibility(this.value);
}

enum ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('macos')
  macos('macos'),
  @JsonValue('windows')
  windows('windows'),
  @JsonValue('linux')
  linux('linux'),
  @JsonValue('ios')
  ios('ios'),
  @JsonValue('android')
  android('android');

  final String? value;

  const ApiV1ChannelsChannelIdRollbackPost$RequestBodyPlatform(this.value);
}

enum ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('x64')
  x64('x64'),
  @JsonValue('arm64')
  arm64('arm64');

  final String? value;

  const ApiV1ChannelsChannelIdRollbackPost$RequestBodyArch(this.value);
}

enum ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('macos')
  macos('macos'),
  @JsonValue('windows')
  windows('windows'),
  @JsonValue('linux')
  linux('linux'),
  @JsonValue('ios')
  ios('ios'),
  @JsonValue('android')
  android('android');

  final String? value;

  const ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemPlatform(
    this.value,
  );
}

enum ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('x64')
  x64('x64'),
  @JsonValue('arm64')
  arm64('arm64');

  final String? value;

  const ApiV1ReleasesReleaseIdPublishPost$RequestBody$Targets$ItemArch(
    this.value,
  );
}

enum ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('macos')
  macos('macos'),
  @JsonValue('windows')
  windows('windows'),
  @JsonValue('linux')
  linux('linux'),
  @JsonValue('ios')
  ios('ios'),
  @JsonValue('android')
  android('android');

  final String? value;

  const ApiV1ReleasesReleaseIdPromotePost$RequestBodyPlatform(this.value);
}

enum ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('x64')
  x64('x64'),
  @JsonValue('arm64')
  arm64('arm64');

  final String? value;

  const ApiV1ReleasesReleaseIdPromotePost$RequestBodyArch(this.value);
}

enum ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('macos')
  macos('macos'),
  @JsonValue('windows')
  windows('windows'),
  @JsonValue('linux')
  linux('linux'),
  @JsonValue('ios')
  ios('ios'),
  @JsonValue('android')
  android('android');

  final String? value;

  const ApiV1ArtifactsUploadUrlPost$RequestBodyPlatform(this.value);
}

enum ApiV1ArtifactsUploadUrlPost$RequestBodyArch {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('x64')
  x64('x64'),
  @JsonValue('arm64')
  arm64('arm64'),
  @JsonValue('universal')
  universal('universal');

  final String? value;

  const ApiV1ArtifactsUploadUrlPost$RequestBodyArch(this.value);
}

enum ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('macos')
  macos('macos'),
  @JsonValue('windows')
  windows('windows'),
  @JsonValue('linux')
  linux('linux'),
  @JsonValue('ios')
  ios('ios'),
  @JsonValue('android')
  android('android');

  final String? value;

  const ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyPlatform(
    this.value,
  );
}

enum ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('x64')
  x64('x64'),
  @JsonValue('arm64')
  arm64('arm64'),
  @JsonValue('universal')
  universal('universal');

  final String? value;

  const ApiV1ReleasesReleaseIdArtifactsUploadUrlPost$RequestBodyArch(
    this.value,
  );
}
