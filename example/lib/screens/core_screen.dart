import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

import '../routes.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../state/languages.dart';
import '../widgets/ui/ui.dart';
import 'department_picker_screen.dart';
import 'uri_scheme_screen.dart';

/// Screen 02 — no init buttons; startup is automatic. Global config + live
/// status only. Mirrors the RN `CoreScreen`.
class CoreScreen extends StatefulWidget {
  const CoreScreen({super.key});

  @override
  State<CoreScreen> createState() => _CoreScreenState();
}

class _CoreScreenState extends State<CoreScreen> {
  String _language = 'English';
  String _department = 'Support';
  final _pageTitle = TextEditingController(text: 'Checkout screen');
  final _sessionId = TextEditingController();
  final _operatorEmail = TextEditingController();
  CommunicationMode? _communicationMode;
  int? _unreadCount;
  bool? _multipleOpenRestricted;
  bool _themeFromPortal = true;
  bool _syncThemeWithOS = false;
  bool _statusLoaded = false;

  // present() builder state — mirrors the Native Android / RN PresentOptions
  // builder so every screen/list/session-behavior combination is demonstrable.
  String _screenKind = 'conversation'; // conversation | knowledgeBase
  String _listKind = 'all'; // chat | call | all | none
  String _filterKind = 'all'; // ongoing | ended | all
  String _behaviorKind = 'none'; // none | alwaysNew | continueOrNew
  String _sessionKind = 'chat'; // chat | call
  bool _showHomepage = true;
  // Knowledge base screen: optional article id to open directly.
  final _articleId = TextEditingController();

  // Conversation data provider (Conversation.setDataProvider).
  bool _providerRegistered = false;
  final _displayKey = TextEditingController(text: 'order_id');
  final _displayValue = TextEditingController(text: 'A-1024');
  final _secretKey = TextEditingController(text: 'auth_token');
  final _secretValue = TextEditingController(text: 'jwt-sample');

  // Runtime configuration flags (updateConfiguration).
  bool _neutralRatingDisabled = false;
  bool _includeVisitorInfo = true;
  bool _enableHomepageBackStack = true;

  Object? _result;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  @override
  void dispose() {
    _pageTitle.dispose();
    _sessionId.dispose();
    _operatorEmail.dispose();
    _displayKey.dispose();
    _displayValue.dispose();
    _secretKey.dispose();
    _secretValue.dispose();
    _articleId.dispose();
    super.dispose();
  }

  Future<void> _refreshStatus() async {
    try {
      // Ask the SDK which channels are enabled (chat / call / both).
      final mode = await ZohoSalesIQ.getCommunicationMode();
      // Number of unread notifications/messages for the current visitor.
      final count = await ZohoSalesIQ.notification.getBadgeCount();
      // Whether the visitor is prevented from opening multiple chats at once.
      final multipleOpen = await ZohoSalesIQ.chat.isMultipleOpenChatRestricted;
      if (!mounted) return;
      setState(() {
        _communicationMode = mode;
        _unreadCount = count;
        _multipleOpenRestricted = multipleOpen;
        _statusLoaded = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusLoaded = true);
    }
  }

  void _applyOperatorEmail() {
    if (_operatorEmail.text.trim().isEmpty) {
      showToast('Enter an operator email first', ToastTone.danger);
      return;
    }
    // Route the visitor's chats to a specific operator by email address.
    ZohoSalesIQ.chat.setOperatorEmail(_operatorEmail.text.trim());
    showToast('Operator email set', ToastTone.success);
  }

  void _toggleThemeSource(bool fromPortal) {
    setState(() => _themeFromPortal = fromPortal);
    // Choose whether the chat UI theme comes from the SalesIQ portal or the SDK.
    ZohoSalesIQ.setThemeSource(
        fromPortal ? ThemeSource.portal : ThemeSource.sdk);
    showToast(
        'Theme source: ${fromPortal ? 'portal' : 'sdk'}', ToastTone.success);
  }

  void _applyPageTitle() {
    // Tag the current app screen so operators see where the visitor is.
    ZohoSalesIQ.tracking.setPageTitle(_pageTitle.text);
    showToast('Page title updated', ToastTone.success);
  }

  void _applySessionId() {
    if (_sessionId.text.trim().isEmpty) {
      showToast('Enter a session ID first', ToastTone.danger);
      return;
    }
    // Attach a custom session identifier to correlate this visitor's activity.
    ZohoSalesIQ.setSessionID(_sessionId.text.trim());
    showToast('Session ID updated', ToastTone.success);
  }

  void _cycleDepartment() {
    final next = _department == 'Support' ? 'Sales' : 'Support';
    setState(() => _department = next);
    // Record the chosen department; new chats are routed to it via the
    // `departmentName` argument of ZohoSalesIQ.chat.start(...).
    showToast('Default department set to $next', ToastTone.success);
  }

  void _cycleLanguage() {
    final next = nextLanguage(_language);
    setState(() => _language = next.label);
    // Force the chat UI language (e.g. 'en', 'fr') regardless of device locale.
    ZohoSalesIQ.setLanguage(next.code);
    showToast('Language set to ${next.label}', ToastTone.success);
  }

  // Builds the SIQScreen described by the present() builder state above.
  SIQScreen _buildScreen() {
    if (_screenKind == 'knowledgeBase') {
      // Show the knowledge base articles screen, or a specific article by id.
      final id = _articleId.text.trim();
      return SIQKnowledgeBaseScreen.articles(id.isEmpty ? null : id);
    }
    // Pick the conversation list (chat / call / all / none) + its status filter.
    final filter = switch (_filterKind) {
      'ongoing' => SIQConversationListFilter.ongoing,
      'ended' => SIQConversationListFilter.ended,
      _ => SIQConversationListFilter.all,
    };
    final list = switch (_listKind) {
      'chat' => SIQConversationList.chat(filter),
      'call' => SIQConversationList.call(filter),
      'none' => const SIQConversationList.none(),
      _ => SIQConversationList.all(filter),
    };
    // Choose how a session opens: reuse an ongoing one, or force a new one.
    final sessionType =
        _sessionKind == 'call' ? SIQSessionType.call : SIQSessionType.chat;
    final behavior = switch (_behaviorKind) {
      'alwaysNew' => SIQSessionBehavior.alwaysNew(sessionType),
      'continueOrNew' => SIQSessionBehavior.continueOrNew(sessionType),
      _ => const SIQSessionBehavior.none(),
    };
    // Assemble the conversation screen from the chosen list + behavior.
    return SIQConversationScreen.withList(list: list, sessionBehavior: behavior);
  }

  Future<void> _presentSdk() async {
    try {
      // Open (present) the fully-configured SDK screen; showHomepage controls
      // whether the homepage appears on back navigation.
      await ZohoSalesIQ.present(
        screen: _buildScreen(),
        showHomepage: _showHomepage,
      );
      setState(() => _result = {'presented': true});
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
      showToast('Failed to present SDK', ToastTone.danger);
    }
  }

  Future<void> _presentDefault() async {
    try {
      // Open the SDK's built-in default UI (no specific screen requested).
      await ZohoSalesIQ.present();
      setState(() => _result = {'presentedDefault': true});
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
      showToast('Failed to present SDK', ToastTone.danger);
    }
  }

  void _dismissUi() {
    // Close any SalesIQ screen the SDK is currently showing.
    ZohoSalesIQ.dismissUI();
    showToast('SDK UI dismissed');
  }

  // Cycles a value to the next entry in [options] (wraps around).
  String _next(String current, List<String> options) {
    final index = options.indexOf(current);
    return options[(index + 1) % options.length];
  }

  String _cap(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

  String _behaviorLabel(String value) => switch (value) {
        'alwaysNew' => 'Always new',
        'continueOrNew' => 'Continue or new',
        _ => 'None',
      };

  void _toggleSyncThemeWithOS(bool value) {
    setState(() => _syncThemeWithOS = value);
    // Sync the SDK theme with the device's dark/light mode (Android only).
    ZohoSalesIQ.syncThemeWithOSForAndroid(value);
    showToast(value ? 'Theme follows OS' : 'Theme fixed', ToastTone.success);
  }

  Map<String, String> _fieldsFrom(
      TextEditingController key, TextEditingController value) {
    final k = key.text.trim();
    if (k.isEmpty) return <String, String>{};
    return <String, String>{k: value.text};
  }

  Future<void> _toggleProvider(bool enabled) async {
    setState(() => _providerRegistered = enabled);
    if (enabled) {
      // Register a provider the SDK invokes on demand to pull custom display /
      // secret fields for a conversation (refreshData re-triggers it).
      await ZohoSalesIQ.conversation.setDataProvider(
        SalesIQConversationDataProvider(
          getDisplayFields: (conversation) {
            final fields = _fieldsFrom(_displayKey, _displayValue);
            setState(() => _result = {
                  'provider': 'displayFields',
                  'conversationId': conversation.id,
                  'count': fields.length,
                });
            return fields;
          },
          getSecretFields: (conversation) {
            final fields = _fieldsFrom(_secretKey, _secretValue);
            setState(() => _result = {
                  'provider': 'secretFields',
                  'conversationId': conversation.id,
                  'count': fields.length,
                });
            return fields;
          },
        ),
      );
      showToast('Data provider registered', ToastTone.success);
    } else {
      // Remove the provider so the SDK stops requesting custom fields.
      await ZohoSalesIQ.conversation.setDataProvider(null);
      showToast('Data provider removed');
    }
  }

  void _toggleConfig(SIQConfiguration key, bool value) {
    // Toggle a named runtime SDK configuration flag on or off.
    ZohoSalesIQ.updateConfiguration(key, value);
    setState(() => _result = {'updateConfiguration': key.name, 'value': value});
  }

  Future<void> _fetchDepartments() async {
    try {
      // Fetch the list of chat departments configured in the SalesIQ portal.
      final departments = await ZohoSalesIQ.conversation.getDepartments();
      setState(() => _result = {
            'departments': departments
                .map((department) => {
                      'id': department.id,
                      'name': department.name,
                      'available': department.available
                    })
                .toList(),
          });
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
      showToast('Failed to fetch departments', ToastTone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return ValueListenableBuilder<InitStatus>(
      valueListenable: app.initStatus,
      builder: (context, status, _) {
        final variant = switch (status) {
          InitStatus.initialized => BannerVariant.ok,
          InitStatus.failed => BannerVariant.danger,
          _ => BannerVariant.info,
        };
        final bannerTitle = switch (status) {
          InitStatus.initialized => 'Initialized at app launch',
          InitStatus.keysRequired => 'Keys required',
          InitStatus.failed => 'Initialization failed',
          InitStatus.initializing => 'Initializing…',
        };
        final bannerBody = status == InitStatus.keysRequired
            ? 'Add your app key and access key in Settings — the SDK initializes on next launch.'
            : 'The SDK starts automatically with your stored keys — no manual step.';

        final modeLabel = switch (_communicationMode) {
          CommunicationMode.chat => 'Chat only',
          CommunicationMode.call => 'Calls only',
          CommunicationMode.chatAndCall => 'Calls + chat',
          null => _statusLoaded ? 'Mode unavailable' : 'Mode…',
        };

        return ScreenScaffold(
          title: 'Core & Config',
          subtitle: 'Global settings and SDK status',
          children: [
            StatusBanner(
              title: bannerTitle,
              body: bannerBody,
              variant: variant,
            ),
            Section(
              title: 'Status',
              child: AppCard(
                separated: false,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AppBadge(
                          label: modeLabel,
                          tone: _communicationMode != null
                              ? BadgeTone.success
                              : BadgeTone.warning,
                          icon: AppIcon.check,
                        ),
                        AppBadge(
                          label: !_statusLoaded
                              ? 'Unread…'
                              : '${_unreadCount ?? 0} unread',
                          tone: BadgeTone.warning,
                        ),
                        if (_multipleOpenRestricted == true)
                          const AppBadge(
                            label: 'Multi-open restricted',
                            tone: BadgeTone.warning,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Section(
              title: 'Configuration',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    children: [
                      ListRow(
                        title: 'Language',
                        icon: AppIcon.globe,
                        tint: IconTint.primary,
                        value: _language,
                        chevron: true,
                        onTap: _cycleLanguage,
                      ),
                      ListRow(
                        title: 'Department',
                        subtitle: 'Route new chats',
                        value: _department,
                        chevron: true,
                        onTap: _cycleDepartment,
                      ),
                      Field(label: 'Page title', controller: _pageTitle),
                      Field(
                        label: 'Session ID',
                        controller: _sessionId,
                        placeholder: 'Optional identifier',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    title: 'Apply page title',
                    variant: ButtonVariant.secondary,
                    onPressed: _applyPageTitle,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    title: 'Apply session ID',
                    variant: ButtonVariant.secondary,
                    onPressed: _applySessionId,
                  ),
                ],
              ),
            ),
            Section(
              title: 'Present a screen',
              footer:
                  'Build a PresentOptions screen like Native Android: pick the '
                  'screen, list, filter and session behavior, then present(). '
                  '“Present default UI” opens the SDK with no specific screen.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(children: [
                    ListRow(
                      title: 'Screen',
                      subtitle: _screenKind == 'knowledgeBase'
                          ? 'SIQKnowledgeBaseScreen.articles()'
                          : 'SIQConversationScreen.withList(…)',
                      value: _screenKind == 'knowledgeBase'
                          ? 'Knowledge base'
                          : 'Conversation',
                      chevron: true,
                      onTap: () => setState(() => _screenKind =
                          _screenKind == 'conversation'
                              ? 'knowledgeBase'
                              : 'conversation'),
                    ),
                    if (_screenKind == 'conversation') ...[
                      ListRow(
                        title: 'List',
                        subtitle: 'chat · call · all · none',
                        value: _cap(_listKind),
                        chevron: true,
                        onTap: () => setState(() => _listKind = _next(
                            _listKind, const ['chat', 'call', 'all', 'none'])),
                      ),
                      ListRow(
                        title: 'List filter',
                        value: _cap(_filterKind),
                        chevron: true,
                        onTap: () => setState(() => _filterKind = _next(
                            _filterKind, const ['ongoing', 'ended', 'all'])),
                      ),
                      ListRow(
                        title: 'Session behavior',
                        value: _behaviorLabel(_behaviorKind),
                        chevron: true,
                        onTap: () => setState(() => _behaviorKind = _next(
                            _behaviorKind,
                            const ['none', 'alwaysNew', 'continueOrNew'])),
                      ),
                      if (_behaviorKind != 'none')
                        ListRow(
                          title: 'Session type',
                          value: _cap(_sessionKind),
                          chevron: true,
                          onTap: () => setState(() => _sessionKind = _next(
                              _sessionKind, const ['chat', 'call'])),
                        ),
                    ] else ...[
                      // Knowledge base: only the ARTICLES resource type exists;
                      // an optional article id opens that article directly.
                      const ListRow(
                        title: 'Type',
                        subtitle: 'ResourceType.articles',
                        value: 'Articles',
                        disabled: true,
                      ),
                      Field(
                        label: 'Article ID',
                        controller: _articleId,
                        placeholder: 'Optional — open a specific article',
                        textCapitalization: TextCapitalization.none,
                      ),
                    ],
                    SwitchRow(
                      title: 'Show homepage',
                      subtitle: 'On back navigation',
                      value: _showHomepage,
                      onChanged: (v) => setState(() => _showHomepage = v),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  AppButton(
                    title: 'present(PresentOptions)',
                    icon: AppIcon.chat,
                    onPressed: _presentSdk,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          title: 'Dismiss UI',
                          variant: ButtonVariant.secondary,
                          onPressed: _dismissUi,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton(
                          title: 'Default UI',
                          variant: ButtonVariant.secondary,
                          onPressed: _presentDefault,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppButton(
              title: 'Fetch departments',
              variant: ButtonVariant.ghost,
              onPressed: _fetchDepartments,
            ),
            Section(
              title: 'Operator & theme',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(children: [
                    Field(
                      label: 'Operator email',
                      controller: _operatorEmail,
                      placeholder: 'agent@company.com',
                    ),
                    SwitchRow(
                      title: 'Theme from portal',
                      subtitle: 'Off = local SDK theme',
                      value: _themeFromPortal,
                      onChanged: _toggleThemeSource,
                    ),
                    SwitchRow(
                      title: 'Sync theme with OS',
                      subtitle: 'Android · follow device dark/light mode',
                      value: _syncThemeWithOS,
                      onChanged: _toggleSyncThemeWithOS,
                    ),
                  ]),
                  const SizedBox(height: 12),
                  AppButton(
                    title: 'Apply operator email',
                    variant: ButtonVariant.secondary,
                    onPressed: _applyOperatorEmail,
                  ),
                ],
              ),
            ),
            Section(
              title: 'Advanced',
              child: AppCard(children: [
                ListRow(
                  title: 'Department picker',
                  subtitle: 'getDepartments → setDepartment',
                  icon: AppIcon.visitor,
                  chevron: true,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      settings: const RouteSettings(name: 'Department'),
                      builder: (_) => const DepartmentPickerScreen())),
                ),
                ListRow(
                  title: 'URI scheme',
                  subtitle: 'setUriScheme(scheme, hosts, paths)',
                  icon: AppIcon.globe,
                  chevron: true,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      settings: const RouteSettings(name: 'URI scheme'),
                      builder: (_) => const UriSchemeScreen())),
                ),
                ListRow(
                  title: 'Refresh data',
                  subtitle: 'refreshData(type, conversationId)',
                  icon: AppIcon.refresh,
                  tint: IconTint.secondary,
                  chevron: true,
                  onTap: () =>
                      Navigator.of(context).pushNamed(Routes.refreshData),
                ),
              ]),
            ),
            Section(
              title: 'Conversation data provider',
              footer: 'The SDK invokes this to fetch display / secret fields; '
                  'refreshData triggers it. Each request updates the response '
                  'below.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(children: [
                    SwitchRow(
                      title: 'Register data provider',
                      subtitle: 'Conversation.setDataProvider',
                      icon: AppIcon.refresh,
                      tint: IconTint.secondary,
                      value: _providerRegistered,
                      onChanged: _toggleProvider,
                    ),
                  ]),
                  const SizedBox(height: 12),
                  AppCard(children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Field(
                            label: 'Display field key',
                            controller: _displayKey,
                            textCapitalization: TextCapitalization.none,
                          ),
                        ),
                        Expanded(
                          child: Field(
                            label: 'Value',
                            controller: _displayValue,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Field(
                            label: 'Secret field key',
                            controller: _secretKey,
                            textCapitalization: TextCapitalization.none,
                          ),
                        ),
                        Expanded(
                          child: Field(
                            label: 'Value',
                            controller: _secretValue,
                          ),
                        ),
                      ],
                    ),
                  ]),
                ],
              ),
            ),
            Section(
              title: 'Configuration flags',
              footer: 'Runtime flags applied via updateConfiguration(key, value).',
              child: AppCard(children: [
                SwitchRow(
                  title: 'Neutral rating disabled',
                  value: _neutralRatingDisabled,
                  onChanged: (v) {
                    setState(() => _neutralRatingDisabled = v);
                    _toggleConfig(SIQConfiguration.NeutralRatingDisabled, v);
                  },
                ),
                SwitchRow(
                  title: 'Include visitor info',
                  subtitle: 'In conversation info on the console',
                  value: _includeVisitorInfo,
                  onChanged: (v) {
                    setState(() => _includeVisitorInfo = v);
                    _toggleConfig(
                        SIQConfiguration.IncludeVisitorInfoInConversationInfo,
                        v);
                  },
                ),
                SwitchRow(
                  title: 'Homepage back stack on chat initiation',
                  value: _enableHomepageBackStack,
                  onChanged: (v) {
                    setState(() => _enableHomepageBackStack = v);
                    _toggleConfig(
                        SIQConfiguration
                            .EnableHomePageBackStackForChatInitiation,
                        v);
                  },
                ),
              ]),
            ),
            if (_result != null)
              ResultBlock(label: 'Last result', data: _result),
          ],
        );
      },
    );
  }
}
