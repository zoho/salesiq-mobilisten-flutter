import 'package:salesiq_mobilisten_core/salesiq_department.dart';
import 'package:salesiq_mobilisten_core/utils/image/utility.dart';

class SalesIQConversationAttributes {
  final String? name;
  final String? additionalInfo;
  final Object? displayPicture;
  final List<SalesIQDepartment>? departments;

  const SalesIQConversationAttributes({
    this.name,
    this.additionalInfo,
    this.displayPicture,
    this.departments,
  });

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
