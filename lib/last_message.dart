/// This class is used to store data of the message
class SIQMessage {
  /// constructor to initialize the message
  SIQMessage(this.text, this.sender, this.time, this.isRead, this.file);

  /// sender of the message
  final String? sender;

  /// content of the message
  final String? text; //type, senderId;
  /// denotes whether the message is read or not
  final bool? isRead; //, sentByVisitor;
  /// file data of the message
  final File? file;

  /// time of the message
  late final DateTime? time;
  // final Status? status;

  /// internal method to convert the map to the object
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

/// This class is used to store data of the file
class File {
  /// name, content type, comment of the file
  final String? name, contentType, comment;

  /// size of the file in bytes
  final int size;

  /// constructor to initialize the file
  File(this.name, this.comment, this.contentType, this.size);
}

// enum Status { Sending, Uploading, Sent, Failure }
