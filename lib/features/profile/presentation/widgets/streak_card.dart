import 'package:flutter/material.dart';
import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/profile_repository.dart';
import '../../data/profile_streak_service.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.l10n;
    final p = ProfileRepository.instance;
    String days(int n) =>
        '$n ${l10n.t(ProfileStreakService.daysKey(n, l10n.lang))}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            c.accent.withValues(alpha: 0.15),
            c.accent.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                ProfileStreakService.getStreakEmoji(p.streak),
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      days(p.streak),
                      style: TextStyle(
                        color: c.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      l10n.t(ProfileStreakService.motivationKey(p.streak)),
                      style: TextStyle(color: c.sub, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events_rounded, color: c.accent, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${l10n.t('streak_record')}: ${days(p.bestStreak)}',
                  style: TextStyle(
                    color: c.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}