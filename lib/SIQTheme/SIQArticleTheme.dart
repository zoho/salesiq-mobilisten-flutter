import 'package:salesiq_mobilisten/SIQTheme/SIQFAQBottomBarTheme.dart';

class SIQArticleTheme {
  SIQFAQBottomBarTheme toolbar;

  SIQArticleTheme({
    SIQFAQBottomBarTheme? toolbar,
  }) : toolbar = toolbar ?? SIQFAQBottomBarTheme();

  Map<String, dynamic> toMap() {
    return {
      'Toolbar': toolbar.toMap(),
    };
  }
}
