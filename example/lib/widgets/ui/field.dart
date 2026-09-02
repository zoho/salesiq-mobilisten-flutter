import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/theme.dart';
import 'app_text.dart';
import '../../theme/tokens.dart';

/// Form field: label 11/600 uppercase textTertiary → value 14.5 input,
/// 12/14 padding, hairline separators inside cards. Mirrors the RN `Field`.
class Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final bool enabled;

  const Field({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.sentences,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            variant: AppType.sectionLabel,
            tone: TextTone.tertiary,
            letterSpacingOverride: 0.4,
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboardType,
            obscureText: obscureText,
            textCapitalization: textCapitalization,
            enabled: enabled,
            cursorColor: c.primary,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: AppType.regular,
              color: enabled ? c.textPrimary : c.textTertiary,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintText: placeholder,
              hintStyle: TextStyle(fontSize: 14.5, color: c.textTertiary),
            ),
            inputFormatters: keyboardType == TextInputType.phone
                ? [FilteringTextInputFormatter.deny(RegExp(r'\n'))]
                : null,
          ),
        ],
      ),
    );
  }
}
