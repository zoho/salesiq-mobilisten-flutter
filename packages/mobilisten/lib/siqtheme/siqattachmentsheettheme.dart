import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQAttachmentSheetTheme {
  // ignore_for_file: public_member_api_docs

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
