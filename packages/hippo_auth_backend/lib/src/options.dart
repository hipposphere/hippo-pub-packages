import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_sql/dart_edge_sql.dart';

const defaultHippoAuthSessionCookieName = 'hippo_auth_session';

final class HippoAuthBackendOptions {
  const HippoAuthBackendOptions({
    required this.database,
    required this.secret,
    required this.baseUrl,
    this.trustedOrigins = const <String>[],
    this.databaseSchema,
    this.manageMigrations = false,
    this.appName = 'Hippo Auth',
    this.betterAuthBasePath = '/better-auth',
    required this.workerPoolSize,
    this.exposeBetterAuthApi = false,
    this.useNativeBetterAuthRoutes = true,
    this.emailSignInEnabled = true,
    this.emailSignUpEnabled = true,
    this.enablePasswordManagement = true,
    this.enableAccountManagement = true,
    this.enableEmailVerification = false,
    this.enableRateLimit = false,
    this.sessionCookieName = defaultHippoAuthSessionCookieName,
    this.allowLoopbackOAuthCallbackUrls = true,
    this.ssoProviders = const <HippoAuthSsoProvider>[],
    this.admin = const HippoAuthBackendAdminOptions(),
    this.branding = const HippoAuthBackendBranding(),
  });

  final SqlPool database;
  final String secret;
  final String baseUrl;
  final List<String> trustedOrigins;
  final String? databaseSchema;
  final bool manageMigrations;
  final String appName;
  final String betterAuthBasePath;
  final int workerPoolSize;
  final bool exposeBetterAuthApi;
  final bool useNativeBetterAuthRoutes;
  final bool emailSignInEnabled;
  final bool emailSignUpEnabled;
  final bool enablePasswordManagement;
  final bool enableAccountManagement;
  final bool enableEmailVerification;
  final bool enableRateLimit;
  final String sessionCookieName;
  final bool allowLoopbackOAuthCallbackUrls;
  final List<HippoAuthSsoProvider> ssoProviders;
  final HippoAuthBackendAdminOptions admin;
  final HippoAuthBackendBranding branding;

  DartEdgeAuthConfig toDartEdgeAuthConfig() {
    final adminRoles = admin.normalizedAdminRoles;
    return DartEdgeAuthConfig(
      secret: secret,
      baseUrl: baseUrl,
      trustedOrigins: trustedOrigins,
      workerPoolSize: workerPoolSize,
      database: DartEdgeAuthDatabase.fromDatabase(
        database,
        schema: normalizedDatabaseSchema,
        manageMigrations: manageMigrations,
      ),
      basePath: betterAuthBasePath,
      appName: appName,
      enableEmailPassword: emailSignInEnabled || emailSignUpEnabled,
      enableSignup: emailSignUpEnabled,
      enablePasswordManagement: enablePasswordManagement,
      enableAccountManagement: enableAccountManagement,
      enableEmailVerification: enableEmailVerification,
      enableRateLimit: enableRateLimit,
      oauthProviders: ssoProviders
          .map((provider) => provider.toDartEdgeOAuthProviderConfig())
          .nonNulls
          .toList(growable: false),
      admin: admin.enabled
          ? DartEdgeAuthAdminConfig(
              adminRole: adminRoles.first,
              defaultUserRole: admin.defaultUserRole,
              allowBanAdmin: admin.allowBanAdmin,
              defaultPageLimit: admin.defaultPageLimit,
              maxPageLimit: admin.maxPageLimit,
            )
          : null,
    );
  }

  String? get normalizedDatabaseSchema {
    final schema = databaseSchema?.trim();
    if (schema == null || schema.isEmpty) {
      return null;
    }
    if (!_postgresIdentifierPattern.hasMatch(schema)) {
      throw ArgumentError.value(
        databaseSchema,
        'databaseSchema',
        'Must be an unquoted PostgreSQL identifier.',
      );
    }
    return schema;
  }
}

final _postgresIdentifierPattern = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

final class HippoAuthBackendAdminOptions {
  const HippoAuthBackendAdminOptions({
    this.enabled = true,
    this.adminRoles = const <String>['admin'],
    this.defaultUserRole = 'user',
    this.allowBanAdmin = false,
    this.defaultPageLimit = 100,
    this.maxPageLimit = 500,
  });

  final bool enabled;
  final List<String> adminRoles;
  final String defaultUserRole;
  final bool allowBanAdmin;
  final int defaultPageLimit;
  final int maxPageLimit;

  List<String> get normalizedAdminRoles {
    final roles = adminRoles
        .map((role) => role.trim())
        .where((role) => role.isNotEmpty)
        .toList(growable: false);
    return roles.isEmpty ? const <String>['admin'] : roles;
  }
}

enum HippoAuthSsoProviderType {
  genericOAuth('generic_oauth'),
  social('social');

  const HippoAuthSsoProviderType(this.jsonValue);

  final String jsonValue;
}

final class HippoAuthSsoProvider {
  const HippoAuthSsoProvider({
    required this.providerId,
    required this.providerType,
    this.clientId,
    this.clientSecret,
    this.authorizationUrl,
    this.tokenUrl,
    this.userInfoUrl,
    this.redirectUrl,
    this.scopes = const <String>['openid', 'email', 'profile'],
  });

  final String providerId;
  final HippoAuthSsoProviderType providerType;
  final String? clientId;
  final String? clientSecret;
  final String? authorizationUrl;
  final String? tokenUrl;
  final String? userInfoUrl;
  final String? redirectUrl;
  final List<String> scopes;

  Map<String, Object?> toJson() => {
    'provider_id': providerId,
    'provider_type': providerType.jsonValue,
  };

  DartEdgeAuthOAuthProviderConfig? toDartEdgeOAuthProviderConfig() {
    if (providerType != HippoAuthSsoProviderType.genericOAuth) {
      return null;
    }
    final normalizedProviderId = providerId.trim();
    final normalizedClientId = clientId?.trim();
    final normalizedClientSecret = clientSecret?.trim();
    final normalizedAuthorizationUrl = authorizationUrl?.trim();
    final normalizedTokenUrl = tokenUrl?.trim();
    final normalizedUserInfoUrl = userInfoUrl?.trim();
    if (normalizedProviderId.isEmpty ||
        normalizedClientId == null ||
        normalizedClientId.isEmpty ||
        normalizedAuthorizationUrl == null ||
        normalizedAuthorizationUrl.isEmpty ||
        normalizedTokenUrl == null ||
        normalizedTokenUrl.isEmpty) {
      return null;
    }
    return DartEdgeAuthOAuthProviderConfig(
      providerId: normalizedProviderId,
      clientId: normalizedClientId,
      clientSecret: normalizedClientSecret,
      authorizationUrl: normalizedAuthorizationUrl,
      tokenUrl: normalizedTokenUrl,
      userInfoUrl: normalizedUserInfoUrl == null || normalizedUserInfoUrl.isEmpty
          ? null
          : normalizedUserInfoUrl,
      scopes: scopes
          .map((scope) => scope.trim())
          .where((scope) => scope.isNotEmpty)
          .toList(growable: false),
    );
  }
}

final class HippoAuthBackendBranding {
  const HippoAuthBackendBranding({
    this.appName,
    this.appLogoUrl,
    this.supportEmail,
    this.footerText,
    this.imprintUrl,
    this.privacyUrl,
    this.termsOfServiceUrl,
    this.primaryColor = '#2563eb',
    this.backgroundColor = '#f6f7fb',
    this.surfaceColor = '#ffffff',
    this.textColor = '#111827',
    this.mutedTextColor = '#6b7280',
  });

  final String? appName;
  final String? appLogoUrl;
  final String? supportEmail;
  final String? footerText;
  final String? imprintUrl;
  final String? privacyUrl;
  final String? termsOfServiceUrl;
  final String primaryColor;
  final String backgroundColor;
  final String surfaceColor;
  final String textColor;
  final String mutedTextColor;
}
