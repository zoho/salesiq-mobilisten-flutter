import 'package:flutter/services.dart';
import 'package:salesiq_mobilisten/notification.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

class Chat {
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

  Future<SIQChat> start(
      String question, [String? customChatId = null, String? departmentName = null]) async {
    return _channel.invokeMethod('startNewChat', <String, dynamic>{
      'question': question,
      'custom_chat_id': customChatId,
      'department_name': departmentName,
    }).then((value) => SIQChat.fromMap(value));
  }

  Future<SIQChat> startWithTrigger(
      [String? customChatId = null, String? departmentName = null]) async {
    return _channel.invokeMethod('startNewChatWithTrigger', <String, dynamic>{
      'custom_chat_id': customChatId,
      'department_name': departmentName,
    }).then((value) => SIQChat.fromMap(value));
  }

  Future<SIQChat> get(String chatId) async {
    return _channel.invokeMethod('getChat', <String, dynamic>{
      'chat_id': chatId,
    }).then((value) => SIQChat.fromMap(value));
  }

  void setWaitingTime(int seconds) {
    _channel.invokeMethod('setChatWaitingTime', seconds);
  }
}
