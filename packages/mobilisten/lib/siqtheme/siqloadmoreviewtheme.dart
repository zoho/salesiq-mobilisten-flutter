import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQLoadMoreViewTheme {
  // ignore_for_file: public_member_api_docs

  String? titleColor;
  String? viewBorderColor;
  String? separatorLineColor;

  SIQLoadMoreViewTheme({
    this.titleColor,
    this.viewBorderColor,
    this.separatorLineColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'titleColor': colorToHex(titleColor),
      'viewBorderColor': colorToHex(viewBorderColor),
      'separatorLineColor': colorToHex(separatorLineColor),
    };
  }
}
