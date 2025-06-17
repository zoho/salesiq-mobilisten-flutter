import 'package:flutter/services.dart';

import 'salesiq_mobilisten.dart';

class Notification {
  // ignore_for_file: public_member_api_docs

  static MethodChannel methodChannel =
      const MethodChannel('salesiqNotificationModule');

  final eventChannel = EventChannel("mobilistenNotificationEvents")
      .receiveBroadcastStream()
      .map((event) => NotificationEvent(
          NotificationAction.from(event["eventName"] as String),
          _getNotificationPayload(event["payload"] as Map)));

  /// Use this API to enable push notifications for Android
  void registerPush(String token, bool isTestDevice) {
    Map<String, dynamic> map = <String, dynamic>{};
    map.putIfAbsent("token", () => token);
    map.putIfAbsent("isTestDevice", () => isTestDevice);
    methodChannel.invokeMethod('registerPush', map);
  }

  Future<bool> isSDKMessage(Map data) async {
    return await methodChannel
        .invokeMethod<bool>('isSDKMessage', data)
        .then((value) => value ?? false);
  }

  void process(Map map) {
    methodChannel.invokeMethod('processNotification', map);
  }

  Future<SalesIQNotificationPayload?> getPayload(Map data) async {
    return _getNotificationPayload(await methodChannel
        .invokeMethod<Map<dynamic, dynamic>>('getNotificationPayload', data));
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

SalesIQNotificationPayload? _getNotificationPayload(Map? data) {
  if (data == null) {
    return null;
  }
  Map? payload = data['payload'] as Map?;
  if (payload == null) {
    return null;
  }

  if (data['type'] == 'chat') {
    return SalesIQNotificationPayloadChat(
        message: payload['message']?.toString(),
        userId: payload['userId']?.toString(),
        chatId: payload['chatId']?.toString(),
        senderName: payload['senderName']?.toString(),
        previousMessageUID: payload['previousMessageUID']?.toString(),
        messageUID: payload['messageUID']?.toString(),
        sender: payload['sender']?.toString(),
        title: payload['title']?.toString(),
        department: getDepartment(payload));
  } else if (data['type'] == 'visitorHistory') {
    return SalesIQNotificationPayloadVisitorHistory(
        imagePath: payload['imagePath']?.toString(),
        targetLink: payload['targetLink']?.toString(),
        title: payload['title']?.toString(),
        message: payload['message']?.toString());
  } else if (data['type'] == 'endChatDetails') {
    return SalesIQNotificationPayloadEndChatDetails(
      message: payload['message']?.toString(),
      userId: payload['userId']?.toString(),
      chatId: payload['chatId']?.toString(),
      title: payload['title']?.toString(),
      department: getDepartment(payload),
    );
  } else {
    return null;
  }
}

Department? getDepartment(Map<dynamic, dynamic> payload) {
  Department? department;
  if (payload['department'] != null && payload['department']?['id'] != null) {
    department = Department(
      id: payload['department']['id']?.toString(),
      name: payload['department']['name']?.toString(),
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
