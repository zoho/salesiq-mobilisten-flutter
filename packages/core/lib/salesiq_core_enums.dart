/// The communication modes supported by a department or brand.
enum CommunicationMode {
  /// Chat only.
  chat,

  /// Call only.
  call,

  /// Both chat and call.
  chatAndCall;

  /// Returns the [CommunicationMode] matching [mode], or `null` if
  /// unrecognized.
  static CommunicationMode? fromString(String? mode) {
    if (mode == null) return null;
    switch (mode) {
      case 'chat':
        return CommunicationMode.chat;
      case 'call':
        return CommunicationMode.call;
      case 'chatAndCall':
        return CommunicationMode.chatAndCall;
      default:
        return null;
    }
  }

  /// The native enum constant name for this mode ("CHAT" / "CALL" /
  /// "CHAT_AND_CALL"), used when sending departments to the native SDK.
  ///
  /// This mirrors the Android/iOS `CommunicationMode` constant names so that
  /// every native reader (Gson-backed core plugin, calls plugin, iOS Swift)
  /// deserializes the mode consistently.
  String toNativeString() {
    switch (this) {
      case CommunicationMode.chat:
        return 'CHAT';
      case CommunicationMode.call:
        return 'CALL';
      case CommunicationMode.chatAndCall:
        return 'CHAT_AND_CALL';
    }
  }
}
