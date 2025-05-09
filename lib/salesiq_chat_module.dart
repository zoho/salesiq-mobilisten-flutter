import 'package:flutter/services.dart';

import 'package:salesiq_mobilisten/notification.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

class Chat {
  // ignore_for_file: public_member_api_docs

  final MethodChannel _channel = const MethodChannel("salesiq_chat_module");

  void showFeedbackAfterSkip(bool enable) {
    Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent("enable", () => enable);
    _channel.invokeMethod('showFeedbackAfterSkip', arguments);
  }

  void showFeedback(int upToDuration) {
    Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent("up_to_duration", () => upToDuration);
    _channel.invokeMethod('showFeedbackUpTo', arguments);
  }

  void hideQueueTime(bool value) {
    _channel.invokeMethod('hideQueueTime', value);
  }

  void open(SalesIQNotificationPayload data) {
    _channel.invokeMethod('showPayloadChat', data.toMap());
  }

  Future<SIQChat?> start(String question,
      [String? customChatId = null, String? departmentName = null]) async {
    return _channel
        .invokeMethod<Map<dynamic, dynamic>>('startNewChat', <String, dynamic>{
      'question': question,
      'custom_chat_id': customChatId,
      'department_name': departmentName,
    }).then((value) => SIQChat.fromMap(value));
  }

  @Deprecated(
      "This method is deprecated since v6.3.4, use initiateWithTrigger instead")
  Future<SIQChat?> startWithTrigger(
      [String? customChatId = null, String? departmentName = null]) async {
    return _channel.invokeMethod<Map<dynamic, dynamic>>(
        'startNewChatWithTrigger', <String, dynamic>{
      'custom_chat_id': customChatId,
      'department_name': departmentName,
    }).then((value) => SIQChat.fromMap(value));
  }

  Future<SIQChat?> initiateWithTrigger(String customActionName,
      [String? customChatId, String? departmentName]) async {
    return _channel.invokeMethod<Map<dynamic, dynamic>>(
        'initiateNewChatWithTrigger', <String, dynamic>{
      'custom_action_name': customActionName,
      'custom_chat_id': customChatId,
      'department_name': departmentName,
    }).then((value) => SIQChat.fromMap(value));
  }

  Future<SIQChat?> get(String chatId) async {
    return _channel
        .invokeMethod<Map<dynamic, dynamic>>('getChat', <String, dynamic>{
      'chat_id': chatId,
    }).then((value) => SIQChat.fromMap(value));
  }

  void setWaitingTime(int seconds) {
    _channel.invokeMethod('setChatWaitingTime', seconds);
  }

  void setVisibility(
      final ZSIQChatComponent chatComponent, final bool visible) {
    String componentName;
    switch (chatComponent) {
      case ZSIQChatComponent.operatorImage:
        componentName = "operator_image";
        break;
      case ZSIQChatComponent.rating:
        componentName = "rating";
        break;
      case ZSIQChatComponent.feedback:
        componentName = "feedback";
        break;
      case ZSIQChatComponent.screenshot:
        componentName = "screenshot";
        break;
      case ZSIQChatComponent.preChatForm:
        componentName = "pre_chat_form";
        break;
      case ZSIQChatComponent.visitorName:
        componentName = "visitor_name";
        break;
      case ZSIQChatComponent.emailTranscript:
        componentName = "email_transcript";
        break;
      case ZSIQChatComponent.fileShare:
        componentName = "file_share";
        break;
      case ZSIQChatComponent.mediaCapture:
        componentName = "media_capture";
        break;
      case ZSIQChatComponent.end:
        componentName = "end";
        break;
      case ZSIQChatComponent.endWhenInQueue:
        componentName = "end_when_in_queue";
        break;
      case ZSIQChatComponent.endWhenBotConnected:
        componentName = "end_when_bot_connected";
        break;
      case ZSIQChatComponent.endWhenOperatorConnected:
        componentName = "end_when_operator_connected";
        break;
      case ZSIQChatComponent.reopen:
        componentName = "reopen";
        break;
    }
    _channel.invokeMethod('setChatComponentVisibility', <String, dynamic>{
      'component_name': componentName,
      'visible': visible,
    });
  }
}

enum ZSIQChatComponent {
  operatorImage,
  rating,
  feedback,
  screenshot,
  preChatForm,
  visitorName,
  emailTranscript,
  fileShare,
  mediaCapture,
  end,
  endWhenInQueue,
  endWhenBotConnected,
  endWhenOperatorConnected,
  reopen
}
