import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

import '../widgets/ui/ui.dart';

class _WidgetRow {
  final SIQWidget widget;
  final String title;
  final AppIcon icon;
  final IconTint tint;
  const _WidgetRow(this.widget, this.title, this.icon, this.tint);
}

const List<_WidgetRow> _widgets = [
  _WidgetRow(SIQWidget.chat, 'Chat', AppIcon.chat, IconTint.primary),
  _WidgetRow(SIQWidget.call, 'Call', AppIcon.calls, IconTint.secondary),
  _WidgetRow(
      SIQWidget.articles, 'Articles', AppIcon.knowledgeBase, IconTint.accent),
  _WidgetRow(SIQWidget.previousConversations, 'Previous conversation',
      AppIcon.events, IconTint.primary),
  _WidgetRow(
      SIQWidget.imageCard, 'Image card', AppIcon.article, IconTint.secondary),
  _WidgetRow(
      SIQWidget.videoCard, 'Video card', AppIcon.article, IconTint.accent),
];

/// Screen 08 — homepage widgets visibility + the AI/agent-backed Help Center.
/// Mirrors the RN `HomepageHelpCenterScreen`.
class HomepageHelpCenterScreen extends StatefulWidget {
  const HomepageHelpCenterScreen({super.key});

  @override
  State<HomepageHelpCenterScreen> createState() =>
      _HomepageHelpCenterScreenState();
}

class _HomepageHelpCenterScreenState extends State<HomepageHelpCenterScreen> {
  bool _homepageEnabled = true;
  final Map<SIQWidget, bool> _widgetState = {
    SIQWidget.chat: true,
    SIQWidget.call: true,
    SIQWidget.articles: true,
    SIQWidget.previousConversations: false,
    SIQWidget.imageCard: false,
    SIQWidget.videoCard: false,
  };
  final _question = TextEditingController();
  Object? _result;

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  void _toggleHomepage(bool value) {
    setState(() => _homepageEnabled = value);
    // Show or hide the SDK's homepage landing view.
    ZohoSalesIQ.homepage.setEnabled(value);
  }

  void _toggleWidget(SIQWidget widget, bool value) {
    setState(() => _widgetState[widget] = value);
    // Show or hide a specific widget (chat, call, articles...) on the homepage.
    ZohoSalesIQ.homepage.setVisibility(widget, value);
  }

  Future<void> _askHelpCenter() async {
    try {
      final question = _question.text.isEmpty ? null : _question.text;
      // Open the AI-backed help center, optionally pre-filled with a question.
      // ask(...) returns Future<void> — it completes on success and throws on failure.
      await ZohoSalesIQ.helpCenter.ask(question);
      setState(() => _result = {'opened': true});
      showToast('Help center opened', ToastTone.success);
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
      showToast('Help center failed to open', ToastTone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Homepage',
      subtitle: 'Widgets & the help center',
      children: [
        Section(
          title: 'Homepage',
          child: AppCard(
            children: [
              SwitchRow(
                title: 'Enable homepage',
                subtitle: 'Show the SDK landing view',
                value: _homepageEnabled,
                onChanged: _toggleHomepage,
              ),
            ],
          ),
        ),
        Section(
          title: 'Widgets',
          child: AppCard(
            children: _widgets
                .map((row) => SwitchRow(
                      title: row.title,
                      icon: row.icon,
                      tint: row.tint,
                      value: _widgetState[row.widget] ?? false,
                      onChanged: (v) => _toggleWidget(row.widget, v),
                    ))
                .toList(),
          ),
        ),
        Section(
          title: 'Help center',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                children: [
                  Field(
                    label: 'Question',
                    controller: _question,
                    placeholder: 'Ask anything about the product',
                  ),
                ],
              ),
              const SizedBox(height: 9),
              AppButton(
                title: 'Ask help center',
                icon: AppIcon.help,
                onPressed: _askHelpCenter,
              ),
            ],
          ),
        ),
        if (_result != null) ResultBlock(label: 'Last result', data: _result),
      ],
    );
  }
}
