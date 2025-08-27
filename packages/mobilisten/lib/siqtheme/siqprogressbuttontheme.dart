import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQProgressButtonTheme {
  // ignore_for_file: public_member_api_docs

  String? backgroundColor;
  String? tintColor;

  SIQProgressButtonTheme({
    this.backgroundColor,
    this.tintColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'tintColor': colorToHex(tintColor),
    };
  }
}
