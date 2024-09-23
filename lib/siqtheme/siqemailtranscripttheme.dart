import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQEmailTranscriptTheme {
  // ignore_for_file: public_member_api_docs

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
