import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';

class SIQSliderCardTheme {
  // ignore_for_file: public_member_api_docs

  String? thumbBorderColor;
  String? selectedTrackColor;
  String? selectedValueTextColor;
  String? unSelectedTrackColor;
  String? thumbBackgroundColor;

  String? minRangeTextColor;
  String? maxRangeTextColor;

  SIQSliderCardTheme({
    this.thumbBorderColor,
    this.selectedTrackColor,
    this.selectedValueTextColor,
    this.unSelectedTrackColor,
    this.thumbBackgroundColor,
    this.minRangeTextColor,
    this.maxRangeTextColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'thumbBorderColor': colorToHex(thumbBorderColor),
      'selectedTrackColor': colorToHex(selectedTrackColor),
      'selectedValueTextColor': colorToHex(selectedValueTextColor),
      'unSelectedTrackColor': colorToHex(unSelectedTrackColor),
      'thumbBackgroundColor': colorToHex(thumbBackgroundColor),
      'minRangeTextColor': colorToHex(minRangeTextColor),
      'maxRangeTextColor': colorToHex(maxRangeTextColor),
    };
  }
}
