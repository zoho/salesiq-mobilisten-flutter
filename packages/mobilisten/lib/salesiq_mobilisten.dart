import 'dart:async';

import 'package:flutter/services.dart';
import 'package:salesiq_mobilisten/conversations/salesiq_conversations.dart';
import 'package:salesiq_mobilisten/notification.dart';
import 'package:salesiq_mobilisten/uri/salesiq_uri_scheme.dart';
import 'package:salesiq_mobilisten_core/salesiq_configuration.dart';
import 'package:salesiq_mobilisten_core/salesiq_core_enums.dart';
import 'package:salesiq_mobilisten_core/utils/salesiq_calls_helper.dart';

import 'package:salesiq_mobilisten_core/salesiq_font.dart';

import 'chat_actions.dart';
import 'last_message.dart';
import 'launcher.dart';
import 'mobilisten_date_time.dart';
import 'package:salesiq_mobilisten_core/salesiq_auth.dart';
import 'salesiq_chat_module.dart';
import 'tracking.dart';
import 'salesiq_help_center.dart';
import 'salesiq_homepage.dart';
import 'salesiq_knowledge_base.dart';
import 'salesiq_screen.dart';
import 'salesiq_visitor.dart';
import 'siqtheme.dart';

export 'package:salesiq_mobilisten/chat_actions.dart';
export 'package:salesiq_mobilisten/conversations/salesiq_conversations.dart';
export 'package:salesiq_mobilisten/launcher.dart';
export 'package:salesiq_mobilisten/logger.dart';
export 'package:salesiq_mobilisten/tracking.dart';
export 'package:salesiq_mobilisten/notification.dart';
export 'package:salesiq_mobilisten_core/salesiq_auth.dart';
export 'package:salesiq_mobilisten/salesiq_chat_module.dart';
export 'package:salesiq_mobilisten/salesiq_help_center.dart';
export 'package:salesiq_mobilisten/salesiq_homepage.dart';
export 'package:salesiq_mobilisten/salesiq_knowledge_base.dart';
export 'package:salesiq_mobilisten/salesiq_screen.dart';
export 'package:salesiq_mobilisten/salesiq_visitor.dart';
export 'package:salesiq_mobilisten/siqtheme.dart';
export 'package:salesiq_mobilisten/uri/salesiq_uri_scheme.dart';
export 'package:salesiq_mobilisten_core/salesiq_configuration.dart';
export 'package:salesiq_mobilisten_core/salesiq_conversation.dart';
export 'package:salesiq_mobilisten_core/salesiq_core_enums.dart';
export 'package:salesiq_mobilisten_core/salesiq_department.dart';
export 'package:salesiq_mobilisten_core/salesiq_font.dart';

/// Provides the main APIs of the Zoho SalesIQ Flutter SDK (Mobilisten). Use it
/// to initialize the SDK and to access each of its modules.
class ZohoSalesIQ {
  static final MethodChannel _channel =
      const MethodChannel('salesiq_mobilisten');

  /// The [Launcher] module, which controls the launcher view.
  static final Launcher launcher = Launcher();

  /// The [KnowledgeBase] module, which controls the Knowledge Base.
  static final KnowledgeBase knowledgeBase = KnowledgeBase();

  /// The [SalesIQMobilistenNotification] module, which handles notifications.
  static final SalesIQMobilistenNotification notification =
      SalesIQMobilistenNotification();

  /// The [Chat] module, which controls chat.
  static final Chat chat = Chat();

  /// The [Conversation] module, which controls conversations.
  static final Conversation conversation = Conversation();

  /// The [Visitor] module, which manages the visitor's information.
  static final Visitor visitor = Visitor();

  /// The [Homepage] module, which controls the SalesIQ homepage.
  static final Homepage homepage = Homepage();

  /// The [HelpCenter] module, which works with the Help Center.
  static final HelpCenter helpCenter = HelpCenter();

  /// The [Tracking] module, which tracks the visitor's footpath.
  static final Tracking tracking = Tracking();

  /// The [ChatActions] module, which registers and manages custom chat actions.
  static final ChatActions chatActions = ChatActions();

  static const String _mobilistenEventChannel = "mobilistenEventChannel";
  static const String _mobilistenChatEventChannel =
      "mobilistenChatEventChannel";

  /// The stream that receives the general events of the SDK.
  static final eventChannel =
      EventChannel(_mobilistenEventChannel).receiveBroadcastStream();

  /// The stream that receives the chat events of the SDK.
  static final chatEventChannel =
      EventChannel(_mobilistenChatEventChannel).receiveBroadcastStream();

  /// Initializes the SDK with the [appKey] and [accessKey] that are generated
  /// for the bundle ID or package name of your app.
  @Deprecated('Use ZohoSalesIQ.initialize(SalesIQConfiguration) instead.')
  static Future<void> init(String appKey, String accessKey) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("appKey", () => appKey);
    args.putIfAbsent("accessKey", () => accessKey);
    await _channel.invokeMethod('init', args);
  }

  /// Initializes the SDK with the given [configuration], which is a
  /// [SalesIQConfiguration] object.
  static Future<void> initialize(SalesIQConfiguration configuration) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("isNewInitializationFlow", () => true);
    args.putIfAbsent("appKey", () => configuration.appKey);
    args.putIfAbsent("accessKey", () => configuration.accessKey);
    if (configuration.androidCallViewMode != null) {
      SalesIQCallsHelper.currentAndroidCallViewMode =
          configuration.androidCallViewMode;
      args.putIfAbsent(
          "callViewMode", () => configuration.androidCallViewMode?.name);
    }
    if (configuration.fonts != null) {
      args.putIfAbsent(
          "fonts",
          () => <String, dynamic>{
                "regular": {"path": configuration.fonts?.regular?.path},
                "medium": {"path": configuration.fonts?.medium?.path},
              });
    }
    await _channel.invokeMethod('init', args);
  }

  /// Sets the custom [font] that the SDK uses in its UI.
  ///
  /// To set fonts when the SDK starts, pass them in
  /// `SalesIQConfiguration.fonts` when you call [initialize]. Use this method
  /// to change them at runtime.
  static void setCustomFont(SalesIQFont font) async {
    Map<String, dynamic> map = <String, dynamic>{};
    Map<String, dynamic> regular = <String, dynamic>{};
    regular.putIfAbsent("path", () => font.regular?.path);
    Map<String, dynamic> medium = <String, dynamic>{};
    medium.putIfAbsent("path", () => font.medium?.path);
    map.putIfAbsent("regular", () => regular);
    map.putIfAbsent("medium", () => medium);
    await _channel.invokeMethod('setCustomFont', map);
  }

  /// Opens the SDK's UI.
  ///
  /// To open a specific screen, pass [screen]. Use [SIQConversationScreen] to
  /// open a conversation or the conversation list. Use [SIQKnowledgeBaseScreen]
  /// to open Knowledge Base articles. If you leave out [screen], the SDK opens
  /// its default UI.
  ///
  /// To skip the homepage when the visitor navigates back, set [showHomepage]
  /// to `false`.
  static Future<void> present(
      {SIQScreen? screen, bool showHomepage = true}) async {
    await _channel.invokeMethod('presentScreen', <String, dynamic>{
      'screen': screen?.toMap(),
      'showHomepage': showHomepage,
    });
  }

  /// Controls whether the SDK opens the URLs that are shared in chat, based on
  /// the value of [openUrl].
  static void shouldOpenUrl(bool openUrl) {
    _channel.invokeMethod('shouldOpenUrl', openUrl);
  }

  /// Shows or hides the default launcher, based on the value of [show].
  @Deprecated(
      'This method was deprecated after v4.0.0, Use launcher.show() method instead.')
  static void showLauncher(bool show) {
    _channel.invokeMethod('showLauncher', show);
  }

  /// Sets the language of the SDK to the language code in [language].
  static void setLanguage(String language) {
    _channel.invokeMethod('setLanguage', language);
  }

  /// Sets the department that all chat requests are routed to by default.
  static void setDepartment(String department) {
    _channel.invokeMethod('setDepartment', department);
  }

  /// Sets the list of departments that chat requests can be routed to.
  static void setDepartments(List<String> departmentList) {
    _channel.invokeMethod('setDepartments', departmentList);
  }

  /// Fills the chat input field of a new chat window with the text in
  /// [question].
  static void setQuestion(String question) {
    _channel.invokeMethod('setQuestion', question);
  }

  /// Tries to start a chat automatically, with the text in [question] as the
  /// question.
  @Deprecated(
      'This method was deprecated after v6.1.0, Use chat.start() method instead.')
  static void startChat(String question) {
    _channel.invokeMethod('startChat', question);
  }

  /// Turns the conversation history on or off, based on the value of
  /// [visibility].
  @Deprecated('Use ZohoSalesIQ.conversation.setVisibility() instead.')
  static void setConversationVisibility(bool visibility) {
    _channel.invokeMethod('setConversationVisibility', visibility);
  }

  /// Sets the title of the conversation list.
  static void setConversationListTitle(String title) {
    _channel.invokeMethod('setConversationListTitle', title);
  }

  /// Registers a visitor with the unique ID in [registerID]. After
  /// registration, the visitor's conversations can be restored and synced
  /// across all devices that are registered with the same [registerID]. Call
  /// this method when the visitor logs in, to set their session. To set their
  /// profile details, call `updateProfile` on [visitor].
  static Future<dynamic> registerVisitor(String registerID) async {
    return await _channel.invokeMethod('registerVisitor', registerID);
  }

  /// Unregisters the current visitor and clears their conversations and data.
  /// Call this method when the visitor logs out, to clear their data.
  static Future<void> unregisterVisitor() async {
    await _channel.invokeMethod('unregisterVisitor');
  }

  /// Sets the title of the current page, [pageTitle], which appears in the
  /// visitor's footpath in the SalesIQ console.
  @Deprecated('Use ZohoSalesIQ.tracking.setPageTitle() instead.')
  static void setPageTitle(String pageTitle) async {
    await _channel.invokeMethod('setPageTitle', pageTitle);
  }

  /// Performs the custom action with the name in [actionName].
  @Deprecated('Use ZohoSalesIQ.visitor.performCustomAction() instead.')
  static void performCustomAction(String actionName) {
    Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent("action_name", () => actionName);
    _channel.invokeMethod('performCustomAction', arguments);
  }

  /// Turns in-app notifications from the SDK back on, if they were turned off.
  /// In-app notifications are `enabled` by default.
  @Deprecated(
      'Use ZohoSalesIQ.notification.enableInAppNotification(true) instead.')
  static void enableInAppNotification() {
    _channel.invokeMethod('enableInAppNotification', true);
  }

  /// Turns off in-app notifications from the SDK.
  @Deprecated(
      'Use ZohoSalesIQ.notification.enableInAppNotification(false) instead.')
  static void disableInAppNotification() {
    _channel.invokeMethod('enableInAppNotification', false);
  }

  /// Routes all chat requests to the operator with the given [email].
  @Deprecated('Use ZohoSalesIQ.chat.setOperatorEmail() instead.')
  static void setOperatorEmail(String email) {
    _channel.invokeMethod('setOperatorEmail', email);
  }

  /// Opens the SDK's UI. Call this method only after the SDK is initialized.
  @Deprecated('Use ZohoSalesIQ.present() instead.')
  static void show() {
    _channel.invokeMethod('show');
  }

  /// Refreshes the launcher and brings the launcher view to the front.
  @Deprecated('Use ZohoSalesIQ.launcher.refreshLauncher() instead.')
  void refreshLauncher() {
    _channel.invokeMethod('refreshLauncher');
  }

  /// Shows an offline banner when all departments are offline, based on the
  /// value of [show]. Use this method only when the chat waiting time is set to
  /// `Infinite`.
  @Deprecated('Use ZohoSalesIQ.chat.showOfflineMessage() instead.')
  static void showOfflineMessage(bool show) {
    _channel.invokeMethod('showOfflineMessage', show);
  }

  /// Ends the chat with the given [chatID].
  @Deprecated('Use ZohoSalesIQ.chat.end() instead.')
  static void endChat(String chatID) {
    _channel.invokeMethod('end', chatID);
  }

  /// Sets the visitor's name.
  @Deprecated(
      'This method is deprecated in v7.0.0, Use visitor.updateProfile() method instead.')
  static void setVisitorName(String visitorName) {
    _channel.invokeMethod('setVisitorName', visitorName);
  }

  /// Sets the visitor's email.
  @Deprecated(
      'This method is deprecated in v7.0.0, Use visitor.updateProfile() method instead.')
  static void setVisitorEmail(String visitorEmail) {
    _channel.invokeMethod('setVisitorEmail', visitorEmail);
  }

  /// Sets the visitor's contact number.
  @Deprecated(
      'This method is deprecated in v7.0.0, Use visitor.updateProfile() method instead.')
  static void setVisitorContactNumber(String contactNumber) {
    _channel.invokeMethod('setVisitorContactNumber', contactNumber);
  }

  /// Sets the visitor's custom information as [key] and [value] pairs.
  @Deprecated(
      'This method is deprecated in v7.0.0, Use visitor.updateProfile() method instead.')
  static void setVisitorAddInfo(String key, String value) {
    Map<String, dynamic> addInfo = <String, dynamic>{};
    addInfo.putIfAbsent("key", () => key);
    addInfo.putIfAbsent("value", () => value);
    _channel.invokeMethod('setVisitorAddInfo', addInfo);
  }

  /// Sets the visitor's secondary location.
  @Deprecated(
      'This method is deprecated in v7.0.0, Use visitor.updateProfile() method instead.')
  static void setVisitorLocation(SIQVisitorLocation locationDetails) {
    Map<String, dynamic> location = <String, dynamic>{};
    location.putIfAbsent("latitude", () => locationDetails.latitude);
    location.putIfAbsent("longitude", () => locationDetails.longitude);
    location.putIfAbsent("city", () => locationDetails.city);
    location.putIfAbsent("state", () => locationDetails.state);
    location.putIfAbsent("country", () => locationDetails.country);
    location.putIfAbsent("countryCode", () => locationDetails.countryCode);
    location.putIfAbsent("zipCode", () => locationDetails.zipCode);
    _channel.invokeMethod('setVisitorLocation', location);
  }

  /// Sets the [chatTitle] that appears in the chat window before a conversation
  /// starts.
  @Deprecated('Use ZohoSalesIQ.chat.setTitle() instead.')
  static void setChatTitle(String chatTitle) {
    _channel.invokeMethod('setChatTitle', chatTitle);
  }

  /// Sets the overall theme color of the SDK on iOS to [hexColor].
  static void setThemeColorForiOS(String hexColor) {
    _channel.invokeMethod('setThemeColorForiOS', hexColor);
  }

  /// Sets the theme on Android to the style resource with the given [id].
  static void setThemeForAndroid(String id) {
    _channel.invokeMethod('setThemeForAndroid', id);
  }

  /// Shows or hides the operator's image in the default launcher, based on the
  /// value of [show].
  @Deprecated('Use ZohoSalesIQ.launcher.showOperatorImage() instead.')
  static void showOperatorImageInLauncher(bool show) {
    _channel.invokeMethod('showOperatorImage', show);
  }

  /// Shows or hides the sender images of incoming messages, based on the value
  /// of [show].
  /// See [chat.setVisibility(chatComponent, visible)] in [chat].
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static void showOperatorImageInChat(bool show) {
    _channel.invokeMethod('showOperatorImageInChat', show);
  }

  /// Shows or hides the visitor's name as the sender name of outgoing messages
  /// in chat, based on [visibility]. The name appears only if it is available.
  /// See [chat.setVisibility(chatComponent, visible)] in [chat].
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static void setVisitorNameVisibility(bool visibility) {
    _channel.invokeMethod('setVisitorNameVisibility', visibility);
  }

  /// Turns the option to give feedback for a chat after it ends on or off,
  /// based on [visibility].
  /// See [chat.setVisibility(chatComponent, visible)] in [chat].
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static void setFeedbackVisibility(bool visibility) {
    _channel.invokeMethod('setFeedbackVisibility', visibility);
  }

  /// Turns the option to rate a chat after it ends on or off, based on
  /// [visibility].
  /// See [chat.setVisibility(chatComponent, visible)] in [chat].
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static void setRatingVisibility(bool visibility) {
    _channel.invokeMethod('setRatingVisibility', visibility);
  }

  /// Sets the [theme] for iOS with an [SIQTheme] object.
  static void setThemeForiOS(SIQTheme theme) {
    _channel.invokeMethod('setThemeColor', theme.toMap());
  }

  /// Turns on the option to capture screenshots from the attachments menu.
  /// See [chat.setVisibility(chatComponent, visible)] in [chat].
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static void enableScreenshotOption() {
    _channel.invokeMethod('enableScreenshotOption');
  }

  /// Turns off the option to capture screenshots from the attachments menu.
  /// See [chat.setVisibility(chatComponent, visible)] in [chat].
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static void disableScreenshotOption() {
    _channel.invokeMethod('disableScreenshotOption');
  }

  /// Turns the pre-chat form back on, if it was turned off. Pre-chat forms are
  /// `enabled` by default.
  /// See [chat.setVisibility(chatComponent, visible)] in [chat].
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static void enablePreChatForms() {
    _channel.invokeMethod('enablePreChatForms');
  }

  /// Turns off the pre-chat form.
  /// See [chat.setVisibility(chatComponent, visible)] in [chat].
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static void disablePreChatForms() {
    _channel.invokeMethod('disablePreChatForms');
  }

  /// Returns the visitor's chats, as [SIQChat] instances.
  static Future<List<SIQChat>> getChats() async {
    final List? mapList = await _channel.invokeMethod<List>('getChats');
    return _getChatObjectList(mapList);
  }

  /// Returns the visitor's chats whose status matches [chatStatus], as
  /// [SIQChat] instances.
  static Future<List<SIQChat>> getChatsWithFilter(
      SIQChatStatus chatStatus) async {
    final List? mapList = await _channel.invokeMethod(
        'getChatsWithFilter', chatStatus.toShortString());
    return _getChatObjectList(mapList);
  }

  /// Returns the departments, as [SIQDepartment] instances.
  @Deprecated('Use ZohoSalesIQ.conversation.getDepartments() instead.')
  static Future<List<SIQDepartment>> getDepartments() async {
    final List? deptList = await _channel.invokeMethod('getDepartments');
    return _getDepartmentObjectList(deptList);
  }

  /// Returns the image of the attender with the given [attenderID], as a base64
  /// string. To use the default image when the attender has no image of their
  /// own, set [fetchDefaultImage] to `true`.
  @Deprecated('Use ZohoSalesIQ.chat.fetchAttenderImage() instead.')
  static Future<String> fetchAttenderImage(
      String attenderID, bool fetchDefaultImage) async {
    Map<String, dynamic> details = <String, dynamic>{};
    details.putIfAbsent("attenderID", () => attenderID);
    details.putIfAbsent("fetchDefaultImage", () => fetchDefaultImage);
    final String image = await _channel
        .invokeMethod<String>('fetchAttenderImage', details)
        .then((value) => value ?? "");
    return image;
  }

  /// Registers the chat action named [actionName], for use in cards. The
  /// visitor triggers the action by tapping it on an operator or bot card.
  @Deprecated('Use ZohoSalesIQ.chatActions.register() instead.')
  static void registerChatAction(String actionName) {
    _channel.invokeMethod('registerChatAction', actionName);
  }

  /// Unregisters the chat action named [actionName].
  @Deprecated('Use ZohoSalesIQ.chatActions.unregister() instead.')
  static void unregisterChatAction(String actionName) {
    _channel.invokeMethod('unregisterChatAction', actionName);
  }

  /// Unregisters all the registered chat actions.
  @Deprecated('Use ZohoSalesIQ.chatActions.unregisterAll() instead.')
  static void unregisterAllChatActions() {
    _channel.invokeMethod('unregisterAllChatActions');
  }

  /// Sets the [timeout], in seconds, for all chat actions.
  @Deprecated('Use ZohoSalesIQ.chatActions.setTimeout() instead.')
  static void setChatActionTimeout(int timeout) {
    _channel.invokeMethod('setChatActionTimeout', timeout);
  }

  /// Marks the chat action with the given [actionUUID] as complete.
  @Deprecated('This method was deprecated after v1.0.5,'
      'Use sendEvent(event, values) method instead.')
  static void completeChatAction(String actionUUID) {
    _channel.invokeMethod('completeChatAction', actionUUID);
  }

  /// Turns on push notifications for iOS with the given [token],
  /// [isTestDevice], and [productionMode]. Before you release the app to
  /// production, set [isTestDevice] to `false` and [productionMode] to `true`.
  static Future<void> enablePushForiOS(
      String token, bool isTestDevice, bool productionMode) {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("token", () => token);
    args.putIfAbsent("isTestDevice", () => isTestDevice);
    args.putIfAbsent("productionMode", () => productionMode);
    return _channel.invokeMethod('enablePushForiOS', args);
  }

  /// Processes the push notification [userInfo] when the visitor taps the
  /// notification on iOS. Use this method only when you set up push
  /// notifications manually in Dart.
  static Future<void> handleNotificationResponseForiOS(Map userInfo) {
    return _channel.invokeMethod('handleNotificationResponseForiOS', userInfo);
  }

  /// Processes the content of the push notification [userInfo] that the app
  /// receives on iOS. Use this method only when you set up push notifications
  /// manually in Dart.
  static Future<void> processNotificationWithInfoForiOS(Map userInfo) {
    return _channel.invokeMethod('processNotificationWithInfoForiOS', userInfo);
  }

  /// Marks the chat action with the given [actionUUID] as complete, with the
  /// completion [state] and the [message] to show when it completes.
  @Deprecated('This method was deprecated after v1.0.5, '
      'Use sendEvent(event, values) method instead.')
  static void completeChatActionWithMessage(
      String actionUUID, bool state, String message) {
    Map<String, dynamic> chatActionDetails = <String, dynamic>{};
    chatActionDetails.putIfAbsent("actionUUID", () => actionUUID);
    chatActionDetails.putIfAbsent("state", () => state);
    chatActionDetails.putIfAbsent("message", () => message);
    _channel.invokeMethod('completeChatActionWithMessage', chatActionDetails);
  }

  /// Returns whether the visitor is restricted from starting more than one open
  /// chat at the same time.
  @Deprecated('Use ZohoSalesIQ.chat.isMultipleOpenChatRestricted instead.')
  static Future<bool> get isMultipleOpenChatRestricted async {
    return await _channel
        .invokeMethod<bool>('isMultipleOpenChatRestricted')
        .then((value) => value ?? false);
  }

  /// Returns the number of unread messages.
  @Deprecated('Use ZohoSalesIQ.chat.unreadCount instead.')
  static Future<int> get chatUnreadCount async {
    return await _channel
        .invokeMethod<int>('getChatUnreadCount')
        .then((value) => value ?? 0);
  }

  /// Closes the SDK's UI, if it is open.
  static void dismissUI() {
    _channel.invokeMethod('dismissUI');
  }

  /// Sets [sessionID] as a custom ID for the current session.
  static void setSessionID(String sessionID) {
    _channel.invokeMethod('setSessionID', sessionID);
  }

  /// Sets the [source] of the theme that the SDK applies.
  ///
  /// This works only on Android. The iOS SDK has no theme source API, so this
  /// call has no effect on iOS.
  static void setThemeSource(ThemeSource source) {
    _channel.invokeMethod('setThemeSource', source.name);
  }

  static List<SIQChat> _getChatObjectList(List? mapList) {
    if (mapList == null) {
      return [];
    }
    List<SIQChat> chatList = [];
    for (int i = 0; i < mapList.length; i++) {
      SIQChat? chat = SIQChat.fromMap(mapList[i] as Map?);
      if (chat != null) {
        chatList.add(chat);
      }
    }
    return chatList;
  }

  static List<SIQDepartment> _getDepartmentObjectList(List? mapList) {
    if (mapList == null) {
      return [];
    }
    List<SIQDepartment> departmentList = [];
    for (int i = 0; i < mapList.length; i++) {
      Map? map = mapList[i] as Map?;
      String? id = map?["id"] as String?;
      String? name = map?["name"] as String?;
      bool available = map?["available"] as bool? ?? false;
      if ((id != null) && (name != null)) {
        SIQDepartment department = SIQDepartment(id, name, available);
        departmentList.add(department);
      }
    }
    return departmentList;
  }

  /// Sends the event [eventName], which is an [SIQSendEvent], to the SDK with
  /// its [values].
  static Future<void> sendEvent(
      final SIQSendEvent eventName, final List<Object> values) {
    Map<String, Object> map = <String, Object>{};
    map.putIfAbsent("eventName", () => eventName.toString());
    if (eventName == SIQSendEvent.visitorRegistrationFailure) {
      if (values.length == 1) {
        SalesIQAuth salesIQAuth = values[0] as SalesIQAuth;
        map.putIfAbsent("values", () => [salesIQAuth.toMap()]);
      }
    } else {
      map.putIfAbsent("values", () => values);
    }
    return _channel.invokeMethod('sendEvent', map);
  }

  /// Sets the launcher properties in [launcherProperties]. Use it to customize
  /// the mode, position, sides, and icons of the launcher.
  ///
  /// This works only on Android.
  static void setLauncherPropertiesForAndroid(
      LauncherProperties launcherProperties) {
    Map<String, Object> map = <String, Object>{};
    map.putIfAbsent("mode", () => launcherProperties.mode.toString());
    if (launcherProperties.yFromBottom != null) {
      map.putIfAbsent("yFromBottom", () => launcherProperties.yFromBottom!);
    }
    if (launcherProperties.horizontalDirection != null) {
      map.putIfAbsent("horizontal_direction",
          () => launcherProperties.horizontalDirection.toString());
    }
    if (launcherProperties.verticalDirection != null) {
      map.putIfAbsent("vertical_direction",
          () => launcherProperties.verticalDirection.toString());
    }
    if (launcherProperties.chatIcon != null) {
      map.putIfAbsent("chat_icon", () => launcherProperties.chatIcon!);
    }
    if (launcherProperties.callIcon != null) {
      map.putIfAbsent("call_icon", () => launcherProperties.callIcon!);
    }
    if (launcherProperties.createIcon != null) {
      map.putIfAbsent("create_icon", () => launcherProperties.createIcon!);
    }
    if (launcherProperties.closeIcon != null) {
      map.putIfAbsent("close_icon", () => launcherProperties.closeIcon!);
    }
    _channel.invokeMethod('setLauncherPropertiesForAndroid', map);
  }

  /// Makes the SDK theme follow the light or dark mode of the device when
  /// [value] is `true`.
  ///
  /// This works only on Android.
  static void syncThemeWithOSForAndroid(bool value) {
    _channel.invokeMethod('syncThemeWithOSForAndroid', value);
  }

  /// Registers the localization file that [value] identifies, for iOS.
  static void registerLocalizationFileForiOS(String value) {
    _channel.invokeMethod('registerLocalizationFileForiOS', value);
  }

  /// Returns the current communication mode of the SDK.
  static Future<CommunicationMode?> getCommunicationMode() async {
    return await _channel
        .invokeMethod('getCommunicationMode')
        .then((onValue) => CommunicationMode.fromString(onValue));
  }

  /// Handles the push notification action with the given [actionIdentifier] on
  /// iOS. It uses the notification [userInfo] and any [responseText] that the
  /// visitor entered.
  @Deprecated('This method is deprecated in v7.0.0, Use '
      'notification.handlePushNotificationAction() method instead.')
  static Future<void> handlePushNotificationAction(
      String actionIdentifier, Map userInfo, String responseText) {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("actionIdentifier", () => actionIdentifier);
    args.putIfAbsent("userInfo", () => userInfo);
    args.putIfAbsent("responseText", () => responseText);
    return _channel.invokeMethod('handlePushNotificationAction', args);
  }

  /// Sets the URI scheme for Android to [uriScheme]. If your app uses a custom
  /// URI scheme, you must set it.
  static void setAndroidUriScheme(SalesIQUriScheme uriScheme) {
    _channel.invokeMethod('setAndroidUriScheme', uriScheme.toMap());
  }

  /// Updates a configuration of the SDK with the given [key] and [value]. For
  /// the available keys, see the [SIQConfiguration] enum. This method works on
  /// both iOS and Android, but some configurations work on only one platform.
  static void updateConfiguration(SIQConfiguration key, Object value) {
    Map<String, Object> args = <String, Object>{};
    args.putIfAbsent("key", () => key.name);
    args.putIfAbsent("value", () => value);
    _channel.invokeMethod('updateConfiguration', args);
  }

  /// Asks the SDK to call your data provider again for one conversation, and to
  /// send the new secret fields or display fields, based on [type]. This works
  /// on both Android and iOS.
  static Future<Null> refreshData(
      SalesIQRefreshDataType type, String conversationId) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("type", () => type.name);
    args.putIfAbsent("conversationId", () => conversationId);
    await _channel.invokeMethod('refreshData', args);
  }
}

/// Defines which data provider data to refresh for a conversation.
enum SalesIQRefreshDataType {
  /// Refreshes the secret fields from the data provider.
  secretFields,

  /// Refreshes the display fields from the data provider.
  displayFields
}

/// Defines the configuration keys of the SDK. To use a key, call
/// [updateConfiguration(key, value)]. The keys work on both iOS and Android,
/// but some work on only one platform.
enum SIQConfiguration {
  /// Turns off neutral ratings in chat feedback.
  NeutralRatingDisabled,

  /// Turns on tracking of the storage space that the SDK uses. This works only
  /// on iOS.
  TrackStorageSpace,

  /// Turns on tracking of the time when the app was installed. This works only
  /// on iOS.
  TrackAppInstalledTime,

  /// Turns on tracking of the time when the app was updated. This works only on
  /// iOS.
  TrackAppUpdatedTime,

  /// Shows the **End Session** option in in-app notifications. This works only
  /// on iOS.
  ShowEndSessionInInAppNotification,

  /// Sets the orientation of the properties in the carousel cards of a bot.
  ChatBotCarousalCardPropertiesOrientation,

  /// Shows or hides the images in the carousel cards of a bot.
  ChatBotCarousalCardImageVisibility,

  /// Shows the list of departments when the visitor reopens the chat window and
  /// all departments are offline.
  ChatFallbackDepartmentsOnReopenIfOffline,

  /// Hides the consent alert for credit card masking in chat.
  HideCreditCardMaskingConsentAlert,

  /// Includes the visitor's information in the conversation info section of the
  /// SalesIQ console.
  IncludeVisitorInfoInConversationInfo,

  /// Sets how long the SDK waits for the getSecretFields provider callback.
  /// Android reads the value in milliseconds, with a default of 5000 ms. iOS
  /// reads it in seconds, with a default of 2 seconds.
  SecretFieldsProviderTimeout,

  /// Sets how long the SDK waits for the getDisplayFields provider callback.
  /// Android reads the value in milliseconds, with a default of 5000 ms. iOS
  /// reads it in seconds, with a default of 2 seconds.
  DisplayFieldsProviderTimeout,

  /// Turns on the homepage back stack when a chat starts through the SDK APIs.
  /// On Android, it matches
  /// `SalesIQConfig.EnableHomePageBackStackForChatInitiation`. On iOS, it
  /// matches the inverse of `dontNeedHomePageInStartFlow`.
  EnableHomePageBackStackForChatInitiation,

  /// Sets the delay, in milliseconds, before the SDK shows the connection
  /// banner, such as "Connecting…" or "Waiting for network…". If the connection
  /// comes back within this delay, the banner does not appear. Pass the delay
  /// in milliseconds as the value. The default is 3000. This works only on
  /// Android.
  ConnectionUIDelayDuration
}

/// A snapshot of a chat that the chat listing APIs return.
class SIQChat {
  /// The unique ID of the chat.
  final String? id;

  /// The question that the chat started with, if any.
  final String? question;

  /// The visitor's position in the queue, if the chat is in the queue.
  final int? queuePosition;

  /// The name of the operator who handles the chat, if one is assigned.
  final String? attenderName;

  /// The email address of the operator who handles the chat, if one is
  /// assigned.
  final String? attenderEmail;

  /// The unique ID of the operator who handles the chat, if one is assigned.
  final String? attenderID;

  /// Whether the current attender is a bot.
  final bool isBotAttender;

  /// The name of the department that handles the chat, if any.
  final String? departmentName;

  /// The current status of the chat.
  final SIQChatStatus status;

  /// The number of unread messages in the chat.
  final int unreadCount;

  /// The text of the last message.
  @Deprecated(
      'lastMessage was deprecated after v2.1.2, Use recentMessage.text instead.')
  final String? lastMessage;

  /// The time of the last message.
  @Deprecated(
      'lastMessageTime was deprecated after v2.1.2, Use recentMessage.time instead.')
  final DateTime? lastMessageTime;

  /// The sender of the last message.
  @Deprecated(
      'lastMessageSender was deprecated after v2.1.2, Use recentMessage.sender instead.')
  final String? lastMessageSender;

  /// The most recent message in the chat, if any.
  final SIQMessage? recentMessage;

  /// The feedback that the visitor gave, if any.
  final String? feedback;

  /// The rating that the visitor gave, if any.
  final String? rating;

  /// Creates a chat snapshot with the given attributes.
  SIQChat(
      this.id,
      this.question,
      this.queuePosition,
      this.attenderName,
      this.attenderEmail,
      this.attenderID,
      this.isBotAttender,
      this.departmentName,
      this.status,
      this.unreadCount,
      this.lastMessage,
      this.lastMessageTime,
      this.lastMessageSender,
      this.recentMessage,
      this.feedback,
      this.rating);

  /// Builds an [SIQChat] from the native [map]. Returns `null` when [map] is
  /// `null`.
  static SIQChat? fromMap(Map<dynamic, dynamic>? map) {
    if (map != null) {
      String? id = map["id"]?.toString();
      String? question = map["question"]?.toString();
      bool isBotAttender = map["isBotAttender"] as bool? ?? false;
      String? attenderEmail = map["attenderEmail"]?.toString();
      String? attenderID = map["attenderID"]?.toString();
      String? attenderName = map["attenderName"]?.toString();
      String? departmentName = map["departmentName"]?.toString();
      int unreadCount = map["unreadCount"] as int? ?? 0;
      String? lastMessage = map["lastMessage"]?.toString();
      String? lastMessageSender = map["lastMessageSender"]?.toString();
      DateTime? lastMessageTime;
      double? lastMessageTimeMS = map["lastMessageTime"] as double?;
      if (lastMessageTimeMS != null) {
        lastMessageTime =
            DateTimeUtils.convertDoubleToDateTime(lastMessageTimeMS);
      }
      SIQMessage? recentMessage =
          SIQMessage.getObject(map["recentMessage"] as Map<dynamic, dynamic>?);
      int? queuePosition = map["queuePosition"] as int?;
      String? rating = map["rating"]?.toString();
      String? feedback = map["feedback"]?.toString();

      String statusString = map["status"]?.toString() ?? "closed";
      SIQChatStatus status = SIQChatStatusString.toChatType(statusString);

      SIQChat chat = SIQChat(
          id,
          question,
          queuePosition,
          attenderName,
          attenderEmail,
          attenderID,
          isBotAttender,
          departmentName,
          status,
          unreadCount,
          lastMessage,
          lastMessageTime,
          lastMessageSender,
          recentMessage,
          feedback,
          rating);
      return chat;
    } else {
      return null;
    }
  }
}

/// A department that the legacy department listing APIs return.
class SIQDepartment {
  /// The unique ID of the department.
  final String id;

  /// The display name of the department.
  final String name;

  /// Whether the department is currently available.
  final bool available;

  /// Creates a department with the given [id], [name], and [available] flag.
  SIQDepartment(this.id, this.name, this.available);
}

/// A secondary geographic location of a visitor.
class SIQVisitorLocation {
  /// The latitude in decimal degrees.
  double? latitude;

  /// The longitude in decimal degrees.
  double? longitude;

  /// The name of the city.
  String? city;

  /// The name of the state or region.
  String? state;

  /// The name of the country.
  String? country;

  /// The ISO country code.
  String? countryCode;

  /// The postal code or ZIP code.
  String? zipCode;
}

/// Defines the names of the events that [ZohoSalesIQ.eventChannel] and
/// [ZohoSalesIQ.chatEventChannel] send.
class SIQEvent {
  /// Sent when the visitor opens the support screen, which is the chat window.
  static const String supportOpened = "supportOpened";

  /// Sent when the visitor closes the support screen, which is the chat window.
  static const String supportClosed = "supportClosed";

  /// Sent when one or more operators come online.
  static const String operatorsOnline = "operatorsOnline";

  /// Sent when all operators go offline.
  static const String operatorsOffline = "operatorsOffline";

  /// Sent when the visitor's IP address is blocked.
  static const String visitorIPBlocked = "visitorIPBlocked";

  /// Sent when a custom trigger fires.
  static const String customTrigger = "customTrigger";

  /// Sent when a bot trigger fires.
  static const String botTrigger = "botTrigger";

  /// Sent when the chat view opens.
  static const String chatViewOpened = "chatViewOpened";

  /// Sent when the chat view closes.
  static const String chatViewClosed = "chatViewClosed";

  /// Sent when a chat opens.
  static const String chatOpened = "chatOpened";

  /// Sent when a chat closes.
  static const String chatClosed = "chatClosed";

  /// Sent when an operator attends a chat.
  static const String chatAttended = "chatAttended";

  /// Sent when a chat is missed.
  static const String chatMissed = "chatMissed";

  /// Sent when the SDK receives feedback for a chat.
  static const String chatFeedbackReceived = "chatFeedbackReceived";

  /// Sent when the SDK receives a rating for a chat.
  static const String chatRatingReceived = "chatRatingReceived";

  /// Sent when a chat error occurs.
  static const String chatError = "chatError";

  /// Sent when the visitor performs a chat action by tapping it on an operator
  /// or bot card.
  static const String performChatAction = "performChatAction";

  /// Sent when the visitor's position in the queue changes.
  static const String chatQueuePositionChange = "chatQueuePositionChange";

  /// Sent when a chat is reopened.
  static const String chatReopened = "chatReopened";

  /// Sent when a chat expires.
  static const String chatExpired = "chatExpired";

  /// Sent when the number of unread chat messages changes.
  static const String chatUnreadCountChanged = "chatUnreadCountChanged";

  /// Sent when the app should handle a URL.
  static const String handleURL = "handleURL";

  /// Sent when the visibility of the custom launcher changes.
  static const String customLauncherVisibility = "customLauncherVisibility";

  /// Sent when visitor registration, or authentication, fails.
  static const String visitorRegistrationFailure = "visitorRegistrationFailure";

  /// Sent when the SDK needs the device to register for push notifications
  /// again.
  ///
  /// To handle it, call `reRegisterPush` on [ZohoSalesIQ.notification]. This
  /// event is sent on iOS only.
  static const String reRegisterPush = "reRegisterPush";
}

/// Defines the status of an [SIQChat].
enum SIQChatStatus {
  /// The chat is open.
  open,

  /// The chat is connected to an operator.
  connected,

  /// The chat is closed.
  closed,

  /// The chat has ended.
  ended,

  /// The chat was missed.
  missed,

  /// The chat is waiting in the queue.
  waiting,

  /// A trigger started the chat.
  triggered,

  /// The chat started proactively.
  proactive
}

/// Converts between [SIQChatStatus] and its native string value.
extension SIQChatStatusString on SIQChatStatus {
  static const Map<SIQChatStatus, String> _stringValues = const {
    SIQChatStatus.open: "open",
    SIQChatStatus.closed: "closed",
    SIQChatStatus.connected: "connected",
    SIQChatStatus.ended: "ended",
    SIQChatStatus.missed: "missed",
    SIQChatStatus.waiting: "waiting",
    SIQChatStatus.triggered: "triggered",
    SIQChatStatus.proactive: "proactive"
  };

  /// Returns the native string value for this status.
  String toShortString() {
    var code = SIQChatStatusString._stringValues[this];
    if (code == null) {
      return "closed";
    }
    return code;
  }

  /// Returns the [SIQChatStatus] that matches the native [chatString]. If the
  /// value is not recognized, it returns [SIQChatStatus.closed].
  static SIQChatStatus toChatType(String chatString) {
    var valueList = SIQChatStatus.values;
    for (var i = 0; i < valueList.length; i++) {
      var chatType = valueList[i];
      if (chatString == chatType.toShortString()) {
        return chatType;
      }
    }
    return SIQChatStatus.closed;
  }
}

/// Defines the source that triggered a notification action.
enum ActionSource {
  /// The action came from the host app.
  app,

  /// The action came from the SDK.
  sdk
}

/// Identifies a type of event that you send to the SDK with
/// [ZohoSalesIQ.sendEvent].
class SIQSendEvent {
  const SIQSendEvent._(this.index);

  /// The ordinal index of the event.
  final int index;

  /// Tells the SDK how to handle a request to open a URL.
  static const SIQSendEvent openUrl = SIQSendEvent._(0);

  /// Marks a chat action as complete.
  static const SIQSendEvent completeChatAction = SIQSendEvent._(1);

  /// Acknowledges a failed visitor registration, or authentication.
  static const SIQSendEvent visitorRegistrationFailure = SIQSendEvent._(2);

  /// All available [SIQSendEvent] values.
  static const List<SIQSendEvent> values = <SIQSendEvent>[
    openUrl,
    completeChatAction,
    visitorRegistrationFailure
  ];

  @override
  String toString() => const <int, String>{
        0: 'OPEN_URL',
        1: 'COMPLETE_CHAT_ACTION',
        2: 'VISITOR_REGISTRATION_FAILURE'
      }[index]!;
}

/// Defines where the SDK gets its theme. See [ZohoSalesIQ.setThemeSource].
enum ThemeSource {
  /// Uses the theme that is set in the SalesIQ portal.
  portal,

  /// Uses the theme that is set locally through the SDK.
  sdk
}
