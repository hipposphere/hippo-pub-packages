import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hippo_auth/src/auth_bloc.dart';
import 'package:hippo_auth/src/models/auth_session.dart';
import 'package:hippo_auth/src/models/auth_state.dart';

class HippoAuthGate<TAuthenticated, TUnauthenticated> extends StatefulWidget {
  const HippoAuthGate({
    super.key,
    required this.authBloc,
    required this.createAuthenticated,
    required this.createUnauthenticated,
    required this.authenticatedBuilder,
    required this.unauthenticatedBuilder,
    required this.loadingBuilder,
    this.errorBuilder,
  });

  final HippoAuthBloc authBloc;
  final FutureOr<TAuthenticated> Function(AuthSession session)
  createAuthenticated;
  final FutureOr<TUnauthenticated> Function() createUnauthenticated;
  final Widget Function(
    BuildContext context,
    TAuthenticated data,
    AuthSession session,
  )
  authenticatedBuilder;
  final Widget Function(BuildContext context, TUnauthenticated data)
  unauthenticatedBuilder;
  final WidgetBuilder loadingBuilder;
  final Widget Function(BuildContext context, ErrorAuthState state)?
  errorBuilder;

  @override
  State<HippoAuthGate<TAuthenticated, TUnauthenticated>> createState() =>
      _HippoAuthGateState<TAuthenticated, TUnauthenticated>();
}

class _HippoAuthGateState<TAuthenticated, TUnauthenticated>
    extends State<HippoAuthGate<TAuthenticated, TUnauthenticated>> {
  StreamSubscription<HippoAuthState>? _subscription;
  int _revision = 0;

  _HippoAuthGateView<TAuthenticated, TUnauthenticated> _view =
      _LoadingHippoAuthGateView<TAuthenticated, TUnauthenticated>();

  @override
  void initState() {
    super.initState();
    _subscribe();
    _handleState(widget.authBloc.apiController.stateSubject.value);
  }

  @override
  void didUpdateWidget(
    covariant HippoAuthGate<TAuthenticated, TUnauthenticated> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authBloc != widget.authBloc) {
      _subscription?.cancel();
      _subscribe();
      _handleState(widget.authBloc.apiController.stateSubject.value);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _subscribe() {
    _subscription = widget.authBloc.apiController.stateSubject.stream
        .skip(1)
        .listen(_handleState);
  }

  void _handleState(HippoAuthState state) {
    final revision = ++_revision;

    switch (state) {
      case LoadingAuthState():
        _setView(_LoadingHippoAuthGateView<TAuthenticated, TUnauthenticated>());
      case ErrorAuthState():
        _setView(
          _ErrorHippoAuthGateView<TAuthenticated, TUnauthenticated>(state),
        );
      case AuthenticatedAuthState(:final session):
        _resolveAuthenticated(revision, session);
      case UnauthenticatedAuthState():
        _resolveUnauthenticated(revision);
    }
  }

  Future<void> _resolveAuthenticated(int revision, AuthSession session) async {
    _setView(_LoadingHippoAuthGateView<TAuthenticated, TUnauthenticated>());

    try {
      final data = await Future<TAuthenticated>.sync(
        () => widget.createAuthenticated(session),
      );
      if (!_isCurrent(revision)) {
        return;
      }
      _setView(
        _AuthenticatedHippoAuthGateView<TAuthenticated, TUnauthenticated>(
          data: data,
          session: session,
        ),
      );
    } catch (error) {
      if (!_isCurrent(revision)) {
        return;
      }
      _setView(
        _ErrorHippoAuthGateView<TAuthenticated, TUnauthenticated>(
          ErrorAuthState(error.toString()),
        ),
      );
    }
  }

  Future<void> _resolveUnauthenticated(int revision) async {
    _setView(_LoadingHippoAuthGateView<TAuthenticated, TUnauthenticated>());

    try {
      final data = await Future<TUnauthenticated>.sync(
        widget.createUnauthenticated,
      );
      if (!_isCurrent(revision)) {
        return;
      }
      _setView(
        _UnauthenticatedHippoAuthGateView<TAuthenticated, TUnauthenticated>(
          data,
        ),
      );
    } catch (error) {
      if (!_isCurrent(revision)) {
        return;
      }
      _setView(
        _ErrorHippoAuthGateView<TAuthenticated, TUnauthenticated>(
          ErrorAuthState(error.toString()),
        ),
      );
    }
  }

  bool _isCurrent(int revision) => mounted && revision == _revision;

  void _setView(_HippoAuthGateView<TAuthenticated, TUnauthenticated> view) {
    if (!mounted) {
      _view = view;
      return;
    }
    setState(() {
      _view = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_view) {
      _LoadingHippoAuthGateView() => widget.loadingBuilder(context),
      _ErrorHippoAuthGateView(:final state) =>
        widget.errorBuilder?.call(context, state) ??
            widget.loadingBuilder(context),
      _AuthenticatedHippoAuthGateView(:final data, :final session) =>
        widget.authenticatedBuilder(context, data, session),
      _UnauthenticatedHippoAuthGateView(:final data) =>
        widget.unauthenticatedBuilder(context, data),
    };
  }
}

sealed class _HippoAuthGateView<TAuthenticated, TUnauthenticated> {
  const _HippoAuthGateView();
}

final class _LoadingHippoAuthGateView<TAuthenticated, TUnauthenticated>
    extends _HippoAuthGateView<TAuthenticated, TUnauthenticated> {}

final class _AuthenticatedHippoAuthGateView<TAuthenticated, TUnauthenticated>
    extends _HippoAuthGateView<TAuthenticated, TUnauthenticated> {
  const _AuthenticatedHippoAuthGateView({
    required this.data,
    required this.session,
  });

  final TAuthenticated data;
  final AuthSession session;
}

final class _UnauthenticatedHippoAuthGateView<TAuthenticated, TUnauthenticated>
    extends _HippoAuthGateView<TAuthenticated, TUnauthenticated> {
  const _UnauthenticatedHippoAuthGateView(this.data);

  final TUnauthenticated data;
}

final class _ErrorHippoAuthGateView<TAuthenticated, TUnauthenticated>
    extends _HippoAuthGateView<TAuthenticated, TUnauthenticated> {
  const _ErrorHippoAuthGateView(this.state);

  final ErrorAuthState state;
}
