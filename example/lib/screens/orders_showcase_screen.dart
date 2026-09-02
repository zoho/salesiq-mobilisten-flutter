import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

import '../widgets/ui/ui.dart';

/// A sample order used to demonstrate the `customChatId` business case.
class _Order {
  final String id;
  final String title;
  final String status;
  final List<String> faqs;
  const _Order(this.id, this.title, this.status, this.faqs);
}

const _orders = <_Order>[
  _Order('ORD-4821', 'Wireless headphones', 'Delivered', [
    'Where is my invoice?',
    'How do I start a return?',
  ]),
  _Order('ORD-4822', 'Mechanical keyboard', 'Shipped', [
    'When will it arrive?',
    'Can I change the address?',
  ]),
  _Order('ORD-4830', 'USB-C hub', 'Processing', [
    'Can I cancel this order?',
  ]),
];

/// Detail — Orders showcase. Each order maps to a `customChatId` so the
/// conversation is tied to that business entity. "Chat about this order"
/// fires a trigger (no question); an FAQ row starts a chat with the FAQ as
/// the question. Mirrors the v3 mockup.
class OrdersShowcaseScreen extends StatefulWidget {
  const OrdersShowcaseScreen({super.key});

  @override
  State<OrdersShowcaseScreen> createState() => _OrdersShowcaseScreenState();
}

class _OrdersShowcaseScreenState extends State<OrdersShowcaseScreen> {
  Object? _result;

  Future<void> _chatAboutOrder(_Order order) async {
    try {
      // No question — trigger a chat bound to the order via customChatId.
      final chat = await ZohoSalesIQ.chat
          .initiateWithTrigger('order_support', order.id, null);
      setState(() => _result = {'order': order.id, 'chatId': chat?.id});
      showToast('Chat for ${order.id}', ToastTone.success);
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
      showToast('Failed to start chat', ToastTone.danger);
      _presentOrderConversation(order.id);
    }
  }

  Future<void> _askFaq(_Order order, String faq) async {
    try {
      // Question is the FAQ; customChatId ties it to the order.
      final chat = await ZohoSalesIQ.chat.start(faq, order.id);
      setState(
          () => _result = {'order': order.id, 'faq': faq, 'chatId': chat?.id});
      showToast('Chat about ${order.id}', ToastTone.success);
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
      showToast('Failed to start chat', ToastTone.danger);
      _presentOrderConversation(order.id);
    }
  }

  /// Fallback: land the visitor in the order's conversation even if start fails.
  Future<void> _presentOrderConversation(String id) async {
    try {
      // Open the SDK chat screen for a specific conversation, found by id.
      await ZohoSalesIQ.present(
        screen:
            SIQConversationScreen.withId(id, sessionType: SIQSessionType.chat),
      );
    } catch (_) {}
  }

  BadgeTone _tone(String status) {
    switch (status) {
      case 'Delivered':
        return BadgeTone.success;
      case 'Shipped':
        return BadgeTone.primary;
      default:
        return BadgeTone.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Orders',
      subtitle: 'customChatId business case',
      children: [
        const StatusBanner(
          title: 'Order-scoped conversations',
          body:
              'customChatId maps a chat to a business entity (order / ticket) '
              'so agents see full context and messages route to the same thread.',
          variant: BannerVariant.info,
        ),
        for (final order in _orders)
          Section(
            title: order.id,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(children: [
                  ListRow(
                    title: order.title,
                    subtitle: 'Order ${order.id}',
                    icon: AppIcon.homepage,
                    tint: IconTint.accent,
                    trailing: AppBadge(
                      label: order.status,
                      tone: _tone(order.status),
                    ),
                  ),
                  for (final faq in order.faqs)
                    ListRow(
                      title: faq,
                      icon: AppIcon.chat,
                      tint: IconTint.primary,
                      chevron: true,
                      onTap: () => _askFaq(order, faq),
                    ),
                ]),
                const SizedBox(height: 12),
                AppButton(
                  title: 'Chat about this order',
                  icon: AppIcon.chat,
                  onPressed: () => _chatAboutOrder(order),
                ),
              ],
            ),
          ),
        if (_result != null) ResultBlock(label: 'Last result', data: _result),
      ],
    );
  }
}
