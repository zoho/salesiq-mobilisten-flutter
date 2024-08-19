import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';

class SIQHandOffBannerTheme {
  String? backgroundColor;
  String? textColor;
  String? buttonTitleColor;

  SIQHandOffBannerTheme({
    this.backgroundColor,
    this.textColor,
    this.buttonTitleColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'textColor': colorToHex(textColor),
      'buttonTitleColor': colorToHex(buttonTitleColor),
    };
  }
}
