// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';

/// Provides the APIs to control the SalesIQ homepage. To use it, call
/// [ZohoSalesIQ.homepage].
class Homepage {
  final MethodChannel _channel = const MethodChannel('salesiq_homepage_module');

  /// Turns the homepage on or off, based on the value of [enabled].
  void setEnabled(bool enabled) {
    _channel.invokeMethod('setHomepageEnabled', enabled);
  }

  /// Shows or hides the given homepage [widget], based on the value of
  /// [visible].
  void setVisibility(SIQWidget widget, bool visible) {
    _channel.invokeMethod('setHomepageWidgetVisibility', <String, dynamic>{
      'widget': widget.name,
      'visible': visible,
    });
  }
}

/// Defines the widgets that the SalesIQ homepage can show.
enum SIQWidget {
  /// The chat widget, which starts a new conversation.
  chat,

  /// The call widget, which starts a support call.
  call,

  /// The widget for Knowledge Base articles.
  articles,

  // FAQs is pending the iOS native implementation. Uncomment when iOS supports it.
  // /// The knowledge base FAQs widget.
  // faqs,

  /// The widget that shows the history of previous chats and calls.
  previousConversations,

  /// A card that shows a promotional or informational image.
  imageCard,

  /// A card that shows a promotional or informational video.
  videoCard
}
