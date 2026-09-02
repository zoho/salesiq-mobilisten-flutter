import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

import '../widgets/conversation_attributes_editor.dart';
import '../widgets/ui/ui.dart';
import 'chat_detail_screen.dart';
import 'orders_showcase_screen.dart';

/// Serializes an [SIQChat] to a plain map for the result block.
Map<String, dynamic> _chatMap(SIQChat? chat) => {
      'id': chat?.id,
      'question': chat?.question,
      'status': chat?.status.name,
      'attenderName': chat?.attenderName,
      'departmentName': chat?.departmentName,
      'unreadCount': chat?.unreadCount,
    };

/// The full ChatComponent set (mediaCapture excluded — deprecated).
const _chatComponents = <ZSIQChatComponent, String>{
  ZSIQChatComponent.operatorImage: 'Operator image',
  ZSIQChatComponent.rating: 'Rating',
  ZSIQChatComponent.feedback: 'Feedback',
  ZSIQChatComponent.screenshot: 'Screenshot',
  ZSIQChatComponent.preChatForm: 'Pre-chat form',
  ZSIQChatComponent.visitorName: 'Visitor name',
  ZSIQChatComponent.emailTranscript: 'Email transcript',
  ZSIQChatComponent.fileShare: 'File sharing',
  ZSIQChatComponent.takePhoto: 'Take photo',
  ZSIQChatComponent.recordVideo: 'Record video',
  ZSIQChatComponent.mediaLibrary: 'Media library',
  ZSIQChatComponent.end: 'End',
  ZSIQChatComponent.endWhenInQueue: 'End · when in queue',
  ZSIQChatComponent.endWhenBotConnected: 'End · when bot connected',
  ZSIQChatComponent.endWhenOperatorConnected: 'End · when operator connected',
  ZSIQChatComponent.reopen: 'Reopen',
  ZSIQChatComponent.call: 'Call',
  ZSIQChatComponent.fileSharingWhenBotConnected:
      'File sharing · when bot connected',
  ZSIQChatComponent.voiceNoteWhenBotConnected:
      'Voice note · when bot connected',
  ZSIQChatComponent.queuePosition: 'Queue position',
};

/// Screen 05 — start conversations, triggers, history, components, operator
/// image, and the Orders (customChatId) showcase. Mirrors the RN `ChatScreen`.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _question = TextEditingController();
  final _chatId = TextEditingController();
  final _onlineTitle = TextEditingController(text: 'We are online');
  final _offlineTitle = TextEditingController(text: 'Leave us a message');
  final _attenderId = TextEditingController();
  final _chatAction = TextEditingController(text: 'apply_coupon');
  final _triggerAction = TextEditingController(text: 'proactive_greeting');
  final _startQuestion = TextEditingController(text: 'How can we help?');
  final _actionUuid = TextEditingController();
  final _listTitle = TextEditingController(text: 'Conversations');
  final Map<ZSIQChatComponent, bool> _componentState = {
    for (final component in _chatComponents.keys)
      component: component != ZSIQChatComponent.preChatForm,
  };
  bool _hideQueueTime = false;
  bool _showOfflineMessage = false;
  bool _conversationHistory = true;
  Object? _result;
  String? _attenderImage;

  /// Attribute set for the global setAttributes path.
  final _globalAttributes = ConversationAttributesController();

  /// Departments fetched via `Conversation.getDepartments()` (after init).
  /// Feed the checkbox multi-select in each attributes editor.
  List<SalesIQDepartment> _departments = [];

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      // Fetch departments so the attribute editors can offer a multi-select.
      final departments = await ZohoSalesIQ.conversation.getDepartments();
      if (!mounted) return;
      setState(() => _departments = departments);
    } catch (_) {
      // Departments are optional; editors just show an empty picker.
    }
  }

  @override
  void dispose() {
    _question.dispose();
    _chatId.dispose();
    _onlineTitle.dispose();
    _offlineTitle.dispose();
    _attenderId.dispose();
    _chatAction.dispose();
    _triggerAction.dispose();
    _startQuestion.dispose();
    _actionUuid.dispose();
    _listTitle.dispose();
    _globalAttributes.dispose();
    super.dispose();
  }

  /// `Chat.get(id)` — fetch a single conversation by id (vs. `openChatWithID`
  /// which opens the UI).
  Future<void> _fetchChatById() async {
    if (_chatId.text.trim().isEmpty) {
      showToast('Enter a chat ID first', ToastTone.danger);
      return;
    }
    try {
      // Look up a single conversation's data by its id (no UI is shown).
      final chat = await ZohoSalesIQ.chat.get(_chatId.text.trim());
      setState(() => _result = {'get': _chatMap(chat)});
      if (chat == null) {
        showToast('No chat for that ID', ToastTone.defaultTone);
        return;
      }
      showToast('Fetched chat', ToastTone.success);
      if (!mounted) return;
      // Show the fetched conversation in a dedicated detail screen.
      await Navigator.of(context).push(MaterialPageRoute(
          settings: const RouteSettings(name: 'Conversation'),
          builder: (_) => ChatDetailScreen(chat: chat)));
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
      showToast('Failed to fetch chat', ToastTone.danger);
    }
  }

  /// System-message overrides, offline behaviour and per-conversation
  /// attributes (`Conversation` namespace).
  void _applyBehavior() {
    // Set how long (seconds) to wait for an operator before showing wait UI.
    ZohoSalesIQ.chat.setWaitingTime(10);
    // Set the message shown when no operators are online.
    ZohoSalesIQ.chat.setOfflineMessage('We are away — leave us a message.');
    setState(() => _result = {
          'setWaitingTime': 10,
          'setOfflineMessage': true,
        });
    showToast('Behavior applied', ToastTone.success);
  }

  /// `Conversation.setAttributes` — apply the global attribute set (name /
  /// additionalInfo / displayPicture / departments) to the current / next
  /// conversation.
  void _applyAttributes() {
    final attributes = _globalAttributes.buildAttributes(_departments);
    if (attributes == null) {
      showToast('Fill at least one attribute first', ToastTone.danger);
      return;
    }
    // Attach custom attributes to the current conversation.
    ZohoSalesIQ.conversation.setAttributes(attributes);
    setState(() => _result = {'conversation.setAttributes': true});
    showToast('Attributes set', ToastTone.success);
  }

  // [pending SalesIQConversation support] `_getChats` (and the ChatDetailScreen
  // flow it drives) is commented out along with Chat.getChats /
  // getChatsWithFilter in the package. Uncomment once the list APIs return
  // SalesIQConversation.
  //
  // Future<void> _getChats() async {
  //   try {
  //     final chats = await ZohoSalesIQ.chat.getChats();
  //     final open = await ZohoSalesIQ.chat.getChatsWithFilter(SIQChatStatus.open);
  //     setState(() => _result = {'count': chats.length, 'open': open.length});
  //     if (chats.isEmpty) {
  //       showToast('No conversations found');
  //       return;
  //     }
  //     if (!mounted) return;
  //     Navigator.of(context).push(
  //       MaterialPageRoute(
  //         settings: const RouteSettings(name: 'Conversation'),
  //         builder: (_) => ChatDetailScreen(chat: chats.first),
  //       ),
  //     );
  //   } catch (e) {
  //     setState(() => _result = {'error': e.toString()});
  //     showToast('Failed to load chats', ToastTone.danger);
  //   }
  // }

  Future<void> _fetchAttenderImage() async {
    if (_attenderId.text.trim().isEmpty) {
      showToast('Enter an attender ID', ToastTone.danger);
      return;
    }
    try {
      // Download the operator's (attender's) profile image as raw bytes.
      final image =
          await ZohoSalesIQ.chat.fetchAttenderImage(_attenderId.text.trim(), true);
      setState(() {
        _attenderImage = image.isEmpty ? null : image;
        _result = {
          'attenderID': _attenderId.text.trim(),
          'imageChars': image.length,
        };
      });
      showToast(image.isEmpty ? 'No image for that attender' : 'Fetched operator image',
          image.isEmpty ? ToastTone.defaultTone : ToastTone.success);
    } catch (e) {
      setState(() {
        _attenderImage = null;
        _result = {'error': e.toString()};
      });
      showToast('Failed to fetch image', ToastTone.danger);
    }
  }

  /// Renders the fetched attender image, which arrives as an http URL, a data:
  /// URI, or a raw base64 string (mirrors the RN/Cordova samples).
  Widget? _attenderImageWidget() {
    final s = _attenderImage;
    if (s == null || s.isEmpty) return null;
    if (s.startsWith('http')) {
      return Image.network(s, width: 72, height: 72, fit: BoxFit.cover);
    }
    final b64 = s.contains(',') ? s.split(',').last : s;
    try {
      return Image.memory(base64Decode(b64), width: 72, height: 72, fit: BoxFit.cover);
    } catch (_) {
      return null;
    }
  }

  void _applyTitles() {
    // Set the chat window header text for the online and offline states.
    ZohoSalesIQ.chat.setTitle(_onlineTitle.text, _offlineTitle.text);
    showToast('Chat titles applied', ToastTone.success);
  }

  void _registerAction() {
    if (_chatAction.text.trim().isEmpty) return;
    // Register a custom in-chat action button the app can respond to.
    ZohoSalesIQ.chatActions.register(_chatAction.text.trim());
    // Set how long (seconds) the app has to handle a fired chat action.
    ZohoSalesIQ.chatActions.setTimeout(30);
    setState(() => _result = {'registeredAction': _chatAction.text.trim()});
    showToast('Chat action registered (30s timeout)', ToastTone.success);
  }

  void _unregisterAction() {
    if (_chatAction.text.trim().isEmpty) return;
    // Remove a previously registered custom chat action.
    ZohoSalesIQ.chatActions.unregister(_chatAction.text.trim());
    setState(() => _result = {'unregisteredAction': _chatAction.text.trim()});
    showToast('Chat action unregistered');
  }

  void _unregisterAllActions() {
    // Remove every registered custom chat action at once.
    ZohoSalesIQ.chatActions.unregisterAll();
    setState(() => _result = {'unregisteredAll': true});
    showToast('All chat actions unregistered');
  }

  void _completeAction({required bool withMessage}) {
    final uuid = _actionUuid.text.trim();
    if (uuid.isEmpty) {
      showToast('Enter an action UUID first', ToastTone.danger);
      return;
    }
    if (withMessage) {
      // Mark the action complete and show a confirmation message in chat.
      // Modern path: sendEvent(completeChatAction, [uuid, state, message]).
      ZohoSalesIQ.sendEvent(
          SIQSendEvent.completeChatAction, [uuid, true, 'Action completed']);
      setState(() =>
          _result = {'completeChatAction': uuid, 'state': true});
    } else {
      // Mark the fired chat action as complete: sendEvent(event, [uuid]).
      ZohoSalesIQ.sendEvent(SIQSendEvent.completeChatAction, [uuid]);
      setState(() => _result = {'completeChatAction': uuid});
    }
    showToast('Chat action completed', ToastTone.success);
  }

  void _prefillQuestion() {
    // Prefill the chat input with a question for the next new chat window.
    ZohoSalesIQ.chat.setQuestion(_startQuestion.text);
    setState(() => _result = {'setQuestion': _startQuestion.text});
    showToast('Question prefilled', ToastTone.success);
  }

  Future<void> _startConversation() async {
    try {
      // Start a new chat with the given opening question.
      final chat = await ZohoSalesIQ.chat.start(
        _startQuestion.text.trim().isEmpty
            ? 'How can we help?'
            : _startQuestion.text.trim(),
      );
      setState(() => _result = {'started': _chatMap(chat)});
      showToast('Conversation started', ToastTone.success);
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
      showToast('Failed to start chat', ToastTone.danger);
    }
  }

  Future<void> _startWithTrigger() async {
    final action = _triggerAction.text.trim();
    if (action.isEmpty) {
      showToast('Enter a trigger action name first', ToastTone.danger);
      return;
    }
    try {
      // Start a new chat through the trigger identified by [action].
      final chat = await ZohoSalesIQ.chat.initiateWithTrigger(action);
      setState(() => _result = {'initiatedWithTrigger': _chatMap(chat)});
      showToast('Trigger fired', ToastTone.success);
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
      showToast('Trigger failed', ToastTone.danger);
    }
  }

  void _setDepartments() {
    // Restrict routing to a specific set of departments for new chats.
    ZohoSalesIQ.setDepartments(const ['Support', 'Sales']);
    setState(() => _result = {
          'setDepartments': ['Support', 'Sales']
        });
    showToast('Departments set', ToastTone.success);
  }

  void _applyListTitle() {
    // Set the title shown above the SDK's conversations list.
    ZohoSalesIQ.setConversationListTitle(_listTitle.text);
    setState(() => _result = {'setConversationListTitle': _listTitle.text});
    showToast('List title applied', ToastTone.success);
  }

  void _toggle(ZSIQChatComponent component, bool value) {
    // Show or hide a specific UI component inside the chat window.
    ZohoSalesIQ.chat.setVisibility(component, value);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Chat',
      subtitle: 'Conversations, triggers & components',
      children: [
        Section(
          title: 'Start chat',
          footer: 'Chat.start(question) opens a new chat; setQuestion prefills '
              'the input; initiateWithTrigger(actionName) fires a trigger.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(children: [
                Field(label: 'Question', controller: _startQuestion),
                ListRow(
                  title: 'Prefill question',
                  subtitle: 'chat.setQuestion(question)',
                  titleTone: RowTitleTone.brand,
                  onTap: _prefillQuestion,
                ),
                Field(
                  label: 'Trigger action name',
                  controller: _triggerAction,
                  placeholder: 'e.g. proactive_greeting',
                  textCapitalization: TextCapitalization.none,
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: AppButton(
                    title: 'Start conversation',
                    icon: AppIcon.chat,
                    onPressed: _startConversation,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    title: 'Start with trigger',
                    variant: ButtonVariant.secondary,
                    onPressed: _startWithTrigger,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              AppButton(
                title: 'Set departments (Support, Sales)',
                variant: ButtonVariant.ghost,
                onPressed: _setDepartments,
              ),
            ],
          ),
        ),
        Section(
          title: 'Global conversation attributes',
          footer: 'Conversation.setAttributes(attributes) — applies to the '
              'current / next conversation.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(children: [
                ConversationAttributesEditor(
                  controller: _globalAttributes,
                  departments: _departments,
                ),
              ]),
              const SizedBox(height: 12),
              AppButton(
                title: 'Set attributes',
                variant: ButtonVariant.secondary,
                onPressed: _applyAttributes,
              ),
            ],
          ),
        ),
        Section(
          title: 'Open & history',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(children: [
                Field(
                  label: 'Chat ID',
                  controller: _chatId,
                  placeholder: 'Paste a conversation ID',
                  textCapitalization: TextCapitalization.none,
                ),
                ListRow(
                  title: 'Fetch by ID',
                  subtitle: 'Chat.get(id) — no UI',
                  titleTone: RowTitleTone.brand,
                  chevron: true,
                  onTap: _fetchChatById,
                ),
              ]),
              // [pending SalesIQConversation support] 'Get chats → detail' is
              // commented out along with Chat.getChats / getChatsWithFilter.
              // const SizedBox(height: 12),
              // AppButton(
              //   title: 'Get chats → detail',
              //   variant: ButtonVariant.secondary,
              //   onPressed: _getChats,
              // ),
            ],
          ),
        ),
        Section(
          title: 'Operator image',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(children: [
                Field(
                  label: 'Attender ID',
                  controller: _attenderId,
                  placeholder: 'fetchAttenderImage(attenderId)',
                  textCapitalization: TextCapitalization.none,
                ),
              ]),
              const SizedBox(height: 12),
              AppButton(
                title: 'Fetch operator image',
                variant: ButtonVariant.ghost,
                onPressed: _fetchAttenderImage,
              ),
              if (_attenderImageWidget() != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _attenderImageWidget(),
                  ),
                ),
            ],
          ),
        ),
        Section(
          title: 'Titles & queue',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(children: [
                Field(label: 'Online title', controller: _onlineTitle),
                Field(label: 'Offline title', controller: _offlineTitle),
                SwitchRow(
                  title: 'Hide queue time',
                  value: _hideQueueTime,
                  onChanged: (v) {
                    setState(() => _hideQueueTime = v);
                    // Show or hide the estimated queue wait time in chat.
                    ZohoSalesIQ.chat.hideQueueTime(v);
                  },
                ),
              ]),
              const SizedBox(height: 12),
              AppButton(
                title: 'Apply titles',
                variant: ButtonVariant.secondary,
                onPressed: _applyTitles,
              ),
              const SizedBox(height: 12),
              AppButton(
                title: 'Show feedback (up to 5 min)',
                variant: ButtonVariant.ghost,
                onPressed: () {
                  // Allow the feedback form to appear for up to N seconds after a chat ends.
                  ZohoSalesIQ.chat.showFeedback(300);
                  // Still show feedback even if the visitor skipped rating.
                  ZohoSalesIQ.chat.showFeedbackAfterSkip(true);
                  showToast('Feedback configured', ToastTone.success);
                },
              ),
            ],
          ),
        ),
        Section(
          title: 'Chat actions',
          footer: 'Register a custom in-chat action with a response timeout.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(children: [
                Field(
                  label: 'Action name',
                  controller: _chatAction,
                  textCapitalization: TextCapitalization.none,
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: AppButton(
                    title: 'Register',
                    variant: ButtonVariant.secondary,
                    onPressed: _registerAction,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    title: 'Unregister',
                    variant: ButtonVariant.secondary,
                    onPressed: _unregisterAction,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              AppButton(
                title: 'Unregister all',
                variant: ButtonVariant.ghost,
                onPressed: _unregisterAllActions,
              ),
              const SizedBox(height: 12),
              AppCard(children: [
                Field(
                  label: 'Action UUID',
                  controller: _actionUuid,
                  placeholder: 'UUID from a fired chat action',
                  textCapitalization: TextCapitalization.none,
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: AppButton(
                    title: 'Complete',
                    variant: ButtonVariant.secondary,
                    onPressed: () => _completeAction(withMessage: false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    title: 'Complete + message',
                    variant: ButtonVariant.secondary,
                    onPressed: () => _completeAction(withMessage: true),
                  ),
                ),
              ]),
            ],
          ),
        ),
        Section(
          title: 'Behavior & offline',
          footer: 'Waiting time, system messages, offline text and the '
              'conversation data provider.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(children: [
                SwitchRow(
                  title: 'Show offline message',
                  subtitle: 'showOfflineMessage',
                  value: _showOfflineMessage,
                  onChanged: (v) {
                    setState(() => _showOfflineMessage = v);
                    // Show an offline banner when all departments are offline.
                    ZohoSalesIQ.chat.showOfflineMessage(v);
                  },
                ),
              ]),
              const SizedBox(height: 12),
              AppButton(
                title: 'Apply behavior',
                variant: ButtonVariant.secondary,
                onPressed: _applyBehavior,
              ),
            ],
          ),
        ),
        Section(
          title: 'Conversation list & history',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(children: [
                SwitchRow(
                  title: 'Conversation history',
                  subtitle: 'conversation.setVisibility',
                  value: _conversationHistory,
                  onChanged: (v) {
                    setState(() => _conversationHistory = v);
                    // Show or hide past conversations (chat history) to the visitor.
                    ZohoSalesIQ.conversation.setVisibility(v);
                  },
                ),
                Field(
                    label: 'Conversation list title', controller: _listTitle),
              ]),
              const SizedBox(height: 12),
              AppButton(
                title: 'Apply list title',
                variant: ButtonVariant.secondary,
                onPressed: _applyListTitle,
              ),
            ],
          ),
        ),
        Section(
          title: 'Visible components',
          child: AppCard(
            children: [
              for (final entry in _chatComponents.entries)
                SwitchRow(
                  title: entry.value,
                  value: _componentState[entry.key] ?? false,
                  onChanged: (v) {
                    setState(() => _componentState[entry.key] = v);
                    _toggle(entry.key, v);
                  },
                ),
            ],
          ),
        ),
        AppButton(
          title: 'Orders demo (customChatId)',
          icon: AppIcon.chat,
          variant: ButtonVariant.ghost,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              settings: const RouteSettings(name: 'Orders'),
              builder: (_) => const OrdersShowcaseScreen(),
            ),
          ),
        ),
        if (_result != null) ResultBlock(label: 'Last result', data: _result),
      ],
    );
  }
}
