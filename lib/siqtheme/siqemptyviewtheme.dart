import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQEmptyViewTheme {
  String? backgroundColor;
  String? chatButtonBackgroundColor;
  String? chatButtonTitleColor;
  String? textColor;

  SIQEmptyViewTheme({
    this.backgroundColor,
    this.chatButtonBackgroundColor,
    this.chatButtonTitleColor,
    this.textColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'chatButtonBackgroundColor': colorToHex(chatButtonBackgroundColor),
      'chatButtonTitleColor': colorToHex(chatButtonTitleColor),
      'textColor': colorToHex(textColor),
    };
  }
}
