const Map<String, String> kLangTextByCode = {
  'auto': '🌐 Auto-detect',
  'tk': '🇹🇲 Türkmençe',
  'ru': '🇷🇺 Русский',
  'en': '🇬🇧 English',
  'tr': '🇹🇷 Türkçe',
  'zh': '🇨🇳 中文',
  'ja': '🇯🇵 日本語',
  'ko': '🇰🇷 한국어',
  'fr': '🇫🇷 Français',
  'de': '🇩🇪 Deutsch',
  'it': '🇮🇹 Italiano',
  'es': '🇪🇸 Español',
  'pt': '🇵🇹 Português',
  'nl': '🇳🇱 Nederlands',
  'pl': '🇵🇱 Polski',
  'sv': '🇸🇪 Svenska',
  'da': '🇩🇰 Dansk',
  'no': '🇳🇴 Norsk',
  'fi': '🇫 Suomi',
  'el': '🇬🇷 Ελληνικά',
  'hu': '🇭🇺 Magyar',
  'cs': '🇨🇿 Čeština',
  'ro': '🇷🇴 Română',
  'bg': '🇧🇬 Български',
  'hi': '🇮🇳 हिन्दी',
  'th': '🇹🇭 ไทย',
  'vi': '🇻🇳 Tiếng Việt',
  'id': '🇮🇩 Indonesia',
  'ms': '🇲🇾 Melayu',
  'tl': '🇵🇭 Filipino',
  'km': '🇰🇭 ខ្មែរ',
  'lo': '🇱🇦 າວ',
  'my': '🇲🇲 မြန်မာ',
  'kk': '🇰🇿 Қазақша',
  'uz': "🇺🇿 O'zbek",
  'ky': '🇰🇬 Кыргызча',
  'tg': '🇹🇯 Тоҷикӣ',
  'ar': '🇸 العربية',
  'he': '🇮🇱 עברית',
  'fa': '🇮🇷 فارسی',
  'az': '🇦🇿 Azərbaycan',
  'af': '🇿🇦 Afrikaans',
  'zu': '🇿🇦 isiZulu',
  'sw': '🇰🇪 Kiswahili',
  'yo': '🇳🇬 Yorùbá',
  'sq': '🇦🇱 Shqip',
  'hy': '🇦🇲 Հայերեն',
  'am': '🇪🇹 አማርኛ',
  'bn': '🇧🇩 বাংলা',
  'ka': '🇬🇪 ქართული',
  'ga': '🇮🇪 Gaeilge',
  'is': '🇮🇸 Íslenska',
  'lv': '🇱🇻 Latviešu',
  'lt': '🇱🇹 Lietuvių',
  'mk': '🇲🇰 Македонски',
  'mt': '🇲🇹 Malti',
  'mn': '🇲🇳 Монгол',
  'ne': '🇳🇵 नेपाली',
  'ur': '🇵🇰 اردو',
  'sr': '🇷🇸 Српски',
  'sk': '🇸🇰 Slovenčina',
  'sl': '🇸🇮 Slovenščina',
  'si': '🇱🇰 සිංහල',
  'uk': '🇺🇦 Українська',
  'hr': '🇭🇷 Hrvatski',
  'et': '🇪🇪 Eesti',
  'la': '🇻🇦 Latina',
};

final Map<String, String> kLangCodeByText = {
  for (final e in kLangTextByCode.entries) e.value: e.key,
};

const Map<String, List<String>> kRegionCodes = {
  '🌍 Популярные': ['tk', 'ru', 'en', 'tr', 'zh', 'ja', 'ko'],
  '🇪🇺 Европа': [
    'fr',
    'de',
    'it',
    'es',
    'pt',
    'nl',
    'pl',
    'sv',
    'da',
    'no',
    'fi',
    'el',
    'hu',
    'cs',
    'ro',
    'bg',
  ],
  '🌏 Азия': [
    'hi',
    'th',
    'vi',
    'id',
    'ms',
    'tl',
    'km',
    'lo',
    'my',
    'kk',
    'uz',
    'ky',
    'tg',
  ],
  '🕌 Ближний Восток': ['ar', 'he', 'fa', 'az'],
  '🌍 Африка': ['af', 'zu', 'sw', 'yo'],
  '🌎 Другие': [
    'sq',
    'hy',
    'am',
    'bn',
    'ka',
    'ga',
    'is',
    'lv',
    'lt',
    'mk',
    'mt',
    'mn',
    'ne',
    'ur',
    'sr',
    'sk',
    'sl',
    'si',
    'uk',
    'hr',
    'et',
    'la',
  ],
};

List<Map<String, List<String>>> buildLanguageLinkageData({
  bool includeAuto = false,
}) {
  return [
    if (includeAuto)
      {
        '🤖 Auto': [kLangTextByCode['auto']!],
      },
    for (final e in kRegionCodes.entries)
      {
        e.key: [for (final code in e.value) kLangTextByCode[code]!],
      },
  ];
}

String? extractLangCodeFromText(String text) => kLangCodeByText[text];

String langTextByCode(String code) => kLangTextByCode[code] ?? '🌐 $code';

List<int> languageIndicesFor(String code, {bool includeAuto = false}) {
  final data = buildLanguageLinkageData(includeAuto: includeAuto);
  final target = langTextByCode(code);
  for (var i = 0; i < data.length; i++) {
    final langs = data[i].values.first;
    final j = langs.indexOf(target);
    if (j >= 0) return [i, j];
  }
  return [0, 0];
}
