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

/// The main class for integrating Zoho SalesIQ Mobilisten SDK in Flutter application.
class ZohoSalesIQ {
  static final MethodChannel _channel =
      const MethodChannel('salesiq_mobilisten');

  /// Instance of [Launcher] to control the launcher view.
  static final Launcher launcher = Launcher();

  /// Instance of [KnowledgeBase] to control the knowledge base.
  static final KnowledgeBase knowledgeBase = KnowledgeBase();

  /// Instance of [SalesIQMobilistenNotification] to handle notifications.
  static final SalesIQMobilistenNotification notification =
      SalesIQMobilistenNotification();

  /// Instance of [Chat] to control the chat module.
  static final Chat chat = Chat();

  /// Instance of [Conversation] to control the chat module.
  static final Conversation conversation = Conversation();

  /// Instance of [Visitor] to manage the visitor's information.
  static final Visitor visitor = Visitor();

  /// Instance of [Homepage] to control the SalesIQ homepage.
  static final Homepage homepage = Homepage();

  /// Instance of [HelpCenter] to interact with the Help Center.
  static final HelpCenter helpCenter = HelpCenter();

  /// Instance of [Tracking] to track the visitor's footpath.
  static final Tracking tracking = Tracking();

  /// Instance of [ChatActions] to register and manage custom chat actions.
  static final ChatActions chatActions = ChatActions();

  static const String _mobilistenEventChannel = "mobilistenEventChannel";
  static const String _mobilistenChatEventChannel =
      "mobilistenChatEventChannel";

  /// Stream to receive general mobilisten events.
  static final eventChannel =
      EventChannel(_mobilistenEventChannel).receiveBroadcastStream();

  /// Stream to receive mobilisten events related to chat.
  static final chatEventChannel =
      EventChannel(_mobilistenChatEventChannel).receiveBroadcastStream();

  /// Initializes Mobilisten using the [appKey] and [accessKey] generated for the bundle ID/package name of an application.
  @Deprecated('Use ZohoSalesIQ.initialize(SalesIQConfiguration) instead.')
  static Future<void> init(String appKey, String accessKey) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("appKey", () => appKey);
    args.putIfAbsent("accessKey", () => accessKey);
    await _channel.invokeMethod('init', args);
  }

  /// Initializes Mobilisten using the [configuration] object
  /// ([SalesIQConfiguration]).
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

  /// Sets the custom [font] to be used inside the Mobilisten UI.
  ///
  /// Prefer supplying fonts through `SalesIQConfiguration.fonts` at
  /// [initialize] time; this method remains for runtime updates.
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

  /// Presents the Mobilisten UI.
  ///
  /// When [screen] is provided, opens that screen: use [SIQConversationScreen]
  /// to open a conversation or a conversation list and [SIQKnowledgeBaseScreen]
  /// to open knowledge base articles. When [screen] is omitted, opens the SDK's
  /// default UI.
  ///
  /// Set [showHomepage] to `false` to skip the homepage on back navigation.
  static Future<void> present(
      {SIQScreen? screen, bool showHomepage = true}) async {
    await _channel.invokeMethod('presentScreen', <String, dynamic>{
      'screen': screen?.toMap(),
      'showHomepage': showHomepage,
    });
  }

  /// Controls whether URLs shared in chat are opened by the SDK, based on the
  /// value provided for [openUrl].
  static void shouldOpenUrl(bool openUrl) {
    _channel.invokeMethod('shouldOpenUrl', openUrl);
  }

  /// Controls the visibility of the default launcher using the value provided for [show].
  @Deprecated(
      'This method was deprecated after v4.0.0, Use launcher.show() method instead.')
  static void showLauncher(bool show) {
    _channel.invokeMethod('showLauncher', show);
  }

  /// Sets the language used by Mobilisten using the language code provided in [language].
  static void setLanguage(String language) {
    _channel.invokeMethod('setLanguage', language);
  }

  /// Sets the department to which all chat requests are routed by default.
  static void setDepartment(String department) {
    _channel.invokeMethod('setDepartment', department);
  }

  /// Sets the list of departments to which chat requests may be routed.
  static void setDepartments(List<String> departmentList) {
    _channel.invokeMethod('setDepartments', departmentList);
  }

  /// Prefills the text provided as [question] in the chat input field for a new chat window.
  static void setQuestion(String question) {
    _channel.invokeMethod('setQuestion', question);
  }

  /// Automatically attempts to starts a chat using the text provided in [question] as the question.
  @Deprecated(
      'This method was deprecated after v6.1.0, Use chat.start() method instead.')
  static void startChat(String question) {
    _channel.invokeMethod('startChat', question);
  }

  /// Enables or disables conversation history using the value provided for
  /// [visibility].
  @Deprecated('Use ZohoSalesIQ.conversation.setVisibility() instead.')
  static void setConversationVisibility(bool visibility) {
    _channel.invokeMethod('setConversationVisibility', visibility);
  }

  /// Sets the title for the conversations list.
  static void setConversationListTitle(String title) {
    _channel.invokeMethod('setConversationListTitle', title);
  }

  /// Registers a visitor using the unique ID provided for [registerID].
  /// Once registered, conversations may be restored and synced across multiple
  /// devices that are registered with the same [registerID]. Use the API
  /// during a `login` operation to set the user's session. Set profile details
  /// via [visitor] `updateProfile`.
  static Future<dynamic> registerVisitor(String registerID) async {
    return await _channel.invokeMethod('registerVisitor', registerID);
  }

  /// Unregisters and clears conversations and data for the current user.
  /// Use the API during a `logout` operation to clear data.
  static Future<void> unregisterVisitor() async {
    await _channel.invokeMethod('unregisterVisitor');
  }

  /// Sets the current page title, [pageTitle], shown in the visitor footpath
  /// on the SalesIQ console.
  @Deprecated('Use ZohoSalesIQ.tracking.setPageTitle() instead.')
  static void setPageTitle(String pageTitle) async {
    await _channel.invokeMethod('setPageTitle', pageTitle);
  }

  /// Performs a custom action using the action name provided in [actionName].
  @Deprecated('Use ZohoSalesIQ.visitor.performCustomAction() instead.')
  static void performCustomAction(String actionName) {
    Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent("action_name", () => actionName);
    _channel.invokeMethod('performCustomAction', arguments);
  }

  /// Enables in-app notifications from Mobilisten if previously disabled.
  /// In-app notifications are `enabled` by default.
  @Deprecated(
      'Use ZohoSalesIQ.notification.enableInAppNotification(true) instead.')
  static void enableInAppNotification() {
    _channel.invokeMethod('enableInAppNotification', true);
  }

  /// Disables in-app notifications from Mobilisten.
  @Deprecated(
      'Use ZohoSalesIQ.notification.enableInAppNotification(false) instead.')
  static void disableInAppNotification() {
    _channel.invokeMethod('enableInAppNotification', false);
  }

  /// Sets the operator to whom all chat requests need to be routed using the
  /// provided [email].
  @Deprecated('Use ZohoSalesIQ.chat.setOperatorEmail() instead.')
  static void setOperatorEmail(String email) {
    _channel.invokeMethod('setOperatorEmail', email);
  }

  /// Opens the Mobilisten UI. Invoke this API only after initialization is complete.
  @Deprecated('Use ZohoSalesIQ.present() instead.')
  static void show() {
    _channel.invokeMethod('show');
  }

  /// This method is used to refresh the launcher, it brings the launcher view
  /// to the front.
  @Deprecated('Use ZohoSalesIQ.launcher.refreshLauncher() instead.')
  void refreshLauncher() {
    _channel.invokeMethod('refreshLauncher');
  }

  /// Shows an offline banner if all departments are offline, based on the
  /// value provided for [show].
  /// This API is intended for use only when the chat waiting time is set to
  /// `Infinite`.
  @Deprecated('Use ZohoSalesIQ.chat.showOfflineMessage() instead.')
  static void showOfflineMessage(bool show) {
    _channel.invokeMethod('showOfflineMessage', show);
  }

  /// Ends the specified chat if provided the [chatID].
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

  /// Sets the visitor's custom information as [key], [value] pairs.
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

  /// Sets the [chatTitle] displayed in the chat window prior to starting a
  /// conversation.
  @Deprecated('Use ZohoSalesIQ.chat.setTitle() instead.')
  static void setChatTitle(String chatTitle) {
    _channel.invokeMethod('setChatTitle', chatTitle);
  }

  /// Sets the overall theme color, [hexColor], used on the iOS platform.
  static void setThemeColorForiOS(String hexColor) {
    _channel.invokeMethod('setThemeColorForiOS', hexColor);
  }

  /// Sets the theme identified by the style resource [id] on the Android
  /// platform.
  static void setThemeForAndroid(String id) {
    _channel.invokeMethod('setThemeForAndroid', id);
  }

  /// Enables or disables showing the operator's image in the default
  /// launcher, based on the value provided for [show].
  @Deprecated('Use ZohoSalesIQ.launcher.showOperatorImage() instead.')
  static void showOperatorImageInLauncher(bool show) {
    _channel.invokeMethod('showOperatorImage', show);
  }

  /// Enables or disables the display of sender images for incoming messages based on the value provided for [show].
  /// See [chat.setVisibility(chatComponent, visible)] in [chat]
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static void showOperatorImageInChat(bool show) {
    _channel.invokeMethod('showOperatorImageInChat', show);
  }

  /// Enables or disables showing the visitor name _if available_ as the
  /// sender name for outgoing messages within chat, based on [visibility].
  /// See [chat.setVisibility(chatComponent, visible)] in [chat]
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static void setVisitorNameVisibility(bool visibility) {
    _channel.invokeMethod('setVisitorNameVisibility', visibility);
  }

  /// Enables or disables the option to provide feedback for a chat once
  /// ended, based on [visibility].
  /// See [chat.setVisibility(chatComponent, visible)] in [chat]
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static void setFeedbackVisibility(bool visibility) {
    _channel.invokeMethod('setFeedbackVisibility', visibility);
  }

  /// Enables or disables the option to provide a rating for a chat once
  /// ended, based on [visibility].
  /// See [chat.setVisibility(chatComponent, visible)] in [chat]
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static void setRatingVisibility(bool visibility) {
    _channel.invokeMethod('setRatingVisibility', visibility);
  }

  /// Sets the [theme] for iOS using the [SIQTheme] object.
  static void setThemeForiOS(SIQTheme theme) {
    _channel.invokeMethod('setThemeColor', theme.toMap());
  }

  /// Enables the option to capture screenshots from the attachments menu.
  /// See [chat.setVisibility(chatComponent, visible)] in [chat]
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static void enableScreenshotOption() {
    _channel.invokeMethod('enableScreenshotOption');
  }

  /// Disables the option to capture screenshots from the attachments menu.
  /// See [chat.setVisibility(chatComponent, visible)] in [chat]
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static void disableScreenshotOption() {
    _channel.invokeMethod('disableScreenshotOption');
  }

  /// Enables the pre-chat form if previously disables. Pre-chat forms are `enabled` by default.
  /// See [chat.setVisibility(chatComponent, visible)] in [chat]
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static void enablePreChatForms() {
    _channel.invokeMethod('enablePreChatForms');
  }

  /// Disables the pre-chat form.
  /// See [chat.setVisibility(chatComponent, visible)] in [chat]
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static void disablePreChatForms() {
    _channel.invokeMethod('disablePreChatForms');
  }

  /// Returns a list of chats (Instances of [SIQChat]).
  static Future<List<SIQChat>> getChats() async {
    final List? mapList = await _channel.invokeMethod<List>('getChats');
    return _getChatObjectList(mapList);
  }

  /// Returns a list of chats (Instances of [SIQChat]) whose status matches
  /// [chatStatus].
  static Future<List<SIQChat>> getChatsWithFilter(
      SIQChatStatus chatStatus) async {
    final List? mapList = await _channel.invokeMethod(
        'getChatsWithFilter', chatStatus.toShortString());
    return _getChatObjectList(mapList);
  }

  /// Returns a list of departments (Instances of [SIQDepartment]).
  @Deprecated('Use ZohoSalesIQ.conversation.getDepartments() instead.')
  static Future<List<SIQDepartment>> getDepartments() async {
    final List? deptList = await _channel.invokeMethod('getDepartments');
    return _getDepartmentObjectList(deptList);
  }

  /// Returns the base64 representation of the attender image for the given
  /// [attenderID]. Set [fetchDefaultImage] to `true` to fall back to the
  /// default image when the attender has no image of their own.
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

  /// Registers a chat action, identified by [actionName], for use in
  /// display cards.
  @Deprecated('Use ZohoSalesIQ.chatActions.register() instead.')
  static void registerChatAction(String actionName) {
    _channel.invokeMethod('registerChatAction', actionName);
  }

  /// Unregisters the chat action identified by [actionName].
  @Deprecated('Use ZohoSalesIQ.chatActions.unregister() instead.')
  static void unregisterChatAction(String actionName) {
    _channel.invokeMethod('unregisterChatAction', actionName);
  }

  /// Unregisters all registered chat actions.
  @Deprecated('Use ZohoSalesIQ.chatActions.unregisterAll() instead.')
  static void unregisterAllChatActions() {
    _channel.invokeMethod('unregisterAllChatActions');
  }

  /// Sets the [timeout], in seconds, applied to all chat actions.
  @Deprecated('Use ZohoSalesIQ.chatActions.setTimeout() instead.')
  static void setChatActionTimeout(int timeout) {
    _channel.invokeMethod('setChatActionTimeout', timeout);
  }

  /// Marks a chat action as complete provided the [actionUUID].
  @Deprecated('This method was deprecated after v1.0.5,'
      'Use sendEvent(event, values) method instead.')
  static void completeChatAction(String actionUUID) {
    _channel.invokeMethod('completeChatAction', actionUUID);
  }

  /// Enables push notifications for iOS using [token], [isTestDevice] and [productionMode].
  /// Set [isTestDevice] to `false` and [productionMode] to `true` before moving the app to production.
  static Future<void> enablePushForiOS(
      String token, bool isTestDevice, bool productionMode) {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("token", () => token);
    args.putIfAbsent("isTestDevice", () => isTestDevice);
    args.putIfAbsent("productionMode", () => productionMode);
    return _channel.invokeMethod('enablePushForiOS', args);
  }

  /// Processes the push notification [userInfo] in response to a tap action
  /// on iOS.
  /// Use this API only if push notification configuration is done manually
  /// in dart.
  static Future<void> handleNotificationResponseForiOS(Map userInfo) {
    return _channel.invokeMethod('handleNotificationResponseForiOS', userInfo);
  }

  /// Processes the content of the push notification [userInfo] received on
  /// iOS.
  /// Use this API only if push notification configuration is done manually
  /// in dart.
  static Future<void> processNotificationWithInfoForiOS(Map userInfo) {
    return _channel.invokeMethod('processNotificationWithInfoForiOS', userInfo);
  }

  /// Marks the chat action identified by [actionUUID] as complete, using the
  /// completion [state] and the [message] shown upon completion.
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

  /// A Boolean value used to determine whether a visitor can start multiple
  /// parallel open chats.
  @Deprecated('Use ZohoSalesIQ.chat.isMultipleOpenChatRestricted instead.')
  static Future<bool> get isMultipleOpenChatRestricted async {
    return await _channel
        .invokeMethod<bool>('isMultipleOpenChatRestricted')
        .then((value) => value ?? false);
  }

  /// An integer value representing the number of unread messages.
  @Deprecated('Use ZohoSalesIQ.chat.unreadCount instead.')
  static Future<int> get chatUnreadCount async {
    return await _channel
        .invokeMethod<int>('getChatUnreadCount')
        .then((value) => value ?? 0);
  }

  /// Dismisses the Mobilisten UI if it is currently presented.
  /// This method is used to close the Mobilisten UI.
  static void dismissUI() {
    _channel.invokeMethod('dismissUI');
  }

  /// Sets a custom session ID, [sessionID], for the current session.
  static void setSessionID(String sessionID) {
    _channel.invokeMethod('setSessionID', sessionID);
  }

  /// Sets the [source] from which the SDK theme is applied.
  ///
  /// Applies only for Android; the iOS native SDK does not expose a
  /// theme source API and this call is a no-op on iOS.
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

  /// Sends an event, [eventName] (a [SIQSendEvent]), to the SDK along with its
  /// associated [values].
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

  /// Sets the launcher properties using [launcherProperties].
  /// This API is used to customize the launcher's mode, position, sides and
  /// icon.
  ///
  /// Applies only for Android
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

  /// Syncs the SDK theme with the system's dark/light mode when [value] is
  /// `true`.
  ///
  /// Applies only for Android
  static void syncThemeWithOSForAndroid(bool value) {
    _channel.invokeMethod('syncThemeWithOSForAndroid', value);
  }

  /// Registers the localization file identified by [value] for iOS.
  static void registerLocalizationFileForiOS(String value) {
    _channel.invokeMethod('registerLocalizationFileForiOS', value);
  }

  /// Returns the current communication mode of the SDK.
  static Future<CommunicationMode?> getCommunicationMode() async {
    return await _channel
        .invokeMethod('getCommunicationMode')
        .then((onValue) => CommunicationMode.fromString(onValue));
  }

  /// Handles the push notification action identified by [actionIdentifier]
  /// for iOS, using the notification [userInfo] and any [responseText]
  /// entered by the user.
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

  /// Sets the URI scheme, [uriScheme], for Android.
  /// This is required to be set if you are using a custom URI scheme for your
  /// application.
  static void setAndroidUriScheme(SalesIQUriScheme uriScheme) {
    _channel.invokeMethod('setAndroidUriScheme', uriScheme.toMap());
  }

  /// Updates the configuration for SalesIQ SDK using the provided [key] and [value].
  /// See [SIQConfiguration] enum for available configuration keys.
  /// Applies for both iOS and Android
  /// Note: Some configurations may be platform specific.
  static void updateConfiguration(SIQConfiguration key, Object value) {
    Map<String, Object> args = <String, Object>{};
    args.putIfAbsent("key", () => key.name);
    args.putIfAbsent("value", () => value);
    _channel.invokeMethod('updateConfiguration', args);
  }

  /// Requests SDK to refresh provider-driven conversation data on demand.
  ///
  /// Applies currently for Android. On iOS, this is a no-op.
  static Future<Null> refreshData(
      SalesIQRefreshDataType type, String conversationId) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("type", () => type.name);
    args.putIfAbsent("conversationId", () => conversationId);
    await _channel.invokeMethod('refreshData', args);
  }
}

/// Data provider payload type to refresh for a specific conversation.
enum SalesIQRefreshDataType {
  /// Refresh secret fields provider data.
  secretFields,

  /// Refresh custom info provider data.
  displayFields
}

/// Configuration keys for SalesIQ SDK
/// See [updateConfiguration(key, value)] method.
/// Applies for both iOS and Android
/// Note: Some configurations may be platform specific.
enum SIQConfiguration {
  /// Disables neutral ratings in chat feedback.
  NeutralRatingDisabled,

  /// Enables tracking of storage space used by the SDK.[iOS]
  TrackStorageSpace,

  /// Enables tracking of app installation time.[iOS]
  TrackAppInstalledTime,

  /// Enables tracking of app update time.[iOS]
  TrackAppUpdatedTime,

  /// Shows 'End Session' option in in-app notifications.[iOS]
  ShowEndSessionInInAppNotification,

  /// Sets the orientation of carousel card properties in chatbot.
  ChatBotCarousalCardPropertiesOrientation,

  /// Sets the visibility of images in carousel cards in chatbot.
  ChatBotCarousalCardImageVisibility,

  /// Fallback to departments list on reopening the chat window when all departments are offline.
  ChatFallbackDepartmentsOnReopenIfOffline,

  /// To hide the alert for credit card masking consent in chat.
  HideCreditCardMaskingConsentAlert,

  /// To include visitor information in the conversation info section of the SalesIQ console.
  IncludeVisitorInfoInConversationInfo,

  /// Timeout for getSecretFields provider callback.
  SecretFieldsProviderTimeout,

  /// Timeout for getCustomInfo provider callback.
  DisplayFieldsProviderTimeout,

  /// Enables the homepage back stack when a chat is initiated through
  /// Mobilisten APIs. Maps to
  /// `SalesIQConfig.EnableHomePageBackStackForChatInitiation` on Android, and
  /// to the inverse of `dontNeedHomePageInStartFlow` on iOS.
  EnableHomePageBackStackForChatInitiation
}

/// A snapshot of a chat, returned by the chat listing APIs.
class SIQChat {
  /// Unique identifier of the chat.
  final String? id;

  /// The question the chat was started with, if any.
  final String? question;

  /// The visitor's position in the queue, if queued.
  final int? queuePosition;

  /// The name of the operator handling the chat, if assigned.
  final String? attenderName;

  /// The email of the operator handling the chat, if assigned.
  final String? attenderEmail;

  /// The unique id of the operator handling the chat, if assigned.
  final String? attenderID;

  /// Whether the current attender is a bot.
  final bool isBotAttender;

  /// The name of the department handling the chat, if any.
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

  /// The feedback left by the visitor, if any.
  final String? feedback;

  /// The rating left by the visitor, if any.
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

  /// Builds a [SIQChat] from the native [map], or `null` when [map] is
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

/// A department, as returned by the legacy department listing APIs.
class SIQDepartment {
  /// Unique identifier of the department.
  final String id;

  /// Display name of the department.
  final String name;

  /// Whether the department is currently available.
  final bool available;

  /// Creates a department with the given [id], [name] and [available] flag.
  SIQDepartment(this.id, this.name, this.available);
}

/// A secondary geographic location for a visitor.
class SIQVisitorLocation {
  /// The latitude in decimal degrees.
  double? latitude;

  /// The longitude in decimal degrees.
  double? longitude;

  /// The city name.
  String? city;

  /// The state/region name.
  String? state;

  /// The country name.
  String? country;

  /// The ISO country code.
  String? countryCode;

  /// The postal/zip code.
  String? zipCode;
}

/// Event name constants emitted on [ZohoSalesIQ.eventChannel] /
/// [ZohoSalesIQ.chatEventChannel].
class SIQEvent {
  /// The support (chat window) was opened.
  static const String supportOpened = "supportOpened";

  /// The support (chat window) was closed.
  static const String supportClosed = "supportClosed";

  /// One or more operators came online.
  static const String operatorsOnline = "operatorsOnline";

  /// All operators went offline.
  static const String operatorsOffline = "operatorsOffline";

  /// The visitor's IP was blocked.
  static const String visitorIPBlocked = "visitorIPBlocked";

  /// A custom trigger fired.
  static const String customTrigger = "customTrigger";

  /// A bot trigger fired.
  static const String botTrigger = "botTrigger";

  /// The chat view was opened.
  static const String chatViewOpened = "chatViewOpened";

  /// The chat view was closed.
  static const String chatViewClosed = "chatViewClosed";

  /// A chat was opened.
  static const String chatOpened = "chatOpened";

  /// A chat was closed.
  static const String chatClosed = "chatClosed";

  /// A chat was attended by an operator.
  static const String chatAttended = "chatAttended";

  /// A chat was missed.
  static const String chatMissed = "chatMissed";

  /// Feedback was received for a chat.
  static const String chatFeedbackReceived = "chatFeedbackReceived";

  /// A rating was received for a chat.
  static const String chatRatingReceived = "chatRatingReceived";

  /// A chat error occurred.
  static const String chatError = "chatError";

  /// A chat action was performed.
  static const String performChatAction = "performChatAction";

  /// The visitor's queue position changed.
  static const String chatQueuePositionChange = "chatQueuePositionChange";

  /// A chat was reopened.
  static const String chatReopened = "chatReopened";

  /// A chat expired.
  static const String chatExpired = "chatExpired";

  /// The unread chat message count changed.
  static const String chatUnreadCountChanged = "chatUnreadCountChanged";

  /// A URL should be handled by the app.
  static const String handleURL = "handleURL";

  /// The custom launcher visibility changed.
  static const String customLauncherVisibility = "customLauncherVisibility";

  /// Visitor registration (authentication) failed.
  static const String visitorRegistrationFailure = "visitorRegistrationFailure";

  /// The SDK requires the device to re-register for push notifications.
  ///
  /// Handle this by calling [ZohoSalesIQ.notification] `reRegisterPush`.
  /// Emitted on iOS only.
  static const String reRegisterPush = "reRegisterPush";
}

/// The status of a [SIQChat].
enum SIQChatStatus {
  /// The chat is open.
  open,

  /// The chat is connected to an operator.
  connected,

  /// The chat is closed.
  closed,

  /// The chat was ended.
  ended,

  /// The chat was missed.
  missed,

  /// The chat is waiting in the queue.
  waiting,

  /// The chat was started by a trigger.
  triggered,

  /// The chat was started proactively.
  proactive
}

/// Conversion helpers between [SIQChatStatus] and its native string value.
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

  /// Returns the [SIQChatStatus] matching the native [chatString], defaulting
  /// to [SIQChatStatus.closed] when unrecognized.
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

/// The source that triggered a notification action.
enum ActionSource {
  /// The action originated from the host app.
  app,

  /// The action originated from the SDK.
  sdk
}

/// Identifies an event type sent to the SDK via [ZohoSalesIQ.sendEvent].
class SIQSendEvent {
  const SIQSendEvent._(this.index);

  /// The ordinal index of the event.
  final int index;

  /// Instructs the SDK how to handle a URL open request.
  static const SIQSendEvent openUrl = SIQSendEvent._(0);

  /// Marks a chat action as complete.
  static const SIQSendEvent completeChatAction = SIQSendEvent._(1);

  /// Acknowledges a visitor registration (authentication) failure.
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

/// The source from which the SDK theme is applied.
/// See [ZohoSalesIQ.setThemeSource].
enum ThemeSource {
  /// Use the theme configured in the SalesIQ portal.
  portal,

  /// Use the theme configured locally through the SDK.
  sdk
}
