import 'dart:async';
import 'dart:collection';
import 'package:flutter/services.dart';

class ZohoSalesIQ {
  static MethodChannel _channel = const MethodChannel('mobilisten_plugin');

  static const String _mobilistenEventChannel = "mobilistenEventChannel";
  static const String _mobilistenChatEventChannel =
      "mobilistenChatEventChannel";
  static const String _mobilistenArticleEventChannel =
      "mobilistenFAQEventChannel";

  static final eventChannel =
      EventChannel(_mobilistenEventChannel).receiveBroadcastStream();
  static final chatEventChannel =
      EventChannel(_mobilistenChatEventChannel).receiveBroadcastStream();
  static final articleEventChannel =
      EventChannel(_mobilistenArticleEventChannel).receiveBroadcastStream();

  static Future<String> init(String appKey, String accessKey) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("appKey", () => appKey);
    args.putIfAbsent("accessKey", () => accessKey);
    final String success = await _channel.invokeMethod('init', args);
    return success;
  }

  static Future<Null> showLauncher(bool show) async {
    await _channel.invokeMethod('showLauncher', show);
  }

  static Future<Null> setLanguage(String language) async {
    await _channel.invokeMethod('setLanguage', language);
  }

  static Future<Null> setDepartment(String department) async {
    await _channel.invokeMethod('setDepartment', department);
  }

  static Future<Null> setDepartments(List<String> departmentList) async {
    await _channel.invokeMethod('setDepartments', departmentList);
  }

  static Future<Null> setQuestion(String question) async {
    await _channel.invokeMethod('setQuestion', question);
  }

  static Future<Null> startChat(String question) async {
    await _channel.invokeMethod('startChat', question);
  }

  static Future<Null> setConversationVisibility(bool visibility) async {
    await _channel.invokeMethod('setConversationVisibility', visibility);
  }

  static Future<Null> setConversationListTitle(String title) async {
    await _channel.invokeMethod('setConversationListTitle', title);
  }

  static Future<Null> setFAQVisibility(bool visibility) async {
    await _channel.invokeMethod('setFAQVisibility', visibility);
  }

  static Future<dynamic> registerVisitor(String registerID) async {
    return await _channel.invokeMethod('registerVisitor', registerID);
  }

  static Future<Null> unregisterVisitor() async {
    await _channel.invokeMethod('unregisterVisitor');
  }

  static Future<Null> setPageTitle(String pageTitle) async {
    await _channel.invokeMethod('setPageTitle', pageTitle);
  }

  static Future<Null> performCustomAction(String actionName) async {
    await _channel.invokeMethod('performCustomAction', actionName);
  }

  static Future<Null> enableInAppNotification() async {
    await _channel.invokeMethod('enableInAppNotification');
  }

  static Future<Null> disableInAppNotification() async {
    await _channel.invokeMethod('disableInAppNotification');
  }

  static Future<Null> setOperatorEmail(String email) async {
    await _channel.invokeMethod('setOperatorEmail', email);
  }

  static Future<Null> show() async {
    await _channel.invokeMethod('show');
  }

  static Future<Null> openChatWithID(String chatID) async {
    await _channel.invokeMethod('openChatWithID', chatID);
  }

  static Future<Null> openNewChat() async {
    await _channel.invokeMethod('openNewChat');
  }

  static Future<Null> showOfflineMessage(bool show) async {
    await _channel.invokeMethod('showOfflineMessage', show);
  }

  static Future<Null> endChat(String chatID) async {
    await _channel.invokeMethod('endChat', chatID);
  }

  static Future<Null> setVisitorName(String visitorName) async {
    await _channel.invokeMethod('setVisitorName', visitorName);
  }

  static Future<Null> setVisitorEmail(String visitorEmail) async {
    await _channel.invokeMethod('setVisitorEmail', visitorEmail);
  }

  static Future<Null> setVisitorContactNumber(String contactNumber) async {
    await _channel.invokeMethod('setVisitorContactNumber', contactNumber);
  }

  static Future<Null> setVisitorAddInfo(String key, String value) async {
    Map<String, dynamic> addInfo = <String, dynamic>{};
    addInfo.putIfAbsent("key", () => key);
    addInfo.putIfAbsent("value", () => value);
    await _channel.invokeMethod('setVisitorAddInfo', addInfo);
  }

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

  static Future<Null> setChatTitle(String chatTitle) async {
    await _channel.invokeMethod('setChatTitle', chatTitle);
  }

  static Future<Null> setThemeColorForiOS(String hexColor) async {
    await _channel.invokeMethod('setThemeColorForiOS', hexColor);
  }

  static Future<Null> showOperatorImageInLauncher(bool show) async {
    await _channel.invokeMethod('showOperatorImageInLauncher', show);
  }

  static Future<Null> showOperatorImageInChat(bool show) async {
    await _channel.invokeMethod('showOperatorImageInChat', show);
  }

  static Future<Null> setVisitorNameVisibility(bool visibility) async {
    await _channel.invokeMethod('setVisitorNameVisibility', visibility);
  }

  static Future<Null> setFeedbackVisibility(bool visibility) async {
    await _channel.invokeMethod('setFeedbackVisibility', visibility);
  }

  static Future<Null> setRatingVisibility(bool visibility) async {
    await _channel.invokeMethod('setRatingVisibility', visibility);
  }

  static Future<Null> enableScreenshotOption() async {
    await _channel.invokeMethod('enableScreenshotOption');
  }

  static Future<Null> disableScreenshotOption() async {
    await _channel.invokeMethod('disableScreenshotOption');
  }

  static Future<Null> enablePreChatForms() async {
    await _channel.invokeMethod('enablePreChatForms');
  }

  static Future<Null> disablePreChatForms() async {
    await _channel.invokeMethod('disablePreChatForms');
  }

  static Future<List<SIQChat>> getChats() async {
    final List mapList = await _channel.invokeMethod('getChats');
    return _getChatObjectList(mapList);
  }

  static Future<List<SIQChat>> getChatsWithFilter(SIQChatStatus filter) async {
    final List mapList = await _channel.invokeMethod(
        'getChatsWithFilter', filter.toShortString());
    return _getChatObjectList(mapList);
  }

  static Future<List<SIQArticle>> getArticles() async {
    final List articleList = await _channel.invokeMethod('getArticles');
    return _getArticleObjectList(articleList);
  }

  static Future<List<SIQArticle>> getArticlesWithCategoryID(
      String categoryID) async {
    final List articleList =
        await _channel.invokeMethod('getArticlesWithCategoryID', categoryID);
    return _getArticleObjectList(articleList);
  }

  static Future<List<SIQArticleCategory>> getArticleCategories() async {
    final List categoryList =
        await _channel.invokeMethod('getArticleCategories');
    return _getArticleCategoryObjectList(categoryList);
  }

  static Future<List<SIQDepartment>> getDepartments() async {
    final List deptList = await _channel.invokeMethod('getDepartments');
    return _getDepartmentObjectList(deptList);
  }

  static Future<String> fetchAttenderImage(
      String attenderID, bool fetchDefaultImage) async {
    Map<String, dynamic> details = <String, dynamic>{};
    details.putIfAbsent("attenderID", () => attenderID);
    details.putIfAbsent("fetchDefaultImage", () => fetchDefaultImage);
    final String image =
        await _channel.invokeMethod('fetchAttenderImage', details);
    return image;
  }

  static Future<String> openArticle(String articleID) async {
    final String articleList =
        await _channel.invokeMethod('openArticle', articleID);
    return articleList;
  }

  static Future<Null> registerChatAction(String actionName) async {
    await _channel.invokeMethod('registerChatAction', actionName);
  }

  static Future<Null> unregisterChatAction(String actionName) async {
    await _channel.invokeMethod('unregisterChatAction', actionName);
  }

  static Future<Null> unregisterAllChatActions() async {
    await _channel.invokeMethod('unregisterAllChatActions');
  }

  static Future<Null> setChatActionTimeout(int timeout) async {
    await _channel.invokeMethod('setChatActionTimeout', timeout);
  }

  static Future<Null> completeChatAction(String actionUUID) async {
    await _channel.invokeMethod('completeChatAction', actionUUID);
  }

  static Future<Null> enablePushForiOS(
      String token, bool isTestDevice, bool productionMode) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("token", () => token);
    args.putIfAbsent("isTestDevice", () => isTestDevice);
    args.putIfAbsent("productionMode", () => productionMode);
    await _channel.invokeMethod('enablePushForiOS', args);
  }

  static Future<Null> handleNotificationResponseForiOS(Map userInfo) async {
    await _channel.invokeMethod('handleNotificationResponseForiOS', userInfo);
  }

  static Future<Null> processNotificationWithInfoForiOS(Map userInfo) async {
    await _channel.invokeMethod('processNotificationWithInfoForiOS', userInfo);
  }

  static Future<Null> completeChatActionWithMessage(
      String actionUUID, bool state, String message) async {
    Map<String, dynamic> chatActionDetails = <String, dynamic>{};
    chatActionDetails.putIfAbsent("actionUUID", () => actionUUID);
    chatActionDetails.putIfAbsent("state", () => state);
    chatActionDetails.putIfAbsent("message", () => message);
    await _channel.invokeMethod(
        'completeChatActionWithMessage', chatActionDetails);
  }

  static Future<bool> get isMultipleOpenChatRestricted async {
    return await _channel.invokeMethod('isMultipleOpenChatRestricted');
  }

  static DateTime _convertDoubleToDateTime(double epochTime) {
    return DateTime.fromMillisecondsSinceEpoch(epochTime.toInt());
  }

  static List<SIQChat> _getChatObjectList(List mapList) {
    List<SIQChat> chatList = [];
    for (int i = 0; i < mapList.length; i++) {
      Map map = mapList[i];
      SIQChat chat = SIQChat();
      chat.id = map["id"];
      chat.question = map["question"];
      chat.isBotAttender = map["isBotAttender"];
      chat.attenderEmail = map["attenderEmail"];
      chat.attenderID = map["attenderID"];
      chat.attenderName = map["attenderName"];
      chat.departmentName = map["departmentName"];
      chat.unreadCount = map["unreadCount"];
      chat.lastMessage = map["lastMessage"];
      chat.lastMessageSender = map["lastMessageSender"];
      chat.queuePosition = map["queuePosition"];
      chat.feedback = map["feedback"];
      chat.rating = map["rating"];

      String status = map["status"] ?? "closed";
      chat.status = SIQChatStatusString.toChatType(status);

      double lastMessageTime = map["lastMessageTime"];
      if (lastMessageTime != null) {
        chat.lastMessageTime = _convertDoubleToDateTime(lastMessageTime);
      }

      chatList.add(chat);
    }
    return chatList;
  }

  static List<SIQArticle> _getArticleObjectList(List mapList) {
    List<SIQArticle> articleList = [];
    for (int i = 0; i < mapList.length; i++) {
      Map map = mapList[i];
      SIQArticle article = SIQArticle();
      article.id = map["id"];
      article.name = map["name"];
      article.categoryId = map["categoryID"];
      article.categoryName = map["categoryName"];
      article.viewCount = map["viewCount"];
      article.likeCount = map["likeCount"];
      article.dislikeCount = map["dislikeCount"];
      article.departmentID = map["departmentID"];
      double createdTime = map["createdTime"];
      double modifiedTime = map["modifiedTime"];
      if (createdTime != null) {
        article.createdTime = _convertDoubleToDateTime(createdTime);
      }
      if (modifiedTime != null) {
        article.modifiedTime = _convertDoubleToDateTime(modifiedTime);
      }
      articleList.add(article);
    }
    return articleList;
  }

  static List<SIQArticleCategory> _getArticleCategoryObjectList(List mapList) {
    List<SIQArticleCategory> categoryList = [];
    for (int i = 0; i < mapList.length; i++) {
      Map map = mapList[i];
      SIQArticleCategory category = SIQArticleCategory();
      category.id = map["id"];
      category.name = map["name"];
      category.articleCount = map["articleCount"];
      categoryList.add(category);
    }
    return categoryList;
  }

  static List<SIQDepartment> _getDepartmentObjectList(List mapList) {
    List<SIQDepartment> departmentList = [];
    for (int i = 0; i < mapList.length; i++) {
      Map map = mapList[i];
      SIQDepartment department = SIQDepartment();
      department.id = map["id"];
      department.name = map["name"];
      department.available = map["available"];
      departmentList.add(department);
    }
    return departmentList;
  }
}

class SIQChat {
  String id;
  String question;
  int queuePosition;

  String attenderName;
  String attenderEmail;
  String attenderID;
  bool isBotAttender;

  String departmentName;
  SIQChatStatus status;
  int unreadCount;

  String lastMessage;
  DateTime lastMessageTime;
  String lastMessageSender;

  String feedback;
  String rating;
}

class SIQDepartment {
  String id;
  String name;
  bool available;
}

class SIQArticle {
  String id;
  String name;

  String categoryId;
  String categoryName;

  int viewCount;
  int likeCount;
  int dislikeCount;

  String departmentID;
  DateTime createdTime;
  DateTime modifiedTime;
}

class SIQArticleCategory {
  String id;
  String name;
  int articleCount;
}

class SIQVisitorLocation {
  double latitude;
  double longitude;
  String city;
  String state;
  String country;
  String countryCode;
  String zipCode;
}

class SIQEvent {
  static const String supportOpened = "supportOpened";
  static const String supportClosed = "supportClosed";
  static const String operatorsOnline = "operatorsOnline";
  static const String operatorsOffline = "operatorsOffline";
  static const String visitorIPBlocked = "visitorIPBlocked";
  static const String customTrigger = "customTrigger";
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
  static const String articleLiked = "articleLiked";
  static const String articleDisliked = "articleDisliked";
  static const String articleOpened = "articleOpened";
  static const String articleClosed = "articleClosed";
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
