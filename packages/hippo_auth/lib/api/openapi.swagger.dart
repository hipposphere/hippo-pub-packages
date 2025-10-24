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
import 'openapi.metadata.swagger.dart';
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

  ///
  Future<chopper.Response<bool>> v1UserConfirmMailPost({
    required V1UserConfirmMailPost$RequestBody? body,
  }) {
    return _v1UserConfirmMailPost(body: body);
  }

  ///
  @POST(path: '/v1/user/confirm_mail', optionalBody: true)
  Future<chopper.Response<bool>> _v1UserConfirmMailPost({
    @Body() required V1UserConfirmMailPost$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  });

  ///
  Future<chopper.Response<V1UserGetUserGet$Response>> v1UserGetUserGet() {
    generatedMapping.putIfAbsent(
      V1UserGetUserGet$Response,
      () => V1UserGetUserGet$Response.fromJsonFactory,
    );

    return _v1UserGetUserGet();
  }

  ///
  @GET(path: '/v1/user/get_user')
  Future<chopper.Response<V1UserGetUserGet$Response>> _v1UserGetUserGet({
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  });

  ///
  Future<chopper.Response<V1UserLogoutGet$Response>> v1UserLogoutGet() {
    generatedMapping.putIfAbsent(
      V1UserLogoutGet$Response,
      () => V1UserLogoutGet$Response.fromJsonFactory,
    );

    return _v1UserLogoutGet();
  }

  ///
  @GET(path: '/v1/user/logout')
  Future<chopper.Response<V1UserLogoutGet$Response>> _v1UserLogoutGet({
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  });

  ///
  Future<chopper.Response<V1UserRefreshSessionPost$Response>>
  v1UserRefreshSessionPost() {
    generatedMapping.putIfAbsent(
      V1UserRefreshSessionPost$Response,
      () => V1UserRefreshSessionPost$Response.fromJsonFactory,
    );

    return _v1UserRefreshSessionPost();
  }

  ///
  @POST(path: '/v1/user/refresh-session', optionalBody: true)
  Future<chopper.Response<V1UserRefreshSessionPost$Response>>
  _v1UserRefreshSessionPost({
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  });

  ///
  Future<chopper.Response<bool>> v1UserRequestPasswordResetPost({
    required V1UserRequestPasswordResetPost$RequestBody? body,
  }) {
    return _v1UserRequestPasswordResetPost(body: body);
  }

  ///
  @POST(path: '/v1/user/request-password-reset', optionalBody: true)
  Future<chopper.Response<bool>> _v1UserRequestPasswordResetPost({
    @Body() required V1UserRequestPasswordResetPost$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  });

  ///
  Future<chopper.Response<bool>> v1UserResetPasswordPost({
    required V1UserResetPasswordPost$RequestBody? body,
  }) {
    return _v1UserResetPasswordPost(body: body);
  }

  ///
  @POST(path: '/v1/user/reset-password', optionalBody: true)
  Future<chopper.Response<bool>> _v1UserResetPasswordPost({
    @Body() required V1UserResetPasswordPost$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  });

  ///
  Future<chopper.Response<V1UserSignInEmailPost$Response>>
  v1UserSignInEmailPost({required V1UserSignInEmailPost$RequestBody? body}) {
    generatedMapping.putIfAbsent(
      V1UserSignInEmailPost$Response,
      () => V1UserSignInEmailPost$Response.fromJsonFactory,
    );

    return _v1UserSignInEmailPost(body: body);
  }

  ///
  @POST(path: '/v1/user/sign-in-email', optionalBody: true)
  Future<chopper.Response<V1UserSignInEmailPost$Response>>
  _v1UserSignInEmailPost({
    @Body() required V1UserSignInEmailPost$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  });

  ///
  Future<chopper.Response<V1UserSignInSsoPost$Response>> v1UserSignInSsoPost({
    required V1UserSignInSsoPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      V1UserSignInSsoPost$Response,
      () => V1UserSignInSsoPost$Response.fromJsonFactory,
    );

    return _v1UserSignInSsoPost(body: body);
  }

  ///
  @POST(path: '/v1/user/sign-in-sso', optionalBody: true)
  Future<chopper.Response<V1UserSignInSsoPost$Response>> _v1UserSignInSsoPost({
    @Body() required V1UserSignInSsoPost$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  });

  ///
  Future<chopper.Response<V1UserSignUpEmailPost$Response>>
  v1UserSignUpEmailPost({required V1UserSignUpEmailPost$RequestBody? body}) {
    generatedMapping.putIfAbsent(
      V1UserSignUpEmailPost$Response,
      () => V1UserSignUpEmailPost$Response.fromJsonFactory,
    );

    return _v1UserSignUpEmailPost(body: body);
  }

  ///
  @POST(path: '/v1/user/sign-up-email', optionalBody: true)
  Future<chopper.Response<V1UserSignUpEmailPost$Response>>
  _v1UserSignUpEmailPost({
    @Body() required V1UserSignUpEmailPost$RequestBody? body,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  });

  ///
  ///@param providerId
  Future<chopper.Response> v1Oauth2CallbackProviderIdGet({
    required String? providerId,
  }) {
    return _v1Oauth2CallbackProviderIdGet(providerId: providerId);
  }

  ///
  ///@param providerId
  @GET(path: '/v1/oauth2/callback/{providerId}')
  Future<chopper.Response> _v1Oauth2CallbackProviderIdGet({
    @Path('providerId') required String? providerId,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  });

  ///
  ///@param providerId
  Future<chopper.Response> v1Oauth2SignInProviderIdGet({
    required String? providerId,
  }) {
    return _v1Oauth2SignInProviderIdGet(providerId: providerId);
  }

  ///
  ///@param providerId
  @GET(path: '/v1/oauth2/sign-in/{providerId}')
  Future<chopper.Response> _v1Oauth2SignInProviderIdGet({
    @Path('providerId') required String? providerId,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  });

  ///
  Future<chopper.Response> viewsResetPasswordGet() {
    return _viewsResetPasswordGet();
  }

  ///
  @GET(path: '/views/reset-password')
  Future<chopper.Response> _viewsResetPasswordGet({
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  });

  ///
  Future<chopper.Response> viewsConfirmMailGet() {
    return _viewsConfirmMailGet();
  }

  ///
  @GET(path: '/views/confirm-mail')
  Future<chopper.Response> _viewsConfirmMailGet({
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
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
