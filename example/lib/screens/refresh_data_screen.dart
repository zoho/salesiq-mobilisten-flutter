import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

import '../widgets/ui/ui.dart';

/// Detail — refreshData(type, conversationId): re-invokes the registered
/// conversation data provider for a conversation, then pushes the resolved
/// display / secret fields to the server. Mirrors the Android
/// `RefreshDataScreen`.
class RefreshDataScreen extends StatefulWidget {
  const RefreshDataScreen({super.key});

  @override
  State<RefreshDataScreen> createState() => _RefreshDataScreenState();
}

class _RefreshDataScreenState extends State<RefreshDataScreen> {
  SalesIQRefreshDataType _fieldType = SalesIQRefreshDataType.displayFields;
  final _conversationId = TextEditingController();
  bool _busy = false;
  Object? _result;

  @override
  void dispose() {
    _conversationId.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final id = _conversationId.text.trim();
    if (id.isEmpty) {
      showToast('Enter a conversation ID first', ToastTone.danger);
      return;
    }
    setState(() => _busy = true);
    try {
      // Ask the SDK to re-fetch this conversation's fields from the registered
      // conversation data provider, then push them to the server.
      await ZohoSalesIQ.refreshData(_fieldType, id);
      setState(() => _result = {'success': true, 'type': _fieldType.name});
      showToast('Data refreshed', ToastTone.success);
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
      showToast('Refresh failed', ToastTone.danger);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Refresh data',
      subtitle: 'refreshData(type, conversationId)',
      children: [
        Section(
          title: 'Field type',
          child: SegmentedControl<SalesIQRefreshDataType>(
            value: _fieldType,
            onChanged: (v) => setState(() => _fieldType = v),
            segments: const [
              Segment(
                  SalesIQRefreshDataType.displayFields, 'Display fields'),
              Segment(SalesIQRefreshDataType.secretFields, 'Secret fields'),
            ],
          ),
        ),
        Section(
          title: 'Conversation',
          footer:
              'Invokes the registered conversation data provider, then pushes '
              'the resolved fields to the server. Android only — a no-op on iOS.',
          child: AppCard(children: [
            Field(
              label: 'Conversation ID',
              controller: _conversationId,
              placeholder: 'c_8f2a',
              textCapitalization: TextCapitalization.none,
            ),
          ]),
        ),
        AppButton(
          title: 'Refresh',
          icon: AppIcon.refresh,
          loading: _busy,
          onPressed: _refresh,
        ),
        if (_result != null) ResultBlock(label: 'Response', data: _result),
      ],
    );
  }
}
