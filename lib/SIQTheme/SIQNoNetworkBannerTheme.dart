import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';

class SIQNoNetworkBannerTheme {
  String? backgroundColor;
  String? textColor;
  String? loaderColor;

  SIQNoNetworkBannerTheme({
    this.backgroundColor,
    this.textColor,
    this.loaderColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'textColor': colorToHex(textColor),
      'loaderColor': colorToHex(loaderColor),
    };
  }
}
