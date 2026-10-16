// ignore_for_file: public_member_api_docs

/// Defines the screen types that you pass to `ZohoSalesIQ.present` to open a
/// specific module of the SDK's UI. They match the native
/// `PresentOptions.Screen` type on Android and the `ZSIQScreen` type on iOS.
abstract class SIQScreen {
  /// Converts this screen configuration to a map for the native bridge.
  Map<String, dynamic> toMap();
}

/// Defines the type of real-time session to create or resume.
enum SIQSessionType { chat, call }

/// Defines the filter for a conversation list.
enum SIQConversationListFilter { ongoing, ended, all }

/// The type of conversation list that appears when the visitor navigates back
/// from a detail view, or opens the list screen directly.
class SIQConversationList {
  final String _type;

  /// The filter for the list.
  final SIQConversationListFilter filter;

  const SIQConversationList._(this._type, this.filter);

  /// Shows a filtered chat list.
  const SIQConversationList.chat(
      [SIQConversationListFilter filter = SIQConversationListFilter.all])
      : this._('chat', filter);

  /// Shows a filtered call list.
  const SIQConversationList.call(
      [SIQConversationListFilter filter = SIQConversationListFilter.all])
      : this._('call', filter);

  /// Shows a filtered list of all conversations, both chats and calls.
  const SIQConversationList.all(
      [SIQConversationListFilter filter = SIQConversationListFilter.all])
      : this._('all', filter);

  /// Shows no list screen. Back navigation closes the SDK.
  const SIQConversationList.none()
      : this._('none', SIQConversationListFilter.all);

  /// Converts this conversation list configuration to a map for the native
  /// bridge.
  Map<String, dynamic> toMap() => {'type': _type, 'filter': filter.name};
}

/// Controls how a session opens when no specific conversation ID is given.
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

  /// Resumes an ongoing session of the given [sessionType] if one exists.
  /// Otherwise, it creates a new one.
  const SIQSessionBehavior.continueOrNew(
      [SIQSessionType sessionType = SIQSessionType.chat])
      : this._('continueOrNew', sessionType);

  /// Converts this session behavior configuration to a map for the native
  /// bridge.
  Map<String, dynamic> toMap() =>
      {'type': _type, 'sessionType': sessionType.name};
}

/// A screen in the Conversation module, which holds chats and calls.
class SIQConversationScreen extends SIQScreen {
  /// The ID of the specific conversation to open, if any.
  final String? id;

  /// The type of the conversation identified by [id].
  final SIQSessionType? sessionType;

  /// The conversation list that appears on back navigation.
  final SIQConversationList list;

  /// How a session opens when no specific conversation [id] is given.
  final SIQSessionBehavior sessionBehavior;

  /// Opens the specific conversation with the given [id].
  ///
  /// [sessionType] must match the actual type of the conversation, which is
  /// chat or call. The given [list] appears on back navigation.
  SIQConversationScreen.withId(String this.id,
      {SIQSessionType this.sessionType = SIQSessionType.chat,
      this.list = const SIQConversationList.all()})
      : sessionBehavior = const SIQSessionBehavior.none();

  /// Opens the given conversation [list]. It can also start or resume a
  /// session, based on [sessionBehavior].
  SIQConversationScreen.withList(
      {this.list = const SIQConversationList.all(),
      this.sessionBehavior = const SIQSessionBehavior.none()})
      : id = null,
        sessionType = null;

  /// Converts this conversation screen to a map for the native bridge.
  @override
  Map<String, dynamic> toMap() => {
        'screenType': 'conversation',
        if (id != null) 'id': id,
        if (sessionType != null) 'sessionType': sessionType!.name,
        'list': list.toMap(),
        'sessionBehavior': sessionBehavior.toMap(),
      };
}

/// A screen in the Knowledge Base module.
class SIQKnowledgeBaseScreen extends SIQScreen {
  /// The optional ID of the article or FAQ to open directly.
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

  /// Converts this Knowledge Base screen to a map for the native bridge.
  @override
  Map<String, dynamic> toMap() => {
        'screenType': 'knowledgeBase',
        'resourceType': _resourceType,
        if (id != null) 'id': id,
      };
}
