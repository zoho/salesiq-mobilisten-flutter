import 'package:flutter/services.dart';
import 'package:salesiq_mobilisten/notification.dart';

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
}
