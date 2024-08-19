import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQMessageTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQHandOffBannerTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQBannerTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQQueueBannerTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQChatInputTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQAttachmentSheetTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQChatScrollButtonTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQEmailTranscriptTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQLogViewTheme.dart';

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
