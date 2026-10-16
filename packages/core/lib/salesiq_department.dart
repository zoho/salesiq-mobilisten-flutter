import 'salesiq_core_enums.dart';

/// A SalesIQ department that a conversation can be routed to.
class SalesIQDepartment {
  /// The unique ID of the department.
  final String? id;

  /// The display name of the department.
  final String? name;

  /// Whether the department is currently available.
  final bool? available;

  // final String? displayName;
  // final bool isEngaged;
  // final int queueSize;
  // final int currentQueueSize;
  /// The communication modes, chat or call, that the department supports.
  final CommunicationMode? communicationMode;

  /// Creates a department with the given attributes.
  const SalesIQDepartment({
    this.id,
    this.name,
    this.available = false,
    this.communicationMode,
  });

  /// Creates a department from its [id], [name], and supported
  /// [communicationMode].
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

  /// Creates a department from its [name] and supported [communicationMode].
  factory SalesIQDepartment.fromName(
    String? name, {
    required CommunicationMode communicationMode,
  }) {
    return SalesIQDepartment(
      name: name,
      communicationMode: communicationMode,
    );
  }

  /// Builds a [SalesIQDepartment] from the native [map]. Returns `null` when
  /// [map] is `null`.
  static SalesIQDepartment? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;

    return SalesIQDepartment(
      id: map["id"] as String?,
      name: map["name"] as String?,
      available: map["available"] as bool?,
      communicationMode: CommunicationMode.fromString(map["communicationMode"]),
    );
  }

  /// Builds a list of [SalesIQDepartment] from the native [mapList]. Returns an
  /// empty list when [mapList] is `null`.
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

  /// Converts this department to a map that the native SDKs can read.
  Map<String, Object?> toMap() {
    return {
      "id": id,
      "name": name,
      "available": available,
      "communicationMode": communicationMode?.toNativeString(),
    };
  }
}

/// Returns the [departments] that support **chat**, which means that their
/// `communicationMode` is `chat` or `chatAndCall`. It is null-safe, so it
/// returns `[]` for null.
///
/// It matches the `chatDepartments()` extension of the Android SDK. Use it
/// after `Conversation.getDepartments()` to keep only the departments that
/// support chat.
List<SalesIQDepartment> chatDepartments(List<SalesIQDepartment>? departments) {
  if (departments == null) return [];
  return departments
      .where((department) =>
          department.communicationMode == CommunicationMode.chat ||
          department.communicationMode == CommunicationMode.chatAndCall)
      .toList();
}

/// Returns the [departments] that support **calls**, which means that their
/// `communicationMode` is `call` or `chatAndCall`. It is null-safe, so it
/// returns `[]` for null. Departments with `chatAndCall` appear both in
/// [chatDepartments] and in this list, by design.
List<SalesIQDepartment> callDepartments(List<SalesIQDepartment>? departments) {
  if (departments == null) return [];
  return departments
      .where((department) =>
          department.communicationMode == CommunicationMode.call ||
          department.communicationMode == CommunicationMode.chatAndCall)
      .toList();
}
