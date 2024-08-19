import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';

class SIQLauncherUnreadBadgeTheme {
  String? backgroundColor;
  String? textColor;
  String? borderColor;
  double? borderWidth;

  SIQLauncherUnreadBadgeTheme({
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'textColor': colorToHex(textColor),
      'borderColor': colorToHex(borderColor),
      'borderWidth': borderWidth,
    };
  }
}
