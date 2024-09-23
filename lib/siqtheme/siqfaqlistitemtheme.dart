import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQFAQListItemTheme {
  // ignore_for_file: public_member_api_docs

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
