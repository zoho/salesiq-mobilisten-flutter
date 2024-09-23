import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQEmptyViewTheme {
  // ignore_for_file: public_member_api_docs

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
