import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show PlatformException, MissingPluginException;

import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import 'app_text.dart';
import 'icons.dart';

/// Toast tone.
enum ToastTone { defaultTone, success, danger }

/// Fire a bottom toast from anywhere — screens call this after an SDK action
/// resolves. A [ToastHost] must be mounted near the app root.
void showToast(String text, [ToastTone tone = ToastTone.defaultTone]) {
  _ToastController.instance?._show(text, tone);
}

/// Turns an SDK failure into a short, user-facing detail that can be *appended*
/// to a failure toast so people see WHY an action failed, not just "Failed".
///
/// SDK calls run over a MethodChannel, so failures arrive as a
/// [PlatformException] (with `message`/`code`) or a [MissingPluginException];
/// anything else falls back to `toString()`. Returns a string already prefixed
/// with ": " (e.g. `": Operator offline"`), or "" when there is no useful
/// detail — so callers can safely write `'Couldn't start chat${reason(e)}'`.
String reason(Object? error) {
  final detail = _reasonDetail(error);
  return (detail == null || detail.isEmpty) ? '' : ': $detail';
}

String? _reasonDetail(Object? error) {
  if (error == null) return null;
  if (error is PlatformException) {
    final message = error.message?.trim();
    if (message != null && message.isNotEmpty) return message;
    final code = error.code.trim();
    return code.isEmpty ? null : code;
  }
  if (error is MissingPluginException) {
    final message = error.message?.trim();
    return (message == null || message.isEmpty) ? null : message;
  }
  final text = error.toString().trim();
  return text.isEmpty ? null : text;
}

class _ToastMessage {
  final int id;
  final String text;
  final ToastTone tone;
  _ToastMessage(this.id, this.text, this.tone);
}

class _ToastController {
  static _ToastController? instance;
  void Function(String, ToastTone)? _handler;
  void _show(String text, ToastTone tone) => _handler?.call(text, tone);
}

/// Mount once near the app root. Renders queued toasts bottom-anchored,
/// auto-dismissed after ~2.5s. Mirrors the RN `ToastHost`.
class ToastHost extends StatefulWidget {
  final Widget child;
  const ToastHost({super.key, required this.child});

  @override
  State<ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<ToastHost> {
  static const _duration = Duration(milliseconds: 2500);
  _ToastMessage? _message;
  int _nextId = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final controller = _ToastController();
    controller._handler = _show;
    _ToastController.instance = controller;
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_ToastController.instance?._handler == _show) {
      _ToastController.instance = null;
    }
    super.dispose();
  }

  void _show(String text, ToastTone tone) {
    _timer?.cancel();
    setState(() => _message = _ToastMessage(_nextId++, text, tone));
    _timer = Timer(_duration, () {
      if (mounted) setState(() => _message = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final msg = _message;
    return Stack(
      children: [
        widget.child,
        if (msg != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 20,
            child: SafeArea(
              top: false,
              child: IgnorePointer(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _ToastCard(
                    key: ValueKey(msg.id),
                    text: msg.text,
                    tone: msg.tone,
                    colors: c,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ToastCard extends StatelessWidget {
  final String text;
  final ToastTone tone;
  final AppColors colors;
  const _ToastCard({
    super.key,
    required this.text,
    required this.tone,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg;
    final AppIcon glyph;
    switch (tone) {
      case ToastTone.success:
        fg = colors.secondary;
        glyph = AppIcon.check;
        break;
      case ToastTone.danger:
        fg = colors.danger;
        glyph = AppIcon.alert;
        break;
      case ToastTone.defaultTone:
        fg = colors.textPrimary;
        glyph = AppIcon.info;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.card,
          border: Border.all(color: colors.border, width: 1),
          borderRadius: BorderRadius.circular(AppRadius.control),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(AppIcons.of(glyph), size: 18, color: fg),
            const SizedBox(width: 10),
            Expanded(
              child: AppText(text, variant: AppType.body, fontSizeOverride: 14),
            ),
          ],
        ),
      ),
    );
  }
}
