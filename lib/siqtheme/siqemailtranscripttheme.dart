import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

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
