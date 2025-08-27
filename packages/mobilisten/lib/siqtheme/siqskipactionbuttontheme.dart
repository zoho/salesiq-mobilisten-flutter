import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQSkipActionButtonTheme {
  // ignore_for_file: public_member_api_docs

  String? textColor;
  String? borderColor;
  String? backgroundColor;
  double? cornerRadius;

  SIQSkipActionButtonTheme({
    this.textColor,
    this.borderColor,
    this.backgroundColor,
    this.cornerRadius,
  });

  Map<String, dynamic> toMap() {
    return {
      'textColor': colorToHex(textColor),
      'borderColor': colorToHex(borderColor),
      'backgroundColor': colorToHex(backgroundColor),
      'cornerRadius': cornerRadius,
    };
  }
}
