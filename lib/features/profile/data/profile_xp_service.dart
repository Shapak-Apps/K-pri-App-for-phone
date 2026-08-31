import 'native/profile_ffi.dart';

class ProfileXpService {
  static final _ffi = ProfileFFI();

  static int getLevel(int xp) => _ffi.getLevel(xp);
  static int getXpForNextLevel(int xp) => _ffi.getXpForNextLevel(xp);
  static int getXpForCurrentLevel(int xp) => _ffi.getXpForCurrentLevel(xp);
  static double getLevelProgress(int xp) => _ffi.getLevelProgress(xp);

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
    if (level >= 100) return 'Легенда перевода';
    if (level >= 80) return 'Гранд-мастер';
    if (level >= 65) return 'Виртуоз';
    if (level >= 50) return 'Мастер слов';
    if (level >= 40) return 'Профессионал';
    if (level >= 30) return 'Уверенный переводчик';
    if (level >= 20) return 'Звезда';
    if (level >= 15) return 'Практик';
    if (level >= 10) return 'Ученик';
    return 'Новичок';
  }
}