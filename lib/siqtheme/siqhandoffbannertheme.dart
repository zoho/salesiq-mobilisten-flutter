import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQHandOffBannerTheme {
  // ignore_for_file: public_member_api_docs

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
