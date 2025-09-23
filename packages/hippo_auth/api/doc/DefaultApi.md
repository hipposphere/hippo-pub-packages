# hippo_auth_server_api.api.DefaultApi

## Load the API package
```dart
import 'package:hippo_auth_server_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**v1ConfirmMailPost**](DefaultApi.md#v1confirmmailpost) | **POST** /v1/confirm_mail | 
[**v1GetUserGet**](DefaultApi.md#v1getuserget) | **GET** /v1/get_user | 
[**v1RefreshSessionPost**](DefaultApi.md#v1refreshsessionpost) | **POST** /v1/refresh-session | 
[**v1RequestPasswordResetPost**](DefaultApi.md#v1requestpasswordresetpost) | **POST** /v1/request-password-reset | 
[**v1ResetPasswordPost**](DefaultApi.md#v1resetpasswordpost) | **POST** /v1/reset-password | 
[**v1SignInEmailPost**](DefaultApi.md#v1signinemailpost) | **POST** /v1/sign-in-email | 
[**v1SignInSsoPost**](DefaultApi.md#v1signinssopost) | **POST** /v1/sign-in-sso | 
[**v1SignUpEmailPost**](DefaultApi.md#v1signupemailpost) | **POST** /v1/sign-up-email | 
[**v1oauth2Delete**](DefaultApi.md#v1oauth2delete) | **DELETE** /v1oauth2/{*} | 
[**v1oauth2Get**](DefaultApi.md#v1oauth2get) | **GET** /v1oauth2/{*} | 
[**v1oauth2Head**](DefaultApi.md#v1oauth2head) | **HEAD** /v1oauth2/{*} | 
[**v1oauth2Options**](DefaultApi.md#v1oauth2options) | **OPTIONS** /v1oauth2/{*} | 
[**v1oauth2Patch**](DefaultApi.md#v1oauth2patch) | **PATCH** /v1oauth2/{*} | 
[**v1oauth2Post**](DefaultApi.md#v1oauth2post) | **POST** /v1oauth2/{*} | 
[**v1oauth2Put**](DefaultApi.md#v1oauth2put) | **PUT** /v1oauth2/{*} | 
[**v1oauth2Trace**](DefaultApi.md#v1oauth2trace) | **TRACE** /v1oauth2/{*} | 


# **v1ConfirmMailPost**
> bool v1ConfirmMailPost(confirmMailBody)



### Example
```dart
import 'package:hippo_auth_server_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final confirmMailBody = ConfirmMailBody(); // ConfirmMailBody | 

try {
    final result = api_instance.v1ConfirmMailPost(confirmMailBody);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->v1ConfirmMailPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **confirmMailBody** | [**ConfirmMailBody**](ConfirmMailBody.md)|  | 

### Return type

**bool**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1GetUserGet**
> GetUserResponse v1GetUserGet()



### Example
```dart
import 'package:hippo_auth_server_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();

try {
    final result = api_instance.v1GetUserGet();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->v1GetUserGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GetUserResponse**](GetUserResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1RefreshSessionPost**
> RefreshSessionResponse v1RefreshSessionPost()



### Example
```dart
import 'package:hippo_auth_server_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();

try {
    final result = api_instance.v1RefreshSessionPost();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->v1RefreshSessionPost: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**RefreshSessionResponse**](RefreshSessionResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1RequestPasswordResetPost**
> bool v1RequestPasswordResetPost(requestPasswordResetBody)



### Example
```dart
import 'package:hippo_auth_server_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final requestPasswordResetBody = RequestPasswordResetBody(); // RequestPasswordResetBody | 

try {
    final result = api_instance.v1RequestPasswordResetPost(requestPasswordResetBody);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->v1RequestPasswordResetPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **requestPasswordResetBody** | [**RequestPasswordResetBody**](RequestPasswordResetBody.md)|  | 

### Return type

**bool**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1ResetPasswordPost**
> bool v1ResetPasswordPost(resetPasswordBody)



### Example
```dart
import 'package:hippo_auth_server_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final resetPasswordBody = ResetPasswordBody(); // ResetPasswordBody | 

try {
    final result = api_instance.v1ResetPasswordPost(resetPasswordBody);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->v1ResetPasswordPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **resetPasswordBody** | [**ResetPasswordBody**](ResetPasswordBody.md)|  | 

### Return type

**bool**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1SignInEmailPost**
> SignInEmailResponse v1SignInEmailPost(signInEmailBody)



### Example
```dart
import 'package:hippo_auth_server_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final signInEmailBody = SignInEmailBody(); // SignInEmailBody | 

try {
    final result = api_instance.v1SignInEmailPost(signInEmailBody);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->v1SignInEmailPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **signInEmailBody** | [**SignInEmailBody**](SignInEmailBody.md)|  | 

### Return type

[**SignInEmailResponse**](SignInEmailResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1SignInSsoPost**
> SignInSSOResponse v1SignInSsoPost(signInSSOBody)



### Example
```dart
import 'package:hippo_auth_server_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final signInSSOBody = SignInSSOBody(); // SignInSSOBody | 

try {
    final result = api_instance.v1SignInSsoPost(signInSSOBody);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->v1SignInSsoPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **signInSSOBody** | [**SignInSSOBody**](SignInSSOBody.md)|  | 

### Return type

[**SignInSSOResponse**](SignInSSOResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1SignUpEmailPost**
> SignUpEmailResponse v1SignUpEmailPost(signUpEmailBody)



### Example
```dart
import 'package:hippo_auth_server_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final signUpEmailBody = SignUpEmailBody(); // SignUpEmailBody | 

try {
    final result = api_instance.v1SignUpEmailPost(signUpEmailBody);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->v1SignUpEmailPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **signUpEmailBody** | [**SignUpEmailBody**](SignUpEmailBody.md)|  | 

### Return type

[**SignUpEmailResponse**](SignUpEmailResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1oauth2Delete**
> v1oauth2Delete(star)



### Example
```dart
import 'package:hippo_auth_server_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final star = star_example; // String | 

try {
    api_instance.v1oauth2Delete(star);
} catch (e) {
    print('Exception when calling DefaultApi->v1oauth2Delete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **star** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1oauth2Get**
> v1oauth2Get(star)



### Example
```dart
import 'package:hippo_auth_server_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final star = star_example; // String | 

try {
    api_instance.v1oauth2Get(star);
} catch (e) {
    print('Exception when calling DefaultApi->v1oauth2Get: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **star** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1oauth2Head**
> v1oauth2Head(star)



### Example
```dart
import 'package:hippo_auth_server_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final star = star_example; // String | 

try {
    api_instance.v1oauth2Head(star);
} catch (e) {
    print('Exception when calling DefaultApi->v1oauth2Head: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **star** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1oauth2Options**
> v1oauth2Options(star)



### Example
```dart
import 'package:hippo_auth_server_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final star = star_example; // String | 

try {
    api_instance.v1oauth2Options(star);
} catch (e) {
    print('Exception when calling DefaultApi->v1oauth2Options: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **star** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1oauth2Patch**
> v1oauth2Patch(star)



### Example
```dart
import 'package:hippo_auth_server_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final star = star_example; // String | 

try {
    api_instance.v1oauth2Patch(star);
} catch (e) {
    print('Exception when calling DefaultApi->v1oauth2Patch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **star** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1oauth2Post**
> v1oauth2Post(star)



### Example
```dart
import 'package:hippo_auth_server_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final star = star_example; // String | 

try {
    api_instance.v1oauth2Post(star);
} catch (e) {
    print('Exception when calling DefaultApi->v1oauth2Post: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **star** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1oauth2Put**
> v1oauth2Put(star)



### Example
```dart
import 'package:hippo_auth_server_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final star = star_example; // String | 

try {
    api_instance.v1oauth2Put(star);
} catch (e) {
    print('Exception when calling DefaultApi->v1oauth2Put: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **star** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1oauth2Trace**
> v1oauth2Trace(star)



### Example
```dart
import 'package:hippo_auth_server_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final star = star_example; // String | 

try {
    api_instance.v1oauth2Trace(star);
} catch (e) {
    print('Exception when calling DefaultApi->v1oauth2Trace: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **star** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

