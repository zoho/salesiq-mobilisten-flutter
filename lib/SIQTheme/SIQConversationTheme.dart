import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQConversationListItemTheme.dart';

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
