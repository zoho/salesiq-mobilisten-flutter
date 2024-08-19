import 'package:salesiq_mobilisten/SIQTheme/SIQBannerColorTheme.dart';

class SIQBannerTheme {
  SIQBannerColorTheme successTheme;
  SIQBannerColorTheme infoTheme;
  SIQBannerColorTheme failureTheme;

  SIQBannerTheme({
    SIQBannerColorTheme? successTheme,
    SIQBannerColorTheme? infoTheme,
    SIQBannerColorTheme? failureTheme,
  })  : successTheme = successTheme ?? SIQBannerColorTheme(),
        infoTheme = infoTheme ?? SIQBannerColorTheme(),
        failureTheme = failureTheme ?? SIQBannerColorTheme();

  Map<String, dynamic> toMap() {
    return {
      'successTheme': successTheme.toMap(),
      'infoTheme': infoTheme.toMap(),
      'failureTheme': failureTheme.toMap(),
    };
  }
}
