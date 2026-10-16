import 'dart:async';

import 'package:flutter/services.dart';
import 'package:salesiq_mobilisten_core/salesiq_conversation.dart';
import 'package:salesiq_mobilisten_core/salesiq_conversation_attributes.dart';
import 'package:salesiq_mobilisten_core/salesiq_department.dart';

/// Called when the SDK needs the secret fields of a conversation.
///
/// Return `null` when you have no value for the given [conversation].
typedef SalesIQSecretFieldsProvider = FutureOr<Map<String, String>?> Function(
    SalesIQConversation conversation);

/// Called when the SDK needs the display fields of a conversation.
///
/// Return `null` when you have no value for the given [conversation].
typedef SalesIQDisplayFieldsProvider = FutureOr<Map<String, String>?> Function(
    SalesIQConversation conversation);

/// The data provider callbacks for conversations.
class SalesIQConversationDataProvider {
  /// Called when the SDK requests the secret fields.
  final SalesIQSecretFieldsProvider? getSecretFields;

  /// Called when the SDK requests the display fields.
  final SalesIQDisplayFieldsProvider? getDisplayFields;

  /// Creates a conversation data provider.
  const SalesIQConversationDataProvider({
    this.getSecretFields,
    this.getDisplayFields,
  });
}

/// Provides the APIs to manage conversations in the Zoho SalesIQ SDK.
class Conversation {
  final MethodChannel _channel =
      const MethodChannel("salesiq_conversations_module");

  static SalesIQConversationDataProvider? _provider;
  static bool _methodHandlerRegistered = false;

  /// Applies the given metadata, [attributes], to all conversations. Use it to
  /// customize the operator's name, display picture, and additional
  /// information, and to link specific departments.
  void setAttributes(SalesIQConversationAttributes attributes) async {
    final attributesMap = await attributes.toMap();
    _channel.invokeMethod('setAttribute', attributesMap);
  }

  /// Turns the conversation, or chat, history on or off, based on the value of
  /// [visibility].
  void setVisibility(bool visibility) {
    _channel.invokeMethod('setVisibility', visibility);
  }

  /// Returns the departments, as [SalesIQDepartment] instances.
  Future<List<SalesIQDepartment>> getDepartments() async {
    return await _channel
        .invokeMethod('fetchDepartments')
        .then((onValue) => SalesIQDepartment.fromList(onValue));
  }

  /// Registers a data provider for conversations.
  ///
  /// The callback receives a non-null [SalesIQConversation] payload.
  ///
  /// To unregister the current provider, pass `null`.
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
