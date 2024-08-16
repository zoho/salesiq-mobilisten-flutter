import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';

class SIQQueueBannerTheme {
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
      'positionContainerBackgroundColor': colorToHex(positionContainerBackgroundColor),
    };
  }
}