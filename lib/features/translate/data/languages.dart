abstract final class AppLanguages {
  static const Map<String, String> all = {
    'az': 'Azərbaycan',
    'af': 'Afrikaans',
    'sq': 'Shqip',
    'am': 'አማርኛ',
    'en': 'English',
    'ar': 'العربية',
    'hy': 'Հայերեն',
    'eu': 'Euskara',
    'be': 'Беларуская',
    'bn': 'বাংলা',
    'my': 'မြန်မာ',
    'bg': 'Български',
    'bs': 'Bosanski',
    'cy': 'Cymraeg',
    'hu': 'Magyar',
    'vi': 'Tiếng Việt',
    'gl': 'Galego',
    'el': 'Ελληνικά',
    'ka': 'ქართული',
    'gu': 'ગુજરાતી',
    'da': 'Dansk',
    'zu': 'isiZulu',
    'he': 'עברית',
    'id': 'Indonesia',
    'ga': 'Gaeilge',
    'is': 'Íslenska',
    'es': 'Español',
    'it': 'Italiano',
    'yo': 'Yorùbá',
    'kk': 'Қазақша',
    'kn': 'ಕನ್ನಡ',
    'ca': 'Català',
    'ky': 'Кыргызча',
    'zh': '中文',
    'ko': '한국어',
    'km': 'ខ្មែរ',
    'lo': 'ລາວ',
    'la': 'Latina',
    'lv': 'Latviešu',
    'lt': 'Lietuvių',
    'mk': 'Македонски',
    'ms': 'Melayu',
    'ml': 'മലയാളം',
    'mt': 'Malti',
    'mr': 'मराठी',
    'mn': 'Монгол',
    'ne': 'नेपाली',
    'nl': 'Nederlands',
    'no': 'Norsk',
    'pa': 'ਪੰਜਾਬੀ',
    'fa': 'فارسی',
    'pl': 'Polski',
    'pt': 'Português',
    'ro': 'Română',
    'ru': 'Русский',
    'sr': 'Српски',
    'si': 'සිංහල',
    'sk': 'Slovenčina',
    'sl': 'Slovenščina',
    'sw': 'Kiswahili',
    'tg': 'Тоҷикӣ',
    'th': 'ไทย',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
    'tr': 'Türkçe',
    'tk': 'Türkmençe',
    'uz': 'O‘zbek',
    'uk': 'Українська',
    'ur': 'اردو',
    'fi': 'Suomi',
    'fr': 'Français',
    'hi': 'हिन्दी',
    'hr': 'Hrvatski',
    'cs': 'Čeština',
    'sv': 'Svenska',
    'et': 'Eesti',
    'ja': '日本語',
  };

  // ── WORD-ONLY LANGUAGES ──────────────────────────────────────────────────
  // These languages translate SINGLE WORDS today. Sentence-level translation
  // is reserved for a future release. Selection is NOT blocked — only a
  // warning is shown in the picker, and sentence input is refused at
  // translate-time. Remove a code to enable full sentences.
  static const Set<String> wordOnly = {'tk'};
  static const String sentenceComingSoonVersion = 'v3.0.0';

  static bool isWordOnly(String code) => wordOnly.contains(code);

  /// True when the text is a sentence (more than one whitespace-separated
  /// token). Empty / single-word strings return false.
  static bool isSentence(String text) {
    final t = text.trim();
    if (t.isEmpty) return false;
    return t.split(RegExp(r'\s+')).length > 1;
  }

  static Map<String, String> get sources => {'auto': 'Awtomat', ...all};

  static String nameOf(String code) =>
      code == 'auto' ? 'Awtomat' : (all[code] ?? code.toUpperCase());
}