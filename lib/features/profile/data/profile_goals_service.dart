class ProfileGoalsService {
  static const List<int> presetGoals = [5, 10, 20, 50];

  static double progress(int done, int goal) =>
      goal > 0 ? (done / goal).clamp(0.0, 1.0) : 0.0;

  static String format(int done, int goal) => '$done/$goal';

  static bool isDone(int done, int goal) => done >= goal;

  static String motivation(int done, int goal) {
    if (done >= goal) return '🎉';
    final left = goal - done;
    if (left <= 2) return '💪';
    if (left <= 5) return '🔥';
    return '🚀';
  }
}