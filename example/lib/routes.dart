import 'package:flutter/widgets.dart';

import 'screens/calls_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/core_screen.dart';
import 'screens/events_screen.dart';
import 'screens/home_screen.dart';
import 'screens/homepage_help_center_screen.dart';
import 'screens/knowledge_base_screen.dart';
import 'screens/launcher_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/refresh_data_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/visitor_screen.dart';
import 'store/store_screen.dart';

/// Named routes for the 11 screens.
class Routes {
  static const home = '/';
  static const store = '/store';
  static const core = '/core';
  static const launcher = '/launcher';
  static const visitor = '/visitor';
  static const chat = '/chat';
  static const calls = '/calls';
  static const knowledgeBase = '/knowledge-base';
  static const homepageHelpCenter = '/homepage-help-center';
  static const notifications = '/notifications';
  static const events = '/events';
  static const refreshData = '/refresh-data';
  static const settings = '/settings';

  static Map<String, WidgetBuilder> get map => {
        home: (_) => const HomeScreen(),
        store: (_) => const StoreScreen(),
        core: (_) => const CoreScreen(),
        launcher: (_) => const LauncherScreen(),
        visitor: (_) => const VisitorScreen(),
        chat: (_) => const ChatScreen(),
        calls: (_) => const CallsScreen(),
        knowledgeBase: (_) => const KnowledgeBaseScreen(),
        homepageHelpCenter: (_) => const HomepageHelpCenterScreen(),
        notifications: (_) => const NotificationsScreen(),
        events: (_) => const EventsScreen(),
        refreshData: (_) => const RefreshDataScreen(),
        settings: (_) => const SettingsScreen(),
      };
}
