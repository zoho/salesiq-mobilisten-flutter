import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQNavigationTheme {
  String? backgroundColor;
  String? titleColor;
  String? tintColor;

  SIQNavigationTheme({
    this.backgroundColor,
    this.titleColor,
    this.tintColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'titleColor': colorToHex(titleColor),
      'tintColor': colorToHex(tintColor),
    };
  }
}
