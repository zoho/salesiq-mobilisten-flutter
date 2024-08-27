import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQArticleMessageTheme {
  String? cardTitleColor;
  String? articleTitleColor;
  String? authorTextColor;
  String? backgroundColor;

  SIQArticleMessageTheme({
    this.cardTitleColor,
    this.articleTitleColor,
    this.authorTextColor,
    this.backgroundColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'cardTitleColor': colorToHex(cardTitleColor),
      'articleTitleColor': colorToHex(articleTitleColor),
      'authorTextColor': colorToHex(authorTextColor),
      'backgroundColor': colorToHex(backgroundColor),
    };
  }
}
