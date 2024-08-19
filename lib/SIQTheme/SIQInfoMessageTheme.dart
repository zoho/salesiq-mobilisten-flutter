import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';

class SIQInfoMessageTheme {
  String? textColor;
  String? lineColor;

  SIQInfoMessageTheme({
    this.textColor,
    this.lineColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'textColor': colorToHex(textColor),
      'lineColor': colorToHex(lineColor),
    };
  }
}
