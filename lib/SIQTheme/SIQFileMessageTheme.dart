import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';

class SIQFileMessageTheme {
  String? incomingTitleColor;
  String? incomingSubTitleColor;
  String? outgoingTitleColor;
  String? outgoingSubTitleColor;

  String? incomingFileViewBackgroundColor;
  String? outgoingFileViewBackgroundColor;

  String? incomingCommentBackgoundColor;
  String? outgoingCommentBackgoundColor;

  SIQFileMessageTheme({
    this.incomingTitleColor,
    this.incomingSubTitleColor,
    this.outgoingTitleColor,
    this.outgoingSubTitleColor,
    this.incomingFileViewBackgroundColor,
    this.outgoingFileViewBackgroundColor,
    this.incomingCommentBackgoundColor,
    this.outgoingCommentBackgoundColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'incomingTitleColor': colorToHex(incomingTitleColor),
      'incomingSubTitleColor': colorToHex(incomingSubTitleColor),
      'outgoingTitleColor': colorToHex(outgoingTitleColor),
      'outgoingSubTitleColor': colorToHex(outgoingSubTitleColor),
      'incomingFileViewBackgroundColor':
          colorToHex(incomingFileViewBackgroundColor),
      'outgoingFileViewBackgroundColor':
          colorToHex(outgoingFileViewBackgroundColor),
      'incomingCommentBackgoundColor':
          colorToHex(incomingCommentBackgoundColor),
      'outgoingCommentBackgoundColor':
          colorToHex(outgoingCommentBackgoundColor),
    };
  }
}
