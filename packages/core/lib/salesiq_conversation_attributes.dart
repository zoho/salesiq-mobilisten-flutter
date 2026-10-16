import 'package:salesiq_mobilisten_core/salesiq_department.dart';
import 'package:salesiq_mobilisten_core/utils/image/utility.dart';

/// The metadata that you apply to conversations. Use it to customize the
/// operator's name, display picture, additional information, and linked
/// departments.
class SalesIQConversationAttributes {
  /// The operator name that appears for the conversation.
  final String? name;

  /// Additional information that appears with the conversation.
  final String? additionalInfo;

  /// The display picture of the operator. It can be an image URL, a Flutter
  /// asset path, a `file://` URI, a `File`, a `Uint8List`, or a base64 string.
  final Object? displayPicture;

  /// The departments that are linked to the conversation.
  final List<SalesIQDepartment>? departments;

  /// Creates a set of conversation attributes.
  const SalesIQConversationAttributes({
    this.name,
    this.additionalInfo,
    this.displayPicture,
    this.departments,
  });

  /// Returns a copy of these attributes, with the given values for [name],
  /// [additionalInfo], [displayPicture], or [departments].
  SalesIQConversationAttributes copyWith({
    String? name,
    String? additionalInfo,
    Object? displayPicture,
    List<SalesIQDepartment>? departments,
  }) {
    return SalesIQConversationAttributes(
      name: name ?? this.name,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      displayPicture: displayPicture ?? this.displayPicture,
      departments: departments ?? this.departments,
    );
  }

  /// Converts these attributes to a map that the native SDKs can read. If there
  /// is a display picture, it is encoded as a base64 string.
  Future<Map<String, Object?>> toMap() async {
    Map<String, Object?> map = {
      "name": name,
      "additionalInfo": additionalInfo,
      "departments": departments?.map((e) => e.toMap()).toList(),
    };
    if (displayPicture != null) {
      String? base64Image = await getBase64EncodedImage(displayPicture);
      if (base64Image != null) {
        map["displayPicture"] = base64Image;
      }
    }
    return map;
  }
}
