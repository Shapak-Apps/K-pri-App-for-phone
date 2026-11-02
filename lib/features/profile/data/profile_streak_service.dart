import '../../../core/l10n/app_strings.dart';

class ProfileStreakService {
  /// The app_strings key of the word "day" after the number [n]. Russian has
  /// 3 forms: 1 день, 2 дня, 5 дней (and 21 день, 11 дней).
  static String daysKey(int n, AppLang lang) {
    if (lang != AppLang.ru) return n == 1 ? 'streak_day' : 'streak_days';
    if (n % 10 == 1 && n % 100 != 11) return 'streak_day';
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) {
      return 'streak_days_few';
    }
    return 'streak_days';
  }

  /// The app_strings key of the motivation message.
  static String motivationKey(int streak) {
    if (streak >= 365) return 'streak_msg_365';
    if (streak >= 180) return 'streak_msg_180';
    if (streak >= 100) return 'streak_msg_100';
    if (streak >= 60) return 'streak_msg_60';
    if (streak >= 30) return 'streak_msg_30';
    if (streak >= 14) return 'streak_msg_14';
    if (streak >= 7) return 'streak_msg_7';
    if (streak >= 3) return 'streak_msg_3';
    if (streak >= 1) return 'streak_msg_1';
    return 'streak_msg_0';
  }

  /// Иконка стрика
  static String getStreakEmoji(int streak) {
    if (streak >= 100) return '🔥🔥🔥';
    if (streak >= 30) return '🔥🔥';
    if (streak >= 7) return '🔥';
    if (streak >= 1) return '⚡';
    return '💤';
  }
}
