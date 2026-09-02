import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';
import 'package:salesiq_mobilisten_core/salesiq_conversation_attributes.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../widgets/ui/ui.dart';
import 'catalog.dart';
import 'store_cart_screen.dart';
import 'store_common.dart';

/// Zylker store product detail — demonstrates a product-scoped chat that pins
/// the conversation to a single SKU via attributes and a customChatId.
class StoreProductScreen extends StatelessWidget {
  final String productId;
  const StoreProductScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final product = productById(productId);
    if (product == null) {
      return const ScreenScaffold(
          title: 'Product', children: [Text('Not found')]);
    }
    final (bg, fg) = tintFor(c, product.tint);

    void addToCart() {
      cart.add(product);
      showToast('Added to cart', ToastTone.success);
    }

    // Product-scoped chat: attributes + customChatId pin it to this SKU.
    void ask() => runSdk('Opening chat…', () {
          // Attach this product's details to the next conversation.
          ZohoSalesIQ.conversation.setAttributes(SalesIQConversationAttributes(
            name: product.name,
            additionalInfo: 'SKU ${product.id}',
          ));
          // Start a chat using the product id as a custom chat id (Sales dept).
          ZohoSalesIQ.chat.start(
              'I have a question about ${product.name}', product.id, 'Sales');
        });

    return ScreenScaffold(
      title: product.name,
      children: [
        Container(
          height: 170,
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
          child: Icon(product.icon, size: 72, color: fg),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Icon(Icons.star, size: 15, color: c.accent),
          const SizedBox(width: 6),
          AppText('${product.rating} · ${product.reviews} reviews',
              variant: AppType.caption, tone: TextTone.secondary),
        ]),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          AppText(money(product.price),
              variant: AppType.title, weight: FontWeight.w600),
          if (product.oldPrice != null) ...[
            const SizedBox(width: 10),
            Text(money(product.oldPrice!),
                style: AppType.subhead
                    .style(color: c.textSecondary)
                    .copyWith(decoration: TextDecoration.lineThrough)),
          ],
        ]),
        const SizedBox(height: 10),
        AppText(product.blurb, variant: AppType.body, tone: TextTone.secondary),
        const SizedBox(height: 18),
        AppButton(title: 'Add to cart', onPressed: addToCart),
        const SizedBox(height: 10),
        AppButton(
            title: 'Ask about this product',
            variant: ButtonVariant.secondary,
            onPressed: ask),
        const SizedBox(height: 9),
        Center(
            child: AppText('Opens a chat scoped to this item',
                variant: AppType.caption, tone: TextTone.secondary)),
        const SizedBox(height: 12),
        AppButton(
          title: 'View cart',
          variant: ButtonVariant.ghost,
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              settings: const RouteSettings(name: 'Your cart'),
              builder: (_) => const StoreCartScreen())),
        ),
      ],
    );
  }
}
