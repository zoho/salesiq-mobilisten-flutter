import 'dart:async';

import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten_calls/salesiq_mobilisten_calls.dart';

import '../widgets/ui/ui.dart';
import 'call_detail_screen.dart';

enum _ViewMode { fullScreen, floating }

const _callComponents = <CallComponent, String>{
  CallComponent.operatorName: 'Operator name',
  CallComponent.operatorImage: 'Operator image',
  CallComponent.preChatForm: 'Pre-chat form',
  CallComponent.queuePosition: 'Queue position',
};

/// Screen 06 — start/end voice calls, monitor active call, browse recent
/// conversations. Mirrors the RN `CallsScreen`.
class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  SalesIQCallState? _callState;
  _ViewMode _viewMode = _ViewMode.fullScreen;
  List<SalesIQConversation> _recent = [];
  bool _recentLoading = true;
  String? _recentError;
  StreamSubscription<CallEvent>? _sub;
  final _onlineTitle = TextEditingController(text: 'On a call');
  final _offlineTitle = TextEditingController(text: 'Call us back');
  final Map<CallComponent, bool> _components = {
    CallComponent.operatorName: true,
    CallComponent.operatorImage: true,
    CallComponent.preChatForm: false,
    CallComponent.queuePosition: true,
  };

  @override
  void initState() {
    super.initState();
    _refreshCallState();
    _refreshRecent();
    // Subscribe to call events so the UI refreshes when call state changes.
    _sub = ZohoSalesIQCalls.events.listen((_) => _refreshCallState());
  }

  @override
  void dispose() {
    _sub?.cancel();
    _onlineTitle.dispose();
    _offlineTitle.dispose();
    super.dispose();
  }

  void _applyTitles() {
    // Set the call screen header text for the online and offline states.
    ZohoSalesIQCalls.setTitle(_onlineTitle.text, _offlineTitle.text);
    // Canned quick-reply messages shown on the Android incoming-call notification.
    ZohoSalesIQCalls.setAndroidReplyMessages(
        const ["I'll call back shortly", 'In a meeting', 'Please text me']);
    showToast('Call titles & replies applied', ToastTone.success);
  }

  Future<void> _refreshCallState() async {
    try {
      // Read the current call's state (status, direction, etc.), if any.
      final state = await ZohoSalesIQCalls.currentState;
      if (!mounted) return;
      setState(() => _callState = state);
    } catch (_) {
      if (!mounted) return;
      setState(() => _callState = null);
    }
  }

  Future<void> _refreshRecent() async {
    setState(() {
      _recentLoading = true;
      _recentError = null;
    });
    try {
      // Fetch the visitor's recent call conversations.
      final list = await ZohoSalesIQCalls.getList();
      if (!mounted) return;
      setState(() {
        _recent = list.take(5).toList();
        _recentLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _recentError = e.toString();
        _recentLoading = false;
      });
    }
  }

  Future<void> _startCall() async {
    try {
      // Start a new voice/video call with an operator.
      await ZohoSalesIQCalls.start();
      showToast('Call started', ToastTone.success);
      _refreshCallState();
    } catch (_) {
      showToast('Failed to start call', ToastTone.danger);
    }
  }

  Future<void> _endCall() async {
    try {
      // End the current call.
      await ZohoSalesIQCalls.end();
      showToast('Call ended');
      _refreshCallState();
    } catch (_) {
      showToast('Failed to end call', ToastTone.danger);
    }
  }

  void _applyViewMode(_ViewMode mode) {
    setState(() => _viewMode = mode);
    if (mode == _ViewMode.fullScreen) {
      // Show the call UI as a full-screen view.
      ZohoSalesIQCalls.enterFullScreenMode();
    } else {
      // Shrink the call UI to a small floating widget.
      ZohoSalesIQCalls.enterFloatingViewMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _callState?.status ?? SalesIQCallStatus.none;
    final active = status.isCallActive;

    return ScreenScaffold(
      title: 'Calls',
      subtitle: 'Voice calls with your operators',
      children: [
        Section(
          title: 'Active call',
          child: AppCard(
            children: [
              ListRow(
                title: 'Support line',
                subtitle: active ? status.name : 'No active call',
                icon: AppIcon.calls,
                tint: active ? IconTint.secondary : IconTint.primary,
                trailing: AppBadge(
                  label: active ? 'Live' : 'Idle',
                  tone: active ? BadgeTone.success : BadgeTone.primary,
                ),
              ),
              const ListRow(
                title: 'View mode',
                subtitle: 'Full screen or floating widget',
              ),
              Padding(
                padding: const EdgeInsets.only(left: 14, right: 14, bottom: 13),
                child: SegmentedControl<_ViewMode>(
                  value: _viewMode,
                  onChanged: _applyViewMode,
                  segments: const [
                    Segment(_ViewMode.fullScreen, 'Full screen'),
                    Segment(_ViewMode.floating, 'Floating'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: AppButton(
                title: 'Start call',
                icon: AppIcon.calls,
                onPressed: _startCall,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton(
                title: 'End',
                variant: ButtonVariant.destructive,
                onPressed: _endCall,
              ),
            ),
          ],
        ),
        Section(
          title: 'Configuration',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(children: [
                Field(label: 'Online title', controller: _onlineTitle),
                Field(label: 'Offline title', controller: _offlineTitle),
              ]),
              const SizedBox(height: 12),
              AppButton(
                title: 'Apply call titles',
                variant: ButtonVariant.secondary,
                onPressed: _applyTitles,
              ),
            ],
          ),
        ),
        Section(
          title: 'Visible components',
          child: AppCard(
            children: _callComponents.entries.map((entry) {
              return SwitchRow(
                title: entry.value,
                value: _components[entry.key] ?? false,
                onChanged: (v) {
                  setState(() => _components[entry.key] = v);
                  // Show or hide a component (operator name, image...) in the call UI.
                  ZohoSalesIQCalls.setVisibility(entry.key, v);
                },
              );
            }).toList(),
          ),
        ),
        Section(
          title: 'Recent calls',
          child: AppCard(
            children: stateRows(
              loading: _recentLoading,
              error: _recentError,
              empty: _recent.isEmpty,
              onRetry: _refreshRecent,
              skeletonRows: 3,
              emptyIcon: AppIcon.calls,
              emptyTitle: 'No recent calls yet',
              emptySubtitle: 'Completed calls will appear here',
              children: _recent.map((conversation) {
                final isCall = conversation is SalesIQCallConversation;
                final status = isCall ? conversation.status : null;
                final missed = status == CallStatus.missed;
                return ListRow(
                  title: conversation.attenderName ??
                      conversation.departmentName ??
                      'Call',
                  subtitle: status?.name ?? conversation.question,
                  icon: AppIcon.calls,
                  tint: missed ? IconTint.danger : IconTint.secondary,
                  chevron: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      settings: const RouteSettings(name: 'Call'),
                      builder: (_) =>
                          CallDetailScreen(conversation: conversation),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
