import 'package:salesiq_mobilisten/siqtheme/siqbannercolortheme.dart';

class SIQBannerTheme {
  // ignore_for_file: public_member_api_docs

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
