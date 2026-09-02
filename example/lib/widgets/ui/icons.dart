/// One icon vocabulary across all sample apps (DESIGN_SYSTEM rule 4), mapped
/// onto Material [Icons]. Mirrors the RN `components/ui/icons.ts` vocabulary.
library;

import 'package:flutter/material.dart';

/// Named app icons. Use [AppIcons.of] to resolve a name to [IconData].
enum AppIcon {
  chat,
  calls,
  launcher,
  visitor,
  knowledgeBase,
  homepage,
  help,
  core,
  notifications,
  events,
  settings,
  logs,
  globe,
  key,
  search,
  check,
  close,
  chevronRight,
  back,
  plus,
  sun,
  moon,
  article,
  department,
  timer,
  refresh,
  send,
  eye,
  history,
  info,
  alert,
}

/// Resolves an [AppIcon] to a Material [IconData], keeping a single
/// cross-platform icon vocabulary.
class AppIcons {
  static IconData of(AppIcon icon) {
    switch (icon) {
      case AppIcon.chat:
        return Icons.chat_bubble_outline;
      case AppIcon.calls:
        return Icons.phone_outlined;
      case AppIcon.launcher:
        return Icons.my_location_outlined;
      case AppIcon.visitor:
        return Icons.person_outline;
      case AppIcon.knowledgeBase:
        return Icons.menu_book_outlined;
      case AppIcon.homepage:
        return Icons.grid_view_outlined;
      case AppIcon.help:
        return Icons.help_outline;
      case AppIcon.core:
        return Icons.bolt_outlined;
      case AppIcon.notifications:
        return Icons.notifications_none;
      case AppIcon.events:
        return Icons.show_chart;
      case AppIcon.settings:
        return Icons.settings_outlined;
      case AppIcon.logs:
        return Icons.description_outlined;
      case AppIcon.globe:
        return Icons.language;
      case AppIcon.key:
        return Icons.vpn_key_outlined;
      case AppIcon.search:
        return Icons.search;
      case AppIcon.check:
        return Icons.check;
      case AppIcon.close:
        return Icons.close;
      case AppIcon.chevronRight:
        return Icons.chevron_right;
      case AppIcon.back:
        return Icons.chevron_left;
      case AppIcon.plus:
        return Icons.add;
      case AppIcon.sun:
        return Icons.wb_sunny_outlined;
      case AppIcon.moon:
        return Icons.nightlight_outlined;
      case AppIcon.article:
        return Icons.description_outlined;
      case AppIcon.department:
        return Icons.groups_outlined;
      case AppIcon.timer:
        return Icons.timer_outlined;
      case AppIcon.refresh:
        return Icons.refresh;
      case AppIcon.send:
        return Icons.send_outlined;
      case AppIcon.eye:
        return Icons.visibility_outlined;
      case AppIcon.history:
        return Icons.history;
      case AppIcon.info:
        return Icons.info_outline;
      case AppIcon.alert:
        return Icons.error_outline;
    }
  }
}

/// Tint variants for the 34×34 list-row icon box.
enum IconTint { primary, secondary, accent, danger }
