import 'package:flutter/services.dart';

/// Provides the APIs to track the visitor's footpath in the SalesIQ console.
///
/// It matches the native `ZohoSalesIQ.Tracking` namespace on Android and iOS.
/// To use it, call [ZohoSalesIQ.tracking].
class Tracking {
  final MethodChannel _channel = const MethodChannel('salesiq_tracking_module');

  /// Sets the title of the current page to [pageTitle]. The title appears in
  /// the visitor's footpath in the SalesIQ console.
  void setPageTitle(String pageTitle) {
    _channel.invokeMethod('setPageTitle', pageTitle);
  }
}
