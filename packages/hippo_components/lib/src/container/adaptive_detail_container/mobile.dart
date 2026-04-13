part of 'adaptive_detail_container.dart';

const String _mobileRootRouteName = '/';
const String _mobileFallbackDetailRouteName = '/detail';

class _Mobile<T> extends StatefulWidget {
  const _Mobile({required this.controller, required this.mobileBuilder, this.state});

  final AdaptiveDetailController<T> controller;
  final Widget Function(BuildContext, AdaptiveDetailContainerState<T>? state) mobileBuilder;
  final AdaptiveDetailContainerState<T>? state;

  @override
  State<_Mobile<T>> createState() => _MobileState<T>();
}

class _MobileState<T> extends State<_Mobile<T>> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _routeObserver = _MobileNavigatorObserver();
  String? _activeRouteName;
  T? _activeStateData;
  bool _ignoreNextRoutePop = false;
  bool _syncScheduled = false;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      initialRoute: '/',
      onGenerateInitialRoutes: (navigator, initialRoute) {
        final routes = <Route<void>>[
          _createAdaptiveRoute(
            routeName: _mobileRootRouteName,
            builder: (context) => widget.mobileBuilder(context, null),
          ),
        ];

        if (widget.state != null) {
          routes.add(
            _createAdaptiveRoute(
              routeName: _resolveRouteName(widget.state!),
              builder: (context) => widget.mobileBuilder(context, widget.state),
              routeArguments: widget.state,
            ),
          );
        }

        return routes;
      },
      onGenerateRoute: (settings) {
        if (settings.arguments != null && settings.arguments is AdaptiveDetailContainerState<T>) {
          final state = settings.arguments;
          if (state is AdaptiveDetailContainerState<T>) {
            return _createAdaptiveRoute(
              routeName: settings.name ?? _resolveRouteName(state),
              routeArguments: state,
              builder: (context) => widget.mobileBuilder(context, state),
            );
          }
        }
        return _createAdaptiveRoute(
          routeName: _mobileRootRouteName,
          builder: (context) => widget.mobileBuilder(context, null),
        );
      },
      observers: [_routeObserver],
    );
  }

  @override
  void initState() {
    super.initState();
    _activeRouteName = widget.state != null ? _resolveRouteName(widget.state!) : null;
    _activeStateData = widget.state?.data;
    _routeObserver.onPop = _handleRoutePop;
    _scheduleSyncWithControllerState();
  }

  @override
  void didUpdateWidget(covariant _Mobile<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state?.data != widget.state?.data ||
        oldWidget.state?.routeName != widget.state?.routeName) {
      _scheduleSyncWithControllerState();
    }
  }

  void _scheduleSyncWithControllerState() {
    if (_syncScheduled) {
      return;
    }
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted) {
        return;
      }
      _syncRoutesToControllerState();
    });
  }

  void _syncRoutesToControllerState() {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      return;
    }

    final targetState = widget.state;
    if (targetState == null) {
      _activeRouteName = null;
      _activeStateData = null;
      if (navigator.canPop()) {
        _ignoreNextRoutePop = true;
        navigator.pop();
      } else {
        _ignoreNextRoutePop = false;
      }
      return;
    }

    final targetRouteName = _resolveRouteName(targetState);
    final hasStateChange =
        _activeRouteName != targetRouteName || _activeStateData != targetState.data;
    if (_activeRouteName == null || hasStateChange) {
      _ignoreNextRoutePop = navigator.canPop();
      if (navigator.canPop()) {
        navigator.pop();
      }
      _activeRouteName = targetRouteName;
      _activeStateData = targetState.data;
      navigator.pushNamed(_resolveRouteName(targetState), arguments: targetState);
      return;
    }
  }

  void _handleRoutePop(Route<dynamic> route) {
    final routeName = route.settings.name;
    if (!_isDetailRoute(routeName)) {
      return;
    }
    if (_ignoreNextRoutePop) {
      _ignoreNextRoutePop = false;
      return;
    }
    if (_activeRouteName == routeName) {
      _activeRouteName = null;
      _activeStateData = null;
      widget.controller.goBack();
    }
  }

  String _resolveRouteName(AdaptiveDetailContainerState<T> state) {
    final routeName = state.routeName?.trim();
    if (routeName == null || routeName.isEmpty || routeName == _mobileRootRouteName) {
      return _mobileFallbackDetailRouteName;
    }
    return routeName;
  }

  bool _isDetailRoute(String? routeName) {
    return routeName != null && routeName != _mobileRootRouteName;
  }

  Route<void> _createAdaptiveRoute({
    required String routeName,
    required WidgetBuilder builder,
    AdaptiveDetailContainerState<T>? routeArguments,
  }) {
    final platform = defaultTargetPlatform;
    final settings = RouteSettings(name: routeName, arguments: routeArguments);

    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return CupertinoPageRoute<void>(settings: settings, builder: builder);
    }

    return MaterialPageRoute<void>(settings: settings, builder: builder);
  }
}

class _MobileNavigatorObserver extends NavigatorObserver {
  void Function(Route<dynamic> route)? onPop;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPop?.call(route);
    super.didPop(route, previousRoute);
  }
}
