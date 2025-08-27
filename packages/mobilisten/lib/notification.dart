import 'package:flutter/services.dart';

import 'salesiq_mobilisten.dart';

/// This class provides APIs to handle push notifications in the Zoho SalesIQ SDK.
class SalesIQMobilistenNotification {
  static final MethodChannel _methodChannel =
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
    _methodChannel.invokeMethod('registerPush', map);
  }

  /// Use this API to verify whether the data belongs to SalesIQ or not.
  Future<bool> isSDKMessage(Map data) async {
    return await _methodChannel
        .invokeMethod<bool>('isSDKMessage', data)
        .then((value) => value ?? false);
  }

  /// Use this API to process the notification data.
  void process(Map map) {
    _methodChannel.invokeMethod('processNotification', map);
  }

  /// Use this API to get the notification payload from the data.
  Future<SalesIQNotificationPayload?> getPayload(Map data) async {
    return _getNotificationPayload(await _methodChannel
        .invokeMethod<Map<dynamic, dynamic>>('getNotificationPayload', data));
  }

  /// Use this API to set the notification action source.
  void setActionSource(ActionSource actionSource) {
    _methodChannel.invokeMethod(
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
        department: _getDepartment(payload));
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
      department: _getDepartment(payload),
    );
  } else if (data['type'] == 'callDetails') {
    return SalesIQNotificationPayloadCallDetails(
      content: payload['content']?.toString(),
      userId: payload['userId']?.toString(),
      userName: payload['userName']?.toString(),
      chatId: payload['chatId']?.toString(),
      title: payload['title']?.toString(),
      operation: Operation.fromString(payload['operation']?.toString()),
      department: _getDepartment(payload),
    );
  } else {
    return null;
  }
}

Department? _getDepartment(Map<dynamic, dynamic> payload) {
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

class SalesIQNotificationPayloadCallDetails extends SalesIQNotificationPayload {
  final String? content;
  final String? userId;
  final String? userName;
  final String? chatId;
  final String? title;
  final Operation? operation;
  final Department? department;

  SalesIQNotificationPayloadCallDetails({
    this.content,
    this.userId,
    this.userName,
    this.chatId,
    this.title,
    this.operation,
    this.department,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      "type": "callDetails",
      "payload": {
        "content": content,
        "userId": userId,
        "userName": userName,
        "chatId": chatId,
        "title": title,
        "operation": operation?.name,
        "department": department?.toMap()
      }
    };
  }
}

enum Operation {
  incoming,
  miss,
  cancel;

  static Operation? fromString(String? value) {
    switch (value) {
      case 'incoming':
        return Operation.incoming;
      case 'miss':
        return Operation.miss;
      case 'cancel':
        return Operation.cancel;
      default:
        return null;
    }
  }
}
