import 'package:hive_flutter/hive_flutter.dart';

import '../../camera/data/camera_repository.dart';
import '../../history/data/history_repository.dart';

/// Aggregate activity counters displayed on the profile tab.
typedef ProfileStats = ({int tr, int fav, int cards, int cam});

/// Reads history / flashcards / camera counters defensively:
/// a missing or not-yet-opened Hive box must never crash the profile tab.
ProfileStats computeProfileStats(HistoryRepository repo) {
  var tr = 0;
  var fav = 0;
  var cards = 0;
  try {
    tr = repo.count;
    fav = repo.favoritesCount;
  } catch (_) {}
  try {
    if (Hive.isBoxOpen('flashcards')) cards = Hive.box('flashcards').length;
  } catch (_) {}
  final cam = CameraRepository.instance.isReady
      ? CameraRepository.instance.count
      : 0;
  return (tr: tr, fav: fav, cards: cards, cam: cam);
}
