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

    final defs = <Map<String, dynamic>>[
      {'id': 'tr10', 'ok': s.tr >= 10, 'ic': Icons.emoji_events_rounded, 't': l10n.t('badge_translator'), 'r': 0},
      {'id': 'tr100', 'ok': s.tr >= 100, 'ic': Icons.stars_rounded, 't': l10n.t('badge_master'), 'r': 1},
      {'id': 'tr500', 'ok': s.tr >= 500, 'ic': Icons.workspace_premium_rounded, 't': l10n.t('badge_legend'), 'r': 3},
      {'id': 'fav20', 'ok': s.fav >= 20, 'ic': Icons.diamond_rounded, 't': l10n.t('badge_collector'), 'r': 2},
      {'id': 'card50', 'ok': s.cards >= 50, 'ic': Icons.psychology_rounded, 't': l10n.t('badge_learner'), 'r': 2},
      {'id': 'cam10', 'ok': s.cam >= 10, 'ic': Icons.photo_camera_rounded, 't': l10n.t('badge_photo'), 'r': 1},
    ];

    final rarColors = [c.sub, c.accent, const Color(0xFF9B7BFF), const Color(0xFFFB923C)];
    final rarNames = [
      l10n.t('rar_common'),
      l10n.t('rar_rare'),
      l10n.t('rar_epic'),
      l10n.t('rar_legendary'),
    ];

    // Сохраняем даты ПОСЛЕ build (безопасно)
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
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ok ? c.surfaceHi : c.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: ok
                      ? (rarColors[b['r'] as int]).withValues(alpha: 0.5)
                      : c.line),
            ),
            child: Row(
              children: [
                Icon(b['ic'] as IconData,
                    color: ok ? rarColors[b['r'] as int] : c.faint, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ok ? b['t'] as String : '???',
                          style: TextStyle(
                              color: ok ? c.text : c.faint,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                      Text(
                          ok
                              ? '${rarNames[b['r'] as int]}${date != null ? ' · ${_formatDate(date)}' : ''}'
                              : l10n.t('profile_hidden'),
                          style: TextStyle(color: c.faint, fontSize: 11)),
                    ],
                  ),
                ),
                if (ok)
                  Icon(Icons.check_circle_rounded,
                      color: rarColors[b['r'] as int], size: 20),
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
        return '${parts[2]}.${parts[1]}.${parts[0]}'; // 15.01.2024
      }
    } catch (_) {}
    return iso;
  }
}