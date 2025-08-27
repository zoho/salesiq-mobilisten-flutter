import 'salesiq_core_enums.dart';

class SalesIQDepartment {
  final String? id;
  final String? name;
  final bool? available;

  // final String? displayName;
  // final bool isEngaged;
  // final int queueSize;
  // final int currentQueueSize;
  final CommunicationMode? communicationMode;

  const SalesIQDepartment({
    this.id,
    this.name,
    this.available = false,
    this.communicationMode,
  });

  factory SalesIQDepartment.fromBasic({
    String? id,
    String? name,
    required CommunicationMode communicationMode,
  }) {
    return SalesIQDepartment(
      id: id,
      name: name,
      communicationMode: communicationMode,
    );
  }

  factory SalesIQDepartment.fromName(
    String? name, {
    required CommunicationMode communicationMode,
  }) {
    return SalesIQDepartment(
      name: name,
      communicationMode: communicationMode,
    );
  }

  static SalesIQDepartment? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;

    return SalesIQDepartment(
      id: map["id"] as String?,
      name: map["name"] as String?,
      available: map["available"] as bool?,
      communicationMode: CommunicationMode.fromString(map["communicationMode"]),
    );
  }

  static List<SalesIQDepartment> fromList(List? mapList) {
    if (mapList == null) {
      return [];
    }

    List<SalesIQDepartment> departments = [];
    for (int i = 0; i < mapList.length; i++) {
      final raw = mapList[i] as Map<Object?, Object?>; // what comes from Swift
      final map = raw.map((key, value) =>
          MapEntry(key.toString(), value)); // convert to <String, dynamic>

      SalesIQDepartment? department = SalesIQDepartment.fromMap(map);
      if (department != null) {
        departments.add(department);
      }
    }
    return departments;
  }

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "name": name,
      "available": available,
      "communicationMode": communicationMode?.index,
    };
  }
}
