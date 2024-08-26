import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQLoadMoreViewTheme {
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
