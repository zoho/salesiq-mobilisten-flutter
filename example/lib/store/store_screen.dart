import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';
import 'package:salesiq_mobilisten_calls/salesiq_mobilisten_calls.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../widgets/ui/ui.dart';
import 'catalog.dart';
import 'store_common.dart';
import 'store_product_screen.dart';
import 'store_cart_screen.dart';
import 'store_order_detail_screen.dart';

/// Zylker demo store — a self-contained shopping app that shows SalesIQ woven
/// into real retail moments. Additive: its own route; no catalog screen changes.
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    // A retailer keeps the chat launcher visible everywhere in the store.
    runSdk('', () => ZohoSalesIQ.launcher.show(VisibilityMode.always));
    // Tag the current screen so operators know the visitor is in the store.
    runSdk('', () => ZohoSalesIQ.tracking.setPageTitle('Zylker store'));
  }

  void _openSupport() =>
      // Start a live chat with a pre-filled first message.
      runSdk('Opening chat…',
          () => ZohoSalesIQ.chat.start('Hi, I need help with Zylker'));

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const tabs = [
      (_Tab.shop, 'Shop', Icons.storefront_outlined),
      (_Tab.orders, 'Orders', Icons.inventory_2_outlined),
      (_Tab.help, 'Help', Icons.support_agent_outlined),
      (_Tab.account, 'Account', Icons.person_outline),
    ];

    return Scaffold(
      backgroundColor: c.page,
      floatingActionButton: FloatingActionButton(
        onPressed: _openSupport,
        backgroundColor: c.primary,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText('Zylker',
                      variant: AppType.title, weight: FontWeight.w600),
                  AnimatedBuilder(
                    animation: cart,
                    builder: (_, __) => Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: Icon(Icons.shopping_cart_outlined,
                              color: c.textPrimary),
                          onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  settings:
                                      const RouteSettings(name: 'Your cart'),
                                  builder: (_) => const StoreCartScreen())),
                        ),
                        if (cart.count > 0)
                          Positioned(
                            right: 4,
                            top: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                  color: c.primary,
                                  borderRadius: BorderRadius.circular(9)),
                              child: Text('${cart.count}',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: const [
                  _ShopTab(),
                  _OrdersTab(),
                  _HelpTab(),
                  _AccountTab()
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: c.card,
            border: Border(top: BorderSide(color: c.border)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _tab = i),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tabs[i].$3,
                            size: 22,
                            color: _tab == i ? c.primary : c.textSecondary),
                        const SizedBox(height: 3),
                        Text(tabs[i].$2,
                            style: TextStyle(
                                fontSize: 10.5,
                                color:
                                    _tab == i ? c.primary : c.textSecondary)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Tab { shop, orders, help, account }

// ── Shop tab ────────────────────────────────────────────────────────────────
class _ShopTab extends StatelessWidget {
  const _ShopTab();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: c.border)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            Icon(Icons.search, size: 18, color: c.textSecondary),
            const SizedBox(width: 8),
            AppText('Search products',
                variant: AppType.caption, tone: TextTone.secondary),
          ]),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
              color: c.tintPrimary, borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.all(15),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Summer sale · up to 20% off',
                style: AppType.subhead
                    .style(color: c.primary, weight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('Free delivery over \$50',
                style: AppType.caption.style(color: c.primary)),
          ]),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
          children: products.map((p) {
            final (bg, fg) = tintFor(c, p.tint);
            return InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  settings: RouteSettings(name: p.name),
                  builder: (_) => StoreProductScreen(productId: p.id))),
              child: Container(
                decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: c.border)),
                padding: const EdgeInsets.all(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 78,
                        decoration: BoxDecoration(
                            color: bg, borderRadius: BorderRadius.circular(10)),
                        child: Icon(p.icon, size: 34, color: fg),
                      ),
                      const SizedBox(height: 8),
                      Text(p.name,
                          style: AppType.caption.style(color: c.textPrimary)),
                      const SizedBox(height: 3),
                      Row(children: [
                        Text(money(p.price),
                            style: AppType.subhead.style(
                                color: c.textPrimary, weight: FontWeight.w600)),
                        if (p.oldPrice != null) ...[
                          const SizedBox(width: 6),
                          Text(money(p.oldPrice!),
                              style: AppType.caption
                                  .style(color: c.textSecondary)
                                  .copyWith(
                                      decoration: TextDecoration.lineThrough)),
                        ],
                      ]),
                    ]),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Orders tab ──────────────────────────────────────────────────────────────
class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        AppText('Your orders',
            variant: AppType.subhead, weight: FontWeight.w600),
        const SizedBox(height: 12),
        ...orders.map((o) {
          final p = productById(o.productId)!;
          final (bg, fg) = tintFor(c, p.tint);
          final delivered = o.status == 'Delivered';
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  settings: RouteSettings(name: 'Order #${o.id}'),
                  builder: (_) => StoreOrderDetailScreen(orderId: o.id))),
              child: Container(
                decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: c.border)),
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                          color: bg, borderRadius: BorderRadius.circular(10)),
                      child: Icon(p.icon, size: 24, color: fg)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style:
                                  AppType.caption.style(color: c.textPrimary)),
                          const SizedBox(height: 2),
                          Text('#${o.id} · ${o.placed}',
                              style: AppType.caption
                                  .style(color: c.textSecondary)),
                        ]),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
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
            ),
          );
        }),
      ],
    );
  }
}

// ── Help tab ──────────────────────────────────────────────────────────────────
class _HelpTab extends StatefulWidget {
  const _HelpTab();
  @override
  State<_HelpTab> createState() => _HelpTabState();
}

class _HelpTabState extends State<_HelpTab> {
  static const _topics = [
    (Icons.local_shipping_outlined, 'Track or change my delivery'),
    (Icons.assignment_return_outlined, 'Returns and refunds'),
    (Icons.credit_card_outlined, 'Payment and billing'),
  ];

  @override
  void initState() {
    super.initState();
    // Pre-warm the knowledge base the way a help center would.
    try {
      // Fetch help articles so they're ready when the visitor searches.
      ZohoSalesIQ.knowledgeBase.getResources(ResourceType.articles);
    } catch (_) {/* SDK not live — the topics below still render */}
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        AppText('How can we help?',
            variant: AppType.title, weight: FontWeight.w600),
        const SizedBox(height: 12),
        Container(
          height: 38,
          decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.border)),
          padding: const EdgeInsets.symmetric(horizontal: 11),
          child: Row(children: [
            Icon(Icons.search, size: 17, color: c.textSecondary),
            const SizedBox(width: 7),
            AppText('Search help articles',
                variant: AppType.caption, tone: TextTone.secondary),
          ]),
        ),
        const SizedBox(height: 14),
        AppText('Popular topics',
            variant: AppType.caption, tone: TextTone.secondary),
        const SizedBox(height: 6),
        AppCard(
          children: _topics
              .map((t) => ListRow(
                    title: t.$2,
                    icon: AppIcon.article,
                    tint: IconTint.accent,
                    chevron: true,
                    // Open a chat pre-filled with the tapped help topic.
                    onTap: () => runSdk('Opening chat…',
                        () => ZohoSalesIQ.chat.start('I need help: ${t.$2}')),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
              color: c.tintPrimary, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Still need help?',
                style: AppType.subhead
                    .style(color: c.primary, weight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('Our team replies in a few minutes.',
                style: AppType.caption.style(color: c.primary)),
            const SizedBox(height: 12),
            // Start a live chat with a generic opening message.
            AppButton(
                title: 'Start live chat',
                onPressed: () => runSdk('Opening chat…',
                    () => ZohoSalesIQ.chat.start('Hi, I have a question'))),
            const SizedBox(height: 10),
            // Start an audio/video call session with an operator.
            AppButton(
                title: 'Request a callback',
                variant: ButtonVariant.secondary,
                onPressed: () => runSdk(
                    'Callback requested', () => ZohoSalesIQCalls.start())),
          ]),
        ),
      ],
    );
  }
}

// ── Account tab ───────────────────────────────────────────────────────────────
class _AccountTab extends StatefulWidget {
  const _AccountTab();
  @override
  State<_AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<_AccountTab> {
  final _name = TextEditingController(text: 'Alex Rivera');
  final _email = TextEditingController(text: 'alex.rivera@example.com');
  bool _notify = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _signIn() {
    final parts = _name.text.trim().split(' ');
    final profile = SalesIQVisitorProfile(
      firstName: parts.isNotEmpty ? parts.first : null,
      lastName: parts.length > 1 ? parts.sublist(1).join(' ') : null,
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      customInfo: const {'tier': 'Gold', 'lifetimeOrders': '14'},
    );
    // Identify the shopper to SalesIQ by pushing their profile details.
    runSdk('Signed in', () => ZohoSalesIQ.visitor.updateProfile(profile));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        Center(
          child: Column(children: [
            Container(
                width: 64,
                height: 64,
                decoration:
                    BoxDecoration(color: c.tintPrimary, shape: BoxShape.circle),
                child: Icon(Icons.person, size: 34, color: c.primary)),
            const SizedBox(height: 10),
            AppText(_name.text.isEmpty ? 'Guest' : _name.text,
                variant: AppType.subhead, weight: FontWeight.w600),
          ]),
        ),
        const SizedBox(height: 18),
        AppCard(children: [
          Field(label: 'Name', controller: _name),
          Field(
              label: 'Email',
              controller: _email,
              textCapitalization: TextCapitalization.none),
        ]),
        const SizedBox(height: 12),
        AppButton(title: 'Sign in', onPressed: _signIn),
        const SizedBox(height: 16),
        AppCard(children: [
          SwitchRow(
            title: 'Order notifications',
            subtitle: 'Shipping and delivery alerts',
            value: _notify,
            onChanged: (v) {
              setState(() => _notify = v);
              // Turn SalesIQ in-app notification banners on or off.
              runSdk(v ? 'Notifications on' : 'Notifications off',
                  () => ZohoSalesIQ.notification.enableInAppNotification(v));
            },
          ),
        ]),
      ],
    );
  }
}
