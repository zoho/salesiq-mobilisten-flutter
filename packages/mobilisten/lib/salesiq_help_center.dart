// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';

/// Provides the APIs to work with the SalesIQ Help Center. To use it, call
/// [ZohoSalesIQ.helpCenter].
class HelpCenter {
  final MethodChannel _channel = const MethodChannel('salesiq_help_center');

  /// Opens the ask flow of the Help Center. You can fill it with the given
  /// [question].
  Future<void> ask([String? question]) async {
    await _channel.invokeMethod('helpCenterAsk', question);
  }
}
