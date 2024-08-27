import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';
import 'package:salesiq_mobilisten/siqtheme/siqconversationlistitemtheme.dart';

class SIQConversationTheme {
  String? backgroundColor;
  SIQConversationListItemTheme listItem;

  SIQConversationTheme({
    this.backgroundColor,
    SIQConversationListItemTheme? listItem,
  }) : listItem = listItem ?? SIQConversationListItemTheme();

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'ListItem': listItem.toMap(),
    };
  }
}
