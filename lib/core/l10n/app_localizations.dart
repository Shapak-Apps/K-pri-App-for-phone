import 'app_strings.dart';

class AppLocalizations {
  final AppLang lang;
  const AppLocalizations(this.lang);

  String t(String key) {
    final primary = appStrings[lang];
    final fallback = appStrings[AppLang.en];
    return primary?[key] ?? fallback?[key] ?? key;
  }
}
