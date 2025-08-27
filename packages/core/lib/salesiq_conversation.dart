import 'package:salesiq_mobilisten_core/utils/primitive_type_cast_utils.dart';

/// This file is part of the ZOHO Flutter SDK.
/// SalesIQConversation is an abstract class that represents a conversation in the Zoho SalesIQ system.
/// It can be either a chat conversation or a call conversation.
abstract class SalesIQConversation {
  /// Unique identifier for the conversation.
  final String? id;
  final String? customConversationId;
  final String? question;
  final String? attenderId;
  final String? attenderName;
  final String? attenderEmail;
  final String? departmentName;
  final String? feedback;
  final String? rating;
  final int queuePosition;
  final Media? media;

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

  Map<String, dynamic> toMap();

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

class SalesIQChatConversation extends SalesIQConversation {
  final bool isBotAttender;
  final ChatStatus? status;
  final int unreadCount;
  final SalesIQMessage? lastSalesIQMessage;

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

class SalesIQCallConversation extends SalesIQConversation {
  final CallStatus? status;

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

class Media {
  final String? id;
  final int? endTime;
  final UserType? initiatedBy;
  final int? pickupTime;
  final int? connectedTime;
  final MediaStatus? status;
  final UserType? endedBy;
  final String? type;
  final int? createdTime;

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

enum MediaStatus {
  ended,
  missed,
  cancelled,
  connected,
  invited,
  initiated,
  accepted;

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

enum UserType {
  visitor,
  operator;

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

enum ChatStatus {
  waiting,
  connected,
  missed,
  closed,
  triggered,
  proactive;

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

enum CallStatus {
  waiting,
  connected,
  missed,
  closed;

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

class SalesIQMessage {
  final String? sender;
  final String? text;
  final String? type;
  final String?
      _senderId; // This is private in Kotlin, we'll keep it the same in Dart
  final int? time;
  final bool isRead;
  final bool sentByVisitor;
  final SalesIQFile? file;
  final Status? status;

  // Constructor
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

  // Computed property for senderId
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

class SalesIQFile {
  final String? name;
  final String? contentType;
  final String? comment;
  final int? size;

  // Constructor
  SalesIQFile({
    this.name,
    this.contentType,
    this.comment,
    this.size,
  });

  static SalesIQFile? fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return null;
    return SalesIQFile(
      name: map['name'] as String?,
      contentType: map['contentType'] as String?,
      comment: map['comment'] as String?,
      size: PrimitiveTypeCastUtils.toInt(map['size']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contentType': contentType,
      'comment': comment,
      'size': size,
    };
  }
}

enum Status {
  sending,
  uploading,
  sent,
  failed;

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
