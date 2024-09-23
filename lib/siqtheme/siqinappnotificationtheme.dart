import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQInAppNotificationTheme {
  // ignore_for_file: public_member_api_docs

  String? titleColor;
  String? subtitleColor;
  String? backgroundColor;
  String? imageBackgroundColor;
  double? cornerRadius;
  double? imageCornerRadius;

  SIQInAppNotificationTheme({
    this.titleColor,
    this.subtitleColor,
    this.backgroundColor,
    this.imageBackgroundColor,
    this.cornerRadius,
    this.imageCornerRadius,
  });

  Map<String, dynamic> toMap() {
    return {
      'titleColor': colorToHex(backgroundColor),
      'subtitleColor': colorToHex(backgroundColor),
      'backgroundColor': colorToHex(backgroundColor),
      'imageBackgroundColor': colorToHex(backgroundColor),
      'cornerRadius': cornerRadius,
      'imageCornerRadius': imageCornerRadius,
    };
  }
}
