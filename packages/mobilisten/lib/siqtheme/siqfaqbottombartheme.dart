import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';
import 'package:salesiq_mobilisten/siqtheme/siqbuttontheme.dart';

class SIQFAQBottomBarTheme {
  // ignore_for_file: public_member_api_docs

  String? backgroundColor;
  SIQButtonTheme likeButton;
  SIQButtonTheme dislikeButton;

  SIQFAQBottomBarTheme({
    this.backgroundColor,
    SIQButtonTheme? likeButton,
    SIQButtonTheme? dislikeButton,
  })  : likeButton = likeButton ?? SIQButtonTheme(),
        dislikeButton = dislikeButton ?? SIQButtonTheme();

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': colorToHex(backgroundColor),
      'LikeButton': likeButton.toMap(),
      'DislikeButton': dislikeButton.toMap(),
    };
  }
}
