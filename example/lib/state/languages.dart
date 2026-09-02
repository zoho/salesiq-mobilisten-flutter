/// A small language cycle used by Core & Settings to demonstrate
/// `ZohoSalesIQ.setLanguage`. Mirrors the RN `constants/languages`.
class AppLanguage {
  final String label;
  final String code;
  const AppLanguage(this.label, this.code);
}

const List<AppLanguage> kLanguages = [
  AppLanguage('English', 'en'),
  AppLanguage('Spanish', 'es'),
  AppLanguage('French', 'fr'),
  AppLanguage('German', 'de'),
  AppLanguage('Japanese', 'ja'),
];

AppLanguage nextLanguage(String currentLabel) {
  final index =
      kLanguages.indexWhere((language) => language.label == currentLabel);
  return kLanguages[(index + 1) % kLanguages.length];
}
