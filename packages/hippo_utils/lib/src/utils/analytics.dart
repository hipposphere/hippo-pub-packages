// ignore_for_file: avoid_print
import 'package:flutter/widgets.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class Analytics {
  static AnalyticsProvider? _instance;

  static const _exceptionMessage = 'AnalyticsProvider is not set.';

  static AnalyticsProvider get instance {
    if (_instance == null) {
      throw Exception('AnalyticsProvider is not initialized. Please call initialize() first.');
    }
    return _instance!;
  }

  static void initialize(AnalyticsProvider provider) {
    if (_instance != null) {
      print(_exceptionMessage);
    }
    _instance = provider;
  }

  static void logEvent({required String eventName, Map<String, Object>? parameters}) {
    if (_instance == null) {
      print(_exceptionMessage);
    }
    _instance!.logEvent(eventName: eventName, parameters: parameters);
  }

  static void identify({required String userId, Map<String, Object>? parameters}) {
    if (_instance == null) {
      print(_exceptionMessage);
    }
    _instance!.identify(userId: userId, parameters: parameters);
  }
}

abstract class AnalyticsProvider {
  void logEvent({required String eventName, Map<String, Object>? parameters});

  void identify({required String userId, Map<String, Object>? parameters});

  void setCurrentScreen({required String screenName, Map<String, Object>? parameters});

  void resetAnalyticsData();
}

class LoggingAnalyticsProvider implements AnalyticsProvider {
  final bool enabled;
  LoggingAnalyticsProvider({this.enabled = true});
  @override
  void logEvent({required String eventName, Map<String, Object>? parameters}) {
    if (enabled) {
      print('Event logged: $eventName, Parameters: $parameters');
    }
  }

  @override
  void identify({required String? userId, Map<String, Object>? parameters}) {
    if (enabled) {
      print('User ID set: $userId with parameters: $parameters');
    }
  }

  @override
  void setCurrentScreen({required String screenName, Map<String, Object>? parameters}) {
    if (enabled) {
      print('Current screen set: $screenName, Parameters: $parameters');
    }
  }

  @override
  void resetAnalyticsData() {
    if (enabled) {
      print('Analytics data reset');
    }
  }
}

class PosthogAnalyticsProvider implements AnalyticsProvider {
  final Posthog _client = Posthog();

  PosthogAnalyticsProvider();

  @override
  void logEvent({required String eventName, Map<String, Object>? parameters}) {
    _client.capture(eventName: eventName, properties: parameters);
  }

  @override
  void identify({required String userId, Map<String, Object>? parameters}) {
    _client.identify(userId: userId, userProperties: parameters);
  }

  @override
  void setCurrentScreen({required String screenName, Map<String, Object>? parameters}) {
    _client.screen(screenName: screenName, properties: parameters);
  }

  @override
  void resetAnalyticsData() {
    _client.reset();
  }
}

class LoggingNavigationObserver extends RouteObserver<ModalRoute<dynamic>> {
  final bool enabled;

  LoggingNavigationObserver({this.enabled = true});

  @override
  void didChangeTop(Route topRoute, Route? previousTopRoute) {
    if (enabled) {
      print('Top route changed: ${topRoute.settings.name}');
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (enabled) {
      print('Route popped: ${route.settings.name}');
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (enabled) {
      print('Route pushed: ${route.settings.name}');
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    if (enabled) {
      print('Route removed: ${route.settings.name}');
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (enabled) {
      print('Route replaced: ${oldRoute?.settings.name} with ${newRoute?.settings.name}');
    }
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    if (enabled) {
      print('User gesture started on route: ${route.settings.name}');
    }
  }

  @override
  void didStopUserGesture() {
    if (enabled) {
      print('User gesture stopped');
    }
  }
}
