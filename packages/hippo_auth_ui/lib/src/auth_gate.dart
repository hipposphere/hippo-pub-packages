import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hippo_auth/hippo_auth.dart';

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

  _HippoAuthGatePhase _phase = _HippoAuthGatePhase.loading;
  Object? _data;
  AuthSession? _session;
  ErrorAuthState? _errorState;

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
        _showLoading();
      case ErrorAuthState():
        _showError(state);
      case AuthenticatedAuthState(:final session):
        _resolveAuthenticated(revision, session);
      case UnauthenticatedAuthState():
        _resolveUnauthenticated(revision);
    }
  }

  Future<void> _resolveAuthenticated(int revision, AuthSession session) async {
    _showLoading();

    try {
      final data = await Future<TAuthenticated>.sync(
        () => widget.createAuthenticated(session),
      );
      if (!_isCurrent(revision)) {
        return;
      }
      _setResolvedAuthenticated(data, session);
    } catch (error) {
      if (!_isCurrent(revision)) {
        return;
      }
      _showError(ErrorAuthState(error.toString()));
    }
  }

  Future<void> _resolveUnauthenticated(int revision) async {
    _showLoading();

    try {
      final data = await Future<TUnauthenticated>.sync(
        widget.createUnauthenticated,
      );
      if (!_isCurrent(revision)) {
        return;
      }
      _setResolvedUnauthenticated(data);
    } catch (error) {
      if (!_isCurrent(revision)) {
        return;
      }
      _showError(ErrorAuthState(error.toString()));
    }
  }

  bool _isCurrent(int revision) => mounted && revision == _revision;

  void _showLoading() {
    _setPhase(_HippoAuthGatePhase.loading);
  }

  void _showError(ErrorAuthState state) {
    _setPhase(_HippoAuthGatePhase.error, errorState: state);
  }

  void _setResolvedAuthenticated(TAuthenticated data, AuthSession session) {
    _setPhase(_HippoAuthGatePhase.authenticated, data: data, session: session);
  }

  void _setResolvedUnauthenticated(TUnauthenticated data) {
    _setPhase(_HippoAuthGatePhase.unauthenticated, data: data);
  }

  void _setPhase(
    _HippoAuthGatePhase phase, {
    Object? data,
    AuthSession? session,
    ErrorAuthState? errorState,
  }) {
    void update() {
      _phase = phase;
      _data = data;
      _session = session;
      _errorState = errorState;
    }

    if (mounted) {
      setState(update);
    } else {
      update();
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _HippoAuthGatePhase.loading => widget.loadingBuilder(context),
      _HippoAuthGatePhase.error =>
        widget.errorBuilder?.call(context, _errorState!) ??
            widget.loadingBuilder(context),
      _HippoAuthGatePhase.authenticated => widget.authenticatedBuilder(
        context,
        _data as TAuthenticated,
        _session!,
      ),
      _HippoAuthGatePhase.unauthenticated => widget.unauthenticatedBuilder(
        context,
        _data as TUnauthenticated,
      ),
    };
  }
}

enum _HippoAuthGatePhase { loading, authenticated, unauthenticated, error }
