import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';
import 'package:salesiq_mobilisten/siqtheme/siqlauncherunreadbadgetheme.dart';

class SIQConversationListItemTheme {
  // ignore_for_file: public_member_api_docs

  String? backgroundColor;
  String? timerTextColor;
  String? timerIconColor;
  String? titleTextColor;
  String? subtitleTextColor;
  String? timeTextColor;
  String? openBadgeBackgroundColor;
  String? openBadgeBorderColor;
  String? openBadgeTextColor;
  String? separatorColor;
  SIQLauncherUnreadBadgeTheme unreadBadge;

  SIQConversationListItemTheme({
    this.backgroundColor,
    this.timerTextColor,
    this.timerIconColor,
    this.titleTextColor,
    this.subtitleTextColor,
    this.timeTextColor,
    this.openBadgeBackgroundColor,
    this.openBadgeBorderColor,
    this.openBadgeTextColor,
    this.separatorColor,
    SIQLauncherUnreadBadgeTheme? unreadBadge,
  }) : unreadBadge = unreadBadge ?? SIQLauncherUnreadBadgeTheme();

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'timerTextColor': colorToHex(timerTextColor),
      'timerIconColor': colorToHex(timerIconColor),
      'titleTextColor': colorToHex(titleTextColor),
      'subtitleTextColor': colorToHex(subtitleTextColor),
      'timeTextColor': colorToHex(timeTextColor),
      'openBadgeBackgroundColor': colorToHex(openBadgeBackgroundColor),
      'openBadgeBorderColor': colorToHex(openBadgeBorderColor),
      'openBadgeTextColor': colorToHex(openBadgeTextColor),
      'separatorColor': colorToHex(separatorColor),
      'UnreadBadge': unreadBadge.toMap(),
    };
  }
}
