import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import 'button.dart';
import 'icons.dart';

/// Standardized async content for a fetch/list screen. Returns the rows to place
/// inside an [AppCard] `children:` list, so real rows keep the card's hairline
/// separators. Precedence: loading → error → empty → [children].
///
/// ```dart
/// AppCard(children: stateRows(
///   loading: !_loaded, error: _error, empty: _items.isEmpty, onRetry: _load,
///   emptyIcon: AppIcon.department, emptyTitle: 'No departments',
///   children: _items.map(buildRow).toList(),
/// ))
/// ```
List<Widget> stateRows({
  required bool loading,
  String? error,
  required bool empty,
  VoidCallback? onRetry,
  int skeletonRows = 3,
  AppIcon emptyIcon = AppIcon.search,
  String emptyTitle = 'Nothing here yet',
  String? emptySubtitle,
  required List<Widget> children,
}) {
  if (loading) {
    return List.generate(skeletonRows, (i) => const _SkeletonRow());
  }
  if (error != null) {
    return [
      _StateBlock(
        icon: AppIcon.alert,
        danger: true,
        title: 'Couldn’t load',
        subtitle: error,
        actionLabel: onRetry != null ? 'Retry' : null,
        onAction: onRetry,
      ),
    ];
  }
  if (empty) {
    return [
      _StateBlock(
        icon: emptyIcon,
        danger: false,
        title: emptyTitle,
        subtitle: emptySubtitle,
        actionLabel: onRetry != null ? 'Refresh' : null,
        onAction: onRetry,
      ),
    ];
  }
  return children;
}

/// A single shimmering placeholder row: pulsing icon box + two text bars.
class _SkeletonRow extends StatefulWidget {
  const _SkeletonRow();

  @override
  State<_SkeletonRow> createState() => _SkeletonRowState();
}

class _SkeletonRowState extends State<_SkeletonRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);
  late final Animation<double> _opacity =
      Tween(begin: 0.45, end: 1.0).animate(_c);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _bar(Color color, double widthFactor, double height) =>
      FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: widthFactor,
        child: Container(
          height: height,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(6)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FadeTransition(
      opacity: _opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: c.cardAlt, borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(c.cardAlt, 0.52, 11),
                  const SizedBox(height: 7),
                  _bar(c.cardAlt, 0.78, 9),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centered icon + title + subtitle (+ optional action) — shared by empty/error.
class _StateBlock extends StatelessWidget {
  final AppIcon icon;
  final bool danger;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StateBlock({
    required this.icon,
    required this.danger,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: danger ? c.tintDanger : c.cardAlt,
                borderRadius: BorderRadius.circular(14)),
            child: Icon(AppIcons.of(icon),
                size: 22, color: danger ? c.danger : c.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style: AppType.subhead
                  .style(color: c.textPrimary, weight: FontWeight.w600)),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(subtitle!,
                textAlign: TextAlign.center,
                style: AppType.caption.style(color: c.textSecondary)),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            AppButton(
                title: actionLabel!,
                variant: ButtonVariant.secondary,
                onPressed: onAction),
          ],
        ],
      ),
    );
  }
}
