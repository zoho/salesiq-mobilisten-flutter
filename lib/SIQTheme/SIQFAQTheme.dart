import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQFAQListItemTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQArticleTheme.dart';

class SIQFAQTheme {
  SIQFAQListItemTheme listItem;
  String? headerTextColor;
  SIQArticleTheme article;

  SIQFAQTheme({
    SIQFAQListItemTheme? listItem,
    this.headerTextColor,
    SIQArticleTheme? article,
  })  : listItem = listItem ?? SIQFAQListItemTheme(),
        article = article ?? SIQArticleTheme();

  Map<String, dynamic> toMap() {
    return {
      'headerTextColor': colorToHex(headerTextColor),
      'ListItem': listItem.toMap(),
      'Article': article.toMap(),
    };
  }
}