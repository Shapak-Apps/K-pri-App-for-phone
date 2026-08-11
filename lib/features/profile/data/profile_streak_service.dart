class ProfileStreakService {
  /// Форматирование стрика
  static String formatStreak(int days) {
    if (days == 0) return 'Начни сегодня!';
    if (days == 1) return '1 день';
    if (days < 5) return '$days дня';
    return '$days дней';
  }

  /// Сообщение мотивации
  static String getMotivationMessage(int streak) {
    if (streak >= 365) return 'Ты невероятен! Целый год! 🔥';
    if (streak >= 180) return 'Полгода подряд! Легенда! 👑';
    if (streak >= 100) return '100 дней! Ты машина! 💪';
    if (streak >= 60) return '2 месяца! Отличная работа! 🎉';
    if (streak >= 30) return 'Месяц подряд! Молодец! 🔥';
    if (streak >= 14) return '2 недели! Продолжай! 📚';
    if (streak >= 7) return 'Неделя! Отличное начало! 🌟';
    if (streak >= 3) return 'Хороший старт! 💪';
    if (streak >= 1) return 'Начало положено! 🚀';
    return 'Начни свою серию сегодня!';
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
