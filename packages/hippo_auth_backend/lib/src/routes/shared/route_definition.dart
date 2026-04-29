import 'dart:async';

import 'package:dart_edge_core/dart_edge_core.dart';

import '../../utils/api_error.dart';

final class HippoAuthRouteError {
  const HippoAuthRouteError(this.code, this.message, {this.status = 500});

  final String code;
  final String message;
  final int status;
}

abstract class HippoAuthJsonRoute<TServices> extends HttpRouteDefinition<TServices, RawResponse> {
  HippoAuthJsonRoute({required this.error});

  final HippoAuthRouteError error;

  FutureOr<Object?> handleJson(RequestContext<TServices> ctx);

  @override
  Future<RawResponse> handle(RequestContext<TServices> ctx) async {
    try {
      final result = await Future.sync(() => handleJson(ctx));
      if (result case final RawResponse response) {
        return response;
      }
      return RawResponse.json(status: 200, body: result);
    } catch (exception) {
      return hippoAuthExceptionResponse(
        exception,
        defaultStatus: error.status,
        defaultCode: error.code,
        defaultMessage: error.message,
      );
    }
  }
}
