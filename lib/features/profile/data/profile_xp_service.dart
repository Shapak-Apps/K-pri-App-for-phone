import 'native/profile_ffi.dart';

class ProfileXpService {
  static final _ffi = ProfileFFI();

  static int getLevel(int xp) => _ffi.getLevel(xp);
  static int getXpForNextLevel(int xp) => _ffi.getXpForNextLevel(xp);
  static int getXpForCurrentLevel(int xp) => _ffi.getXpForCurrentLevel(xp);
  static double getLevelProgress(int xp) => _ffi.getLevelProgress(xp);

  // 1 XP per letter of the TRANSLATED text (cap 500),
  // +30% rare language, +50 first translation of the window.
  // charCount/isFirstInWindow.
  static int computeTranslationXp({
    required String resultText,
    required String targetLanguage,
    required bool isFirstInWindow,
  }) {
    return _ffi.computeTranslationXp(
      charCount: countChars(resultText),
      isRareLanguage: isRareLanguage(targetLanguage),
      isFirstInWindow: isFirstInWindow,
    );
  }

  // ── Daily cap (grows with level) ──────────────────────────────────────────
  static int getDailyCap(int level) => _ffi.dailyXpCap(level);

  // ── Diminishing returns multiplier ────────────────────────────────────────
  static double getXpMultiplier(int translationsToday) =>
      _ffi.xpMultiplier(translationsToday);

  // ── Helpers ──────────────────────────────────────────────────────────────
  /// Counts letters only (no spaces/punctuation) — "буквы перевода".
  /// FIXED: replacement '' belongs to replaceAll(), not to RegExp().
  static int countChars(String text) => text
      .replaceAll(RegExp(r'[^a-zA-Zа-яА-ЯёЁçÇöÖüÜşŞğĞıIäÄæÆňŇöÖüÜýÝžŽ]'), '')
      .length;

  // Common languages = native, no bonus.
  // Everything else = rare language, +30% XP.
  static bool isRareLanguage(String code) {
    const common = {'en', 'ru', 'tk', 'tr'};
    return !common.contains(code.toLowerCase());
  }

  static String getLevelEmoji(int level) {
    if (level >= 100) return '👑';
    if (level >= 80) return '🔮';
    if (level >= 65) return '🌟';
    if (level >= 50) return '💎';
    if (level >= 40) return '🏆';
    if (level >= 30) return '🚀';
    if (level >= 20) return '⭐';
    if (level >= 15) return '🔥';
    if (level >= 10) return '⚡';
    return '🌱';
  }

  static String getLevelTitle(int level) {
    if (level >= 100) return 'Translation Legend';
    if (level >= 80) return 'Grand Master';
    if (level >= 65) return 'Virtuoso';
    if (level >= 50) return 'Word Master';
    if (level >= 40) return 'Professional';
    if (level >= 30) return 'Confident Translator';
    if (level >= 20) return 'Rising Star';
    if (level >= 15) return 'Practitioner';
    if (level >= 10) return 'Student';
    return 'Beginner';
  }
}
