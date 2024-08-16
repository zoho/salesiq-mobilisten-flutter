import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';

class SIQFAQListItemTheme {
  String? backgroundColor;
  String? titleTextColor;
  String? subtitleTextColor;
  String? subtitlePartitionColor;
  String? likePendingColor;
  String? likedColor;
  String? separatorColor;

  SIQFAQListItemTheme({
    this.backgroundColor,
    this.titleTextColor,
    this.subtitleTextColor,
    this.subtitlePartitionColor,
    this.likePendingColor,
    this.likedColor,
    this.separatorColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'titleTextColor': colorToHex(titleTextColor),
      'subtitleTextColor': colorToHex(subtitleTextColor),
      'subtitlePartitionColor': colorToHex(subtitlePartitionColor),
      'likePendingColor': colorToHex(likePendingColor),
      'likedColor': colorToHex(likedColor),
      'separatorColor': colorToHex(separatorColor),
    };
  }
}