import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';

class SIQAttachmentSheetTheme {
  String? backgroundColor;
  String? overlayColor;
  String? tintColor;
  String? separatorColor;

  SIQAttachmentSheetTheme({
    this.backgroundColor,
    this.overlayColor,
    this.tintColor,
    this.separatorColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'overlayColor': colorToHex(overlayColor),
      'tintColor': colorToHex(tintColor),
      'separatorColor': colorToHex(separatorColor),
    };
  }
}