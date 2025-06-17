import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';
import 'package:salesiq_mobilisten/siqtheme/siqloadmoreviewtheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqprogressbuttontheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqreplyviewtheme.dart';

class SIQMessageCommonTheme {
  // ignore_for_file: public_member_api_docs

  int? botTypingIndicatorStyle;
  String? messageSenderNameColor;

  String? outgoingBackgroundColor;
  String? outgoingTextColor;
  String? outgoingBorderColor;
  String? outgoingTimeTextColor;
  String? outgoingTimeIconColor;

  String? incomingBackgroundColor;
  String? incomingTextColor;
  String? incomingBorderColor;
  String? incomingTimeTextColor;
  String? incomingTimeIconColor;
  String? incomingTextTimeColor;
  String? outgoingTextTimeColor;
  String? messageStatusIconColor;

  SIQProgressButtonTheme incomingProgressButton;
  SIQProgressButtonTheme outgoingProgressButton;

  SIQReplyViewTheme outgoingRepliedMessage;
  SIQReplyViewTheme incomingRepliedMessage;

  String? incomingMessageEditedTagColor;
  String? outgoingMessageEditedTagColor;

  String? incomingMessageTimeStampColor;
  String? outgoingMessageTimeStampColor;

  String? incomingDeletedMessageColor;
  String? outgoingDeletedMessageColor;

  String? deletingMessageTitleColor;
  String? deliveryStatusIconColor;
  String? repliedMessageHighLightColor;
  String? incomingMessageReplyIconColor;
  String? outgoingMessageReplyIconColor;

  SIQLoadMoreViewTheme loadMore;

  SIQMessageCommonTheme({
    this.botTypingIndicatorStyle,
    this.messageSenderNameColor,
    this.outgoingBackgroundColor,
    this.outgoingTextColor,
    this.outgoingBorderColor,
    this.outgoingTimeTextColor,
    this.outgoingTimeIconColor,
    this.incomingBackgroundColor,
    this.incomingTextColor,
    this.incomingBorderColor,
    this.incomingTimeTextColor,
    this.incomingTimeIconColor,
    this.incomingTextTimeColor,
    this.outgoingTextTimeColor,
    this.messageStatusIconColor,
    SIQProgressButtonTheme? incomingProgressButton,
    SIQProgressButtonTheme? outgoingProgressButton,
    SIQReplyViewTheme? outgoingRepliedMessage,
    SIQReplyViewTheme? incomingRepliedMessage,
    this.incomingMessageEditedTagColor,
    this.outgoingMessageEditedTagColor,
    this.incomingMessageTimeStampColor,
    this.outgoingMessageTimeStampColor,
    this.incomingDeletedMessageColor,
    this.outgoingDeletedMessageColor,
    this.deletingMessageTitleColor,
    this.deliveryStatusIconColor,
    this.repliedMessageHighLightColor,
    this.incomingMessageReplyIconColor,
    this.outgoingMessageReplyIconColor,
    SIQLoadMoreViewTheme? loadMore,
  })  : incomingProgressButton =
            incomingProgressButton ?? SIQProgressButtonTheme(),
        outgoingProgressButton =
            outgoingProgressButton ?? SIQProgressButtonTheme(),
        outgoingRepliedMessage = outgoingRepliedMessage ?? SIQReplyViewTheme(),
        incomingRepliedMessage = incomingRepliedMessage ?? SIQReplyViewTheme(),
        loadMore = loadMore ?? SIQLoadMoreViewTheme();

  Map<String, dynamic> toMap() {
    return {
      'botTypingIndicatorStyle': botTypingIndicatorStyle,
      'messageSenderNameColor': colorToHex(messageSenderNameColor),
      'outgoingBackgroundColor': colorToHex(outgoingBackgroundColor),
      'outgoingTextColor': colorToHex(outgoingTextColor),
      'outgoingBorderColor': colorToHex(outgoingBorderColor),
      'outgoingTimeTextColor': colorToHex(outgoingTimeTextColor),
      'outgoingTimeIconColor': colorToHex(outgoingTimeIconColor),
      'incomingBackgroundColor': colorToHex(incomingBackgroundColor),
      'incomingTextColor': colorToHex(incomingTextColor),
      'incomingBorderColor': colorToHex(incomingBorderColor),
      'incomingTimeTextColor': colorToHex(incomingTimeTextColor),
      'incomingTimeIconColor': colorToHex(incomingTimeIconColor),
      'incomingTextTimeColor': colorToHex(incomingTextTimeColor),
      'outgoingTextTimeColor': colorToHex(outgoingTextTimeColor),
      'messageStatusIconColor': colorToHex(messageStatusIconColor),
      'incomingProgressButton': incomingProgressButton.toMap(),
      'outgoingProgressButton': outgoingProgressButton.toMap(),
      'outgoingRepliedMessage': outgoingRepliedMessage.toMap(),
      'incomingRepliedMessage': incomingRepliedMessage.toMap(),
      'incomingMessageEditedTagColor':
          colorToHex(incomingMessageEditedTagColor),
      'outgoingMessageEditedTagColor':
          colorToHex(outgoingMessageEditedTagColor),
      'incomingMessageTimeStampColor':
          colorToHex(incomingMessageTimeStampColor),
      'outgoingMessageTimeStampColor':
          colorToHex(outgoingMessageTimeStampColor),
      'incomingDeletedMessageColor': colorToHex(incomingDeletedMessageColor),
      'outgoingDeletedMessageColor': colorToHex(outgoingDeletedMessageColor),
      'deletingMessageTitleColor': colorToHex(deletingMessageTitleColor),
      'deliveryStatusIconColor': colorToHex(deliveryStatusIconColor),
      'repliedMessageHighLightColor': colorToHex(repliedMessageHighLightColor),
      'incomingMessageReplyIconColor':
          colorToHex(incomingMessageReplyIconColor),
      'outgoingMessageReplyIconColor':
          colorToHex(outgoingMessageReplyIconColor),
      'LoadMore': loadMore.toMap(),
    };
  }
}
