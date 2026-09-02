import 'package:salesiq_mobilisten_core/salesiq_department.dart';
import 'package:salesiq_mobilisten_core/utils/image/utility.dart';

/// Metadata applied to conversations, used to customize the operator's name,
/// display picture, additional information, and associated departments.
class SalesIQConversationAttributes {
  /// The operator name shown for the conversation.
  final String? name;

  /// Additional information shown alongside the conversation.
  final String? additionalInfo;

  /// The operator display picture (an asset path or bytes).
  final Object? displayPicture;

  /// The departments associated with the conversation.
  final List<SalesIQDepartment>? departments;

  /// Creates a set of conversation attributes.
  const SalesIQConversationAttributes({
    this.name,
    this.additionalInfo,
    this.displayPicture,
    this.departments,
  });

  /// Returns a copy of these attributes overriding [name], [additionalInfo],
  /// [displayPicture] and/or [departments] with the provided values.
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

  /// Serializes these attributes to a native-compatible map, encoding the
  /// display picture as a base64 string when present.
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
