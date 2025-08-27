enum CommunicationMode {
  chat,
  call,
  chatAndCall;

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
}
