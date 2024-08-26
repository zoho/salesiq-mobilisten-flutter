import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

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
