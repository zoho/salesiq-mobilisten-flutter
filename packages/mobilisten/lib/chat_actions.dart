import 'package:flutter/services.dart';

/// Provides the APIs to register and manage the custom chat actions that cards
/// use. The visitor triggers a chat action by tapping it on an operator or bot
/// card.
///
/// It matches the native `ZohoSalesIQ.ChatActions` namespace on Android and
/// `SIQActionRegistry` on iOS. To use it, call [ZohoSalesIQ.chatActions].
class ChatActions {
  final MethodChannel _channel = const MethodChannel('salesiq_chatactions_module');

  /// Registers the chat action named [actionName].
  void register(String actionName) {
    _channel.invokeMethod('registerChatAction', actionName);
  }

  /// Unregisters the chat action named [actionName].
  void unregister(String actionName) {
    _channel.invokeMethod('unregisterChatAction', actionName);
  }

  /// Unregisters all the chat actions that were registered.
  void unregisterAll() {
    _channel.invokeMethod('unregisterAllChatActions');
  }

  /// Sets the [timeout], in seconds, for all chat actions.
  void setTimeout(int timeout) {
    _channel.invokeMethod('setChatActionTimeout', timeout);
  }
}
