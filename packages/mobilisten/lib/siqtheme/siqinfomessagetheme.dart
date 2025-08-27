import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQInfoMessageTheme {
  // ignore_for_file: public_member_api_docs

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
