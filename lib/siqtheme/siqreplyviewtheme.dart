import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQReplyViewTheme {
  String? backgroundColor;
  String? titleColor;
  String? subtitleColor;
  String? verticalLine;
  String? messageTypeIconColor;
  String? closeButton;

  SIQReplyViewTheme({
    this.backgroundColor,
    this.titleColor,
    this.subtitleColor,
    this.verticalLine,
    this.messageTypeIconColor,
    this.closeButton,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'titleColor': colorToHex(titleColor),
      'subtitleColor': colorToHex(subtitleColor),
      'verticalLine': colorToHex(verticalLine),
      'messageTypeIconColor': colorToHex(messageTypeIconColor),
      'closeButton': colorToHex(closeButton),
    };
  }
}
