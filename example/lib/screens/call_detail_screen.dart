import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';
import 'package:salesiq_mobilisten_calls/salesiq_mobilisten_calls.dart';

import '../widgets/ui/ui.dart';

/// Detail — a recent call, reached by tapping a row in the Calls history.
/// "Open conversation" presents that conversation via
/// present(SIQConversationScreen.withId(id, call)). Mirrors the v3 mockup.
class CallDetailScreen extends StatefulWidget {
  final SalesIQConversation conversation;

  const CallDetailScreen({super.key, required this.conversation});

  @override
  State<CallDetailScreen> createState() => _CallDetailScreenState();
}

class _CallDetailScreenState extends State<CallDetailScreen> {
  Object? _result;

  SalesIQConversation get _conversation => widget.conversation;

  Future<void> _open() async {
    final id = _conversation.id;
    if (id == null) {
      showToast('Call has no conversation ID', ToastTone.danger);
      return;
    }
    try {
      // Open the SDK screen for this call conversation, found by its id.
      await ZohoSalesIQ.present(
        screen:
            SIQConversationScreen.withId(id, sessionType: SIQSessionType.call),
      );
      setState(() => _result = {'opened': id, 'presented': true});
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
      showToast('Failed to open conversation${reason(e)}', ToastTone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final call = _conversation is SalesIQCallConversation
        ? _conversation as SalesIQCallConversation
        : null;
    final missed = call?.status == CallStatus.missed;
    return ScreenScaffold(
      title: 'Call',
      subtitle: 'conversationId · ${_conversation.id ?? '—'}',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppBadge(
                label: call?.status?.name ?? 'Call',
                tone: missed ? BadgeTone.danger : BadgeTone.primary,
              ),
            ],
          ),
        ),
        Section(
          title: 'Details',
          child: AppCard(
            children: [
              ListRow(
                title: _conversation.attenderName ?? 'Unassigned',
                subtitle: _conversation.attenderEmail ?? 'Operator',
                icon: AppIcon.visitor,
              ),
              ListRow(
                  title: 'Department',
                  value: _conversation.departmentName ?? '—'),
              ListRow(title: 'Question', value: _conversation.question ?? '—'),
            ],
          ),
        ),
        AppButton(
          title: 'Open conversation',
          icon: AppIcon.calls,
          onPressed: _open,
        ),
        const Section(
          footer: 'Open = present(SIQConversationScreen.withId(id, call)).',
          child: SizedBox.shrink(),
        ),
        if (_result != null) ResultBlock(label: 'Last result', data: _result),
      ],
    );
  }
}
