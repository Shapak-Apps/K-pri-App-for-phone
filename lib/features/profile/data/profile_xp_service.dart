import 'dart:math' as math;
import 'native/profile_ffi.dart';

class ProfileXpService {
  static final _ffi = ProfileFFI();
  static const int baseXpPerLevel = 100;
  static const double xpGrowthFactor = 1.15;

  static int getLevel(int xp) => _ffi.getLevel(xp);

  static int getXpForNextLevel(int currentXp) =>
      _ffi.getXpForNextLevel(currentXp);

  static int getXpForCurrentLevel(int currentXp) =>
      _ffi.getXpForCurrentLevel(currentXp);

  static double getLevelProgress(int xp) => _ffi.getLevelProgress(xp);

  // UI-методы остаются как были
  static String getLevelTitle(int level) { /* как было */ return ''; }
  static String getLevelEmoji(int level) { /* как было */ return ''; }
}