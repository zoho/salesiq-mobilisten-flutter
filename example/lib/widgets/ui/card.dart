import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../theme/tokens.dart';

/// Card surface: `card` bg, 1pt `border`, radius 16, subtle elevation.
/// When [separated] is true, hairline separators are inserted between children
/// (list-style cards). Mirrors the RN `Card`.
class AppCard extends StatelessWidget {
  final List<Widget> children;
  final bool separated;

  const AppCard({super.key, required this.children, this.separated = true});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (separated && i > 0) {
        items.add(Container(height: 1, color: c.hairline));
      }
      items.add(children[i]);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.border, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: items,
        ),
      ),
    );
  }
}
