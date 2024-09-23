import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';
import 'package:salesiq_mobilisten/siqtheme/siqlauncherunreadbadgetheme.dart';

class SIQChatScrollButtonTheme {
  // ignore_for_file: public_member_api_docs

  String? iconColor;
  String? backgroundColor;
  SIQLauncherUnreadBadgeTheme unreadBadge;

  SIQChatScrollButtonTheme({
    this.iconColor,
    this.backgroundColor,
    SIQLauncherUnreadBadgeTheme? unreadBadge,
  }) : unreadBadge = unreadBadge ?? SIQLauncherUnreadBadgeTheme();

  Map<String, dynamic> toMap() {
    return {
      'iconColor': colorToHex(iconColor),
      'backgroundColor': colorToHex(backgroundColor),
      'UnreadBadge': unreadBadge.toMap(),
    };
  }
}
