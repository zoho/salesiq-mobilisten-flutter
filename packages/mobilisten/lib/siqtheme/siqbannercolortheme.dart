import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQBannerColorTheme {
  // ignore_for_file: public_member_api_docs

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
