import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';

class SIQSkipActionButtonTheme {
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
