import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQNavigationTheme {
  // ignore_for_file: public_member_api_docs

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
