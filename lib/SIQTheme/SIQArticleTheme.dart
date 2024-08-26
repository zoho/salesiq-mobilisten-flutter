import 'package:salesiq_mobilisten/siqtheme/siqfaqbottombartheme.dart';

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
