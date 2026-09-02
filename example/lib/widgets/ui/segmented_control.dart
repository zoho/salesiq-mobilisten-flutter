import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import 'app_text.dart';

/// One segment: a value paired with its display label.
class Segment<T> {
  final T value;
  final String label;
  const Segment(this.value, this.label);
}

/// Segmented control: track radius 12 pad 3, selected thumb radius 9 with a
/// subtle shadow. Mirrors the RN `SegmentedControl`.
class SegmentedControl<T> extends StatelessWidget {
  final List<Segment<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;

  const SegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.segmentTrack,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: segments.map((segment) {
          final selected = segment.value == value;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(segment.value),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? c.segmentThumb : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.14),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: AppText(
                  segment.label,
                  variant: AppType.subhead,
                  tone: selected ? TextTone.primary : TextTone.secondary,
                  weight: AppType.medium,
                  fontSizeOverride: 12.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
