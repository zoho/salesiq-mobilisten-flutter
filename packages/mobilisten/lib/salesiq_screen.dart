// ignore_for_file: public_member_api_docs

/// Screen types used with `ZohoSalesIQ.present` to open a specific
/// module of the Mobilisten UI, mirroring the native `PresentOptions.Screen`
/// (Android) and `ZSIQScreen` (iOS) types.
abstract class SIQScreen {
  /// Serializes this screen configuration to a map for the native bridge.
  Map<String, dynamic> toMap();
}

/// The type of real-time session to create or resume.
enum SIQSessionType { chat, call }

/// Filter applied to a conversation list.
enum SIQConversationListFilter { ongoing, ended, all }

/// The type of conversation list shown when navigating back from a
/// detail view (or when directly opening the list screen).
class SIQConversationList {
  final String _type;

  /// The filter applied to the list.
  final SIQConversationListFilter filter;

  const SIQConversationList._(this._type, this.filter);

  /// Show a filtered chat list.
  const SIQConversationList.chat(
      [SIQConversationListFilter filter = SIQConversationListFilter.all])
      : this._('chat', filter);

  /// Show a filtered call list.
  const SIQConversationList.call(
      [SIQConversationListFilter filter = SIQConversationListFilter.all])
      : this._('call', filter);

  /// Show a filtered list of all conversations (chats and calls).
  const SIQConversationList.all(
      [SIQConversationListFilter filter = SIQConversationListFilter.all])
      : this._('all', filter);

  /// Do not show a list screen; back navigation dismisses the SDK.
  const SIQConversationList.none()
      : this._('none', SIQConversationListFilter.all);

  /// Serializes this conversation-list configuration to a map for the native
  /// bridge.
  Map<String, dynamic> toMap() => {'type': _type, 'filter': filter.name};
}

/// Controls how a session is opened when no specific conversation ID
/// is provided.
class SIQSessionBehavior {
  final String _type;

  /// The type of session to create or resume.
  final SIQSessionType sessionType;

  const SIQSessionBehavior._(this._type, this.sessionType);

  /// No session is created or resumed.
  const SIQSessionBehavior.none() : this._('none', SIQSessionType.chat);

  /// Always creates a new session of the given [sessionType].
  const SIQSessionBehavior.alwaysNew(
      [SIQSessionType sessionType = SIQSessionType.chat])
      : this._('alwaysNew', sessionType);

  /// Resumes an ongoing session of the given [sessionType] if one exists;
  /// otherwise creates a new one.
  const SIQSessionBehavior.continueOrNew(
      [SIQSessionType sessionType = SIQSessionType.chat])
      : this._('continueOrNew', sessionType);

  /// Serializes this session-behavior configuration to a map for the native
  /// bridge.
  Map<String, dynamic> toMap() =>
      {'type': _type, 'sessionType': sessionType.name};
}

/// A screen within the Conversation module (chats and calls).
class SIQConversationScreen extends SIQScreen {
  /// The ID of the specific conversation to open, if any.
  final String? id;

  /// The type of the conversation identified by [id].
  final SIQSessionType? sessionType;

  /// The conversation list shown on back navigation.
  final SIQConversationList list;

  /// How a session is opened when no specific conversation [id] is given.
  final SIQSessionBehavior sessionBehavior;

  /// Opens the specific conversation identified by [id].
  ///
  /// [sessionType] must match the actual type of the conversation
  /// (chat or call). The given [list] is shown on back navigation.
  SIQConversationScreen.withId(String this.id,
      {SIQSessionType this.sessionType = SIQSessionType.chat,
      this.list = const SIQConversationList.all()})
      : sessionBehavior = const SIQSessionBehavior.none();

  /// Opens the given conversation [list], optionally starting or resuming
  /// a session based on [sessionBehavior].
  SIQConversationScreen.withList(
      {this.list = const SIQConversationList.all(),
      this.sessionBehavior = const SIQSessionBehavior.none()})
      : id = null,
        sessionType = null;

  /// Serializes this conversation screen to a map for the native bridge.
  @override
  Map<String, dynamic> toMap() => {
        'screenType': 'conversation',
        if (id != null) 'id': id,
        if (sessionType != null) 'sessionType': sessionType!.name,
        'list': list.toMap(),
        'sessionBehavior': sessionBehavior.toMap(),
      };
}

/// A screen within the Knowledge Base module.
class SIQKnowledgeBaseScreen extends SIQScreen {
  /// Optional ID of the article or FAQ to open directly.
  final String? id;

  final String _resourceType;

  /// Opens the articles screen, or a specific article when [id] is given.
  SIQKnowledgeBaseScreen.articles([this.id]) : _resourceType = 'articles';

  // FAQs / combined knowledge-base screens are pending the iOS native implementation.
  // Uncomment when the iOS SDK supports the FAQs resource type:
  // /// Opens the FAQs screen, or a specific FAQ when [id] is given.
  // SIQKnowledgeBaseScreen.faqs([this.id]) : _resourceType = 'faqs';
  //
  // /// Opens the combined articles and FAQs knowledge base.
  // SIQKnowledgeBaseScreen.both([this.id]) : _resourceType = 'both';

  /// Serializes this knowledge base screen to a map for the native bridge.
  @override
  Map<String, dynamic> toMap() => {
        'screenType': 'knowledgeBase',
        'resourceType': _resourceType,
        if (id != null) 'id': id,
      };
}
