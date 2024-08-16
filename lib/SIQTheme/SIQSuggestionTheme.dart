import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';

class SIQSuggestionTheme {
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
