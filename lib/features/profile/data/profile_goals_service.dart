/// Goal ladder: escalation stops at 150 — no infinite growth.
/// Success  → next rung up.
/// Failure  → one rung DOWN (punishment) + streak reset (in repository).
class ProfileGoalsService {
  static const List<int> ladder = [10, 30, 60, 90, 120, 150];

  /// Presets for quick-settings = the ladder itself.
  static const List<int> presetGoals = ladder;

  static int rungToGoal(int rung) => ladder[rung.clamp(0, ladder.length - 1)];

  static int goalToRung(int goal) {
    var best = 0;
    var bestDiff = (ladder[0] - goal).abs();
    for (var i = 1; i < ladder.length; i++) {
      final d = (ladder[i] - goal).abs();
      if (d < bestDiff) {
        bestDiff = d;
        best = i;
      }
    }
    return best;
  }

  static int nextGoal(int rung) => rungToGoal(rung + 1);
  static int prevGoal(int rung) => rungToGoal(rung - 1);

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

  /// Formats remaining milliseconds as HH:MM:SS countdown.
  static String countdown(int ms) {
    if (ms <= 0) return '00:00:00';
    final total = ms ~/ 1000;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(h)}:${two(m)}:${two(s)}';
  }
}
