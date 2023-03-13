class SIQTab {
  const SIQTab._(this.index);
  final int index;

  static const SIQTab conversations = SIQTab._(0);
  static const SIQTab faq = SIQTab._(1);

  static const List<SIQTab> values = <SIQTab>[conversations, faq];

  @override
  String toString() {
    return const <int, String>{0: 'TAB_CONVERSATIONS', 1: 'TAB_FAQ'}[index]!;
  }
}
