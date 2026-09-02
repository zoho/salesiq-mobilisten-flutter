import 'package:flutter/services.dart';

/// Provides APIs to track the visitor's footpath in the SalesIQ console.
///
/// Mirrors the native `ZohoSalesIQ.Tracking` namespace (Android
/// `ZohoSalesIQ.Tracking`, iOS `ZohoSalesIQ.Tracking`). Access this via
/// [ZohoSalesIQ.tracking].
class Tracking {
  final MethodChannel _channel = const MethodChannel('salesiq_tracking_module');

  /// Sets the current page title shown in the visitor footpath on the
  /// SalesIQ console, using the value provided for [pageTitle].
  void setPageTitle(String pageTitle) {
    _channel.invokeMethod('setPageTitle', pageTitle);
  }
}
