import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQLauncherUnreadBadgeTheme.dart';


class SIQChatScrollButtonTheme {
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