import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQNoNetworkBannerTheme {
  // ignore_for_file: public_member_api_docs

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
