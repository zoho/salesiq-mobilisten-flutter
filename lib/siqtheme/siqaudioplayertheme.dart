import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQAudioPlayerTheme {
  String? thumbColor;
  String? playButtonBackgroundColor;
  String? incomingTrackColor;
  String? outgoingTrackColor;

  String? incomingButtonIconColor;
  String? outgoingButtonIconColor;

  String? outgoingDurationTextColor;
  String? incomingDurationTextColor;

  SIQAudioPlayerTheme({
    this.thumbColor,
    this.playButtonBackgroundColor,
    this.incomingTrackColor,
    this.outgoingTrackColor,
    this.incomingButtonIconColor,
    this.outgoingButtonIconColor,
    this.outgoingDurationTextColor,
    this.incomingDurationTextColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'thumbColor': colorToHex(thumbColor),
      'playButtonBackgroundColor': colorToHex(playButtonBackgroundColor),
      'incomingTrackColor': colorToHex(incomingTrackColor),
      'outgoingTrackColor': colorToHex(outgoingTrackColor),
      'incomingButtonIconColor': colorToHex(incomingButtonIconColor),
      'outgoingButtonIconColor': colorToHex(outgoingButtonIconColor),
      'outgoingDurationTextColor': colorToHex(outgoingDurationTextColor),
      'incomingDurationTextColor': colorToHex(incomingDurationTextColor),
    };
  }
}
