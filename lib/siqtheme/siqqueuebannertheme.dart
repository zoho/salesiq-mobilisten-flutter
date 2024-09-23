import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQQueueBannerTheme {
  // ignore_for_file: public_member_api_docs

  String? backgroundColor;
  String? titleColor;
  String? subtitleColor;
  String? subtitleTimeColor;
  String? positionTextColor;
  String? positionSubtitleColor;
  String? positionContainerBackgroundColor;

  SIQQueueBannerTheme({
    this.backgroundColor,
    this.titleColor,
    this.subtitleColor,
    this.subtitleTimeColor,
    this.positionTextColor,
    this.positionSubtitleColor,
    this.positionContainerBackgroundColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'titleColor': colorToHex(titleColor),
      'subtitleColor': colorToHex(subtitleColor),
      'subtitleTimeColor': colorToHex(subtitleTimeColor),
      'positionTextColor': colorToHex(positionTextColor),
      'positionSubtitleColor': colorToHex(positionSubtitleColor),
      'positionContainerBackgroundColor':
          colorToHex(positionContainerBackgroundColor),
    };
  }
}
