class SIQMessage {
  final String? sender;
  final String? text; //type, senderId;
  final bool? isRead; //, sentByVisitor;
  final File? file;
  late final DateTime? time;
  // final Status? status;

  SIQMessage(this.text, this.sender, this.time, this.isRead, this.file);

  static SIQMessage getObject(Map map) {
    String? sender = map["sender"];
    // String? senderId = map["sender_id"];
    String? text = map["text"];
    // String? type = map["type"];
    double? _time = map["time"];
    // bool? sentByVisitor = map["sent_by_visitor"] ?? false;
    bool? isRead = map["is_read"];
    // Status? status = map["status"];
    Map? fileMap = map["file"];
    String? name = fileMap?["name"];
    String? comment = fileMap?["comment"];
    String? contentType = fileMap?["content_type"];
    int size = fileMap?["size"] ?? 0;
    File? file = File(name, comment, contentType, size);
    DateTime? time;
    if (_time != null) {
      time = _convertDoubleToDateTime(_time);
    }
    SIQMessage message = SIQMessage(text, sender, time, isRead, file);
    return message;
  }

  static DateTime _convertDoubleToDateTime(double epochTime) {
    return DateTime.fromMillisecondsSinceEpoch(epochTime.toInt());
  }
}

class File {
  final String? name, contentType, comment;

  final int size;

  File(this.name, this.comment, this.contentType, this.size);
}

// enum Status { Sending, Uploading, Sent, Failure }
