import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';
import 'package:salesiq_mobilisten/siqtheme/siqmessagetheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqhandoffbannertheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqbannertheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqqueuebannertheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqchatinputtheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqattachmentsheettheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqchatscrollbuttontheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqemailtranscripttheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqlogviewtheme.dart';

class SIQChatWindowTheme {
  String? backgroundColor;
  String? backgroundImage;
  SIQMessageTheme message;
  SIQHandOffBannerTheme handOffBanner;
  SIQBannerTheme banner;
  SIQQueueBannerTheme queueBanner;
  SIQChatInputTheme input;
  SIQAttachmentSheetTheme attachmentsSheet;
  SIQChatScrollButtonTheme scrollButton;
  SIQEmailTranscriptTheme emailTranscript;
  SIQLogViewTheme debugLog;

  SIQChatWindowTheme({
    this.backgroundColor,
    this.backgroundImage,
    SIQMessageTheme? message,
    SIQHandOffBannerTheme? handOffBanner,
    SIQBannerTheme? banner,
    SIQQueueBannerTheme? queueBanner,
    SIQChatInputTheme? input,
    SIQAttachmentSheetTheme? attachmentsSheet,
    SIQChatScrollButtonTheme? scrollButton,
    SIQEmailTranscriptTheme? emailTranscript,
    SIQLogViewTheme? debugLog,
  })  : message = message ?? SIQMessageTheme(),
        handOffBanner = handOffBanner ?? SIQHandOffBannerTheme(),
        banner = banner ?? SIQBannerTheme(),
        queueBanner = queueBanner ?? SIQQueueBannerTheme(),
        input = input ?? SIQChatInputTheme(),
        attachmentsSheet = attachmentsSheet ?? SIQAttachmentSheetTheme(),
        scrollButton = scrollButton ?? SIQChatScrollButtonTheme(),
        emailTranscript = emailTranscript ?? SIQEmailTranscriptTheme(),
        debugLog = debugLog ?? SIQLogViewTheme();

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'backgroundImage': colorToHex(backgroundImage),
      'Message': message.toMap(),
      'HandOffBanner': handOffBanner.toMap(),
      'Banner': banner.toMap(),
      'QueueBanner': queueBanner.toMap(),
      'Input': input.toMap(),
      'AttachmentsSheet': attachmentsSheet.toMap(),
      'ScrollButton': scrollButton.toMap(),
      'EmailTranscript': emailTranscript.toMap(),
      'DebugLog': debugLog.toMap(),
    };
  }
}
