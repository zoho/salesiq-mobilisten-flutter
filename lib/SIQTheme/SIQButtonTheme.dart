import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQButtonTheme {
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
