import 'package:salesiq_mobilisten_core/utils/primitive_type_cast_utils.dart';

/// A conversation in Zoho SalesIQ. A conversation can be a chat conversation
/// or a call conversation.
abstract class SalesIQConversation {
  /// The unique ID of the conversation.
  final String? id;

  /// The custom conversation ID that was passed when the chat or call started,
  /// if any.
  final String? customConversationId;

  /// The question that the conversation started with, if any.
  final String? question;

  /// The unique ID of the operator who handles the conversation, if one is
  /// assigned.
  final String? attenderId;

  /// The name of the operator who handles the conversation, if one is assigned.
  final String? attenderName;

  /// The email address of the operator who handles the conversation, if one is
  /// assigned.
  final String? attenderEmail;

  /// The name of the department that handles the conversation, if any.
  final String? departmentName;

  /// The feedback that the visitor gave, if any.
  final String? feedback;

  /// The rating that the visitor gave, if any.
  final String? rating;

  /// The visitor's position in the queue. It is `-1` when the conversation is
  /// not in the queue.
  final int queuePosition;

  /// The call or media details of the conversation, if any.
  final Media? media;

  /// Creates a conversation with the given common attributes.
  SalesIQConversation({
    this.id,
    this.customConversationId,
    this.question,
    this.attenderId,
    this.attenderName,
    this.attenderEmail,
    this.departmentName,
    this.feedback,
    this.rating,
    required this.queuePosition,
    this.media,
  });

  /// Converts this conversation to a map that the native SDKs can read.
  Map<String, dynamic> toMap();

  /// Builds a [SalesIQChatConversation] or a [SalesIQCallConversation] from the
  /// native [map], based on its `type`. Returns `null` when [map] is empty or
  /// not valid.
  static SalesIQConversation? fromMap(Map<dynamic, dynamic>? map) {
    if (map == null ||
        map.isEmpty ||
        map['type'] == null ||
        map['type'] == "") {
      return null;
    }
    bool isCallConversation =
        map['type'].toString().toLowerCase() == "Call".toLowerCase();
    SalesIQConversation? conversation;
    if (isCallConversation) {
      conversation = SalesIQCallConversation._fromMap(map);
    } else {
      conversation = SalesIQChatConversation._fromMap(map);
    }

    return conversation;
  }
}

/// A chat conversation, which is a [SalesIQConversation] whose type is `chat`.
class SalesIQChatConversation extends SalesIQConversation {
  /// Whether the current attender is a bot.
  final bool isBotAttender;

  /// The current status of the chat.
  final ChatStatus? status;

  /// The number of unread messages in the chat.
  final int unreadCount;

  /// The most recent message in the chat, if any.
  final SalesIQMessage? lastSalesIQMessage;

  /// Creates a chat conversation with the given attributes.
  SalesIQChatConversation(
    String? id,
    String? customConversationId,
    String? question,
    String? attenderId,
    String? attenderName,
    String? attenderEmail,
    String? departmentName,
    String? feedback,
    String? rating,
    int queuePosition,
    Media? media,
    this.isBotAttender,
    this.status,
    this.unreadCount,
    this.lastSalesIQMessage,
  ) : super(
          id: id,
          customConversationId: customConversationId,
          question: question,
          attenderId: attenderId,
          attenderName: attenderName,
          attenderEmail: attenderEmail,
          departmentName: departmentName,
          feedback: feedback,
          rating: rating,
          queuePosition: queuePosition,
          media: media,
        );

  /// Converts this conversation to a map for the native bridge.
  @override
  Map<String, dynamic> toMap() {
    return {
      "type": "chat",
      "id": id,
      "customConversationId": customConversationId,
      "question": question,
      "attenderId": attenderId,
      "attenderName": attenderName,
      "attenderEmail": attenderEmail,
      "departmentName": departmentName,
      "feedback": feedback,
      "rating": rating,
      "queuePosition": queuePosition,
      "media": media?.toMap(),
      "isBotAttender": isBotAttender,
      "status": status?.name,
      "unreadCount": unreadCount,
      "lastSalesIQMessage": lastSalesIQMessage?.toMap(),
    };
  }

  static SalesIQConversation? _fromMap(Map<dynamic, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return null;
    }
    return SalesIQChatConversation(
      map['id'] as String?,
      map['customConversationId'] as String?,
      map['question'] as String?,
      map['attenderId'] as String?,
      map['attenderName'] as String?,
      map['attenderEmail'] as String?,
      map['departmentName'] as String?,
      map['feedback'] as String?,
      map['rating'] as String?,
      PrimitiveTypeCastUtils.toInt(map['queuePosition']) ?? -1,
      Media.fromMap(map['media'] as Map<dynamic, dynamic>?),
      map['isBotAttender'] as bool? ?? false,
      ChatStatus.fromString(map['status'] as String?),
      PrimitiveTypeCastUtils.toIntOrZero(map['unreadCount']),
      SalesIQMessage.fromMap(
          map['lastSalesIQMessage'] as Map<dynamic, dynamic>?),
    );
  }
}

/// A call conversation, which is a [SalesIQConversation] whose type is `call`.
class SalesIQCallConversation extends SalesIQConversation {
  /// The current status of the call.
  final CallStatus? status;

  /// Creates a call conversation with the given attributes.
  SalesIQCallConversation(
    String? id,
    String? customConversationId,
    String? question,
    String? attenderId,
    String? attenderName,
    String? attenderEmail,
    String? departmentName,
    String? feedback,
    String? rating,
    int queuePosition,
    Media? media,
    this.status,
  ) : super(
            id: id,
            customConversationId: customConversationId,
            question: question,
            attenderId: attenderId,
            attenderName: attenderName,
            attenderEmail: attenderEmail,
            departmentName: departmentName,
            feedback: feedback,
            rating: rating,
            queuePosition: queuePosition,
            media: media);

  /// Converts this conversation to a map for the native bridge.
  @override
  Map<String, dynamic> toMap() {
    return {
      "type": "call",
      "id": id,
      "customConversationId": customConversationId,
      "question": question,
      "attenderId": attenderId,
      "attenderName": attenderName,
      "attenderEmail": attenderEmail,
      "departmentName": departmentName,
      "feedback": feedback,
      "rating": rating,
      "queuePosition": queuePosition,
      "media": media?.toMap(),
      "status": status?.name,
    };
  }

  static SalesIQConversation? _fromMap(Map<dynamic, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return null;
    }
    final queuePosition = map['queuePosition'];
    return SalesIQCallConversation(
      map['id'] as String?,
      map['customConversationId'] as String?,
      map['question'] as String?,
      map['attenderId'] as String?,
      map['attenderName'] as String?,
      map['attenderEmail'] as String?,
      map['departmentName'] as String?,
      map['feedback'] as String?,
      map['rating'] as String?,
      PrimitiveTypeCastUtils.toInt(queuePosition) ?? -1,
      Media.fromMap(map['media'] as Map<dynamic, dynamic>?),
      CallStatus.fromString(map['status'] as String?),
    );
  }
}

/// The call or media details of a [SalesIQConversation].
class Media {
  /// The unique ID of the media session.
  final String? id;

  /// The time when the media session ended, in epoch milliseconds, if it has
  /// ended.
  final int? endTime;

  /// The party that started the media session.
  final UserType? initiatedBy;

  /// The time when the media session was picked up, in epoch milliseconds.
  final int? pickupTime;

  /// The time when the media session connected, in epoch milliseconds.
  final int? connectedTime;

  /// The current status of the media session.
  final MediaStatus? status;

  /// The party that ended the media session.
  final UserType? endedBy;

  /// The media type, such as audio.
  final String? type;

  /// The time when the media session was created, in epoch milliseconds.
  final int? createdTime;

  /// Creates a media session with the given attributes.
  Media({
    this.id,
    this.endTime,
    this.initiatedBy,
    this.pickupTime,
    this.connectedTime,
    this.status,
    this.endedBy,
    this.type,
    this.createdTime,
  });

  /// Builds a [Media] from the native [map]. Returns `null` when [map] is
  /// `null`.
  static Media? fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return null;
    return Media(
      id: map['id'] as String?,
      endTime: PrimitiveTypeCastUtils.toInt(map['endTime']),
      initiatedBy: UserType.fromString(map['initiatedBy'] as String?),
      pickupTime: PrimitiveTypeCastUtils.toInt(map['pickupTime']),
      connectedTime: PrimitiveTypeCastUtils.toInt(map['connectedTime']),
      status: MediaStatus.fromString(map['status'] as String?),
      endedBy: UserType.fromString(map['endedBy'] as String?),
      type: map['type'] as String?,
      createdTime: PrimitiveTypeCastUtils.toInt(map['createdTime']),
    );
  }

  /// Converts this media session to a map that the native SDKs can read.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'endTime': endTime,
      'initiatedBy': initiatedBy?.name,
      'pickupTime': pickupTime,
      'connectedTime': connectedTime,
      'status': status?.name,
      'endedBy': endedBy?.name,
      'type': type,
      'createdTime': createdTime,
    };
  }
}

/// Defines the status of a [Media] session.
enum MediaStatus {
  /// The media session ended.
  ended,

  /// The media session was missed.
  missed,

  /// The media session was canceled.
  cancelled,

  /// The media session is connected.
  connected,

  /// The invite for the media session was sent.
  invited,

  /// The media session was started.
  initiated,

  /// The media session was accepted.
  accepted;

  /// Returns the [MediaStatus] that matches [status], or `null` if it is not
  /// recognized.
  static MediaStatus? fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'ended':
        return MediaStatus.ended;
      case 'missed':
        return MediaStatus.missed;
      case 'cancelled':
        return MediaStatus.cancelled;
      case 'connected':
        return MediaStatus.connected;
      case 'invited':
        return MediaStatus.invited;
      case 'initiated':
        return MediaStatus.initiated;
      case 'accepted':
        return MediaStatus.accepted;
      default:
        return null;
    }
  }
}

/// Defines a party in a conversation or media session.
enum UserType {
  /// The visitor, who is the person who chats with you through your app.
  visitor,

  /// The operator, who is a person in your SalesIQ portal who chats with
  /// visitors.
  operator;

  /// Returns the [UserType] that matches [type], or `null` if it is not
  /// recognized.
  static UserType? fromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'visitor':
        return UserType.visitor;
      case 'operator':
        return UserType.operator;
      default:
        return null;
    }
  }
}

/// Defines the status of a [SalesIQChatConversation].
enum ChatStatus {
  /// The chat is waiting in the queue.
  waiting,

  /// The chat is connected to an operator.
  connected,

  /// The chat was missed.
  missed,

  /// The chat is closed.
  closed,

  /// A trigger started the chat.
  triggered,

  /// The chat started proactively.
  proactive;

  /// Returns the [ChatStatus] that matches [status], or `null` if it is not
  /// recognized.
  static ChatStatus? fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'waiting':
        return ChatStatus.waiting;
      case 'connected':
        return ChatStatus.connected;
      case 'missed':
        return ChatStatus.missed;
      case 'closed':
        return ChatStatus.closed;
      case 'triggered':
        return ChatStatus.triggered;
      case 'proactive':
        return ChatStatus.proactive;
      default:
        return null;
    }
  }
}

/// Defines the status of a [SalesIQCallConversation].
enum CallStatus {
  /// The call is waiting in the queue.
  waiting,

  /// The call is connected to an operator.
  connected,

  /// The call was missed.
  missed,

  /// The call is closed.
  closed;

  /// Returns the [CallStatus] that matches [status], or `null` if it is not
  /// recognized.
  static CallStatus? fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'waiting':
        return CallStatus.waiting;
      case 'connected':
        return CallStatus.connected;
      case 'missed':
        return CallStatus.missed;
      case 'closed':
        return CallStatus.closed;
      default:
        return null;
    }
  }
}

/// A single message in a [SalesIQChatConversation].
class SalesIQMessage {
  /// The display name of the message sender.
  final String? sender;

  /// The text of the message.
  final String? text;

  /// The message type.
  final String? type;

  final String?
      _senderId; // This is private in Kotlin, we'll keep it the same in Dart

  /// The time when the message was sent, in epoch milliseconds.
  final int? time;

  /// Whether the message has been read.
  final bool isRead;

  /// Whether the message was sent by the visitor.
  final bool sentByVisitor;

  /// The attached file, if any.
  final SalesIQFile? file;

  /// The delivery status of the message.
  final Status? status;

  /// Creates a message with the given attributes.
  SalesIQMessage({
    this.sender,
    this.text,
    this.type,
    String? senderId,
    this.time,
    required this.isRead,
    required this.sentByVisitor,
    this.file,
    this.status,
  }) : _senderId = senderId;

  /// Returns the normalized sender ID, which comes from the raw native sender
  /// ID.
  String? get senderId {
    if (_senderId?.startsWith("\$") == true) {
      return _senderId?.substring(1);
    } else if (_senderId?.startsWith("LD") == true) {
      var senderInSplits = _senderId?.split("_") ?? [];
      return senderInSplits.isNotEmpty ? senderInSplits.last : null;
    } else {
      return _senderId;
    }
  }

  /// Builds a [SalesIQMessage] from the native [map]. Returns `null` when [map]
  /// is `null`.
  static SalesIQMessage? fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return null;

    return SalesIQMessage(
      sender: map['sender'] as String?,
      text: map['text'] as String?,
      type: map['type'] as String?,
      senderId: map['senderId'] as String?,
      time: PrimitiveTypeCastUtils.toInt(map['time']),
      isRead: map['isRead'] as bool? ?? false,
      sentByVisitor: map['sentByVisitor'] as bool? ?? false,
      file: SalesIQFile.fromMap(map['file'] as Map<dynamic, dynamic>?),
      status: Status.fromString(map['status'] as String?),
    );
  }

  /// Converts this message to a map that the native SDKs can read.
  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'text': text,
      'type': type,
      'senderId': _senderId,
      'time': time,
      'isRead': isRead,
      'sentByVisitor': sentByVisitor,
      'file': file?.toMap(),
      'status': status?.name,
    };
  }
}

/// A file that is attached to a [SalesIQMessage].
class SalesIQFile {
  /// The name of the file.
  final String? name;

  /// The MIME content type of the file.
  final String? contentType;

  /// An optional comment about the file.
  final String? comment;

  /// The size of the file in bytes.
  final int? size;

  /// Creates a file with the given attributes.
  SalesIQFile({
    this.name,
    this.contentType,
    this.comment,
    this.size,
  });

  /// Builds a [SalesIQFile] from the native [map]. Returns `null` when [map] is
  /// `null`.
  static SalesIQFile? fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return null;
    return SalesIQFile(
      name: map['name'] as String?,
      contentType: map['contentType'] as String?,
      comment: map['comment'] as String?,
      size: PrimitiveTypeCastUtils.toInt(map['size']),
    );
  }

  /// Converts this file to a map that the native SDKs can read.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contentType': contentType,
      'comment': comment,
      'size': size,
    };
  }
}

/// Defines the delivery status of a [SalesIQMessage].
enum Status {
  /// The message is being sent.
  sending,

  /// An attachment is being uploaded.
  uploading,

  /// The message was sent.
  sent,

  /// The message failed to send.
  failed;

  /// Returns the [Status] that matches [status], or `null` if it is not
  /// recognized.
  static Status? fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'sending':
        return Status.sending;
      case 'uploading':
        return Status.uploading;
      case 'sent':
        return Status.sent;
      case 'failed':
        return Status.failed;
      default:
        return null;
    }
  }
}
