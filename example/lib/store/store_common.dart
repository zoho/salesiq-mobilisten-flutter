import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../widgets/ui/ui.dart';
import 'catalog.dart';

String money(int amount) => '\$$amount';

/// (background, foreground) tint pair for a product's placeholder tile.
(Color, Color) tintFor(AppColors c, ProductTint tint) => switch (tint) {
      ProductTint.secondary => (c.tintSecondary, c.secondary),
      ProductTint.accent => (c.tintAccent, c.accent),
      ProductTint.primary => (c.tintPrimary, c.primary),
    };

/// Fires an SDK call, toasting failure; safe before the SDK is live.
void runSdk(String label, VoidCallback fn) {
  try {
    fn();
    if (label.isNotEmpty) showToast(label, ToastTone.success);
  } catch (e) {
    // Usually "SDK not initialized" before keys are added — keep the hint, but
    // append the real reason and log it so genuine failures aren't hidden.
    debugPrint('Store SDK call "$label" failed: $e');
    showToast('Add keys in Settings to run live${reason(e)}');
  }
}
