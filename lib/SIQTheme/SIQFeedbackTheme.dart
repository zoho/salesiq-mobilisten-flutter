import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQFeedbackTheme {
  String? backgroundColor;
  String? primaryTextColor;
  String? secondaryTextColor;
  String? skipButtonTextColor;
  String? submitButtonTextColor;
  String? submitButtonBackgroundColor;
  String? feedbackTextFieldTintColor;
  String? feedbackPlaceholderTextColor;

  SIQFeedbackTheme({
    this.backgroundColor,
    this.primaryTextColor,
    this.secondaryTextColor,
    this.skipButtonTextColor,
    this.submitButtonTextColor,
    this.submitButtonBackgroundColor,
    this.feedbackTextFieldTintColor,
    this.feedbackPlaceholderTextColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'primaryTextColor': colorToHex(primaryTextColor),
      'secondaryTextColor': colorToHex(secondaryTextColor),
      'skipButtonTextColor': colorToHex(skipButtonTextColor),
      'submitButtonTextColor': colorToHex(submitButtonTextColor),
      'submitButtonBackgroundColor': colorToHex(submitButtonBackgroundColor),
      'feedbackTextFieldTintColor': colorToHex(feedbackTextFieldTintColor),
      'feedbackPlaceholderTextColor': colorToHex(feedbackPlaceholderTextColor),
    };
  }
}
