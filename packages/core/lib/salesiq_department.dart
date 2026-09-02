import 'salesiq_core_enums.dart';

/// A SalesIQ department a conversation can be routed to.
class SalesIQDepartment {
  /// Unique identifier of the department.
  final String? id;

  /// Display name of the department.
  final String? name;

  /// Whether the department is currently available.
  final bool? available;

  // final String? displayName;
  // final bool isEngaged;
  // final int queueSize;
  // final int currentQueueSize;
  /// The communication modes (chat/call) supported by the department.
  final CommunicationMode? communicationMode;

  /// Creates a department with the given attributes.
  const SalesIQDepartment({
    this.id,
    this.name,
    this.available = false,
    this.communicationMode,
  });

  /// Creates a department from its [id], [name] and supported
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

  /// Builds a [SalesIQDepartment] from the native [map], or `null` when
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

  /// Builds a list of [SalesIQDepartment] from the native [mapList],
  /// returning an empty list when [mapList] is `null`.
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

  /// Serializes this department to a native-compatible map.
  Map<String, Object?> toMap() {
    return {
      "id": id,
      "name": name,
      "available": available,
      "communicationMode": communicationMode?.toNativeString(),
    };
  }
}

/// Filters [departments] to those usable for **chat** — `communicationMode` is `chat` or `chatAndCall`.
/// Null-safe (returns `[]` for null).
///
/// Cross-platform counterpart of the Android SDK's `List<SIQDepartment>.chatDepartments()` extension
/// (com.zoho.livechat.android.modules.extensions.SIQDepartmentExtensions). Use it after
/// `Conversation.getDepartments()` to keep only chat-capable departments.
List<SalesIQDepartment> chatDepartments(List<SalesIQDepartment>? departments) {
  if (departments == null) return [];
  return departments
      .where((department) =>
          department.communicationMode == CommunicationMode.chat ||
          department.communicationMode == CommunicationMode.chatAndCall)
      .toList();
}

/// Filters [departments] to those usable for **calls** — `communicationMode` is `call` or `chatAndCall`.
/// Null-safe (returns `[]` for null). `chatAndCall` departments intentionally appear in both
/// [chatDepartments] and this list.
List<SalesIQDepartment> callDepartments(List<SalesIQDepartment>? departments) {
  if (departments == null) return [];
  return departments
      .where((department) =>
          department.communicationMode == CommunicationMode.call ||
          department.communicationMode == CommunicationMode.chatAndCall)
      .toList();
}
