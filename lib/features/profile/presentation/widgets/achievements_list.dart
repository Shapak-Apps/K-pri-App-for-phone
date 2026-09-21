import 'package:flutter/material.dart';
import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/profile_repository.dart';

class AchievementsList extends StatelessWidget {
  final ({int tr, int fav, int cards, int cam}) stats;

  const AchievementsList({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.l10n;
    final p = ProfileRepository.instance;
    final s = stats;

    // ── HARDER ACHIEVEMENTS ────────────────────────────────────────────────
    // All thresholds increased 2-5x to prevent one-day completion.
    // Added new categories: streak, diversity, consistency.
    final defs = <Map<String, dynamic>>[
      // Translation milestones (harder: 25/200/1000/5000 instead of 10/100/500)
      {
        'id': 'tr25',
        'ok': s.tr >= 25,
        'ic': Icons.emoji_events_rounded,
        't': 'First Steps',
        'd': 'Complete 25 translations',
        'r': 0,
      },
      {
        'id': 'tr200',
        'ok': s.tr >= 200,
        'ic': Icons.stars_rounded,
        't': 'Dedicated Translator',
        'd': 'Complete 200 translations',
        'r': 1,
      },
      {
        'id': 'tr1000',
        'ok': s.tr >= 1000,
        'ic': Icons.workspace_premium_rounded,
        't': 'Translation Veteran',
        'd': 'Complete 1000 translations',
        'r': 2,
      },
      {
        'id': 'tr5000',
        'ok': s.tr >= 5000,
        'ic': Icons.military_tech_rounded,
        't': 'Translation Legend',
        'd': 'Complete 5000 translations',
        'r': 3,
      },

      // Streak achievements (NEW)
      {
        'id': 'streak7',
        'ok': p.bestStreak >= 7,
        'ic': Icons.local_fire_department_rounded,
        't': 'Week Warrior',
        'd': '7-day streak',
        'r': 1,
      },
      {
        'id': 'streak30',
        'ok': p.bestStreak >= 30,
        'ic': Icons.whatshot_rounded,
        't': 'Monthly Master',
        'd': '30-day streak',
        'r': 2,
      },
      {
        'id': 'streak100',
        'ok': p.bestStreak >= 100,
        'ic': Icons.bolt_rounded,
        't': 'Centurion',
        'd': '100-day streak',
        'r': 3,
      },
      {
        'id': 'streak365',
        'ok': p.bestStreak >= 365,
        'ic': Icons.celebration_rounded,
        't': 'Year of Dedication',
        'd': '365-day streak',
        'r': 3,
      },

      // Favorites (harder: 50/200 instead of 20)
      {
        'id': 'fav50',
        'ok': s.fav >= 50,
        'ic': Icons.diamond_rounded,
        't': 'Phrase Collector',
        'd': 'Save 50 favorites',
        'r': 1,
      },
      {
        'id': 'fav200',
        'ok': s.fav >= 200,
        'ic': Icons.bookmark_rounded,
        't': 'Knowledge Keeper',
        'd': 'Save 200 favorites',
        'r': 2,
      },

      // Flashcards (harder: 100/500 instead of 50)
      {
        'id': 'card100',
        'ok': s.cards >= 100,
        'ic': Icons.psychology_rounded,
        't': 'Active Learner',
        'd': 'Create 100 flashcards',
        'r': 1,
      },
      {
        'id': 'card500',
        'ok': s.cards >= 500,
        'ic': Icons.school_rounded,
        't': 'Scholar',
        'd': 'Create 500 flashcards',
        'r': 2,
      },

      // Camera (harder: 25/100 instead of 10)
      {
        'id': 'cam25',
        'ok': s.cam >= 25,
        'ic': Icons.photo_camera_rounded,
        't': 'Visual Translator',
        'd': 'Translate 25 photos',
        'r': 1,
      },
      {
        'id': 'cam100',
        'ok': s.cam >= 100,
        'ic': Icons.camera_alt_rounded,
        't': 'Photo Pro',
        'd': 'Translate 100 photos',
        'r': 2,
      },

      // Level milestones (NEW)
      {
        'id': 'lvl5',
        'ok': p.level >= 5,
        'ic': Icons.trending_up_rounded,
        't': 'Rising Star',
        'd': 'Reach level 5',
        'r': 1,
      },
      {
        'id': 'lvl10',
        'ok': p.level >= 10,
        'ic': Icons.star_rounded,
        't': 'Student',
        'd': 'Reach level 10',
        'r': 2,
      },
      {
        'id': 'lvl25',
        'ok': p.level >= 25,
        'ic': Icons.star_border_rounded,
        't': 'Expert',
        'd': 'Reach level 25',
        'r': 3,
      },
    ];

    final rarColors = [
      c.sub,
      c.accent,
      const Color(0xFF9B7BFF),
      const Color(0xFFFB923C),
    ];
    final rarNames = ['Common', 'Rare', 'Epic', 'Legendary'];

    final newIds = defs
        .where((b) => (b['ok'] as bool) && !p.badgeDates.containsKey(b['id']))
        .map((b) => b['id'] as String)
        .toList();
    if (newIds.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final id in newIds) {
          p.markBadge(id);
        }
      });
    }

    return Column(
      children: defs.map((b) {
        final ok = b['ok'] as bool;
        final date = p.badgeDates[b['id']] as String?;
        final r = b['r'] as int;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ok ? c.surfaceHi : c.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ok ? rarColors[r].withValues(alpha: 0.5) : c.line,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  b['ic'] as IconData,
                  color: ok ? rarColors[r] : c.faint,
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ok ? b['t'] as String : '???',
                        style: TextStyle(
                          color: ok ? c.text : c.faint,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        ok ? (b['d'] as String) : '???',
                        style: TextStyle(
                          color: ok ? c.sub : c.faint,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ok
                            ? '${rarNames[r]}${date != null ? ' · ${_formatDate(date)}' : ''}'
                            : rarNames[r],
                        style: TextStyle(color: c.faint, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                if (ok)
                  Icon(
                    Icons.check_circle_rounded,
                    color: rarColors[r],
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(String iso) {
    try {
      final parts = iso.split('-');
      if (parts.length == 3) {
        return '${parts[2]}.${parts[1]}.${parts[0]}';
      }
    } catch (_) {}
    return iso;
  }
}
