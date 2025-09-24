// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';
import 'dart:convert';

part 'openapi.models.swagger.g.dart';

@JsonSerializable(explicitToJson: true)
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.emailVerified,
    required this.name,
    this.image,
    this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);

  static const toJsonFactory = _$AuthUserToJson;
  Map<String, dynamic> toJson() => _$AuthUserToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'emailVerified', includeIfNull: false)
  final bool emailVerified;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'image', includeIfNull: false)
  final String? image;
  @JsonKey(name: 'role', includeIfNull: false)
  final String? role;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  final DateTime updatedAt;
  static const fromJsonFactory = _$AuthUserFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AuthUser &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.emailVerified, emailVerified) ||
                const DeepCollectionEquality().equals(
                  other.emailVerified,
                  emailVerified,
                )) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.image, image) ||
                const DeepCollectionEquality().equals(other.image, image)) &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(emailVerified) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(image) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $AuthUserExtension on AuthUser {
  AuthUser copyWith({
    String? id,
    String? email,
    bool? emailVerified,
    String? name,
    String? image,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      name: name ?? this.name,
      image: image ?? this.image,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  AuthUser copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? email,
    Wrapped<bool>? emailVerified,
    Wrapped<String>? name,
    Wrapped<String?>? image,
    Wrapped<String?>? role,
    Wrapped<DateTime>? createdAt,
    Wrapped<DateTime>? updatedAt,
  }) {
    return AuthUser(
      id: (id != null ? id.value : this.id),
      email: (email != null ? email.value : this.email),
      emailVerified: (emailVerified != null
          ? emailVerified.value
          : this.emailVerified),
      name: (name != null ? name.value : this.name),
      image: (image != null ? image.value : this.image),
      role: (role != null ? role.value : this.role),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Def0 {
  const Def0({required this.error, required this.message});

  factory Def0.fromJson(Map<String, dynamic> json) => _$Def0FromJson(json);

  static const toJsonFactory = _$Def0ToJson;
  Map<String, dynamic> toJson() => _$Def0ToJson(this);

  @JsonKey(name: 'error', includeIfNull: false)
  final String error;
  @JsonKey(name: 'message', includeIfNull: false)
  final String message;
  static const fromJsonFactory = _$Def0FromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Def0 &&
            (identical(other.error, error) ||
                const DeepCollectionEquality().equals(other.error, error)) &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(other.message, message)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(error) ^
      const DeepCollectionEquality().hash(message) ^
      runtimeType.hashCode;
}

extension $Def0Extension on Def0 {
  Def0 copyWith({String? error, String? message}) {
    return Def0(error: error ?? this.error, message: message ?? this.message);
  }

  Def0 copyWithWrapped({Wrapped<String>? error, Wrapped<String>? message}) {
    return Def0(
      error: (error != null ? error.value : this.error),
      message: (message != null ? message.value : this.message),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1ConfirmMailPost$RequestBody {
  const V1ConfirmMailPost$RequestBody({required this.token});

  factory V1ConfirmMailPost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$V1ConfirmMailPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1ConfirmMailPost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$V1ConfirmMailPost$RequestBodyToJson(this);

  @JsonKey(name: 'token', includeIfNull: false)
  final String token;
  static const fromJsonFactory = _$V1ConfirmMailPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1ConfirmMailPost$RequestBody &&
            (identical(other.token, token) ||
                const DeepCollectionEquality().equals(other.token, token)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(token) ^ runtimeType.hashCode;
}

extension $V1ConfirmMailPost$RequestBodyExtension
    on V1ConfirmMailPost$RequestBody {
  V1ConfirmMailPost$RequestBody copyWith({String? token}) {
    return V1ConfirmMailPost$RequestBody(token: token ?? this.token);
  }

  V1ConfirmMailPost$RequestBody copyWithWrapped({Wrapped<String>? token}) {
    return V1ConfirmMailPost$RequestBody(
      token: (token != null ? token.value : this.token),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1RequestPasswordResetPost$RequestBody {
  const V1RequestPasswordResetPost$RequestBody({required this.email});

  factory V1RequestPasswordResetPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$V1RequestPasswordResetPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1RequestPasswordResetPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1RequestPasswordResetPost$RequestBodyToJson(this);

  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  static const fromJsonFactory =
      _$V1RequestPasswordResetPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1RequestPasswordResetPost$RequestBody &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^ runtimeType.hashCode;
}

extension $V1RequestPasswordResetPost$RequestBodyExtension
    on V1RequestPasswordResetPost$RequestBody {
  V1RequestPasswordResetPost$RequestBody copyWith({String? email}) {
    return V1RequestPasswordResetPost$RequestBody(email: email ?? this.email);
  }

  V1RequestPasswordResetPost$RequestBody copyWithWrapped({
    Wrapped<String>? email,
  }) {
    return V1RequestPasswordResetPost$RequestBody(
      email: (email != null ? email.value : this.email),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1ResetPasswordPost$RequestBody {
  const V1ResetPasswordPost$RequestBody({
    required this.token,
    required this.newPassword,
  });

  factory V1ResetPasswordPost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$V1ResetPasswordPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1ResetPasswordPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1ResetPasswordPost$RequestBodyToJson(this);

  @JsonKey(name: 'token', includeIfNull: false)
  final String token;
  @JsonKey(name: 'new_password', includeIfNull: false)
  final String newPassword;
  static const fromJsonFactory = _$V1ResetPasswordPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1ResetPasswordPost$RequestBody &&
            (identical(other.token, token) ||
                const DeepCollectionEquality().equals(other.token, token)) &&
            (identical(other.newPassword, newPassword) ||
                const DeepCollectionEquality().equals(
                  other.newPassword,
                  newPassword,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(token) ^
      const DeepCollectionEquality().hash(newPassword) ^
      runtimeType.hashCode;
}

extension $V1ResetPasswordPost$RequestBodyExtension
    on V1ResetPasswordPost$RequestBody {
  V1ResetPasswordPost$RequestBody copyWith({
    String? token,
    String? newPassword,
  }) {
    return V1ResetPasswordPost$RequestBody(
      token: token ?? this.token,
      newPassword: newPassword ?? this.newPassword,
    );
  }

  V1ResetPasswordPost$RequestBody copyWithWrapped({
    Wrapped<String>? token,
    Wrapped<String>? newPassword,
  }) {
    return V1ResetPasswordPost$RequestBody(
      token: (token != null ? token.value : this.token),
      newPassword: (newPassword != null ? newPassword.value : this.newPassword),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1SignInEmailPost$RequestBody {
  const V1SignInEmailPost$RequestBody({
    required this.email,
    required this.password,
  });

  factory V1SignInEmailPost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$V1SignInEmailPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1SignInEmailPost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$V1SignInEmailPost$RequestBodyToJson(this);

  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'password', includeIfNull: false)
  final String password;
  static const fromJsonFactory = _$V1SignInEmailPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1SignInEmailPost$RequestBody &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.password, password) ||
                const DeepCollectionEquality().equals(
                  other.password,
                  password,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(password) ^
      runtimeType.hashCode;
}

extension $V1SignInEmailPost$RequestBodyExtension
    on V1SignInEmailPost$RequestBody {
  V1SignInEmailPost$RequestBody copyWith({String? email, String? password}) {
    return V1SignInEmailPost$RequestBody(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  V1SignInEmailPost$RequestBody copyWithWrapped({
    Wrapped<String>? email,
    Wrapped<String>? password,
  }) {
    return V1SignInEmailPost$RequestBody(
      email: (email != null ? email.value : this.email),
      password: (password != null ? password.value : this.password),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1SignInSsoPost$RequestBody {
  const V1SignInSsoPost$RequestBody({
    required this.providerId,
    required this.successUrl,
  });

  factory V1SignInSsoPost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$V1SignInSsoPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1SignInSsoPost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$V1SignInSsoPost$RequestBodyToJson(this);

  @JsonKey(name: 'provider_id', includeIfNull: false)
  final String providerId;
  @JsonKey(name: 'success_url', includeIfNull: false)
  final String successUrl;
  static const fromJsonFactory = _$V1SignInSsoPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1SignInSsoPost$RequestBody &&
            (identical(other.providerId, providerId) ||
                const DeepCollectionEquality().equals(
                  other.providerId,
                  providerId,
                )) &&
            (identical(other.successUrl, successUrl) ||
                const DeepCollectionEquality().equals(
                  other.successUrl,
                  successUrl,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(providerId) ^
      const DeepCollectionEquality().hash(successUrl) ^
      runtimeType.hashCode;
}

extension $V1SignInSsoPost$RequestBodyExtension on V1SignInSsoPost$RequestBody {
  V1SignInSsoPost$RequestBody copyWith({
    String? providerId,
    String? successUrl,
  }) {
    return V1SignInSsoPost$RequestBody(
      providerId: providerId ?? this.providerId,
      successUrl: successUrl ?? this.successUrl,
    );
  }

  V1SignInSsoPost$RequestBody copyWithWrapped({
    Wrapped<String>? providerId,
    Wrapped<String>? successUrl,
  }) {
    return V1SignInSsoPost$RequestBody(
      providerId: (providerId != null ? providerId.value : this.providerId),
      successUrl: (successUrl != null ? successUrl.value : this.successUrl),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1SignUpEmailPost$RequestBody {
  const V1SignUpEmailPost$RequestBody({
    required this.name,
    required this.email,
    required this.password,
  });

  factory V1SignUpEmailPost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$V1SignUpEmailPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1SignUpEmailPost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$V1SignUpEmailPost$RequestBodyToJson(this);

  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'password', includeIfNull: false)
  final String password;
  static const fromJsonFactory = _$V1SignUpEmailPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1SignUpEmailPost$RequestBody &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.password, password) ||
                const DeepCollectionEquality().equals(
                  other.password,
                  password,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(password) ^
      runtimeType.hashCode;
}

extension $V1SignUpEmailPost$RequestBodyExtension
    on V1SignUpEmailPost$RequestBody {
  V1SignUpEmailPost$RequestBody copyWith({
    String? name,
    String? email,
    String? password,
  }) {
    return V1SignUpEmailPost$RequestBody(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  V1SignUpEmailPost$RequestBody copyWithWrapped({
    Wrapped<String>? name,
    Wrapped<String>? email,
    Wrapped<String>? password,
  }) {
    return V1SignUpEmailPost$RequestBody(
      name: (name != null ? name.value : this.name),
      email: (email != null ? email.value : this.email),
      password: (password != null ? password.value : this.password),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1GetUserGet$Response {
  const V1GetUserGet$Response({required this.user});

  factory V1GetUserGet$Response.fromJson(Map<String, dynamic> json) =>
      _$V1GetUserGet$ResponseFromJson(json);

  static const toJsonFactory = _$V1GetUserGet$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1GetUserGet$ResponseToJson(this);

  @JsonKey(name: 'user', includeIfNull: false)
  final AuthUser user;
  static const fromJsonFactory = _$V1GetUserGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1GetUserGet$Response &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(user) ^ runtimeType.hashCode;
}

extension $V1GetUserGet$ResponseExtension on V1GetUserGet$Response {
  V1GetUserGet$Response copyWith({AuthUser? user}) {
    return V1GetUserGet$Response(user: user ?? this.user);
  }

  V1GetUserGet$Response copyWithWrapped({Wrapped<AuthUser>? user}) {
    return V1GetUserGet$Response(user: (user != null ? user.value : this.user));
  }
}

@JsonSerializable(explicitToJson: true)
class V1RefreshSessionPost$Response {
  const V1RefreshSessionPost$Response({this.expiresAt});

  factory V1RefreshSessionPost$Response.fromJson(Map<String, dynamic> json) =>
      _$V1RefreshSessionPost$ResponseFromJson(json);

  static const toJsonFactory = _$V1RefreshSessionPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1RefreshSessionPost$ResponseToJson(this);

  @JsonKey(name: 'expires_at', includeIfNull: false)
  final DateTime? expiresAt;
  static const fromJsonFactory = _$V1RefreshSessionPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1RefreshSessionPost$Response &&
            (identical(other.expiresAt, expiresAt) ||
                const DeepCollectionEquality().equals(
                  other.expiresAt,
                  expiresAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(expiresAt) ^ runtimeType.hashCode;
}

extension $V1RefreshSessionPost$ResponseExtension
    on V1RefreshSessionPost$Response {
  V1RefreshSessionPost$Response copyWith({DateTime? expiresAt}) {
    return V1RefreshSessionPost$Response(
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  V1RefreshSessionPost$Response copyWithWrapped({
    Wrapped<DateTime?>? expiresAt,
  }) {
    return V1RefreshSessionPost$Response(
      expiresAt: (expiresAt != null ? expiresAt.value : this.expiresAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1SignInEmailPost$Response {
  const V1SignInEmailPost$Response({
    required this.sessionId,
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  factory V1SignInEmailPost$Response.fromJson(Map<String, dynamic> json) =>
      _$V1SignInEmailPost$ResponseFromJson(json);

  static const toJsonFactory = _$V1SignInEmailPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1SignInEmailPost$ResponseToJson(this);

  @JsonKey(name: 'session_id', includeIfNull: false)
  final String sessionId;
  @JsonKey(name: 'token', includeIfNull: false)
  final String token;
  @JsonKey(name: 'expires_at', includeIfNull: false)
  final DateTime expiresAt;
  @JsonKey(name: 'user', includeIfNull: false)
  final AuthUser user;
  static const fromJsonFactory = _$V1SignInEmailPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1SignInEmailPost$Response &&
            (identical(other.sessionId, sessionId) ||
                const DeepCollectionEquality().equals(
                  other.sessionId,
                  sessionId,
                )) &&
            (identical(other.token, token) ||
                const DeepCollectionEquality().equals(other.token, token)) &&
            (identical(other.expiresAt, expiresAt) ||
                const DeepCollectionEquality().equals(
                  other.expiresAt,
                  expiresAt,
                )) &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(sessionId) ^
      const DeepCollectionEquality().hash(token) ^
      const DeepCollectionEquality().hash(expiresAt) ^
      const DeepCollectionEquality().hash(user) ^
      runtimeType.hashCode;
}

extension $V1SignInEmailPost$ResponseExtension on V1SignInEmailPost$Response {
  V1SignInEmailPost$Response copyWith({
    String? sessionId,
    String? token,
    DateTime? expiresAt,
    AuthUser? user,
  }) {
    return V1SignInEmailPost$Response(
      sessionId: sessionId ?? this.sessionId,
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
      user: user ?? this.user,
    );
  }

  V1SignInEmailPost$Response copyWithWrapped({
    Wrapped<String>? sessionId,
    Wrapped<String>? token,
    Wrapped<DateTime>? expiresAt,
    Wrapped<AuthUser>? user,
  }) {
    return V1SignInEmailPost$Response(
      sessionId: (sessionId != null ? sessionId.value : this.sessionId),
      token: (token != null ? token.value : this.token),
      expiresAt: (expiresAt != null ? expiresAt.value : this.expiresAt),
      user: (user != null ? user.value : this.user),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1SignInSsoPost$Response {
  const V1SignInSsoPost$Response({required this.success, required this.data});

  factory V1SignInSsoPost$Response.fromJson(Map<String, dynamic> json) =>
      _$V1SignInSsoPost$ResponseFromJson(json);

  static const toJsonFactory = _$V1SignInSsoPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1SignInSsoPost$ResponseToJson(this);

  @JsonKey(name: 'success', includeIfNull: false)
  final bool success;
  @JsonKey(name: 'data', includeIfNull: false)
  final V1SignInSsoPost$Response$Data data;
  static const fromJsonFactory = _$V1SignInSsoPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1SignInSsoPost$Response &&
            (identical(other.success, success) ||
                const DeepCollectionEquality().equals(
                  other.success,
                  success,
                )) &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(success) ^
      const DeepCollectionEquality().hash(data) ^
      runtimeType.hashCode;
}

extension $V1SignInSsoPost$ResponseExtension on V1SignInSsoPost$Response {
  V1SignInSsoPost$Response copyWith({
    bool? success,
    V1SignInSsoPost$Response$Data? data,
  }) {
    return V1SignInSsoPost$Response(
      success: success ?? this.success,
      data: data ?? this.data,
    );
  }

  V1SignInSsoPost$Response copyWithWrapped({
    Wrapped<bool>? success,
    Wrapped<V1SignInSsoPost$Response$Data>? data,
  }) {
    return V1SignInSsoPost$Response(
      success: (success != null ? success.value : this.success),
      data: (data != null ? data.value : this.data),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1SignUpEmailPost$Response {
  const V1SignUpEmailPost$Response({
    required this.sessionId,
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  factory V1SignUpEmailPost$Response.fromJson(Map<String, dynamic> json) =>
      _$V1SignUpEmailPost$ResponseFromJson(json);

  static const toJsonFactory = _$V1SignUpEmailPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1SignUpEmailPost$ResponseToJson(this);

  @JsonKey(name: 'session_id', includeIfNull: false)
  final String sessionId;
  @JsonKey(name: 'token', includeIfNull: false)
  final String token;
  @JsonKey(name: 'expires_at', includeIfNull: false)
  final DateTime expiresAt;
  @JsonKey(name: 'user', includeIfNull: false)
  final AuthUser user;
  static const fromJsonFactory = _$V1SignUpEmailPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1SignUpEmailPost$Response &&
            (identical(other.sessionId, sessionId) ||
                const DeepCollectionEquality().equals(
                  other.sessionId,
                  sessionId,
                )) &&
            (identical(other.token, token) ||
                const DeepCollectionEquality().equals(other.token, token)) &&
            (identical(other.expiresAt, expiresAt) ||
                const DeepCollectionEquality().equals(
                  other.expiresAt,
                  expiresAt,
                )) &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(sessionId) ^
      const DeepCollectionEquality().hash(token) ^
      const DeepCollectionEquality().hash(expiresAt) ^
      const DeepCollectionEquality().hash(user) ^
      runtimeType.hashCode;
}

extension $V1SignUpEmailPost$ResponseExtension on V1SignUpEmailPost$Response {
  V1SignUpEmailPost$Response copyWith({
    String? sessionId,
    String? token,
    DateTime? expiresAt,
    AuthUser? user,
  }) {
    return V1SignUpEmailPost$Response(
      sessionId: sessionId ?? this.sessionId,
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
      user: user ?? this.user,
    );
  }

  V1SignUpEmailPost$Response copyWithWrapped({
    Wrapped<String>? sessionId,
    Wrapped<String>? token,
    Wrapped<DateTime>? expiresAt,
    Wrapped<AuthUser>? user,
  }) {
    return V1SignUpEmailPost$Response(
      sessionId: (sessionId != null ? sessionId.value : this.sessionId),
      token: (token != null ? token.value : this.token),
      expiresAt: (expiresAt != null ? expiresAt.value : this.expiresAt),
      user: (user != null ? user.value : this.user),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1SignInSsoPost$Response$Data {
  const V1SignInSsoPost$Response$Data({
    required this.redirectUrl,
    required this.providerId,
  });

  factory V1SignInSsoPost$Response$Data.fromJson(Map<String, dynamic> json) =>
      _$V1SignInSsoPost$Response$DataFromJson(json);

  static const toJsonFactory = _$V1SignInSsoPost$Response$DataToJson;
  Map<String, dynamic> toJson() => _$V1SignInSsoPost$Response$DataToJson(this);

  @JsonKey(name: 'redirectUrl', includeIfNull: false)
  final String redirectUrl;
  @JsonKey(name: 'providerId', includeIfNull: false)
  final String providerId;
  static const fromJsonFactory = _$V1SignInSsoPost$Response$DataFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1SignInSsoPost$Response$Data &&
            (identical(other.redirectUrl, redirectUrl) ||
                const DeepCollectionEquality().equals(
                  other.redirectUrl,
                  redirectUrl,
                )) &&
            (identical(other.providerId, providerId) ||
                const DeepCollectionEquality().equals(
                  other.providerId,
                  providerId,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(redirectUrl) ^
      const DeepCollectionEquality().hash(providerId) ^
      runtimeType.hashCode;
}

extension $V1SignInSsoPost$Response$DataExtension
    on V1SignInSsoPost$Response$Data {
  V1SignInSsoPost$Response$Data copyWith({
    String? redirectUrl,
    String? providerId,
  }) {
    return V1SignInSsoPost$Response$Data(
      redirectUrl: redirectUrl ?? this.redirectUrl,
      providerId: providerId ?? this.providerId,
    );
  }

  V1SignInSsoPost$Response$Data copyWithWrapped({
    Wrapped<String>? redirectUrl,
    Wrapped<String>? providerId,
  }) {
    return V1SignInSsoPost$Response$Data(
      redirectUrl: (redirectUrl != null ? redirectUrl.value : this.redirectUrl),
      providerId: (providerId != null ? providerId.value : this.providerId),
    );
  }
}

// ignore: unused_element
String? _dateToJson(DateTime? date) {
  if (date == null) {
    return null;
  }

  final year = date.year.toString();
  final month = date.month < 10 ? '0${date.month}' : date.month.toString();
  final day = date.day < 10 ? '0${date.day}' : date.day.toString();

  return '$year-$month-$day';
}

class Wrapped<T> {
  final T value;
  const Wrapped.value(this.value);
}
