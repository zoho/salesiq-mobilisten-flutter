import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQOfflineBannerTheme {
  // ignore_for_file: public_member_api_docs

  String? textColor;
  String? backgroundColor;

  SIQOfflineBannerTheme({
    this.textColor,
    this.backgroundColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'textColor': colorToHex(textColor),
      'backgroundColor': colorToHex(backgroundColor),
    };
  }
}
