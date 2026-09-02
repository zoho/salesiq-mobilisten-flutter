import 'package:flutter/services.dart';

/// Provides APIs to register and manage custom chat actions used in
/// display cards.
///
/// Mirrors the native `ZohoSalesIQ.ChatActions` namespace (Android
/// `ZohoSalesIQ.ChatActions`, iOS `SIQActionRegistry`). Access this via
/// [ZohoSalesIQ.chatActions].
///
/// Registration by name reuses the existing name-based bridge; object-based
/// registration (supplying a label and type) requires a native-bridge
/// addition and is tracked in `MOBILISTEN_FLUTTER_TIER2_NATIVE_SPEC.md`.
class ChatActions {
  final MethodChannel _channel = const MethodChannel('salesiq_chatactions_module');

  /// Registers a chat action identified by [actionName].
  void register(String actionName) {
    _channel.invokeMethod('registerChatAction', actionName);
  }

  /// Unregisters the chat action identified by [actionName].
  void unregister(String actionName) {
    _channel.invokeMethod('unregisterChatAction', actionName);
  }

  /// Unregisters all previously registered chat actions.
  void unregisterAll() {
    _channel.invokeMethod('unregisterAllChatActions');
  }

  /// Sets the [timeout], in seconds, applied to all chat actions.
  void setTimeout(int timeout) {
    _channel.invokeMethod('setChatActionTimeout', timeout);
  }
}
