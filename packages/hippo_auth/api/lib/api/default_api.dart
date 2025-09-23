//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class DefaultApi {
  DefaultApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'POST /v1/confirm_mail' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [ConfirmMailBody] confirmMailBody (required):
  Future<Response> v1ConfirmMailPostWithHttpInfo(ConfirmMailBody confirmMailBody,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/confirm_mail';

    // ignore: prefer_final_locals
    Object? postBody = confirmMailBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [ConfirmMailBody] confirmMailBody (required):
  Future<bool?> v1ConfirmMailPost(ConfirmMailBody confirmMailBody,) async {
    final response = await v1ConfirmMailPostWithHttpInfo(confirmMailBody,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'bool',) as bool;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /v1/get_user' operation and returns the [Response].
  Future<Response> v1GetUserGetWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/get_user';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  Future<GetUserResponse?> v1GetUserGet() async {
    final response = await v1GetUserGetWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetUserResponse',) as GetUserResponse;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /v1/refresh-session' operation and returns the [Response].
  Future<Response> v1RefreshSessionPostWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/refresh-session';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  Future<RefreshSessionResponse?> v1RefreshSessionPost() async {
    final response = await v1RefreshSessionPostWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RefreshSessionResponse',) as RefreshSessionResponse;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /v1/request-password-reset' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [RequestPasswordResetBody] requestPasswordResetBody (required):
  Future<Response> v1RequestPasswordResetPostWithHttpInfo(RequestPasswordResetBody requestPasswordResetBody,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/request-password-reset';

    // ignore: prefer_final_locals
    Object? postBody = requestPasswordResetBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [RequestPasswordResetBody] requestPasswordResetBody (required):
  Future<bool?> v1RequestPasswordResetPost(RequestPasswordResetBody requestPasswordResetBody,) async {
    final response = await v1RequestPasswordResetPostWithHttpInfo(requestPasswordResetBody,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'bool',) as bool;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /v1/reset-password' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [ResetPasswordBody] resetPasswordBody (required):
  Future<Response> v1ResetPasswordPostWithHttpInfo(ResetPasswordBody resetPasswordBody,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/reset-password';

    // ignore: prefer_final_locals
    Object? postBody = resetPasswordBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [ResetPasswordBody] resetPasswordBody (required):
  Future<bool?> v1ResetPasswordPost(ResetPasswordBody resetPasswordBody,) async {
    final response = await v1ResetPasswordPostWithHttpInfo(resetPasswordBody,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'bool',) as bool;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /v1/sign-in-email' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [SignInEmailBody] signInEmailBody (required):
  Future<Response> v1SignInEmailPostWithHttpInfo(SignInEmailBody signInEmailBody,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/sign-in-email';

    // ignore: prefer_final_locals
    Object? postBody = signInEmailBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [SignInEmailBody] signInEmailBody (required):
  Future<SignInEmailResponse?> v1SignInEmailPost(SignInEmailBody signInEmailBody,) async {
    final response = await v1SignInEmailPostWithHttpInfo(signInEmailBody,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SignInEmailResponse',) as SignInEmailResponse;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /v1/sign-in-sso' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [SignInSSOBody] signInSSOBody (required):
  Future<Response> v1SignInSsoPostWithHttpInfo(SignInSSOBody signInSSOBody,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/sign-in-sso';

    // ignore: prefer_final_locals
    Object? postBody = signInSSOBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [SignInSSOBody] signInSSOBody (required):
  Future<SignInSSOResponse?> v1SignInSsoPost(SignInSSOBody signInSSOBody,) async {
    final response = await v1SignInSsoPostWithHttpInfo(signInSSOBody,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SignInSSOResponse',) as SignInSSOResponse;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /v1/sign-up-email' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [SignUpEmailBody] signUpEmailBody (required):
  Future<Response> v1SignUpEmailPostWithHttpInfo(SignUpEmailBody signUpEmailBody,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/sign-up-email';

    // ignore: prefer_final_locals
    Object? postBody = signUpEmailBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [SignUpEmailBody] signUpEmailBody (required):
  Future<SignUpEmailResponse?> v1SignUpEmailPost(SignUpEmailBody signUpEmailBody,) async {
    final response = await v1SignUpEmailPostWithHttpInfo(signUpEmailBody,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SignUpEmailResponse',) as SignUpEmailResponse;
    
    }
    return null;
  }

  /// Performs an HTTP 'DELETE /v1oauth2/{*}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] star (required):
  Future<Response> v1oauth2DeleteWithHttpInfo(String star,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1oauth2/{*}'
      .replaceAll('{*}', star);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] star (required):
  Future<void> v1oauth2Delete(String star,) async {
    final response = await v1oauth2DeleteWithHttpInfo(star,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /v1oauth2/{*}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] star (required):
  Future<Response> v1oauth2GetWithHttpInfo(String star,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1oauth2/{*}'
      .replaceAll('{*}', star);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] star (required):
  Future<void> v1oauth2Get(String star,) async {
    final response = await v1oauth2GetWithHttpInfo(star,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'HEAD /v1oauth2/{*}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] star (required):
  Future<Response> v1oauth2HeadWithHttpInfo(String star,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1oauth2/{*}'
      .replaceAll('{*}', star);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'HEAD',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] star (required):
  Future<void> v1oauth2Head(String star,) async {
    final response = await v1oauth2HeadWithHttpInfo(star,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'OPTIONS /v1oauth2/{*}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] star (required):
  Future<Response> v1oauth2OptionsWithHttpInfo(String star,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1oauth2/{*}'
      .replaceAll('{*}', star);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'OPTIONS',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] star (required):
  Future<void> v1oauth2Options(String star,) async {
    final response = await v1oauth2OptionsWithHttpInfo(star,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'PATCH /v1oauth2/{*}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] star (required):
  Future<Response> v1oauth2PatchWithHttpInfo(String star,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1oauth2/{*}'
      .replaceAll('{*}', star);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] star (required):
  Future<void> v1oauth2Patch(String star,) async {
    final response = await v1oauth2PatchWithHttpInfo(star,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /v1oauth2/{*}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] star (required):
  Future<Response> v1oauth2PostWithHttpInfo(String star,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1oauth2/{*}'
      .replaceAll('{*}', star);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] star (required):
  Future<void> v1oauth2Post(String star,) async {
    final response = await v1oauth2PostWithHttpInfo(star,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'PUT /v1oauth2/{*}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] star (required):
  Future<Response> v1oauth2PutWithHttpInfo(String star,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1oauth2/{*}'
      .replaceAll('{*}', star);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] star (required):
  Future<void> v1oauth2Put(String star,) async {
    final response = await v1oauth2PutWithHttpInfo(star,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'TRACE /v1oauth2/{*}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] star (required):
  Future<Response> v1oauth2TraceWithHttpInfo(String star,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1oauth2/{*}'
      .replaceAll('{*}', star);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'TRACE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] star (required):
  Future<void> v1oauth2Trace(String star,) async {
    final response = await v1oauth2TraceWithHttpInfo(star,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
