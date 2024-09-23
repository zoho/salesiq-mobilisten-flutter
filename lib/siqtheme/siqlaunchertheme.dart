import 'package:salesiq_mobilisten/siqtheme/siqlauncherunreadbadgetheme.dart';
import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQLauncherTheme {
  // ignore_for_file: public_member_api_docs

  String? backgroundColor;
  String? iconColor;
  SIQLauncherUnreadBadgeTheme unreadBadge;

  SIQLauncherTheme({
    this.backgroundColor,
    this.iconColor,
    SIQLauncherUnreadBadgeTheme? unreadBadge,
  }) : unreadBadge = unreadBadge ?? SIQLauncherUnreadBadgeTheme();

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'iconColor': colorToHex(iconColor),
      'UnreadBadge': unreadBadge.toMap(),
    };
  }
}
