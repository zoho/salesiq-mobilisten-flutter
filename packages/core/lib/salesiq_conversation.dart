import 'package:salesiq_mobilisten_core/utils/primitive_type_cast_utils.dart';

/// This file is part of the ZOHO Flutter SDK.
/// SalesIQConversation is an abstract class that represents a conversation in the Zoho SalesIQ system.
/// It can be either a chat conversation or a call conversation.
abstract class SalesIQConversation {
  /// Unique identifier for the conversation.
  final String? id;

  /// The custom conversation id supplied at chat/call start, if any.
  final String? customConversationId;

  /// The question the conversation was started with, if any.
  final String? question;

  /// The unique id of the operator handling the conversation, if assigned.
  final String? attenderId;

  /// The name of the operator handling the conversation, if assigned.
  final String? attenderName;

  /// The email of the operator handling the conversation, if assigned.
  final String? attenderEmail;

  /// The name of the department handling the conversation, if any.
  final String? departmentName;

  /// The feedback left by the visitor, if any.
  final String? feedback;

  /// The rating left by the visitor, if any.
  final String? rating;

  /// The visitor's position in the queue; `-1` when not queued.
  final int queuePosition;

  /// The associated call/media details, if any.
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

  /// Serializes this conversation to a native-compatible map.
  Map<String, dynamic> toMap();

  /// Builds a [SalesIQChatConversation] or [SalesIQCallConversation] from the
  /// native [map] based on its `type`, or `null` when [map] is empty/invalid.
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

/// A chat conversation. A [SalesIQConversation] whose type is `chat`.
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

  /// Serializes this conversation to a map for the native bridge.
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

/// A call conversation. A [SalesIQConversation] whose type is `call`.
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

  /// Serializes this conversation to a map for the native bridge.
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

/// Call/media details associated with a [SalesIQConversation].
class Media {
  /// Unique identifier for the media session.
  final String? id;

  /// The time (epoch ms) at which the media session ended, if ended.
  final int? endTime;

  /// The party that initiated the media session.
  final UserType? initiatedBy;

  /// The time (epoch ms) at which the media session was picked up.
  final int? pickupTime;

  /// The time (epoch ms) at which the media session connected.
  final int? connectedTime;

  /// The current status of the media session.
  final MediaStatus? status;

  /// The party that ended the media session.
  final UserType? endedBy;

  /// The media type (e.g. audio/video).
  final String? type;

  /// The time (epoch ms) at which the media session was created.
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

  /// Builds a [Media] from the native [map], or `null` when [map] is `null`.
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

  /// Serializes this media session to a native-compatible map.
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

/// The status of a [Media] session.
enum MediaStatus {
  /// The media session ended.
  ended,

  /// The media session was missed.
  missed,

  /// The media session was cancelled.
  cancelled,

  /// The media session is connected.
  connected,

  /// The media session invite was sent.
  invited,

  /// The media session was initiated.
  initiated,

  /// The media session was accepted.
  accepted;

  /// Returns the [MediaStatus] matching [status], or `null` if unrecognized.
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

/// A party involved in a conversation or media session.
enum UserType {
  /// The visitor (end user).
  visitor,

  /// The operator (agent).
  operator;

  /// Returns the [UserType] matching [type], or `null` if unrecognized.
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

/// The status of a [SalesIQChatConversation].
enum ChatStatus {
  /// The chat is waiting in the queue.
  waiting,

  /// The chat is connected to an operator.
  connected,

  /// The chat was missed.
  missed,

  /// The chat is closed.
  closed,

  /// The chat was started by a trigger.
  triggered,

  /// The chat was started proactively.
  proactive;

  /// Returns the [ChatStatus] matching [status], or `null` if unrecognized.
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

/// The status of a [SalesIQCallConversation].
enum CallStatus {
  /// The call is waiting in the queue.
  waiting,

  /// The call is connected to an operator.
  connected,

  /// The call was missed.
  missed,

  /// The call is closed.
  closed;

  /// Returns the [CallStatus] matching [status], or `null` if unrecognized.
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

/// A single message within a [SalesIQChatConversation].
class SalesIQMessage {
  /// The display name of the message sender.
  final String? sender;

  /// The text content of the message.
  final String? text;

  /// The message type.
  final String? type;

  final String?
      _senderId; // This is private in Kotlin, we'll keep it the same in Dart

  /// The time (epoch ms) at which the message was sent.
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

  /// The normalized sender id, derived from the raw native sender id.
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

  /// Builds a [SalesIQMessage] from the native [map], or `null` when [map]
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

  /// Serializes this message to a native-compatible map.
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

/// A file attached to a [SalesIQMessage].
class SalesIQFile {
  /// The file name.
  final String? name;

  /// The MIME content type of the file.
  final String? contentType;

  /// An optional comment associated with the file.
  final String? comment;

  /// The file size in bytes.
  final int? size;

  /// Creates a file with the given attributes.
  SalesIQFile({
    this.name,
    this.contentType,
    this.comment,
    this.size,
  });

  /// Builds a [SalesIQFile] from the native [map], or `null` when [map] is
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

  /// Serializes this file to a native-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contentType': contentType,
      'comment': comment,
      'size': size,
    };
  }
}

/// The delivery status of a [SalesIQMessage].
enum Status {
  /// The message is being sent.
  sending,

  /// An attachment is uploading.
  uploading,

  /// The message was sent.
  sent,

  /// The message failed to send.
  failed;

  /// Returns the [Status] matching [status], or `null` if unrecognized.
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
