/// Defines the communication modes that a department or brand supports.
enum CommunicationMode {
  /// Chat only.
  chat,

  /// Call only.
  call,

  /// Both chat and call.
  chatAndCall;

  /// Returns the [CommunicationMode] that matches [mode], or `null` if it is
  /// not recognized.
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

  /// Returns the native enum constant name for this mode, which is "CHAT",
  /// "CALL", or "CHAT_AND_CALL". The SDK uses it when it sends departments to
  /// the native SDK.
  ///
  /// These names match the `CommunicationMode` constant names on Android and
  /// iOS.
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
