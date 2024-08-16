import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';

class SIQEmailTranscriptTheme {
  String? textFieldTintColor;

  SIQEmailTranscriptTheme({
    this.textFieldTintColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'textFieldTintColor': colorToHex(textFieldTintColor),
    };
  }
}