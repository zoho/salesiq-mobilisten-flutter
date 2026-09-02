import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

import '../theme/tokens.dart';
import '../widgets/ui/ui.dart';

/// Detail A — chat detail, reached by tapping a row in the fetched chats list.
/// End = Chat.end(id). Mirrors the v3 mockup.
class ChatDetailScreen extends StatefulWidget {
  /// The chat whose details are shown.
  final SIQChat chat;

  const ChatDetailScreen({super.key, required this.chat});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  Object? _result;

  SIQChat get _chat => widget.chat;

  void _end() {
    final id = _chat.id;
    if (id == null) {
      showToast('Chat has no ID', ToastTone.danger);
      return;
    }
    // End (close) this conversation, by its id.
    ZohoSalesIQ.chat.end(id);
    setState(() => _result = {'ended': id});
    showToast('Chat ended');
  }

  @override
  Widget build(BuildContext context) {
    final chat = _chat;
    final connected = chat.status == SIQChatStatus.connected ||
        chat.status == SIQChatStatus.open;
    return ScreenScaffold(
      title: 'Conversation',
      subtitle: 'chatId · ${chat.id ?? '—'}',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppBadge(
                label: connected ? 'Connected' : chat.status.name,
                tone: connected ? BadgeTone.success : BadgeTone.primary,
                icon: connected ? AppIcon.check : null,
              ),
              if (chat.unreadCount > 0)
                AppBadge(
                  label: '${chat.unreadCount} unread',
                  tone: BadgeTone.warning,
                ),
              if (chat.rating != null && chat.rating!.isNotEmpty)
                AppBadge(label: 'Rating ${chat.rating}'),
            ],
          ),
        ),
        Section(
          title: 'Details',
          child: AppCard(
            children: [
              ListRow(
                title: chat.attenderName ?? 'Unassigned',
                subtitle: chat.attenderEmail ??
                    (chat.isBotAttender ? 'Bot' : 'Awaiting operator'),
                icon: AppIcon.visitor,
              ),
              ListRow(
                title: 'Department',
                value: chat.departmentName ?? '—',
              ),
              _ReadOnlyField(
                label: 'Question',
                value: chat.question ?? '—',
              ),
              _ReadOnlyField(
                label: 'Last message',
                value: chat.recentMessage?.text ?? '—',
              ),
            ],
          ),
        ),
        AppButton(
          title: 'End chat',
          variant: ButtonVariant.destructive,
          onPressed: _end,
        ),
        const Section(
          footer: 'End = Chat.end(id).',
          child: SizedBox.shrink(),
        ),
        if (_result != null) ResultBlock(label: 'Last result', data: _result),
      ],
    );
  }
}

/// A read-only labelled value styled like a [Field] inside a card.
class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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
          AppText(value, variant: AppType.body, fontSizeOverride: 14.5),
        ],
      ),
    );
  }
}
