import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQSuggestionTheme {
  // ignore_for_file: public_member_api_docs

  String? textColor;
  String? borderColor;
  String? backgroundColor;
  double? cornerRadius;
  int? displayStyle;

  SIQSuggestionTheme({
    this.textColor,
    this.borderColor,
    this.backgroundColor,
    this.cornerRadius,
    this.displayStyle,
  });

  Map<String, dynamic> toMap() {
    return {
      'textColor': colorToHex(textColor),
      'borderColor': colorToHex(borderColor),
      'backgroundColor': colorToHex(backgroundColor),
      'cornerRadius': cornerRadius,
      'displayStyle': displayStyle,
    };
  }
}
