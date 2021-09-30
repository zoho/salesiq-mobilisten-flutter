import 'dart:async';
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

  static Future<Null> init(String appKey, String accessKey) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("appKey", () => appKey);
    args.putIfAbsent("accessKey", () => accessKey);
    await _channel.invokeMethod('init', args);
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
      String? id = map["id"];
      String? question = map["question"];
      bool isBotAttender = map["isBotAttender"] ?? false;
      String? attenderEmail = map["attenderEmail"];
      String? attenderID = map["attenderID"];
      String? attenderName = map["attenderName"];
      String? departmentName = map["departmentName"];
      int unreadCount = map["unreadCount"] ?? 0;
      String? lastMessage = map["lastMessage"];
      String? lastMessageSender = map["lastMessageSender"];
      DateTime? lastMessageTime;
      double? lastMessageTimeMS = map["lastMessageTime"];
      if (lastMessageTimeMS != null) {
        lastMessageTime = _convertDoubleToDateTime(lastMessageTimeMS);
      }
      int? queuePosition = map["queuePosition"];
      String? rating = map["rating"];
      String? feedback = map["feedback"];

      String statusString = map["status"] ?? "closed";
      SIQChatStatus status = SIQChatStatusString.toChatType(statusString);

      if (id != null) {
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
            feedback,
            rating);
        chatList.add(chat);
      }
    }
    return chatList;
  }

  static List<SIQArticle> _getArticleObjectList(List mapList) {
    List<SIQArticle> articleList = [];
    for (int i = 0; i < mapList.length; i++) {
      Map map = mapList[i];

      String? id = map["id"];
      String name = map["name"] ?? "-";
      String? categoryId = map["categoryID"];
      String categoryName = map["categoryName"] ?? "-";
      int viewCount = map["viewCount"] ?? 0;
      int likeCount = map["likeCount"] ?? 0;
      int dislikeCount = map["dislikeCount"] ?? 0;
      double? createdTimeMS = map["createdTime"];
      double? modifiedTimeMS = map["modifiedTime"];

      late DateTime createdTime;
      late DateTime modifiedTime;

      if (createdTimeMS != null) {
        createdTime = _convertDoubleToDateTime(createdTimeMS);
      } else {
        createdTime = DateTime.now();
      }

      if (modifiedTimeMS != null) {
        modifiedTime = _convertDoubleToDateTime(modifiedTimeMS);
      } else {
        modifiedTime = createdTime;
      }

      if (id != null && categoryId != null) {
        SIQArticle article = SIQArticle(id, name, categoryId, categoryName,
            viewCount, likeCount, dislikeCount, createdTime, modifiedTime);
        articleList.add(article);
      }
    }
    return articleList;
  }

  static List<SIQArticleCategory> _getArticleCategoryObjectList(List mapList) {
    List<SIQArticleCategory> categoryList = [];
    for (int i = 0; i < mapList.length; i++) {
      Map map = mapList[i];
      String? id = map["id"];
      String? name = map["name"];
      int articleCount = map["articleCount"] ?? 0;
      if (id != null && name != null) {
        SIQArticleCategory category =
            SIQArticleCategory(id, name, articleCount);
        categoryList.add(category);
      }
    }
    return categoryList;
  }

  static List<SIQDepartment> _getDepartmentObjectList(List mapList) {
    List<SIQDepartment> departmentList = [];
    for (int i = 0; i < mapList.length; i++) {
      Map map = mapList[i];
      String? id = map["id"];
      String? name = map["name"];
      bool available = map["available"] ?? false;
      if ((id != null) && (name != null)) {
        SIQDepartment department = SIQDepartment(id, name, available);
        departmentList.add(department);
      }
    }
    return departmentList;
  }
}

class SIQChat {
  final String id;
  final String? question;
  final int? queuePosition;

  final String? attenderName;
  final String? attenderEmail;
  final String? attenderID;
  final bool isBotAttender;

  final String? departmentName;
  final SIQChatStatus status;
  final int unreadCount;

  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSender;

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
      this.feedback,
      this.rating);
}

class SIQDepartment {
  final String id;
  final String name;
  final bool available;
  SIQDepartment(this.id, this.name, this.available);
}

class SIQArticle {
  final String id;
  final String name;

  final String categoryId;
  final String categoryName;

  final int viewCount;
  final int likeCount;
  final int dislikeCount;

  final DateTime createdTime;
  final DateTime modifiedTime;
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

class SIQArticleCategory {
  final String id;
  final String name;
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
