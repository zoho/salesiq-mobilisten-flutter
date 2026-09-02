// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';

/// Provides APIs to control the SalesIQ homepage.
/// Access this via [ZohoSalesIQ.homepage].
class Homepage {
  final MethodChannel _channel = const MethodChannel('salesiq_homepage_module');

  /// Enables or disables the homepage using the value provided for [enabled].
  void setEnabled(bool enabled) {
    _channel.invokeMethod('setHomepageEnabled', enabled);
  }

  /// Controls the visibility of the given homepage [widget], using the value
  /// provided for [visible].
  void setVisibility(SIQWidget widget, bool visible) {
    _channel.invokeMethod('setHomepageWidgetVisibility', <String, dynamic>{
      'widget': widget.name,
      'visible': visible,
    });
  }
}

/// Widgets available on the SalesIQ homepage.
enum SIQWidget {
  /// The chat widget to start a new conversation.
  chat,

  /// The call widget to initiate a support call.
  call,

  /// The knowledge base articles widget.
  articles,

  // FAQs is pending the iOS native implementation. Uncomment when iOS supports it.
  // /// The knowledge base FAQs widget.
  // faqs,

  /// The widget displaying previous chat and call history.
  previousConversations,

  /// A card displaying a promotional or informational image.
  imageCard,

  /// A card displaying a promotional or informational video.
  videoCard
}
