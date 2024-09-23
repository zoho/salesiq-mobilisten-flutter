import 'package:salesiq_mobilisten/siqtheme/siqfaqbottombartheme.dart';

class SIQArticleTheme {
  // ignore_for_file: public_member_api_docs

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
