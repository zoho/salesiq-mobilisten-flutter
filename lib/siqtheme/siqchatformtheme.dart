import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQChatFormTheme {
  // ignore_for_file: public_member_api_docs

  String? backgroundColor;
  String? textFieldBackgroundColor;
  String? textFieldTextColor;
  String? textFieldTintColor;
  String? textFieldPlaceholderColor;
  String? textFieldTitleColor;
  String? textFieldRequiredIndicatorColor;
  String? errorColor;
  String? submitButtonBackgroundColor;
  String? submitButtonTextColor;
  String? campaignOptInTextColor;
  String? checkboxCheckedColor;
  String? checkboxUncheckedColor;

  SIQChatFormTheme({
    this.backgroundColor,
    this.textFieldBackgroundColor,
    this.textFieldTextColor,
    this.textFieldTintColor,
    this.textFieldPlaceholderColor,
    this.textFieldTitleColor,
    this.textFieldRequiredIndicatorColor,
    this.errorColor,
    this.submitButtonBackgroundColor,
    this.submitButtonTextColor,
    this.campaignOptInTextColor,
    this.checkboxCheckedColor,
    this.checkboxUncheckedColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'textFieldBackgroundColor': colorToHex(textFieldBackgroundColor),
      'textFieldTextColor': colorToHex(textFieldTextColor),
      'textFieldTintColor': colorToHex(textFieldTintColor),
      'textFieldPlaceholderColor': colorToHex(textFieldPlaceholderColor),
      'textFieldTitleColor': colorToHex(textFieldTitleColor),
      'textFieldRequiredIndicatorColor':
          colorToHex(textFieldRequiredIndicatorColor),
      'errorColor': colorToHex(errorColor),
      'submitButtonBackgroundColor': colorToHex(submitButtonBackgroundColor),
      'submitButtonTextColor': colorToHex(submitButtonTextColor),
      'campaignOptInTextColor': colorToHex(campaignOptInTextColor),
      'checkboxCheckedColor': colorToHex(checkboxCheckedColor),
      'checkboxUncheckedColor': colorToHex(checkboxUncheckedColor),
    };
  }
}
