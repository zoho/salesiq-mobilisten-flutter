import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQSelectionComponentTheme {
  // ignore_for_file: public_member_api_docs

  String? textColor;
  String? accessoryColor;
  String? backgroundColor;
  String? selectionBackgroundColor;
  String? buttonTextColor;
  String? buttonBackgroundColor;
  String? linkTextColor;

  SIQSelectionComponentTheme({
    this.textColor,
    this.accessoryColor,
    this.backgroundColor,
    this.selectionBackgroundColor,
    this.buttonTextColor,
    this.buttonBackgroundColor,
    this.linkTextColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'textColor': colorToHex(textColor),
      'accessoryColor': colorToHex(accessoryColor),
      'backgroundColor': colorToHex(backgroundColor),
      'selectionBackgroundColor': colorToHex(selectionBackgroundColor),
      'buttonTextColor': colorToHex(buttonTextColor),
      'buttonBackgroundColor': colorToHex(buttonBackgroundColor),
      'linkTextColor': colorToHex(linkTextColor),
    };
  }
}
