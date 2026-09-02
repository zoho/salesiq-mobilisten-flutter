import 'package:flutter/services.dart';

import 'salesiq_mobilisten.dart';

/// This class provides APIs to handle push notifications in the Zoho SalesIQ SDK.
class SalesIQMobilistenNotification {
  static final MethodChannel _methodChannel =
      const MethodChannel('salesiqNotificationModule');

  /// Stream of notification events (e.g. a notification being tapped).
  final eventChannel = EventChannel("mobilistenNotificationEvents")
      .receiveBroadcastStream()
      .map((event) => NotificationEvent(
          NotificationAction.from(event["eventName"] as String),
          _getNotificationPayload(event["payload"] as Map)));

  /// Enables push notifications for Android using the FCM [token].
  ///
  /// Set [isTestDevice] to `true` to register the device against the test
  /// (development) push environment.
  Future<void> registerPush(String token, bool isTestDevice) {
    Map<String, dynamic> map = <String, dynamic>{};
    map.putIfAbsent("token", () => token);
    map.putIfAbsent("isTestDevice", () => isTestDevice);
    return _methodChannel.invokeMethod('registerPush', map);
  }

  /// Disables push notifications for Android.
  ///
  /// The FCM token captured during [registerPush] is reused internally, so no
  /// token needs to be passed here.
  Future<void> disablePush() {
    return _methodChannel.invokeMethod('disablePush');
  }

  /// Enables or disables in-app notifications from Mobilisten, based on the
  /// value provided for [enabled]. In-app notifications are enabled by default.
  void enableInAppNotification(bool enabled) {
    _methodChannel.invokeMethod('enableInAppNotification', enabled);
  }

  /// Returns the current badge count for unread conversations.
  ///
  /// On iOS, the unread message count is returned as the badge-count
  /// equivalent.
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

  /// Processes the SalesIQ notification contained in [map].
  ///
  /// Applies only for Android, where it is called from your
  /// `FirebaseMessagingService` to hand an incoming FCM message to the SDK. On
  /// iOS, notifications are handled through
  /// [ZohoSalesIQ.processNotificationWithInfoForiOS] /
  /// [ZohoSalesIQ.handleNotificationResponseForiOS] instead.
  void process(Map map) {
    _methodChannel.invokeMethod('process', map);
  }

  /// Returns the parsed notification payload extracted from the raw
  /// notification [data].
  Future<SalesIQNotificationPayload?> getPayload(Map data) async {
    return _getNotificationPayload(await _methodChannel
        .invokeMethod<Map<dynamic, dynamic>>('getNotificationPayload', data));
  }

  /// Sets the notification action source using the given [actionSource].
  void setActionSource(ActionSource actionSource) {
    _methodChannel.invokeMethod(
        'setNotificationActionSource', actionSource.name);
  }

  /// Re-registers the device for push notifications with the SalesIQ SDK.
  ///
  /// Call this in response to a `SIQEvent.reRegisterPush` event, which the SDK
  /// emits when the existing push registration is no longer valid.
  ///
  /// Applies only for iOS; the Android native SDK does not expose a
  /// re-registration API and this call is a no-op on Android.
  Future<void> reRegisterPush() async {
    await _methodChannel.invokeMethod('reRegisterPush');
  }

  /// Handles the push notification action identified by [actionIdentifier]
  /// for iOS, using the notification [userInfo] and any [responseText]
  /// entered by the user.
  Future<void> handlePushNotificationAction(
      String actionIdentifier, Map userInfo, String responseText) {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("actionIdentifier", () => actionIdentifier);
    args.putIfAbsent("userInfo", () => userInfo);
    args.putIfAbsent("responseText", () => responseText);
    return _methodChannel.invokeMethod('handlePushNotificationAction', args);
  }
}

/// An event emitted on the notification stream (e.g. a notification tap).
class NotificationEvent {
  /// The action that occurred, if recognized.
  NotificationAction? action;

  /// The payload associated with the notification, if any.
  SalesIQNotificationPayload? payload;

  /// Creates a notification event with the given [action] and [payload].
  NotificationEvent(this.action, this.payload);
}

/// The user action performed on a SalesIQ notification.
class NotificationAction {
  const NotificationAction._(this.value);

  /// The raw native value of the action.
  final String value;

  /// The notification was clicked/tapped.
  static const NotificationAction clicked =
      NotificationAction._("notificationClicked");

  /// Returns the [NotificationAction] matching the raw event [value], or
  /// `null` if it is unrecognized.
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

/// Base class for the payload carried by a SalesIQ notification.
abstract class SalesIQNotificationPayload {
  /// Serializes this payload to a native-compatible map.
  Map<String, dynamic> toMap();
}

/// The payload of a chat notification.
class SalesIQNotificationPayloadChat extends SalesIQNotificationPayload {
  /// The message text.
  final String? message;

  /// The user id associated with the chat.
  final String? userId;

  /// The chat id.
  final String? chatId;

  /// The display name of the message sender.
  final String? senderName;

  /// The UID of the previous message, used for ordering.
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

  /// Serializes this notification payload to a native-compatible map.
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

/// A department referenced by a notification payload.
class Department {
  /// Unique identifier of the department.
  final String? id;

  /// Display name of the department.
  final String? name;

  /// Creates a department reference with the given [id] and [name].
  Department({this.id, this.name});

  /// Serializes this department to a native-compatible map.
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
    };
  }
}

/// The payload of a visitor-history notification.
class SalesIQNotificationPayloadVisitorHistory
    extends SalesIQNotificationPayload {
  /// The image path shown with the notification.
  final String? imagePath;

  /// The target link opened when the notification is tapped.
  final String? targetLink;

  /// The notification title.
  final String? title;

  /// The notification message.
  final String? message;

  /// Creates a visitor-history notification payload.
  SalesIQNotificationPayloadVisitorHistory({
    this.imagePath,
    this.targetLink,
    this.title,
    this.message,
  });

  /// Serializes this notification payload to a native-compatible map.
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

/// The payload of an end-of-chat details notification.
class SalesIQNotificationPayloadEndChatDetails
    extends SalesIQNotificationPayload {
  /// The message text.
  final String? message;

  /// The user id associated with the chat.
  final String? userId;

  /// The chat id.
  final String? chatId;

  /// The notification title.
  final String? title;

  /// The department associated with the chat, if any.
  final Department? department;

  /// Creates an end-of-chat details notification payload.
  SalesIQNotificationPayloadEndChatDetails({
    this.message,
    this.userId,
    this.chatId,
    this.title,
    this.department,
  });

  /// Serializes this notification payload to a native-compatible map.
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
  /// The notification content text.
  final String? content;

  /// The user id associated with the call.
  final String? userId;

  /// The display name of the caller.
  final String? userName;

  /// The chat/call id.
  final String? chatId;

  /// The notification title.
  final String? title;

  /// The call operation (incoming/miss/cancel).
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

  /// Serializes this notification payload to a native-compatible map.
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

/// The call operation described by a call notification payload.
enum Operation {
  /// An incoming call.
  incoming,

  /// A missed call.
  miss,

  /// A cancelled call.
  cancel;

  /// Returns the [Operation] matching [value], or `null` if unrecognized.
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
