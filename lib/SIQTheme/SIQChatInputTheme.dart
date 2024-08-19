import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQReplyViewTheme.dart';

class SIQChatInputTheme {
  String? backgroundColor;
  String? audioRecordHintBackgroundColor;
  String? audioRecordHintTextColor;
  String? textFieldBorderColor;
  String? textFieldTintColor;
  String? textFieldBackgroundColor;
  String? textFieldPlaceholderColor;
  String? textFieldTextColor;
  String? attachmentButtonBackgroundColor;
  String? recordButtonBackgroundColor;
  String? recordSoundPulseBackgroundColor;
  String? sendButtonBackgroundColor;
  String? buttonDisabledBackgroundColor;
  String? recordTimerBackgroundColor;
  String? recordTimerTextColor;
  String? recordTimerIndicatorColor;
  String? recordSlideTextColor;
  String? recordSlideIconColor;
  String? recordCancelTextColor;
  String? moreIconColor;
  String? sendIconColor;
  String? recordIconColor;
  SIQReplyViewTheme reply;
  SIQReplyViewTheme edit;

  SIQChatInputTheme({
    this.backgroundColor,
    this.audioRecordHintBackgroundColor,
    this.audioRecordHintTextColor,
    this.textFieldBorderColor,
    this.textFieldTintColor,
    this.textFieldBackgroundColor,
    this.textFieldPlaceholderColor,
    this.textFieldTextColor,
    this.attachmentButtonBackgroundColor,
    this.recordButtonBackgroundColor,
    this.recordSoundPulseBackgroundColor,
    this.sendButtonBackgroundColor,
    this.buttonDisabledBackgroundColor,
    this.recordTimerBackgroundColor,
    this.recordTimerTextColor,
    this.recordTimerIndicatorColor,
    this.recordSlideTextColor,
    this.recordSlideIconColor,
    this.recordCancelTextColor,
    this.moreIconColor,
    this.sendIconColor,
    this.recordIconColor,
    SIQReplyViewTheme? reply,
    SIQReplyViewTheme? edit,
  })  : reply = reply ?? SIQReplyViewTheme(),
        edit = edit ?? SIQReplyViewTheme();

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'audioRecordHintBackgroundColor':
          colorToHex(audioRecordHintBackgroundColor),
      'audioRecordHintTextColor': colorToHex(audioRecordHintTextColor),
      'textFieldBorderColor': colorToHex(textFieldBorderColor),
      'textFieldTintColor': colorToHex(textFieldTintColor),
      'textFieldBackgroundColor': colorToHex(textFieldBackgroundColor),
      'textFieldPlaceholderColor': colorToHex(textFieldPlaceholderColor),
      'textFieldTextColor': colorToHex(textFieldTextColor),
      'attachmentButtonBackgroundColor':
          colorToHex(attachmentButtonBackgroundColor),
      'recordButtonBackgroundColor': colorToHex(recordButtonBackgroundColor),
      'recordSoundPulseBackgroundColor':
          colorToHex(recordSoundPulseBackgroundColor),
      'sendButtonBackgroundColor': colorToHex(sendButtonBackgroundColor),
      'buttonDisabledBackgroundColor':
          colorToHex(buttonDisabledBackgroundColor),
      'recordTimerBackgroundColor': colorToHex(recordTimerBackgroundColor),
      'recordTimerTextColor': colorToHex(recordTimerTextColor),
      'recordTimerIndicatorColor': colorToHex(recordTimerIndicatorColor),
      'recordSlideTextColor': colorToHex(recordSlideTextColor),
      'recordSlideIconColor': colorToHex(recordSlideIconColor),
      'recordCancelTextColor': colorToHex(recordCancelTextColor),
      'moreIconColor': colorToHex(moreIconColor),
      'sendIconColor': colorToHex(sendIconColor),
      'recordIconColor': colorToHex(recordIconColor),
      'Reply': reply.toMap(),
      'Edit': edit.toMap(),
    };
  }
}
