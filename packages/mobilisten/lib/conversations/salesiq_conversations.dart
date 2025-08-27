import 'package:flutter/services.dart';
import 'package:salesiq_mobilisten_core/salesiq_conversation_attributes.dart';
import 'package:salesiq_mobilisten_core/salesiq_department.dart';

/// This class provides APIs to manage conversations in the Zoho SalesIQ SDK.
class Conversation {
  final MethodChannel _channel =
      const MethodChannel("salesiq_conversations_module");

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
}
