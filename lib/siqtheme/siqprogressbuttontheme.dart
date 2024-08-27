import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

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
