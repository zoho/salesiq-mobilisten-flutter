import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../widgets/ui/ui.dart';
import 'catalog.dart';
import 'store_common.dart';

/// Zylker store cart — demonstrates firing a proactive chat trigger at
/// checkout and starting a chat about payment.
class StoreCartScreen extends StatefulWidget {
  const StoreCartScreen({super.key});
  @override
  State<StoreCartScreen> createState() => _StoreCartScreenState();
}

class _StoreCartScreenState extends State<StoreCartScreen> {
  void _placeOrder() {
    // A proactive trigger — the SDK offers help at checkout the way a store would.
    runSdk(
        'Order placed — we’ll follow up in chat',
        () => ZohoSalesIQ.chat
            .initiateWithTrigger('checkout_completed', 'cart', 'Support'));
    cart.clear();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedBuilder(
      animation: cart,
      builder: (context, _) {
        final items = cart.items;
        return ScreenScaffold(
          title: 'Your cart',
          children: [
            AppCard(
              children: items.isEmpty
                  ? [
                      const _CartEmpty(),
                    ]
                  : items.map((item) {
                      final (bg, fg) = tintFor(c, item.product.tint);
                      return ListRow(
                        title: item.product.name,
                        subtitle:
                            'Qty ${item.qty} · ${money(item.product.price)}',
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(9)),
                              child:
                                  Icon(item.product.icon, size: 18, color: fg)),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: Icon(Icons.close,
                                size: 18, color: c.textSecondary),
                            onPressed: () => cart.remove(item.product.id),
                          ),
                        ]),
                      );
                    }).toList(),
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText('Total',
                          variant: AppType.body, tone: TextTone.secondary),
                      AppText(money(cart.total),
                          variant: AppType.title, weight: FontWeight.w600),
                    ]),
              ),
              const SizedBox(height: 12),
              AppButton(title: 'Place order', onPressed: _placeOrder),
              const SizedBox(height: 10),
              AppButton(
                title: 'Chat about payment',
                variant: ButtonVariant.secondary,
                // Start a chat pre-filled with a payment question, routed to Support.
                onPressed: () => runSdk(
                    'Opening chat…',
                    () => ZohoSalesIQ.chat.start(
                        'I have a question about payment', 'cart', 'Support')),
              ),
            ] else ...[
              const SizedBox(height: 12),
              AppButton(
                  title: 'Continue shopping',
                  variant: ButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop()),
            ],
          ],
        );
      },
    );
  }
}

class _CartEmpty extends StatelessWidget {
  const _CartEmpty();
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(children: [
        Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: c.cardAlt, borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.shopping_cart_outlined,
                size: 22, color: c.textSecondary)),
        const SizedBox(height: 12),
        Text('Your cart is empty',
            textAlign: TextAlign.center,
            style: AppType.subhead
                .style(color: c.textPrimary, weight: FontWeight.w600)),
        const SizedBox(height: 3),
        Text('Browse the store and add something you like',
            textAlign: TextAlign.center,
            style: AppType.caption.style(color: c.textSecondary)),
      ]),
    );
  }
}
