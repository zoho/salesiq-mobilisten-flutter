/// Holds the data of a message.
class SIQMessage {
  /// Creates a message with the given data.
  SIQMessage(this.text, this.sender, this.time, this.isRead, this.file);

  /// The sender of the message.
  final String? sender;

  /// The content of the message.
  final String? text; //type, senderId;
  /// Whether the message is read.
  final bool? isRead; //, sentByVisitor;
  /// The file data of the message.
  final File? file;

  /// The time of the message.
  late final DateTime? time;
  // final Status? status;

  /// Builds an [SIQMessage] from the native message [map]. Returns `null` when
  /// [map] is `null`.
  static SIQMessage? getObject(Map? map) {
    if (map != null) {
      String? sender = map["sender"]?.toString();
      // String? senderId = map["sender_id"];
      String? text = map["text"]?.toString();
      // String? type = map["type"];
      double? _time = map["time"] as double?;
      // bool? sentByVisitor = map["sent_by_visitor"] ?? false;
      bool? isRead = map["is_read"] as bool?;
      // Status? status = map["status"];
      Map? fileMap = map["file"] as Map?;
      String? name = fileMap?["name"] as String?;
      String? comment = fileMap?["comment"] as String?;
      String? contentType = fileMap?["content_type"] as String?;
      int size = fileMap?["size"] as int? ?? 0;
      File? file = File(name, comment, contentType, size);
      DateTime? time;
      if (_time != null) {
        time = _convertDoubleToDateTime(_time);
      }
      SIQMessage message = SIQMessage(text, sender, time, isRead, file);
      return message;
    } else {
      return null;
    }
  }

  static DateTime _convertDoubleToDateTime(double epochTime) {
    return DateTime.fromMillisecondsSinceEpoch(epochTime.toInt());
  }
}

/// Holds the data of a file.
class File {
  /// The name, content type, and comment of the file.
  final String? name, contentType, comment;

  /// The size of the file in bytes.
  final int size;

  /// Creates a file with the given data.
  File(this.name, this.comment, this.contentType, this.size);
}

// enum Status { Sending, Uploading, Sent, Failure }
