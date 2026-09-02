import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../widgets/ui/ui.dart';
import 'catalog.dart';
import 'store_common.dart';

/// Zylker store order detail — demonstrates starting a support chat scoped to
/// a specific order via a customChatId.
class StoreOrderDetailScreen extends StatelessWidget {
  final String orderId;
  const StoreOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Order? order;
    for (final o in orders) {
      if (o.id == orderId) order = o;
    }
    if (order == null) {
      return const ScreenScaffold(
          title: 'Order', children: [Text('Not found')]);
    }
    final o = order;
    final product = productById(o.productId)!;
    final (bg, fg) = tintFor(c, product.tint);
    final delivered = o.status == 'Delivered';

    final steps = <(String, bool)>[
      ('Ordered · ${o.placed}', true),
      ('Shipped · Jul 5', o.status != 'Processing'),
      (o.eta, delivered),
    ];

    // Start a Support chat scoped to this order (order id used as custom chat id).
    void getHelp() => runSdk(
        'Opening chat…',
        () => ZohoSalesIQ.chat
            .start('I need help with order ${o.id}', o.id, 'Support'));

    return ScreenScaffold(
      title: 'Order #${o.id}',
      children: [
        AppCard(children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                      color: bg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(product.icon, size: 24, color: fg)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(product.name, variant: AppType.caption),
                      const SizedBox(height: 2),
                      AppText('Qty 1 · ${money(product.price)}',
                          variant: AppType.caption, tone: TextTone.secondary),
                    ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                    color: delivered ? c.tintSecondary : c.tintPrimary,
                    borderRadius: BorderRadius.circular(8)),
                child: Text(o.status,
                    style: AppType.caption.style(
                        color: delivered ? c.secondary : c.primary,
                        weight: FontWeight.w600)),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        ...List.generate(steps.length, (i) {
          final (label, done) = steps[i];
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(
                      done ? Icons.check_circle : Icons.local_shipping_outlined,
                      size: 18,
                      color: done ? c.secondary : c.textSecondary),
                  const SizedBox(width: 10),
                  Text(label,
                      style: AppType.caption.style(
                          color: done ? c.textPrimary : c.textSecondary)),
                ]),
                if (i < steps.length - 1)
                  Container(
                      width: 1.5,
                      height: 14,
                      color: c.border,
                      margin:
                          const EdgeInsets.only(left: 8, top: 2, bottom: 2)),
              ]);
        }),
        const SizedBox(height: 18),
        AppButton(title: 'Get help with this order', onPressed: getHelp),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: AppButton(
                  title: 'Track',
                  variant: ButtonVariant.secondary,
                  onPressed: () => showToast('Tracking opened'))),
          const SizedBox(width: 10),
          Expanded(
              child: AppButton(
                  title: 'Return',
                  variant: ButtonVariant.secondary,
                  onPressed: getHelp)),
        ]),
      ],
    );
  }
}
