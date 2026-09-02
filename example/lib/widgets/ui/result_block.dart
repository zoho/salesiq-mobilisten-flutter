import 'dart:convert';

import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import 'app_text.dart';

/// ResultBlock: mono 12, resultBlockBg surface, radius 12, selectable output for
/// API results. Keys are tinted primary, string values secondary-green.
/// Mirrors the RN `ResultBlock`.
class ResultBlock extends StatelessWidget {
  /// Any JSON-serializable value, or a preformatted string.
  final Object? data;

  /// Optional label rendered above the block (e.g. "Last result").
  final String? label;

  const ResultBlock({super.key, required this.data, this.label});

  String get _text {
    final d = data;
    if (d is String) return d;
    try {
      return const JsonEncoder.withIndent('  ').convert(d);
    } catch (_) {
      return d.toString();
    }
  }

  List<InlineSpan> _spans(BuildContext context) {
    final c = context.colors;
    final keyStyle =
        AppType.mono.style(color: c.primary).copyWith(fontFamily: kMonoFont);
    final stringStyle =
        AppType.mono.style(color: c.secondary).copyWith(fontFamily: kMonoFont);
    final plainStyle = AppType.mono
        .style(color: c.textSecondary)
        .copyWith(fontFamily: kMonoFont);

    final spans = <InlineSpan>[];
    final lines = _text.split('\n');
    final keyRe = RegExp(r'^(\s*)("[^"]+")(:\s*)(.*)$');
    final strValRe = RegExp(r'^".*",?$');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final suffix = i == lines.length - 1 ? '' : '\n';
      final m = keyRe.firstMatch(line);
      if (m == null) {
        spans.add(TextSpan(text: '$line$suffix', style: plainStyle));
        continue;
      }
      final indent = m.group(1)!;
      final key = m.group(2)!;
      final colon = m.group(3)!;
      final rest = m.group(4)!;
      final isStringValue = strValRe.hasMatch(rest);
      spans.add(TextSpan(text: indent, style: plainStyle));
      spans.add(TextSpan(text: key, style: keyStyle));
      spans.add(TextSpan(text: colon, style: plainStyle));
      spans.add(TextSpan(
          text: '$rest$suffix',
          style: isStringValue ? stringStyle : plainStyle));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: AppText(
              label!,
              variant: AppType.sectionLabel,
              tone: TextTone.tertiary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            color: c.resultBlockBg,
            border: Border.all(color: c.border, width: 1),
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          child: SelectableText.rich(TextSpan(children: _spans(context))),
        ),
      ],
    );
  }
}
