import 'package:flutter/services.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

class Notification {
  static MethodChannel methodChannel =
      const MethodChannel('salesiqNotificationModule');

  final eventChannel = EventChannel("mobilistenNotificationEvents")
      .receiveBroadcastStream()
      .map((event) => NotificationEvent(
          NotificationAction.from(event["eventName"]),
          _getNotificationPayload(event["payload"])));

  /// Use this API to enable push notifications for Android
  void registerPush(String token, bool isTestDevice) {
    Map<String, dynamic> map = <String, dynamic>{};
    map.putIfAbsent("token", () => token);
    map.putIfAbsent("isTestDevice", () => isTestDevice);
    methodChannel.invokeMethod('registerPush', map);
  }

  Future<bool> isSDKMessage(Map data) async {
    return await methodChannel.invokeMethod('isSDKMessage', data);
  }

  void process(Map map) {
    methodChannel.invokeMethod('processNotification', map);
  }

  Future<SalesIQNotificationPayload?> getPayload(Map data) async {
    return _getNotificationPayload(
        await methodChannel.invokeMethod('getNotificationPayload', data));
  }

  void setActionSource(ActionSource actionSource) {
    methodChannel.invokeMethod(
        'setNotificationActionSource', actionSource.name);
  }
}

class NotificationEvent {
  NotificationAction? action;
  SalesIQNotificationPayload? payload;

  NotificationEvent(this.action, this.payload);
}

class NotificationAction {
  const NotificationAction._(this.value);

  final String value;
  static const NotificationAction clicked =
      NotificationAction._("notificationClicked");

  static NotificationAction? from(String value) {
    if (value == clicked.value) {
      return clicked;
    } else {
      return null;
    }
  }
}

SalesIQNotificationPayload? _getNotificationPayload(Map data) {
  print("Push test data: ${data["type"]} ${data['payload']["department"]}");
  Map payload = data['payload'];
  if (data['type'] == 'chat') {
    return SalesIQNotificationPayloadChat(
        message: payload['message'],
        userId: payload['userId'],
        chatId: payload['chatId'],
        senderName: payload['senderName'],
        previousMessageUID: payload['previousMessageUID'],
        messageUID: payload['messageUID'],
        sender: payload['sender'],
        title: payload['title'],
        department: getDepartment(payload));
  } else if (data['type'] == 'visitorHistory') {
    return SalesIQNotificationPayloadVisitorHistory(
      imagePath: payload['imagePath'],
      targetLink: payload['targetLink'],
      title: payload['title'],
      message: payload['message'],
    );
  } else if (data['type'] == 'endChatDetails') {
    return SalesIQNotificationPayloadEndChatDetails(
      message: payload['message'],
      userId: payload['userId'],
      chatId: payload['chatId'],
      title: payload['title'],
      department: getDepartment(payload),
    );
  } else {
    return null;
  }
}

Department? getDepartment(Map<dynamic, dynamic> payload) {
  Department? department;
  if (payload['department'] != null && payload['department']['id'] != null) {
    department = Department(
      id: payload['department']['id'],
      name: payload['department']['name'],
    );
  }
  return department;
}

abstract class SalesIQNotificationPayload {
  Map<String, dynamic> toMap();
}

class SalesIQNotificationPayloadChat extends SalesIQNotificationPayload {
  final String? message;
  final String? userId;
  final String? chatId;
  final String? senderName;
  final String? previousMessageUID;
  final String? messageUID;
  final String? sender;
  final String? title;
  final Department? department;

  SalesIQNotificationPayloadChat({
    this.message,
    this.userId,
    this.chatId,
    this.senderName,
    this.previousMessageUID,
    this.messageUID,
    this.sender,
    this.title,
    this.department,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      "type": "chat",
      "payload": {
        "message": message,
        "userId": userId,
        "chatId": chatId,
        "senderName": senderName,
        "previousMessageUID": previousMessageUID,
        "messageUID": messageUID,
        "sender": sender,
        "title": title,
        "department": department?.toMap()
      }
    };
  }
}

class Department {
  final String? id;
  final String? name;

  Department({this.id, this.name});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
    };
  }
}

class SalesIQNotificationPayloadVisitorHistory
    extends SalesIQNotificationPayload {
  final String? imagePath;
  final String? targetLink;
  final String? title;
  final String? message;

  SalesIQNotificationPayloadVisitorHistory({
    this.imagePath,
    this.targetLink,
    this.title,
    this.message,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      "type": "visitorHistory",
      "payload": {
        "imagePath": imagePath,
        "targetLink": targetLink,
        "title": title,
        "message": message
      }
    };
  }
}

class SalesIQNotificationPayloadEndChatDetails
    extends SalesIQNotificationPayload {
  final String? message;
  final String? userId;
  final String? chatId;
  final String? title;
  final Department? department;

  SalesIQNotificationPayloadEndChatDetails({
    this.message,
    this.userId,
    this.chatId,
    this.title,
    this.department,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      "type": "endChatDetails",
      "payload": {
        "message": message,
        "userId": userId,
        "chatId": chatId,
        "title": title,
        "department": department?.toMap()
      }
    };
  }
}
