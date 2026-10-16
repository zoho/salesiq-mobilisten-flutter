import 'package:flutter/services.dart';

import 'salesiq_mobilisten.dart';

/// Provides the APIs to handle push notifications in the Zoho SalesIQ SDK.
class SalesIQMobilistenNotification {
  static final MethodChannel _methodChannel =
      const MethodChannel('salesiqNotificationModule');

  /// The stream of notification events, such as a tap on a notification.
  final eventChannel = EventChannel("mobilistenNotificationEvents")
      .receiveBroadcastStream()
      .map((event) => NotificationEvent(
          NotificationAction.from(event["eventName"] as String),
          _getNotificationPayload(event["payload"] as Map)));

  /// Turns on push notifications for Android with the FCM [token].
  ///
  /// To register the device with the test, or development, push environment,
  /// set [isTestDevice] to `true`.
  Future<void> registerPush(String token, bool isTestDevice) {
    Map<String, dynamic> map = <String, dynamic>{};
    map.putIfAbsent("token", () => token);
    map.putIfAbsent("isTestDevice", () => isTestDevice);
    return _methodChannel.invokeMethod('registerPush', map);
  }

  /// Turns off push notifications for Android.
  ///
  /// The SDK reuses the FCM token that it received in [registerPush], so you do
  /// not need to pass a token here.
  Future<void> disablePush() {
    return _methodChannel.invokeMethod('disablePush');
  }

  /// Turns in-app notifications from the SDK on or off, based on the value of
  /// [enabled]. In-app notifications are on by default.
  void enableInAppNotification(bool enabled) {
    _methodChannel.invokeMethod('enableInAppNotification', enabled);
  }

  /// Returns the current badge count, which is the total number of unread
  /// messages across all conversations.
  Future<int> getBadgeCount() async {
    return await _methodChannel
        .invokeMethod<int>('getBadgeCount')
        .then((value) => value ?? 0);
  }

  /// Returns whether the notification [data] belongs to SalesIQ.
  Future<bool> isSDKMessage(Map data) async {
    return await _methodChannel
        .invokeMethod<bool>('isSDKMessage', data)
        .then((value) => value ?? false);
  }

  /// Processes the SalesIQ notification in [map].
  ///
  /// This works only on Android. Call it from your `FirebaseMessagingService`
  /// to pass an incoming FCM message to the SDK. On iOS, use
  /// [ZohoSalesIQ.processNotificationWithInfoForiOS] or
  /// [ZohoSalesIQ.handleNotificationResponseForiOS] instead.
  void process(Map map) {
    _methodChannel.invokeMethod('process', map);
  }

  /// Returns the parsed notification payload from the raw notification [data].
  Future<SalesIQNotificationPayload?> getPayload(Map data) async {
    return _getNotificationPayload(await _methodChannel
        .invokeMethod<Map<dynamic, dynamic>>('getNotificationPayload', data));
  }

  /// Sets the source of notification actions to the given [actionSource].
  void setActionSource(ActionSource actionSource) {
    _methodChannel.invokeMethod(
        'setNotificationActionSource', actionSource.name);
  }

  /// Registers the device for push notifications with the SalesIQ SDK again.
  ///
  /// Call this method when you receive an `SIQEvent.reRegisterPush` event. The
  /// SDK sends this event when the current push registration is no longer
  /// valid.
  ///
  /// This works only on iOS. The Android SDK has no re-registration API, so
  /// this call has no effect on Android.
  Future<void> reRegisterPush() async {
    await _methodChannel.invokeMethod('reRegisterPush');
  }

  /// Handles the push notification action with the given [actionIdentifier] on
  /// iOS. It uses the notification [userInfo] and any [responseText] that the
  /// visitor entered.
  Future<void> handlePushNotificationAction(
      String actionIdentifier, Map userInfo, String responseText) {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("actionIdentifier", () => actionIdentifier);
    args.putIfAbsent("userInfo", () => userInfo);
    args.putIfAbsent("responseText", () => responseText);
    return _methodChannel.invokeMethod('handlePushNotificationAction', args);
  }
}

/// An event that the notification stream sends, such as a tap on a
/// notification.
class NotificationEvent {
  /// The action that occurred, if it is recognized.
  NotificationAction? action;

  /// The payload associated with the notification, if any.
  SalesIQNotificationPayload? payload;

  /// Creates a notification event with the given [action] and [payload].
  NotificationEvent(this.action, this.payload);
}

/// The action that the visitor performed on a SalesIQ notification.
class NotificationAction {
  const NotificationAction._(this.value);

  /// The raw native value of the action.
  final String value;

  /// The visitor clicked or tapped the notification.
  static const NotificationAction clicked =
      NotificationAction._("notificationClicked");

  /// Returns the [NotificationAction] that matches the raw event [value], or
  /// `null` if it is not recognized.
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

/// Represents the payload that a SalesIQ notification carries. It is the base
/// class for each payload type.
abstract class SalesIQNotificationPayload {
  /// Converts this payload to a map that the native SDKs can read.
  Map<String, dynamic> toMap();
}

/// The payload of a chat notification.
class SalesIQNotificationPayloadChat extends SalesIQNotificationPayload {
  /// The message text.
  final String? message;

  /// The ID of the sender on the other end of the chat, usually the operator or bot.
  final String? userId;

  /// The ID of the chat.
  final String? chatId;

  /// The display name of the message sender.
  final String? senderName;

  /// The UID of the previous message, which is used for ordering.
  final String? previousMessageUID;

  /// The UID of this message.
  final String? messageUID;

  /// The raw sender identifier.
  final String? sender;

  /// The notification title.
  final String? title;

  /// The department associated with the chat, if any.
  final Department? department;

  /// Creates a chat notification payload.
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

  /// Converts this notification payload to a map that the native SDKs can read.
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

/// A department that a notification payload refers to.
class Department {
  /// The unique ID of the department.
  final String? id;

  /// The display name of the department.
  final String? name;

  /// Creates a department reference with the given [id] and [name].
  Department({this.id, this.name});

  /// Converts this department to a map that the native SDKs can read.
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
    };
  }
}

/// The payload of a visitor history notification.
class SalesIQNotificationPayloadVisitorHistory
    extends SalesIQNotificationPayload {
  /// The path of the image that appears with the notification.
  final String? imagePath;

  /// The link that opens when the visitor taps the notification.
  final String? targetLink;

  /// The notification title.
  final String? title;

  /// The notification message.
  final String? message;

  /// Creates a visitor history notification payload.
  SalesIQNotificationPayloadVisitorHistory({
    this.imagePath,
    this.targetLink,
    this.title,
    this.message,
  });

  /// Converts this notification payload to a map that the native SDKs can read.
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

/// The payload of a notification with the details of an ended chat.
class SalesIQNotificationPayloadEndChatDetails
    extends SalesIQNotificationPayload {
  /// The message text.
  final String? message;

  /// The ID of the operator or bot on the other end of the chat.
  final String? userId;

  /// The ID of the chat.
  final String? chatId;

  /// The notification title.
  final String? title;

  /// The department associated with the chat, if any.
  final Department? department;

  /// Creates a notification payload with the details of an ended chat.
  SalesIQNotificationPayloadEndChatDetails({
    this.message,
    this.userId,
    this.chatId,
    this.title,
    this.department,
  });

  /// Converts this notification payload to a map that the native SDKs can read.
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

/// The payload of a call details notification.
class SalesIQNotificationPayloadCallDetails extends SalesIQNotificationPayload {
  /// The content text of the notification.
  final String? content;

  /// The ID of the operator on the other end of the call.
  final String? userId;

  /// The display name of the operator on the other end of the call.
  final String? userName;

  /// The ID of the chat or call.
  final String? chatId;

  /// The notification title.
  final String? title;

  /// The call operation, such as an incoming, missed, or canceled call.
  final Operation? operation;

  /// The department associated with the call, if any.
  final Department? department;

  /// Creates a call details notification payload.
  SalesIQNotificationPayloadCallDetails({
    this.content,
    this.userId,
    this.userName,
    this.chatId,
    this.title,
    this.operation,
    this.department,
  });

  /// Converts this notification payload to a map that the native SDKs can read.
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

/// Defines the call operation that a call notification payload describes.
enum Operation {
  /// An incoming call.
  incoming,

  /// A missed call.
  miss,

  /// A canceled call.
  cancel;

  /// Returns the [Operation] that matches [value], or `null` if it is not
  /// recognized.
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
