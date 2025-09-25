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
class V1UserConfirmMailPost$RequestBody {
  const V1UserConfirmMailPost$RequestBody({required this.token});

  factory V1UserConfirmMailPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$V1UserConfirmMailPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1UserConfirmMailPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1UserConfirmMailPost$RequestBodyToJson(this);

  @JsonKey(name: 'token', includeIfNull: false)
  final String token;
  static const fromJsonFactory = _$V1UserConfirmMailPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserConfirmMailPost$RequestBody &&
            (identical(other.token, token) ||
                const DeepCollectionEquality().equals(other.token, token)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(token) ^ runtimeType.hashCode;
}

extension $V1UserConfirmMailPost$RequestBodyExtension
    on V1UserConfirmMailPost$RequestBody {
  V1UserConfirmMailPost$RequestBody copyWith({String? token}) {
    return V1UserConfirmMailPost$RequestBody(token: token ?? this.token);
  }

  V1UserConfirmMailPost$RequestBody copyWithWrapped({Wrapped<String>? token}) {
    return V1UserConfirmMailPost$RequestBody(
      token: (token != null ? token.value : this.token),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserRequestPasswordResetPost$RequestBody {
  const V1UserRequestPasswordResetPost$RequestBody({required this.email});

  factory V1UserRequestPasswordResetPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$V1UserRequestPasswordResetPost$RequestBodyFromJson(json);

  static const toJsonFactory =
      _$V1UserRequestPasswordResetPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1UserRequestPasswordResetPost$RequestBodyToJson(this);

  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  static const fromJsonFactory =
      _$V1UserRequestPasswordResetPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserRequestPasswordResetPost$RequestBody &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^ runtimeType.hashCode;
}

extension $V1UserRequestPasswordResetPost$RequestBodyExtension
    on V1UserRequestPasswordResetPost$RequestBody {
  V1UserRequestPasswordResetPost$RequestBody copyWith({String? email}) {
    return V1UserRequestPasswordResetPost$RequestBody(
      email: email ?? this.email,
    );
  }

  V1UserRequestPasswordResetPost$RequestBody copyWithWrapped({
    Wrapped<String>? email,
  }) {
    return V1UserRequestPasswordResetPost$RequestBody(
      email: (email != null ? email.value : this.email),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserResetPasswordPost$RequestBody {
  const V1UserResetPasswordPost$RequestBody({
    required this.token,
    required this.newPassword,
  });

  factory V1UserResetPasswordPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$V1UserResetPasswordPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1UserResetPasswordPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1UserResetPasswordPost$RequestBodyToJson(this);

  @JsonKey(name: 'token', includeIfNull: false)
  final String token;
  @JsonKey(name: 'new_password', includeIfNull: false)
  final String newPassword;
  static const fromJsonFactory = _$V1UserResetPasswordPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserResetPasswordPost$RequestBody &&
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

extension $V1UserResetPasswordPost$RequestBodyExtension
    on V1UserResetPasswordPost$RequestBody {
  V1UserResetPasswordPost$RequestBody copyWith({
    String? token,
    String? newPassword,
  }) {
    return V1UserResetPasswordPost$RequestBody(
      token: token ?? this.token,
      newPassword: newPassword ?? this.newPassword,
    );
  }

  V1UserResetPasswordPost$RequestBody copyWithWrapped({
    Wrapped<String>? token,
    Wrapped<String>? newPassword,
  }) {
    return V1UserResetPasswordPost$RequestBody(
      token: (token != null ? token.value : this.token),
      newPassword: (newPassword != null ? newPassword.value : this.newPassword),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserSignInEmailPost$RequestBody {
  const V1UserSignInEmailPost$RequestBody({
    required this.email,
    required this.password,
  });

  factory V1UserSignInEmailPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$V1UserSignInEmailPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1UserSignInEmailPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1UserSignInEmailPost$RequestBodyToJson(this);

  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'password', includeIfNull: false)
  final String password;
  static const fromJsonFactory = _$V1UserSignInEmailPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserSignInEmailPost$RequestBody &&
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

extension $V1UserSignInEmailPost$RequestBodyExtension
    on V1UserSignInEmailPost$RequestBody {
  V1UserSignInEmailPost$RequestBody copyWith({
    String? email,
    String? password,
  }) {
    return V1UserSignInEmailPost$RequestBody(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  V1UserSignInEmailPost$RequestBody copyWithWrapped({
    Wrapped<String>? email,
    Wrapped<String>? password,
  }) {
    return V1UserSignInEmailPost$RequestBody(
      email: (email != null ? email.value : this.email),
      password: (password != null ? password.value : this.password),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserSignInSsoPost$RequestBody {
  const V1UserSignInSsoPost$RequestBody({
    required this.providerId,
    required this.successUrl,
  });

  factory V1UserSignInSsoPost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$V1UserSignInSsoPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1UserSignInSsoPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1UserSignInSsoPost$RequestBodyToJson(this);

  @JsonKey(name: 'provider_id', includeIfNull: false)
  final String providerId;
  @JsonKey(name: 'success_url', includeIfNull: false)
  final String successUrl;
  static const fromJsonFactory = _$V1UserSignInSsoPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserSignInSsoPost$RequestBody &&
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

extension $V1UserSignInSsoPost$RequestBodyExtension
    on V1UserSignInSsoPost$RequestBody {
  V1UserSignInSsoPost$RequestBody copyWith({
    String? providerId,
    String? successUrl,
  }) {
    return V1UserSignInSsoPost$RequestBody(
      providerId: providerId ?? this.providerId,
      successUrl: successUrl ?? this.successUrl,
    );
  }

  V1UserSignInSsoPost$RequestBody copyWithWrapped({
    Wrapped<String>? providerId,
    Wrapped<String>? successUrl,
  }) {
    return V1UserSignInSsoPost$RequestBody(
      providerId: (providerId != null ? providerId.value : this.providerId),
      successUrl: (successUrl != null ? successUrl.value : this.successUrl),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserSignUpEmailPost$RequestBody {
  const V1UserSignUpEmailPost$RequestBody({
    required this.name,
    required this.email,
    required this.password,
  });

  factory V1UserSignUpEmailPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$V1UserSignUpEmailPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1UserSignUpEmailPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1UserSignUpEmailPost$RequestBodyToJson(this);

  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'password', includeIfNull: false)
  final String password;
  static const fromJsonFactory = _$V1UserSignUpEmailPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserSignUpEmailPost$RequestBody &&
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

extension $V1UserSignUpEmailPost$RequestBodyExtension
    on V1UserSignUpEmailPost$RequestBody {
  V1UserSignUpEmailPost$RequestBody copyWith({
    String? name,
    String? email,
    String? password,
  }) {
    return V1UserSignUpEmailPost$RequestBody(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  V1UserSignUpEmailPost$RequestBody copyWithWrapped({
    Wrapped<String>? name,
    Wrapped<String>? email,
    Wrapped<String>? password,
  }) {
    return V1UserSignUpEmailPost$RequestBody(
      name: (name != null ? name.value : this.name),
      email: (email != null ? email.value : this.email),
      password: (password != null ? password.value : this.password),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserGetUserGet$Response {
  const V1UserGetUserGet$Response({required this.user});

  factory V1UserGetUserGet$Response.fromJson(Map<String, dynamic> json) =>
      _$V1UserGetUserGet$ResponseFromJson(json);

  static const toJsonFactory = _$V1UserGetUserGet$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1UserGetUserGet$ResponseToJson(this);

  @JsonKey(name: 'user', includeIfNull: false)
  final AuthUser user;
  static const fromJsonFactory = _$V1UserGetUserGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserGetUserGet$Response &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(user) ^ runtimeType.hashCode;
}

extension $V1UserGetUserGet$ResponseExtension on V1UserGetUserGet$Response {
  V1UserGetUserGet$Response copyWith({AuthUser? user}) {
    return V1UserGetUserGet$Response(user: user ?? this.user);
  }

  V1UserGetUserGet$Response copyWithWrapped({Wrapped<AuthUser>? user}) {
    return V1UserGetUserGet$Response(
      user: (user != null ? user.value : this.user),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserLogoutGet$Response {
  const V1UserLogoutGet$Response({required this.user});

  factory V1UserLogoutGet$Response.fromJson(Map<String, dynamic> json) =>
      _$V1UserLogoutGet$ResponseFromJson(json);

  static const toJsonFactory = _$V1UserLogoutGet$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1UserLogoutGet$ResponseToJson(this);

  @JsonKey(name: 'user', includeIfNull: false)
  final dynamic user;
  static const fromJsonFactory = _$V1UserLogoutGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserLogoutGet$Response &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(user) ^ runtimeType.hashCode;
}

extension $V1UserLogoutGet$ResponseExtension on V1UserLogoutGet$Response {
  V1UserLogoutGet$Response copyWith({dynamic user}) {
    return V1UserLogoutGet$Response(user: user ?? this.user);
  }

  V1UserLogoutGet$Response copyWithWrapped({Wrapped<dynamic>? user}) {
    return V1UserLogoutGet$Response(
      user: (user != null ? user.value : this.user),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserRefreshSessionPost$Response {
  const V1UserRefreshSessionPost$Response({this.expiresAt});

  factory V1UserRefreshSessionPost$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$V1UserRefreshSessionPost$ResponseFromJson(json);

  static const toJsonFactory = _$V1UserRefreshSessionPost$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$V1UserRefreshSessionPost$ResponseToJson(this);

  @JsonKey(name: 'expires_at', includeIfNull: false)
  final DateTime? expiresAt;
  static const fromJsonFactory = _$V1UserRefreshSessionPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserRefreshSessionPost$Response &&
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

extension $V1UserRefreshSessionPost$ResponseExtension
    on V1UserRefreshSessionPost$Response {
  V1UserRefreshSessionPost$Response copyWith({DateTime? expiresAt}) {
    return V1UserRefreshSessionPost$Response(
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  V1UserRefreshSessionPost$Response copyWithWrapped({
    Wrapped<DateTime?>? expiresAt,
  }) {
    return V1UserRefreshSessionPost$Response(
      expiresAt: (expiresAt != null ? expiresAt.value : this.expiresAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserSignInEmailPost$Response {
  const V1UserSignInEmailPost$Response({
    required this.sessionId,
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  factory V1UserSignInEmailPost$Response.fromJson(Map<String, dynamic> json) =>
      _$V1UserSignInEmailPost$ResponseFromJson(json);

  static const toJsonFactory = _$V1UserSignInEmailPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1UserSignInEmailPost$ResponseToJson(this);

  @JsonKey(name: 'session_id', includeIfNull: false)
  final String sessionId;
  @JsonKey(name: 'token', includeIfNull: false)
  final String token;
  @JsonKey(name: 'expires_at', includeIfNull: false)
  final DateTime expiresAt;
  @JsonKey(name: 'user', includeIfNull: false)
  final AuthUser user;
  static const fromJsonFactory = _$V1UserSignInEmailPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserSignInEmailPost$Response &&
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

extension $V1UserSignInEmailPost$ResponseExtension
    on V1UserSignInEmailPost$Response {
  V1UserSignInEmailPost$Response copyWith({
    String? sessionId,
    String? token,
    DateTime? expiresAt,
    AuthUser? user,
  }) {
    return V1UserSignInEmailPost$Response(
      sessionId: sessionId ?? this.sessionId,
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
      user: user ?? this.user,
    );
  }

  V1UserSignInEmailPost$Response copyWithWrapped({
    Wrapped<String>? sessionId,
    Wrapped<String>? token,
    Wrapped<DateTime>? expiresAt,
    Wrapped<AuthUser>? user,
  }) {
    return V1UserSignInEmailPost$Response(
      sessionId: (sessionId != null ? sessionId.value : this.sessionId),
      token: (token != null ? token.value : this.token),
      expiresAt: (expiresAt != null ? expiresAt.value : this.expiresAt),
      user: (user != null ? user.value : this.user),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserSignInSsoPost$Response {
  const V1UserSignInSsoPost$Response({
    required this.success,
    required this.data,
  });

  factory V1UserSignInSsoPost$Response.fromJson(Map<String, dynamic> json) =>
      _$V1UserSignInSsoPost$ResponseFromJson(json);

  static const toJsonFactory = _$V1UserSignInSsoPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1UserSignInSsoPost$ResponseToJson(this);

  @JsonKey(name: 'success', includeIfNull: false)
  final bool success;
  @JsonKey(name: 'data', includeIfNull: false)
  final V1UserSignInSsoPost$Response$Data data;
  static const fromJsonFactory = _$V1UserSignInSsoPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserSignInSsoPost$Response &&
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

extension $V1UserSignInSsoPost$ResponseExtension
    on V1UserSignInSsoPost$Response {
  V1UserSignInSsoPost$Response copyWith({
    bool? success,
    V1UserSignInSsoPost$Response$Data? data,
  }) {
    return V1UserSignInSsoPost$Response(
      success: success ?? this.success,
      data: data ?? this.data,
    );
  }

  V1UserSignInSsoPost$Response copyWithWrapped({
    Wrapped<bool>? success,
    Wrapped<V1UserSignInSsoPost$Response$Data>? data,
  }) {
    return V1UserSignInSsoPost$Response(
      success: (success != null ? success.value : this.success),
      data: (data != null ? data.value : this.data),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserSignUpEmailPost$Response {
  const V1UserSignUpEmailPost$Response({
    required this.sessionId,
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  factory V1UserSignUpEmailPost$Response.fromJson(Map<String, dynamic> json) =>
      _$V1UserSignUpEmailPost$ResponseFromJson(json);

  static const toJsonFactory = _$V1UserSignUpEmailPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1UserSignUpEmailPost$ResponseToJson(this);

  @JsonKey(name: 'session_id', includeIfNull: false)
  final String sessionId;
  @JsonKey(name: 'token', includeIfNull: false)
  final String token;
  @JsonKey(name: 'expires_at', includeIfNull: false)
  final DateTime expiresAt;
  @JsonKey(name: 'user', includeIfNull: false)
  final AuthUser user;
  static const fromJsonFactory = _$V1UserSignUpEmailPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserSignUpEmailPost$Response &&
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

extension $V1UserSignUpEmailPost$ResponseExtension
    on V1UserSignUpEmailPost$Response {
  V1UserSignUpEmailPost$Response copyWith({
    String? sessionId,
    String? token,
    DateTime? expiresAt,
    AuthUser? user,
  }) {
    return V1UserSignUpEmailPost$Response(
      sessionId: sessionId ?? this.sessionId,
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
      user: user ?? this.user,
    );
  }

  V1UserSignUpEmailPost$Response copyWithWrapped({
    Wrapped<String>? sessionId,
    Wrapped<String>? token,
    Wrapped<DateTime>? expiresAt,
    Wrapped<AuthUser>? user,
  }) {
    return V1UserSignUpEmailPost$Response(
      sessionId: (sessionId != null ? sessionId.value : this.sessionId),
      token: (token != null ? token.value : this.token),
      expiresAt: (expiresAt != null ? expiresAt.value : this.expiresAt),
      user: (user != null ? user.value : this.user),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserSignInSsoPost$Response$Data {
  const V1UserSignInSsoPost$Response$Data({
    required this.redirectUrl,
    required this.providerId,
  });

  factory V1UserSignInSsoPost$Response$Data.fromJson(
    Map<String, dynamic> json,
  ) => _$V1UserSignInSsoPost$Response$DataFromJson(json);

  static const toJsonFactory = _$V1UserSignInSsoPost$Response$DataToJson;
  Map<String, dynamic> toJson() =>
      _$V1UserSignInSsoPost$Response$DataToJson(this);

  @JsonKey(name: 'redirectUrl', includeIfNull: false)
  final String redirectUrl;
  @JsonKey(name: 'providerId', includeIfNull: false)
  final String providerId;
  static const fromJsonFactory = _$V1UserSignInSsoPost$Response$DataFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserSignInSsoPost$Response$Data &&
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

extension $V1UserSignInSsoPost$Response$DataExtension
    on V1UserSignInSsoPost$Response$Data {
  V1UserSignInSsoPost$Response$Data copyWith({
    String? redirectUrl,
    String? providerId,
  }) {
    return V1UserSignInSsoPost$Response$Data(
      redirectUrl: redirectUrl ?? this.redirectUrl,
      providerId: providerId ?? this.providerId,
    );
  }

  V1UserSignInSsoPost$Response$Data copyWithWrapped({
    Wrapped<String>? redirectUrl,
    Wrapped<String>? providerId,
  }) {
    return V1UserSignInSsoPost$Response$Data(
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
