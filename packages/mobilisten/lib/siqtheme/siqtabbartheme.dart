import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQTabBarTheme {
  // ignore_for_file: public_member_api_docs

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
