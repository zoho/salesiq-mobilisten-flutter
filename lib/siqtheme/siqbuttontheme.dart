import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQButtonTheme {
  // ignore_for_file: public_member_api_docs

  String? selectedColor;
  String? normalColor;

  SIQButtonTheme({
    this.selectedColor,
    this.normalColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'selectedColor': colorToHex(selectedColor),
      'normalColor': colorToHex(normalColor),
    };
  }
}
