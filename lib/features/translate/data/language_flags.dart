import 'native/translate_ffi.dart';

const _langToCountry = <String, String>{
  'az': 'AZ',
  'af': 'ZA',
  'sq': 'AL',
  'am': 'ET',
  'en': 'GB',
  'ar': 'SA',
  'hy': 'AM',
  'eu': 'ES',
  'be': 'BY',
  'bn': 'BD',
  'my': 'MM',
  'bg': 'BG',
  'bs': 'BA',
  'cy': 'GB',
  'hu': 'HU',
  'vi': 'VN',
  'gl': 'ES',
  'el': 'GR',
  'ka': 'GE',
  'gu': 'IN',
  'da': 'DK',
  'zu': 'ZA',
  'he': 'IL',
  'id': 'ID',
  'ga': 'IE',
  'is': 'IS',
  'es': 'ES',
  'it': 'IT',
  'yo': 'NG',
  'kk': 'KZ',
  'kn': 'IN',
  'ca': 'ES',
  'ky': 'KG',
  'zh': 'CN',
  'ko': 'KR',
  'km': 'KH',
  'lo': 'LA',
  'la': 'VA',
  'lv': 'LV',
  'lt': 'LT',
  'mk': 'MK',
  'ms': 'MY',
  'ml': 'IN',
  'mt': 'MT',
  'mr': 'IN',
  'mn': 'MN',
  'ne': 'NP',
  'nl': 'NL',
  'no': 'NO',
  'pa': 'IN',
  'fa': 'IR',
  'pl': 'PL',
  'pt': 'PT',
  'ro': 'RO',
  'ru': 'RU',
  'sr': 'RS',
  'si': 'LK',
  'sk': 'SK',
  'sl': 'SI',
  'sw': 'TZ',
  'tg': 'TJ',
  'th': 'TH',
  'ta': 'IN',
  'te': 'IN',
  'tr': 'TR',
  'tk': 'TM',
  'uz': 'UZ',
  'uk': 'UA',
  'ur': 'PK',
  'fi': 'FI',
  'fr': 'FR',
  'hi': 'IN',
  'hr': 'HR',
  'cs': 'CZ',
  'sv': 'SE',
  'et': 'EE',
  'ja': 'JP',
};

/// Flag emoji for a translation language code, built from the country
/// code in [_langToCountry]. Used by the language chips and Settings.
String langFlagFor(String code) {
  if (code == 'auto') return '🌐';
  final cc = _langToCountry[code];
  if (cc == null || cc.length != 2) return '🏳️';

  try {
    final native = TranslateFFI().flag(cc);
    if (native != null && native.isNotEmpty) return native;
  } catch (_) {}

  const base = 0x1F1E6 - 0x41;
  return String.fromCharCode(base + cc.codeUnitAt(0)) +
      String.fromCharCode(base + cc.codeUnitAt(1));
}
