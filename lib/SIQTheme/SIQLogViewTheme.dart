import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';

class SIQLogViewTheme {
  String? backgroundColor;
  String? titleColor;
  String? textViewColor;
  String? textViewBackgroundColor;
  String? sendTitleColor;
  String? sendBackgroundColor;
  String? cancelTitleColor;

  SIQLogViewTheme({
    this.backgroundColor,
    this.titleColor,
    this.textViewColor,
    this.textViewBackgroundColor,
    this.sendTitleColor,
    this.sendBackgroundColor,
    this.cancelTitleColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'titleColor': colorToHex(titleColor),
      'textViewColor': colorToHex(textViewColor),
      'textViewBackgroundColor': colorToHex(textViewBackgroundColor),
      'sendTitleColor': colorToHex(sendTitleColor),
      'sendBackgroundColor': colorToHex(sendBackgroundColor),
      'cancelTitleColor': colorToHex(cancelTitleColor),
    };
  }
}
