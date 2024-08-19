import 'package:salesiq_mobilisten/SIQTheme/SIQLauncherUnreadBadgeTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';

class SIQLauncherTheme {
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
