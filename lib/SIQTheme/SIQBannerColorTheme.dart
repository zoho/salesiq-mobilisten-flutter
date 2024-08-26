import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQBannerColorTheme {
  String? backgroundColor;
  String? textColor;

  SIQBannerColorTheme({
    this.backgroundColor,
    this.textColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'textColor': colorToHex(textColor),
    };
  }
}
