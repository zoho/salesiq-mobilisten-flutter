import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';

class SIQProgressButtonTheme {
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