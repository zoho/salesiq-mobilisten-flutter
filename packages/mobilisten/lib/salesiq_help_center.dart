// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';

/// Provides APIs to interact with the SalesIQ Help Center.
/// Access this via [ZohoSalesIQ.helpCenter].
class HelpCenter {
  final MethodChannel _channel = const MethodChannel('salesiq_help_center');

  /// Opens the Help Center's ask flow, optionally pre-filling the
  /// given [question].
  Future<void> ask([String? question]) async {
    await _channel.invokeMethod('helpCenterAsk', question);
  }
}
