import '../../../core/l10n/app_strings.dart';

/// Support bot used by all feedback flows.
const String kTelegramUrl = 'https://t.me/kopri_support_bot';

/// Sample phrase used by the TTS preview tile.
String ttsExampleFor(AppLang lang) => switch (lang) {
  AppLang.ru => 'Привет, как дела?',
  AppLang.tk => 'Salam, ýagdaýyňyz nähili?',
  AppLang.en => 'Hello, how are you?',
  AppLang.tr => 'Merhaba, nasılsınız?',
};
