import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

import '../widgets/ui/ui.dart';

enum _VisibilityKey { always, activeChat, never }

/// Screen 03 — launcher visibility, drag-to-dismiss, operator image, position.
/// Mirrors the RN `LauncherScreen`.
class LauncherScreen extends StatefulWidget {
  const LauncherScreen({super.key});

  @override
  State<LauncherScreen> createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  _VisibilityKey _visibility = _VisibilityKey.always;
  bool _dragToDismiss = true;
  bool _operatorImage = true;
  bool _customLauncher = false;
  String _horizontal = 'Right';
  String _vertical = 'Bottom';
  final _minPressDuration = TextEditingController(text: '500');

  @override
  void dispose() {
    _minPressDuration.dispose();
    super.dispose();
  }

  static const _copy = {
    _VisibilityKey.always:
        'Shown at all times, even without an active conversation.',
    _VisibilityKey.activeChat:
        'Only shown while the visitor has an active conversation.',
    _VisibilityKey.never:
        'The launcher never appears; present the SDK from your own UI.',
  };

  VisibilityMode get _mode => switch (_visibility) {
        _VisibilityKey.always => VisibilityMode.always,
        _VisibilityKey.activeChat => VisibilityMode.whenActiveChat,
        _VisibilityKey.never => VisibilityMode.never,
      };

  void _apply() {
    try {
      if (_customLauncher) {
        // Apply the visibility mode to your own custom launcher view.
        ZohoSalesIQ.launcher.setVisibilityModeToCustomLauncher(_mode);
      } else {
        // Show the default floating launcher with the chosen visibility mode.
        ZohoSalesIQ.launcher.show(_mode);
      }
      // Let the visitor drag the launcher off-screen to dismiss it.
      ZohoSalesIQ.launcher.enableDragToDismiss(_dragToDismiss);
      // Show the connected operator's photo on the launcher button.
      ZohoSalesIQ.launcher.showOperatorImage(_operatorImage);

      final properties = LauncherProperties(LauncherMode.floating)
        ..horizontalDirection =
            _horizontal == 'Left' ? Horizontal.left : Horizontal.right
        ..verticalDirection =
            _vertical == 'Top' ? Vertical.top : Vertical.bottom;
      // Position the floating launcher on screen (Android only).
      ZohoSalesIQ.setLauncherPropertiesForAndroid(properties);

      final minPress = int.tryParse(_minPressDuration.text.trim());
      if (minPress != null) {
        // Set the long-press duration (ms) before the drag gesture starts.
        ZohoSalesIQ.launcher.setMinimumPressDuration(minPress);
      }

      // Re-render the launcher so the new properties take effect immediately.
      ZohoSalesIQ.launcher.refreshLauncher();

      showToast('Launcher settings applied', ToastTone.success);
    } catch (e) {
      showToast('Failed to apply launcher settings', ToastTone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Launcher',
      subtitle: 'How and where the launcher appears',
      children: [
        Section(
          title: 'Visibility mode',
          footer: _copy[_visibility],
          child: SegmentedControl<_VisibilityKey>(
            value: _visibility,
            onChanged: (v) => setState(() => _visibility = v),
            segments: const [
              Segment(_VisibilityKey.always, 'Always'),
              Segment(_VisibilityKey.activeChat, 'Active chat'),
              Segment(_VisibilityKey.never, 'Never'),
            ],
          ),
        ),
        Section(
          title: 'Behavior',
          child: AppCard(
            children: [
              SwitchRow(
                title: 'Drag to dismiss',
                subtitle: 'Let users swipe the launcher away',
                value: _dragToDismiss,
                onChanged: (v) => setState(() => _dragToDismiss = v),
              ),
              SwitchRow(
                title: 'Operator image',
                subtitle: 'Show agent photo in launcher',
                value: _operatorImage,
                onChanged: (v) => setState(() => _operatorImage = v),
              ),
              SwitchRow(
                title: 'Custom launcher',
                subtitle: 'Use your own trigger view',
                value: _customLauncher,
                onChanged: (v) => setState(() => _customLauncher = v),
              ),
            ],
          ),
        ),
        Section(
          title: 'Gesture',
          footer: 'Long-press duration before the drag gesture activates.',
          child: AppCard(
            children: [
              Field(
                label: 'Minimum press duration (ms)',
                controller: _minPressDuration,
              ),
            ],
          ),
        ),
        Section(
          title: 'Position',
          footer: 'Android only.',
          child: AppCard(
            children: [
              ListRow(
                title: 'Horizontal',
                value: _horizontal,
                onTap: () => setState(() =>
                    _horizontal = _horizontal == 'Left' ? 'Right' : 'Left'),
              ),
              ListRow(
                title: 'Vertical',
                value: _vertical,
                onTap: () => setState(
                    () => _vertical = _vertical == 'Top' ? 'Bottom' : 'Top'),
              ),
            ],
          ),
        ),
        AppButton(
          title: 'Apply launcher settings',
          icon: AppIcon.launcher,
          onPressed: _apply,
        ),
      ],
    );
  }
}
