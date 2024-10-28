import 'dart:async';

import 'package:flutter/services.dart';
import 'package:salesiq_mobilisten/last_message.dart';
import 'package:salesiq_mobilisten/mobilisten_date_time.dart';
import 'package:salesiq_mobilisten/notification.dart';
import 'package:salesiq_mobilisten/salesiq_chat_module.dart';
import 'package:salesiq_mobilisten/salesiq_knowledge_base.dart';
import 'launcher.dart';
import 'tab.dart';
import 'siqtheme.dart';

class ZohoSalesIQ {
  // ignore_for_file: public_member_api_docs

  static MethodChannel _channel = const MethodChannel('salesiq_mobilisten');

  static Launcher launcher = new Launcher();
  static KnowledgeBase knowledgeBase = new KnowledgeBase();
  static Notification notification = new Notification();
  static Chat chat = new Chat();
  static const String _mobilistenEventChannel = "mobilistenEventChannel";
  static const String _mobilistenChatEventChannel =
      "mobilistenChatEventChannel";
  static const String _mobilistenArticleEventChannel =
      "mobilistenFAQEventChannel";

  /// Stream to receive general mobilisten events.
  static final eventChannel =
      EventChannel(_mobilistenEventChannel).receiveBroadcastStream();

  /// Stream to receive mobilisten events related to chat.
  static final chatEventChannel =
      EventChannel(_mobilistenChatEventChannel).receiveBroadcastStream();

  /// Stream to receive events related to the knowledge base.
  /// See [knowledgeBase.eventChannel] in [knowledgeBase]
  @Deprecated(
      'This EventChannel was deprecated after v3.1.2, Use eventChannel() in knowledgeBase instead.')
  static final articleEventChannel =
      EventChannel(_mobilistenArticleEventChannel).receiveBroadcastStream();

  /// Initializes Mobilisten using the [appKey] and [accessKey] generated for the bundle ID/package name of an application.
  static Future<Null> init(String appKey, String accessKey) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("appKey", () => appKey);
    args.putIfAbsent("accessKey", () => accessKey);
    await _channel.invokeMethod('init', args);
  }

  /// sets the custom font to be used inside the Mobilisten UI.
  static void setCustomFont(SalesIQFont font) async {
    print("onMethodCall --> setCustomFont" + font.toString());
    Map<String, dynamic> map = <String, dynamic>{};
    Map<String, dynamic> regular = <String, dynamic>{};
    regular.putIfAbsent("path", () => font.regular?.path);
    Map<String, dynamic> medium = <String, dynamic>{};
    medium.putIfAbsent("path", () => font.medium?.path);
    map.putIfAbsent("regular", () => regular);
    map.putIfAbsent("medium", () => medium);
    print("onMethodCall --> setCustomFont-out" + map.toString());
    await _channel.invokeMethod('setCustomFont', map);
  }

  static Future<bool> present([SIQTab? tab = null, String? id = null]) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("tab", () => tab?.toString());
    args.putIfAbsent("id", () => id);
    return await _channel
        .invokeMethod<bool>('present', args)
        .then((value) => value ?? false);
  }

  /// This API controls the behaviour of url opening behaviour
  static void shouldOpenUrl(bool openUrl) {
    _channel.invokeMethod('shouldOpenUrl', openUrl);
  }

  /// Controls the visibility of the default launcher using the value provided for [show].
  @Deprecated(
      'This method was deprecated after v4.0.0, Use launcher.show() method instead.')
  static Future<Null> showLauncher(bool show) async {
    await _channel.invokeMethod('showLauncher', show);
  }

  /// Sets the language used by Mobilisten using the language code provided in [language].
  static Future<Null> setLanguage(String language) async {
    await _channel.invokeMethod('setLanguage', language);
  }

  /// Sets the department to which all chat requests are routed by default.
  static Future<Null> setDepartment(String department) async {
    await _channel.invokeMethod('setDepartment', department);
  }

  /// Sets the list of departments to which chat requests may be routed.
  static Future<Null> setDepartments(List<String> departmentList) async {
    await _channel.invokeMethod('setDepartments', departmentList);
  }

  /// Prefills the text provided as [question] in the chat input field for a new chat window.
  static Future<Null> setQuestion(String question) async {
    await _channel.invokeMethod('setQuestion', question);
  }

  /// Automatically attempts to starts a chat using the text provided in [question] as the question.
  @Deprecated(
      'This method was deprecated after v6.1.0, Use chat.start() method instead.')
  static Future<Null> startChat(String question) async {
    await _channel.invokeMethod('startChat', question);
  }

  /// Enables or disables conversation history using the value provided for [visibility].
  static Future<Null> setConversationVisibility(bool visibility) async {
    await _channel.invokeMethod('setConversationVisibility', visibility);
  }

  /// Sets the title for the conversations list.
  static Future<Null> setConversationListTitle(String title) async {
    await _channel.invokeMethod('setConversationListTitle', title);
  }

  /// Enables or disables the FAQs/the Knowledge base using the value provided for [visibility].
  /// See [knowledgeBase.setVisibility(type, shouldShow)] in [knowledgeBase]
  @Deprecated(
      'This method was deprecated after v3.1.2, Use knowledgeBase.setVisibility() method instead.')
  static Future<Null> setFAQVisibility(bool visibility) async {
    await _channel.invokeMethod('setFAQVisibility', visibility);
  }

  /// Registers a visitor using the unique ID provided for [registerID].
  /// Once registered, conversations may be restored and synced across multiple devices that are registered with the same [registerID].
  /// Use the API during a `login` operation to set the user's session.
  static Future<dynamic> registerVisitor(String registerID) async {
    return await _channel.invokeMethod('registerVisitor', registerID);
  }

  /// Unregisters and clears conversations and data for the current user.
  /// Use the API during a `logout` operation to clear data.
  static Future<Null> unregisterVisitor() async {
    await _channel.invokeMethod('unregisterVisitor');
  }

  /// Sets the current page title to be shown in the visitor footpath on the SalesIQ console.
  static void setPageTitle(String pageTitle) async {
    await _channel.invokeMethod('setPageTitle', pageTitle);
  }

  /// Performs a custom action using the action name provided in [actionName].
  static Future<Null> performCustomAction(String actionName,
      [bool shouldOpenChatWindow = false]) async {
    Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent("action_name", () => actionName);
    arguments.putIfAbsent(
        "should_open_chat_window", () => shouldOpenChatWindow);
    await _channel.invokeMethod('performCustomAction', arguments);
  }

  /// Enables in-app notifications from Mobilisten if previously disabled.
  /// In-app notifications are `enabled` by default.
  static Future<Null> enableInAppNotification() async {
    await _channel.invokeMethod('enableInAppNotification');
  }

  /// Disables in-app notifications from Mobilisten.
  static Future<Null> disableInAppNotification() async {
    await _channel.invokeMethod('disableInAppNotification');
  }

  /// Sets the operator to whom all chat requests need to be routed using the provided [email].
  static Future<Null> setOperatorEmail(String email) async {
    await _channel.invokeMethod('setOperatorEmail', email);
  }

  /// Opens the Mobilisten UI. Invoke this API only after initialization is complete.
  static Future<Null> show() async {
    await _channel.invokeMethod('show');
  }

  /// Opens the chat window for a specified chat if provided the [chatID].
  static Future<Null> openChatWithID(String chatID) async {
    await _channel.invokeMethod('openChatWithID', chatID);
  }

  /// This method is used to refresh the launcher, it brings the launcher view to the front.
  void refreshLauncher() {
    _channel.invokeMethod('refreshLauncher');
  }

  /// Opens a new chat window for creating a new chat.
  static Future<Null> openNewChat() async {
    await _channel.invokeMethod('openNewChat');
  }

  /// Shows an offline banner if all departments are offline.
  /// This API is indended for use only when then chat waiting time is set to `Infinite`.
  static Future<Null> showOfflineMessage(bool show) async {
    await _channel.invokeMethod('showOfflineMessage', show);
  }

  /// Ends the specified chat if provided the [chatID].
  static Future<Null> endChat(String chatID) async {
    await _channel.invokeMethod('endChat', chatID);
  }

  /// Sets the visitor's name.
  static Future<Null> setVisitorName(String visitorName) async {
    await _channel.invokeMethod('setVisitorName', visitorName);
  }

  /// Sets the visitor's email.
  static Future<Null> setVisitorEmail(String visitorEmail) async {
    await _channel.invokeMethod('setVisitorEmail', visitorEmail);
  }

  /// Sets the visitor's contact number.
  static Future<Null> setVisitorContactNumber(String contactNumber) async {
    await _channel.invokeMethod('setVisitorContactNumber', contactNumber);
  }

  /// Sets the visitor's custom information as [key], [value] pairs.
  static Future<Null> setVisitorAddInfo(String key, String value) async {
    Map<String, dynamic> addInfo = <String, dynamic>{};
    addInfo.putIfAbsent("key", () => key);
    addInfo.putIfAbsent("value", () => value);
    await _channel.invokeMethod('setVisitorAddInfo', addInfo);
  }

  /// Sets the visitor's secondary location.
  static Future<Null> setVisitorLocation(
      SIQVisitorLocation locationDetails) async {
    Map<String, dynamic> location = <String, dynamic>{};
    location.putIfAbsent("latitude", () => locationDetails.latitude);
    location.putIfAbsent("longitude", () => locationDetails.longitude);
    location.putIfAbsent("city", () => locationDetails.city);
    location.putIfAbsent("state", () => locationDetails.state);
    location.putIfAbsent("country", () => locationDetails.country);
    location.putIfAbsent("countryCode", () => locationDetails.countryCode);
    location.putIfAbsent("zipCode", () => locationDetails.zipCode);
    await _channel.invokeMethod('setVisitorLocation', location);
  }

  /// Sets the title displayed in the chat window prior to starting a conversation.
  static Future<Null> setChatTitle(String chatTitle) async {
    await _channel.invokeMethod('setChatTitle', chatTitle);
  }

  /// Sets the overall theme color used in the iOS platform.
  static Future<Null> setThemeColorForiOS(String hexColor) async {
    await _channel.invokeMethod('setThemeColorForiOS', hexColor);
  }

  /// Sets the given theme in the Android platform.
  static Future<Null> setThemeForAndroid(String id) async {
    await _channel.invokeMethod('setThemeForAndroid', id);
  }

  /// Enables showing the operator's image in the default launcher.
  static Future<Null> showOperatorImageInLauncher(bool show) async {
    await _channel.invokeMethod('showOperatorImageInLauncher', show);
  }

  /// Enables or disables the display of sender images for incoming messages based on the value provided for [show].
  /// See [chat.setVisibility(chatComponent, visible)] in [chat]
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static Future<Null> showOperatorImageInChat(bool show) async {
    await _channel.invokeMethod('showOperatorImageInChat', show);
  }

  /// Enables or disables showing the visitor name _if available_ as the sender name for outgoing messages within chat.
  /// See [chat.setVisibility(chatComponent, visible)] in [chat]
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static Future<Null> setVisitorNameVisibility(bool visibility) async {
    await _channel.invokeMethod('setVisitorNameVisibility', visibility);
  }

  /// Enables or disables the option to provide feedback for a chat once ended.
  /// See [chat.setVisibility(chatComponent, visible)] in [chat]
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static Future<Null> setFeedbackVisibility(bool visibility) async {
    await _channel.invokeMethod('setFeedbackVisibility', visibility);
  }

  /// Enables or disables the option to provide rating for a chat once ended.
  /// See [chat.setVisibility(chatComponent, visible)] in [chat]
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static Future<Null> setRatingVisibility(bool visibility) async {
    await _channel.invokeMethod('setRatingVisibility', visibility);
  }

  static Future<Null> setThemeForiOS(SIQTheme theme) async {
    await _channel.invokeMethod('setThemeColor', theme.toMap());
  }

  /// Enables the option to capture screenshots from the attachments menu.
  /// See [chat.setVisibility(chatComponent, visible)] in [chat]
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static Future<Null> enableScreenshotOption() async {
    await _channel.invokeMethod('enableScreenshotOption');
  }

  /// Disables the option to capture screenshots fromm the attachments menu.
  /// See [chat.setVisibility(chatComponent, visible)] in [chat]
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static Future<Null> disableScreenshotOption() async {
    await _channel.invokeMethod('disableScreenshotOption');
  }

  /// Enables the pre-chat form if previously disables. Pre-chat forms are `enabled` by default.
  /// See [chat.setVisibility(chatComponent, visible)] in [chat]
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static Future<Null> enablePreChatForms() async {
    await _channel.invokeMethod('enablePreChatForms');
  }

  /// Disables the pre-chat form.
  /// See [chat.setVisibility(chatComponent, visible)] in [chat]
  @Deprecated(
      'This method was deprecated since v6.3.1, Use [chat.setVisibility] method instead.')
  static Future<Null> disablePreChatForms() async {
    await _channel.invokeMethod('disablePreChatForms');
  }

  /// Returns a list of chats (Instances of [SIQChat]).
  static Future<List<SIQChat>> getChats() async {
    final List? mapList = await _channel.invokeMethod<List>('getChats');
    return _getChatObjectList(mapList);
  }

  /// Returns a list of chats (Instances of [SIQChat]) whose status matches [chatStatus].
  static Future<List<SIQChat>> getChatsWithFilter(
      SIQChatStatus chatStatus) async {
    final List? mapList = await _channel.invokeMethod(
        'getChatsWithFilter', chatStatus.toShortString());
    return _getChatObjectList(mapList);
  }

  /// Returns a list of articles (Instances of [SIQArticle]).
  /// See [knowledgeBase.getResources(type)] in [knowledgeBase]
  @Deprecated(
      'This method was deprecated after v3.1.2, Use knowledgeBase.getResources() method instead.')
  static Future<List<SIQArticle>> getArticles() async {
    final List? articleList = await _channel.invokeMethod('getArticles');
    return _getArticleObjectList(articleList);
  }

  /// Returns a list of articles (Instances of [SIQArticle]) belonging to a specific category if provided a [categoryID].
  /// See [knowledgeBase.getResources(type)] in [knowledgeBase]
  @Deprecated(
      'This method was deprecated after v3.1.2, Use knowledgeBase.getResources() method instead.')
  static Future<List<SIQArticle>> getArticlesWithCategoryID(
      String categoryID) async {
    final List? articleList =
        await _channel.invokeMethod('getArticlesWithCategoryID', categoryID);
    return _getArticleObjectList(articleList);
  }

  /// Returns a list of article categories (Instances of [SIQArticleCategory]).
  /// See [knowledgeBase.getCategories(type)] in [knowledgeBase]
  @Deprecated(
      'This method was deprecated after v3.1.2, Use knowledgeBase.getCategories() method instead.')
  static Future<List<SIQArticleCategory>> getArticleCategories() async {
    final List? categoryList =
        await _channel.invokeMethod('getArticleCategories');
    return _getArticleCategoryObjectList(categoryList);
  }

  /// Returns a list of departments (Instances of [SIQDepartment]).
  static Future<List<SIQDepartment>> getDepartments() async {
    final List? deptList = await _channel.invokeMethod('getDepartments');
    return _getDepartmentObjectList(deptList);
  }

  /// Returns the base64 representation of an attender image for the given attender ID.
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

  /// Opens an article from the knowledge base using the [articleID].
  /// See [knowledgeBase.openResource(type, id)] in [knowledgeBase]
  @Deprecated(
      'This method was deprecated after v3.1.2, Use knowledgeBase.openResource() method instead.')
  static Future<String> openArticle(String articleID) async {
    final String articleList = await _channel
        .invokeMethod<String>('openArticle', articleID)
        .then((value) => value ?? "");
    return articleList;
  }

  /// Registers a chat action to be used in display-cards using an action name.
  static Future<Null> registerChatAction(String actionName) async {
    await _channel.invokeMethod('registerChatAction', actionName);
  }

  /// Unregisters a chat action to be used in display-cards using an action name.
  static Future<Null> unregisterChatAction(String actionName) async {
    await _channel.invokeMethod('unregisterChatAction', actionName);
  }

  /// Unregisters all registered chat action to be used in display-cards.
  static Future<Null> unregisterAllChatActions() async {
    await _channel.invokeMethod('unregisterAllChatActions');
  }

  /// Sets the timeout for all chat actions.
  static Future<Null> setChatActionTimeout(int timeout) async {
    await _channel.invokeMethod('setChatActionTimeout', timeout);
  }

  /// Marks a chat action as complete provided the [actionUUID].
  @Deprecated('This method was deprecated after v1.0.5,'
      'Use sendEvent(event, values) method instead.')
  static Future<Null> completeChatAction(String actionUUID) async {
    await _channel.invokeMethod('completeChatAction', actionUUID);
  }

  /// Enables push notifications for iOS using [token], [isTestDevice] and [productionMode].
  /// Set [isTestDevice] to `false` and [productionMode] to `true` before moving the app to production.
  static Future<Null> enablePushForiOS(
      String token, bool isTestDevice, bool productionMode) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("token", () => token);
    args.putIfAbsent("isTestDevice", () => isTestDevice);
    args.putIfAbsent("productionMode", () => productionMode);
    await _channel.invokeMethod('enablePushForiOS', args);
  }

  /// Processes the content of push notifications in response to a the tap action in iOS.
  /// Use this API only if push notification configuration is to be done manually in dart.
  static Future<Null> handleNotificationResponseForiOS(Map userInfo) async {
    await _channel.invokeMethod('handleNotificationResponseForiOS', userInfo);
  }

  /// Processes the content of push notification received for iOS.
  /// Use this API only if push notification configuration is to be done manually in dart.
  static Future<Null> processNotificationWithInfoForiOS(Map userInfo) async {
    await _channel.invokeMethod('processNotificationWithInfoForiOS', userInfo);
  }

  /// Marks a chat action as complete provided the [actionUUID], completion state and the message to be shown upon completion.
  @Deprecated('This method was deprecated after v1.0.5, '
      'Use sendEvent(event, values) method instead.')
  static Future<Null> completeChatActionWithMessage(
      String actionUUID, bool state, String message) async {
    Map<String, dynamic> chatActionDetails = <String, dynamic>{};
    chatActionDetails.putIfAbsent("actionUUID", () => actionUUID);
    chatActionDetails.putIfAbsent("state", () => state);
    chatActionDetails.putIfAbsent("message", () => message);
    await _channel.invokeMethod(
        'completeChatActionWithMessage', chatActionDetails);
  }

  /// A Boolean value used to determine whether a visitor can start multiple parallely open chats.
  static Future<bool> get isMultipleOpenChatRestricted async {
    return await _channel
        .invokeMethod<bool>('isMultipleOpenChatRestricted')
        .then((value) => value ?? false);
  }

  /// An integer value representing the number of unread messages.
  static Future<int> get chatUnreadCount async {
    return await _channel
        .invokeMethod<int>('getChatUnreadCount')
        .then((value) => value ?? 0);
  }

  static void dismissUI() {
    _channel.invokeMethod('dismissUI');
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

  @Deprecated('This method was deprecated after v3.1.2')
  static List<SIQArticle> _getArticleObjectList(List? mapList) {
    if (mapList == null) {
      return [];
    }
    List<SIQArticle> articleList = [];
    for (int i = 0; i < mapList.length; i++) {
      Map? map = mapList[i] as Map?;

      String? id = map?["id"]?.toString();
      String name = map?["name"]?.toString() ?? "-";
      String? categoryId = map?["categoryID"]?.toString();
      String categoryName = map?["categoryName"]?.toString() ?? "-";
      int viewCount = map?["viewCount"] as int? ?? 0;
      int likeCount = map?["likeCount"] as int? ?? 0;
      int dislikeCount = map?["dislikeCount"] as int? ?? 0;
      double? createdTimeMS = map?["createdTime"] as double?;
      double? modifiedTimeMS = map?["modifiedTime"] as double?;

      late DateTime? createdTime =
          DateTimeUtils.convertDoubleToDateTime(createdTimeMS);
      late DateTime? modifiedTime =
          DateTimeUtils.convertDoubleToDateTime(modifiedTimeMS) ?? createdTime;

      if (id != null && categoryId != null) {
        SIQArticle article = SIQArticle(id, name, categoryId, categoryName,
            viewCount, likeCount, dislikeCount, createdTime, modifiedTime);
        articleList.add(article);
      }
    }
    return articleList;
  }

  @Deprecated('This method was deprecated after v3.1.2')
  static List<SIQArticleCategory> _getArticleCategoryObjectList(List? mapList) {
    if (mapList == null) {
      return [];
    }
    List<SIQArticleCategory> categoryList = [];
    for (int i = 0; i < mapList.length; i++) {
      Map? map = mapList[i] as Map?;
      String? id = map?["id"]?.toString();
      String? name = map?["name"]?.toString();
      int articleCount = map?["articleCount"] as int? ?? 0;
      if (id != null && name != null) {
        SIQArticleCategory category =
            SIQArticleCategory(id, name, articleCount);
        categoryList.add(category);
      }
    }
    return categoryList;
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

  /// Sets the order for the bottom navigation tabs inside the SDK
  static void setTabOrder(List<SIQTab> tabs) {
    _channel.invokeMethod(
        'setTabOrder', tabs.map((tab) => tab.toString()).toList());
  }

  /// Use this API to send events to the SDK with [SIQSendEvent] and it's values
  /// with respect to the event
  static Future<Null> sendEvent(
      SIQSendEvent eventName, List<Object> values) async {
    Map<String, Object> map = <String, Object>{};
    map.putIfAbsent("eventName", () => eventName.toString());
    map.putIfAbsent("values", () => values);
    await _channel.invokeMethod('sendEvent', map);
  }

  /// Sets the properties for the launcher using [LauncherProperties].
  /// This API is used to customize launcher's mode, y position, sides and icon.
  ///
  /// Applies only for Android
  static void setLauncherPropertiesForAndroid(
      LauncherProperties launcherProperties) {
    Map<String, Object> map = <String, Object>{};
    map.putIfAbsent("mode", () => launcherProperties.mode.toString());
    if (launcherProperties.y != null) {
      map.putIfAbsent("y", () => launcherProperties.y!);
    }
    if (launcherProperties.horizontalDirection != null) {
      map.putIfAbsent("horizontal_direction",
          () => launcherProperties.horizontalDirection.toString());
    }
    if (launcherProperties.verticalDirection != null) {
      map.putIfAbsent("vertical_direction",
          () => launcherProperties.verticalDirection.toString());
    }
    if (launcherProperties.icon != null) {
      map.putIfAbsent("icon", () => launcherProperties.icon!);
    }
    _channel.invokeMethod('setLauncherPropertiesForAndroid', map);
  }

  /// This API sets the icon for the notifications created from SDK.
  ///
  /// Applies only for Android
  ///
  /// params: resourceName  - specifies the name of the resource
  ///                         in the drawable folder
  static void setNotificationIconForAndroid(String resourceName) {
    _channel.invokeMethod('setNotificationIconForAndroid', resourceName);
  }

  /// If this API is enabled, the SDK theme will work in sync with system's
  /// dark/light mode
  ///
  /// Applies only for Android
  static void syncThemeWithOSForAndroid(bool value) {
    _channel.invokeMethod('syncThemeWithOSForAndroid', value);
  }

  /// The android mobilisten debug logs will be printed only when true is set.
  static void printDebugLogsForAndroid(bool value) {
    _channel.invokeMethod('printDebugLogsForAndroid', value);
  }

  static void registerLocalizationFileForiOS(String value) {
    _channel.invokeMethod('registerLocalizationFileForiOS', value);
  }
}

class SIQChat {
  final String? id;
  final String? question;
  final int? queuePosition;

  final String? attenderName;
  final String? attenderEmail;
  final String? attenderID;
  final bool isBotAttender;

  final String? departmentName;
  final SIQChatStatus status;
  final int unreadCount;

  @Deprecated(
      'lastMessage was deprecated after v2.1.2, Use recentMessage.text instead.')
  final String? lastMessage;
  @Deprecated(
      'lastMessageTime was deprecated after v2.1.2, Use recentMessage.time instead.')
  final DateTime? lastMessageTime;
  @Deprecated(
      'lastMessageSender was deprecated after v2.1.2, Use recentMessage.sender instead.')
  final String? lastMessageSender;
  final SIQMessage? recentMessage;

  final String? feedback;
  final String? rating;

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

class SIQDepartment {
  final String id;
  final String name;
  final bool available;

  SIQDepartment(this.id, this.name, this.available);
}

/// See [Resource] class .
@Deprecated(
    'This class was deprecated after v3.1.2, Use [Resource] class instead.')
class SIQArticle {
  @Deprecated(
      'This reference was deprecated after v3.1.2, Use id from Resource class instead.')
  final String id;
  @Deprecated(
      'This reference was deprecated after v3.1.2, Use name from Resource class instead.')
  final String name;

  @Deprecated(
      'This reference was deprecated after v3.1.2, Use category from Resource class instead.')
  final String categoryId;
  @Deprecated(
      'This reference was deprecated after v3.1.2, Use category from Resource class instead.')
  final String categoryName;

  @Deprecated(
      'This reference was deprecated after v3.1.2, Use stats from Resource class instead.')
  final int viewCount;
  @Deprecated(
      'This reference was deprecated after v3.1.2, Use stats from Resource class instead.')
  final int likeCount;
  @Deprecated(
      'This reference was deprecated after v3.1.2, Use stats from Resource class instead.')
  final int dislikeCount;

  @Deprecated(
      'This reference was deprecated after v3.1.2, Use createdTime from Resource class instead.')
  final DateTime? createdTime;
  @Deprecated(
      'This reference was deprecated after v3.1.2, Use modifiedTime from Resource class instead.')
  final DateTime? modifiedTime;

  SIQArticle(
      this.id,
      this.name,
      this.categoryId,
      this.categoryName,
      this.viewCount,
      this.likeCount,
      this.dislikeCount,
      this.createdTime,
      this.modifiedTime);
}

/// See [ResourceCategory] class .
@Deprecated(
    'This class was deprecated after v3.1.2, Use Resource class instead.')
class SIQArticleCategory {
  @Deprecated(
      'This reference was deprecated after v3.1.2, Use id from ResourceCategory class instead.')
  final String id;
  @Deprecated(
      'This reference was deprecated after v3.1.2, Use name from ResourceCategory class instead.')
  final String name;
  @Deprecated(
      'This reference was deprecated after v3.1.2, Use count from ResourceCategory class instead.')
  final int articleCount;

  SIQArticleCategory(this.id, this.name, this.articleCount);
}

class SIQVisitorLocation {
  double? latitude;
  double? longitude;
  String? city;
  String? state;
  String? country;
  String? countryCode;
  String? zipCode;
}

class SIQEvent {
  static const String supportOpened = "supportOpened";
  static const String supportClosed = "supportClosed";
  static const String operatorsOnline = "operatorsOnline";
  static const String operatorsOffline = "operatorsOffline";
  static const String visitorIPBlocked = "visitorIPBlocked";
  static const String customTrigger = "customTrigger";
  static const String botTrigger = "botTrigger";
  static const String chatViewOpened = "chatViewOpened";
  static const String chatViewClosed = "chatViewClosed";
  static const String chatOpened = "chatOpened";
  static const String chatClosed = "chatClosed";
  static const String chatAttended = "chatAttended";
  static const String chatMissed = "chatMissed";
  static const String chatFeedbackReceived = "chatFeedbackReceived";
  static const String chatRatingReceived = "chatRatingReceived";
  static const String performChatAction = "performChatAction";
  static const String chatQueuePositionChange = "chatQueuePositionChange";
  static const String chatReopened = "chatReopened";

  /// See [KnowledgeBaseEvent.resourceLiked].
  @Deprecated(
      "This constant was deprecated after v3.1.2, Use KnowledgeBaseEvent.resourceLiked constant instead.")
  static const String articleLiked = "articleLiked";

  /// See [KnowledgeBaseEvent.resourceDisliked].
  @Deprecated(
      "This constant was deprecated after v3.1.2, Use KnowledgeBaseEvent.resourceDisliked constant instead.")
  static const String articleDisliked = "articleDisliked";

  /// See [KnowledgeBaseEvent.resourceOpened].
  @Deprecated(
      "This constant was deprecated after v3.1.2, Use KnowledgeBaseEvent.resourceOpened constant instead.")
  static const String articleOpened = "articleOpened";

  /// See [KnowledgeBaseEvent.resourceClosed].
  @Deprecated(
      "This constant was deprecated after v3.1.2, Use KnowledgeBaseEvent.resourceClosed constant instead.")
  static const String articleClosed = "articleClosed";
  static const String chatUnreadCountChanged = "chatUnreadCountChanged";
  static const String handleURL = "handleURL";
  static const String customLauncherVisibility = "customLauncherVisibility";
}

enum SIQChatStatus {
  open,
  connected,
  closed,
  ended,
  missed,
  waiting,
  triggered,
  proactive
}

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

  String toShortString() {
    var code = SIQChatStatusString._stringValues[this];
    if (code == null) {
      return "closed";
    }
    return code;
  }

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

enum ActionSource { app, sdk }

class SIQSendEvent {
  const SIQSendEvent._(this.index);

  final int index;

  static const SIQSendEvent openUrl = SIQSendEvent._(0);
  static const SIQSendEvent completeChatAction = SIQSendEvent._(1);

  static const List<SIQSendEvent> values = <SIQSendEvent>[
    openUrl,
    completeChatAction
  ];

  @override
  String toString() {
    return const <int, String>{
      0: 'OPEN_URL',
      1: 'COMPLETE_CHAT_ACTION'
    }[index]!;
  }
}

class SalesIQFont {
  SalesIQFontType? regular = null, medium = null;
}

class SalesIQFontType {
  String? path = null; //,name = null, file = null;

  SalesIQFontType(this.path); //, [this.name, this.file]);
}
