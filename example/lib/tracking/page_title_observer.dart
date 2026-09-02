import 'package:flutter/widgets.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

import '../routes.dart';

/// [NavigatorObserver] that reports the active screen to SalesIQ via
/// `ZohoSalesIQ.tracking.setPageTitle`, so the operator sees the visitor's
/// in-app navigation path (which screen they are on).
///
/// Registered once on [MaterialApp.navigatorObservers]; it fires on every push,
/// replace, and pop, so each page the visitor lands on is reported from a
/// single central place — no per-screen edits.
class PageTitleObserver extends NavigatorObserver {
  /// Human-readable title per named route (the titles the screens already show
  /// in their scaffolds). Detail screens pushed as unnamed [MaterialPageRoute]s
  /// carry their title directly in `RouteSettings.name`, so any name not found
  /// here is reported as-is.
  static const Map<String, String> _titles = {
    Routes.home: 'Home',
    Routes.store: 'Zylker store',
    Routes.core: 'Core & Config',
    Routes.launcher: 'Launcher',
    Routes.visitor: 'Visitor',
    Routes.chat: 'Chat',
    Routes.calls: 'Calls',
    Routes.knowledgeBase: 'Knowledge Base',
    Routes.homepageHelpCenter: 'Homepage',
    Routes.notifications: 'Notifications',
    Routes.events: 'Events',
    Routes.settings: 'Settings',
  };

  void _track(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null || name.isEmpty) return;
    ZohoSalesIQ.tracking.setPageTitle(_titles[name] ?? name);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _track(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _track(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Report the screen revealed underneath, so returning to a page re-tracks it.
    _track(previousRoute);
  }
}
