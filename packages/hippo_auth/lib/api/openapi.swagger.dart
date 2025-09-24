// ignore_for_file: type=lint

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
  Future<chopper.Response<bool>> v1ConfirmMailPost({
    required V1ConfirmMailPost$RequestBody? body,
  }) {
    return _v1ConfirmMailPost(body: body);
  }

  ///
  @POST(path: '/v1/confirm_mail', optionalBody: true)
  Future<chopper.Response<bool>> _v1ConfirmMailPost({
    @Body() required V1ConfirmMailPost$RequestBody? body,
  });

  ///
  Future<chopper.Response<V1GetUserGet$Response>> v1GetUserGet() {
    generatedMapping.putIfAbsent(
      V1GetUserGet$Response,
      () => V1GetUserGet$Response.fromJsonFactory,
    );

    return _v1GetUserGet();
  }

  ///
  @GET(path: '/v1/get_user')
  Future<chopper.Response<V1GetUserGet$Response>> _v1GetUserGet();

  ///
  ///@param *
  Future<chopper.Response> v1oauth2Get({required String? undefinedParameter}) {
    return _v1oauth2Get(undefinedParameter: undefinedParameter);
  }

  ///
  ///@param *
  @GET(path: '/v1oauth2/{*}')
  Future<chopper.Response> _v1oauth2Get({
    @Path('*') required String? undefinedParameter,
  });

  ///
  ///@param *
  Future<chopper.Response> v1oauth2Head({required String? undefinedParameter}) {
    return _v1oauth2Head(undefinedParameter: undefinedParameter);
  }

  ///
  ///@param *
  @HEAD(path: '/v1oauth2/{*}')
  Future<chopper.Response> _v1oauth2Head({
    @Path('*') required String? undefinedParameter,
  });

  ///
  ///@param *
  Future<chopper.Response> v1oauth2Delete({
    required String? undefinedParameter,
  }) {
    return _v1oauth2Delete(undefinedParameter: undefinedParameter);
  }

  ///
  ///@param *
  @DELETE(path: '/v1oauth2/{*}')
  Future<chopper.Response> _v1oauth2Delete({
    @Path('*') required String? undefinedParameter,
  });

  ///
  ///@param *
  Future<chopper.Response> v1oauth2Patch({
    required String? undefinedParameter,
  }) {
    return _v1oauth2Patch(undefinedParameter: undefinedParameter);
  }

  ///
  ///@param *
  @PATCH(path: '/v1oauth2/{*}', optionalBody: true)
  Future<chopper.Response> _v1oauth2Patch({
    @Path('*') required String? undefinedParameter,
  });

  ///
  ///@param *
  Future<chopper.Response> v1oauth2Put({required String? undefinedParameter}) {
    return _v1oauth2Put(undefinedParameter: undefinedParameter);
  }

  ///
  ///@param *
  @PUT(path: '/v1oauth2/{*}', optionalBody: true)
  Future<chopper.Response> _v1oauth2Put({
    @Path('*') required String? undefinedParameter,
  });

  ///
  ///@param *
  Future<chopper.Response> v1oauth2Post({required String? undefinedParameter}) {
    return _v1oauth2Post(undefinedParameter: undefinedParameter);
  }

  ///
  ///@param *
  @POST(path: '/v1oauth2/{*}', optionalBody: true)
  Future<chopper.Response> _v1oauth2Post({
    @Path('*') required String? undefinedParameter,
  });

  ///
  Future<chopper.Response<V1RefreshSessionPost$Response>>
  v1RefreshSessionPost() {
    generatedMapping.putIfAbsent(
      V1RefreshSessionPost$Response,
      () => V1RefreshSessionPost$Response.fromJsonFactory,
    );

    return _v1RefreshSessionPost();
  }

  ///
  @POST(path: '/v1/refresh-session', optionalBody: true)
  Future<chopper.Response<V1RefreshSessionPost$Response>>
  _v1RefreshSessionPost();

  ///
  Future<chopper.Response<bool>> v1RequestPasswordResetPost({
    required V1RequestPasswordResetPost$RequestBody? body,
  }) {
    return _v1RequestPasswordResetPost(body: body);
  }

  ///
  @POST(path: '/v1/request-password-reset', optionalBody: true)
  Future<chopper.Response<bool>> _v1RequestPasswordResetPost({
    @Body() required V1RequestPasswordResetPost$RequestBody? body,
  });

  ///
  Future<chopper.Response<bool>> v1ResetPasswordPost({
    required V1ResetPasswordPost$RequestBody? body,
  }) {
    return _v1ResetPasswordPost(body: body);
  }

  ///
  @POST(path: '/v1/reset-password', optionalBody: true)
  Future<chopper.Response<bool>> _v1ResetPasswordPost({
    @Body() required V1ResetPasswordPost$RequestBody? body,
  });

  ///
  Future<chopper.Response<V1SignInEmailPost$Response>> v1SignInEmailPost({
    required V1SignInEmailPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      V1SignInEmailPost$Response,
      () => V1SignInEmailPost$Response.fromJsonFactory,
    );

    return _v1SignInEmailPost(body: body);
  }

  ///
  @POST(path: '/v1/sign-in-email', optionalBody: true)
  Future<chopper.Response<V1SignInEmailPost$Response>> _v1SignInEmailPost({
    @Body() required V1SignInEmailPost$RequestBody? body,
  });

  ///
  Future<chopper.Response<V1SignInSsoPost$Response>> v1SignInSsoPost({
    required V1SignInSsoPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      V1SignInSsoPost$Response,
      () => V1SignInSsoPost$Response.fromJsonFactory,
    );

    return _v1SignInSsoPost(body: body);
  }

  ///
  @POST(path: '/v1/sign-in-sso', optionalBody: true)
  Future<chopper.Response<V1SignInSsoPost$Response>> _v1SignInSsoPost({
    @Body() required V1SignInSsoPost$RequestBody? body,
  });

  ///
  Future<chopper.Response<V1SignUpEmailPost$Response>> v1SignUpEmailPost({
    required V1SignUpEmailPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      V1SignUpEmailPost$Response,
      () => V1SignUpEmailPost$Response.fromJsonFactory,
    );

    return _v1SignUpEmailPost(body: body);
  }

  ///
  @POST(path: '/v1/sign-up-email', optionalBody: true)
  Future<chopper.Response<V1SignUpEmailPost$Response>> _v1SignUpEmailPost({
    @Body() required V1SignUpEmailPost$RequestBody? body,
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
