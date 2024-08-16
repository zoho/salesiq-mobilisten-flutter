import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';

class SIQInputCardTheme {
  String? titleColor;
  String? textFieldTextColor;
  String? textFieldBackgroundColor;
  String? textFieldPlaceholderColor;
  String? sendButtonBackgroundColor;
  String? sendButtonIconColor;
  String? separatorColor;

  SIQInputCardTheme({
    this.titleColor,
    this.textFieldTextColor,
    this.textFieldBackgroundColor,
    this.textFieldPlaceholderColor,
    this.sendButtonBackgroundColor,
    this.sendButtonIconColor,
    this.separatorColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'titleColor': colorToHex(titleColor),
      'textFieldTextColor': colorToHex(textFieldTextColor),
      'textFieldBackgroundColor': colorToHex(textFieldBackgroundColor),
      'textFieldPlaceholderColor': colorToHex(textFieldPlaceholderColor),
      'sendButtonBackgroundColor': colorToHex(sendButtonBackgroundColor),
      'sendButtonIconColor': colorToHex(sendButtonIconColor),
      'separatorColor': colorToHex(separatorColor),
    };
  }
}