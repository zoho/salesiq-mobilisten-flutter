class SIQTab {
  // ignore_for_file: public_member_api_docs
  // ignore_for_file: deprecated_member_use_from_same_package

  const SIQTab._(this.index);

  final int index;

  static const SIQTab conversations = SIQTab._(0);
  static const SIQTab knowledgeBase = SIQTab._(1);

  /// See [knowledgeBase].
  @Deprecated(
      "This constant was deprecated after v3.1.2, Use knowledgeBase constant instead.")
  static const SIQTab faq = SIQTab._(2);

  static const List<SIQTab> values = <SIQTab>[
    conversations,
    knowledgeBase,
    faq
  ];

  @override
  String toString() {
    return const <int, String>{
      0: 'TAB_CONVERSATIONS',
      1: 'TAB_KNOWLEDGE_BASE',
      2: 'TAB_FAQ'
    }[index]!;
  }
}
