import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../state/languages.dart';
import '../widgets/ui/ui.dart';

/// Mirrors the `salesiq_mobilisten` package version at the time of writing.
const String _sdkVersion = '7.0.0-beta.1';

/// Screen 11 — appearance, language, credentials (keys-required state), logger,
/// SDK version. Mirrors the RN `SettingsScreen`.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = 'English';
  bool _loggerEnabled = false;
  late final TextEditingController _appKeyDraft;
  late final TextEditingController _accessKeyDraft;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _appKeyDraft = TextEditingController();
    _accessKeyDraft = TextEditingController();
    _loadLogger();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final app = AppScope.of(context);
    if (!hasPlaceholderKeys(app.appKey, app.accessKey)) {
      _appKeyDraft.text = app.pendingAppKey ?? app.appKey;
      _accessKeyDraft.text = app.pendingAccessKey ?? app.accessKey;
    } else {
      _appKeyDraft.text = app.pendingAppKey ?? '';
      _accessKeyDraft.text = app.pendingAccessKey ?? '';
    }
  }

  @override
  void dispose() {
    _appKeyDraft.dispose();
    _accessKeyDraft.dispose();
    super.dispose();
  }

  Future<void> _loadLogger() async {
    try {
      // Check whether the SDK's on-device debug logger is currently enabled.
      final enabled = await ZohoSalesIQLogger.isEnabled;
      if (!mounted) return;
      setState(() => _loggerEnabled = enabled);
    } catch (_) {}
  }

  void _cycleLanguage() {
    final next = nextLanguage(_language);
    setState(() => _language = next.label);
    // Force the chat UI language (e.g. 'en', 'fr') regardless of device locale.
    ZohoSalesIQ.setLanguage(next.code);
  }

  void _toggleLogger(bool value) {
    setState(() => _loggerEnabled = value);
    // Turn the SDK's on-device debug logger on or off.
    ZohoSalesIQLogger.setEnabled(value);
  }

  void _saveCredentials() {
    final appKey = _appKeyDraft.text.trim();
    final accessKey = _accessKeyDraft.text.trim();
    if (appKey.isEmpty || accessKey.isEmpty) {
      showToast('Both keys are required', ToastTone.danger);
      return;
    }
    final app = AppScope.of(context);
    app.pendingAppKey = appKey;
    app.pendingAccessKey = accessKey;
    showToast('Keys saved — restart the app to initialize', ToastTone.success);
  }

  ThemeMode _modeFromLabel(String label) => switch (label) {
        'Light' => ThemeMode.light,
        'Dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  String _labelFromMode(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
        ThemeMode.system => 'System',
      };

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([app.theme, app.initStatus]),
      builder: (context, _) {
        final keysRequired = app.initStatus.value == InitStatus.keysRequired;
        return ScreenScaffold(
          title: 'Settings',
          subtitle: 'Appearance, credentials, and developer tools',
          children: [
            Section(
              title: 'Appearance',
              child: SegmentedControl<String>(
                value: _labelFromMode(app.theme.mode),
                onChanged: (label) => app.theme.setMode(_modeFromLabel(label)),
                segments: const [
                  Segment('Light', 'Light'),
                  Segment('Dark', 'Dark'),
                  Segment('System', 'System'),
                ],
              ),
            ),
            Section(
              title: 'Preferences',
              child: AppCard(
                children: [
                  ListRow(
                    title: 'Language',
                    icon: AppIcon.globe,
                    tint: IconTint.primary,
                    value: _language,
                    chevron: true,
                    onTap: _cycleLanguage,
                  ),
                ],
              ),
            ),
            Section(
              title: 'Credentials',
              child: AppCard(
                children: [
                  Field(
                    label: 'App key',
                    controller: _appKeyDraft,
                    placeholder: '<YOUR_APP_KEY>',
                    textCapitalization: TextCapitalization.none,
                  ),
                  Field(
                    label: 'Access key',
                    controller: _accessKeyDraft,
                    placeholder: '<YOUR_ACCESS_KEY>',
                    textCapitalization: TextCapitalization.none,
                  ),
                  if (keysRequired)
                    const ListRow(
                      title: 'Keys required',
                      subtitle: 'Add keys — the SDK initializes on next launch',
                      icon: AppIcon.key,
                      tint: IconTint.danger,
                    ),
                  ListRow(
                    title: 'Save keys',
                    titleTone: RowTitleTone.brand,
                    onTap: _saveCredentials,
                  ),
                ],
              ),
            ),
            Section(
              title: 'Developer',
              child: AppCard(
                children: [
                  SwitchRow(
                    title: 'Debug logs',
                    subtitle: 'Capture SDK logs on device',
                    icon: AppIcon.logs,
                    tint: IconTint.accent,
                    value: _loggerEnabled,
                    onChanged: _toggleLogger,
                  ),
                  ListRow(
                    title: 'Write test log',
                    subtitle: 'iOS only · writeLogForiOS',
                    chevron: true,
                    onTap: () {
                      // Write a custom entry to the SDK log file (iOS only).
                      ZohoSalesIQLogger.writeLogForiOS(
                          'Sample log from the demo app', Level.info);
                      showToast('Log written (iOS)');
                    },
                  ),
                  ListRow(
                    title: 'Clear logs',
                    subtitle: 'iOS only · clearLogsForiOS',
                    chevron: true,
                    onTap: () {
                      // Delete the SDK's stored log files (iOS only).
                      ZohoSalesIQLogger.clearLogsForiOS();
                      showToast('Logs cleared (iOS)');
                    },
                  ),
                  ListRow(
                    title: 'Set log path',
                    subtitle: 'iOS only · setPathForiOS',
                    chevron: true,
                    onTap: () {
                      // Set the directory where the SDK writes its logs (iOS only).
                      ZohoSalesIQLogger.setPathForiOS('mobilisten/logs');
                      showToast('Log path set (iOS)');
                    },
                  ),
                  const ListRow(title: 'SDK version', value: _sdkVersion),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
