import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';

class SIQTabBarTheme {
  String? backgroundColor;
  String? activeTabColor;
  String? inactiveTabColor;

  SIQTabBarTheme({
    this.backgroundColor,
    this.activeTabColor,
    this.inactiveTabColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'activeTabColor': colorToHex(activeTabColor),
      'inactiveTabColor': colorToHex(inactiveTabColor),
    };
  }
}
