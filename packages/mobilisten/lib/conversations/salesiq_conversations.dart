import 'dart:async';

import 'package:flutter/services.dart';
import 'package:salesiq_mobilisten_core/salesiq_conversation.dart';
import 'package:salesiq_mobilisten_core/salesiq_conversation_attributes.dart';
import 'package:salesiq_mobilisten_core/salesiq_department.dart';

/// Callback to supply conversation secret fields on demand.
///
/// Return `null` to indicate that no value is provided for the given
/// [conversation].
typedef SalesIQSecretFieldsProvider = FutureOr<Map<String, String>?> Function(
    SalesIQConversation conversation);

/// Callback to supply conversation custom info on demand.
///
/// Return `null` to indicate that no value is provided for the given
/// [conversation].
typedef SalesIQDisplayFieldsProvider = FutureOr<Map<String, String>?> Function(
    SalesIQConversation conversation);

/// Configuration for conversation-level data provider callbacks.
class SalesIQConversationDataProvider {
  /// Invoked by the SDK when secret fields are requested.
  final SalesIQSecretFieldsProvider? getSecretFields;

  /// Invoked by the SDK when custom info is requested.
  final SalesIQDisplayFieldsProvider? getDisplayFields;

  /// Creates a conversation data provider.
  const SalesIQConversationDataProvider({
    this.getSecretFields,
    this.getDisplayFields,
  });
}

/// This class provides APIs to manage conversations in the Zoho SalesIQ SDK.
class Conversation {
  final MethodChannel _channel =
      const MethodChannel("salesiq_conversations_module");

  static SalesIQConversationDataProvider? _provider;
  static bool _methodHandlerRegistered = false;

  /// Applies the specified meta data to all conversations. You can use this to customize the operator's name, display picture, additional information, and associate specific departments.
  void setAttributes(SalesIQConversationAttributes attributes) async {
    final attributesMap = await attributes.toMap();
    _channel.invokeMethod('setAttribute', attributesMap);
  }

  /// Returns a list of departments (Instances of [SalesIQDepartment]).
  Future<List<SalesIQDepartment>> getDepartments() async {
    return await _channel
        .invokeMethod('fetchDepartments')
        .then((onValue) => SalesIQDepartment.fromList(onValue));
  }

  /// Registers a conversation-level data provider.
  ///
  /// The callback receives a non-null [SalesIQConversation] payload.
  ///
  /// Pass `null` to unregister the currently set provider.
  Future<void> setDataProvider(
      SalesIQConversationDataProvider? provider) async {
    _provider = provider;
    if (!_methodHandlerRegistered) {
      _channel.setMethodCallHandler(_handleProviderCallback);
      _methodHandlerRegistered = true;
    }
    await _channel.invokeMethod('setDataProvider', <String, dynamic>{
      'secretFieldsEnabled': provider?.getSecretFields != null,
      'customInfoEnabled': provider?.getDisplayFields != null,
    });
  }

  Future<dynamic> _handleProviderCallback(MethodCall call) async {
    switch (call.method) {
      case 'onSecretFieldsRequested':
        if (_provider?.getSecretFields == null) {
          return null;
        }
        final Map<dynamic, dynamic>? args =
            call.arguments as Map<dynamic, dynamic>?;
        final Map<dynamic, dynamic>? conversationMap =
            args?['conversation'] as Map<dynamic, dynamic>?;
        if (conversationMap == null) {
          return null;
        }
        final SalesIQConversation? conversation =
            SalesIQConversation.fromMap(conversationMap) ??
                SalesIQChatConversation(
                  conversationMap['id']?.toString(),
                  conversationMap['customConversationId']?.toString() ??
                      conversationMap['custom_chat_id']?.toString(),
                  conversationMap['question']?.toString(),
                  null,
                  null,
                  null,
                  conversationMap['departmentName']?.toString(),
                  null,
                  null,
                  -1,
                  null,
                  false,
                  null,
                  0,
                  null,
                );
        if (conversation == null) {
          return null;
        }
        final response = await _provider!.getSecretFields!(conversation);
        return response;
      case 'onDisplayFieldsRequested':
        if (_provider?.getDisplayFields == null) {
          return null;
        }
        final Map<dynamic, dynamic>? args =
            call.arguments as Map<dynamic, dynamic>?;
        final Map<dynamic, dynamic>? conversationMap =
            args?['conversation'] as Map<dynamic, dynamic>?;
        if (conversationMap == null) {
          return null;
        }
        final SalesIQConversation? conversation =
            SalesIQConversation.fromMap(conversationMap) ??
                SalesIQChatConversation(
                  conversationMap['id']?.toString(),
                  conversationMap['customConversationId']?.toString() ??
                      conversationMap['custom_chat_id']?.toString(),
                  conversationMap['question']?.toString(),
                  null,
                  null,
                  null,
                  conversationMap['departmentName']?.toString(),
                  null,
                  null,
                  -1,
                  null,
                  false,
                  null,
                  0,
                  null,
                );
        if (conversation == null) {
          return null;
        }
        final response = await _provider!.getDisplayFields!(conversation);
        return response;
      default:
        throw MissingPluginException();
    }
  }
}
